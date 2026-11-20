const {setGlobalOptions} = require("firebase-functions");
const {onSchedule} = require("firebase-functions/scheduler");
const {defineSecret} = require("firebase-functions/params");
const logger = require("firebase-functions/logger");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, Timestamp} = require("firebase-admin/firestore");
const {Resend} = require("resend");

initializeApp();
setGlobalOptions({region: "europe-west1", maxInstances: 1});

const resendApiKey = defineSecret("RESEND_API_KEY");

// Every 15 minutes: email the contacts of users who missed their deadline.
exports.checkMissedDeadlines = onSchedule(
  {schedule: "every 15 minutes", secrets: [resendApiKey]},
  async () => {
    const db = getFirestore();
    const resend = new Resend(resendApiKey.value());

    const snapshot = await db.collection("users")
      .where("alertSent", "==", false)
      .where("nextDeadline", "<=", Timestamp.now())
      .get();

    logger.info(`Found ${snapshot.size} missed check-ins`);

    for (const doc of snapshot.docs) {
      const contacts = doc.get("contacts") || [];

      // Nobody to email: mark it as handled so we don't check it again.
      if (contacts.length === 0) {
        await doc.ref.update({alertSent: true});
        continue;
      }

      const {error} = await resend.emails.send({
        from: "DailyCheck <onboarding@resend.dev>",
        to: contacts,
        subject: "DailyCheck: a missed check-in",
        text: "Someone who added you as a contact in DailyCheck " +
          "did not check in before their deadline today. " +
          "Please call or visit them to make sure they are okay.",
      });

      // Email failed: keep alertSent false, so we try again in 15 minutes.
      if (error) {
        logger.error(`Email failed for user ${doc.id}`, error);
        continue;
      }

      await doc.ref.update({alertSent: true});
      logger.info(`Alert sent for user ${doc.id}`);
    }
  },
);

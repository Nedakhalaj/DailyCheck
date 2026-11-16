//
//  NotificationManager.swift
//  DailyCheck
//
//  Created by neda khalajnejad on 2026-11-13.
//

import UserNotifications

enum NotificationManager {
   
    // Shows the "Allow notifications?" popup. iOS shows it only once.
    static func requestPermission() async {
        do {
            _ = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
        } catch {
            print("Notification permission error: \(error)")
        }
    }

    // Plans one reminder per day for the next 7 days, 1 hour before the deadline.
    // Skips today if the user already checked in today.
    static func scheduleReminders(deadlineMinutes: Int, lastCheckIn: Date?) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let calendar = Calendar.current
        let now = Date()

        var checkedInToday = false
        if let lastCheckIn {
            checkedInToday = calendar.isDateInToday(lastCheckIn)
        }

        let content = UNMutableNotificationContent()
        content.title = "Time to check in"
        content.body = "Open Daily Check and tap I'm okay."
        content.sound = .default

        for dayOffset in 0..<7 {
            if dayOffset == 0 && checkedInToday {
                continue
            }

            guard
                let day = calendar.date(byAdding: .day, value: dayOffset, to: now),
                let deadline = calendar.date(
                    bySettingHour: deadlineMinutes / 60,
                    minute: deadlineMinutes % 60,
                    second: 0,
                    of: day
                )
            else { continue }

            let reminderDate = deadline.addingTimeInterval(-60 * 60)
            if reminderDate <= now {
                continue
            }

            let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
            let request = UNNotificationRequest(identifier: "reminder-\(dayOffset)", content: content, trigger: trigger)
            center.add(request)
        }
    }
}

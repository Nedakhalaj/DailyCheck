//
//  FirestoreService.swift
//  DailyCheck
//
//  Created by neda khalajnejad on 2026-11-17.
//

import FirebaseFirestore

enum FirestoreService {
    // Saves the check-in in users/{userID}.
    static func saveCheckIn(userID: String, checkIn: Date, nextDeadline: Date) async throws {
        try await Firestore.firestore()
            .collection("users")
            .document(userID)
            .setData([
                "lastCheckIn": Timestamp(date: checkIn),
                "nextDeadline": Timestamp(date: nextDeadline),
                "alertSent": false
            ], merge: true)
    }
}

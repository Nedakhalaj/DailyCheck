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
    
    // Saves the contact emails in the same users/{userID} document.
    static func saveContacts(userID: String, contacts: [String]) async throws {
        try await Firestore.firestore()
            .collection("users")
            .document(userID)
            .setData(["contacts": contacts], merge: true)
    }
    
    // Reads the contacts from users/{userID}. Empty list if none.
    static func loadContacts(userID: String) async throws -> [String] {
        let snapshot = try await Firestore.firestore()
            .collection("users")
            .document(userID)
            .getDocument()
        return snapshot.data()?["contacts"] as? [String] ?? []
    }
}

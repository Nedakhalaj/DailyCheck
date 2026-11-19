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
    
    // Updates only the next deadline in users/{userID}.
    static func saveNextDeadline(userID: String, nextDeadline: Date) async throws {
        try await Firestore.firestore()
            .collection("users")
            .document(userID)
            .setData(["nextDeadline": Timestamp(date: nextDeadline)], merge: true)
    }
    
    // Saves the deadline setting (minutes after midnight).
    static func saveDeadlineMinutes(userID: String, deadlineMinutes: Int) async throws {
        try await Firestore.firestore()
            .collection("users")
            .document(userID)
            .setData(["deadlineMinutes": deadlineMinutes], merge: true)
    }

    // Reads the deadline setting. nil if it was never saved.
    static func loadDeadlineMinutes(userID: String) async throws -> Int? {
        let snapshot = try await Firestore.firestore()
            .collection("users")
            .document(userID)
            .getDocument()
        return snapshot.data()?["deadlineMinutes"] as? Int
    }


    
    // Reads the contacts from users/{userID}. Empty list if none.
    static func loadContacts(userID: String) async throws -> [String] {
        let snapshot = try await Firestore.firestore()
            .collection("users")
            .document(userID)
            .getDocument()
        return snapshot.data()?["contacts"] as? [String] ?? []
    }
    
    // Reads the last check-in. nil if she never checked in.
    static func loadLastCheckIn(userID: String) async throws -> Date? {
        let snapshot = try await Firestore.firestore()
            .collection("users")
            .document(userID)
            .getDocument()
        let timestamp = snapshot.data()?["lastCheckIn"] as? Timestamp
        return timestamp?.dateValue()
    }

}

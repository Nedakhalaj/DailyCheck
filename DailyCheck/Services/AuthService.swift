//
//  AuthService.swift
//  DailyCheck
//
//  Created by neda khalajnejad on 2026-11-17.
//

import FirebaseAuth

enum AuthService {
    // Returns the user's ID. Creates an anonymous user only the first time.
    static func signInIfNeeded() async throws -> String {
        if let user = Auth.auth().currentUser {
            return user.uid
        }

        let result = try await Auth.auth().signInAnonymously()
        return result.user.uid
    }
}

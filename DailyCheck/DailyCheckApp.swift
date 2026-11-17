//
//  DailyCheckApp.swift
//  DailyCheck
//
//  Created by neda khalajnejad on 2026-11-13.
//

import SwiftUI
import FirebaseCore

@main
struct DailyCheckApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


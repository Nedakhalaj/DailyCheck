//
//  CheckInViewModel.swift
//  DailyCheck
//
//  Created by neda khalajnejad on 2026-11-16.
//

import Foundation
import Observation
@Observable
final class CheckInViewModel {
    private(set) var lastCheckIn: Date?
    private(set) var deadlineMinutes: Int
    private(set) var userID: String?
    private let defaults = UserDefaults.standard
    
    init() {
        let store = UserDefaults.standard
        let saved = store.double(forKey: Keys.lastCheckIn)
        lastCheckIn = saved == 0 ? nil : Date(timeIntervalSince1970: saved)
        deadlineMinutes = store.object(forKey: Keys.deadlineMinutes) as? Int ?? 20 * 60
    }
    
    // MARK: - For the views
    // 1200 -> "20:00"
    var deadlineText: String {
        String(format: "%02d:%02d", deadlineMinutes / 60, deadlineMinutes % 60)
    }
    // The DatePicker needs a Date: today at the deadline time.
    var deadlineDate: Date {
        Calendar.current.date(
            bySettingHour: deadlineMinutes / 60,
            minute: deadlineMinutes % 60,
            second: 0,
            of: Date()
        ) ?? Date()
    }
    
    // MARK: - User actions
    func checkIn() {
        let now = Date()
        lastCheckIn = now
        defaults.set(now.timeIntervalSince1970, forKey: Keys.lastCheckIn)
        rescheduleReminders()
        Task { await uploadCheckIn(at: now) }
    }
    func updateDeadline(from date: Date) {
        let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
        deadlineMinutes = (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
        defaults.set(deadlineMinutes, forKey: Keys.deadlineMinutes)
        rescheduleReminders()
    }
    func setUp() async {
        await NotificationManager.requestPermission()
        rescheduleReminders()

        do {
            userID = try await AuthService.signInIfNeeded()
            print("Signed in with uid: \(userID ?? "none")")
        } catch {
            print("Sign-in failed: \(error)")
        }
    }

    // MARK: - Firestore

    private func uploadCheckIn(at date: Date) async {
        guard let userID else {
            print("No user yet, check-in not uploaded")
            return
        }

        do {
            try await FirestoreService.saveCheckIn(
                userID: userID,
                checkIn: date,
                nextDeadline: nextDeadline(after: date)
            )
            print("Check-in saved to Firestore")
        } catch {
            print("Saving check-in failed: \(error)")
        }
    }

    // A check-in covers today, so the next deadline is tomorrow.
    private func nextDeadline(after date: Date) -> Date {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        return calendar.date(
            bySettingHour: deadlineMinutes / 60,
            minute: deadlineMinutes % 60,
            second: 0,
            of: tomorrow
        ) ?? tomorrow
    }

    // MARK: - Reminders
    
    private func rescheduleReminders() {
        NotificationManager.scheduleReminders(deadlineMinutes: deadlineMinutes, lastCheckIn: lastCheckIn)
    }
    
    
    // MARK: - Keys
    private enum Keys {
        static let lastCheckIn = "lastCheckIn"
        static let deadlineMinutes = "deadlineMinutes"
    }
}

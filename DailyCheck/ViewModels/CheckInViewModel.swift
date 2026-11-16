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
    }
    func updateDeadline(from date: Date) {
        let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
        deadlineMinutes = (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
        defaults.set(deadlineMinutes, forKey: Keys.deadlineMinutes)
        NotificationManager.scheduleDailyReminder(deadlineMinutes: deadlineMinutes)
    }
    func setUp() async {
        await NotificationManager.requestPermission()
        NotificationManager.scheduleDailyReminder(deadlineMinutes: deadlineMinutes)
    }
    // MARK: - Keys
    private enum Keys {
        static let lastCheckIn = "lastCheckIn"
        static let deadlineMinutes = "deadlineMinutes"
    }
}

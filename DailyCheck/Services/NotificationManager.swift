//
//  NotificationManager.swift
//  DailyCheck
//
//  Created by neda khalajnejad on 2026-11-13.
//

import UserNotifications

enum NotificationManager {
    static let reminderID = "dailyReminder"

    // Shows the "Allow notifications?" popup. iOS shows it only once.
    static func requestPermission() async {
        do {
            _ = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
        } catch {
            print("Notification permission error: \(error)")
        }
    }

    // Schedules a reminder every day, 60 minutes before the deadline.
    static func scheduleDailyReminder(deadlineMinutes: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [reminderID])

        let reminderMinutes = (deadlineMinutes - 60 + 1440) % 1440

        var time = DateComponents()
        time.hour = reminderMinutes / 60
        time.minute = reminderMinutes % 60

        let content = UNMutableNotificationContent()
        content.title = "Time to check in"
        content.body = "Open Daily Check and tap I'm okay."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
        let request = UNNotificationRequest(identifier: reminderID, content: content, trigger: trigger)
        center.add(request)
    }
}

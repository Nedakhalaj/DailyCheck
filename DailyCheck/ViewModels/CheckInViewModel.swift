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
    private(set) var contacts: [String]
    private let defaults = UserDefaults.standard
    
    init() {
        let store = UserDefaults.standard
        let saved = store.double(forKey: Keys.lastCheckIn)
        lastCheckIn = saved == 0 ? nil : Date(timeIntervalSince1970: saved)
        deadlineMinutes = store.object(forKey: Keys.deadlineMinutes) as? Int ?? 20 * 60
        contacts = store.stringArray(forKey: Keys.contacts) ?? []
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
        Task {
            await uploadDeadlineMinutes()
            await uploadNextDeadline()
        }

    }
    
    func setUp() async {
        await NotificationManager.requestPermission()
        rescheduleReminders()
        
        do {
            userID = try await AuthService.signInIfNeeded()
            print("Signed in with uid: \(userID ?? "none")")
            await syncContacts()
            await syncLastCheckIn()
            await syncDeadline()

        } catch {
            print("Sign-in failed: \(error)")
        }
    }
    
    
    // MARK: - Contacts
    
    func addContact(_ text: String) {
        let email = text.trimmingCharacters(in: .whitespaces).lowercased()
        guard !email.isEmpty, !contacts.contains(email), contacts.count < 3 else { return }
        
        contacts.append(email)
        saveContacts()
    }
    
    func removeContacts(_ emails: [String]) {
        contacts.removeAll { emails.contains($0) }
        saveContacts()
    }
    
    private func saveContacts() {
        defaults.set(contacts, forKey: Keys.contacts)
        Task { await uploadContacts() }
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
                nextDeadline: nextDeadline()
            )
            print("Check-in saved to Firestore")
        } catch {
            print("Saving check-in failed: \(error)")
        }
    }
    
    private func uploadContacts() async {
        guard let userID else { return }
        
        do {
            try await FirestoreService.saveContacts(userID: userID, contacts: contacts)
            print("Contacts saved to Firestore")
        } catch {
            print("Saving contacts failed: \(error)")
        }
    }
    
    // New install: the phone is empty, so get the contacts back from the server.
    // Otherwise the phone is the newest copy, so send it up.
    private func syncContacts() async {
        guard let userID else { return }
        
        if contacts.isEmpty {
            do {
                contacts = try await FirestoreService.loadContacts(userID: userID)
                defaults.set(contacts, forKey: Keys.contacts)
            } catch {
                print("Loading contacts failed: \(error)")
            }
        } else {
            await uploadContacts()
        }
    }
    
    // If she has not checked in today and today's deadline is still ahead: today.
    // Otherwise: tomorrow.
    private func nextDeadline() -> Date {
        let calendar = Calendar.current
        let now = Date()
        let todayDeadline = deadlineDate

        var checkedInToday = false
        if let lastCheckIn {
            checkedInToday = calendar.isDateInToday(lastCheckIn)
        }

        if !checkedInToday && todayDeadline > now {
            return todayDeadline
        }
        return calendar.date(byAdding: .day, value: 1, to: todayDeadline) ?? todayDeadline
    }
    
    private func uploadNextDeadline() async {
        guard let userID, lastCheckIn != nil else { return }

        do {
            try await FirestoreService.saveNextDeadline(userID: userID, nextDeadline: nextDeadline())
            print("Next deadline saved to Firestore")
        } catch {
            print("Saving next deadline failed: \(error)")
        }
    }
    
    private func uploadDeadlineMinutes() async {
        guard let userID else { return }

        do {
            try await FirestoreService.saveDeadlineMinutes(userID: userID, deadlineMinutes: deadlineMinutes)
            print("Deadline setting saved to Firestore")
        } catch {
            print("Saving deadline setting failed: \(error)")
        }
    }

    // New install: no deadline on the phone, so get it back from the server.
    // Otherwise the phone is the newest copy, so send it up.
    private func syncDeadline() async {
        guard let userID else { return }

        if defaults.object(forKey: Keys.deadlineMinutes) == nil {
            do {
                if let saved = try await FirestoreService.loadDeadlineMinutes(userID: userID) {
                    deadlineMinutes = saved
                    defaults.set(saved, forKey: Keys.deadlineMinutes)
                    rescheduleReminders()
                }
            } catch {
                print("Loading deadline setting failed: \(error)")
            }
        } else {
            await uploadDeadlineMinutes()
        }
    }

    // New install: no check-in on the phone, so get it back from the server.
    private func syncLastCheckIn() async {
        guard let userID, lastCheckIn == nil else { return }

        do {
            if let saved = try await FirestoreService.loadLastCheckIn(userID: userID) {
                lastCheckIn = saved
                defaults.set(saved.timeIntervalSince1970, forKey: Keys.lastCheckIn)
                rescheduleReminders()
            }
        } catch {
            print("Loading last check-in failed: \(error)")
        }
    }


    
    // MARK: - Reminders
    
    private func rescheduleReminders() {
        NotificationManager.scheduleReminders(deadlineMinutes: deadlineMinutes, lastCheckIn: lastCheckIn)
    }
    
    
    // MARK: - Keys
    private enum Keys {
        static let lastCheckIn = "lastCheckIn"
        static let deadlineMinutes = "deadlineMinutes"
        static let contacts = "contacts"
    }
}

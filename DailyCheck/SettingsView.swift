//
//  SettingsView.swift
//  DailyCheck
//
//  Created by neda khalajnejad on 2026-11-13.
//

import SwiftUI

struct SettingsView: View {
    //DeadLine saved as minutes after midnight. 1200 = 20:00.
    @AppStorage("deadlineMinutes") private var deadlineMinutes: Int = 20 * 60
    @AppStorage("contactEmails") private var contactEmailsText: String = ""
    @State private var newEmail = ""
    
    // "a@x.se\nb@y.se" -> ["a@x.se", "b@y.se"]
    private var contacts: [String] {
        contactEmailsText.split(separator: "\n").map(String.init)
    }
    
    // A simple check. It is not perfect, just enough to catch typos.
    private var isNewEmailValid: Bool {
        newEmail.contains("@") && newEmail.contains(".")
    }
    
    var body: some View {
        Form {
            Section {
                DatePicker("Check in before", selection: deadLineBinding , displayedComponents: .hourAndMinute)
            }footer: {
                Text("If you have not checked in by this time, your contacts get an email.")
            }
            
            Section {
                ForEach(contacts, id: \.self) { email in
                    Text(email)
                }
                .onDelete(perform: deleteContacts)
                
                if contacts.count < 3 {
                    HStack {
                        TextField("Email", text: $newEmail)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        
                        Button("Add") {
                            addContact()
                        }
                        .disabled(!isNewEmailValid)
                    }
                }
            } header: {
                Text("Contacts")
            } footer: {
                Text("Up to 3 people. Swipe left to delete.")
            }
        }
        .navigationTitle("Settings")
        
    }
    //DatePicker needs a Date, but we save an Int.
    // This binding converts between them in both directions.
    private var deadLineBinding: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    bySettingHour: deadlineMinutes / 60, minute: deadlineMinutes % 60, second: 0, of: Date()
                ) ?? Date()
            },
            set: { newDate in
                let parts = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                deadlineMinutes = (parts.hour ?? 0) * 60 + (parts.minute ?? 0 )
            }
        )
        
    }
    private func addContact() {
        let email = newEmail.trimmingCharacters(in: .whitespaces).lowercased()
        guard !contacts.contains(email) else { return }
        
        contactEmailsText = (contacts + [email]).joined(separator: "\n")
        newEmail = ""
    }
    
    private func deleteContacts(at offsets: IndexSet) {
        var list = contacts
        list.remove(atOffsets: offsets)
        contactEmailsText = list.joined(separator: "\n")
    }
    
    
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}

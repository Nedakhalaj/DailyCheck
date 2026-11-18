//
//  SettingsView.swift
//  DailyCheck
//
//  Created by neda khalajnejad on 2026-11-13.
//

import SwiftUI

struct SettingsView: View {
    let viewModel: CheckInViewModel
    
    @State private var newEmail = ""
    // A simple check. It is not perfect, just enough to catch typos.
    private var isNewEmailValid: Bool {
        newEmail.contains("@") && newEmail.contains(".")
    }
    
    var body: some View {
        Form {
            Section {
                DatePicker("Check in before", selection: deadlineBinding , displayedComponents: .hourAndMinute)
            }footer: {
                Text("If you have not checked in by this time, your contacts get an email.")
            }
            
            Section {
                ForEach(viewModel.contacts, id: \.self) { email in
                    Text(email)
                }
                .onDelete { offsets in
                    let emails = offsets.map { viewModel.contacts[$0] }
                    viewModel.removeContacts(emails)
                }
                
                if viewModel.contacts.count < 3 {
                    HStack {
                        TextField("Email", text: $newEmail)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        
                        Button("Add") {
                            viewModel.addContact(newEmail)
                            newEmail = ""
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
    private var deadlineBinding: Binding<Date> {
        Binding(
            get: { viewModel.deadlineDate },
            set: { viewModel.updateDeadline(from: $0) }
        )
    }
}

#Preview {
    NavigationStack {
        SettingsView(viewModel: CheckInViewModel())
    }
}

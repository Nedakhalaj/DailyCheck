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
    
    var body: some View {
        Form {
            Section {
                DatePicker("Check in before", selection: deadLineBinding , displayedComponents: .hourAndMinute)
            } footer: {
                Text("If you have not checked in by this time, your contacts get an email.")
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
    
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}

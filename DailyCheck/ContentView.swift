//
//  ContentView.swift
//  DailyCheck
//
//  Created by neda khalajnejad on 2026-11-13.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage("lastCheckIn") private var lastCheckInTimestamp: Double = 0
    @AppStorage("deadlineMinutes") private var deadlineMinutes: Int = 20 * 60
    
    
    private var lastCheckIn: Date? {
        lastCheckInTimestamp == 0 ? nil : Date(timeIntervalSince1970: lastCheckInTimestamp )
    }
    
    private var deadlineText: String {
        String(format: "%02d:%02d", deadlineMinutes / 60, deadlineMinutes % 60)
    }
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 24){
                Text("Daily Check")
                    .font(.largeTitle.bold())
                Button{
                    lastCheckInTimestamp = Date().timeIntervalSince1970
                }label: {
                    Text("I'm okay")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 200, height: 200)
                        .background(Circle().fill(.green))
                }
                .buttonStyle(.plain)
                if let lastCheckIn {
                    Text("Last check-in: \(lastCheckIn.formatted(date: .abbreviated, time: .shortened))")
                        .foregroundStyle(.secondary)
                }else{
                    Text("No check-in yet")
                            .foregroundStyle(.secondary)
                }
                Text("Check in before \(deadlineText)")
                    .font(.headline)
            }
            .padding()
            .toolbar {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape")
                }
            }
            
        }
        
    }
}



#Preview {
    ContentView()
}

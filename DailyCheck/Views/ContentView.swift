//
//  ContentView.swift
//  DailyCheck
//
//  Created by neda khalajnejad on 2026-11-13.
//

import SwiftUI

struct ContentView: View {
    
    @State private var viewModel = CheckInViewModel()
    
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 24){
                Text("Daily Check")
                    .font(.largeTitle.bold())
                Button{
                    viewModel.checkIn()
                }label: {
                    Text("I'm okay")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(width: 200, height: 200)
                        .background(Circle().fill(.green))
                }
                .buttonStyle(.plain)
                if let lastCheckIn = viewModel.lastCheckIn {
                    Text("Last check-in: \(lastCheckIn.formatted(date: .abbreviated, time: .shortened))")
                        .foregroundStyle(.secondary)
                }else{
                    Text("No check-in yet")
                        .foregroundStyle(.secondary)
                }
                Text("Check in before \(viewModel.deadlineText)")
                    .font(.headline)
            }
            .padding()
            .toolbar {
                NavigationLink {
                    SettingsView(viewModel: viewModel)
                } label: {
                    Image(systemName: "gearshape")
                }
            }
            .task {
                await viewModel.setUp()
            }
        }
        
    }
}



#Preview {
    ContentView()
}

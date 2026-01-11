//
//  ContentView.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                ProgramListView()
                    .preferredColorScheme(.dark)
            } else {
                OnboardingView()
                    .preferredColorScheme(.dark)
            }
        }
    }
}

#Preview {
    ContentView()
}

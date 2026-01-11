//
//  SessionResultView.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import SwiftUI

struct SessionResultView: View {
    let sessionResult: SessionResult
    let program: Program
    let onRepeat: () -> Void
    let onBackToMenu: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var saved = false
    private let persistenceService = PersistenceService()
    private let ghostService = PaceGhostService()
    
    var timeDifference: TimeInterval? {
        guard let bestSession = persistenceService.fetchBestSession(for: program.id) else {
            return nil
        }
        return sessionResult.totalTime - bestSession.totalTime
    }
    
    var body: some View {
        ZStack {
            ColorTheme.seaDeep.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Session Complete")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top)
                
                // Statistics
                VStack(spacing: 16) {
                    StatCard(title: "Total Time", value: sessionResult.formattedTotalTime, color: ColorTheme.boat)
                    
                    StatCard(title: "Intervals Completed", value: "\(sessionResult.intervalsCompleted)/\(sessionResult.totalIntervals)", color: ColorTheme.track)
                    
                    if let difference = timeDifference {
                        let isFaster = difference < 0
                        StatCard(
                            title: "vs Best Time",
                            value: isFaster ? "\(abs(Int(difference)))s faster" : "\(Int(difference))s slower",
                            color: isFaster ? .green : .orange
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button {
                        if !saved {
                            persistenceService.saveSession(sessionResult)
                            saved = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: saved ? "checkmark.circle.fill" : "square.and.arrow.down")
                            Text(saved ? "Saved" : "Save Result")
                        }
                        .font(.headline)
                        .foregroundColor(ColorTheme.seaDeep)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(saved ? ColorTheme.track : ColorTheme.boat)
                        .cornerRadius(12)
                    }
                    .disabled(saved)
                    
                    Button {
                        dismiss()
                        onRepeat()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Repeat")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ColorTheme.track)
                        .cornerRadius(12)
                    }
                    
                    Button {
                        dismiss()
                        onBackToMenu()
                    } label: {
                        Text("Back to Menu")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ColorTheme.track.opacity(0.5))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(ColorTheme.track)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(ColorTheme.seaDeep.opacity(0.5))
        .cornerRadius(12)
    }
}

#Preview {
    SessionResultView(
        sessionResult: SessionResult(
            programId: UUID(),
            programName: "Test Program",
            date: Date(),
            totalTime: 300,
            intervalsCompleted: 3,
            totalIntervals: 3
        ),
        program: Program(name: "Test", intervals: []),
        onRepeat: {},
        onBackToMenu: {}
    )
}


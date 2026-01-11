//
//  WorkoutModeSelectorView.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import SwiftUI

struct WorkoutModeSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var programListViewModel = ProgramListViewModel()
    @State private var selectedMode: WorkoutMode = .standard
    @State private var programName: String = ""
    @State private var rounds: Int = 8
    
    let onProgramCreated: (Program) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorTheme.seaDeep.ignoresSafeArea()
                
                Form {
                    Section("Workout Mode") {
                        Picker("Mode", selection: $selectedMode) {
                            ForEach(WorkoutMode.allCases, id: \.self) { mode in
                                Text(mode.displayName).tag(mode)
                            }
                        }
                        .foregroundColor(.white)
                        
                        Text(selectedMode.description)
                            .font(.caption)
                            .foregroundColor(ColorTheme.track)
                    }
                    .listRowBackground(ColorTheme.seaDeep.opacity(0.5))
                    
                    Section("Program Name") {
                        TextField("Enter program name", text: $programName)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(ColorTheme.seaDeep.opacity(0.5))
                    
                    if selectedMode == .hiit || selectedMode == .circuit || selectedMode == .tabata {
                        Section("Rounds") {
                            Stepper("Rounds: \(rounds)", value: $rounds, in: 4...20)
                                .foregroundColor(.white)
                        }
                        .listRowBackground(ColorTheme.seaDeep.opacity(0.5))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(ColorTheme.track)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createProgram()
                        dismiss()
                    }
                    .foregroundColor(ColorTheme.boat)
                    .fontWeight(.semibold)
                    .disabled(programName.isEmpty)
                }
            }
        }
    }
    
    private func createProgram() {
        let name = programName.isEmpty ? selectedMode.displayName : programName
        let program = selectedMode.generateProgram(name: name, rounds: rounds)
        onProgramCreated(program)
    }
}

#Preview {
    WorkoutModeSelectorView { _ in }
}


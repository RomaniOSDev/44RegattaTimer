//
//  ScheduleEditorView.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import SwiftUI

struct ScheduleEditorView: View {
    @StateObject private var scheduleService = ScheduleService()
    @StateObject private var programListViewModel = ProgramListViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedProgramId: UUID?
    @State private var scheduledDate: Date = Date()
    @State private var reminderEnabled: Bool = true
    @State private var reminderTime: Double = 30
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorTheme.seaDeep.ignoresSafeArea()
                
                Form {
                    Section("Program") {
                        Picker("Program", selection: $selectedProgramId) {
                            Text("Select Program").tag(nil as UUID?)
                            ForEach(programListViewModel.programs) { program in
                                Text(program.name).tag(program.id as UUID?)
                            }
                        }
                        .foregroundColor(.white)
                    }
                    .listRowBackground(ColorTheme.seaDeep.opacity(0.5))
                    
                    Section("Schedule") {
                        DatePicker("Date & Time", selection: $scheduledDate, displayedComponents: [.date, .hourAndMinute])
                            .foregroundColor(.white)
                    }
                    .listRowBackground(ColorTheme.seaDeep.opacity(0.5))
                    
                    Section("Reminder") {
                        Toggle("Enable Reminder", isOn: $reminderEnabled)
                            .foregroundColor(.white)
                        
                        if reminderEnabled {
                            HStack {
                                Text("Remind Before")
                                Spacer()
                                Text("\(Int(reminderTime)) min")
                                    .foregroundColor(ColorTheme.boat)
                            }
                            .foregroundColor(.white)
                            
                            Slider(value: $reminderTime, in: 5...120, step: 5)
                                .tint(ColorTheme.boat)
                        }
                    }
                    .listRowBackground(ColorTheme.seaDeep.opacity(0.5))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Schedule Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(ColorTheme.track)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSchedule()
                        dismiss()
                    }
                    .foregroundColor(ColorTheme.boat)
                    .fontWeight(.semibold)
                    .disabled(selectedProgramId == nil)
                }
            }
            .onAppear {
                programListViewModel.loadPrograms()
            }
        }
    }
    
    private func saveSchedule() {
        guard let programId = selectedProgramId,
              let program = programListViewModel.programs.first(where: { $0.id == programId }) else {
            return
        }
        
        let workout = ScheduledWorkout(
            programId: programId,
            programName: program.name,
            scheduledDate: scheduledDate,
            reminderEnabled: reminderEnabled,
            reminderTime: reminderTime * 60 // Convert to seconds
        )
        
        scheduleService.addWorkout(workout)
    }
}

#Preview {
    ScheduleEditorView()
}


//
//  GoalEditorView.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import SwiftUI

struct GoalEditorView: View {
    @StateObject private var goalService = GoalService()
    @StateObject private var programListViewModel = ProgramListViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var goalType: GoalType = .totalSessions
    @State private var targetValue: Double = 10
    @State private var endDate: Date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var selectedProgramId: UUID?
    
    let existingGoal: Goal?
    
    init(goal: Goal? = nil) {
        self.existingGoal = goal
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorTheme.seaDeep.ignoresSafeArea()
                
                Form {
                    Section("Goal Type") {
                        Picker("Type", selection: $goalType) {
                            ForEach(GoalType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .foregroundColor(.white)
                    }
                    .listRowBackground(ColorTheme.seaDeep.opacity(0.5))
                    
                    Section("Target") {
                        HStack {
                            Text("Target Value")
                            Spacer()
                            TextField("Value", value: $targetValue, format: .number)
                                .keyboardType(.decimalPad)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.trailing)
                        }
                        .foregroundColor(.white)
                        
                        if goalType == .programCompletion {
                            Picker("Program", selection: $selectedProgramId) {
                                Text("Select Program").tag(nil as UUID?)
                                ForEach(programListViewModel.programs) { program in
                                    Text(program.name).tag(program.id as UUID?)
                                }
                            }
                            .foregroundColor(.white)
                        }
                    }
                    .listRowBackground(ColorTheme.seaDeep.opacity(0.5))
                    
                    Section("Deadline") {
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(ColorTheme.seaDeep.opacity(0.5))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(existingGoal == nil ? "New Goal" : "Edit Goal")
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
                        saveGoal()
                        dismiss()
                    }
                    .foregroundColor(ColorTheme.boat)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                if let goal = existingGoal {
                    goalType = goal.type
                    targetValue = goal.targetValue
                    endDate = goal.endDate
                    selectedProgramId = goal.programId
                }
                programListViewModel.loadPrograms()
            }
        }
    }
    
    private func saveGoal() {
        let goal = Goal(
            id: existingGoal?.id ?? UUID(),
            type: goalType,
            targetValue: targetValue,
            currentValue: existingGoal?.currentValue ?? 0,
            startDate: existingGoal?.startDate ?? Date(),
            endDate: endDate,
            programId: selectedProgramId
        )
        
        if existingGoal != nil {
            goalService.updateGoal(goal)
        } else {
            goalService.addGoal(goal)
        }
    }
}

#Preview {
    GoalEditorView()
}


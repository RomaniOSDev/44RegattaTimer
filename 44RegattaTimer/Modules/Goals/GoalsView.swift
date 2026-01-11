//
//  GoalsView.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import SwiftUI

struct GoalsView: View {
    @StateObject private var goalService = GoalService()
    @StateObject private var scheduleService = ScheduleService()
    @StateObject private var programListViewModel = ProgramListViewModel()
    @State private var showingGoalEditor = false
    @State private var showingScheduleEditor = false
    @State private var selectedGoal: Goal?
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorTheme.seaDeep.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Active Goals
                        if !goalService.activeGoals.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Active Goals")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                ForEach(goalService.activeGoals) { goal in
                                    GoalCardView(goal: goal)
                                }
                            }
                        }
                        
                        // Today's Schedule
                        if !scheduleService.todayWorkouts.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Today's Workouts")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                ForEach(scheduleService.todayWorkouts) { workout in
                                    ScheduledWorkoutCardView(workout: workout, scheduleService: scheduleService)
                                }
                            }
                        }
                        
                        // This Week Schedule
                        if !scheduleService.thisWeekWorkouts.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("This Week")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                ForEach(scheduleService.thisWeekWorkouts) { workout in
                                    ScheduledWorkoutCardView(workout: workout, scheduleService: scheduleService)
                                }
                            }
                        }
                        
                        // Quick Actions
                        VStack(spacing: 12) {
                            Button {
                                showingGoalEditor = true
                            } label: {
                                HStack {
                                    Image(systemName: "target")
                                    Text("New Goal")
                                }
                                .font(.headline)
                                .foregroundColor(ColorTheme.seaDeep)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(ColorTheme.boat)
                                .cornerRadius(12)
                            }
                            
                            Button {
                                showingScheduleEditor = true
                            } label: {
                                HStack {
                                    Image(systemName: "calendar.badge.plus")
                                    Text("Schedule Workout")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(ColorTheme.track)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Goals & Schedule")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingGoalEditor) {
                GoalEditorView(goal: selectedGoal)
            }
            .sheet(isPresented: $showingScheduleEditor) {
                ScheduleEditorView()
            }
            .onAppear {
                goalService.loadGoals()
                scheduleService.loadSchedule()
                programListViewModel.loadPrograms()
            }
        }
    }
}

struct GoalCardView: View {
    let goal: Goal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(goal.type.displayName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if goal.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Text("\(goal.daysRemaining)d left")
                        .font(.caption)
                        .foregroundColor(ColorTheme.track)
                }
            }
            
            Text(goal.formattedProgress)
                .font(.subheadline)
                .foregroundColor(ColorTheme.track)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(ColorTheme.track.opacity(0.3))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(goal.isCompleted ? Color.green : ColorTheme.boat)
                        .frame(width: geometry.size.width * goal.progress, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(ColorTheme.seaDeep.opacity(0.5))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct ScheduledWorkoutCardView: View {
    let workout: ScheduledWorkout
    let scheduleService: ScheduleService
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.programName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(workout.scheduledDate, style: .date)
                    .font(.subheadline)
                    .foregroundColor(ColorTheme.track)
                
                if workout.reminderEnabled {
                    Text("Reminder: \(Int(workout.reminderTime)) min before")
                        .font(.caption)
                        .foregroundColor(ColorTheme.track.opacity(0.7))
                }
            }
            
            Spacer()
            
            if workout.isToday {
                Text("Today")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(ColorTheme.boat)
                    .foregroundColor(ColorTheme.seaDeep)
                    .cornerRadius(6)
            }
        }
        .padding()
        .background(ColorTheme.seaDeep.opacity(0.5))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    GoalsView()
}


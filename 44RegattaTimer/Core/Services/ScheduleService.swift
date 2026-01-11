//
//  ScheduleService.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import Foundation
import Combine

class ScheduleService: ObservableObject {
    @Published private(set) var scheduledWorkouts: [ScheduledWorkout] = []
    
    init() {
        loadSchedule()
    }
    
    func loadSchedule() {
        // Load from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "scheduled_workouts"),
           let decoded = try? JSONDecoder().decode([ScheduledWorkout].self, from: data) {
            scheduledWorkouts = decoded
        }
    }
    
    func saveSchedule() {
        if let encoded = try? JSONEncoder().encode(scheduledWorkouts) {
            UserDefaults.standard.set(encoded, forKey: "scheduled_workouts")
        }
    }
    
    func addWorkout(_ workout: ScheduledWorkout) {
        scheduledWorkouts.append(workout)
        saveSchedule()
    }
    
    func updateWorkout(_ workout: ScheduledWorkout) {
        if let index = scheduledWorkouts.firstIndex(where: { $0.id == workout.id }) {
            scheduledWorkouts[index] = workout
            saveSchedule()
        }
    }
    
    func deleteWorkout(_ workout: ScheduledWorkout) {
        scheduledWorkouts.removeAll { $0.id == workout.id }
        saveSchedule()
    }
    
    func markCompleted(_ workout: ScheduledWorkout) {
        if let index = scheduledWorkouts.firstIndex(where: { $0.id == workout.id }) {
            scheduledWorkouts[index].isCompleted = true
            saveSchedule()
        }
    }
    
    var todayWorkouts: [ScheduledWorkout] {
        scheduledWorkouts.filter { $0.isToday && !$0.isCompleted }
    }
    
    var upcomingWorkouts: [ScheduledWorkout] {
        scheduledWorkouts.filter { $0.isUpcoming }.sorted { $0.scheduledDate < $1.scheduledDate }
    }
    
    var thisWeekWorkouts: [ScheduledWorkout] {
        let calendar = Calendar.current
        let now = Date()
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: now)!
        
        return scheduledWorkouts.filter { workout in
            workout.scheduledDate >= now && workout.scheduledDate <= weekEnd && !workout.isCompleted
        }.sorted { $0.scheduledDate < $1.scheduledDate }
    }
}


//
//  GoalService.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import Foundation
import Combine

class GoalService: ObservableObject {
    private let persistenceService: PersistenceService
    @Published private(set) var goals: [Goal] = []
    
    init(persistenceService: PersistenceService = PersistenceService()) {
        self.persistenceService = persistenceService
        loadGoals()
    }
    
    func loadGoals() {
        // Load from UserDefaults for now (can be migrated to CoreData later)
        if let data = UserDefaults.standard.data(forKey: "goals"),
           let decoded = try? JSONDecoder().decode([Goal].self, from: data) {
            goals = decoded
        }
        updateGoalProgress()
    }
    
    func saveGoals() {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: "goals")
        }
    }
    
    func addGoal(_ goal: Goal) {
        goals.append(goal)
        saveGoals()
        updateGoalProgress()
    }
    
    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveGoals()
            updateGoalProgress()
        }
    }
    
    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        saveGoals()
    }
    
    func updateGoalProgress() {
        let allSessions = persistenceService.fetchAllSessions()
        let calendar = Calendar.current
        let now = Date()
        
        for (index, goal) in goals.enumerated() {
            guard !goal.isCompleted else { continue }
            
            var currentValue: Double = 0
            
            switch goal.type {
            case .totalSessions:
                currentValue = Double(allSessions.filter { $0.date >= goal.startDate && $0.date <= goal.endDate }.count)
                
            case .totalTime:
                let sessionsInPeriod = allSessions.filter { $0.date >= goal.startDate && $0.date <= goal.endDate }
                currentValue = sessionsInPeriod.reduce(0) { $0 + $1.totalTime } / 60.0 // Convert to minutes
                
            case .weeklySessions:
                let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
                currentValue = Double(allSessions.filter { $0.date >= weekAgo }.count)
                
            case .programCompletion:
                if let programId = goal.programId {
                    let programSessions = allSessions.filter { $0.programId == programId && $0.date >= goal.startDate && $0.date <= goal.endDate }
                    currentValue = Double(programSessions.count)
                }
            }
            
            goals[index].currentValue = currentValue
        }
        
        saveGoals()
    }
    
    var activeGoals: [Goal] {
        goals.filter { !$0.isCompleted && $0.endDate >= Date() }
    }
    
    var completedGoals: [Goal] {
        goals.filter { $0.isCompleted }
    }
}


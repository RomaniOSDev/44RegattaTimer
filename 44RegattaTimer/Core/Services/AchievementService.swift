//
//  AchievementService.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import Foundation
import Combine

class AchievementService: ObservableObject {
    private let persistenceService: PersistenceService
    @Published private(set) var achievements: [Achievement] = []
    
    init(persistenceService: PersistenceService = PersistenceService()) {
        self.persistenceService = persistenceService
        loadAchievements()
    }
    
    func loadAchievements() {
        // Initialize all achievement types
        achievements = AchievementType.allCases.map { type in
            Achievement(type: type)
        }
        checkAchievements()
    }
    
    func checkAchievements() {
        let allSessions = persistenceService.fetchAllSessions()
        let programs = persistenceService.fetchPrograms()
        
        // Check each achievement
        for (index, achievement) in achievements.enumerated() {
            if achievement.isUnlocked { continue }
            
            var progress: Double = 0.0
            var shouldUnlock = false
            
            switch achievement.type {
            case .firstSession:
                progress = allSessions.isEmpty ? 0.0 : 1.0
                shouldUnlock = !allSessions.isEmpty
                
            case .tenSessions:
                progress = min(1.0, Double(allSessions.count) / 10.0)
                shouldUnlock = allSessions.count >= 10
                
            case .fiftySessions:
                progress = min(1.0, Double(allSessions.count) / 50.0)
                shouldUnlock = allSessions.count >= 50
                
            case .hundredSessions:
                progress = min(1.0, Double(allSessions.count) / 100.0)
                shouldUnlock = allSessions.count >= 100
                
            case .firstPersonalRecord:
                let hasPR = programs.contains { program in
                    persistenceService.fetchBestSession(for: program.id) != nil
                }
                progress = hasPR ? 1.0 : 0.0
                shouldUnlock = hasPR
                
            case .fivePersonalRecords:
                let prCount = programs.filter { program in
                    persistenceService.fetchBestSession(for: program.id) != nil
                }.count
                progress = min(1.0, Double(prCount) / 5.0)
                shouldUnlock = prCount >= 5
                
            case .weeklyStreak:
                let streak = calculateWeeklyStreak(sessions: allSessions)
                progress = min(1.0, Double(streak) / 7.0)
                shouldUnlock = streak >= 7
                
            case .monthlyStreak:
                let streak = calculateMonthlyStreak(sessions: allSessions)
                progress = min(1.0, Double(streak) / 30.0)
                shouldUnlock = streak >= 30
                
            case .tabataMaster:
                let tabataSessions = allSessions.filter { session in
                    if let program = programs.first(where: { $0.id == session.programId }) {
                        return program.isTabataMode
                    }
                    return false
                }
                progress = min(1.0, Double(tabataSessions.count) / 10.0)
                shouldUnlock = tabataSessions.count >= 10
                
            case .marathonTime:
                let marathonSessions = allSessions.filter { $0.totalTime >= 14400 } // 4 hours
                progress = marathonSessions.isEmpty ? 0.0 : 1.0
                shouldUnlock = !marathonSessions.isEmpty
            }
            
            achievements[index].progress = progress
            
            if shouldUnlock && achievement.unlockedDate == nil {
                achievements[index].unlockedDate = Date()
            }
        }
    }
    
    private func calculateWeeklyStreak(sessions: [SessionResult]) -> Int {
        guard !sessions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var currentDate = Date()
        var streak = 0
        
        for _ in 0..<7 {
            let hasSession = sessions.contains { session in
                calendar.isDate(session.date, inSameDayAs: currentDate)
            }
            
            if hasSession {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func calculateMonthlyStreak(sessions: [SessionResult]) -> Int {
        guard !sessions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var currentDate = Date()
        var streak = 0
        
        for _ in 0..<30 {
            let hasSession = sessions.contains { session in
                calendar.isDate(session.date, inSameDayAs: currentDate)
            }
            
            if hasSession {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }
        
        return streak
    }
    
    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var totalCount: Int {
        achievements.count
    }
}


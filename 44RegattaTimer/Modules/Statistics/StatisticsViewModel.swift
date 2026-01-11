//
//  StatisticsViewModel.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import Foundation
import Combine

class StatisticsViewModel: ObservableObject {
    @Published var allSessions: [SessionResult] = []
    @Published var sessionsByProgram: [UUID: [SessionResult]] = [:]
    @Published var personalRecords: [UUID: SessionResult] = [:]
    @Published var weeklyStats: WeeklyStats?
    @Published var monthlyStats: MonthlyStats?
    
    private let persistenceService: PersistenceService
    
    init(persistenceService: PersistenceService = PersistenceService()) {
        self.persistenceService = persistenceService
        loadStatistics()
    }
    
    func loadStatistics() {
        allSessions = persistenceService.fetchAllSessions()
        updateSessionsByProgram()
        updatePersonalRecords()
        updateWeeklyStats()
        updateMonthlyStats()
    }
    
    func sessions(for programId: UUID) -> [SessionResult] {
        return sessionsByProgram[programId] ?? []
    }
    
    func personalRecord(for programId: UUID) -> SessionResult? {
        return personalRecords[programId]
    }
    
    private func updateSessionsByProgram() {
        sessionsByProgram = Dictionary(grouping: allSessions) { $0.programId }
    }
    
    private func updatePersonalRecords() {
        personalRecords = Dictionary(uniqueKeysWithValues: 
            sessionsByProgram.map { programId, sessions in
                let bestSession = sessions.min(by: { $0.totalTime < $1.totalTime })
                return (programId, bestSession!)
            }
        )
    }
    
    private func updateWeeklyStats() {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
        
        let weekSessions = allSessions.filter { $0.date >= weekAgo }
        
        guard !weekSessions.isEmpty else {
            weeklyStats = nil
            return
        }
        
        let totalTime = weekSessions.reduce(0) { $0 + $1.totalTime }
        let averageTime = totalTime / Double(weekSessions.count)
        let totalSessions = weekSessions.count
        
        weeklyStats = WeeklyStats(
            totalSessions: totalSessions,
            totalTime: totalTime,
            averageTime: averageTime,
            sessions: weekSessions
        )
    }
    
    private func updateMonthlyStats() {
        let calendar = Calendar.current
        let now = Date()
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
        
        let monthSessions = allSessions.filter { $0.date >= monthAgo }
        
        guard !monthSessions.isEmpty else {
            monthlyStats = nil
            return
        }
        
        let totalTime = monthSessions.reduce(0) { $0 + $1.totalTime }
        let averageTime = totalTime / Double(monthSessions.count)
        let totalSessions = monthSessions.count
        
        monthlyStats = MonthlyStats(
            totalSessions: totalSessions,
            totalTime: totalTime,
            averageTime: averageTime,
            sessions: monthSessions
        )
    }
}

struct WeeklyStats {
    let totalSessions: Int
    let totalTime: TimeInterval
    let averageTime: TimeInterval
    let sessions: [SessionResult]
    
    var formattedTotalTime: String {
        formatTime(totalTime)
    }
    
    var formattedAverageTime: String {
        formatTime(averageTime)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let total = Int(time)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
}

struct MonthlyStats {
    let totalSessions: Int
    let totalTime: TimeInterval
    let averageTime: TimeInterval
    let sessions: [SessionResult]
    
    var formattedTotalTime: String {
        formatTime(totalTime)
    }
    
    var formattedAverageTime: String {
        formatTime(averageTime)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let total = Int(time)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
}


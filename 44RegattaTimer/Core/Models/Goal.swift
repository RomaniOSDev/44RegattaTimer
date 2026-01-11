//
//  Goal.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import Foundation

enum GoalType: String, Codable, CaseIterable {
    case totalSessions = "total_sessions"
    case totalTime = "total_time"
    case weeklySessions = "weekly_sessions"
    case programCompletion = "program_completion"
    
    var displayName: String {
        switch self {
        case .totalSessions: return "Total Sessions"
        case .totalTime: return "Total Time"
        case .weeklySessions: return "Weekly Sessions"
        case .programCompletion: return "Program Completion"
        }
    }
    
    var unit: String {
        switch self {
        case .totalSessions, .weeklySessions, .programCompletion: return "sessions"
        case .totalTime: return "minutes"
        }
    }
}

struct Goal: Identifiable, Codable {
    let id: UUID
    var type: GoalType
    var targetValue: Double
    var currentValue: Double
    var startDate: Date
    var endDate: Date
    var programId: UUID? // For program-specific goals
    
    init(id: UUID = UUID(), type: GoalType, targetValue: Double, currentValue: Double = 0, startDate: Date = Date(), endDate: Date, programId: UUID? = nil) {
        self.id = id
        self.type = type
        self.targetValue = targetValue
        self.currentValue = currentValue
        self.startDate = startDate
        self.endDate = endDate
        self.programId = programId
    }
    
    var progress: Double {
        guard targetValue > 0 else { return 0 }
        return min(1.0, currentValue / targetValue)
    }
    
    var isCompleted: Bool {
        return currentValue >= targetValue
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: endDate).day ?? 0
        return max(0, days)
    }
    
    var formattedProgress: String {
        if type == .totalTime {
            return "\(Int(currentValue)) / \(Int(targetValue)) minutes"
        } else {
            return "\(Int(currentValue)) / \(Int(targetValue)) \(type.unit)"
        }
    }
}


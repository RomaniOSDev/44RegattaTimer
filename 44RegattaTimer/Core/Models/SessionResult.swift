//
//  SessionResult.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import Foundation

struct SessionResult: Identifiable {
    let id: UUID
    let programId: UUID
    let programName: String
    let date: Date
    let totalTime: TimeInterval
    let intervalsCompleted: Int
    let totalIntervals: Int
    
    init(id: UUID = UUID(), programId: UUID, programName: String, date: Date, totalTime: TimeInterval, intervalsCompleted: Int, totalIntervals: Int) {
        self.id = id
        self.programId = programId
        self.programName = programName
        self.date = date
        self.totalTime = totalTime
        self.intervalsCompleted = intervalsCompleted
        self.totalIntervals = totalIntervals
    }
    
    var formattedTotalTime: String {
        let total = Int(totalTime)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var progress: Double {
        guard totalIntervals > 0 else { return 0 }
        return Double(intervalsCompleted) / Double(totalIntervals)
    }
}


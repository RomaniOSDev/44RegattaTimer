//
//  Program.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import Foundation

struct Program: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var intervals: [Interval]
    var restBetweenIntervals: TimeInterval // Pause between intervals in seconds
    var isTabataMode: Bool // Tabata mode (20s work, 10s rest)
    
    init(id: UUID = UUID(), name: String, intervals: [Interval] = [], restBetweenIntervals: TimeInterval = 0, isTabataMode: Bool = false) {
        self.id = id
        self.name = name
        self.intervals = intervals
        self.restBetweenIntervals = restBetweenIntervals
        self.isTabataMode = isTabataMode
    }
    
    var totalDuration: TimeInterval {
        intervals.reduce(0) { $0 + $1.duration }
    }
    
    var formattedTotalDuration: String {
        let total = Int(totalDuration)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}


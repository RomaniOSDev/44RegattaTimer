//
//  Interval.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import Foundation

struct Interval: Identifiable, Codable, Equatable {
    let id: UUID
    var order: Int
    var name: String
    var duration: TimeInterval // in seconds
    var type: IntervalType
    
    init(id: UUID = UUID(), order: Int, name: String, duration: TimeInterval, type: IntervalType) {
        self.id = id
        self.order = order
        self.name = name
        self.duration = duration
        self.type = type
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}


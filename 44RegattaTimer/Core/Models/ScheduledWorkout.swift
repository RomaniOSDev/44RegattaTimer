//
//  ScheduledWorkout.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import Foundation

struct ScheduledWorkout: Identifiable, Codable {
    let id: UUID
    var programId: UUID
    var programName: String
    var scheduledDate: Date
    var isCompleted: Bool
    var reminderEnabled: Bool
    var reminderTime: TimeInterval // Minutes before workout
    
    init(id: UUID = UUID(), programId: UUID, programName: String, scheduledDate: Date, isCompleted: Bool = false, reminderEnabled: Bool = true, reminderTime: TimeInterval = 30) {
        self.id = id
        self.programId = programId
        self.programName = programName
        self.scheduledDate = scheduledDate
        self.isCompleted = isCompleted
        self.reminderEnabled = reminderEnabled
        self.reminderTime = reminderTime
    }
    
    var isPast: Bool {
        return scheduledDate < Date()
    }
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(scheduledDate)
    }
    
    var isUpcoming: Bool {
        return scheduledDate > Date() && !isCompleted
    }
}


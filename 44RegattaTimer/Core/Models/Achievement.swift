//
//  Achievement.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import Foundation

enum AchievementType: String, Codable, CaseIterable {
    case firstSession = "first_session"
    case tenSessions = "ten_sessions"
    case fiftySessions = "fifty_sessions"
    case hundredSessions = "hundred_sessions"
    case firstPersonalRecord = "first_pr"
    case fivePersonalRecords = "five_prs"
    case weeklyStreak = "weekly_streak"
    case monthlyStreak = "monthly_streak"
    case tabataMaster = "tabata_master"
    case marathonTime = "marathon_time"
    
    var displayName: String {
        switch self {
        case .firstSession: return "First Steps"
        case .tenSessions: return "Getting Started"
        case .fiftySessions: return "Half Century"
        case .hundredSessions: return "Century Club"
        case .firstPersonalRecord: return "Personal Best"
        case .fivePersonalRecords: return "Record Breaker"
        case .weeklyStreak: return "Week Warrior"
        case .monthlyStreak: return "Month Master"
        case .tabataMaster: return "Tabata Master"
        case .marathonTime: return "Marathon Time"
        }
    }
    
    var description: String {
        switch self {
        case .firstSession: return "Complete your first training session"
        case .tenSessions: return "Complete 10 training sessions"
        case .fiftySessions: return "Complete 50 training sessions"
        case .hundredSessions: return "Complete 100 training sessions"
        case .firstPersonalRecord: return "Set your first personal record"
        case .fivePersonalRecords: return "Set 5 personal records"
        case .weeklyStreak: return "Complete 7 days in a row"
        case .monthlyStreak: return "Complete 30 days in a row"
        case .tabataMaster: return "Complete 10 Tabata workouts"
        case .marathonTime: return "Complete a 4-hour training session"
        }
    }
    
    var iconName: String {
        switch self {
        case .firstSession: return "star.fill"
        case .tenSessions: return "flame.fill"
        case .fiftySessions: return "trophy.fill"
        case .hundredSessions: return "crown.fill"
        case .firstPersonalRecord: return "medal.fill"
        case .fivePersonalRecords: return "trophy.circle.fill"
        case .weeklyStreak: return "calendar.badge.clock"
        case .monthlyStreak: return "calendar.badge.exclamationmark"
        case .tabataMaster: return "bolt.fill"
        case .marathonTime: return "figure.run"
        }
    }
}

struct Achievement: Identifiable, Codable {
    let id: UUID
    let type: AchievementType
    var unlockedDate: Date?
    var progress: Double // 0.0 to 1.0
    
    init(id: UUID = UUID(), type: AchievementType, unlockedDate: Date? = nil, progress: Double = 0.0) {
        self.id = id
        self.type = type
        self.unlockedDate = unlockedDate
        self.progress = progress
    }
    
    var isUnlocked: Bool {
        return unlockedDate != nil
    }
}


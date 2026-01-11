//
//  WorkoutMode.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import Foundation

enum WorkoutMode: String, Codable, CaseIterable {
    case standard = "standard"
    case hiit = "hiit"
    case running = "running"
    case circuit = "circuit"
    case tabata = "tabata"
    
    var displayName: String {
        switch self {
        case .standard: return "Standard"
        case .hiit: return "HIIT"
        case .running: return "Running"
        case .circuit: return "Circuit"
        case .tabata: return "Tabata"
        }
    }
    
    var description: String {
        switch self {
        case .standard: return "Custom interval training"
        case .hiit: return "High Intensity Interval Training"
        case .running: return "Running intervals with pace tracking"
        case .circuit: return "Circuit training with rest periods"
        case .tabata: return "Tabata protocol (20s work, 10s rest)"
        }
    }
    
    func generateProgram(name: String, rounds: Int = 8) -> Program {
        switch self {
        case .standard:
            return Program(name: name, intervals: [])
            
        case .hiit:
            var intervals: [Interval] = []
            for i in 0..<rounds {
                intervals.append(Interval(order: i * 2, name: "Work \(i + 1)", duration: 30, type: .work))
                intervals.append(Interval(order: i * 2 + 1, name: "Rest \(i + 1)", duration: 15, type: .rest))
            }
            return Program(name: name, intervals: intervals, restBetweenIntervals: 0, isTabataMode: false)
            
        case .running:
            var intervals: [Interval] = []
            intervals.append(Interval(order: 0, name: "Warmup", duration: 300, type: .warmup))
            for i in 0..<5 {
                intervals.append(Interval(order: i * 2 + 1, name: "Run \(i + 1)", duration: 180, type: .work))
                intervals.append(Interval(order: i * 2 + 2, name: "Recovery \(i + 1)", duration: 60, type: .rest))
            }
            intervals.append(Interval(order: intervals.count, name: "Cooldown", duration: 300, type: .cooldown))
            return Program(name: name, intervals: intervals, restBetweenIntervals: 0, isTabataMode: false)
            
        case .circuit:
            var intervals: [Interval] = []
            for i in 0..<rounds {
                intervals.append(Interval(order: i * 2, name: "Exercise \(i + 1)", duration: 45, type: .work))
                intervals.append(Interval(order: i * 2 + 1, name: "Rest \(i + 1)", duration: 30, type: .rest))
            }
            return Program(name: name, intervals: intervals, restBetweenIntervals: 15, isTabataMode: false)
            
        case .tabata:
            var intervals: [Interval] = []
            for i in 0..<rounds {
                intervals.append(Interval(order: i * 2, name: "Work \(i + 1)", duration: 20, type: .work))
                intervals.append(Interval(order: i * 2 + 1, name: "Rest \(i + 1)", duration: 10, type: .rest))
            }
            return Program(name: name, intervals: intervals, restBetweenIntervals: 0, isTabataMode: true)
        }
    }
}


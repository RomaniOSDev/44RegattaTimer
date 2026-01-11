//
//  IntervalType.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import Foundation
import SwiftUI

enum IntervalType: String, CaseIterable, Codable {
    case work = "work"
    case rest = "rest"
    case warmup = "warmup"
    case cooldown = "cooldown"
    
    var displayName: String {
        switch self {
        case .work: return "Work"
        case .rest: return "Rest"
        case .warmup: return "Warmup"
        case .cooldown: return "Cooldown"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .work: return ColorTheme.workBackground
        case .rest: return ColorTheme.restBackground
        case .warmup: return ColorTheme.warmupBackground
        case .cooldown: return ColorTheme.cooldownBackground
        }
    }
}


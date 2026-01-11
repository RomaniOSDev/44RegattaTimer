//
//  PaceGhostService.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import Foundation
import Combine

class PaceGhostService {
    private let persistenceService: PersistenceService
    
    init(persistenceService: PersistenceService = PersistenceService()) {
        self.persistenceService = persistenceService
    }
    
    func getGhostProgress(for programId: UUID, at totalProgress: Double) -> Double? {
        guard let bestSession = persistenceService.fetchBestSession(for: programId),
              let program = persistenceService.fetchProgram(by: programId) else {
            return nil
        }
        
        // Calculate what progress the ghost should be at based on best session timing
        let ghostProgress = bestSession.progress
        
        // If ghost finished earlier, it's ahead
        if ghostProgress >= 1.0 && totalProgress < 1.0 {
            return 1.0
        }
        
        // Calculate ghost position based on time ratio
        let currentTimeRatio = totalProgress
        let ghostTimeRatio = bestSession.totalTime / program.totalDuration
        
        if ghostTimeRatio < currentTimeRatio {
            // Ghost is ahead
            return min(1.0, currentTimeRatio / ghostTimeRatio * ghostProgress)
        } else {
            // Ghost is behind
            return min(1.0, ghostProgress * (currentTimeRatio / ghostTimeRatio))
        }
    }
    
    func getGhostPosition(for programId: UUID, at totalProgress: Double) -> Double? {
        return getGhostProgress(for: programId, at: totalProgress)
    }
    
    func hasGhost(for programId: UUID) -> Bool {
        return persistenceService.fetchBestSession(for: programId) != nil
    }
}


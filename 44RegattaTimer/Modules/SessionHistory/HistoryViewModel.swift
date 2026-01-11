//
//  HistoryViewModel.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import Foundation
import Combine

class HistoryViewModel: ObservableObject {
    @Published var sessions: [SessionResult] = []
    
    private let persistenceService: PersistenceService
    
    init(persistenceService: PersistenceService = PersistenceService()) {
        self.persistenceService = persistenceService
        loadSessions()
    }
    
    func loadSessions() {
        sessions = persistenceService.fetchAllSessions()
    }
    
    func sessions(for programId: UUID) -> [SessionResult] {
        return persistenceService.fetchSessions(for: programId)
    }
}


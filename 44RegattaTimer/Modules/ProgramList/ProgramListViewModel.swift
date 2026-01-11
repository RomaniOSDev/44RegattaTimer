//
//  ProgramListViewModel.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import Foundation
import Combine

class ProgramListViewModel: ObservableObject {
    @Published var programs: [Program] = []
    
    private let persistenceService: PersistenceService
    
    init(persistenceService: PersistenceService = PersistenceService()) {
        self.persistenceService = persistenceService
        loadPrograms()
    }
    
    func loadPrograms() {
        programs = persistenceService.fetchPrograms()
    }
    
    func deleteProgram(_ program: Program) {
        persistenceService.deleteProgram(program)
        loadPrograms()
    }
    
    func duplicateProgram(_ program: Program) {
        var duplicated = program
        duplicated = Program(id: UUID(), name: "\(program.name) Copy", intervals: program.intervals)
        persistenceService.saveProgram(duplicated)
        loadPrograms()
    }
}


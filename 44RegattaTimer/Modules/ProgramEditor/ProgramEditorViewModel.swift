//
//  ProgramEditorViewModel.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import Foundation
import Combine

class ProgramEditorViewModel: ObservableObject {
    @Published var program: Program
    @Published var isEditing: Bool
    
    private let persistenceService: PersistenceService
    
    init(program: Program? = nil, persistenceService: PersistenceService = PersistenceService()) {
        if let program = program {
            self.program = program
            self.isEditing = true
        } else {
            self.program = Program(id: UUID(), name: "New Program", intervals: [])
            self.isEditing = false
        }
        self.persistenceService = persistenceService
    }
    
    func saveProgram() -> Bool {
        // Validate that program has at least one interval
        guard !program.intervals.isEmpty else {
            return false
        }
        
        // Validate that all intervals have valid duration
        guard program.intervals.allSatisfy({ $0.duration > 0 }) else {
            return false
        }
        
        persistenceService.saveProgram(program)
        return true
    }
    
    func addInterval() {
        let newInterval = Interval(
            order: program.intervals.count,
            name: "Interval \(program.intervals.count + 1)",
            duration: 60,
            type: .work
        )
        program.intervals.append(newInterval)
    }
    
    func deleteInterval(at indexSet: IndexSet) {
        let indices = indexSet.sorted(by: >) // Sort in descending order to remove from end
        for index in indices {
            program.intervals.remove(at: index)
        }
        // Reorder intervals
        for (index, _) in program.intervals.enumerated() {
            program.intervals[index].order = index
        }
    }
    
    func moveInterval(from source: IndexSet, to destination: Int) {
        let indices = source.sorted()
        guard let firstIndex = indices.first else { return }
        
        let itemsToMove = indices.map { program.intervals[$0] }
        
        // Remove items in reverse order to maintain indices
        for index in indices.reversed() {
            program.intervals.remove(at: index)
        }
        
        // Calculate insertion point
        let insertionIndex = destination > firstIndex ? destination - indices.count + 1 : destination
        
        // Insert items at new location
        for (offset, item) in itemsToMove.enumerated() {
            program.intervals.insert(item, at: insertionIndex + offset)
        }
        
        // Reorder intervals
        for (index, _) in program.intervals.enumerated() {
            program.intervals[index].order = index
        }
    }
    
    func createTabataProgram(rounds: Int = 8) {
        program.name = "Tabata \(rounds) Rounds"
        program.isTabataMode = true
        program.restBetweenIntervals = 0
        program.intervals = []
        
        for i in 0..<rounds {
            // Work interval (20 seconds)
            program.intervals.append(Interval(
                order: i * 2,
                name: "Work \(i + 1)",
                duration: 20,
                type: .work
            ))
            
            // Rest interval (10 seconds)
            program.intervals.append(Interval(
                order: i * 2 + 1,
                name: "Rest \(i + 1)",
                duration: 10,
                type: .rest
            ))
        }
    }
}


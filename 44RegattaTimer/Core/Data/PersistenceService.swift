//
//  PersistenceService.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import CoreData
import Foundation

class PersistenceService {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.viewContext) {
        self.context = context
    }
    
    // MARK: - Program Operations
    
    func fetchPrograms() -> [Program] {
        let request = NSFetchRequest<ProgramEntity>(entityName: "ProgramEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ProgramEntity.name, ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            return entities.map { entityToProgram($0) }
        } catch {
            print("Failed to fetch programs: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchProgram(by id: UUID) -> Program? {
        let request = NSFetchRequest<ProgramEntity>(entityName: "ProgramEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            guard let entity = try context.fetch(request).first else { return nil }
            return entityToProgram(entity)
        } catch {
            print("Failed to fetch program: \(error.localizedDescription)")
            return nil
        }
    }
    
    func saveProgram(_ program: Program) {
        let request = NSFetchRequest<ProgramEntity>(entityName: "ProgramEntity")
        request.predicate = NSPredicate(format: "id == %@", program.id as CVarArg)
        request.fetchLimit = 1
        
        do {
            let entity = try context.fetch(request).first ?? ProgramEntity(context: context)
            entity.id = program.id
            entity.name = program.name
            entity.restBetweenIntervals = program.restBetweenIntervals
            entity.isTabataMode = program.isTabataMode
            
            // Remove old intervals
            if let oldIntervals = entity.intervals as? Set<IntervalEntity> {
                oldIntervals.forEach { context.delete($0) }
            }
            
            // Add new intervals
            for interval in program.intervals {
                let intervalEntity = IntervalEntity(context: context)
                intervalEntity.id = interval.id
                intervalEntity.order = Int32(interval.order)
                intervalEntity.name = interval.name
                intervalEntity.duration = interval.duration
                intervalEntity.type = interval.type.rawValue
                entity.addToIntervals(intervalEntity)
            }
            
            try context.save()
        } catch {
            print("Failed to save program: \(error.localizedDescription)")
        }
    }
    
    func deleteProgram(_ program: Program) {
        let request = NSFetchRequest<ProgramEntity>(entityName: "ProgramEntity")
        request.predicate = NSPredicate(format: "id == %@", program.id as CVarArg)
        request.fetchLimit = 1
        
        do {
            if let entity = try context.fetch(request).first {
                context.delete(entity)
                try context.save()
            }
        } catch {
            print("Failed to delete program: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Session Operations
    
    func saveSession(_ session: SessionResult) {
        let entity = SessionEntity(context: context)
        entity.id = session.id
        entity.date = session.date
        entity.programId = session.programId
        entity.programName = session.programName
        entity.totalTime = session.totalTime
        entity.intervalsCompleted = Int32(session.intervalsCompleted)
        entity.totalIntervals = Int32(session.totalIntervals)
        
        do {
            try context.save()
        } catch {
            print("Failed to save session: \(error.localizedDescription)")
        }
    }
    
    func fetchSessions(for programId: UUID) -> [SessionResult] {
        let request = NSFetchRequest<SessionEntity>(entityName: "SessionEntity")
        request.predicate = NSPredicate(format: "programId == %@", programId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SessionEntity.date, ascending: false)]
        
        do {
            let entities = try context.fetch(request)
            return entities.map { entityToSession($0) }
        } catch {
            print("Failed to fetch sessions: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchBestSession(for programId: UUID) -> SessionResult? {
        let request = NSFetchRequest<SessionEntity>(entityName: "SessionEntity")
        request.predicate = NSPredicate(format: "programId == %@", programId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SessionEntity.totalTime, ascending: true)]
        request.fetchLimit = 1
        
        do {
            guard let entity = try context.fetch(request).first else { return nil }
            return entityToSession(entity)
        } catch {
            print("Failed to fetch best session: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchAllSessions() -> [SessionResult] {
        let request = NSFetchRequest<SessionEntity>(entityName: "SessionEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SessionEntity.date, ascending: false)]
        
        do {
            let entities = try context.fetch(request)
            return entities.map { entityToSession($0) }
        } catch {
            print("Failed to fetch all sessions: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Mapping
    
    private func entityToProgram(_ entity: ProgramEntity) -> Program {
        let intervals = entity.intervalsArray.map { intervalEntity in
            Interval(
                id: intervalEntity.id ?? UUID(),
                order: Int(intervalEntity.order),
                name: intervalEntity.name ?? "",
                duration: intervalEntity.duration,
                type: IntervalType(rawValue: intervalEntity.type ?? "work") ?? .work
            )
        }
        return Program(
            id: entity.id ?? UUID(),
            name: entity.name ?? "",
            intervals: intervals,
            restBetweenIntervals: entity.restBetweenIntervals,
            isTabataMode: entity.isTabataMode
        )
    }
    
    private func entityToSession(_ entity: SessionEntity) -> SessionResult {
        SessionResult(
            id: entity.id ?? UUID(),
            programId: entity.programId ?? UUID(),
            programName: entity.programName ?? "",
            date: entity.date ?? Date(),
            totalTime: entity.totalTime,
            intervalsCompleted: Int(entity.intervalsCompleted),
            totalIntervals: Int(entity.totalIntervals)
        )
    }
}


//
//  RaceViewModel.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import Foundation
import Combine

class RaceViewModel: ObservableObject {
    @Published var program: Program
    @Published var ghostProgress: Double?
    @Published var showSessionResult: Bool = false
    @Published var sessionResult: SessionResult?
    
    let timerEngine: TimerEngine
    private let persistenceService: PersistenceService
    private let ghostService: PaceGhostService
    private let achievementService = AchievementService()
    private let goalService = GoalService()
    private var cancellables = Set<AnyCancellable>()
    
    init(program: Program, 
         timerEngine: TimerEngine = TimerEngine(),
         persistenceService: PersistenceService = PersistenceService(),
         ghostService: PaceGhostService = PaceGhostService()) {
        self.program = program
        self.timerEngine = timerEngine
        self.persistenceService = persistenceService
        self.ghostService = ghostService
        
        setupSubscriptions()
        updateGhostProgress()
    }
    
    private func setupSubscriptions() {
        timerEngine.$totalProgress
            .sink { [weak self] _ in
                self?.updateGhostProgress()
            }
            .store(in: &cancellables)
        
        timerEngine.onFinish = { [weak self] in
            self?.finishRace()
        }
    }
    
    private func updateGhostProgress() {
        if ghostService.hasGhost(for: program.id) {
            ghostProgress = ghostService.getGhostPosition(for: program.id, at: timerEngine.totalProgress)
        } else {
            ghostProgress = nil
        }
    }
    
    func startRace() {
        timerEngine.start(program: program)
        AudioService.shared.playStartSound()
    }
    
    func pauseRace() {
        timerEngine.pause()
    }
    
    func resumeRace() {
        timerEngine.resume()
    }
    
    func stopRace() {
        timerEngine.stop()
        finishRace()
    }
    
    func skipInterval() {
        timerEngine.skipToNextInterval()
    }
    
    private func finishRace() {
        let result = SessionResult(
            programId: program.id,
            programName: program.name,
            date: Date(),
            totalTime: timerEngine.totalElapsedTime,
            intervalsCompleted: timerEngine.completedIntervals,
            totalIntervals: program.intervals.count
        )
        sessionResult = result
        showSessionResult = true
        AudioService.shared.playFinishSound()
        
        // Update achievements and goals
        saveSessionAndUpdateProgress(result)
    }
    
    func saveSessionAndUpdateProgress(_ result: SessionResult) {
        persistenceService.saveSession(result)
        achievementService.checkAchievements()
        goalService.updateGoalProgress()
    }
    
    func saveSession() {
        guard let result = sessionResult else { return }
        saveSessionAndUpdateProgress(result)
    }
    
    func restartRace() {
        showSessionResult = false
        sessionResult = nil
        timerEngine.state = .ready
        timerEngine.currentIntervalIndex = 0
        timerEngine.timeRemainingInInterval = 0
        timerEngine.totalProgress = 0
        timerEngine.totalElapsedTime = 0
    }
}


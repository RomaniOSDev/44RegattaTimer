//
//  TimerEngine.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import Foundation
import Combine

enum TimerState {
    case ready
    case running
    case paused
    case finished
}

class TimerEngine: ObservableObject {
    @Published var state: TimerState = .ready
    @Published var currentIntervalIndex: Int = 0
    @Published var timeRemainingInInterval: TimeInterval = 0
    @Published var totalProgress: Double = 0.0
    @Published var totalElapsedTime: TimeInterval = 0.0
    
    private var program: Program?
    private var timer: Timer?
    private var startTime: Date?
    private var pausedTimeRemaining: TimeInterval = 0
    private var audioService: AudioService
    
    var onIntervalChange: ((Int) -> Void)?
    var onFinish: (() -> Void)?
    
    init(audioService: AudioService = AudioService.shared) {
        self.audioService = audioService
    }
    
    func start(program: Program) -> Bool {
        guard !program.intervals.isEmpty else {
            print("TimerEngine: Cannot start - program has no intervals")
            return false
        }
        
        guard program.intervals.allSatisfy({ $0.duration > 0 }) else {
            print("TimerEngine: Cannot start - program has intervals with invalid duration")
            return false
        }
        
        self.program = program
        state = .running
        currentIntervalIndex = 0
        pausedTimeRemaining = program.intervals[0].duration
        timeRemainingInInterval = pausedTimeRemaining
        totalElapsedTime = 0
        startTime = Date()
        
        updateTotalProgress()
        startTimer()
        onIntervalChange?(currentIntervalIndex)
        return true
    }
    
    func pause() {
        guard state == .running else { return }
        state = .paused
        timer?.invalidate()
        timer = nil
    }
    
    func resume() {
        guard state == .paused, let program = program else { return }
        state = .running
        startTime = Date().addingTimeInterval(-totalElapsedTime)
        startTimer()
    }
    
    func stop() {
        state = .finished
        timer?.invalidate()
        timer = nil
        onFinish?()
    }
    
    func skipToNextInterval() {
        guard let program = program, currentIntervalIndex < program.intervals.count - 1 else {
            stop()
            return
        }
        
        currentIntervalIndex += 1
        pausedTimeRemaining = program.intervals[currentIntervalIndex].duration
        timeRemainingInInterval = pausedTimeRemaining
        updateTotalProgress()
        onIntervalChange?(currentIntervalIndex)
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func tick() {
        guard let program = program, state == .running else { return }
        
        let elapsed = Date().timeIntervalSince(startTime ?? Date())
        totalElapsedTime = elapsed
        
        // Calculate current interval progress
        var accumulatedTime: TimeInterval = 0
        for i in 0..<currentIntervalIndex {
            accumulatedTime += program.intervals[i].duration
        }
        
        let intervalElapsed = elapsed - accumulatedTime
        let currentIntervalDuration = program.intervals[currentIntervalIndex].duration
        timeRemainingInInterval = max(0, currentIntervalDuration - intervalElapsed)
        pausedTimeRemaining = timeRemainingInInterval
        
        // Check for countdown sounds (3, 2, 1 seconds before interval ends)
        if timeRemainingInInterval <= 3.0 && timeRemainingInInterval > 2.9 {
            audioService.playCountdownSound(count: 3)
        } else if timeRemainingInInterval <= 2.0 && timeRemainingInInterval > 1.9 {
            audioService.playCountdownSound(count: 2)
        } else if timeRemainingInInterval <= 1.0 && timeRemainingInInterval > 0.9 {
            audioService.playCountdownSound(count: 1)
        }
        
        // Check if interval finished
        if timeRemainingInInterval <= 0 {
            moveToNextInterval()
        }
        
        updateTotalProgress()
    }
    
    private func moveToNextInterval() {
        guard let program = program else { return }
        
        // Play interval end sound
        let currentType = program.intervals[currentIntervalIndex].type
        audioService.playIntervalEndSound(type: currentType)
        
        if currentIntervalIndex < program.intervals.count - 1 {
            // Add rest period between intervals if configured
            if program.restBetweenIntervals > 0 {
                // Pause for rest period
                pause()
                DispatchQueue.main.asyncAfter(deadline: .now() + program.restBetweenIntervals) { [weak self] in
                    guard let self = self else { return }
                    self.currentIntervalIndex += 1
                    self.pausedTimeRemaining = program.intervals[self.currentIntervalIndex].duration
                    self.timeRemainingInInterval = self.pausedTimeRemaining
                    self.resume()
                    self.onIntervalChange?(self.currentIntervalIndex)
                }
            } else {
                currentIntervalIndex += 1
                pausedTimeRemaining = program.intervals[currentIntervalIndex].duration
                timeRemainingInInterval = pausedTimeRemaining
                onIntervalChange?(currentIntervalIndex)
            }
        } else {
            stop()
        }
    }
    
    private func updateTotalProgress() {
        guard let program = program else {
            totalProgress = 0
            return
        }
        
        let totalDuration = program.totalDuration
        guard totalDuration > 0 else {
            totalProgress = 0
            return
        }
        
        var accumulatedTime: TimeInterval = 0
        for i in 0..<currentIntervalIndex {
            accumulatedTime += program.intervals[i].duration
        }
        
        let currentIntervalElapsed = program.intervals[currentIntervalIndex].duration - timeRemainingInInterval
        let totalElapsed = accumulatedTime + currentIntervalElapsed
        
        totalProgress = min(1.0, totalElapsed / totalDuration)
    }
    
    var currentInterval: Interval? {
        guard let program = program, currentIntervalIndex < program.intervals.count else { return nil }
        return program.intervals[currentIntervalIndex]
    }
    
    var completedIntervals: Int {
        guard let program = program else { return 0 }
        if state == .finished {
            return program.intervals.count
        }
        return currentIntervalIndex
    }
}


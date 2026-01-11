//
//  AudioService.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import AVFoundation
import Foundation

class AudioService {
    static let shared = AudioService()
    
    private var audioPlayer: AVAudioPlayer?
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    func playCountdownSound(count: Int) {
        // Generate a short beep sound
        let systemSoundId: SystemSoundID
        
        switch count {
        case 3:
            systemSoundId = 1054 // System sound for countdown
        case 2:
            systemSoundId = 1054
        case 1:
            systemSoundId = 1054
        default:
            systemSoundId = 1054
        }
        
        AudioServicesPlaySystemSound(systemSoundId)
    }
    
    func playIntervalEndSound(type: IntervalType) {
        let systemSoundId: SystemSoundID
        
        switch type {
        case .work:
            systemSoundId = 1057 // Different sound for work interval end
        case .rest:
            systemSoundId = 1053 // Different sound for rest interval end
        case .warmup, .cooldown:
            systemSoundId = 1054
        }
        
        AudioServicesPlaySystemSound(systemSoundId)
    }
    
    func playStartSound() {
        AudioServicesPlaySystemSound(1057)
    }
    
    func playFinishSound() {
        AudioServicesPlaySystemSound(1057)
    }
}


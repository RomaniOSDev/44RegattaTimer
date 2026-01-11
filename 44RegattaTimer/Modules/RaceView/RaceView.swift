//
//  RaceView.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import SwiftUI

struct RaceView: View {
    @StateObject private var viewModel: RaceViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(program: Program) {
        _viewModel = StateObject(wrappedValue: RaceViewModel(program: program))
    }
    
    var body: some View {
        ZStack {
            ColorTheme.seaDeep.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top panel - Program name and progress
                VStack(spacing: 12) {
                    Text(viewModel.program.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    ZStack {
                        Circle()
                            .stroke(ColorTheme.track.opacity(0.3), lineWidth: 8)
                            .frame(width: 60, height: 60)
                        
                        Circle()
                            .trim(from: 0, to: viewModel.timerEngine.totalProgress)
                            .stroke(ColorTheme.boat, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.1), value: viewModel.timerEngine.totalProgress)
                        
                        Text("\(Int(viewModel.timerEngine.totalProgress * 100))%")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(ColorTheme.boat)
                    }
                }
                .padding()
                
                // Center - Track visualization
                GeometryReader { geometry in
                    TrackView(
                        program: viewModel.program,
                        progress: viewModel.timerEngine.totalProgress,
                        ghostProgress: viewModel.ghostProgress
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .frame(maxHeight: .infinity)
                
                // Bottom panel - Timer and controls
                VStack(spacing: 16) {
                    // Current interval timer
                    VStack(spacing: 8) {
                        Text(formatTime(viewModel.timerEngine.timeRemainingInInterval))
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundColor(ColorTheme.boat)
                            .monospacedDigit()
                        
                        if let currentInterval = viewModel.timerEngine.currentInterval {
                            HStack {
                                Text(currentInterval.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text(currentInterval.type.displayName)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(currentInterval.type.backgroundColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        viewModel.timerEngine.currentInterval?.type.backgroundColor ?? ColorTheme.seaDeep
                    )
                    
                    // Control buttons
                    HStack(spacing: 20) {
                        if viewModel.timerEngine.state == .ready {
                            Button {
                                viewModel.startRace()
                            } label: {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("Start")
                                }
                                .font(.headline)
                                .foregroundColor(ColorTheme.seaDeep)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(ColorTheme.boat)
                                .cornerRadius(12)
                            }
                        } else if viewModel.timerEngine.state == .running {
                            Button {
                                viewModel.pauseRace()
                            } label: {
                                HStack {
                                    Image(systemName: "pause.fill")
                                    Text("Pause")
                                }
                                .font(.headline)
                                .foregroundColor(ColorTheme.seaDeep)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(ColorTheme.boat)
                                .cornerRadius(12)
                            }
                            
                            Button {
                                viewModel.skipInterval()
                            } label: {
                                Image(systemName: "forward.fill")
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(ColorTheme.track)
                                    .cornerRadius(12)
                            }
                            
                            Button {
                                viewModel.stopRace()
                            } label: {
                                Image(systemName: "stop.fill")
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.red)
                                    .cornerRadius(12)
                            }
                        } else if viewModel.timerEngine.state == .paused {
                            Button {
                                viewModel.resumeRace()
                            } label: {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("Resume")
                                }
                                .font(.headline)
                                .foregroundColor(ColorTheme.seaDeep)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(ColorTheme.boat)
                                .cornerRadius(12)
                            }
                            
                            Button {
                                viewModel.stopRace()
                            } label: {
                                Image(systemName: "stop.fill")
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color.red)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
        }
        .fullScreenCover(isPresented: $viewModel.showSessionResult) {
            if let result = viewModel.sessionResult {
                SessionResultView(
                    sessionResult: result,
                    program: viewModel.program,
                    onRepeat: {
                        viewModel.restartRace()
                    },
                    onBackToMenu: {
                        viewModel.showSessionResult = false
                        dismiss()
                    }
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    if viewModel.timerEngine.state == .running || viewModel.timerEngine.state == .paused {
                        viewModel.stopRace()
                    }
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(max(0, time))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct TrackView: View {
    let program: Program
    let progress: Double
    let ghostProgress: Double?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Track path
                TrackPath(intervals: program.intervals)
                    .stroke(ColorTheme.track, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                
                // Ghost boat
                if let ghostProgress = ghostProgress {
                    BoatView(position: ghostProgress)
                        .foregroundColor(ColorTheme.boat.opacity(0.4))
                }
                
                // Main boat
                BoatView(position: progress)
                    .foregroundColor(ColorTheme.boat)
                    .shadow(color: ColorTheme.boat.opacity(0.5), radius: 10)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct TrackPath: Shape {
    let intervals: [Interval]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        guard !intervals.isEmpty else { return path }
        
        let totalDuration = intervals.reduce(0) { $0 + $1.duration }
        guard totalDuration > 0 else { return path }
        
        let margin: CGFloat = 40
        let width = rect.width - margin * 2
        let height = rect.height - margin * 2
        
        var currentX: CGFloat = margin
        var currentY: CGFloat = margin + height / 2
        
        path.move(to: CGPoint(x: currentX, y: currentY))
        
        for interval in intervals {
            let segmentWidth = width * CGFloat(interval.duration / totalDuration)
            let nextX = currentX + segmentWidth
            
            // Create a curved segment
            let controlPoint1 = CGPoint(x: currentX + segmentWidth * 0.3, y: currentY - 20)
            let controlPoint2 = CGPoint(x: currentX + segmentWidth * 0.7, y: currentY - 20)
            
            path.addCurve(
                to: CGPoint(x: nextX, y: currentY),
                control1: controlPoint1,
                control2: controlPoint2
            )
            
            currentX = nextX
        }
        
        return path
    }
}

struct BoatView: View {
    let position: Double
    
    var body: some View {
        GeometryReader { geometry in
            let margin: CGFloat = 40
            let width = geometry.size.width - margin * 2
            let x = margin + width * CGFloat(position)
            let y = geometry.size.height / 2
            
            Circle()
                .frame(width: 20, height: 20)
                .position(x: x, y: y)
        }
    }
}

#Preview {
    RaceView(program: Program(
        name: "Test Program",
        intervals: [
            Interval(order: 0, name: "Warmup", duration: 60, type: .warmup),
            Interval(order: 1, name: "Work", duration: 120, type: .work),
            Interval(order: 2, name: "Rest", duration: 60, type: .rest)
        ]
    ))
}


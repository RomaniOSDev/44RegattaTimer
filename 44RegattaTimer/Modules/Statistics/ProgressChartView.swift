//
//  ProgressChartView.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import SwiftUI

struct ProgressChartView: View {
    let sessions: [SessionResult]
    let program: Program
    
    private var chartData: [ChartDataPoint] {
        sessions.sorted(by: { $0.date < $1.date })
            .enumerated()
            .map { index, session in
                ChartDataPoint(
                    index: index,
                    time: session.totalTime,
                    date: session.date
                )
            }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress Chart")
                .font(.headline)
                .foregroundColor(.white)
            
            if chartData.isEmpty {
                Text("No data available")
                    .foregroundColor(ColorTheme.track)
                    .frame(maxWidth: .infinity, minHeight: 150)
            } else {
                GeometryReader { geometry in
                    let maxTime = chartData.map { $0.time }.max() ?? 1
                    let minTime = chartData.map { $0.time }.min() ?? 0
                    let timeRange = maxTime - minTime
                    
                    ZStack {
                        // Grid lines
                        ForEach(0..<5) { i in
                            let y = CGFloat(i) / 4.0
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: geometry.size.height * (1 - y)))
                                path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height * (1 - y)))
                            }
                            .stroke(ColorTheme.track.opacity(0.2), lineWidth: 1)
                        }
                        
                        // Chart line
                        if chartData.count > 1 {
                            Path { path in
                                for (index, point) in chartData.enumerated() {
                                    let x = CGFloat(index) / CGFloat(max(chartData.count - 1, 1)) * geometry.size.width
                                    let normalizedTime = timeRange > 0 ? (point.time - minTime) / timeRange : 0.5
                                    let y = geometry.size.height * (1 - CGFloat(normalizedTime))
                                    
                                    if index == 0 {
                                        path.move(to: CGPoint(x: x, y: y))
                                    } else {
                                        path.addLine(to: CGPoint(x: x, y: y))
                                    }
                                }
                            }
                            .stroke(ColorTheme.boat, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                        }
                        
                        // Data points
                        ForEach(Array(chartData.enumerated()), id: \.offset) { index, point in
                            let x = CGFloat(index) / CGFloat(max(chartData.count - 1, 1)) * geometry.size.width
                            let normalizedTime = timeRange > 0 ? (point.time - minTime) / timeRange : 0.5
                            let y = geometry.size.height * (1 - CGFloat(normalizedTime))
                            
                            Circle()
                                .fill(ColorTheme.boat)
                                .frame(width: 6, height: 6)
                                .position(x: x, y: y)
                        }
                    }
                }
                .frame(height: 150)
            }
            
            // Legend
            HStack {
                Text("Best: \(formatTime(chartData.map { $0.time }.min() ?? 0))")
                    .font(.caption)
                    .foregroundColor(ColorTheme.track)
                
                Spacer()
                
                Text("Latest: \(formatTime(chartData.last?.time ?? 0))")
                    .font(.caption)
                    .foregroundColor(ColorTheme.track)
            }
        }
        .padding()
        .background(ColorTheme.seaDeep.opacity(0.5))
        .cornerRadius(12)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let total = Int(time)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct ChartDataPoint {
    let index: Int
    let time: TimeInterval
    let date: Date
}

#Preview {
    ProgressChartView(
        sessions: [
            SessionResult(programId: UUID(), programName: "Test", date: Date(), totalTime: 300, intervalsCompleted: 3, totalIntervals: 3),
            SessionResult(programId: UUID(), programName: "Test", date: Date(), totalTime: 280, intervalsCompleted: 3, totalIntervals: 3)
        ],
        program: Program(name: "Test", intervals: [])
    )
}


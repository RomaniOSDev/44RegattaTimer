//
//  AnalyticsView.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import SwiftUI

struct AnalyticsView: View {
    @StateObject private var statisticsViewModel = StatisticsViewModel()
    @StateObject private var achievementService = AchievementService()
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorTheme.seaDeep.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Performance Prediction
                        if let prediction = calculatePerformancePrediction() {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Performance Prediction")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Based on your recent progress, you're on track to improve by \(String(format: "%.1f", prediction.improvementPercent))% in the next month")
                                    .font(.subheadline)
                                    .foregroundColor(ColorTheme.track)
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Current Avg")
                                            .font(.caption)
                                            .foregroundColor(ColorTheme.track)
                                        Text(formatTime(prediction.currentAverage))
                                            .font(.headline)
                                            .foregroundColor(ColorTheme.boat)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.right")
                                        .foregroundColor(ColorTheme.track)
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text("Predicted Avg")
                                            .font(.caption)
                                            .foregroundColor(ColorTheme.track)
                                        Text(formatTime(prediction.predictedAverage))
                                            .font(.headline)
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                            .padding()
                            .background(ColorTheme.seaDeep.opacity(0.5))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        // Trends
                        if statisticsViewModel.allSessions.count >= 4 {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Trends")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                TrendCardView(
                                    title: "Weekly Trend",
                                    sessions: statisticsViewModel.weeklyStats?.sessions ?? [],
                                    isImproving: calculateTrend(sessions: statisticsViewModel.weeklyStats?.sessions ?? [])
                                )
                                
                                TrendCardView(
                                    title: "Monthly Trend",
                                    sessions: statisticsViewModel.monthlyStats?.sessions ?? [],
                                    isImproving: calculateTrend(sessions: statisticsViewModel.monthlyStats?.sessions ?? [])
                                )
                            }
                        }
                        
                        // Achievement Progress
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Achievement Progress")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            Text("\(achievementService.unlockedCount) / \(achievementService.totalCount) unlocked")
                                .font(.subheadline)
                                .foregroundColor(ColorTheme.track)
                                .padding(.horizontal)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(ColorTheme.track.opacity(0.3))
                                        .frame(height: 20)
                                        .cornerRadius(10)
                                    
                                    Rectangle()
                                        .fill(ColorTheme.boat)
                                        .frame(width: geometry.size.width * Double(achievementService.unlockedCount) / Double(achievementService.totalCount), height: 20)
                                        .cornerRadius(10)
                                }
                            }
                            .frame(height: 20)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                statisticsViewModel.loadStatistics()
                achievementService.checkAchievements()
            }
        }
    }
    
    private func calculatePerformancePrediction() -> PerformancePrediction? {
        guard let monthlyStats = statisticsViewModel.monthlyStats,
              monthlyStats.sessions.count >= 4 else {
            return nil
        }
        
        let sessions = monthlyStats.sessions.sorted { $0.date < $1.date }
        let firstHalf = Array(sessions.prefix(sessions.count / 2))
        let secondHalf = Array(sessions.suffix(sessions.count / 2))
        
        let firstAvg = firstHalf.reduce(0) { $0 + $1.totalTime } / Double(firstHalf.count)
        let secondAvg = secondHalf.reduce(0) { $0 + $1.totalTime } / Double(secondHalf.count)
        
        let improvementRate = (firstAvg - secondAvg) / firstAvg // Negative means improvement
        let predictedAverage = secondAvg * (1 - improvementRate)
        let improvementPercent = abs(improvementRate) * 100
        
        return PerformancePrediction(
            currentAverage: secondAvg,
            predictedAverage: predictedAverage,
            improvementPercent: improvementPercent
        )
    }
    
    private func calculateTrend(sessions: [SessionResult]) -> Bool {
        guard sessions.count >= 4 else { return false }
        
        let sorted = sessions.sorted { $0.date < $1.date }
        let firstHalf = Array(sorted.prefix(sorted.count / 2))
        let secondHalf = Array(sorted.suffix(sorted.count / 2))
        
        let firstAvg = firstHalf.reduce(0) { $0 + $1.totalTime } / Double(firstHalf.count)
        let secondAvg = secondHalf.reduce(0) { $0 + $1.totalTime } / Double(secondHalf.count)
        
        return secondAvg < firstAvg // Improving if times are decreasing
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let total = Int(time)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct PerformancePrediction {
    let currentAverage: TimeInterval
    let predictedAverage: TimeInterval
    let improvementPercent: Double
}

struct TrendCardView: View {
    let title: String
    let sessions: [SessionResult]
    let isImproving: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    Image(systemName: isImproving ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                        .foregroundColor(isImproving ? .green : .orange)
                    Text(isImproving ? "Improving" : "Needs Work")
                        .font(.subheadline)
                        .foregroundColor(isImproving ? .green : .orange)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(ColorTheme.seaDeep.opacity(0.5))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    AnalyticsView()
}


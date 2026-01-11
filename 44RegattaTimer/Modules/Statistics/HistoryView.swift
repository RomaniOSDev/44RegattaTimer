//
//  HistoryView.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = StatisticsViewModel()
    @StateObject private var programListViewModel = ProgramListViewModel()
    @State private var selectedProgram: Program?
    @State private var showingDetails = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorTheme.seaDeep.ignoresSafeArea()
                
                if viewModel.allSessions.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "chart.bar")
                            .font(.system(size: 60))
                            .foregroundColor(ColorTheme.track)
                        Text("No History")
                            .font(.title2)
                            .foregroundColor(ColorTheme.track)
                        Text("Complete a training session to see statistics")
                            .font(.subheadline)
                            .foregroundColor(ColorTheme.track.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Weekly Stats
                            if let weeklyStats = viewModel.weeklyStats {
                                StatsCardView(title: "This Week", stats: weeklyStats)
                            }
                            
                            // Monthly Stats
                            if let monthlyStats = viewModel.monthlyStats {
                                StatsCardView(title: "This Month", stats: monthlyStats)
                            }
                            
                            // Sessions by Program
                            if !programListViewModel.programs.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Sessions by Program")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                    
                                    ForEach(programListViewModel.programs) { program in
                                        VStack(spacing: 12) {
                                            ProgramStatsCard(
                                                program: program,
                                                sessions: viewModel.sessions(for: program.id),
                                                personalRecord: viewModel.personalRecord(for: program.id)
                                            )
                                            
                                            // Progress Chart
                                            if viewModel.sessions(for: program.id).count > 1 {
                                                ProgressChartView(
                                                    sessions: viewModel.sessions(for: program.id),
                                                    program: program
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // All Sessions List
                            VStack(alignment: .leading, spacing: 12) {
                                Text("All Sessions")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                ForEach(viewModel.allSessions.prefix(20)) { session in
                                    SessionRowView(session: session)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.loadStatistics()
                programListViewModel.loadPrograms()
            }
        }
    }
}

struct StatsCardView: View {
    let title: String
    let stats: Any
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            if let weekly = stats as? WeeklyStats {
                HStack(spacing: 20) {
                    StatItem(label: "Sessions", value: "\(weekly.totalSessions)")
                    StatItem(label: "Total Time", value: weekly.formattedTotalTime)
                    StatItem(label: "Avg Time", value: weekly.formattedAverageTime)
                }
            } else if let monthly = stats as? MonthlyStats {
                HStack(spacing: 20) {
                    StatItem(label: "Sessions", value: "\(monthly.totalSessions)")
                    StatItem(label: "Total Time", value: monthly.formattedTotalTime)
                    StatItem(label: "Avg Time", value: monthly.formattedAverageTime)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ColorTheme.seaDeep.opacity(0.5))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct StatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(ColorTheme.track)
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(ColorTheme.boat)
        }
    }
}

struct ProgramStatsCard: View {
    let program: Program
    let sessions: [SessionResult]
    let personalRecord: SessionResult?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(program.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if let record = personalRecord {
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(ColorTheme.boat)
                        Text("PR: \(record.formattedTotalTime)")
                            .font(.subheadline)
                            .foregroundColor(ColorTheme.boat)
                    }
                }
            }
            
            Text("\(sessions.count) sessions")
                .font(.subheadline)
                .foregroundColor(ColorTheme.track)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ColorTheme.seaDeep.opacity(0.5))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct SessionRowView: View {
    let session: SessionResult
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.programName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(session.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(ColorTheme.track)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(session.formattedTotalTime)
                    .font(.headline)
                    .foregroundColor(ColorTheme.boat)
                
                Text("\(session.intervalsCompleted)/\(session.totalIntervals)")
                    .font(.caption)
                    .foregroundColor(ColorTheme.track)
            }
        }
        .padding()
        .background(ColorTheme.seaDeep.opacity(0.3))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

#Preview {
    HistoryView()
}


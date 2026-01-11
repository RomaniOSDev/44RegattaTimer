//
//  ProgramListView.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import SwiftUI

struct ProgramListView: View {
    @StateObject private var viewModel = ProgramListViewModel()
    @StateObject private var statisticsViewModel = StatisticsViewModel()
    @State private var showingEditor = false
    @State private var selectedProgram: Program?
    @State private var programToEdit: Program?
    @State private var showingWorkoutModeSelector = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [ColorTheme.seaDeep, ColorTheme.seaDeep.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if viewModel.programs.isEmpty {
                    EmptyStateView()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Header Section
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Regatta Timer")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.white)
                                        
                                        Text("Your Training Companion")
                                            .font(.subheadline)
                                            .foregroundColor(ColorTheme.track)
                                    }
                                    
                                    Spacer()
                                    
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [ColorTheme.boat.opacity(0.3), ColorTheme.boat.opacity(0.1)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 60, height: 60)
                                        
                                        Image(systemName: "sailboat.fill")
                                            .font(.title2)
                                            .foregroundColor(ColorTheme.boat)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            
                            // Quick Stats Section
                            QuickStatsSection(statisticsViewModel: statisticsViewModel)
                            
                            // Programs Grid
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Training Programs")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(viewModel.programs.count)")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(ColorTheme.boat)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(ColorTheme.boat.opacity(0.2))
                                        .cornerRadius(12)
                                }
                                .padding(.horizontal)
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                    ForEach(viewModel.programs) { program in
                                        ProgramCardView(
                                            program: program,
                                            bestTime: statisticsViewModel.personalRecord(for: program.id)?.formattedTotalTime
                                        )
                                        .onTapGesture {
                                            selectedProgram = program
                                        }
                                        .contextMenu {
                                            Button {
                                                programToEdit = program
                                                showingEditor = true
                                            } label: {
                                                Label("Edit", systemImage: "pencil")
                                            }
                                            
                                            Button {
                                                viewModel.duplicateProgram(program)
                                            } label: {
                                                Label("Duplicate", systemImage: "doc.on.doc")
                                            }
                                            
                                            Button(role: .destructive) {
                                                viewModel.deleteProgram(program)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ColorTheme.seaDeep, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        NavigationLink {
                            HistoryView()
                        } label: {
                            Label("Statistics", systemImage: "chart.bar")
                        }
                        
                        NavigationLink {
                            AnalyticsView()
                        } label: {
                            Label("Analytics", systemImage: "chart.line.uptrend.xyaxis")
                        }
                        
                        NavigationLink {
                            GoalsView()
                        } label: {
                            Label("Goals", systemImage: "target")
                        }
                        
                        NavigationLink {
                            AchievementsView()
                        } label: {
                            Label("Achievements", systemImage: "trophy")
                        }
                        
                        Divider()
                        
                        NavigationLink {
                            SettingsView()
                        } label: {
                            Label("Settings", systemImage: "gearshape")
                        }
                    } label: {
                        Image(systemName: "chart.bar")
                            .foregroundColor(ColorTheme.boat)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            programToEdit = nil
                            showingEditor = true
                        } label: {
                            Label("Custom Program", systemImage: "plus")
                        }
                        
                        Button {
                            showingWorkoutModeSelector = true
                        } label: {
                            Label("From Template", systemImage: "square.grid.2x2")
                        }
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(ColorTheme.boat)
                    }
                }
            }
            .sheet(isPresented: $showingEditor) {
                if let program = programToEdit {
                    ProgramEditorView(program: program)
                        .onDisappear {
                            viewModel.loadPrograms()
                            programToEdit = nil
                        }
                } else {
                    ProgramEditorView()
                        .onDisappear {
                            viewModel.loadPrograms()
                        }
                }
            }
            .sheet(isPresented: $showingWorkoutModeSelector) {
                WorkoutModeSelectorView { program in
                    let persistenceService = PersistenceService()
                    persistenceService.saveProgram(program)
                    viewModel.loadPrograms()
                }
            }
            .fullScreenCover(item: $selectedProgram) { program in
                RaceView(program: program)
            }
            .onAppear {
                viewModel.loadPrograms()
                statisticsViewModel.loadStatistics()
            }
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [ColorTheme.boat.opacity(0.3), ColorTheme.boat.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "sailboat.fill")
                    .font(.system(size: 60))
                    .foregroundColor(ColorTheme.boat)
            }
            
            VStack(spacing: 8) {
                Text("Welcome to Regatta Timer")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Create your first training program\nto start your fitness journey")
                    .font(.subheadline)
                    .foregroundColor(ColorTheme.track)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
}

struct QuickStatsSection: View {
    @ObservedObject var statisticsViewModel: StatisticsViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Quick Stats")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal)
            
            HStack(spacing: 12) {
                StatMiniCard(
                    icon: "flame.fill",
                    value: "\(statisticsViewModel.allSessions.count)",
                    label: "Sessions",
                    color: .orange
                )
                
                StatMiniCard(
                    icon: "trophy.fill",
                    value: "\(statisticsViewModel.personalRecords.count)",
                    label: "Records",
                    color: ColorTheme.boat
                )
                
                StatMiniCard(
                    icon: "calendar.badge.clock",
                    value: statisticsViewModel.weeklyStats != nil ? "\(statisticsViewModel.weeklyStats!.totalSessions)" : "0",
                    label: "This Week",
                    color: .green
                )
            }
            .padding(.horizontal)
        }
    }
}

struct StatMiniCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(ColorTheme.track)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ColorTheme.seaDeep.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct ProgramCardView: View {
    let program: Program
    let bestTime: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with icon
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [ColorTheme.boat.opacity(0.3), ColorTheme.boat.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: program.isTabataMode ? "bolt.fill" : "figure.run")
                        .font(.title3)
                        .foregroundColor(ColorTheme.boat)
                }
                
                Spacer()
                
                if program.isTabataMode {
                    Text("TABATA")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(ColorTheme.boat)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(ColorTheme.boat.opacity(0.2))
                        .cornerRadius(6)
                }
            }
            
            // Program name
            Text(program.name)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(2)
            
            // Duration and intervals
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundColor(ColorTheme.track)
                    Text(program.formattedTotalDuration)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(ColorTheme.boat)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "list.number")
                        .font(.caption)
                        .foregroundColor(ColorTheme.track)
                    Text("\(program.intervals.count) intervals")
                        .font(.caption)
                        .foregroundColor(ColorTheme.track)
                }
            }
            
            // Best time if available
            if let bestTime = bestTime {
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.caption)
                        .foregroundColor(ColorTheme.boat)
                    Text("PR: \(bestTime)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(ColorTheme.boat)
                }
                .padding(.top, 4)
            }
            
            Spacer()
            
            // Start button
            HStack {
                Spacer()
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(ColorTheme.boat)
            }
        }
        .padding()
        .frame(height: 200)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            ColorTheme.seaDeep.opacity(0.8),
                            ColorTheme.seaDeep.opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [ColorTheme.boat.opacity(0.3), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: ColorTheme.boat.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ProgramListView()
}


//
//  AchievementsView.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import SwiftUI

struct AchievementsView: View {
    @StateObject private var achievementService = AchievementService()
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorTheme.seaDeep.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Summary
                        VStack(spacing: 12) {
                            Text("\(achievementService.unlockedCount) / \(achievementService.totalCount)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(ColorTheme.boat)
                            
                            Text("Achievements Unlocked")
                                .font(.headline)
                                .foregroundColor(ColorTheme.track)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(ColorTheme.seaDeep.opacity(0.5))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Achievements Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(achievementService.achievements) { achievement in
                                AchievementCardView(achievement: achievement)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                achievementService.checkAchievements()
            }
        }
    }
}

struct AchievementCardView: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? ColorTheme.boat.opacity(0.2) : ColorTheme.track.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: achievement.type.iconName)
                    .font(.system(size: 40))
                    .foregroundColor(achievement.isUnlocked ? ColorTheme.boat : ColorTheme.track.opacity(0.5))
            }
            
            VStack(spacing: 4) {
                Text(achievement.type.displayName)
                    .font(.headline)
                    .foregroundColor(achievement.isUnlocked ? .white : ColorTheme.track)
                    .multilineTextAlignment(.center)
                
                Text(achievement.type.description)
                    .font(.caption)
                    .foregroundColor(ColorTheme.track)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                if !achievement.isUnlocked && achievement.progress > 0 {
                    Text("\(Int(achievement.progress * 100))%")
                        .font(.caption)
                        .foregroundColor(ColorTheme.boat)
                        .padding(.top, 4)
                }
                
                if let date = achievement.unlockedDate {
                    Text(date, style: .date)
                        .font(.caption2)
                        .foregroundColor(ColorTheme.track.opacity(0.7))
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(ColorTheme.seaDeep.opacity(0.5))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(achievement.isUnlocked ? ColorTheme.boat : Color.clear, lineWidth: 2)
        )
    }
}

#Preview {
    AchievementsView()
}


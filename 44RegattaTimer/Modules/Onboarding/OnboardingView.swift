//
//  OnboardingView.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            ColorTheme.seaDeep.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page Content
                TabView(selection: $currentPage) {
                    OnboardingPageView(
                        imageName: "sailboat.fill",
                        title: "Welcome to Regatta Timer",
                        description: "Professional interval training timer with beautiful race visualization. Track your progress and achieve your fitness goals.",
                        pageIndex: 0
                    )
                    .tag(0)
                    
                    OnboardingPageView(
                        imageName: "chart.line.uptrend.xyaxis",
                        title: "Track Your Progress",
                        description: "Monitor your performance with detailed statistics, personal records, and progress charts. Compare your times and improve.",
                        pageIndex: 1
                    )
                    .tag(1)
                    
                    OnboardingPageView(
                        imageName: "target",
                        title: "Set Goals & Achieve",
                        description: "Create training programs, set goals, and unlock achievements. Stay motivated with our comprehensive tracking system.",
                        pageIndex: 2
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Bottom Section
                VStack(spacing: 20) {
                    // Page Indicators
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(index == currentPage ? ColorTheme.boat : ColorTheme.track.opacity(0.3))
                                .frame(width: index == currentPage ? 12 : 8, height: index == currentPage ? 12 : 8)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Action Button
                    Button {
                        if currentPage < 2 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            hasCompletedOnboarding = true
                        }
                    } label: {
                        HStack {
                            Text(currentPage < 2 ? "Next" : "Get Started")
                                .font(.headline)
                                .foregroundColor(ColorTheme.seaDeep)
                            
                            if currentPage < 2 {
                                Image(systemName: "arrow.right")
                                    .font(.headline)
                                    .foregroundColor(ColorTheme.seaDeep)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ColorTheme.boat)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String
    let pageIndex: Int
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon/Image
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ColorTheme.boat.opacity(0.3),
                                ColorTheme.boat.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                
                Image(systemName: imageName)
                    .font(.system(size: 100))
                    .foregroundColor(ColorTheme.boat)
            }
            .padding(.bottom, 20)
            
            // Text Content
            VStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(ColorTheme.track)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .padding(.vertical, 60)
    }
}

#Preview {
    OnboardingView()
}


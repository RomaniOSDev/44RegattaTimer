//
//  SettingsView.swift
//  44RegattaTimer
//
//  Created by Роман Главацкий on 07.01.2026.
//

import SwiftUI
import UIKit
import StoreKit

struct SettingsView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                ColorTheme.seaDeep.ignoresSafeArea()
                
                List {
                    Section {
                        SettingsRowView(
                            icon: "star.fill",
                            title: "Rate Us",
                            iconColor: ColorTheme.boat
                        ) {
                            rateApp()
                        }
                        
                        SettingsRowView(
                            icon: "lock.shield.fill",
                            title: "Privacy Policy",
                            iconColor: .blue
                        ) {
                            openPrivacyPolicy()
                        }
                        
                        SettingsRowView(
                            icon: "doc.text.fill",
                            title: "Terms of Service",
                            iconColor: .green
                        ) {
                            openTermsOfService()
                        }
                    } header: {
                        Text("Legal")
                            .foregroundColor(ColorTheme.track)
                    }
                    .listRowBackground(ColorTheme.seaDeep.opacity(0.5))
                    
                    Section {
                        SettingsRowView(
                            icon: "info.circle.fill",
                            title: "Version",
                            iconColor: ColorTheme.track,
                            showChevron: false,
                            trailingText: "1.0.0"
                        ) {
                            // No action
                        }
                        
                        SettingsRowView(
                            icon: "arrow.clockwise",
                            title: "Show Onboarding",
                            iconColor: ColorTheme.boat
                        ) {
                            hasCompletedOnboarding = false
                        }
                    } header: {
                        Text("About")
                            .foregroundColor(ColorTheme.track)
                    }
                    .listRowBackground(ColorTheme.seaDeep.opacity(0.5))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func rateApp() {
        SKStoreReviewController.requestReview()
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://example.com/privacy-policy") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openTermsOfService() {
        if let url = URL(string: "https://example.com/terms-of-service") {
            UIApplication.shared.open(url)
        }
    }
}

struct SettingsRowView: View {
    let icon: String
    let title: String
    let iconColor: Color
    var showChevron: Bool = true
    var trailingText: String?
    let action: () -> Void
    
    init(
        icon: String,
        title: String,
        iconColor: Color,
        showChevron: Bool = true,
        trailingText: String? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.iconColor = iconColor
        self.showChevron = showChevron
        self.trailingText = trailingText
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                }
                
                Text(title)
                    .foregroundColor(.white)
                    .font(.body)
                
                Spacer()
                
                if let trailingText = trailingText {
                    Text(trailingText)
                        .foregroundColor(ColorTheme.track)
                } else if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(ColorTheme.track)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    SettingsView()
}


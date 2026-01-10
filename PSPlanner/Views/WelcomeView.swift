//
//  WelcomeView.swift
//  PSPlanner
//
//  Created by Sean Raymor on 1/9/26.
//

import SwiftUI

struct WelcomeView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "checkmark.circle.fill",
            iconColor: .orange,
            title: "Welcome to PS Planner",
            subtitle: "Your personal task organizer",
            description: "Stay on top of your daily, weekly, and monthly tasks with a simple, beautiful interface."
        ),
        OnboardingPage(
            icon: "calendar.badge.clock",
            iconColor: .blue,
            title: "Organize by Time",
            subtitle: "Daily • Weekly • Monthly",
            description: "Break down your tasks by time period. Focus on today's priorities or plan ahead for the month."
        ),
        OnboardingPage(
            icon: "folder.fill",
            iconColor: .green,
            title: "Categories & Colors",
            subtitle: "Keep everything organized",
            description: "Group tasks by category like Home, Work, or Errands. Each with its own color for easy recognition."
        ),
        OnboardingPage(
            icon: "clock.badge.checkmark.fill",
            iconColor: .cyan,
            title: "Never Miss a Deadline",
            subtitle: "Smart task visibility",
            description: "Set deadlines on tasks and they'll appear in your daily view when due. Incomplete tasks carry forward until done."
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Page content
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentPage)
            
            // Bottom section
            VStack(spacing: 24) {
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? Color.orange : Color.secondary.opacity(0.3))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                
                // Buttons
                if currentPage == pages.count - 1 {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            hasCompletedOnboarding = true
                        }
                    } label: {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    HStack(spacing: 16) {
                        Button {
                            hasCompletedOnboarding = true
                        } label: {
                            Text("Skip")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                        }
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Text("Next")
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let description: String
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(page.iconColor.opacity(0.15))
                    .frame(width: 140, height: 140)
                
                Image(systemName: page.icon)
                    .font(.system(size: 60))
                    .foregroundStyle(page.iconColor)
            }
            
            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.orange)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    WelcomeView(hasCompletedOnboarding: .constant(false))
}


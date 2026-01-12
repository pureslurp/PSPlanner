//
//  RootView.swift
//  Gotta
//
//  Created by Sean Raymor on 1/9/26.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @State private var hasSeededCategories = false
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                ContentView()
                    .transition(.opacity)
            } else {
                WelcomeView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: hasCompletedOnboarding)
        .onAppear {
            seedDefaultCategoriesIfNeeded()
            // Use fully qualified name to disambiguate from SwiftData Task model
            _Concurrency.Task {
                await requestNotificationPermission()
            }
        }
        .onChange(of: hasCompletedOnboarding) { _, newValue in
            if newValue {
                // Seed categories when onboarding completes (in case they weren't seeded)
                seedDefaultCategoriesIfNeeded()
                // Use fully qualified name to disambiguate from SwiftData Task model
                _Concurrency.Task {
                    await requestNotificationPermission()
                }
            }
        }
    }
    
    private func seedDefaultCategoriesIfNeeded() {
        // Only seed if we haven't already and there are no existing categories
        guard !hasSeededCategories && categories.isEmpty else { return }
        
        hasSeededCategories = true
        
        // Create default categories
        for (name, colorHex) in Category.defaultCategories {
            let category = Category(name: name, colorHex: colorHex)
            modelContext.insert(category)
        }
        
        // Save immediately
        do {
            try modelContext.save()
        } catch {
            print("Failed to seed default categories: \(error)")
        }
    }
    
    private func requestNotificationPermission() async {
        // Only request if notifications are enabled by user
        guard notificationsEnabled else { return }
        
        _ = await NotificationManager.shared.requestAuthorization()
    }
}

#Preview("Onboarding") {
    RootView()
        .modelContainer(for: [Task.self, Category.self], inMemory: true)
}

#Preview("Main App") {
    RootView()
        .modelContainer(for: [Task.self, Category.self], inMemory: true)
        .onAppear {
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        }
}


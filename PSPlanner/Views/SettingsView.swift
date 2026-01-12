import SwiftUI
import UserNotifications

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @State private var isCheckingStatus = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { oldValue, newValue in
                            handleNotificationToggle(newValue: newValue)
                        }
                    
                    if authorizationStatus == .denied {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text("Notifications are disabled in Settings")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Button("Open Settings") {
                            NotificationManager.shared.openSettings()
                        }
                    } else if authorizationStatus == .notDetermined {
                        Text("Enable notifications to receive reminders for your tasks")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Get reminded about tasks with deadlines or receive daily, weekly, and monthly reminders for tasks without deadlines.")
                }
                
                #if DEBUG
                Section("Debug") {
                    Button("List Pending Notifications") {
                        _Concurrency.Task {
                            await NotificationManager.shared.listPendingNotifications()
                        }
                    }
                }
                #endif
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await checkAuthorizationStatus()
            }
        }
    }
    
    private func checkAuthorizationStatus() async {
        isCheckingStatus = true
        authorizationStatus = await NotificationManager.shared.checkAuthorizationStatus()
        isCheckingStatus = false
        
        // If user disabled in system settings, update our toggle
        if authorizationStatus == .denied && notificationsEnabled {
            notificationsEnabled = false
        }
    }
    
    private func handleNotificationToggle(newValue: Bool) {
        if newValue {
            // User wants to enable notifications - request permission
            _Concurrency.Task {
                let granted = await NotificationManager.shared.requestAuthorization()
                if !granted {
                    // Permission denied, update toggle back
                    await MainActor.run {
                        notificationsEnabled = false
                    }
                }
                await checkAuthorizationStatus()
            }
        } else {
            // User wants to disable notifications - cancel all pending notifications
            _Concurrency.Task {
                let center = UNUserNotificationCenter.current()
                center.removeAllPendingNotificationRequests()
            }
        }
    }
}

#Preview {
    SettingsView()
}

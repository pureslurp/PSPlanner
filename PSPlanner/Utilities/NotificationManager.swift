import Foundation
import UIKit
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()
    
    private let center = UNUserNotificationCenter.current()
    
    // Debug mode for testing notifications with short delays
    #if DEBUG
    static var testModeEnabled = false // Set to false to use real notification times
    static let testDelaySeconds: TimeInterval = 5 // Notification fires in 5 seconds
    #else
    static let testModeEnabled = false
    #endif
    
    // Notification IDs for recurring reminders (no deadline tasks)
    private enum RecurringNotificationID {
        static let dailyReminder = "daily-reminder"
        static let weeklyReminder = "weekly-reminder"
        static let monthlyReminder = "monthly-reminder"
    }
    
    private init() {}
    
    // MARK: - Permission Request
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            print("📱 Notification permission \(granted ? "granted" : "denied")")
            return granted
        } catch {
            print("❌ Notification authorization error: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            _Concurrency.Task { @MainActor in
                if await UIApplication.shared.canOpenURL(url) {
                    await UIApplication.shared.open(url)
                }
            }
        }
    }
    
    // MARK: - Task Notifications (with deadlines)
    
    func scheduleNotification(for task: Task) async {
        // Check if notifications are enabled by user (default to true if key doesn't exist)
        let notificationsEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool ?? true
        guard notificationsEnabled else {
            print("⚠️ Notifications disabled by user preference")
            return
        }
        
        // Check authorization status
        let status = await checkAuthorizationStatus()
        guard status == .authorized else {
            print("⚠️ Notification authorization status: \(status.rawValue) - not authorized")
            return
        }
        
        // Skip if task is completed
        guard !task.isCompleted else {
            print("⚠️ Task '\(task.title)' is already completed - skipping notification")
            return
        }
        
        // Skip if no deadline
        guard let deadline = task.deadline else {
            print("⚠️ Task '\(task.title)' has no deadline - skipping notification")
            return
        }
        
        // Skip if deadline is in the past
        guard deadline > Date() else {
            print("⚠️ Task '\(task.title)' deadline is in the past - skipping notification")
            return
        }
        
        // Calculate notification time based on task type
        let notificationDate = calculateNotificationDate(for: task, deadline: deadline)
        
        // Skip if notification time is in the past
        guard notificationDate > Date() else {
            print("⚠️ Task '\(task.title)' notification time is in the past - skipping notification")
            return
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = "\(task.title)"
        content.sound = .default
        
        // Add task identifier to userInfo for potential deep linking
        content.userInfo = ["taskID": task.id.uuidString, "taskType": task.taskType.rawValue]
        
        // Create trigger - use test mode delay if enabled, otherwise use calculated date
        let trigger: UNNotificationTrigger
        #if DEBUG
        if Self.testModeEnabled {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: Self.testDelaySeconds, repeats: false)
        } else {
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        }
        #else
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        #endif
        
        // Create request with task ID
        let requestID = task.id.uuidString
        let request = UNNotificationRequest(identifier: requestID, content: content, trigger: trigger)
        
        // Store notification ID in task (we'll need to update task model)
        // For now, we'll just schedule it
        
        // Schedule notification
        do {
            try await center.add(request)
            #if DEBUG
            if Self.testModeEnabled {
                print("✅ Notification scheduled for task: '\(task.title)' - will fire in \(Self.testDelaySeconds) seconds")
            } else {
                print("✅ Notification scheduled for task: '\(task.title)' - will fire at scheduled time")
            }
            #else
            print("✅ Notification scheduled for task: '\(task.title)' - will fire at scheduled time")
            #endif
        } catch {
            print("❌ Failed to schedule notification for task \(task.id): \(error)")
        }
    }
    
    func cancelNotification(for task: Task) async {
        let requestID = task.id.uuidString
        center.removePendingNotificationRequests(withIdentifiers: [requestID])
    }
    
    // MARK: - Recurring Notifications (no deadline tasks)
    
    func rescheduleRecurringNotifications(incompleteTasks: [Task]) async {
        // Check if notifications are enabled by user (default to true if key doesn't exist)
        let notificationsEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool ?? true
        guard notificationsEnabled else {
            // Cancel all recurring notifications if disabled
            center.removePendingNotificationRequests(withIdentifiers: [
                RecurringNotificationID.dailyReminder,
                RecurringNotificationID.weeklyReminder,
                RecurringNotificationID.monthlyReminder
            ])
            return
        }
        
        // Check authorization status
        let status = await checkAuthorizationStatus()
        guard status == .authorized else {
            // Cancel all recurring notifications if not authorized
            center.removePendingNotificationRequests(withIdentifiers: [
                RecurringNotificationID.dailyReminder,
                RecurringNotificationID.weeklyReminder,
                RecurringNotificationID.monthlyReminder
            ])
            return
        }
        
        // Group tasks by type
        let dailyTasks = incompleteTasks.filter { $0.taskType == .daily && $0.deadline == nil }
        let weeklyTasks = incompleteTasks.filter { $0.taskType == .weekly && $0.deadline == nil }
        let monthlyTasks = incompleteTasks.filter { $0.taskType == .monthly && $0.deadline == nil }
        
        // Cancel existing recurring notifications
        center.removePendingNotificationRequests(withIdentifiers: [
            RecurringNotificationID.dailyReminder,
            RecurringNotificationID.weeklyReminder,
            RecurringNotificationID.monthlyReminder
        ])
        
        // Schedule new recurring notifications only if there are incomplete tasks
        if !dailyTasks.isEmpty {
            await scheduleDailyReminder(count: dailyTasks.count)
        }
        
        if !weeklyTasks.isEmpty {
            await scheduleWeeklyReminder(count: weeklyTasks.count)
        }
        
        if !monthlyTasks.isEmpty {
            await scheduleMonthlyReminder(count: monthlyTasks.count)
        }
    }
    
    private func scheduleDailyReminder(count: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "Daily Tasks Reminder"
        content.body = "You have \(count) daily task\(count == 1 ? "" : "s") remaining"
        content.sound = .default
        
        // Create trigger - use test mode delay if enabled
        let trigger: UNNotificationTrigger
        #if DEBUG
        if Self.testModeEnabled {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: Self.testDelaySeconds, repeats: false)
        } else {
            var dateComponents = DateComponents()
            dateComponents.hour = 20 // 8pm
            dateComponents.minute = 0
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        }
        #else
        var dateComponents = DateComponents()
        dateComponents.hour = 20 // 8pm
        dateComponents.minute = 0
        trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        #endif
        
        let request = UNNotificationRequest(
            identifier: RecurringNotificationID.dailyReminder,
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            #if DEBUG
            if Self.testModeEnabled {
                print("✅ Daily reminder scheduled - will fire in \(Self.testDelaySeconds) seconds")
            } else {
                print("✅ Daily reminder scheduled - will fire at 8pm daily")
            }
            #else
            print("✅ Daily reminder scheduled - will fire at 8pm daily")
            #endif
        } catch {
            print("❌ Failed to schedule daily reminder: \(error)")
        }
    }
    
    private func scheduleWeeklyReminder(count: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "Weekly Tasks Reminder"
        content.body = "You have \(count) weekly task\(count == 1 ? "" : "s") remaining"
        content.sound = .default
        
        // Create trigger - use test mode delay if enabled
        let trigger: UNNotificationTrigger
        #if DEBUG
        if Self.testModeEnabled {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: Self.testDelaySeconds, repeats: false)
        } else {
            var dateComponents = DateComponents()
            dateComponents.weekday = 1 // Sunday
            dateComponents.hour = 9 // 9am
            dateComponents.minute = 0
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        }
        #else
        var dateComponents = DateComponents()
        dateComponents.weekday = 1 // Sunday
        dateComponents.hour = 9 // 9am
        dateComponents.minute = 0
        trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        #endif
        
        let request = UNNotificationRequest(
            identifier: RecurringNotificationID.weeklyReminder,
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            #if DEBUG
            if Self.testModeEnabled {
                print("✅ Weekly reminder scheduled - will fire in \(Self.testDelaySeconds) seconds")
            } else {
                print("✅ Weekly reminder scheduled - will fire on Sunday 9am")
            }
            #else
            print("✅ Weekly reminder scheduled - will fire on Sunday 9am")
            #endif
        } catch {
            print("❌ Failed to schedule weekly reminder: \(error)")
        }
    }
    
    private func scheduleMonthlyReminder(count: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "Monthly Tasks Reminder"
        content.body = "You have \(count) monthly task\(count == 1 ? "" : "s") remaining"
        content.sound = .default
        
        // Create trigger - use test mode delay if enabled
        let trigger: UNNotificationTrigger
        #if DEBUG
        if Self.testModeEnabled {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: Self.testDelaySeconds, repeats: false)
        } else {
            // Schedule for 1 week before end of month at 9am
            // Using the 23rd of each month (roughly 1 week before end)
            var dateComponents = DateComponents()
            dateComponents.day = 23
            dateComponents.hour = 9
            dateComponents.minute = 0
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        }
        #else
        // Schedule for 1 week before end of month at 9am
        // Using the 23rd of each month (roughly 1 week before end)
        var dateComponents = DateComponents()
        dateComponents.day = 23
        dateComponents.hour = 9
        dateComponents.minute = 0
        trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        #endif
        
        let request = UNNotificationRequest(
            identifier: RecurringNotificationID.monthlyReminder,
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            #if DEBUG
            if Self.testModeEnabled {
                print("✅ Monthly reminder scheduled - will fire in \(Self.testDelaySeconds) seconds")
            } else {
                print("✅ Monthly reminder scheduled - will fire on 23rd at 9am")
            }
            #else
            print("✅ Monthly reminder scheduled - will fire on 23rd at 9am")
            #endif
        } catch {
            print("❌ Failed to schedule monthly reminder: \(error)")
        }
    }
    
    // MARK: - Debug Methods
    
    #if DEBUG
    func listPendingNotifications() async {
        let requests = await center.pendingNotificationRequests()
        print("📋 Pending Notifications (\(requests.count)):")
        if requests.isEmpty {
            print("   No pending notifications")
        } else {
            for request in requests {
                print("   - ID: \(request.identifier)")
                print("     Title: \(request.content.title)")
                print("     Body: \(request.content.body)")
                if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                    print("     Trigger: \(trigger.timeInterval) seconds from now")
                } else if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    print("     Trigger: Calendar trigger")
                }
            }
        }
    }
    #endif
    
    // MARK: - Helper Methods
    
    private func calculateNotificationDate(for task: Task, deadline: Date) -> Date {
        let calendar = Calendar.current
        
        switch task.taskType {
        case .daily:
            // 1 hour before deadline
            return calendar.date(byAdding: .hour, value: -1, to: deadline) ?? deadline
            
        case .weekly:
            // 1 day before deadline
            return calendar.date(byAdding: .day, value: -1, to: deadline) ?? deadline
            
        case .monthly:
            // 3 days before deadline
            return calendar.date(byAdding: .day, value: -3, to: deadline) ?? deadline
        }
    }
}

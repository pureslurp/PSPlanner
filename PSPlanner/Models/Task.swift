import Foundation
import SwiftData

enum TaskType: String, Codable, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    
    var displayName: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        }
    }
    
    var iconName: String {
        switch self {
        case .daily: return "sun.max"
        case .weekly: return "calendar"
        case .monthly: return "calendar.badge.clock"
        }
    }
}

@Model
final class Task: Identifiable {
    var id: UUID
    var title: String
    var taskType: TaskType
    var category: Category?
    var deadline: Date?
    var notes: String?
    var isCompleted: Bool
    var completedAt: Date?
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        taskType: TaskType = .weekly,
        category: Category? = nil,
        deadline: Date? = nil,
        notes: String? = nil,
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.taskType = taskType
        self.category = category
        self.deadline = deadline
        self.notes = notes
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.createdAt = createdAt
    }
    
    func toggleCompletion() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
    }
}



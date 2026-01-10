import SwiftUI
import SwiftData

struct TaskRow: View {
    @Bindable var task: Task
    var onEdit: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    task.toggleCompletion()
                    triggerHaptic()
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            
            // Task content - tappable to edit (expands to fill available space)
            Button {
                onEdit?()
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(task.title)
                            .font(.body)
                            .foregroundStyle(task.isCompleted ? .secondary : .primary)
                            .strikethrough(task.isCompleted, color: .secondary)
                        
                        HStack(spacing: 8) {
                            // Category badge
                            if let category = task.category {
                                CategoryBadge(category: category)
                            }
                            
                            // Deadline
                            if let deadline = task.deadline {
                                DeadlineBadge(deadline: deadline, isCompleted: task.isCompleted)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Task type indicator
                    Image(systemName: task.taskType.iconName)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - Deadline Badge
struct DeadlineBadge: View {
    let deadline: Date
    let isCompleted: Bool
    
    // Show red if due today or overdue (and not completed)
    private var isDueOrOverdue: Bool {
        guard !isCompleted else { return false }
        return deadline.isDueToday || deadline.isOverdue
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isDueOrOverdue ? "exclamationmark.circle.fill" : "clock")
                .font(.caption2)
            
            Text(deadline.deadlineString)
                .font(.caption)
        }
        .foregroundStyle(isDueOrOverdue ? .red : .secondary)
    }
}

#Preview {
    List {
        TaskRow(task: Task(title: "Buy groceries", taskType: .weekly))
        TaskRow(task: Task(title: "Complete project", taskType: .daily, deadline: Date()))
        TaskRow(task: Task(title: "Already done", isCompleted: true))
    }
    .modelContainer(for: [Task.self, Category.self], inMemory: true)
}



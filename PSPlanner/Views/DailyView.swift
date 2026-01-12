import SwiftUI
import SwiftData

struct DailyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Task.createdAt, order: .reverse) private var allTasks: [Task]
    
    @State private var currentDate = Date()
    @State private var showingCategories = false
    @State private var showingSettings = false
    @State private var taskToEdit: Task?
    
    private var dailyTasks: [Task] {
        allTasks.filter { task in
            // Daily tasks
            if task.taskType == .daily {
                // Only show tasks created on or before the current date (no future tasks, no past viewing of future tasks)
                guard task.createdAt.startOfDay <= currentDate.startOfDay else {
                    return false
                }
                
                // Show if incomplete (carry forward) OR completed on this date
                if !task.isCompleted {
                    return true
                }
                if let completedAt = task.completedAt, completedAt.isSameDay(as: currentDate) {
                    return true
                }
                return false
            }
            
            // Deadline promotion: weekly/monthly tasks with deadline today
            if task.taskType == .weekly || task.taskType == .monthly {
                if let deadline = task.deadline, deadline.isSameDay(as: currentDate) {
                    return true
                }
                return false
            }
            
            return false
        }
    }
    
    private var incompleteTasks: [Task] {
        dailyTasks.filter { !$0.isCompleted }
    }
    
    private var completedTasks: [Task] {
        dailyTasks.filter { $0.isCompleted }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                WeekSelector(
                    currentDate: $currentDate,
                    mode: .daily
                )
                .padding()
                .background(Color(.systemBackground))
                
                if dailyTasks.isEmpty {
                    EmptyTasksView(
                        icon: "sun.max",
                        message: "No tasks for today",
                        submessage: "Tap + to add your first task"
                    )
                } else {
                    List {
                        if !incompleteTasks.isEmpty {
                            Section {
                                ForEach(incompleteTasks) { task in
                                    TaskRow(task: task) {
                                        taskToEdit = task
                                    }
                                }
                                .onDelete(perform: deleteIncompleteTasks)
                            }
                        }
                        
                        if !completedTasks.isEmpty {
                            Section("Completed") {
                                ForEach(completedTasks) { task in
                                    TaskRow(task: task) {
                                        taskToEdit = task
                                    }
                                }
                                .onDelete(perform: deleteCompletedTasks)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showingCategories = true
                        } label: {
                            Label("Manage Categories", systemImage: "folder")
                        }
                        
                        Button {
                            showingSettings = true
                        } label: {
                            Label("Settings", systemImage: "gearshape")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingCategories) {
                CategoriesView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(item: $taskToEdit) { task in
                AddTaskView(defaultTaskType: task.taskType, taskToEdit: task)
            }
        }
    }
    
    private func deleteIncompleteTasks(at offsets: IndexSet) {
        var deletedTasks: [Task] = []
        for index in offsets {
            let task = incompleteTasks[index]
            deletedTasks.append(task)
            modelContext.delete(task)
        }
        
        // Cancel notifications and reschedule recurring notifications
        _Concurrency.Task {
            for task in deletedTasks {
                if task.deadline != nil {
                    await NotificationManager.shared.cancelNotification(for: task)
                }
            }
            await rescheduleRecurringNotifications()
        }
    }
    
    private func deleteCompletedTasks(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(completedTasks[index])
        }
    }
    
    private func rescheduleRecurringNotifications() async {
        let descriptor = FetchDescriptor<Task>(
            predicate: #Predicate<Task> { !$0.isCompleted },
            sortBy: [SortDescriptor(\.createdAt)]
        )
        
        do {
            let allTasks = try modelContext.fetch(descriptor)
            await NotificationManager.shared.rescheduleRecurringNotifications(incompleteTasks: allTasks)
        } catch {
            print("Failed to fetch tasks for recurring notifications: \(error)")
        }
    }
}

#Preview {
    DailyView()
        .modelContainer(for: [Task.self, Category.self], inMemory: true)
}



import SwiftUI
import SwiftData

struct MonthlyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Task.createdAt, order: .reverse) private var allTasks: [Task]
    
    @State private var currentMonth = Date()
    @State private var showingCategories = false
    @State private var showingSettings = false
    @State private var showingEditTask = false
    @State private var taskToEdit: Task?
    
    private var monthlyTasks: [Task] {
        allTasks.filter { task in
            // Monthly tasks only
            guard task.taskType == .monthly else { return false }
            
            // Only show tasks created in or before the current month (carry forward, not backward)
            guard task.createdAt.startOfMonth <= currentMonth.startOfMonth else {
                return false
            }
            
            // Show if incomplete (carry forward) OR completed this month
            if !task.isCompleted {
                return true
            }
            if let completedAt = task.completedAt, completedAt.isInMonth(of: currentMonth) {
                return true
            }
            
            return false
        }
    }
    
    private var incompleteTasks: [Task] {
        monthlyTasks.filter { !$0.isCompleted }
    }
    
    private var completedTasks: [Task] {
        monthlyTasks.filter { $0.isCompleted }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                WeekSelector(
                    currentDate: $currentMonth,
                    mode: .monthly
                )
                .padding()
                .background(Color(.systemBackground))
                
                if monthlyTasks.isEmpty {
                    EmptyTasksView(
                        icon: "calendar.badge.clock",
                        message: "No monthly tasks",
                        submessage: "Tap + to add your first task"
                    )
                } else {
                    List {
                        if !incompleteTasks.isEmpty {
                            Section {
                                ForEach(incompleteTasks) { task in
                                    TaskRow(task: task) {
                                        taskToEdit = task
                                        showingEditTask = true
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
                                        showingEditTask = true
                                    }
                                }
                                .onDelete(perform: deleteCompletedTasks)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("This Month")
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
            .sheet(isPresented: $showingEditTask) {
                Group {
                    if let task = taskToEdit {
                        AddTaskView(defaultTaskType: task.taskType, taskToEdit: task)
                    } else {
                        EmptyView()
                    }
                }
                .onDisappear {
                    taskToEdit = nil
                }
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
    MonthlyView()
        .modelContainer(for: [Task.self, Category.self], inMemory: true)
}



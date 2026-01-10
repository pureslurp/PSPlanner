import SwiftUI
import SwiftData

struct WeeklyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Task.createdAt, order: .reverse) private var allTasks: [Task]
    
    @State private var currentWeek = Date()
    @State private var showingCategories = false
    @State private var showingEditTask = false
    @State private var taskToEdit: Task?
    
    private var weeklyTasks: [Task] {
        allTasks.filter { task in
            // Weekly tasks
            if task.taskType == .weekly {
                // Only show tasks created in or before the current week (carry forward, not backward)
                guard task.createdAt.startOfWeek <= currentWeek.startOfWeek else {
                    return false
                }
                
                // Show if incomplete (carry forward) OR completed this week
                if !task.isCompleted {
                    return true
                }
                if let completedAt = task.completedAt, completedAt.isInWeek(of: currentWeek) {
                    return true
                }
                return false
            }
            
            // Deadline promotion: monthly tasks with deadline this week
            if task.taskType == .monthly, let deadline = task.deadline, deadline.isInWeek(of: currentWeek) {
                return true
            }
            
            return false
        }
    }
    
    private var incompleteTasks: [Task] {
        weeklyTasks.filter { !$0.isCompleted }
    }
    
    private var completedTasks: [Task] {
        weeklyTasks.filter { $0.isCompleted }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                WeekSelector(
                    currentDate: $currentWeek,
                    mode: .weekly
                )
                .padding()
                .background(Color(.systemBackground))
                
                if weeklyTasks.isEmpty {
                    EmptyTasksView(
                        icon: "calendar",
                        message: "No tasks this week",
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
            .navigationTitle("This Week")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showingCategories = true
                        } label: {
                            Label("Manage Categories", systemImage: "folder")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingCategories) {
                CategoriesView()
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
        for index in offsets {
            modelContext.delete(incompleteTasks[index])
        }
    }
    
    private func deleteCompletedTasks(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(completedTasks[index])
        }
    }
}

#Preview {
    WeeklyView()
        .modelContainer(for: [Task.self, Category.self], inMemory: true)
}



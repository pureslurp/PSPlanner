import SwiftUI
import SwiftData

struct DailyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Task.createdAt, order: .reverse) private var allTasks: [Task]
    
    @State private var currentDate = Date()
    @State private var showingCategories = false
    
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
                                    TaskRow(task: task)
                                }
                                .onDelete(perform: deleteIncompleteTasks)
                            }
                        }
                        
                        if !completedTasks.isEmpty {
                            Section("Completed") {
                                ForEach(completedTasks) { task in
                                    TaskRow(task: task)
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
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingCategories) {
                CategoriesView()
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
    DailyView()
        .modelContainer(for: [Task.self, Category.self], inMemory: true)
}



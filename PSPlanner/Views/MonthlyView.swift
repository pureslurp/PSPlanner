import SwiftUI
import SwiftData

struct MonthlyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Task.createdAt, order: .reverse) private var allTasks: [Task]
    
    @State private var currentMonth = Date()
    @State private var showingCategories = false
    
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
            .navigationTitle("This Month")
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
    MonthlyView()
        .modelContainer(for: [Task.self, Category.self], inMemory: true)
}



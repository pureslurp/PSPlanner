import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 1 // Default to Weekly (middle tab)
    @State private var showingAddTask = false
    @State private var showingCategories = false
    @State private var taskTypeForNewTask: TaskType = .weekly
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                DailyView()
                    .tabItem {
                        Label("Daily", systemImage: "sun.max")
                    }
                    .tag(0)
                
                WeeklyView()
                    .tabItem {
                        Label("Weekly", systemImage: "calendar")
                    }
                    .tag(1)
                
                MonthlyView()
                    .tabItem {
                        Label("Monthly", systemImage: "calendar.badge.clock")
                    }
                    .tag(2)
            }
            .tint(.orange)
            .onChange(of: selectedTab) { _, newValue in
                // Update task type when tab changes
                taskTypeForNewTask = taskTypeForTab(newValue)
            }
            .onAppear {
                // Set initial task type
                taskTypeForNewTask = taskTypeForTab(selectedTab)
            }
            
            // Floating Action Button
            Button {
                // Capture current tab's task type at button press time
                taskTypeForNewTask = taskTypeForTab(selectedTab)
                showingAddTask = true
            } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.orange)
                    .clipShape(Circle())
                    .shadow(color: .orange.opacity(0.3), radius: 8, y: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 80)
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(defaultTaskType: taskTypeForNewTask)
        }
        .sheet(isPresented: $showingCategories) {
            CategoriesView()
        }
    }
    
    private func taskTypeForTab(_ tab: Int) -> TaskType {
        switch tab {
        case 0: return .daily
        case 2: return .monthly
        default: return .weekly
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Task.self, Category.self], inMemory: true)
}



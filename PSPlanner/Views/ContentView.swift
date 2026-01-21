import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("defaultTabIndex") private var defaultTabIndex = 1 // Default to Weekly (1)
    @State private var selectedTab = 1
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
            .onAppear {
                // Set initial tab from user preference
                selectedTab = defaultTabIndex
                taskTypeForNewTask = taskTypeForTab(selectedTab)
            }
            .onChange(of: selectedTab) { _, newValue in
                // Update task type when tab changes
                taskTypeForNewTask = taskTypeForTab(newValue)
            }
            .onChange(of: defaultTabIndex) { _, newValue in
                // If user changes default view in settings while app is open, switch to it
                selectedTab = newValue
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



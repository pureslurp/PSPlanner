import SwiftUI
import SwiftData

struct AddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Category.name) private var categories: [Category]
    
    let defaultTaskType: TaskType
    let taskToEdit: Task?
    
    @State private var title = ""
    @State private var selectedTaskType: TaskType
    @State private var selectedCategory: Category?
    @State private var hasDeadline = false
    @State private var deadline = Date()
    @State private var notes = ""
    @State private var showingNewCategory = false
    
    init(defaultTaskType: TaskType = .weekly, taskToEdit: Task? = nil) {
        self.defaultTaskType = defaultTaskType
        self.taskToEdit = taskToEdit
        
        if let task = taskToEdit {
            _selectedTaskType = State(initialValue: task.taskType)
            _title = State(initialValue: task.title)
            _selectedCategory = State(initialValue: task.category)
            _hasDeadline = State(initialValue: task.deadline != nil)
            _notes = State(initialValue: task.notes ?? "")
            
            // For daily tasks, if editing, use the time from the deadline
            // For other tasks, use the deadline date as-is
            if let deadline = task.deadline {
                _deadline = State(initialValue: deadline)
            } else {
                _deadline = State(initialValue: Date())
            }
        } else {
            _selectedTaskType = State(initialValue: defaultTaskType)
        }
    }
    
    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Form Sections
    
    private var titleSection: some View {
        Section {
            TextField("What do you need to do?", text: $title)
                .font(.body)
        }
    }
    
    private var taskTypeSection: some View {
        Section("Task Type") {
            Picker("Type", selection: $selectedTaskType) {
                ForEach(TaskType.allCases, id: \.self) { type in
                    Label(type.displayName, systemImage: type.iconName)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var categorySection: some View {
        Section("Category (Optional)") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Existing categories
                    ForEach(categories) { category in
                        SelectableCategoryBadge(
                            category: category,
                            isSelected: selectedCategory?.id == category.id,
                            action: {
                                // Toggle selection - tap again to deselect
                                if selectedCategory?.id == category.id {
                                    selectedCategory = nil
                                } else {
                                    selectedCategory = category
                                }
                            }
                        )
                    }
                    
                    // Add new category
                    Button {
                        showingNewCategory = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("New")
                        }
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.orange.opacity(0.15))
                        .foregroundStyle(.orange)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    private var deadlineSection: some View {
        Section {
            Toggle("Set Deadline", isOn: $hasDeadline.animation())
            
            if hasDeadline {
                if selectedTaskType == .daily {
                    // For daily tasks, show time picker (date is implied as today)
                    DatePicker(
                        "Due Time",
                        selection: $deadline,
                        displayedComponents: .hourAndMinute
                    )
                    .tint(.orange)
                } else {
                    // For weekly/monthly tasks, show date picker
                    DatePicker(
                        "Due Date",
                        selection: $deadline,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .tint(.orange)
                }
            }
        }
    }
    
    private var notesSection: some View {
        Section {
            notesEditor
        } header: {
            Text("Notes (Optional)")
        }
    }
    
    private var notesEditor: some View {
        ZStack(alignment: .topLeading) {
            if notes.isEmpty {
                Text("Add extra details, a list, or any additional information...")
                    .foregroundStyle(.secondary)
                    .font(.body)
                    .padding(.top, 8)
                    .padding(.leading, 4)
                    .allowsHitTesting(false)
            }
            TextEditor(text: $notes)
                .font(.body)
                .scrollContentBackground(.hidden)
        }
        .frame(minHeight: 100)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                titleSection
                taskTypeSection
                categorySection
                deadlineSection
                notesSection
            }
            .navigationTitle(taskToEdit == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTask()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        hideKeyboard()
                    }
                }
            }
            .sheet(isPresented: $showingNewCategory) {
                NewCategorySheet { newCategory in
                    selectedCategory = newCategory
                }
            }
            .onChange(of: selectedTaskType) { oldType, newType in
                // When switching to daily task type, if deadline exists, extract time and set to today
                if hasDeadline && newType == .daily {
                    let calendar = Calendar.current
                    let timeComponents = calendar.dateComponents([.hour, .minute], from: deadline)
                    deadline = calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                            minute: timeComponents.minute ?? 0,
                                            second: 0,
                                            of: Date()) ?? Date()
                }
            }
        }
    }
    
    private func saveTask() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        // For daily tasks with deadline, combine today's date with selected time
        var finalDeadline: Date? = nil
        if hasDeadline {
            if selectedTaskType == .daily {
                // Combine today's date with the selected time
                let calendar = Calendar.current
                let today = Date()
                let timeComponents = calendar.dateComponents([.hour, .minute], from: deadline)
                finalDeadline = calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                              minute: timeComponents.minute ?? 0,
                                              second: 0,
                                              of: today)
            } else {
                // For weekly/monthly, use the date as-is
                finalDeadline = deadline
            }
        }
        
        let savedTask: Task
        if let task = taskToEdit {
            // Cancel old notification if task had a deadline
            if task.deadline != nil {
                _Concurrency.Task {
                    await NotificationManager.shared.cancelNotification(for: task)
                }
            }
            
            // Update existing task
            task.title = trimmedTitle
            task.taskType = selectedTaskType
            task.category = selectedCategory
            task.deadline = finalDeadline
            task.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines)
            savedTask = task
        } else {
            // Create new task
            let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            let task = Task(
                title: trimmedTitle,
                taskType: selectedTaskType,
                category: selectedCategory,
                deadline: finalDeadline,
                notes: trimmedNotes.isEmpty ? nil : trimmedNotes
            )
            modelContext.insert(task)
            savedTask = task
        }
        
        // Save context first
        do {
            try modelContext.save()
        } catch {
            print("Failed to save task: \(error)")
        }
        
        // Schedule notifications
        _Concurrency.Task {
            // Schedule notification for task with deadline
            if savedTask.deadline != nil {
                await NotificationManager.shared.scheduleNotification(for: savedTask)
            }
            
            // Reschedule recurring notifications for tasks without deadlines
            await rescheduleRecurringNotifications()
        }
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        dismiss()
    }
    
    private func rescheduleRecurringNotifications() async {
        // Fetch all incomplete tasks
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

// MARK: - New Category Sheet
struct NewCategorySheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var selectedColor = Color.categoryColors[0]
    
    var onSave: ((Category) -> Void)?
    
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Category Name", text: $name)
                }
                
                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                        ForEach(Color.categoryColors, id: \.self) { color in
                            ColorPickerBadge(
                                color: color,
                                isSelected: selectedColor == color,
                                action: { selectedColor = color }
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveCategory()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func saveCategory() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let category = Category(name: trimmedName, colorHex: selectedColor.toHex())
        modelContext.insert(category)
        
        onSave?(category)
        dismiss()
    }
}

#Preview {
    AddTaskView()
        .modelContainer(for: [Task.self, Category.self], inMemory: true)
}



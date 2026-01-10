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
    @State private var showingNewCategory = false
    
    init(defaultTaskType: TaskType = .weekly, taskToEdit: Task? = nil) {
        self.defaultTaskType = defaultTaskType
        self.taskToEdit = taskToEdit
        
        if let task = taskToEdit {
            _selectedTaskType = State(initialValue: task.taskType)
            _title = State(initialValue: task.title)
            _selectedCategory = State(initialValue: task.category)
            _hasDeadline = State(initialValue: task.deadline != nil)
            
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
    
    var body: some View {
        NavigationStack {
            Form {
                // Title Section
                Section {
                    TextField("What do you need to do?", text: $title)
                        .font(.body)
                }
                
                // Task Type Section
                Section("Task Type") {
                    Picker("Type", selection: $selectedTaskType) {
                        ForEach(TaskType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.iconName)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Category Section (optional - no selection means no category)
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
                
                // Deadline Section
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
        
        if let task = taskToEdit {
            // Update existing task
            task.title = trimmedTitle
            task.taskType = selectedTaskType
            task.category = selectedCategory
            task.deadline = finalDeadline
        } else {
            // Create new task
            let task = Task(
                title: trimmedTitle,
                taskType: selectedTaskType,
                category: selectedCategory,
                deadline: finalDeadline
            )
            modelContext.insert(task)
        }
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        dismiss()
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



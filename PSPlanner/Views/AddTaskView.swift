import SwiftUI
import SwiftData

struct AddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Category.name) private var categories: [Category]
    
    let defaultTaskType: TaskType
    
    @State private var title = ""
    @State private var selectedTaskType: TaskType
    @State private var selectedCategory: Category?
    @State private var hasDeadline = false
    @State private var deadline = Date()
    @State private var showingNewCategory = false
    
    init(defaultTaskType: TaskType = .weekly) {
        self.defaultTaskType = defaultTaskType
        _selectedTaskType = State(initialValue: defaultTaskType)
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
            .navigationTitle("New Task")
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
        }
    }
    
    private func saveTask() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        let task = Task(
            title: trimmedTitle,
            taskType: selectedTaskType,
            category: selectedCategory,
            deadline: hasDeadline ? deadline : nil
        )
        
        modelContext.insert(task)
        
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



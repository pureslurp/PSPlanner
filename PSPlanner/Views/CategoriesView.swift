import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Category.name) private var categories: [Category]
    
    @State private var showingNewCategory = false
    @State private var editingCategory: Category?
    
    var body: some View {
        NavigationStack {
            Group {
                if categories.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(systemName: "folder")
                            .font(.system(size: 60))
                            .foregroundStyle(.tertiary)
                        
                        VStack(spacing: 6) {
                            Text("No Categories")
                                .font(.title3.weight(.medium))
                                .foregroundStyle(.secondary)
                            
                            Text("Add categories to organize your tasks")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                        }
                        
                        Button {
                            showingNewCategory = true
                        } label: {
                            Label("Add Category", systemImage: "plus")
                                .font(.headline)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Color.orange)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    List {
                        ForEach(categories) { category in
                            CategoryRow(category: category) {
                                editingCategory = category
                            }
                        }
                        .onDelete(perform: deleteCategories)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewCategory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewCategory) {
                NewCategorySheet()
            }
            .sheet(item: $editingCategory) { category in
                EditCategorySheet(category: category)
            }
        }
    }
    
    private func deleteCategories(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(categories[index])
        }
    }
}

// MARK: - Category Row
struct CategoryRow: View {
    let category: Category
    let onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(category.color)
                .frame(width: 12, height: 12)
            
            Text(category.name)
                .font(.body)
            
            Spacer()
            
            if let tasks = category.tasks, !tasks.isEmpty {
                Text("\(tasks.count) task\(tasks.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit()
        }
    }
}

// MARK: - Edit Category Sheet
struct EditCategorySheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var category: Category
    @State private var name: String
    @State private var selectedColor: Color
    
    init(category: Category) {
        self.category = category
        _name = State(initialValue: category.name)
        _selectedColor = State(initialValue: category.color)
    }
    
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
                
                if let tasks = category.tasks, !tasks.isEmpty {
                    Section {
                        Text("This category has \(tasks.count) task\(tasks.count == 1 ? "" : "s")")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func saveChanges() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        category.name = trimmedName
        category.colorHex = selectedColor.toHex()
        
        dismiss()
    }
}

#Preview {
    CategoriesView()
        .modelContainer(for: [Task.self, Category.self], inMemory: true)
}



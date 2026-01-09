import SwiftUI

struct CategoryBadge: View {
    let category: Category
    
    var body: some View {
        Text(category.name)
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(category.color.opacity(0.2))
            .foregroundStyle(category.color)
            .clipShape(Capsule())
    }
}

// MARK: - Selectable Category Badge
struct SelectableCategoryBadge: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.name)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? category.color : category.color.opacity(0.15))
                .foregroundStyle(isSelected ? .white : category.color)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Color Picker Badge
struct ColorPickerBadge: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 32, height: 32)
                .overlay {
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }
                .shadow(color: color.opacity(0.3), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 20) {
        CategoryBadge(category: Category(name: "Home Improvement", colorHex: "#E07A5F"))
        
        HStack {
            SelectableCategoryBadge(
                category: Category(name: "Work", colorHex: "#81B29A"),
                isSelected: false,
                action: {}
            )
            SelectableCategoryBadge(
                category: Category(name: "Personal", colorHex: "#F2CC8F"),
                isSelected: true,
                action: {}
            )
        }
        
        HStack {
            ForEach(Color.categoryColors, id: \.self) { color in
                ColorPickerBadge(color: color, isSelected: color == Color.categoryColors[0], action: {})
            }
        }
    }
    .padding()
}



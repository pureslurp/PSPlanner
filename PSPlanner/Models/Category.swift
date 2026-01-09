import Foundation
import SwiftData
import SwiftUI

@Model
final class Category {
    var id: UUID
    var name: String
    var colorHex: String
    
    @Relationship(deleteRule: .nullify, inverse: \Task.category)
    var tasks: [Task]?
    
    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String = "#E07A5F"
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.tasks = []
    }
    
    var color: Color {
        Color(hex: colorHex) ?? .orange
    }
}

// MARK: - Default Categories
extension Category {
    static let defaultCategories: [(name: String, color: String)] = [
        ("Home Improvement", "#E07A5F"),
        ("Errands", "#3D405B"),
        ("Work", "#81B29A"),
        ("Personal", "#F2CC8F"),
        ("Health", "#E94560"),
    ]
}

// MARK: - Color Extension
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
    
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else { return "#000000" }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

// MARK: - Predefined Colors
extension Color {
    static let categoryColors: [Color] = [
        Color(hex: "#E07A5F")!,  // Terracotta
        Color(hex: "#3D405B")!,  // Dark slate
        Color(hex: "#81B29A")!,  // Sage green
        Color(hex: "#F2CC8F")!,  // Sand
        Color(hex: "#E94560")!,  // Coral red
        Color(hex: "#4ECDC4")!,  // Teal
        Color(hex: "#9B5DE5")!,  // Purple
        Color(hex: "#00BBF9")!,  // Sky blue
        Color(hex: "#F15BB5")!,  // Pink
        Color(hex: "#FEE440")!,  // Yellow
    ]
}


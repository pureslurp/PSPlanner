import Foundation

// MARK: - Date Extensions
extension Date {
    /// Get the start of the week (Monday)
    var startOfWeek: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        components.weekday = 2 // Monday
        return calendar.date(from: components) ?? self
    }
    
    /// Get the end of the week (Sunday)
    var endOfWeek: Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? self
    }
    
    /// Get the start of the month
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    /// Get the end of the month
    var endOfMonth: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = 1
        components.day = -1
        return calendar.date(byAdding: components, to: startOfMonth) ?? self
    }
    
    /// Get the start of the day
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// Check if the date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Check if the date is in the current week
    var isInCurrentWeek: Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    /// Check if the date is in the current month
    var isInCurrentMonth: Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: Date(), toGranularity: .month)
    }
    
    /// Check if the date is in a specific week
    func isInWeek(of date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: date, toGranularity: .weekOfYear)
    }
    
    /// Check if the date is in a specific month
    func isInMonth(of date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: date, toGranularity: .month)
    }
    
    /// Check if the date is on the same day
    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    /// Check if the date is overdue (before today's start)
    var isOverdue: Bool {
        self < Date().startOfDay
    }
    
    /// Check if the date is due today
    var isDueToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Get days until this date
    var daysUntil: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date().startOfDay, to: self.startOfDay)
        return components.day ?? 0
    }
    
    /// Format date for display
    func formatted(style: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.string(from: self)
    }
    
    /// Get week range string (e.g., "Jan 6 - Jan 12")
    var weekRangeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }
    
    /// Get month string (e.g., "January 2024")
    var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }
    
    /// Get day string (e.g., "Friday, Jan 10")
    var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: self)
    }
    
    /// Navigate to previous week
    var previousWeek: Date {
        Calendar.current.date(byAdding: .weekOfYear, value: -1, to: self) ?? self
    }
    
    /// Navigate to next week
    var nextWeek: Date {
        Calendar.current.date(byAdding: .weekOfYear, value: 1, to: self) ?? self
    }
    
    /// Navigate to previous month
    var previousMonth: Date {
        Calendar.current.date(byAdding: .month, value: -1, to: self) ?? self
    }
    
    /// Navigate to next month
    var nextMonth: Date {
        Calendar.current.date(byAdding: .month, value: 1, to: self) ?? self
    }
    
    /// Navigate to previous day
    var previousDay: Date {
        Calendar.current.date(byAdding: .day, value: -1, to: self) ?? self
    }
    
    /// Navigate to next day
    var nextDay: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: self) ?? self
    }
}

// MARK: - Deadline Formatting
extension Date {
    /// Format deadline for display with relative indicator
    var deadlineString: String {
        let days = daysUntil
        let calendar = Calendar.current
        
        // If deadline is today, show time (for daily tasks)
        if calendar.isDateInToday(self) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return "Due at \(formatter.string(from: self))"
        }
        
        if days < 0 {
            let absDays = abs(days)
            return "\(absDays) day\(absDays == 1 ? "" : "s") overdue"
        } else if days == 0 {
            return "Due today"
        } else if days == 1 {
            return "Due tomorrow"
        } else if days <= 7 {
            return "Due in \(days) days"
        } else {
            return formatted(style: .medium)
        }
    }
}



import SwiftUI

enum SelectorMode {
    case daily
    case weekly
    case monthly
}

struct WeekSelector: View {
    @Binding var currentDate: Date
    let mode: SelectorMode
    
    var body: some View {
        HStack {
            // Previous button
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    navigatePrevious()
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.orange)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            // Current date display
            VStack(spacing: 2) {
                Text(displayText)
                    .font(.headline)
                
                if !isCurrent {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            currentDate = Date()
                        }
                    } label: {
                        Text("Go to \(currentLabel)")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
            .contentTransition(.numericText())
            
            Spacer()
            
            // Next button
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    navigateNext()
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.orange)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 8)
    }
    
    private var displayText: String {
        switch mode {
        case .daily:
            return currentDate.dayString
        case .weekly:
            return currentDate.weekRangeString
        case .monthly:
            return currentDate.monthString
        }
    }
    
    private var currentLabel: String {
        switch mode {
        case .daily: return "today"
        case .weekly: return "this week"
        case .monthly: return "this month"
        }
    }
    
    private var isCurrent: Bool {
        switch mode {
        case .daily:
            return currentDate.isToday
        case .weekly:
            return currentDate.isInCurrentWeek
        case .monthly:
            return currentDate.isInCurrentMonth
        }
    }
    
    private func navigatePrevious() {
        switch mode {
        case .daily:
            currentDate = currentDate.previousDay
        case .weekly:
            currentDate = currentDate.previousWeek
        case .monthly:
            currentDate = currentDate.previousMonth
        }
    }
    
    private func navigateNext() {
        switch mode {
        case .daily:
            currentDate = currentDate.nextDay
        case .weekly:
            currentDate = currentDate.nextWeek
        case .monthly:
            currentDate = currentDate.nextMonth
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        WeekSelector(currentDate: .constant(Date()), mode: .daily)
        WeekSelector(currentDate: .constant(Date()), mode: .weekly)
        WeekSelector(currentDate: .constant(Date()), mode: .monthly)
    }
    .padding()
}



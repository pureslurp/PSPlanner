import SwiftUI

struct EmptyTasksView: View {
    let icon: String
    let message: String
    let submessage: String
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(.tertiary)
            
            VStack(spacing: 6) {
                Text(message)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.secondary)
                
                Text(submessage)
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyTasksView(
        icon: "calendar",
        message: "No tasks this week",
        submessage: "Tap + to add your first task"
    )
}



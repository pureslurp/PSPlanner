# Gotta - Project Plan

## Overview

Gotta is a simple iOS app for personal task/to-do list management. The app organizes tasks by time period (daily, weekly, monthly) with the weekly view as the default. Each task can have an optional category and deadline. The name "Gotta" comes from the slang phrase "got to do it!" - capturing that feeling of "I gotta do this, I gotta do that..."

## User Requirements

1. **Task Organization**: Break up tasks into daily, weekly, and monthly categories
2. **Default View**: Weekly tasks starting on Monday
3. **Task Properties**: 
   - Title (required)
   - Category (optional) - e.g., "Home Improvement", "Errands"
   - Deadline (optional)
4. **Home Screen**: List of week's tasks with checkboxes and add button
5. **Simple & Clean**: Keep the app minimal and easy to use

## Tech Stack

- **SwiftUI** - Native iOS UI framework
- **SwiftData** - Apple's modern persistence framework (replaces Core Data)
- **iCloud/CloudKit** - Automatic sync across devices (no backend needed)
- **iOS 17+** - Minimum deployment target
- **Swift 5.9+** - Language version

### Why SwiftUI over React Native?

The user initially tried React Native with Expo but found:
- Testing was difficult (Expo Go compatibility issues, SDK version mismatches)
- Build tooling was complex
- Wanted seamless Cursor → Xcode → Simulator workflow

SwiftUI provides:
- Edit code in Cursor, instant preview in Xcode Canvas
- Native performance
- No JavaScript bundling or build complexity
- Automatic iCloud sync without managing a backend (Supabase was used before)

## Data Models

### Task
```swift
@Model
class Task {
    var id: UUID
    var title: String
    var taskType: TaskType      // .daily, .weekly, .monthly
    var category: Category?     // Optional relationship
    var deadline: Date?         // Optional due date
    var isCompleted: Bool
    var completedAt: Date?      // When completed
    var createdAt: Date
}

enum TaskType: String, Codable, CaseIterable {
    case daily, weekly, monthly
}
```

### Category
```swift
@Model
class Category {
    var id: UUID
    var name: String
    var colorHex: String        // Hex color code like "#E07A5F"
    var tasks: [Task]?          // Inverse relationship
}
```

## App Structure

```
PSPlanner/
├── PSPlannerApp.swift          # App entry point with SwiftData container
├── Models/
│   ├── Task.swift              # Task model + TaskType enum
│   └── Category.swift          # Category model + Color extensions
├── Views/
│   ├── ContentView.swift       # Main tab view (Daily/Weekly/Monthly tabs)
│   ├── DailyView.swift         # Daily tasks screen
│   ├── WeeklyView.swift        # Weekly tasks screen (default)
│   ├── MonthlyView.swift       # Monthly tasks screen
│   ├── AddTaskView.swift       # Sheet for adding new tasks
│   ├── CategoriesView.swift    # Category management screen
│   └── Components/
│       ├── TaskRow.swift       # Individual task row with checkbox
│       ├── WeekSelector.swift  # Date navigation (prev/next week/month/day)
│       ├── CategoryBadge.swift # Colored category pills
│       └── EmptyTasksView.swift# Empty state placeholder
└── Utilities/
    └── DateHelpers.swift       # Date extension helpers
```

## Features

### Implemented ✅

1. **Tab Navigation**
   - Three tabs: Daily, Weekly (default), Monthly
   - Orange accent color
   - Floating action button (FAB) to add tasks

2. **Task List Views**
   - Tasks grouped by completion status (incomplete first, then completed)
   - Swipe to delete
   - Checkbox toggle with haptic feedback
   - Shows category badge and deadline indicator

3. **Date Navigation**
   - WeekSelector component for navigating between dates
   - "Go to today/this week/this month" button when viewing past/future

4. **Add Task Sheet**
   - Title input
   - Task type picker (segmented control)
   - Category selector with horizontal scroll
   - Optional deadline with graphical date picker
   - Inline "New Category" creation

5. **Category Management**
   - List of all categories with task counts
   - Swipe to delete
   - Tap to edit (name and color)
   - 10 predefined colors to choose from

6. **Visual Design**
   - Clean, minimal aesthetic
   - System colors (auto dark/light mode)
   - SF Symbols for all icons
   - Spring animations for checkbox

7. **Data Persistence**
   - SwiftData for local storage
   - iCloud sync ready via CloudKit (needs capability enabled)

## Default Categories

Pre-defined category options:
- Home Improvement (#E07A5F - Terracotta)
- Errands (#3D405B - Dark slate)
- Work (#81B29A - Sage green)
- Personal (#F2CC8F - Sand)
- Health (#E94560 - Coral red)

## Design Guidelines

- **Color Palette**: Orange primary, system backgrounds
- **Typography**: System fonts (San Francisco)
- **Icons**: SF Symbols throughout
- **Spacing**: Standard iOS spacing
- **Interactions**: Haptic feedback on task completion

## Setup Instructions

1. Create new Xcode project (iOS App, SwiftUI, SwiftData)
2. Delete default ContentView.swift and Item.swift
3. Add all Swift files from this project
4. Enable iCloud capability with CloudKit
5. Build and run

## Development Workflow

1. **Edit in Cursor** - Make code changes
2. **Preview in Xcode** - See instant Canvas previews
3. **Run in Simulator** - Test with ⌘R

## Original Context

This project was migrated from a React Native + Expo + Supabase implementation due to testing difficulties. The original React Native project is in the `PSPlanner/` directory (Expo project). This SwiftUI version is in `PSPlannerSwiftUI/`.

## Future Enhancement Ideas

- Task recurring/repeat options
- Notifications/reminders
- Widget for home screen
- Search/filter tasks
- Task notes/descriptions
- Subtasks
- Drag to reorder
- Archive completed tasks


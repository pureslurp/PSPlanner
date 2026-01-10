# Gotta - SwiftUI

A simple, elegant task planner for iOS built with SwiftUI and SwiftData. Got to do it!

## Features

- **Daily, Weekly, Monthly tasks** - Organize tasks by time period
- **Categories** - Color-coded categories for task organization
- **Deadlines** - Optional due dates with overdue indicators
- **iCloud Sync** - Automatic sync across all your devices
- **Native iOS** - Fast, smooth, and battery efficient

## Requirements

- macOS 14+ (Sonoma) for development
- Xcode 15+
- iOS 17+ deployment target

## Setup Instructions

### Step 1: Create New Xcode Project

1. Open Xcode
2. **File → New → Project**
3. Select **iOS → App**
4. Configure:
   - **Product Name:** `PSPlanner`
   - **Organization Identifier:** `com.yourname` (or your preferred identifier)
   - **Interface:** `SwiftUI`
   - **Storage:** `SwiftData`
   - **Language:** `Swift`
5. Choose a location and click **Create**

### Step 2: Copy Source Files

1. **Delete** the default `ContentView.swift` and `Item.swift` files Xcode created
2. **Drag and drop** all the Swift files from this folder into your Xcode project:
   - `PSPlannerApp.swift`
   - `Models/` folder
   - `Views/` folder  
   - `Utilities/` folder
3. When prompted, select:
   - ✅ Copy items if needed
   - ✅ Create groups
   - Select your PSPlanner target

### Step 3: Enable iCloud

1. Select your project in the navigator
2. Select the **PSPlanner** target
3. Go to **Signing & Capabilities**
4. Click **+ Capability**
5. Add **iCloud**
6. Check **CloudKit** in the iCloud section
7. Xcode will create a default container (or you can customize it)

### Step 4: Add Entitlements (Optional)

If Xcode doesn't auto-create entitlements:
1. Copy `PSPlanner.entitlements` to your project
2. In **Build Settings**, set **Code Signing Entitlements** to the path

### Step 5: Run!

1. Select an iPhone simulator or your device
2. Press **⌘R** to build and run
3. The app should launch with the Weekly view

## Project Structure

```
PSPlanner/
├── PSPlannerApp.swift          # App entry point with SwiftData setup
├── Models/
│   ├── Task.swift              # Task model with TaskType enum
│   └── Category.swift          # Category model with color support
├── Views/
│   ├── ContentView.swift       # Main tab view
│   ├── DailyView.swift         # Daily tasks screen
│   ├── WeeklyView.swift        # Weekly tasks screen (default)
│   ├── MonthlyView.swift       # Monthly tasks screen
│   ├── AddTaskView.swift       # Add/edit task sheet
│   ├── CategoriesView.swift    # Category management
│   └── Components/
│       ├── TaskRow.swift       # Individual task row
│       ├── WeekSelector.swift  # Date navigation
│       ├── CategoryBadge.swift # Category indicators
│       └── EmptyTasksView.swift # Empty state
├── Utilities/
│   └── DateHelpers.swift       # Date extension helpers
└── PSPlanner.entitlements      # iCloud entitlements
```

## Development Workflow

The beauty of SwiftUI is the seamless Cursor → Xcode workflow:

1. **Edit in Cursor** - Make code changes in Cursor
2. **Preview in Xcode** - Changes appear instantly in Xcode's Canvas preview
3. **Run in Simulator** - Press ⌘R to test on simulator

No build waiting, no JS bundling - just native development!

## Customization

### Adding New Categories (Default)

Edit `Models/Category.swift` to change default categories:

```swift
static let defaultCategories: [(name: String, color: String)] = [
    ("Home Improvement", "#E07A5F"),
    ("Errands", "#3D405B"),
    ("Work", "#81B29A"),
    ("Personal", "#F2CC8F"),
    ("Health", "#E94560"),
]
```

### Changing Theme Colors

Edit `Models/Category.swift` to modify available colors:

```swift
static let categoryColors: [Color] = [
    Color(hex: "#E07A5F")!,  // Terracotta
    Color(hex: "#3D405B")!,  // Dark slate
    // Add more...
]
```

### Modifying Tab Order

Edit `Views/ContentView.swift` - change `selectedTab` initial value:
- `0` = Daily first
- `1` = Weekly first (default)
- `2` = Monthly first

## Troubleshooting

### "iCloud container not configured"
1. Make sure you're signed into iCloud on your device/simulator
2. Check Xcode Signing & Capabilities has CloudKit enabled
3. Wait a few minutes for CloudKit container to provision

### Preview not updating
1. Press ⌘⌥P to refresh previews
2. Or clean build folder: ⇧⌘K

### App crashes on launch
1. Clean build: ⇧⌘K
2. Delete derived data: Window → Projects → Delete Derived Data
3. Rebuild: ⌘B

## License

MIT - Do whatever you want with it!



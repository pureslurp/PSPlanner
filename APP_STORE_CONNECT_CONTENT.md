# App Store Connect Distribution Content

## 1. Previews and Screenshots

### Screenshot Suggestions

**iPhone Screenshots (Required for all sizes):**

1. **Main Daily View (Today Tab)**
   - Show the Daily view with a mix of incomplete and completed tasks
   - Include 2-3 incomplete tasks with different categories (color badges visible)
   - Include 1-2 completed tasks in the "Completed" section
   - This demonstrates the core functionality and visual organization

2. **Weekly View**
   - Show the Weekly tab with several tasks across different categories
   - Include the week selector at the top showing the current week
   - Mix of incomplete and completed tasks to show progress tracking

3. **Add Task Screen**
   - Show the AddTaskView with:
     - Task type selector (Daily/Weekly/Monthly) visible
     - Category selection with colorful badges
     - Deadline toggle enabled with date picker visible
   - This showcases the task creation flow

4. **Monthly View**
   - Show the Monthly tab with tasks organized by month
   - Demonstrate the monthly planning aspect

5. **Categories Management**
   - Show the CategoriesView with multiple custom categories
   - Display the color-coded organization system

**Tips for Screenshots:**
- Use realistic task names (e.g., "Review quarterly report", "Grocery shopping", "Call dentist")
- Include a mix of task types to show the tiered system
- Show completed tasks to demonstrate progress tracking
- Use the default categories plus 1-2 custom ones to show flexibility
- Make sure category color badges are clearly visible
- Consider showing a task with a deadline set to demonstrate that feature

---

## 2. Promotional Text

**Option 1 (Concise):**
```
Organize your life with a simple, tiered task system. Focus on what matters today, plan for the week, and track monthly goals—all in one beautiful app.
```

**Option 2 (Feature-focused):**
```
Never miss a deadline again. PSPlanner helps you organize tasks by priority: daily essentials, weekly goals, and monthly milestones. Smart reminders and category organization keep you on track.
```

**Option 3 (Benefit-focused):**
```
Stop feeling overwhelmed by your to-do list. PSPlanner's tiered system helps you prioritize what needs attention today, this week, and this month—so you can focus on what matters most.
```

**Recommended:** Option 1 (concise and clear)

---

## 3. Description

```
PSPlanner is a tiered task management app designed to help you organize and prioritize your life. Instead of one overwhelming list, organize your tasks into three priority levels: Daily (high priority), Weekly (medium priority), and Monthly (low priority).

KEY FEATURES:

📅 Tiered Task Organization
• Daily Tasks: Focus on what needs attention today
• Weekly Tasks: Plan and track goals for the week ahead
• Monthly Tasks: Set and monitor longer-term objectives
• Tasks automatically carry forward until completed, so nothing gets forgotten

🎯 Smart Task Visibility
• Weekly and monthly tasks automatically appear in your daily view when their deadline approaches
• Incomplete tasks stay visible until you complete them
• Completed tasks are organized separately so you can track your progress

🏷️ Category Organization
• Organize tasks with color-coded categories
• Pre-loaded categories: Home Improvement, Errands, Work, Personal, and Health
• Create unlimited custom categories with your own colors
• Quickly identify task types at a glance

⏰ Intelligent Reminders
• Set deadlines on any task for timely reminders
• Automatic reminders: 1 hour before daily deadlines, 1 day before weekly deadlines, 3 days before monthly deadlines
• Recurring reminders for tasks without deadlines (daily at 8pm, weekly on Sundays, monthly on the 23rd)
• Full control over notification preferences in Settings

✨ Beautiful, Intuitive Design
• Clean, modern interface built with SwiftUI
• Smooth animations and haptic feedback
• Easy navigation between daily, weekly, and monthly views
• Quick access floating action button for adding tasks

🎯 Perfect For:
• Professionals managing work and personal tasks
• Students organizing assignments and deadlines
• Anyone looking to improve productivity and reduce overwhelm
• People who want a simple, focused task manager without complexity

PSPlanner helps you break down your responsibilities into manageable chunks, so you can focus on what needs attention now while keeping an eye on the bigger picture. Start organizing your tasks today and take control of your time.
```

---

## 4. Keywords

```
task manager,to-do list,productivity,organizer,daily planner,weekly planner,monthly planner,priority tasks,deadline tracker,reminder app,category organizer,time management,goal tracking,task tracker,productivity app
```

**Alternative (if character limit allows more):**
```
task manager,to-do list,productivity,organizer,daily planner,weekly planner,monthly planner,priority tasks,deadline tracker,reminder app,category organizer,time management,goal tracking,task tracker,productivity app,GTD,getting things done,personal organizer
```

**Note:** Apple allows up to 100 characters for keywords. The first option is approximately 95 characters. Separate keywords with commas.

---

## 5. Support URL

**If you don't have a support URL yet, you have a few options:**

1. **Create a simple GitHub Pages site** with basic support information
2. **Use a free service** like:
   - GitHub Pages (if you have a GitHub repo)
   - Notion public page
   - Google Sites
   - Simple HTML page hosted anywhere

**Suggested Support Page Content:**
- How to use the app
- FAQ section
- How to contact for support
- Privacy policy (if applicable)

**Temporary Solution:** You can use a placeholder URL for now, but Apple requires a valid URL. Consider creating a simple one-page site.

**Example placeholder text for now:**
```
https://yourwebsite.com/support
```
(Replace with your actual URL when available)

---

## 6. Marketing URL

**Similar to Support URL, you have options:**

1. **Create a landing page** showcasing the app
2. **Use the same URL as Support** (many apps do this)
3. **Leave blank** (this field is optional)

**If creating a marketing page, include:**
- App screenshots
- Key features
- Download link to App Store
- Brief description

**Note:** This field is optional. You can leave it blank if you don't have a marketing site yet.

---

## 7. Copyright

**Format:** `YYYY [Your Name or Company Name]`

**Examples:**
- `2025 Sean Raymor` (if using your name)
- `2025 [Your Company Name]` (if you have a company)
- `2025 PSPlanner` (if using app name as copyright holder)

**Note:** Based on the code comments, I see "Sean Raymor" as the creator. You might want to use:
```
2025 Sean Raymor
```

Or if you prefer to use a company name or the app name itself, adjust accordingly.

---

## 8. Notes (App Review Information)

```
This is the first release of PSPlanner, a tiered task management application.

APP FUNCTIONALITY:
- The app organizes tasks into three priority levels: Daily, Weekly, and Monthly
- Users can create, edit, and delete tasks
- Tasks can be assigned to categories with custom colors
- Tasks can have optional deadlines
- Completed tasks are tracked with completion timestamps
- Incomplete tasks automatically carry forward to the next day/week/month

NOTIFICATIONS:
- The app requests notification permissions on first launch (if enabled in settings)
- Notifications are used for:
  * Deadline reminders (1 hour before daily deadlines, 1 day before weekly, 3 days before monthly)
  * Recurring reminders for tasks without deadlines (daily at 8pm, weekly on Sundays at 9am, monthly on the 23rd at 9am)
- Users can enable/disable notifications in Settings
- If notifications are denied, the app continues to function normally without reminders

TESTING INSTRUCTIONS:
1. Launch the app and complete the onboarding flow
2. Create a few tasks of each type (Daily, Weekly, Monthly)
3. Assign tasks to different categories
4. Set deadlines on some tasks
5. Mark some tasks as complete to see the completion tracking
6. Navigate between Daily, Weekly, and Monthly tabs
7. Test notification permissions in Settings (if testing on device)
8. Create and manage custom categories

NO SPECIAL ACCOUNTS OR CREDENTIALS REQUIRED:
- The app uses local storage only (SwiftData)
- No login or account creation needed
- All data is stored locally on the device

PRIVACY:
- The app does not collect any user data
- All task data is stored locally on the device
- No analytics or tracking is implemented
- No third-party services are used

If you have any questions or need additional information, please contact us.
```

---

## Additional Recommendations

### App Icon
Make sure your app icon is:
- 1024x1024 pixels
- PNG format
- No transparency
- Follows Apple's design guidelines

### App Preview Video (Optional but Recommended)
Consider creating a short video (15-30 seconds) showing:
1. The onboarding flow
2. Creating a task
3. Navigating between tabs
4. Completing a task
5. Managing categories

### Subtitle (Optional)
You can add a subtitle to your app listing. Suggested options:
- "Tiered Task Manager"
- "Daily, Weekly, Monthly Planner"
- "Priority-Based Task Organizer"

### What's New (For Future Updates)
When you release updates, you'll need "What's New" text. Keep this in mind for future releases.

---

## Summary Checklist

Before submitting, ensure you have:
- [ ] All required screenshots for your target device sizes
- [ ] App icon (1024x1024)
- [ ] Promotional text filled in
- [ ] Description filled in
- [ ] Keywords (comma-separated, under 100 characters)
- [ ] Support URL (valid, working URL)
- [ ] Marketing URL (optional, can be blank)
- [ ] Copyright information
- [ ] Review notes with testing instructions
- [ ] Age rating completed
- [ ] Privacy information completed (if required)

---

**Good luck with your App Store submission!** 🚀

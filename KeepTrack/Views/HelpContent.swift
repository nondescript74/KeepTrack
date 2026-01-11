//
//  HelpContent.swift
//  KeepTrack
//
//  Created by Zahirudeen Premji on 11/14/25.
//

import Foundation

/// Represents a help topic for a specific view
struct HelpTopic: Identifiable {
    let id = UUID()
    let title: String
    let sections: [HelpSection]
}

/// A section within a help topic
struct HelpSection: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let tips: [String]?
    
    init(title: String, content: String, tips: [String]? = nil) {
        self.title = title
        self.content = content
        self.tips = tips
    }
}

/// Enum to identify different views in the app
enum HelpViewIdentifier {
    case dashboard
    case today
    case yesterday
    case consumptionByDayAndTime
    case addHistory
    case showGoals
    case enterGoal
    case editHistory
    case editGoals
    case addIntakeType
    case license
    case reminderTesting
}

/// Central help content manager
struct HelpContentManager {
    
    static func getHelpTopic(for identifier: HelpViewIdentifier) -> HelpTopic {
        switch identifier {
        case .dashboard:
            return dashboardHelp
        case .today:
            return todayHelp
        case .yesterday:
            return yesterdayHelp
        case .consumptionByDayAndTime:
            return consumptionByDayAndTimeHelp
        case .addHistory:
            return addHistoryHelp
        case .showGoals:
            return showGoalsHelp
        case .enterGoal:
            return enterGoalHelp
        case .editHistory:
            return editHistoryHelp
        case .editGoals:
            return editGoalsHelp
        case .addIntakeType:
            return addIntakeTypeHelp
        case .license:
            return licenseHelp
        case .reminderTesting:
            return reminderTestingHelp
        }
    }
    
    // MARK: - Dashboard Help
    private static let dashboardHelp = HelpTopic(
        title: "Dashboard",
        sections: [
            HelpSection(
                title: "Welcome to KeepTrack",
                content: "KeepTrack helps you monitor your daily intake of medications, supplements, water, or any other items you want to track. The dashboard provides quick access to all features through tabs.",
                tips: [
                    "Use tabs at the top to navigate between different views",
                    "Start by adding intake types in the 'Add New' tab",
                    "Set up goals in the 'Goal' tab to track your progress",
                    "View your history in the 'Today' and 'Yesterday' tabs"
                ]
            ),
            HelpSection(
                title: "Quick Start Guide",
                content: "To get started with KeepTrack:\n\n1. Go to 'Add New' to create intake types (e.g., Water, Vitamin C)\n2. Go to 'Goal' to set daily goals for each item\n3. Use 'Add History' to log when you take something\n4. Check 'Today' to see your current progress",
                tips: nil
            ),
            HelpSection(
                title: "Smart Reminders",
                content: "KeepTrack includes intelligent reminders for all frequency types:\n\n• Daily reminders: Automatically suppressed if you've logged intake today\n• Weekly reminders: Fire only on specified weekdays, suppressed if logged this week\n• Monthly reminders: Fire only on specified days, suppressed if logged this month\n• Confirm button: Quick logging without opening the app\n• Cancel button: Stop specific unwanted reminders\n• Automatic cleanup: Missed daily reminders are cleaned up\n• Works everywhere: Notifications work whether app is open, in background, or closed\n\nFor detailed information about reminders, see 'Testing Reminders' in the Help menu.",
                tips: [
                    "Enable reminders when creating goals",
                    "Choose the right frequency (daily, weekly, or monthly)",
                    "Notifications help build consistent habits",
                    "Tap 'Confirm' on notifications to quickly log intake",
                    "Weekly and monthly reminders only fire on correct days"
                ]
            )
        ]
    )
    
    // MARK: - Today View Help
    private static let todayHelp = HelpTopic(
        title: "Today's History",
        sections: [
            HelpSection(
                title: "Overview",
                content: "This view shows all the items you've tracked today. You can see what you've taken, when you took it, and whether you've met your goals.",
                tips: [
                    "Items are listed in chronological order",
                    "A checkmark indicates a goal was met",
                    "Tap any entry to see more details"
                ]
            ),
            HelpSection(
                title: "Understanding Your Progress",
                content: "Each entry shows the time, amount, and units of what you tracked. If you have a goal set for that item, you'll see whether the goal was met.",
                tips: [
                    "Green indicators show goals that were met",
                    "Review your progress throughout the day",
                    "Use this view to ensure you're on track"
                ]
            )
        ]
    )
    
    // MARK: - Yesterday View Help
    private static let yesterdayHelp = HelpTopic(
        title: "Yesterday's History",
        sections: [
            HelpSection(
                title: "Overview",
                content: "This view displays all items you tracked yesterday. It helps you review your past performance and maintain consistency.",
                tips: [
                    "Compare yesterday's entries with today's",
                    "Identify patterns in your tracking habits",
                    "Learn from missed goals to improve today"
                ]
            ),
            HelpSection(
                title: "Why Review Yesterday?",
                content: "Looking at yesterday's data helps you understand your habits and ensure you're maintaining consistency in your tracking routine.",
                tips: nil
            )
        ]
    )
    
    // MARK: - Consumption By Day and Time Help
    private static let consumptionByDayAndTimeHelp = HelpTopic(
        title: "Consumption By Day & Time",
        sections: [
            HelpSection(
                title: "Overview",
                content: "This view provides a detailed breakdown of your consumption patterns organized by day and time. It helps you visualize when you typically take your tracked items.",
                tips: [
                    "View patterns across multiple days",
                    "Identify optimal times for your routine",
                    "Spot gaps in your tracking schedule"
                ]
            ),
            HelpSection(
                title: "Using This View",
                content: "Browse through different days to see your consumption timeline. This helps you understand your habits and optimize your schedule for better consistency.",
                tips: [
                    "Look for consistent patterns",
                    "Adjust your goals based on actual behavior",
                    "Use insights to improve your routine"
                ]
            )
        ]
    )
    
    // MARK: - Add History Help
    private static let addHistoryHelp = HelpTopic(
        title: "Add History",
        sections: [
            HelpSection(
                title: "Overview",
                content: "Use this view to manually add entries to your tracking history. This is where you log each time you take medication, drink water, or consume any tracked item.",
                tips: [
                    "Select the item type from your saved intake types",
                    "Specify the amount and time",
                    "Mark if this entry meets a goal",
                    "Add notes if needed for future reference"
                ]
            ),
            HelpSection(
                title: "When to Add Entries",
                content: "Add an entry whenever you consume something you're tracking. You can also add entries retroactively if you forgot to log something earlier.",
                tips: [
                    "Log entries as they happen for accuracy",
                    "You can backdate entries if needed",
                    "Be consistent with units (e.g., always use ml or oz)"
                ]
            ),
            HelpSection(
                title: "Goal Met Indicator",
                content: "When adding an entry, you can mark whether it fulfills a goal. This helps track your progress toward daily targets.",
                tips: nil
            )
        ]
    )
    
    // MARK: - Show Goals Help
    private static let showGoalsHelp = HelpTopic(
        title: "Show Goals",
        sections: [
            HelpSection(
                title: "Overview",
                content: "This view displays all your current goals organized by intake type. You can see your target amounts, frequencies, and progress.",
                tips: [
                    "Review goals to stay motivated",
                    "Check progress throughout the day",
                    "See which goals need attention"
                ]
            ),
            HelpSection(
                title: "Understanding Your Goals",
                content: "Goals help you maintain consistency and reach your health targets. Each goal shows what you're aiming for and how close you are to achieving it.",
                tips: [
                    "Goals can be daily, weekly, or custom schedules",
                    "Visual indicators show your progress",
                    "Update goals as your needs change"
                ]
            ),
            HelpSection(
                title: "Goal Notifications & Reminders",
                content: "If you've enabled notifications, KeepTrack can remind you when it's time to take something according to your goals.\n\nReminder Features:\n• Frequency-aware: Daily, weekly, and monthly reminders work correctly\n• Daily reminders: Suppressed if you logged today before scheduled time\n• Weekly reminders: Suppressed if you logged this week on same weekday\n• Monthly reminders: Suppressed if you logged this month on same day\n• Confirm button to quickly log without opening the app\n• Cancel button to stop unwanted reminders\n• Smart cleanup of missed daily reminders",
                tips: [
                    "Enable notifications for important medications",
                    "Set reminder times that match your schedule",
                    "Tap notifications to quickly log entries",
                    "Weekly reminders only fire on the correct weekday",
                    "Monthly reminders only fire on the correct day of month",
                    "See 'Testing Reminders' in Help for detailed information"
                ]
            )
        ]
    )
    
    // MARK: - Enter Goal Help
    private static let enterGoalHelp = HelpTopic(
        title: "Create Goals",
        sections: [
            HelpSection(
                title: "Overview",
                content: "Create goals to track your progress toward daily targets. Goals help you stay consistent with medications, water intake, or any tracked item.",
                tips: [
                    "Select an existing intake type",
                    "Set target amounts and times",
                    "Enable notifications for reminders",
                    "Customize frequency (daily, specific days, etc.)"
                ]
            ),
            HelpSection(
                title: "Setting Up a Goal",
                content: "To create a goal:\n\n1. Choose an intake type from your list\n2. Set the target amount\n3. Choose when you want to achieve it\n4. Optionally enable notifications\n5. Save your goal",
                tips: [
                    "Be realistic with your targets",
                    "Start with fewer goals and add more later",
                    "Adjust goals based on your progress"
                ]
            ),
            HelpSection(
                title: "Goal Schedules",
                content: "You can create goals with different schedules:\n\n• Daily frequencies: Once, twice, three times, or more per day\n• Weekly frequencies: Once, twice, three, or four times per week\n• Monthly frequencies: Once, twice, or three times per month\n\nThe app automatically calculates reminder times based on your chosen frequency.",
                tips: [
                    "Daily goals spread reminders throughout the day (e.g., twice daily = 12 hours apart)",
                    "Weekly goals fire on specific weekdays",
                    "Monthly goals fire on specific days of the month",
                    "Each frequency type has smart suppression when you log intake"
                ]
            ),
            HelpSection(
                title: "Smart Reminders",
                content: "When you enable notifications for a goal, KeepTrack provides intelligent reminders that adapt to your frequency:\n\n• Daily reminders: Won't remind if you logged today at/before scheduled time\n• Weekly reminders: Won't remind if you logged this week on the same weekday\n• Monthly reminders: Won't remind if you logged this month on the same day\n\nPlus:\n• Confirm button to quickly log without opening the app\n• Cancel button to stop specific reminders\n• Automatically cleans up missed daily reminders\n\nFor detailed testing and understanding of reminders, see 'Testing Reminders' in the Help menu.",
                tips: [
                    "Reminders adapt to your behavior and frequency",
                    "No annoying duplicate notifications",
                    "Quick actions save time",
                    "Weekly and monthly reminders only fire on correct days"
                ]
            )
        ]
    )
    
    // MARK: - Edit History Help
    private static let editHistoryHelp = HelpTopic(
        title: "Edit History",
        sections: [
            HelpSection(
                title: "Overview",
                content: "This view allows you to modify or delete existing history entries. Use it to correct mistakes or update information about past entries.",
                tips: [
                    "Swipe to delete entries",
                    "Tap an entry to edit details",
                    "Changes are saved automatically",
                    "Be careful when deleting - it cannot be undone"
                ]
            ),
            HelpSection(
                title: "Why Edit History?",
                content: "Sometimes you may need to correct an entry's time, amount, or goal status. This view gives you full control over your historical data.",
                tips: [
                    "Fix accidental entries immediately",
                    "Update amounts if you recorded incorrectly",
                    "Adjust timestamps for accuracy"
                ]
            ),
            HelpSection(
                title: "Best Practices",
                content: "Only edit entries when necessary to maintain data integrity. If you frequently need to edit entries, consider being more careful when initially logging them.",
                tips: nil
            )
        ]
    )
    
    // MARK: - Edit Goals Help
    private static let editGoalsHelp = HelpTopic(
        title: "Edit Goals",
        sections: [
            HelpSection(
                title: "Overview",
                content: "Modify or delete existing goals. As your needs change, you can adjust targets, schedules, and notification settings.",
                tips: [
                    "Swipe to delete goals",
                    "Tap a goal to edit its details",
                    "Changes take effect immediately",
                    "Deleted goals don't affect historical data"
                ]
            ),
            HelpSection(
                title: "When to Edit Goals",
                content: "Edit goals when your routine changes, doctor adjusts dosages, or you want to challenge yourself with new targets.",
                tips: [
                    "Review goals weekly to ensure they're still relevant",
                    "Increase targets gradually as you build habits",
                    "Disable notifications if they become overwhelming"
                ]
            ),
            HelpSection(
                title: "Managing Multiple Goals",
                content: "You can have multiple goals for the same intake type (e.g., morning and evening doses). Edit each goal independently to maintain your complete schedule.",
                tips: nil
            )
        ]
    )
    
    // MARK: - Add Intake Type Help
    private static let addIntakeTypeHelp = HelpTopic(
        title: "Add Intake Type",
        sections: [
            HelpSection(
                title: "Overview",
                content: "Create new intake types to track different items. Each type has a name, default amount, and unit of measurement.",
                tips: [
                    "Give descriptive names (e.g., 'Vitamin D', 'Water')",
                    "Choose appropriate units (pills, ml, oz, mg, etc.)",
                    "Set realistic default amounts",
                    "Create types before setting goals"
                ]
            ),
            HelpSection(
                title: "Creating an Intake Type",
                content: "To add a new intake type:\n\n1. Enter a clear name\n2. Set the default amount\n3. Choose the unit of measurement\n4. Save the type\n\nYou can then use this type when adding history or creating goals.",
                tips: [
                    "Use consistent naming conventions",
                    "Include strength/dosage in the name if needed (e.g., 'Vitamin C 1000mg')",
                    "Group similar items logically"
                ]
            ),
            HelpSection(
                title: "Common Intake Types",
                content: "Popular intake types include:\n• Medications (pills, tablets)\n• Supplements (capsules, gummies)\n• Liquids (water, protein shakes)\n• Food items (meals, snacks)\n\nCreate whatever types match your tracking needs.",
                tips: nil
            ),
            HelpSection(
                title: "Units of Measurement",
                content: "Choose units that make sense for what you're tracking. Common options include: pills, tablets, capsules, ml, oz, cups, mg, g, servings.",
                tips: [
                    "Be consistent with units for the same type of item",
                    "Consider what's easiest to measure",
                    "Use standard units when possible"
                ]
            )
        ]
    )
    
    // MARK: - License Help
    private static let licenseHelp = HelpTopic(
        title: "License Agreement",
        sections: [
            HelpSection(
                title: "Overview",
                content: "The license agreement outlines the terms of use for KeepTrack. You must accept the license to use the app.",
                tips: [
                    "Read the license terms carefully",
                    "You only need to accept once per version",
                    "Your data remains private on your device"
                ]
            ),
            HelpSection(
                title: "Privacy & Data",
                content: "KeepTrack stores all your data locally on your device. Your tracking information, goals, and history are private and never shared with external servers.",
                tips: nil
            )
        ]
    )
    
    // MARK: - Reminder Testing Help
    private static let reminderTestingHelp = HelpTopic(
        title: "Testing Reminders",
        sections: [
            HelpSection(
                title: "Setup",
                content: "To test the reminder system:\n\n1. Ensure notification permissions are granted in Settings\n2. Create a goal with at least 2 reminder times\n3. Test different scenarios to verify functionality",
                tips: [
                    "For faster testing, set reminders just a few minutes ahead",
                    "Check Focus mode isn't blocking notifications",
                    "Verify you have active goals set up"
                ]
            ),
            HelpSection(
                title: "Test 1: Automatic Suppression",
                content: "Verify that reminders are suppressed when intake is logged before the scheduled time.\n\nSteps:\n1. Manually log an intake for the goal before the reminder time (e.g., at 1:55 PM for a 2:00 PM reminder)\n2. Wait for the reminder time to arrive\n3. Expected Result: No notification appears",
                tips: [
                    "This prevents duplicate reminders for items already taken",
                    "The system checks if any entry was logged at or before the scheduled time"
                ]
            ),
            HelpSection(
                title: "Test 2: Confirm Button",
                content: "Verify that the Confirm button logs an entry at the current time.\n\nSteps:\n1. Don't log any intake manually\n2. Wait for the reminder to fire\n3. When the notification appears, tap the 'Confirm' button\n4. Open the app and check your history\n5. Expected Result: Entry is logged with the timestamp when you pressed Confirm",
                tips: [
                    "This allows quick logging without opening the app",
                    "The entry will include the goal's name, dosage, and units",
                    "Perfect for when you're busy and need to confirm quickly"
                ]
            ),
            HelpSection(
                title: "Test 3: Cancel Button",
                content: "Verify that the Cancel button permanently stops the reminder.\n\nSteps:\n1. Don't log any intake\n2. Wait for the reminder to fire\n3. When the notification appears, tap the 'Cancel' button\n4. Expected Result: This specific reminder is cancelled and won't repeat",
                tips: [
                    "Useful if you decide you don't need this particular reminder",
                    "The reminder won't come back tomorrow unless you reschedule the goal",
                    "Other reminders for different times remain active"
                ]
            ),
            HelpSection(
                title: "Test 4: Superseded Reminders",
                content: "Verify that later reminders automatically cancel earlier ones.\n\nSteps:\n1. Set up a goal with multiple reminder times (e.g., 2:00 PM and 4:00 PM)\n2. Don't log any intake at 2:00 PM\n3. Ignore the 2:00 PM notification\n4. Wait for 4:00 PM reminder to fire\n5. Expected Result: The 2:00 PM reminder is automatically cancelled when 4:00 PM fires",
                tips: [
                    "This prevents notification clutter from missed reminders",
                    "Only the current and future reminders remain active",
                    "Helps keep your notification center clean"
                ]
            ),
            HelpSection(
                title: "Test 5: App in Foreground",
                content: "Verify reminders work when the app is open.\n\nSteps:\n1. Keep the app open and in focus\n2. Wait for a scheduled reminder time\n3. Expected Result: A banner notification appears at the top of the screen\n4. You can still use Confirm/Cancel buttons",
                tips: [
                    "Reminders work whether the app is open, in background, or closed",
                    "Banner appears temporarily at the top",
                    "Tap the banner to see more options"
                ]
            ),
            HelpSection(
                title: "Test 6: Multiple Goals",
                content: "Verify that different goals don't interfere with each other.\n\nSteps:\n1. Create two different goals (e.g., 'Medication A' and 'Medication B')\n2. Schedule reminders at the same time for both (e.g., both at 3:00 PM)\n3. Log intake for only 'Medication A'\n4. Wait for 3:00 PM\n5. Expected Result: Only the 'Medication B' reminder fires",
                tips: [
                    "Each goal's reminders are tracked independently",
                    "Logging one item doesn't affect other items",
                    "You can have many goals with overlapping times"
                ]
            ),
            HelpSection(
                title: "Test 7: Weekly Reminders",
                content: "Verify weekly reminders work correctly.\n\nSteps:\n1. Create a goal with weekly frequency (e.g., 'Sunday Vitamins')\n2. Set reminder for a specific weekday and time\n3. Log intake on that weekday before the reminder time\n4. Expected Result: Reminder is suppressed for that week\n5. Next week on the same day: Reminder fires normally",
                tips: [
                    "Weekly reminders only fire on the specified weekday",
                    "Logging on other days doesn't suppress the reminder",
                    "Each week resets - reminders fire again next week",
                    "Perfect for medications taken on specific days"
                ]
            ),
            HelpSection(
                title: "Test 8: Monthly Reminders",
                content: "Verify monthly reminders work correctly.\n\nSteps:\n1. Create a goal with monthly frequency (e.g., 'Prescription Refill')\n2. Set reminder for a specific day of month and time\n3. Log intake on that day before the reminder time\n4. Expected Result: Reminder is suppressed for that month\n5. Next month on the same day: Reminder fires normally",
                tips: [
                    "Monthly reminders only fire on the specified day of month",
                    "Logging on other days doesn't suppress the reminder",
                    "Each month resets - reminders fire again next month",
                    "Great for monthly medications or appointments"
                ]
            ),
            HelpSection(
                title: "Common Issues",
                content: "If notifications aren't appearing:\n\n• Check notification permissions in Settings → KeepTrack → Notifications\n• Verify Focus mode isn't blocking app notifications\n• Ensure the scheduled time hasn't already passed today\n• Check if intake was already logged (causing suppression)\n• Make sure the goal is active and has reminder times set",
                tips: nil
            ),
            HelpSection(
                title: "Understanding Reminder Behavior",
                content: "The reminder system is designed to be intelligent:\n\n• Automatically suppresses reminders for items already logged\n• Frequency-aware: Daily, weekly, and monthly reminders behave appropriately\n• Daily: Suppressed if logged today before scheduled time\n• Weekly: Suppressed if logged this week on same weekday before scheduled time\n• Monthly: Suppressed if logged this month on same day before scheduled time\n• Allows quick confirmation without opening the app\n• Cleans up old daily reminders to prevent clutter\n• Works independently for each goal you create\n• Respects your device's notification settings",
                tips: [
                    "Reminders help build consistent habits",
                    "Use Confirm for quick logging",
                    "Use Cancel if you change your mind",
                    "Choose the right frequency for your needs",
                    "Weekly and monthly reminders only fire on the correct days"
                ]
            )
        ]
    )
}


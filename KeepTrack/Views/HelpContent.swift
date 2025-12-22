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
                title: "Goal Notifications",
                content: "If you've enabled notifications, KeepTrack can remind you when it's time to take something according to your goals.",
                tips: [
                    "Enable notifications for important medications",
                    "Set reminder times that match your schedule",
                    "Tap notifications to quickly log entries"
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
                content: "You can create goals with different schedules: once daily, multiple times per day, specific days of the week, or custom intervals.",
                tips: [
                    "Multiple daily goals work well for medications",
                    "Weekly goals suit supplements taken on certain days",
                    "Custom intervals offer maximum flexibility"
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
}

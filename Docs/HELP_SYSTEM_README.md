# KeepTrack Help System

## Overview

The KeepTrack help system provides context-sensitive help for every view in the app. Users can tap a "?" button in the toolbar to access detailed guidance, tips, and instructions for each screen.

## Architecture

The help system consists of four main components:

### 1. HelpContent.swift
- `HelpTopic`: Represents help content for a specific view
- `HelpSection`: Individual sections within a help topic
- `HelpViewIdentifier`: Enum identifying different views
- `HelpContentManager`: Central manager for all help content

### 2. HelpView.swift
- `HelpView`: SwiftUI view displaying help content
- `HelpSectionView`: Displays individual help sections
- `HelpButtonModifier`: View modifier that adds help button
- `View.helpButton(for:)`: Convenience extension for adding help

### 3. Help Content
All help content is centralized in `HelpContentManager` with pre-defined topics for:
- Dashboard
- Today's History
- Yesterday's History
- Consumption By Day & Time
- Add History
- Show Goals
- Create Goals
- Edit History
- Edit Goals
- Add Intake Type
- License Agreement

### 4. View Integration
Each view in the app has the `.helpButton(for:)` modifier applied to display contextual help.

## Usage

### Adding Help to a New View

1. **Add an identifier to HelpViewIdentifier enum:**
```swift
enum HelpViewIdentifier {
    case dashboard
    case myNewView  // Add your view here
}
```

2. **Create help content in HelpContentManager:**
```swift
private static let myNewViewHelp = HelpTopic(
    title: "My New View",
    sections: [
        HelpSection(
            title: "Overview",
            content: "Description of what this view does.",
            tips: [
                "Tip 1 for users",
                "Tip 2 for users"
            ]
        )
    ]
)
```

3. **Update getHelpTopic method:**
```swift
static func getHelpTopic(for identifier: HelpViewIdentifier) -> HelpTopic {
    switch identifier {
    // ... existing cases
    case .myNewView:
        return myNewViewHelp
    }
}
```

4. **Add the help button to your view:**
```swift
struct MyNewView: View {
    var body: some View {
        NavigationStack {
            // Your view content
        }
        .helpButton(for: .myNewView)
    }
}
```

## Help Content Structure

Each help topic consists of:

- **Title**: The name of the view or feature
- **Sections**: One or more help sections containing:
  - **Section Title**: A descriptive heading
  - **Content**: Detailed explanation (supports multi-line text)
  - **Tips** (optional): Array of helpful tips displayed with checkmarks

## Design Principles

### User-Friendly
- Clear, concise language
- Progressive disclosure (overview → details → tips)
- Visual hierarchy with icons and colors

### Consistent
- All views have help available
- Uniform help button placement (top-right toolbar)
- Consistent help content structure

### Contextual
- Help content specific to each view
- Relevant to user's current task
- Action-oriented guidance

### Accessible
- VoiceOver labels on help buttons
- High contrast icons
- Readable typography

## UI Components

### Help Button
- Location: Top-right toolbar
- Icon: `questionmark.circle`
- Color: Blue (hierarchical rendering)
- Accessibility: "Show help for this screen"

### Help View
- Presentation: Sheet modal
- Navigation: NavigationStack with close button
- Scrollable content
- Sections with icons and visual hierarchy

### Help Sections
- Book icon for section titles
- Lightbulb icon for tips
- Checkmarks for individual tips
- Orange-tinted background for tip boxes

## Customization

### Modifying Help Content
Edit `HelpContent.swift` to update help text, add sections, or modify tips.

### Styling
Modify `HelpView.swift` and `HelpSectionView` to customize:
- Colors and typography
- Icons and symbols
- Layout and spacing

### Help Button Placement
The `.helpButton(for:)` modifier adds the button to `.topBarTrailing` by default. To customize placement, modify `HelpButtonModifier` in `HelpView.swift`.

## Best Practices

1. **Write for Your Audience**: Use simple language appropriate for all users
2. **Be Concise**: Provide essential information without overwhelming users
3. **Use Examples**: Include specific examples when explaining features
4. **Keep Updated**: Update help content when features change
5. **Test**: Verify help content is accurate and helpful

## Examples

### Basic Help Integration
```swift
struct SimpleView: View {
    var body: some View {
        NavigationStack {
            Text("My Content")
        }
        .helpButton(for: .myView)
    }
}
```

### Help with Multiple Sections
```swift
private static let exampleHelp = HelpTopic(
    title: "Example Feature",
    sections: [
        HelpSection(
            title: "Getting Started",
            content: "This is how you begin using this feature...",
            tips: ["First tip", "Second tip"]
        ),
        HelpSection(
            title: "Advanced Usage",
            content: "Once you're comfortable, try these advanced features...",
            tips: nil
        )
    ]
)
```

## Future Enhancements

Potential improvements to the help system:

- [ ] Search functionality within help content
- [ ] Video tutorials or animated guides
- [ ] Quick tips overlay (tooltips)
- [ ] Contextual help based on user actions
- [ ] Multi-language support
- [ ] Help history or frequently viewed topics
- [ ] Interactive tutorials or walkthroughs

## Support

For questions about the help system implementation, refer to:
- `HelpContent.swift` - Help content definitions
- `HelpView.swift` - UI components and view modifiers
- `HelpSystemDemo.swift` - Example implementation

---

**Last Updated**: November 14, 2025
**Version**: 1.0

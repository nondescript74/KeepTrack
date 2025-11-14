# Help System Architecture

## View Hierarchy

### Final Working Structure

```
NavigationStack (NewDashboard)
└── VStack ← .toolbar, .sheet applied here
    ├── TabView(selection: $selectedTab) ← Binding tracks active tab
    │   ├── Tab("Today", value: .today)
    │   │   └── HistoryDayView(kind: .today)
    │   │       └── EnterIntake (no NavigationStack)
    │   ├── Tab("Yesterday", value: .yesterday)
    │   │   └── HistoryDayView(kind: .yesterday)
    │   ├── Tab("By Day & Time", value: .byDayTime)
    │   │   └── ConsumptionByDayAndTimeView()
    │   ├── Tab("Add History", value: .addHistory)
    │   │   └── ChangeHistory()
    │   ├── Tab("Show Goals", value: .showGoals)
    │   │   └── GoalDisplayByName()
    │   ├── Tab("Goal", value: .enterGoal)
    │   │   └── EnterGoal()
    │   ├── Tab("History", value: .editHistory)
    │   │   └── EditHistory(items: $store.history)
    │   ├── Tab("Edit Goals", value: .editGoals)
    │   │   └── EditGoals(items: $goals.goals) (no NavigationView)
    │   └── Tab("Add New", value: .addNew)
    │       └── AddIntakeType()
    └── HStack (footer)
        └── "Welcome to KeepTrack!" + version info
```

### What Makes This Work

1. **Single NavigationStack**: Only at the top level (NewDashboard)
2. **VStack Container**: Wraps both TabView and footer
3. **Toolbar on VStack**: Can access `selectedTab` binding
4. **No Nested Navigation**: Child views don't create their own NavigationStack/NavigationView
5. **Tab Selection Binding**: `$selectedTab` tracks which tab is active
6. **Dynamic Help Content**: Sheet shows help based on `selectedTab.helpIdentifier`

## Data Flow

### Tab Selection Flow

```
User taps tab
    ↓
TabView updates selection
    ↓
@State selectedTab changes
    ↓
.onChange triggers (logging)
    ↓
User taps "?" button
    ↓
showingHelp = true
    ↓
.sheet presents with selectedTab.helpIdentifier
    ↓
Correct help content displayed
```

### State Management

```swift
@State private var selectedTab: TabSelection = .today
@State private var showingHelp = false

enum TabSelection {
    case today, yesterday, byDayTime, addHistory, 
         showGoals, enterGoal, editHistory, editGoals, addNew
    
    var helpIdentifier: HelpViewIdentifier {
        // Maps tab to help content
    }
}
```

## iPhone vs iPad Behavior

### iPhone (Compact Width)

**TabView Layout**: Bottom tab bar
- All tabs share the same toolbar space
- Toolbar items appear at the top
- Only one toolbar can be visible at a time
- Tab selection changes which content is visible

**Why It Was Broken (Issue #2)**:
```
NavigationStack
└── TabView
    .padding(10)
    HStack  ← .toolbar was here (wrong!)
```
The toolbar on HStack couldn't see TabView's selection changes.

**Why It Works Now**:
```
NavigationStack
└── VStack  ← .toolbar is here (correct!)
    ├── TabView(selection: $selectedTab)
    └── HStack
```
The toolbar on VStack can observe `$selectedTab` binding.

### iPad (Regular Width)

**TabView Layout**: Sidebar or floating tabs
- More space for multiple toolbars
- Different rendering of tabs
- Less affected by toolbar placement issues

**Why It Worked on iPad**:
Even with the wrong structure, iPad's layout gave enough separation that the binding worked correctly. However, the architecture was still wrong.

## Common Pitfalls

### ❌ Don't Do This

**1. Multiple NavigationStacks**
```swift
// Parent
NavigationStack {
    TabView {
        MyView()
    }
}

// Child (MyView)
NavigationStack {  // ❌ Nested!
    // content
}
```

**2. Toolbar on Wrong Element**
```swift
TabView {
    // tabs
}
SomeOtherView()
    .toolbar {  // ❌ Too far from TabView!
        // toolbar items
    }
```

**3. Individual Help Buttons in Tabs**
```swift
TabView {
    Tab("One") {
        View1()
            .helpButton(for: .view1)  // ❌ Creates duplicates!
    }
    Tab("Two") {
        View2()
            .helpButton(for: .view2)  // ❌ Creates duplicates!
    }
}
```

### ✅ Do This Instead

**1. Single NavigationStack**
```swift
// Parent
NavigationStack {
    TabView {
        MyView()  // No NavigationStack
    }
}
```

**2. Toolbar on Container**
```swift
VStack {
    TabView(selection: $selectedTab) {
        // tabs
    }
    Footer()
}
.toolbar {  // ✅ On VStack containing TabView
    // toolbar items
}
```

**3. Single Context-Aware Help Button**
```swift
VStack {
    TabView(selection: $selectedTab) {
        Tab("One", value: .one) { View1() }
        Tab("Two", value: .two) { View2() }
    }
}
.toolbar {
    ToolbarItem {
        Button { showHelp = true } label: { /* ... */ }
    }
}
.sheet(isPresented: $showHelp) {
    // ✅ Dynamic help based on selectedTab
    HelpView(topic: getHelp(for: selectedTab))
}
```

## Debugging Tips

### Check Tab Selection

Add logging to track tab changes:
```swift
TabView(selection: $selectedTab) {
    // tabs
}
.onChange(of: selectedTab) { oldValue, newValue in
    logger.debug("Tab changed: \(oldValue) → \(newValue)")
}
```

### Check Help Button Taps

Log what tab is active when help is tapped:
```swift
Button {
    logger.debug("Help tapped for: \(selectedTab)")
    showingHelp = true
} label: {
    // button label
}
```

### Verify Help Content

Check which help identifier is being used:
```swift
.sheet(isPresented: $showingHelp) {
    let identifier = selectedTab.helpIdentifier
    logger.debug("Showing help for: \(identifier)")
    return HelpView(topic: HelpContentManager.getHelpTopic(for: identifier))
}
```

## Testing Strategy

### Device Matrix

| Device | Layout | Tab Style | Expected Behavior |
|--------|--------|-----------|-------------------|
| iPhone SE | Compact | Bottom bar | One "?" button, content changes with tabs |
| iPhone 15 | Compact | Bottom bar | One "?" button, content changes with tabs |
| iPhone 15 Pro Max | Compact | Bottom bar | One "?" button, content changes with tabs |
| iPad mini | Regular | Sidebar/Floating | One "?" button, content changes with tabs |
| iPad Pro 11" | Regular | Sidebar/Floating | One "?" button, content changes with tabs |
| iPad Pro 12.9" | Regular | Sidebar/Floating | One "?" button, content changes with tabs |

### Test Cases

1. **Tab Switching**
   - [ ] Switch to each tab
   - [ ] Verify "?" button remains visible
   - [ ] Tap "?" button on each tab
   - [ ] Verify correct help content appears

2. **Orientation Changes**
   - [ ] Test portrait orientation
   - [ ] Test landscape orientation
   - [ ] Verify help still works in both

3. **Sheet Interaction**
   - [ ] Open help sheet
   - [ ] Scroll through content
   - [ ] Close sheet
   - [ ] Switch tabs
   - [ ] Re-open help
   - [ ] Verify content updated

4. **Accessibility**
   - [ ] Enable VoiceOver
   - [ ] Navigate to help button
   - [ ] Verify button is announced correctly
   - [ ] Verify help content is readable

## Performance Considerations

### State Management
- `selectedTab`: Lightweight enum, minimal memory
- `showingHelp`: Simple boolean flag
- No heavy computations in view body

### Help Content Loading
- Help content is static (defined at compile time)
- `HelpContentManager.getHelpTopic(for:)` is O(1) switch statement
- No network requests or file I/O
- Sheet presentation is lazy (only loaded when shown)

### View Updates
- Tab changes trigger minimal re-renders
- Only affected by `selectedTab` binding
- Help sheet is separate view hierarchy (not part of main view)

## Future Enhancements

### Potential Improvements

1. **Deep Linking to Help**
   ```swift
   .onOpenURL { url in
       if url.host == "help" {
           if let tab = TabSelection(rawValue: url.path) {
               selectedTab = tab
               showingHelp = true
           }
       }
   }
   ```

2. **Help Search**
   - Add search functionality across all help topics
   - Show results with navigation to relevant tab

3. **Contextual Help Tips**
   - Show inline tips on first app launch
   - Highlight new features
   - Offer quick help overlays

4. **Help History**
   - Track which help topics user viewed
   - Suggest related help content
   - Provide "recently viewed" section

5. **Interactive Help**
   - Step-by-step walkthroughs
   - Interactive tutorials
   - Guided tours of each feature

---

**Last Updated**: November 14, 2025  
**Version**: 2.0 (Fixed tab selection issue)

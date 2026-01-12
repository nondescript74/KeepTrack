#!/bin/bash

# Find all files calling addEntry(entry:) and show the context

echo "🔍 Searching for all addEntry() calls in your project..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Find all Swift files containing addEntry(entry:
grep -n -B 2 -A 2 "addEntry(entry:" --include="*.swift" -r . 2>/dev/null | \
while IFS= read -r line; do
    echo "$line"
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 INSTRUCTIONS:"
echo ""
echo "For each file listed above, update the addEntry() call to:"
echo "  await store.addEntry(entry: entry, goals: goals)"
echo ""
echo "If 'goals' is not available in that scope, you have options:"
echo "  1. Pass it as a parameter from a parent view/function"
echo "  2. Access it from @Environment"
echo "  3. Pass nil for now: await store.addEntry(entry: entry, goals: nil)"
echo ""
echo "✅ Already updated:"
echo "  - NewDashboard.swift"
echo ""
echo "💡 TIP: Use Xcode's 'Find and Replace' feature:"
echo "  Find: addEntry(entry: "
echo "  Review each result and add ', goals: goals' where appropriate"
echo ""

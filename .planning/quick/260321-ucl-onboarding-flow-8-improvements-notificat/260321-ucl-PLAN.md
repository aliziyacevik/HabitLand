# Quick Task 260321-ucl: Onboarding Flow 8 Improvements

## Task 1: Rewrite OnboardingView with all improvements

**Files:** `HabitLand/Screens/Onboarding/OnboardingView.swift`
**Action:**
- Merge Track+Sleep pages into single "Track Everything" page (3 info pages → 2)
- Add back button (chevron.left) on pages 1+
- Add emoji avatar picker to name entry page
- Replace dot indicators with "Step X of 4" + linear progress bar
- Add step-based flow: Pages → StarterHabits → GoalSetup → Notifications → Complete
- Wire GoalSetupView, NotificationSetupView, OnboardingCompleteView into the flow
**Verify:** Build succeeds, flow goes Welcome → Track → LevelUp → Name+Avatar → Habits → Goals → Notifications → Complete

## Task 2: Update StarterHabitsView limit to 5

**Files:** `HabitLand/Screens/Onboarding/StarterHabitsView.swift`
**Action:** Change free user habit limit from 3 to 5, update text
**Verify:** Limit text shows "5 habits"

## Task 3: Update OnboardingCompleteView for new flow

**Files:** `HabitLand/Screens/Onboarding/OnboardingCompleteView.swift`
**Action:** Accept habitsCreated count instead of categories, show habits + goals + sleep summary
**Verify:** Build succeeds

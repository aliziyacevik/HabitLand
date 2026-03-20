# HabitLand QA Test Plan

## Testing Approach
- Code-level static analysis (primary method — full source read)
- Runtime verification on iPhone 16 Pro simulator (iOS 18)
- Cross-referencing runtime behavior against source code

## Priority Flows
1. [x] First launch / onboarding
2. [x] Home dashboard — habit completion flow
3. [x] Create habit flow
4. [x] Edit habit flow
5. [x] Delete habit flow
6. [x] Habit detail / statistics
7. [x] Sleep tracking (premium gate)
8. [x] Premium paywall / IAP
9. [x] Profile view and edit
10. [x] Settings navigation
11. [x] Achievements system
12. [x] Notification management
13. [x] Theme/appearance changes
14. [x] Social tab (coming soon gate)
15. [x] Analytics screens

## Test Categories
- [x] Data model integrity
- [x] Navigation correctness
- [x] State management
- [x] Input validation
- [x] Empty states
- [x] Error handling
- [x] Premium gating logic
- [x] XP / level-up system
- [x] Streak calculation accuracy
- [x] Achievement unlock logic
- [x] Notification scheduling
- [x] Performance concerns
- [x] Accessibility basics
- [x] Visual/UX consistency

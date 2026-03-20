# UX Findings — HabitLand v1.0

1. **"On track today!" always shows** — HomeDashboardView shows this encouragement even at 0% completion. Should be contextual.
2. **No unsaved changes warning** — EditHabitView dismisses on close button without warning if user made changes.
3. **Archive toggle has no confirmation** — HabitDetailView toolbar menu toggles archive instantly. Destructive-ish action needs confirmation.
4. **LogSleepView default bedtime is yesterday 11pm** — Users opening at 2pm see confusing time. Should default to "last night" intelligently.
5. **Sleep quality picker too small on smaller screens** — 5 emoji buttons in a row may be cramped on iPhone SE/16e.
6. **No search in Settings** — 6 settings sub-pages with no search or shortcuts.
7. **Habit name allows whitespace-only** — Can create a habit named "   " (spaces only) since validation is just `name.isEmpty`.
8. **Delete habit is buried** — Delete is at bottom of EditHabitView AND in HabitDetailView toolbar menu. Inconsistent placement.
9. **No feedback after habit deletion** — User taps delete, view dismisses with no toast/confirmation that deletion succeeded.
10. **Custom days picker doesn't show day names** — Only single letters S/M/T/W/T/F/S — Tuesday and Thursday are both "T".

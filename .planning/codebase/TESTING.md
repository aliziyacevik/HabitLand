# Testing Patterns

**Analysis Date:** 2026-03-21

## Test Framework

**Runner:**
- Apple Testing framework (Swift 6.1+): `import Testing`
- XCTest for UI tests: `import XCTest`
- Config: No explicit test config file; uses Xcode defaults

**Assertion Library:**
- Apple Testing: `#expect()` macro (e.g., `#expect(habit.name == "Test Habit")`)
- XCTest: `XCTAssert*` methods (e.g., `XCTAssertTrue(element.exists)`)

**Run Commands:**
```bash
# Run all unit tests
xcodebuild test -scheme HabitLand

# Run UI tests
xcodebuild test -scheme HabitLand -testLanguage en

# Watch mode: use Xcode UI or IDE integration
```

## Test File Organization

**Location:**
- Unit tests: `HabitLandTests/` directory
- UI tests: `HabitLandUITests/` directory
- Co-located with app code by functionality

**File Structure:**
```
HabitLandTests/
├── HabitLandTests.swift          # Main unit test suite
└── [Components match app structure]

HabitLandUITests/
├── HabitLandUITests.swift        # General UI tests
├── QAAuditTests.swift            # Comprehensive QA audit
├── ScreenshotTests.swift         # Screenshot generation
└── HabitLandUITestsLaunchTests.swift  # App launch tests
```

**Naming:**
- Test files: `[Name]Tests.swift`
- Test structs: `struct HabitTests { }`, `struct UserProfileTests { }`
- Test functions: `@Test func testNameDescribesAssertion()` (Apple Testing)
- Test methods: `func testNameDescribesAssertion()` (XCTest)

## Test Structure

**Unit Test Pattern (Apple Testing):**

```swift
import Testing
import Foundation
@testable import HabitLand

struct HabitTests {
    @Test func newHabitHasDefaultValues() {
        let habit = Habit(name: "Test Habit")
        #expect(habit.name == "Test Habit")
        #expect(habit.icon == "checkmark.circle")
        #expect(habit.colorHex == "#34C759")
        #expect(habit.category == .health)
        #expect(habit.frequency == .daily)
        #expect(habit.isArchived == false)
        #expect(habit.safeCompletions.isEmpty)
        #expect(habit.goalCount == 1)
    }

    @Test func todayCompletedReturnsTrueWhenCompletedToday() {
        let habit = Habit(name: "Exercise")
        let completion = HabitCompletion(date: Date())
        completion.habit = habit
        habit.completions = (habit.completions ?? []) + [completion]
        #expect(habit.todayCompleted == true)
    }
}
```

**UI Test Pattern (XCTest):**

```swift
import XCTest

final class QAAuditTests: XCTestCase {
    let screenshotDir = "/path/to/screenshots/"

    @MainActor
    func testFullAppAudit() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-screenshotMode"]
        app.launch()
        sleep(2)
        continueAfterFailure = true

        // Test interaction
        let element = app.staticTexts["Text"]
        XCTAssertTrue(element.waitForExistence(timeout: 3))
        element.tap()
        sleep(1)

        // Save screenshot
        save(app, "screenshot_name")
    }

    private func save(_ app: XCUIApplication, _ filename: String) {
        let screenshot = XCUIScreen.main.screenshot()
        // Save to directory
    }
}
```

## Test Types

**Unit Tests:**
- **Scope:** Model validation, computed properties, data transformations
- **Approach:** Create models, call methods, assert results
- **Location:** `HabitLandTests/HabitLandTests.swift`
- **Examples:**
  - Model initialization: `newHabitHasDefaultValues()`
  - Computed properties: `todayCompletedReturnsTrueWhenCompletedToday()`
  - Calculations: `currentStreakCalculation()`, `bestStreakCalculation()`
  - Data validation: `allTemplatesHaveValidData()`

**Integration Tests:**
- Not explicitly separated; unit tests may include model relationships
- Example: `HabitCompletion` created and linked to `Habit`, then tested

**UI/E2E Tests:**
- **Scope:** User workflows, screen navigation, button interactions
- **Approach:** Launch app, interact with XCUITest API, verify state
- **Location:** `HabitLandUITests/`
- **Key test:** `QAAuditTests.swift` - comprehensive QA audit
  - Navigates all tabs (Home, Habits, Sleep, Social, Gamification, Profile, Settings)
  - Tests habit creation, detail view, achievement unlocking
  - Verifies social features, leaderboard, challenges
  - Captures screenshots for each major screen
  - Uses `-screenshotMode` launch argument for demo data
  - `continueAfterFailure = true` - allows test to continue after first failure

## Mocking

**Framework:** Not used; tests work with real model objects
**Approach:** Create actual model instances for testing
- No mock frameworks (OCMock, Mockito, etc.)
- Real `Habit`, `UserProfile`, `SleepLog` objects created in tests

**Example:**
```swift
@Test func todayProgressCalculation() {
    let habit = Habit(name: "Drink Water", goalCount: 3)
    #expect(habit.todayProgress == 0.0)

    let c1 = HabitCompletion(date: Date())
    c1.habit = habit
    habit.completions = (habit.completions ?? []) + [c1]
    #expect(abs(habit.todayProgress - (1.0/3.0)) < 0.01)
}
```

**What NOT to Mock:**
- Data models (Habit, UserProfile, etc.) - create real instances
- SwiftData relationships - used as-is in tests
- Time/Date operations - use Calendar API, not frozen time

**What COULD be Mocked (if needed):**
- Network calls (not present in current tests)
- File I/O (not present in current tests)
- External services (not present in current tests)

## Fixtures and Factories

**Test Data:**
- Created inline in test functions
- No separate factory classes
- Reused patterns via copy-paste in different test structs

**Example:**
```swift
let habit = Habit(name: "Meditate")
let calendar = Calendar.current
let today = calendar.startOfDay(for: Date())

for dayOffset in 0...2 {
    let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
    let c = HabitCompletion(date: date)
    c.habit = habit
    habit.completions = (habit.completions ?? []) + [c]
}
```

**Seed Data (for UI tests):**
- Location: `HabitLandApp.seedScreenshotData()` function in `HabitLandApp.swift`
- Activated by `-screenshotMode` launch argument
- Creates:
  - Profile with level 8, 520 XP
  - 5 sample habits with streaks (7-32 days)
  - Sleep logs for past 10 days
  - Unlocked achievements
  - Friend list for leaderboard testing
- Used in `QAAuditTests.swift` for consistent UI testing

## Coverage

**Requirements:** None enforced; no minimum coverage target
**Approach:** Test critical paths (models, calculations, user workflows)

**Current Coverage:**
- Model tests: Comprehensive (Habit, UserProfile, SleepLog, Achievement, Friend, Challenge, AppNotification, HabitCompletion)
- Computed property tests: Streak calculation, progress, level progression
- Data validation tests: Template library, category templates, achievement data
- Enum tests: SleepQuality values, NotificationType rawValues, HabitFrequency cases
- UI tests: Full app audit including all tabs, features, and states

## Test Categories (by file)

**`HabitLandTests.swift` - Model Unit Tests:**
- `struct HabitTests` - 7 tests
- `struct UserProfileTests` - 4 tests
- `struct HabitCompletionTests` - 1 test
- `struct SleepLogTests` - 1 test
- `struct AchievementTests` - 2 tests
- `struct XPLevelTests` - 8 tests (XP gain/loss, level up/down, progression)
- `struct SleepQualityTests` - 2 tests
- `struct NotificationTypeTests` - 1 test
- `struct HabitFrequencyTests` - 1 test
- `struct SampleDataTests` - 6 tests (template library, achievements)
- `struct HabitCategoryTests` - 2 tests
- **Total: ~38 unit tests**

**`QAAuditTests.swift` - Comprehensive UI Audit:**
- Systematic navigation through all tabs
- Screen interactions: tap, scroll, wait for elements
- Screenshot capture at each major state
- Element existence/interaction validation
- Uses `sleep()` for state transitions (crude but effective for UI tests)
- Wrapped in `@MainActor` for UI thread safety

**`ScreenshotTests.swift` - Screenshot Generation:**
- Isolated screenshot capture tests
- Configuration for marketing/app store imagery

**`HabitLandUITests.swift` - General UI Tests:**
- Basic launch and interaction tests
- May include smoke tests for critical flows

## Common Testing Patterns

**Async Testing:**
- Tests are synchronous; async code in app is tested synchronously
- Example: `seedScreenshotData()` creates data synchronously; no await in tests

**Date/Calendar Testing:**
- Use `Calendar.current` consistently
- Date components via `calendar.dateComponents([.day], from:...)`
- Date arithmetic via `calendar.date(byAdding: .day, value: -1, to: date)`
- Streak tests create consecutive dates and verify no gaps

**Example:**
```swift
@Test func currentStreakCalculation() {
    let habit = Habit(name: "Meditate")
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())

    // Add completions for today and 2 days prior (consecutive)
    for dayOffset in 0...2 {
        let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
        let c = HabitCompletion(date: date)
        c.habit = habit
        habit.completions = (habit.completions ?? []) + [c]
    }

    #expect(habit.currentStreak == 3)
}
```

**String Manipulation Testing:**
- Format verification: `#expect(log.durationFormatted.contains("h"))`
- Empty checks: `#expect(!value.isEmpty)`
- Pattern matching: `#expect(colorHex.hasPrefix("#"))`

**Enum Case Testing:**
- Iterate all cases: `for quality in SleepQuality.allCases { }`
- Verify properties: `#expect(!quality.icon.isEmpty)`
- Value ordering: `#expect(values[i] > values[i-1])`

**Collection Testing:**
- Count verification: `#expect(HabitTemplateLibrary.all.count >= 60)`
- Content existence: `#expect(!pack.templates.isEmpty)`
- Category filtering: `#expect(!HabitTemplateLibrary.templates(for: category).isEmpty)`

## UI Test Helpers

**Common XCUITest Methods:**
```swift
// Element queries
app.buttons["Label"]
app.staticTexts["Text"]
app.navigationBars.buttons.element(boundBy: 0)

// Interactions
element.tap()
element.waitForExistence(timeout: 3)
app.swipeUp()

// Configuration
app.launchArguments = ["-screenshotMode"]
continueAfterFailure = true

// Timing
sleep(1)  // Wait for animations/transitions
```

## Launch Arguments

**Screenshot Mode:**
- Flag: `-screenshotMode`
- Effect: Seeds demo data, skips onboarding, enables all Pro features
- Used in: `QAAuditTests`, `ScreenshotTests`

---

*Testing analysis: 2026-03-21*

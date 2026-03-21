# Coding Conventions

**Analysis Date:** 2026-03-21

## Naming Patterns

**Files:**
- View files: `[FeatureName]View.swift` (e.g., `HomeDashboardView.swift`, `HabitCard.swift`)
- Model files: `Models.swift` (all data models in single file), or `[ModelName].swift` for enums/templates (e.g., `HabitTemplate.swift`)
- Service/Manager files: `[Name]Manager.swift` or `[Name]Service.swift` (e.g., `NotificationManager.swift`, `ThemeManager.swift`)
- Intent files: `[Action]Intent.swift` (e.g., `CompleteHabitIntent.swift`, `DailyProgressIntent.swift`)
- Test files: `[Name]Tests.swift` in HabitLandTests/, `[Name]Tests.swift` in HabitLandUITests/ (e.g., `HabitLandTests.swift`, `QAAuditTests.swift`)

**Types (Classes, Structs, Enums):**
- PascalCase: `HomeDashboardView`, `NotificationManager`, `Habit`, `UserProfile`
- Enum cases: camelCase or lowercase depending on context
  - Simple enums: lowercase (e.g., `.daily`, `.health`, `.good`)
  - Complex enums: check examples in `Models.swift`
- Extensions: Organized by MARK sections with dashes (e.g., `// MARK: - Authorization`, `// MARK: - Computed Properties`)

**Functions and Methods:**
- camelCase: `scheduleHabitReminder`, `requestPermission`, `fetchCount`, `checkAuthorization`
- Private functions: prefix with `private func` (e.g., `private func setupQuickActions()`)
- Getter/computed properties: `var currentStreak: Int`, `var todayCompleted: Bool`

**Variables and Properties:**
- camelCase for local variables and properties: `userName`, `completedCount`, `streakDays`, `isFocused`
- Private properties: `@State private var`, `private let`, `nonisolated(unsafe) static var`
- Published properties for Observable: `@Published var isAuthorized`

**Type Prefixes for Design System:**
- Colors: `hl` prefix in extension (e.g., `Color.hlPrimary`, `Color.hlSuccess`, `Color.hlError`)
- Spacing: `HLSpacing` struct with static constants (e.g., `HLSpacing.xs`, `HLSpacing.md`)
- Fonts: `HLFont` struct with static functions (e.g., `HLFont.headline()`, `HLFont.body()`)
- Radius: `HLRadius` struct (e.g., `HLRadius.md`, `HLRadius.lg`)
- Icons: `HLIcon` enum/constants (e.g., `HLIcon.flame`, `HLIcon.trendUp`)
- Shadows: `HLShadow.Level`

## Code Style

**Formatting:**
- No explicit linting/formatting config (Xcode defaults applied)
- Spaces for indentation (not tabs), 4-space indent
- Maximum line length: not explicitly enforced; lines typically ~100 chars
- Trailing commas in multi-line collections

**Comments:**
- Section dividers: `// MARK: - Section Name` (with dashes)
- Single-line comments on complex logic (not excessive)
- No JSDoc-style comments; focus on clear code over documentation comments
- Inline comments for non-obvious behavior (e.g., `// Fire at 8pm if not completed`)

**Brace Style:**
- Opening braces on same line: `if condition {`
- Closing braces on new line (standard Swift)
- Minimal braces in simple conditions where readable

## Import Organization

**Order:**
1. Framework imports (SwiftUI, SwiftData, UIKit, Foundation, etc.)
2. `@testable import HabitLand` for test files
3. No explicit grouping with blank lines enforced; grouped logically

**Example from `HabitLandApp.swift`:**
```swift
import SwiftUI
import SwiftData
import UIKit
```

**Example from test file (`HabitLandTests.swift`):**
```swift
import Testing
import Foundation
@testable import HabitLand
```

## SwiftUI Component Patterns

**View Structure:**
- Components are `struct` implementing `View` protocol
- Multiple initializers supported: one for model objects, one for preview/manual construction
- Example from `HabitCard.swift`:
  ```swift
  struct HabitCard: View {
    // MARK: - Model Initializer
    init(habit: Habit, onToggle: (() -> Void)? = nil) { ... }

    // MARK: - Preview Initializer
    init(name: String, icon: String = "...", ...) { ... }
  }
  ```

**Body and Subviews:**
- Main `body` property contains high-level layout
- Complex subviews extracted into `private var` properties
- Subview pattern: `private var iconView: some View { ... }`
- Example from `HabitCard.swift`:
  ```swift
  var body: some View {
    HStack(spacing: HLSpacing.sm) {
      iconView      // extracted subview
      // ...
      checkmarkButton  // extracted subview
    }
    .hlCard()  // design system modifier
  }

  private var iconView: some View {
    ZStack { ... }
  }
  ```

**State Management:**
- `@State` for local UI state: `@State private var showDailyOverview = false`
- `@Query` for SwiftData queries: `@Query(filter: ..., sort: ...) private var habits: [Habit]`
- `@Environment` for model context: `@Environment(\.modelContext) private var modelContext`
- `@ObservedObject` for published objects: `@ObservedObject private var proManager = ProManager.shared`
- `@Binding` for parent-child value passing: `@Binding var text: String`
- `@FocusState` for keyboard focus: `@FocusState private var isFocused: Bool`

**Modifier Application:**
- Design system modifiers chained: `.hlCard()`, `.hlButton()`, etc.
- Animations: `.animation(HLAnimation.quick, value: someState)`
- Transitions: `.transition(.opacity.combined(with: .move(edge: .top)))`

## Error Handling

**Pattern:**
- Try-catch in methods returning optional or Bool
- Silent failures (return false/nil) for permission/notification operations
- No exception throwing; preference for optional returns
- Example from `NotificationManager.swift`:
  ```swift
  func requestPermission() async -> Bool {
    do {
      let granted = try await center.requestAuthorization(options: [...])
      isAuthorized = granted
      return granted
    } catch {
      return false  // Silent failure
    }
  }
  ```

**Data Validation:**
- Guard statements for required values: `guard totalCount > 0 else { return 0 }`
- Safe accessors for optional relationships: `var safeCompletions: [HabitCompletion] { completions ?? [] }`
- nil-coalescing in computed properties: `private var profile: UserProfile? { profiles.first }`

## Logging

**Framework:** No explicit logging framework; `print()` or `os_log` not observed in codebase
**Approach:** Focus on error handling rather than debug logging; no console output in production code

## Model Design (SwiftData)

**Convention:**
- `@Model` macro for persistent classes
- Classes (not structs): `final class Habit`, `final class UserProfile`
- UUID primary key: `var id: UUID = UUID()`
- Timestamps: `createdAt: Date`, `updatedAt: Date`
- Relationships: `@Relationship(deleteRule: .cascade) var completions: [HabitCompletion]? = []`
- Optional relationships for CloudKit compatibility: `var habit: Habit?`
- Safe accessors for optional relationships: `var safeCompletions: [HabitCompletion] { completions ?? [] }`
- Designated initializer: All properties initialized, UUIDs and dates set in init
- Example from `Models.swift`:
  ```swift
  @Model
  final class Habit {
    var id: UUID = UUID()
    var name: String = ""
    var colorHex: String = "#34C759"
    @Relationship(deleteRule: .cascade) var completions: [HabitCompletion]? = []

    init(name: String, icon: String = "checkmark.circle", ...) {
      self.id = UUID()
      self.name = name
      // ...
    }

    var safeCompletions: [HabitCompletion] { completions ?? [] }
  }
  ```

**Computed Properties (Performance Considerations):**
- Streak calculation: Iterates through sorted completions, early exit on first gap
- Weekly completion: Filters completions by date range
- Used heavily in `HomeDashboardView` and habit detail views
- No caching; computed on-demand (acceptable for small datasets per habit)

## Testing Patterns

- Unit tests in `HabitLandTests/`
- UI tests in `HabitLandUITests/`
- See TESTING.md for detailed patterns

## Screenshot Mode

**Convention:**
- Launch argument flag: `-screenshotMode`
- Check via: `ProcessInfo.processInfo.arguments.contains("-screenshotMode")`
- Used to seed demo data and skip real initializations
- Example from `HabitLandApp.swift`:
  ```swift
  private var isScreenshotMode: Bool {
    ProcessInfo.processInfo.arguments.contains("-screenshotMode")
  }
  ```

## Actor Isolation (MainActor)

**Pattern:**
- `@MainActor final class` for managers (e.g., `NotificationManager`, `ThemeManager`)
- `@MainActor` on methods that update UI state from background tasks
- Async/await for background operations: `Task { await manager.checkAuthorization() }`
- Thread-safe globals for theme: `nonisolated(unsafe) static var current` in `ActiveAccent`

## Special Patterns

**Quick Actions (iOS Shortcuts):**
- Defined as enum in app: `enum QuickAction: String`
- Configured in `setupQuickActions()` method
- Triggered via `AppDelegate` and `SceneDelegate`
- Notification center used for event propagation: `NotificationCenter.default.post(name: .quickActionTriggered, object: action)`

---

*Convention analysis: 2026-03-21*

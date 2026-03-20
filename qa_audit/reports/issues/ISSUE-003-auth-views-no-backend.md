# Issue ID
ISSUE-003

# Title
Auth views (Login, Register, ForgotPassword) have no backend — loading state never resolves

# Category
Bug / State

# Severity
High

# Priority
P1

# Screen / Feature
LoginView, RegisterView, ForgotPasswordView

# Environment
All

# Preconditions
Auth screens must be reachable (they exist but are not wired into onboarding flow)

# Steps to Reproduce
1. Navigate to LoginView
2. Enter email and password
3. Tap "Sign In"
4. Observe loading state

# Expected Result
Either authenticate user or show error

# Actual Result
LoginView.swift:72: `isLoading = true` is set, then `onLogin(email, password)` is called. The default closure `{ _, _ in }` does nothing. isLoading is NEVER set back to false. The button stays in loading state forever.

Same issue in RegisterView.swift:77: `isLoading = true` then `onRegister(...)` with empty closure. Loading never stops.

ForgotPasswordView uses a hardcoded 1.5s delay and always shows success — no actual email validation or sending.

# Frequency
Always

# Evidence
- LoginView.swift:8 (`var onLogin: (String, String) -> Void = { _, _ in }`)
- LoginView.swift:72 (`isLoading = true`)
- RegisterView.swift:10 (`var onRegister: ... = { _, _, _, _ in }`)
- RegisterView.swift:77 (`isLoading = true`)

# Suspected Root Cause
Auth views are UI shells with no backend integration. The loading state is set but never cleared because the callback closures are empty.

# Code References
- LoginView.swift:8, 72
- RegisterView.swift:10, 77
- ForgotPasswordView.swift (hardcoded delay, fake success)

# Impact
If auth screens are ever presented, the user gets stuck in an infinite loading state. Currently these screens are not reachable from the main flow, but they exist in the codebase and could be accidentally wired in.

# Recommended Fix Direction
Either: (1) Remove auth views if not needed for v1.0, (2) Add proper state management with timeout/error handling, or (3) Mark clearly as placeholder with TODO comments and ensure they cannot be navigated to.

# Notes for Next Agent
These screens are dead code in v1.0. The app uses local-only SwiftData with no auth. If shipping without auth, consider removing these files to avoid confusion. If keeping for future use, add `isLoading = false` in the callback fallback.

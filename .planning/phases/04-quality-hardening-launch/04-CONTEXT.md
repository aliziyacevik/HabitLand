# Phase 4: Quality Hardening & Launch - Context

**Gathered:** 2026-03-21
**Status:** Ready for planning

<domain>
## Phase Boundary

Strip debug artifacts, fix crash paths, implement production logging, test every screen's free tier behavior on clean device, polish UI transitions for premium feel, measure and optimize performance. Final gate before App Store submission.

</domain>

<decisions>
## Implementation Decisions

### Logging Strategy
- **D-01:** Replace all 28 unguarded `print()` with `os_log` using Apple's unified logging — best practice production logging
- **D-02:** Create a lightweight `HLLogger` wrapper using `os.Logger` with subsystem `"com.azc.HabitLand"` and per-module categories (storekit, cloudkit, healthkit, app)
- **D-03:** Log levels: `.debug` for dev-only info, `.info` for normal events, `.error` for failures. Debug-level messages auto-stripped from release builds by os_log
- **D-04:** APNs device token logging must be `.debug` level only — never visible in production logs

### Debug Bypass Cleanup
- **D-05:** All 5 `screenshotMode` checks must be wrapped in `#if DEBUG` blocks: ProManager.swift:28, HomeDashboardView.swift:61, PremiumGateView.swift:98, PremiumGateView.swift:150, PaywallView.swift:102
- **D-06:** `SharedModelContainer.swift:50` `try!` replaced with descriptive error handling (graceful fallback, not crash)

### Free Tier Testing Scope
- **D-07:** Every screen and every feature must be tested from a clean device free-tier perspective
- **D-08:** Specific flows to verify:
  - 3-habit limit enforcement (create 4th → paywall)
  - Analytics screens → Pro gate
  - Challenge join → Pro gate
  - Sleep insights Pro features → gate
  - Achievement details → accessible or gated
  - All tab bar destinations reachable
  - Settings → all rows functional
  - Profile → edit, stats, achievements
  - Social → friends, leaderboard, feed, challenges (without iCloud → graceful message)
  - Onboarding → complete flow
  - Referral code entry → works
  - Share sheet → functional
- **D-09:** Test both fresh install (no data) and populated state (demo data)

### UI Polish — Premium Transitions
- **D-10:** All `.sheet()` and `.fullScreenCover()` presentations get smooth custom transitions — sade, modern, premium hissi
- **D-11:** Transition style: subtle spring animations, opacity fade-in with gentle scale or slide. Not flashy — refined and consistent
- **D-12:** Sheet dismiss should feel equally smooth (not abrupt)
- **D-13:** Review empty states across all screens — friendly illustrations/messages where content is missing
- **D-14:** Dark mode compatibility check across all screens
- **D-15:** Edge case handling: very long habit names (truncation), 0 habits state, max streak display, network unavailable states

### Performance Thresholds
- **D-16:** Launch time target: < 1.5 seconds to interactive (cold start)
- **D-17:** Scroll performance: 60fps sustained in habit list, leaderboard, and feed views
- **D-18:** Memory footprint: < 100MB during normal usage, no leaks detected in Instruments
- **D-19:** Measurement approach: Xcode Time Profiler + Allocations instruments for profiling. Build with Release configuration for accurate measurements
- **D-20:** No pixel-by-pixel image processing on main thread (generate_screenshots.py is offline tool, not in-app — acceptable)

### Claude's Discretion
- Exact spring animation parameters (damping, stiffness)
- Which empty states need illustrations vs. simple text
- os.Logger category naming convention
- Specific Instruments profiling workflow

</decisions>

<specifics>
## Specific Ideas

- Transitions must feel "premium" — the kind of polish that makes users feel the app is high quality
- Sade ve modern — no bouncy or playful animations, refined and smooth
- Her ekran, her buton, her state test edilecek — kapsamlı QA
- Logging best practice: Apple'ın os_log unified logging framework'ü

</specifics>

<canonical_refs>
## Canonical References

No external specs — requirements are fully captured in decisions above and REQUIREMENTS.md (QAL-01 through QAL-06).

### Codebase references for fixes
- `HabitLand/Services/ProManager.swift` — screenshotMode bypass (line 28), print statements
- `HabitLand/Services/SharedModelContainer.swift` — try! crash path (line 50)
- `HabitLand/Services/CloudKitManager.swift` — 19 print statements
- `HabitLand/Services/HealthKitManager.swift` — 2 print statements
- `HabitLand/HabitLandApp.swift` — APNs token logging
- `HabitLand/Screens/Premium/PremiumGateView.swift` — 2 unguarded screenshotMode checks
- `HabitLand/Screens/Home/HomeDashboardView.swift` — 1 unguarded screenshotMode check

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `HLAnimation` struct with `.quick`, `.microSpring` presets — extend with sheet transition presets
- `hlStaggeredAppear` modifier (36 uses) — established pattern for entrance animations
- Design system tokens (HLSpacing, HLFont, HLRadius, HLShadow) — consistent styling foundation

### Established Patterns
- `@ObservedObject private var proManager = ProManager.shared` — singleton for Pro checks
- `ProcessInfo.processInfo.arguments.contains("-screenshotMode")` — pattern to wrap in #if DEBUG
- `.hlCard()` modifier for card styling — consistent card presentation

### Integration Points
- ProManager.isPro — central gate, must be clean before free tier testing
- All `.sheet()` presentations — 14+ locations for transition polish
- CloudKitManager, HealthKitManager, ProManager — logging migration targets

</code_context>

<deferred>
## Deferred Ideas

- Structured Concurrency audit (async/await patterns) — v2 optimization
- Accessibility audit (VoiceOver, Dynamic Type) — v2 requirement
- Localization of in-app strings (currently English only in UI) — v2

</deferred>

---

*Phase: 04-quality-hardening-launch*
*Context gathered: 2026-03-21*

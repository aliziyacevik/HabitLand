# Phase 5: Pro Visibility & Conversion Touchpoints - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-03-25
**Phase:** 05-pro-visibility-conversion-touchpoints
**Areas discussed:** Streak nudge, Sleep lock badge, Paywall & Profile, Onboarding pro offer

---

## Streak Nudge

### Q1: Where should the 7-day streak pro nudge appear?

| Option | Description | Selected |
|--------|-------------|----------|
| Home banner | Dismissable card at top of HomeDashboardView | |
| Celebration modal | Full-screen or sheet celebration with confetti, then Pro CTA | ✓ |
| Inline in streak | Small badge/button next to streak counter | |

**User's choice:** Celebration modal
**Notes:** More impactful, full-screen celebration moment

### Q2: When should this celebration trigger?

| Option | Description | Selected |
|--------|-------------|----------|
| Only 7-day | Single nudge at 7-day streak milestone | |
| Multiple milestones | 7, 14, 30 day milestones with Pro CTA | |
| You decide | Claude picks based on existing achievement system | ✓ |

**User's choice:** You decide
**Notes:** Claude's discretion on milestone pattern

### Q3: Should celebration show for all users?

| Option | Description | Selected |
|--------|-------------|----------|
| Free only | Only free users see celebration + Pro CTA | |
| Everyone, CTA varies | All users see celebration, Pro users just get congrats | ✓ |

**User's choice:** Everyone, CTA varies

---

## Sleep Lock Badge

### Q1: How should the lock badge look on Sleep tab?

| Option | Description | Selected |
|--------|-------------|----------|
| Small lock overlay | Tiny lock icon overlaid on moon icon | |
| Replace icon | Moon icon changes to moon+lock | |
| Crown badge | Small crown icon next to Sleep text label | ✓ |

**User's choice:** Crown badge

### Q2: What happens when free user taps Sleep tab?

| Option | Description | Selected |
|--------|-------------|----------|
| Show existing gate | Current blurredPremiumGate shows, just add crown badge | ✓ |
| Intercept before | Don't navigate, show paywall immediately | |
| Navigate + gate | Navigate normally + trigger paywall automatically | |

**User's choice:** Show existing gate

---

## Paywall & Profile

### Q1: Where should "Got a referral?" appear?

| Option | Description | Selected |
|--------|-------------|----------|
| Below pricing | After subscription buttons, small text link | |
| Top of paywall | Before pricing section, prominent banner | |
| Bottom footer | With Restore Purchases, minimal | ✓ |

**User's choice:** Bottom footer

### Q2: How should Profile pro gate work?

| Option | Description | Selected |
|--------|-------------|----------|
| Lock PersonalStats | PersonalStatisticsView link shows lock, tapping opens paywall | ✓ |
| Blur stats section | Stats in profile show blurred preview with overlay | |
| Hide stats entirely | Link hidden, replaced with upgrade card | |

**User's choice:** Lock PersonalStats

---

## Onboarding Pro Offer

### Q1: How should the onboarding pro offer look?

| Option | Description | Selected |
|--------|-------------|----------|
| Dedicated screen | Full onboarding page with feature highlights + "Start Pro" / "Maybe Later" | ✓ |
| Sheet overlay | Bottom sheet after onboarding completes | |
| Soft banner | Dismissable banner at top of Home after onboarding | |

**User's choice:** Dedicated screen

---

## Claude's Discretion

- Celebration modal design (confetti, colors, layout)
- Streak milestone trigger pattern
- Paywall copy improvements
- Crown badge sizing in TabBarView
- Onboarding Pro screen layout

## Deferred Ideas

- Referral system enhancement — future milestone
- Time/success-based upsells — post-launch
- A/B testing paywall designs — future

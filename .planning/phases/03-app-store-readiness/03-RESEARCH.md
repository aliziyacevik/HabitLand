# Phase 3: App Store Readiness - Research

**Researched:** 2026-03-21
**Domain:** App Store Connect metadata, ASO, screenshots, privacy/legal, Custom Product Pages
**Confidence:** HIGH

## Summary

Phase 3 is a content/metadata phase with minimal code changes. The primary deliverables are: (1) App Store screenshots in two required sizes, (2) ASO-optimized metadata in English and Turkish, (3) hosted privacy policy and terms of use URLs, (4) icon verification, and (5) Custom Product Pages for three audience segments.

The project already has strong foundations: a `ScreenshotTests.swift` UI test that captures 6 screens using `-screenshotMode`, in-app legal views (`LegalView.swift`) with complete privacy policy and terms of use content, and a well-configured app icon with light/dark/tinted variants. The main work is: composing the screenshots with marketing text overlays, creating hosted web versions of the legal pages, writing ASO-optimized copy in both languages, and configuring App Store Connect.

**Primary recommendation:** Focus on content creation (copy, keywords, screenshot compositions) rather than code. The only code-adjacent work is enhancing `ScreenshotTests.swift` to capture both device sizes and potentially creating a simple GitHub Pages site for legal URLs.

<user_constraints>

## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-01:** Pain point focused messaging -- "Aliskanliklarina hep yarida mi birakiyorsun?" style. Emotion-driven, not feature lists.
- **D-02:** Subtitle (30 char): English "Build habits that stick" / Turkish "Aliskanliklrini kalici yap"
- **D-03:** Description structure: Hook (pain point) -> Solution (what HabitLand does) -> Features (bullet list) -> Social proof (gamification, compete with friends) -> CTA
- **D-04:** Keyword field (100 char): habit tracker, aliskanlik, streak, gunluk rutin, sleep tracker, gamification -- no word repetition across title+subtitle+keywords
- **D-05:** 6 screenshots in specific order: Home Dashboard, Habit List, Sleep Dashboard, Social/Leaderboard, Achievements/Gamification, Paywall/Pro
- **D-06:** Each screenshot has short, bold headline text ABOVE the device frame
- **D-07:** Device sizes: 6.7" (iPhone 15 Pro Max / 16 Pro Max) + 5.5" (iPhone 8 Plus)
- **D-08:** Use existing `-screenshotMode` launch arg for automated screenshot capture
- **D-09:** Two languages: English (primary) + Turkish
- **D-10:** Screenshot headline text in both languages as separate sets
- **D-11:** Description and keywords fully translated for each language's market
- **D-12:** 3 Custom Product Pages: Fitness, Productivity, Sleep -- each reorders the same 6 screenshots
- **D-13:** CPPs use same screenshots in different order -- no extra screenshots needed
- **D-14:** Privacy policy URL: GitHub Pages or Notion public page (free hosting)
- **D-15:** Terms of use URL: same hosting, separate page
- **D-16:** Both URLs accessible from Settings -> Legal (already wired via TermsOfUseView, PrivacyPolicyView)
- **D-17:** Verify existing icon at 1024x1024 master + all required sizes

### Claude's Discretion
- Exact keyword selection (via ASO research)
- Screenshot frame style and color palette
- Description detailed copywriting
- Privacy policy and terms of use content
- Note: In-app legal content already exists in LegalView.swift -- web versions should match

### Deferred Ideas (OUT OF SCOPE)
- App Store In-App Events (seasonal campaigns) -- v2
- Apple Search Ads integration -- post-launch
- A/B testing different screenshot orders -- post-launch analytics
- Video preview for App Store listing -- future enhancement

</user_constraints>

<phase_requirements>

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| ASR-01 | App Store screenshots created for 6.7" and 5.5" device sizes | Screenshot specs verified: 1290x2796 (6.7") and 1242x2208 (5.5"). Existing ScreenshotTests.swift captures raw screenshots. Need composition with marketing text. |
| ASR-02 | App Store description, subtitle (30 chars), and keyword field (100 chars) optimized for ASO | ASO best practices documented. Title+subtitle+keywords form combined index set -- no repetition. Comma-separated, no spaces after commas in keyword field. |
| ASR-03 | Privacy policy and terms of use URLs set and accessible | In-app content exists in LegalView.swift. Need web-hosted versions at stable URLs. GitHub Pages recommended. URLs must be set in App Store Connect AND updated in app views. |
| ASR-04 | App icon verified at all required sizes (1024x1024 down to 40x40) | Icon asset catalog has AppIcon.png (1024x1024) + dark + tinted variants. Modern Xcode auto-generates all sizes from 1024x1024 master -- just verify render quality at small sizes. |
| ASR-05 | Turkish localization for App Store listing (description, keywords, screenshots) | Separate Turkish keyword set targeting Turkish App Store (less competitive for habit trackers). Screenshot headline text needs Turkish variants. Full description translation. |
| ASR-06 | Custom Product Pages configured for different audiences (fitness, productivity, sleep) | Up to 70 CPPs allowed. Each can customize screenshots, promotional text, and (since July 2025) can appear in organic search. Same screenshots, different order per D-13. |

</phase_requirements>

## Standard Stack

This phase is primarily content/configuration work. No new libraries needed.

### Core Tools
| Tool | Purpose | Why Standard |
|------|---------|--------------|
| XCUITest + `ScreenshotTests.swift` | Automated raw screenshot capture | Already exists in project, uses `-screenshotMode` |
| GitHub Pages | Host privacy policy and terms of use | Free, stable URLs, no server needed, per D-14 |
| App Store Connect | Upload metadata, screenshots, configure CPPs | Apple's required portal |

### Supporting
| Tool | Purpose | When to Use |
|------|---------|-------------|
| Xcode Simulator | Capture screenshots at exact device resolutions | 6.7" and 5.5" simulators |
| Any image editor / SwiftUI preview | Compose screenshots with marketing text overlays | Adding headline text above device frames |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| GitHub Pages | Notion public page | Notion URLs are long/ugly, less professional. GitHub Pages gives `username.github.io/habitland/privacy` |
| Manual screenshot composition | fastlane snapshot + frameit | Overkill for 6 screenshots. Manual or simple script is faster for indie. |

## Architecture Patterns

### Recommended Content Structure
```
AppStoreAssets/
  Screenshots/
    en/
      6.7/          # 1290x2796 composed screenshots with English text
      5.5/          # 1242x2208 composed screenshots with English text
    tr/
      6.7/          # 1290x2796 composed screenshots with Turkish text
      5.5/          # 1242x2208 composed screenshots with Turkish text
    raw/            # Raw simulator captures (no marketing text)
  Metadata/
    en/
      description.txt
      keywords.txt
      subtitle.txt
    tr/
      description.txt
      keywords.txt
      subtitle.txt
docs/               # GitHub Pages site (or separate repo)
  privacy-policy.md
  terms-of-use.md
  index.html        # Optional landing page
```

### Pattern 1: Screenshot Composition
**What:** Raw simulator screenshots with marketing headline text overlaid above device frame
**When to use:** All 6 screenshots in both languages
**Approach:**
1. Capture raw screenshots via `ScreenshotTests.swift` on both simulator sizes
2. Compose final images with headline text, background color, and optional device frame
3. Export at exact pixel dimensions: 1290x2796 (6.7") and 1242x2208 (5.5")

**Screenshot order and headlines (per D-05, D-06):**

| # | Screen | English Headline | Turkish Headline |
|---|--------|-----------------|-----------------|
| 1 | Home Dashboard | "Every day, one step closer" | "Her gun bir adim daha" |
| 2 | Habit List | "Start with 3, go unlimited" | "3 aliskanlikla basla, sinirsiza gec" |
| 3 | Sleep Dashboard | "Track your sleep, change your life" | "Uykunu takip et, hayatini degistir" |
| 4 | Social/Leaderboard | "Compete with friends" | "Arkadaslarinla yaris" |
| 5 | Achievements | "Earn badges, level up" | "Rozetler kazan, seviye atla" |
| 6 | Paywall/Pro | "Unlimited experience with Pro" | "Pro ile sinirsiz deneyim" |

### Pattern 2: ASO Keyword Strategy
**What:** Title + subtitle + keyword field treated as a single combined index set
**Key rules:**
- No word should appear in more than one field (title, subtitle, keywords)
- Keyword field: comma-separated, NO spaces after commas
- "HabitLand" in title is already indexed -- don't repeat in keywords
- "habits" and "stick" from subtitle "Build habits that stick" are indexed -- don't repeat
- Use the full 100 characters
- Digits instead of spelled-out numbers
- No stop words (the, a, an, and, for)

### Pattern 3: GitHub Pages for Legal URLs
**What:** Static site hosted on GitHub Pages with privacy policy and terms
**Structure:**
- Repository: can be the same repo's `docs/` folder or a separate `habitland-legal` repo
- Privacy URL: `https://{username}.github.io/habitland/privacy`
- Terms URL: `https://{username}.github.io/habitland/terms`
- Content: Convert existing `LegalView.swift` text to HTML/Markdown
- Must be publicly accessible without authentication

### Anti-Patterns to Avoid
- **Keyword stuffing in title:** Apple rejects titles like "HabitLand - Best Habit Tracker App." Keep it clean: "HabitLand" or "HabitLand: Habit Tracker" max.
- **Repeating words across fields:** "habit" in title AND subtitle AND keywords wastes characters and adds no ranking benefit.
- **Raw screenshots without context:** Uploading bare app UI without marketing text significantly reduces conversion rate.
- **Using spaces in keyword field:** "habit tracker, sleep" wastes 2 characters. Use "habit,tracker,sleep" (no spaces after commas).

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Privacy policy content | Custom legal text from scratch | Adapt existing LegalView.swift content + use privacy policy generator for gaps | Already written and reviewed; consistency between app and web versions |
| Screenshot device frames | Custom frame drawing code | Pre-made device frame templates or simple colored background with text | Device frames are cosmetic; simple bold text above screenshot is the user's chosen style |
| ASO keyword research | Guessing keywords | Apple Search Ads keyword tool (free account) or AppTweak free tier | Data-driven keyword selection beats guessing |
| App Store Connect metadata upload | Manual field-by-field entry | Prepare all text in files first, then paste systematically | Prevents typos, enables version control of metadata |

**Key insight:** This phase is content creation, not engineering. The value is in the copy quality, keyword selection, and visual presentation -- not in tooling.

## Common Pitfalls

### Pitfall 1: Keyword Repetition Across Fields
**What goes wrong:** Using "habit" in title ("HabitLand"), subtitle ("Build habits that stick"), AND keyword field. Each repetition wastes 5+ characters from the 100-char keyword field.
**Why it happens:** Developers don't realize Apple indexes title + subtitle + keywords as a combined set.
**How to avoid:** Create a master keyword list. Assign each word to exactly ONE field. Title gets brand + primary keyword. Subtitle gets secondary keywords. Keyword field gets everything else.
**Warning signs:** Same word appears in multiple fields; keyword field is under 90 characters used.

### Pitfall 2: Screenshot Dimension Mismatch
**What goes wrong:** Uploading screenshots at wrong pixel dimensions causes App Store Connect rejection or blurry display.
**Why it happens:** Confusing points vs pixels, or using wrong simulator device.
**How to avoid:** 6.7" must be exactly 1290x2796px. 5.5" must be exactly 1242x2208px. PNG format, RGB, 72dpi.
**Warning signs:** App Store Connect shows upload error; screenshots look blurry on device pages.

### Pitfall 3: Privacy Policy URL Not Accessible
**What goes wrong:** Privacy policy URL returns 404 or requires authentication. Apple cannot access it during review.
**Why it happens:** GitHub Pages not enabled, wrong URL path, or repository is private.
**How to avoid:** After deploying, test the URL in an incognito browser window. Ensure GitHub Pages is enabled in repo settings. Verify HTTPS works.
**Warning signs:** URL returns 404; page requires login; HTTPS certificate error.

### Pitfall 4: Missing HealthKit Disclosure in Privacy Labels
**What goes wrong:** App uses HealthKit but privacy nutrition labels in App Store Connect don't declare health data collection. Apple rejects with vague "privacy information isn't accurate" message.
**Why it happens:** HealthKit data read on-device feels like "not collected" but if any derivative data is synced via CloudKit, it must be declared.
**How to avoid:** Audit data flow: HealthKit data read -> displayed locally (not collected). BUT if step counts are synced to CloudKit for leaderboards, that IS collection. Declare accordingly.
**Warning signs:** HealthKit permission strings exist but no health data declared in privacy labels.

### Pitfall 5: Custom Product Pages Without Unique Promotional Text
**What goes wrong:** Creating CPPs with just reordered screenshots but no unique promotional text. Misses the opportunity for audience-specific messaging.
**Why it happens:** Developers think CPPs are just about screenshot order.
**How to avoid:** Each CPP should have unique promotional text (170 char limit) targeting its audience segment. Fitness CPP: "Track steps, build exercise habits, compete on leaderboards." Sleep CPP: "Better sleep, better habits. Track your rest and wake refreshed."
**Warning signs:** All CPPs have identical promotional text.

### Pitfall 6: Not Updating In-App Legal Views with Web URLs
**What goes wrong:** Privacy policy and terms exist as in-app views (LegalView.swift) but don't link to the web-hosted versions. App Store Connect expects a URL, not just in-app text.
**Why it happens:** Developers create web versions but forget to update the app views to reference them.
**How to avoid:** After creating GitHub Pages URLs, update TermsOfUseView and PrivacyPolicyView (or GeneralSettingsView's legal section) to include "View online" links to the web versions. Also set URLs in App Store Connect.
**Warning signs:** App Store Connect privacy/terms URL fields are empty; in-app legal views don't mention web URLs.

## Code Examples

### Existing Screenshot Infrastructure
```swift
// Source: HabitLandUITests/ScreenshotTests.swift
// Already captures 5 tabs + paywall using -screenshotMode
// Saves to /Users/azc/works/HabitLand/AppStoreAssets/Screenshots/
// Enhancement needed: run on both 6.7" and 5.5" simulators
```

### Existing Legal Content
```swift
// Source: HabitLand/Screens/Premium/LegalView.swift
// Contains complete PrivacyPolicyView and TermsOfUseView
// Content covers: data collection, HealthKit, IAP, notifications,
// data deletion, children's privacy, subscriptions, free features
// This content should be mirrored to web-hosted versions
```

### App Icon Configuration
```json
// Source: HabitLand/Assets.xcassets/AppIcon.appiconset/Contents.json
// Has: AppIcon.png (1024x1024), AppIcon-Dark.png, AppIcon-Tinted.png
// Modern Xcode (iOS 17+) auto-generates all required sizes from 1024x1024
// Verification: build and check all sizes render without artifacts
```

### Keyword Field Format Example
```
// CORRECT: comma-separated, no spaces, no words from title/subtitle
streak,routine,goals,wellness,gamification,challenge,reminder,daily,health,sleep,rutin,hedef,saglik

// WRONG: spaces after commas, repeated words, phrases
habit tracker, daily habits, build habits, sleep tracking
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| CPPs only for paid ads | CPPs appear in organic search results | July 2025 | CPPs now directly impact organic ASO, not just ad campaigns |
| Single icon size (1024x1024) | 1024x1024 with dark + tinted variants | iOS 18 / 2024 | Must provide dark and tinted icon variants (project already has these) |
| 10 screenshot slots | Up to 10 screenshots per locale per device | Unchanged | 6 screenshots per D-05 is within limits |
| Manual screenshot capture | XCUITest automated capture | Standard | Project already uses ScreenshotTests.swift |
| Up to 35 CPPs | Up to 70 CPPs | 2024 | More room for audience segmentation |

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | XCTest / XCUITest (built-in) |
| Config file | Xcode project scheme configuration |
| Quick run command | `xcodebuild test -scheme HabitLand -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' -only-testing ScreenshotTests` |
| Full suite command | `xcodebuild test -scheme HabitLand -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max'` |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| ASR-01 | Screenshots captured at correct sizes | smoke | Run ScreenshotTests on both 6.7" and 5.5" simulators, verify output PNGs exist and have correct dimensions | Partial -- ScreenshotTests.swift exists but needs enhancement for 5.5" |
| ASR-02 | Metadata text lengths within limits | manual-only | Verify subtitle <= 30 chars, keywords <= 100 chars by character count | N/A -- text file verification |
| ASR-03 | Privacy/terms URLs accessible | smoke | `curl -s -o /dev/null -w "%{http_code}" https://URL` returns 200 | N/A -- post-deployment verification |
| ASR-04 | App icon renders at all sizes | manual-only | Build app, verify icon in simulator at various sizes | N/A -- visual verification |
| ASR-05 | Turkish metadata exists and correct length | manual-only | Verify Turkish text files exist and meet character limits | N/A -- text file verification |
| ASR-06 | CPP configuration documented | manual-only | Verify CPP screenshot orders and promotional text prepared | N/A -- App Store Connect config |

### Sampling Rate
- **Per task commit:** Visual verification of outputs
- **Per wave merge:** Full screenshot capture test on both simulators
- **Phase gate:** All screenshots exist at correct dimensions; all URLs accessible; all text within character limits

### Wave 0 Gaps
- [ ] `ScreenshotTests.swift` enhancement -- add 5.5" simulator support and 6th screenshot (paywall already partially exists)
- [ ] URL accessibility test script -- simple curl check for deployed legal pages

## Open Questions

1. **GitHub username for Pages URL**
   - What we know: Decision D-14 says GitHub Pages or Notion
   - What's unclear: Exact GitHub username/org for the URL structure
   - Recommendation: Use the developer's GitHub account. URL format: `https://{username}.github.io/habitland-legal/privacy`

2. **Screenshot composition tooling**
   - What we know: Need marketing text above device frames (D-06)
   - What's unclear: Whether to use an image editor, SwiftUI canvas, or a screenshot framing tool
   - Recommendation: Use a simple SwiftUI view rendered to image, or Figma/Sketch if available. For an indie app, even Keynote/PowerPoint works well for composing screenshots with text overlays. The planner should keep this flexible.

3. **Exact keyword selection**
   - What we know: Combined set across title+subtitle+keywords, 100 char limit, no repetition
   - What's unclear: Optimal keywords depend on search volume data
   - Recommendation: Create initial keyword set based on competitor analysis and Turkish market gaps. Iterate post-launch with Apple Search Ads data. This is Claude's discretion per CONTEXT.md.

## Sources

### Primary (HIGH confidence)
- [Apple Developer - Screenshot Specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/) -- exact pixel sizes verified
- [Apple Developer - Custom Product Pages](https://developer.apple.com/app-store/custom-product-pages/) -- CPP limits and capabilities
- [Apple Developer - App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/) -- privacy nutrition label requirements

### Secondary (MEDIUM confidence)
- [Udonis - Complete ASO Guide 2026](https://www.blog.udonis.co/mobile-marketing/mobile-apps/complete-guide-to-app-store-optimization) -- ASO keyword strategy verified against Apple docs
- [AppTweak - Custom Product Pages Guide 2026](https://www.apptweak.com/en/aso-blog/guide-to-custom-product-pages-cpp) -- CPP organic search feature (July 2025)
- [MobileAction - App Screenshot Sizes 2026](https://www.mobileaction.co/guide/app-screenshot-sizes-and-guidelines-for-the-app-store/) -- screenshot dimension verification
- [App Privacy Policy Generator](https://mobile-privacy.github.io/generator/) -- template for web-hosted privacy policy

### Tertiary (LOW confidence)
- [MobileAction - ASO Keyword Research 2026](https://www.mobileaction.co/blog/aso-keyword-research/) -- keyword research methodology (general advice, not HabitLand-specific)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- this phase uses existing infrastructure (XCUITest, GitHub Pages, App Store Connect)
- Architecture: HIGH -- screenshot specs and ASO rules are well-documented by Apple
- Pitfalls: HIGH -- sourced from project's own PITFALLS.md research + Apple guidelines
- Content strategy: MEDIUM -- copywriting and keyword selection are inherently iterative; initial set will be refined post-launch

**Research date:** 2026-03-21
**Valid until:** 2026-04-21 (stable -- App Store requirements change infrequently)

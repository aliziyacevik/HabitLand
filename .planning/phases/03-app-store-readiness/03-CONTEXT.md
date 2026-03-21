# Phase 3: App Store Readiness - Context

**Gathered:** 2026-03-21
**Status:** Ready for planning

<domain>
## Phase Boundary

App Store listing is complete, optimized for discovery, and ready for submission. This covers metadata (title, subtitle, keywords, description), screenshots, privacy policy/terms URLs, icon verification, Turkish localization, and Custom Product Pages. No code changes — purely content and configuration.

</domain>

<decisions>
## Implementation Decisions

### App Store Messaging Tone
- **D-01:** Pain point odaklı mesajlar — "Alışkanlıklarını hep yarıda mı bırakıyorsun?" tarzı. Özellik listesi değil, duygu odaklı.
- **D-02:** Subtitle (30 char): İngilizce "Build habits that stick" / Türkçe "Alışkanlıklarını kalıcı yap"
- **D-03:** Description yapısı: Hook (pain point) → Çözüm (HabitLand ne yapar) → Özellikler (bullet list) → Social proof (gamification, arkadaşlarla yarış) → CTA
- **D-04:** Keyword field (100 char): habit tracker, alışkanlık, streak, günlük rutin, sleep tracker, gamification — kelime tekrarı yok (title+subtitle+keywords birleşik set)

### Screenshot Strategy
- **D-05:** 6 screenshot, şu sırayla:
  1. Home Dashboard (streak'ler, günlük ilerleme) — "Her gün bir adım daha"
  2. Habit List (aktif alışkanlıklar) — "3 alışkanlıkla başla, sınırsıza geç"
  3. Sleep Dashboard — "Uykunu takip et, hayatını değiştir"
  4. Social/Leaderboard — "Arkadaşlarınla yarış"
  5. Achievements/Gamification — "Rozetler kazan, seviye atla"
  6. Paywall/Pro (özellik listesi) — "Pro ile sınırsız deneyim"
- **D-06:** Her screenshot'ta üst kısımda kısa, bold başlık yazısı (device frame içinde değil, üstünde)
- **D-07:** Device sizes: 6.7" (iPhone 15 Pro Max / 16 Pro Max) + 5.5" (iPhone 8 Plus — eski format zorunlu)
- **D-08:** Mevcut `-screenshotMode` launch arg kullanılarak simulator'da otomatik screenshot alınabilir

### Localization
- **D-09:** İki dil: İngilizce (primary) + Türkçe
- **D-10:** Screenshot üst yazıları her iki dilde ayrı set
- **D-11:** Description ve keywords her iki dilde tam çeviri (keyword'lerde her dil kendi pazarına uygun)

### Custom Product Pages
- **D-12:** 3 Custom Product Page:
  1. **Fitness** — screenshot sırası: HealthKit/steps first, exercise habits, then streaks. Subtitle: "Track your fitness habits"
  2. **Productivity** — screenshot sırası: habit list first, streaks, achievements. Subtitle: "Build productive routines"
  3. **Sleep** — screenshot sırası: sleep dashboard first, then habits, social. Subtitle: "Better sleep, better life"
- **D-13:** Her CPP aynı 6 screenshot'tan farklı sıralama kullanır — ekstra screenshot üretmeye gerek yok

### Privacy & Legal
- **D-14:** Privacy policy URL: GitHub Pages veya Notion public page (ücretsiz hosting)
- **D-15:** Terms of use URL: aynı hosting, ayrı sayfa
- **D-16:** Her iki URL uygulamanın Settings → Legal bölümünden erişilebilir (zaten var — TermsOfUseView, PrivacyPolicyView)

### App Icon
- **D-17:** Mevcut icon'u doğrula — 1024x1024 master + tüm gerekli boyutlarda (40, 60, 76, 83.5, 120, 152, 167, 180, 1024) doğru render

### Claude's Discretion
- Exact keyword selection (ASO araştırması ile belirlenir)
- Screenshot frame style ve renk paleti
- Description'ın detaylı copywriting'i
- Privacy policy ve terms of use içeriği

</decisions>

<specifics>
## Specific Ideas

- Pain point marketing mesajı: "Alışkanlıklarını hep yarıda mı bırakıyorsun?", "Bu sefer farklı olacak", "Motivasyonun düştüğünde arkadaşların devam ettiriyor"
- Türkçe App Store'da habit tracker kategorisinde çok az kaliteli uygulama var — Türkçe lokalizasyon rekabet avantajı
- Screenshots'larda gerçek veri yerine "ideal" demo veri kullanılacak (uzun streak'ler, güzel isimli alışkanlıklar)

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Screenshot Infrastructure
- `HabitLand/HabitLandApp.swift` — `-screenshotMode` launch argument handling
- `HabitLandUITests/` — Existing UI test target for automated screenshots

### Legal Views
- `HabitLand/Screens/Settings/TermsOfUseView.swift` — Terms URL display
- `HabitLand/Screens/Settings/PrivacyPolicyView.swift` — Privacy policy URL display

### App Icon
- `HabitLand/Assets.xcassets/AppIcon.appiconset/` — Icon assets

### Research
- `.planning/research/FEATURES.md` — Competitor pricing and feature comparison
- `.planning/research/PITFALLS.md` — ASO mistakes to avoid

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `-screenshotMode` flag — already bypasses onboarding, enables Pro, seeds demo data
- UI test infrastructure — can be extended for automated screenshot capture
- TermsOfUseView / PrivacyPolicyView — already wired in Settings

### Established Patterns
- QA audit screenshots already exist in `qa_audit/screenshots/` — can serve as reference for final screenshots

### Integration Points
- App Store Connect — metadata, screenshots, localization uploaded there
- Privacy policy / terms URLs — set in App Store Connect and referenced in app

</code_context>

<deferred>
## Deferred Ideas

- App Store In-App Events (seasonal campaigns) — v2
- Apple Search Ads integration — post-launch
- A/B testing different screenshot orders — post-launch analytics
- Video preview for App Store listing — future enhancement

</deferred>

---

*Phase: 03-app-store-readiness*
*Context gathered: 2026-03-21*

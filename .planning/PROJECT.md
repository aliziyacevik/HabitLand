# HabitLand

## What This Is

HabitLand, gamification odaklı bir iOS habit tracker uygulamasıdır. Kullanıcılar günlük alışkanlıklarını takip eder, streak'ler ve rozetlerle motivasyon kazanır, arkadaşlarıyla yarışır ve uyku kalitelerini izler. SwiftUI + SwiftData ile iOS 17+ hedeflenerek geliştirilmektedir.

## Core Value

Kullanıcıların alışkanlıklarını eğlenceli ve sosyal bir deneyimle kalıcı hale getirmesi — "Bu sefer yarıda bırakmayacaksın."

## Requirements

### Validated

- ✓ Alışkanlık oluşturma, düzenleme, silme — existing
- ✓ Günlük alışkanlık tamamlama ve streak takibi — existing
- ✓ HealthKit entegrasyonu (adım, su, egzersiz, kalori, uyku vb.) — existing
- ✓ Uyku takibi dashboard'u — existing
- ✓ Rozet/Achievement sistemi — existing
- ✓ Sosyal özellikler (arkadaş ekleme, leaderboard, challenge) — existing
- ✓ Profil ve ayarlar ekranları — existing
- ✓ Widget desteği — existing
- ✓ Watch app desteği — existing
- ✓ Tema ve görünüm özelleştirme — existing
- ✓ Bildirim sistemi — existing
- ✓ Onboarding akışı — existing
- ✓ Design system (tipografi, renk, spacing, animasyon) — existing
- ✓ Pro/Free ayrımı altyapısı (ProManager) — existing
- ✓ Gizlilik ve veri dışa aktarma — existing
- ✓ StoreKit 2 IAP entegrasyonu ($19.99/yr + $39.99 lifetime) — Phase 1
- ✓ Contextual paywall triggers (habit limit, sleep, social, achievements) — Phase 1
- ✓ Subscription management in Settings — Phase 1
- ✓ Security hardening (screenshotMode #if DEBUG, fatalError removed) — Phase 1
- ✓ Platform activation (iCloud, HealthKit, Push entitlements + UI) — Phase 1
- ✓ Referral sistemi (kod üretme, paylaşma, redemption, CloudKit tracking) — Phase 2
- ✓ Referrer Pro ödülü (on-launch check, max 4 stack / 28 gün cap) — Phase 2

- ✓ App Store metadata (EN+TR descriptions, keywords, subtitles, promotional text) — Phase 3
- ✓ ASO optimization (keyword research, character limits, no repetition) — Phase 3
- ✓ App Store screenshots (24 composed: 6 screens x 2 langs x 2 sizes) — Phase 3
- ✓ Custom Product Pages (Fitness, Productivity, Sleep) documented — Phase 3
- ✓ Legal URLs (privacy + terms) linked in-app and web-ready — Phase 3
- ✓ App icon verified (light, dark, tinted variants) — Phase 3
- ✓ AvatarView component (initials in gradient circles, replaces emoji) — Phase 3

- ✓ HLLogger with os.Logger — production logging (5 categories: app, storekit, cloudkit, healthkit, data) — Phase 4
- ✓ Debug bypass cleanup — all screenshotMode wrapped in #if DEBUG, 0 fatalError — Phase 4
- ✓ 28 print() replaced with structured os_log logging — Phase 4
- ✓ HLSheetContent modifier — premium spring transitions on all 32 sheet sites — Phase 4
- ✓ UI edge cases — habit name truncation, sleep empty state, dark mode — Phase 4
- ✓ Release build verified, automated quality audit passed — Phase 4

### Active

- [ ] Streak milestone'larında pro nudge (7 gün streak kutlama + teşvik)
- [ ] Sleep tab'da lock badge (tab bar'da kilit ikonu, tıklayınca blurred pro gate)
- [ ] Paywall'da daha güçlü CTA ve net değer teklifi
- [ ] Profile ekranında belirgin "Upgrade to Pro" CTA

### Out of Scope

- Android versiyonu — iOS-first, sonraki milestone'da değerlendirilecek
- Backend/server altyapısı — CloudKit kullanılıyor, custom backend gereksiz
- Yapay zeka tabanlı coaching — karmaşıklık ve maliyet nedeniyle ertelendi

## Current Milestone: v1.1 Pro Growth & Conversion

**Goal:** Pro dönüşüm oranını artırmak — referral sistemi iyileştirmesi, doğal pro nudge'lar ve daha görünür upgrade CTA'ları

**Target features:**
- Streak milestone'larında pro nudge (7 gün streak kutlama + teşvik)
- Sleep tab'da lock badge (tab bar'da kilit ikonu, tıklayınca blurred pro gate)
- Paywall'da daha güçlü CTA ve net değer teklifi
- Profile ekranında belirgin "Upgrade to Pro" CTA

## Context

- Apple Developer hesabı aktif — iCloud, HealthKit, Push enabled
- v1.0 milestone tamamlandı: StoreKit 2 IAP, referral sistemi, ASO, quality hardening
- Mevcut referral altyapısı var (6 haneli kod, CloudKit tracking, 1 hafta pro reward)
- Pro CTA'lar şu an pasif — sadece Settings'te upgrade butonu, kilitli içerik blur'lu
- Codebase olgun: 50+ Swift dosyası, design system, component library, test altyapısı
- Gamification güçlü: streak, rozet, XP, seviye sistemi, leaderboard

## Constraints

- **Platform**: iOS 17+ only, SwiftUI + SwiftData
- **Backend**: CloudKit only — no custom server
- **Developer Account**: Active — iCloud/HealthKit/Push enabled
- **Monetization**: Apple IAP only (StoreKit 2)
- **Language**: Swift 5.0, no third-party dependencies (pure Apple stack)

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Pure Apple stack (no 3rd party deps) | Maintenance simplicity, Apple review compatibility | ✓ Good |
| CloudKit for social features | No backend cost, Apple ecosystem native | — Pending |
| Gamification as core differentiator | Rakiplerden farklılaşma (Streaks=minimal, Habitica=RPG, Fabulous=coaching) | — Pending |
| Pain point marketing approach | Kullanıcıya duygusal dokunuş, dönüşüm oranını artırma | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd:transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd:complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-03-25 after milestone v1.1 start*

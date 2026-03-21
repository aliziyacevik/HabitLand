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

### Active
- [ ] App Store hazırlığı (metadata, screenshots, açıklama, icon finalizasyonu)
- [ ] ASO (App Store Optimization) — anahtar kelime, açıklama, screenshot optimizasyonu
- [ ] Performans ve bug temizliği (crash, yavaşlık, edge case'ler)
- [ ] UI/UX polish — genel kalite yükseltme
- [ ] Referral sistemi (arkadaş davet et, ödül kazan)
- [ ] Sosyal medya pazarlama stratejisi — pain point odaklı mesajlar
- [ ] iCloud sync aktifleştirme (Apple Developer hesabı onayı sonrası)
- [ ] HealthKit ve Push notification izinlerinin aktifleştirilmesi

### Out of Scope

- Android versiyonu — iOS-first, sonraki milestone'da değerlendirilecek
- Backend/server altyapısı — CloudKit kullanılıyor, custom backend gereksiz
- Yapay zeka tabanlı coaching — karmaşıklık ve maliyet nedeniyle ertelendi

## Context

- Apple Developer hesabı onay bekliyor — iCloud, HealthKit ve Push şu anda devre dışı
- ProManager ve StoreKit 2 altyapısı mevcut ama gerçek ürünlere bağlı değil
- Codebase olgun: 50+ Swift dosyası, design system, component library, test altyapısı
- Gamification güçlü: streak, rozet, XP, seviye sistemi, leaderboard
- Sosyal özellikler CloudKit public database üzerinden çalışıyor
- Pazarlama mesajı: kullanıcının duygusal noktasına dokunmak — "Alışkanlıklarını hep yarıda mı bırakıyorsun?", "Bu sefer farklı olacak"

## Constraints

- **Platform**: iOS 17+ only, SwiftUI + SwiftData
- **Backend**: CloudKit only — no custom server
- **Developer Account**: Pending approval — iCloud/HealthKit/Push disabled until then
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
*Last updated: 2026-03-21 after Phase 1 completion*

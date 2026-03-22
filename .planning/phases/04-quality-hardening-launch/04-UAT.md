---
status: partial
phase: 04-quality-hardening-launch
source: [04-01-SUMMARY.md, 04-02-SUMMARY.md, 04-03-SUMMARY.md]
started: 2026-03-22T10:00:00Z
updated: 2026-03-22T10:00:00Z
---

## Current Test

number: 1
name: Sheet Entrance Animation
expected: |
  Herhangi bir sheet açıldığında (örn. habit oluştur, settings'te bir detay) içerik hafif bir spring animasyonla yukarıdan kayarak gelir. Sert/ani açılma olmamalı.
awaiting: user response

## Tests

### 1. Sheet Entrance Animation
expected: Herhangi bir sheet açıldığında (örn. Create Habit, Settings detay) içerik hafif spring animasyonla yukarıdan kayarak gelir. Ani/sert açılma olmamalı.
result: [pending]

### 2. Long Habit Name Truncation
expected: Uzun isimli bir habit oluştur (30+ karakter). Habit listesinde ve detay ekranında isim max 2 satırda gösterilir, taşan kısmı "..." ile kesilir.
result: [pending]

### 3. Sleep Dashboard Empty State
expected: Sleep tab'ına git (henüz sleep verisi yoksa). Boş durumda moon.zzz.fill ikonu ve teşvik edici bir mesaj gösterilir.
result: [pending]

## Summary

total: 3
passed: 0
issues: 0
pending: 3
skipped: 0
blocked: 0

## Gaps

[none yet]

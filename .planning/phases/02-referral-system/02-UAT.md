---
status: partial
phase: 02-referral-system
source: [02-01-SUMMARY.md, 02-02-SUMMARY.md, 02-03-SUMMARY.md]
started: 2026-03-22T10:00:00Z
updated: 2026-03-22T10:00:00Z
---

## Current Test

number: 1
name: Referral Code Display
expected: |
  Social tab > Invite Friends ekranında kişisel referral kodun (HBT-XXXXXX formatında) görünmeli. Koda tıklayınca panoya kopyalanmalı ve bir toast/feedback gösterilmeli.
awaiting: user response

## Tests

### 1. Referral Code Display
expected: Social tab > Friends > Arkadaş Ekle butonuyla açılan sheet'te kişisel referral kodun (HBT-XXXXXX formatında) görünür. Koda tıklayınca panoya kopyalanır ve feedback gösterilir.
result: pass

### 2. Referral Share Link
expected: Invite Friends ekranındaki Share butonuna tıklayınca iOS share sheet açılır. Paylaşım mesajı Türkçe (veya İngilizce) ve referral kodunu içerir.
result: [pending]

### 3. Referral Stats Display
expected: Invite Friends ekranında referral istatistikleri (kaç kişi davet ettiğin) bölümü görünür.
result: [pending]

### 4. Referral Code Entry in Settings
expected: Settings > Account bölümünde "Enter Referral Code" (veya Türkçe karşılığı) satırı görünür. Tıklayınca referral kodu girme formu açılır.
result: [pending]

### 5. Onboarding Referral Sheet
expected: Onboarding tamamlanırken, starter habits seçiminden sonra referral kodu giriş sheet'i açılır. Skip ile geçilebilir.
result: [pending]

### 6. Challenge Share with Referral
expected: Social > Challenges ekranında bir challenge'ı paylaşırken share link ?ref= parametresi içerir.
result: [pending]

## Summary

total: 6
passed: 1
issues: 0
pending: 5
skipped: 0
blocked: 0

## Gaps

[none yet]

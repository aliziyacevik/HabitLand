# Product Findings — HabitLand v1.0

1. **Social tab is a dead end for Pro users** — Even after purchasing Pro, Social shows "Coming Soon" gate. Pro users paid but get no value from this feature area. This could drive refund requests.
2. **Auth screens exist but are unreachable** — Login/Register/ForgotPassword are fully built but not connected to any flow. Dead code that ships with the binary.
3. **Free tier limit (3 habits) is very restrictive** — Most habit apps allow 5-7 free habits. 3 feels punishing and may drive negative reviews.
4. **Share Profile does nothing** — Button exists on profile with no functionality. Broken promise.
5. **"See All" achievements button is empty** — Clicking does nothing. User expects navigation.
6. **Help Center / Contact Support / Rate buttons are non-functional** — Settings has 3 dead links.
7. **No data sync or backup** — Purely local SwiftData. If user deletes app, all data is lost forever. No iCloud sync, no export in a restorable format.
8. **Paywall shows hardcoded fallback prices** — PaywallView:131,140 shows "$39.99" and "$19.99" if StoreKit products fail to load. These could be wrong if prices change on App Store Connect.
9. **weekCompletionRate penalizes non-daily habits** — A Mon-Fri habit can never show more than 71% weekly rate, making insights misleading.
10. **Streak display drops to 0 before daily completion** — Users see streak reset to 0 each morning until they complete the habit, which is discouraging. Better pattern: show "(streak) — complete today to continue!"

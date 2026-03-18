# HabitLand — App Store Metadata

## App Name
HabitLand

## Subtitle (30 chars max)
Build Better Habits Daily

## Category
Primary: Health & Fitness
Secondary: Lifestyle

## Keywords (100 chars max)
habit,tracker,streak,goals,routine,daily,wellness,productivity,sleep,health,mindfulness,self-care

## Description
Build lasting habits with HabitLand — the beautifully designed habit tracker that makes self-improvement feel like a game.

**Track Your Habits**
Create custom habits with personalized icons, colors, and schedules. Track daily completions with satisfying animations and watch your progress grow.

**Stay Motivated with Streaks**
Build consecutive day streaks and see your commitment visualized with dynamic flame animations that grow stronger as your streak gets longer.

**Earn XP & Level Up**
Every completed habit earns you experience points. Level up from Seedling to Legend as you build consistency and unlock achievements along the way.

**See Your Progress**
Beautiful weekly charts and daily overviews show exactly how you're doing. Celebrate when you complete all your daily habits with a confetti celebration.

**Sleep Better**
Track your sleep patterns, see weekly trends, and get quality scores to help you optimize your rest.

**Compete with Friends**
Add friends, climb leaderboards, and challenge each other to stay consistent. Accountability made fun.

**HabitLand Pro unlocks:**
- Unlimited habits (free: up to 3)
- Advanced analytics & monthly insights
- Sleep tracking & quality analysis
- Social features — friends, leaderboard & challenges
- All achievements & badges
- Full customization — every icon & color
- Premium celebration effects

**Pricing:**
- Yearly: $19.99/year
- Lifetime: $39.99 one-time purchase (Best Deal!)

All your data stays on your device. No account required. No ads. Ever.

## Promotional Text (170 chars, can be updated without review)
Start building better habits today! Track streaks, earn XP, level up, and celebrate your progress with beautiful animations.

## What's New (Version 1.0)
Welcome to HabitLand! Your new home for building better habits.

- Create and track daily habits with beautiful UI
- Streak tracking with animated fire effects
- XP system with leveling (Seedling to Legend)
- Confetti celebrations for daily completions
- Sleep tracking and quality analysis
- Weekly progress charts and insights
- Friends, leaderboard & social challenges
- Swipe gestures for quick habit completion
- Drag & drop habit reordering
- Starter habit picker during onboarding
- Dark mode support
- Local notifications for habit reminders

## Support URL
https://<your-github-username>.github.io/HabitLand/support.html

## Privacy Policy URL
https://<your-github-username>.github.io/HabitLand/privacy.html

## Terms of Service URL
https://<your-github-username>.github.io/HabitLand/terms.html

## Marketing URL (optional)
https://<your-github-username>.github.io/HabitLand/

## Age Rating
4+ (No objectionable content)

## Copyright
(c) 2026 HabitLand

## App Store Screenshots

### Provided Sizes
- **6.7" (iPhone 15 Pro Max)**: 1290 x 2796 px — `AppStoreAssets/AppStore_6.7/`
- **5.5" (iPhone 8 Plus)**: 1242 x 2208 px — `AppStoreAssets/AppStore_5.5/`

### Screenshot Order (6 total)
| # | File | Headline | Feature Highlighted |
|---|------|----------|---------------------|
| 1 | 01_home_dashboard.png | Build Better Habits | Home dashboard with real app screenshot, progress ring, streaks, motivation card |
| 2 | 02_streaks_habits.png | Never Break a Streak | Habit list sorted by streak, flame icons, progress rings, FAB |
| 3 | 03_sleep_tracking.png | Sleep Better Tonight | Sleep duration, weekly bar chart, stats (avg/best/score) |
| 4 | 04_achievements_xp.png | Earn XP & Level Up | Profile with level, XP bar, stats, achievements list |
| 5 | 05_premium_pro.png | Unlock Everything | Paywall with feature list, Yearly vs Lifetime pricing |
| 6 | 06_social_leaderboard.png | Compete With Friends | Leaderboard with rankings, highlighted "You" entry |

### Regenerating Screenshots
Run `python3 AppStoreAssets/generate_screenshots.py` to regenerate all screenshots.
The script uses the raw simulator screenshot in `AppStoreAssets/Screenshots/raw_home.png` for screenshot #1.

## App Store Review Notes
- This app uses StoreKit 2 for in-app purchases (yearly subscription + lifetime non-consumable)
- No backend/server — all data is stored locally with SwiftData
- No third-party SDKs or analytics
- No user tracking or data collection
- App requires iOS 17.0+

## In-App Purchases for App Store Connect
| Reference Name | Product ID | Type | Price |
|---------------|-----------|------|-------|
| HabitLand Pro Yearly | com.habitland.pro.yearly | Auto-Renewable Subscription | $19.99/year |
| HabitLand Pro Lifetime | com.habitland.pro.lifetime | Non-Consumable | $39.99 |

### Subscription Group
Name: HabitLand Pro
Products: com.habitland.pro.yearly

## Checklist Before Submission

- [x] App icon (1024x1024) in Assets.xcassets
- [x] Screenshots for 6.7" and 5.5"
- [x] App name, subtitle, keywords, description
- [x] Privacy policy (in-app + needs hosted URL)
- [x] Terms of use (in-app + needs hosted URL)
- [x] PrivacyInfo.xcprivacy manifest
- [x] Deployment target iOS 17.0
- [x] ITSAppUsesNonExemptEncryption = NO
- [x] StoreKit configuration file
- [x] Age rating: 4+
- [x] Unit tests passing (38/38)
- [x] Accessibility labels on key interactive elements
- [x] Privacy Policy, Terms, Support pages created (docs/)
- [ ] Apple Developer account approved
- [ ] Push repo to GitHub and enable GitHub Pages (Settings > Pages > Source: main, /docs)
- [ ] Update URLs in this file with actual GitHub username
- [ ] Bundle ID registered in App Store Connect
- [ ] App Store Connect listing created
- [ ] StoreKit products created in App Store Connect
- [ ] TestFlight build uploaded and tested
- [ ] Archive & upload via Xcode
- [ ] Submit for review

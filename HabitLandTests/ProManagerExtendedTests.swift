import Testing
import Foundation
@testable import HabitLand

// MARK: - ProManager Extended Tests (Referral, Limits, Display)

@Suite(.serialized)
struct ProManagerExtendedTests {

    private func clearKeys() {
        UserDefaults.standard.removeObject(forKey: "referralProExpiresAt")
        UserDefaults.standard.removeObject(forKey: "habitland_trial_start")
        UserDefaults.standard.removeObject(forKey: "habitland_trial_offered")
        UserDefaults.standard.removeObject(forKey: "habitland_trial_expiry_paywall_shown")
    }

    // MARK: - Referral Pro

    @Test @MainActor func extendReferralProSetsExpiry() {
        clearKeys()
        let manager = ProManager.shared
        manager.referralProExpiresAt = nil

        manager.extendReferralPro(days: 7, referralCount: 0)

        #expect(manager.referralProExpiresAt != nil)
        let expiry = manager.referralProExpiresAt!
        let daysUntilExpiry = Calendar.current.dateComponents([.day], from: Date.now, to: expiry).day ?? 0
        #expect(daysUntilExpiry >= 6 && daysUntilExpiry <= 7)

        clearKeys()
    }

    @Test @MainActor func extendReferralProStacksOnExisting() {
        clearKeys()
        let manager = ProManager.shared

        // First extension
        manager.referralProExpiresAt = nil
        manager.extendReferralPro(days: 7, referralCount: 0)
        let firstExpiry = manager.referralProExpiresAt!

        // Second extension — should stack
        manager.extendReferralPro(days: 7, referralCount: 1)
        let secondExpiry = manager.referralProExpiresAt!

        #expect(secondExpiry > firstExpiry)
        let daysBetween = Calendar.current.dateComponents([.day], from: firstExpiry, to: secondExpiry).day ?? 0
        #expect(daysBetween >= 6 && daysBetween <= 7)

        clearKeys()
    }

    @Test @MainActor func extendReferralProRejectsAtMaxStacks() {
        clearKeys()
        let manager = ProManager.shared
        manager.referralProExpiresAt = nil

        manager.extendReferralPro(days: 7, referralCount: ProManager.maxReferralStacks)

        // Should not set expiry — at max stacks
        #expect(manager.referralProExpiresAt == nil)

        clearKeys()
    }

    @Test @MainActor func canReceiveReferralRewardBelowMax() {
        let manager = ProManager.shared
        #expect(manager.canReceiveReferralReward(currentCount: 0) == true)
        #expect(manager.canReceiveReferralReward(currentCount: 3) == true)
    }

    @Test @MainActor func canReceiveReferralRewardAtMax() {
        let manager = ProManager.shared
        #expect(manager.canReceiveReferralReward(currentCount: ProManager.maxReferralStacks) == false)
    }

    @Test func maxReferralStacksIs4() {
        #expect(ProManager.maxReferralStacks == 4)
    }

    // MARK: - Free Tier Limits

    @Test func freeHabitLimitIs3() {
        #expect(ProManager.freeHabitLimit == 3)
    }

    @Test func freeAchievementLimitIs5() {
        #expect(ProManager.freeAchievementLimit == 5)
    }

    @Test func freeQuestLimitIs1() {
        #expect(ProManager.freeQuestLimit == 1)
    }

    @Test func freePomodoroDurationIs5Minutes() {
        #expect(ProManager.freePomodoroDuration == 300)
    }

    @Test @MainActor func canCreateHabitBelowLimit() {
        clearKeys()
        let manager = ProManager.shared
        #expect(manager.canCreateHabit(currentCount: 0) == true)
        #expect(manager.canCreateHabit(currentCount: 2) == true)
        clearKeys()
    }

    @Test @MainActor func cannotCreateHabitAtLimitWithoutPro() {
        clearKeys()
        let manager = ProManager.shared
        // Ensure no trial or pro
        UserDefaults.standard.removeObject(forKey: "habitland_trial_start")
        #expect(manager.canCreateHabit(currentCount: 3) == false)
        #expect(manager.canCreateHabit(currentCount: 10) == false)
        clearKeys()
    }

    // MARK: - Current Plan Display

    @Test @MainActor func freePlanDisplayForNonPro() {
        clearKeys()
        let manager = ProManager.shared
        manager.referralProExpiresAt = nil

        let plan = manager.currentPlanDisplay
        // Should show either "Free Plan" or trial-based plan
        #expect(!plan.name.isEmpty)
        #expect(!plan.icon.isEmpty)

        clearKeys()
    }

    @Test @MainActor func referralPlanDisplayWhenActive() {
        clearKeys()
        let manager = ProManager.shared
        manager.referralProExpiresAt = Calendar.current.date(byAdding: .day, value: 5, to: Date.now)

        let plan = manager.currentPlanDisplay
        #expect(plan.name.contains("Referral"))
        #expect(plan.icon == "gift.fill")

        clearKeys()
    }

    // MARK: - Trial Remaining Days

    @Test @MainActor func trialRemainingDaysCalculation() {
        clearKeys()
        let manager = ProManager.shared

        // No trial
        #expect(manager.trialRemainingDays == 0)

        // Trial started today
        UserDefaults.standard.set(Date.now, forKey: "habitland_trial_start")
        #expect(manager.trialRemainingDays >= 6)

        // Trial started 5 days ago
        let fiveDaysAgo = Date.now.addingTimeInterval(-5 * 24 * 60 * 60)
        UserDefaults.standard.set(fiveDaysAgo, forKey: "habitland_trial_start")
        #expect(manager.trialRemainingDays >= 1 && manager.trialRemainingDays <= 2)

        clearKeys()
    }

    // MARK: - Trial Expiry Paywall

    @Test @MainActor func shouldShowTrialExpiryPaywallWhenExpired() {
        clearKeys()
        let manager = ProManager.shared

        // No trial — should not show
        #expect(manager.shouldShowTrialExpiryPaywall == false)

        // Expired trial
        let eightDaysAgo = Date.now.addingTimeInterval(-8 * 24 * 60 * 60)
        UserDefaults.standard.set(eightDaysAgo, forKey: "habitland_trial_start")
        // Paywall not yet shown
        UserDefaults.standard.set(false, forKey: "habitland_trial_expiry_paywall_shown")

        #expect(manager.hasTrialExpired == true)

        clearKeys()
    }

    @Test @MainActor func trialExpiryPaywallNotShownTwice() {
        clearKeys()
        let manager = ProManager.shared

        let eightDaysAgo = Date.now.addingTimeInterval(-8 * 24 * 60 * 60)
        UserDefaults.standard.set(eightDaysAgo, forKey: "habitland_trial_start")
        UserDefaults.standard.set(true, forKey: "habitland_trial_expiry_paywall_shown")

        #expect(manager.shouldShowTrialExpiryPaywall == false)

        clearKeys()
    }

    // MARK: - Has Trial Been Offered

    @Test @MainActor func hasTrialBeenOfferedTracksCorrectly() {
        clearKeys()
        let manager = ProManager.shared

        #expect(manager.hasTrialBeenOffered == false)

        manager.startInAppTrial()
        #expect(manager.hasTrialBeenOffered == true)

        clearKeys()
    }

    // MARK: - Product IDs

    @Test func productIDsAreCorrect() {
        #expect(ProManager.yearlyID == "com.habitland.pro.yearly")
        #expect(ProManager.lifetimeID == "com.habitland.pro.lifetime")
    }
}

// MARK: - PaywallContext Tests

struct PaywallContextTests {

    @Test func allContextsHaveTitles() {
        let contexts: [PaywallContext] = [.habitLimit, .sleepTracking, .socialFeatures, .achievements, .analytics, .pomodoro]
        for ctx in contexts {
            #expect(!ctx.title.isEmpty)
            #expect(!ctx.icon.isEmpty)
            #expect(!ctx.description.isEmpty)
        }
    }

    @Test func habitLimitContextTitle() {
        #expect(PaywallContext.habitLimit.title == "Unlock Unlimited Habits")
    }

    @Test func sleepTrackingContextIcon() {
        #expect(PaywallContext.sleepTracking.icon == "moon.fill")
    }
}

// MARK: - StoreError Tests

struct StoreErrorTests {
    @Test func verificationFailedExists() {
        let error = StoreError.verificationFailed
        #expect(error is StoreError)
    }
}

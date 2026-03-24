import Testing
import Foundation
@testable import HabitLand

// MARK: - HLHaptics Tests

struct HLHapticsTests {

    @Test func hapticsEnabledByDefault() {
        // When key doesn't exist, haptics should be enabled (nil → true)
        let key = "habit_hapticFeedback"
        let original = UserDefaults.standard.object(forKey: key)

        UserDefaults.standard.removeObject(forKey: key)
        // isEnabled is private, but we can test that calling haptic functions doesn't crash
        HLHaptics.light()
        HLHaptics.medium()
        HLHaptics.heavy()
        HLHaptics.success()
        HLHaptics.warning()
        HLHaptics.selection()

        // Restore
        if let orig = original {
            UserDefaults.standard.set(orig, forKey: key)
        }
    }

    @Test func hapticsCanBeDisabled() {
        let key = "habit_hapticFeedback"
        let original = UserDefaults.standard.object(forKey: key)

        UserDefaults.standard.set(false, forKey: key)
        // Should not crash even when disabled
        HLHaptics.light()
        HLHaptics.success()
        HLHaptics.completionSuccess()
        HLHaptics.achievementUnlocked()

        // Restore
        if let orig = original {
            UserDefaults.standard.set(orig, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    @Test func completionSuccessDoesNotCrash() {
        HLHaptics.completionSuccess()
    }

    @Test func achievementUnlockedDoesNotCrash() {
        HLHaptics.achievementUnlocked()
    }
}

// MARK: - HLAnimation Tests

struct HLAnimationTests {

    @Test func animationPresetsExist() {
        // Verify all animation presets are accessible without crash
        let _ = HLAnimation.microSpring
        let _ = HLAnimation.gentleSpring
        let _ = HLAnimation.fadeIn
        let _ = HLAnimation.slideIn
        let _ = HLAnimation.progressFill
        let _ = HLAnimation.ringGlow
        let _ = HLAnimation.celebration
        let _ = HLAnimation.shimmerLoop
        let _ = HLAnimation.sheetContentAppear
    }
}

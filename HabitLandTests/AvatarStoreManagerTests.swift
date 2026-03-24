import Testing
import Foundation
@testable import HabitLand

// MARK: - AvatarStoreManager Unlock Logic Tests

struct AvatarStoreManagerUnlockTests {

    // MARK: - Initial Avatar

    @Test @MainActor func initialAvatarAlwaysUnlocked() {
        let manager = AvatarStoreManager.shared
        #expect(manager.isAvatarUnlocked(.initial, userLevel: 0) == true)
        #expect(manager.isAvatarUnlocked(.initial, userLevel: 1) == true)
        #expect(manager.isAvatarUnlocked(.initial, userLevel: 100) == true)
    }

    @Test @MainActor func initialAvatarNoUnlockReason() {
        let manager = AvatarStoreManager.shared
        #expect(manager.unlockReason(.initial, userLevel: 0) == nil)
    }

    // MARK: - Animal Avatars Level Unlock

    @Test @MainActor func foxUnlocksAtLevel5() {
        let manager = AvatarStoreManager.shared
        // Fox requires level 5
        let lockedResult = manager.isAvatarUnlocked(.animal(.fox), userLevel: 4)
        let unlockedResult = manager.isAvatarUnlocked(.animal(.fox), userLevel: 5)

        // Without purchase, level-based unlock
        if !manager.isAvatarUnlocked(.animal(.fox), userLevel: 0) {
            // Animals not purchased via IAP, so level-based check applies
            #expect(lockedResult == false)
            #expect(unlockedResult == true)
        }
    }

    @Test @MainActor func owlUnlocksAtLevel10() {
        let manager = AvatarStoreManager.shared
        if !manager.isAvatarUnlocked(.animal(.owl), userLevel: 0) {
            #expect(manager.isAvatarUnlocked(.animal(.owl), userLevel: 9) == false)
            #expect(manager.isAvatarUnlocked(.animal(.owl), userLevel: 10) == true)
        }
    }

    // MARK: - Frame Avatars Level Unlock

    @Test @MainActor func crownUnlocksAtLevel15() {
        let manager = AvatarStoreManager.shared
        if !manager.isAvatarUnlocked(.frame(.crown), userLevel: 0) {
            #expect(manager.isAvatarUnlocked(.frame(.crown), userLevel: 14) == false)
            #expect(manager.isAvatarUnlocked(.frame(.crown), userLevel: 15) == true)
        }
    }

    // MARK: - Unlock Reason Strings

    @Test @MainActor func foxUnlockReasonShowsLevel5() {
        let manager = AvatarStoreManager.shared
        if !manager.isAvatarUnlocked(.animal(.fox), userLevel: 0) {
            let reason = manager.unlockReason(.animal(.fox), userLevel: 0)
            #expect(reason == "Level 5")
        }
    }

    @Test @MainActor func owlUnlockReasonShowsLevel10() {
        let manager = AvatarStoreManager.shared
        if !manager.isAvatarUnlocked(.animal(.owl), userLevel: 0) {
            let reason = manager.unlockReason(.animal(.owl), userLevel: 0)
            #expect(reason == "Level 10")
        }
    }

    @Test @MainActor func crownUnlockReasonShowsLevel15() {
        let manager = AvatarStoreManager.shared
        if !manager.isAvatarUnlocked(.frame(.crown), userLevel: 0) {
            let reason = manager.unlockReason(.frame(.crown), userLevel: 0)
            #expect(reason == "Level 15")
        }
    }

    @Test @MainActor func unlockedAvatarHasNilReason() {
        let manager = AvatarStoreManager.shared
        // Initial is always unlocked
        #expect(manager.unlockReason(.initial, userLevel: 0) == nil)
    }

    // MARK: - Product IDs

    @Test func animalsPackID() {
        #expect(AvatarStoreManager.animalsPackID == "com.azc.HabitLand.avatar.animals")
    }

    @Test func framesPackID() {
        #expect(AvatarStoreManager.framesPackID == "com.azc.HabitLand.avatar.frames")
    }

    // MARK: - Non-Level Animals Show Price

    @Test @MainActor func nonLevelAnimalShowsPrice() {
        let manager = AvatarStoreManager.shared
        // Bears, pandas, etc. don't have level-based unlock
        if !manager.isAvatarUnlocked(.animal(.bear), userLevel: 100) {
            let reason = manager.unlockReason(.animal(.bear), userLevel: 100)
            // Should show price string
            #expect(reason != nil)
        }
    }
}

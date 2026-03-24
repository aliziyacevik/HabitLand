import Testing
import Foundation
@testable import HabitLand

// MARK: - ReviewManager Tests

@Suite(.serialized)
struct ReviewManagerTests {

    private let completionCountKey = "review_completionsSinceLastPrompt"
    private let lastPromptDateKey = "review_lastPromptDate"

    private func clearKeys() {
        UserDefaults.standard.removeObject(forKey: completionCountKey)
        UserDefaults.standard.removeObject(forKey: lastPromptDateKey)
    }

    // MARK: - Track Completion

    @Test func trackCompletionIncrementsCounter() {
        clearKeys()

        ReviewManager.trackCompletion()
        #expect(UserDefaults.standard.integer(forKey: completionCountKey) == 1)

        ReviewManager.trackCompletion()
        #expect(UserDefaults.standard.integer(forKey: completionCountKey) == 2)

        ReviewManager.trackCompletion()
        #expect(UserDefaults.standard.integer(forKey: completionCountKey) == 3)

        clearKeys()
    }

    @Test func trackCompletionStartsFromZero() {
        clearKeys()

        let initial = UserDefaults.standard.integer(forKey: completionCountKey)
        #expect(initial == 0)

        ReviewManager.trackCompletion()
        #expect(UserDefaults.standard.integer(forKey: completionCountKey) == 1)

        clearKeys()
    }

    // MARK: - Request If Appropriate

    @Test func requestIfAppropriateSkipsWhenTooFewCompletions() {
        clearKeys()

        // Set only 5 completions (need 15)
        UserDefaults.standard.set(5, forKey: completionCountKey)

        ReviewManager.requestIfAppropriate()

        // Counter should remain unchanged (guard returned early)
        #expect(UserDefaults.standard.integer(forKey: completionCountKey) == 5)

        clearKeys()
    }

    @Test func requestIfAppropriateSkipsWhenRecentPrompt() {
        clearKeys()

        // Set enough completions
        UserDefaults.standard.set(20, forKey: completionCountKey)
        // But prompted recently (10 days ago, need 60)
        let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        UserDefaults.standard.set(tenDaysAgo, forKey: lastPromptDateKey)

        ReviewManager.requestIfAppropriate()

        // Counter should remain — guard returned early
        #expect(UserDefaults.standard.integer(forKey: completionCountKey) == 20)

        clearKeys()
    }

    @Test func requestIfAppropriateResetsCounterWhenEligible() {
        clearKeys()

        // Set enough completions and no recent prompt
        UserDefaults.standard.set(20, forKey: completionCountKey)
        // Prompted 90 days ago (> 60 days minimum)
        let ninetyDaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: Date())!
        UserDefaults.standard.set(ninetyDaysAgo, forKey: lastPromptDateKey)

        ReviewManager.requestIfAppropriate()

        // Counter should be reset to 0
        #expect(UserDefaults.standard.integer(forKey: completionCountKey) == 0)
        // Last prompt date should be updated
        let lastPrompt = UserDefaults.standard.object(forKey: lastPromptDateKey) as? Date
        #expect(lastPrompt != nil)

        clearKeys()
    }

    @Test func requestIfAppropriateWorksWithNoLastPromptDate() {
        clearKeys()

        // Set enough completions, no previous prompt
        UserDefaults.standard.set(15, forKey: completionCountKey)

        ReviewManager.requestIfAppropriate()

        // Should proceed and reset counter
        #expect(UserDefaults.standard.integer(forKey: completionCountKey) == 0)

        clearKeys()
    }
}

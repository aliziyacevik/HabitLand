import StoreKit
import UIKit

enum ReviewManager {
    private static let completionCountKey = "review_completionsSinceLastPrompt"
    private static let lastPromptDateKey = "review_lastPromptDate"
    private static let minCompletionsBeforePrompt = 15
    private static let minDaysBetweenPrompts = 60

    /// Call after positive moments (achievement unlock, streak milestone)
    static func requestIfAppropriate() {
        let lastPrompt = UserDefaults.standard.object(forKey: lastPromptDateKey) as? Date
        if let lastPrompt, Calendar.current.dateComponents([.day], from: lastPrompt, to: Date()).day ?? 0 < minDaysBetweenPrompts {
            return
        }

        let completions = UserDefaults.standard.integer(forKey: completionCountKey)
        guard completions >= minCompletionsBeforePrompt else { return }

        // Reset counter and record prompt date
        UserDefaults.standard.set(0, forKey: completionCountKey)
        UserDefaults.standard.set(Date(), forKey: lastPromptDateKey)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }

    /// Track habit completions toward next review prompt
    static func trackCompletion() {
        let current = UserDefaults.standard.integer(forKey: completionCountKey)
        UserDefaults.standard.set(current + 1, forKey: completionCountKey)
    }
}

import CloudKit
import SwiftData
import SwiftUI

// MARK: - CloudKit Manager

@MainActor
final class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()

    private let container = CKContainer(identifier: "iCloud.azc.HabitLand")
    private var publicDB: CKDatabase { container.publicCloudDatabase }

    @Published var iCloudAvailable = false
    @Published var currentUserRecordID: CKRecord.ID?
    @Published var pendingRequests: [FriendRequest] = []
    @Published var isLoading = false

    // MARK: - Record Types

    enum RecordType {
        static let userProfile = "SocialProfile"
        static let friendRequest = "FriendRequest"
        static let challenge = "SocialChallenge"
        static let challengeParticipant = "ChallengeParticipant"
        static let nudge = "Nudge"
    }

    // MARK: - Init

    private init() {
        Task { await checkiCloudStatus() }
    }

    // MARK: - iCloud Status

    func checkiCloudStatus() async {
        do {
            let status = try await container.accountStatus()
            iCloudAvailable = status == .available
            if iCloudAvailable {
                await fetchCurrentUser()
            }
        } catch {
            iCloudAvailable = false
            print("CloudKit status check failed: \(error)")
        }
    }

    private func fetchCurrentUser() async {
        do {
            let recordID = try await container.userRecordID()
            currentUserRecordID = recordID
        } catch {
            print("Failed to fetch user record ID: \(error)")
        }
    }

    // MARK: - Publish Profile

    /// Upserts the local UserProfile to CloudKit public database
    func publishProfile(_ profile: UserProfile) async {
        guard let userID = currentUserRecordID else { return }

        let recordID = CKRecord.ID(recordName: userID.recordName, zoneID: .default)
        let record: CKRecord

        // Try fetching existing record first
        do {
            record = try await publicDB.record(for: recordID)
        } catch {
            record = CKRecord(recordType: RecordType.userProfile, recordID: recordID)
        }

        record["username"] = profile.username as CKRecordValue
        record["name"] = profile.name as CKRecordValue
        record["avatarEmoji"] = profile.avatarEmoji as CKRecordValue
        record["level"] = profile.level as CKRecordValue
        record["xp"] = profile.xp as CKRecordValue
        record["bio"] = profile.bio as CKRecordValue

        do {
            try await publicDB.save(record)
        } catch {
            print("Failed to publish profile: \(error)")
        }
    }

    /// Update streak & daily stats for leaderboard
    func publishStats(streak: Int, totalCompletions: Int, habitsCompletedToday: Int) async {
        guard let userID = currentUserRecordID else { return }

        let recordID = CKRecord.ID(recordName: userID.recordName, zoneID: .default)

        do {
            let record = try await publicDB.record(for: recordID)
            record["currentStreak"] = streak as CKRecordValue
            record["totalCompletions"] = totalCompletions as CKRecordValue
            record["habitsCompletedToday"] = habitsCompletedToday as CKRecordValue
            record["lastActive"] = Date() as CKRecordValue
            try await publicDB.save(record)
        } catch {
            print("Failed to publish stats: \(error)")
        }
    }

    // MARK: - Search Users

    func searchUsers(username: String) async -> [CKRecord] {
        let predicate = NSPredicate(format: "username BEGINSWITH[c] %@", username)
        let query = CKQuery(recordType: RecordType.userProfile, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "username", ascending: true)]

        do {
            let (results, _) = try await publicDB.records(matching: query, resultsLimit: 20)
            return results.compactMap { try? $0.1.get() }
                .filter { $0.recordID != currentUserRecordID }
        } catch {
            print("Search failed: \(error)")
            return []
        }
    }

    // MARK: - Friend Requests

    func sendFriendRequest(to targetRecordName: String) async -> Bool {
        guard let userID = currentUserRecordID else { return false }

        let record = CKRecord(recordType: RecordType.friendRequest)
        record["fromUserID"] = userID.recordName as CKRecordValue
        record["toUserID"] = targetRecordName as CKRecordValue
        record["status"] = "pending" as CKRecordValue
        record["sentAt"] = Date() as CKRecordValue

        do {
            try await publicDB.save(record)
            return true
        } catch {
            print("Failed to send friend request: \(error)")
            return false
        }
    }

    func fetchPendingRequests() async {
        guard let userID = currentUserRecordID else { return }

        let predicate = NSPredicate(format: "toUserID == %@ AND status == %@",
                                    userID.recordName, "pending")
        let query = CKQuery(recordType: RecordType.friendRequest, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "sentAt", ascending: false)]

        do {
            let (results, _) = try await publicDB.records(matching: query, resultsLimit: 50)
            let records = results.compactMap { try? $0.1.get() }

            // Fetch sender profiles
            var requests: [FriendRequest] = []
            for record in records {
                guard let fromUserID = record["fromUserID"] as? String else { continue }

                let profileID = CKRecord.ID(recordName: fromUserID)
                if let profile = try? await publicDB.record(for: profileID) {
                    requests.append(FriendRequest(
                        recordID: record.recordID,
                        fromUserID: fromUserID,
                        fromName: profile["name"] as? String ?? "Unknown",
                        fromUsername: profile["username"] as? String ?? "",
                        fromEmoji: profile["avatarEmoji"] as? String ?? "😊",
                        fromLevel: profile["level"] as? Int ?? 1,
                        sentAt: record["sentAt"] as? Date ?? Date()
                    ))
                }
            }
            pendingRequests = requests
        } catch {
            print("Failed to fetch pending requests: \(error)")
        }
    }

    func acceptFriendRequest(_ request: FriendRequest, context: ModelContext) async -> Bool {
        guard let userID = currentUserRecordID else { return false }

        // Update CK record status
        do {
            let record = try await publicDB.record(for: request.recordID)
            record["status"] = "accepted" as CKRecordValue
            try await publicDB.save(record)
        } catch {
            print("Failed to accept request: \(error)")
            return false
        }

        // Create reverse friendship record
        let reverseRecord = CKRecord(recordType: RecordType.friendRequest)
        reverseRecord["fromUserID"] = userID.recordName as CKRecordValue
        reverseRecord["toUserID"] = request.fromUserID as CKRecordValue
        reverseRecord["status"] = "accepted" as CKRecordValue
        reverseRecord["sentAt"] = Date() as CKRecordValue
        do {
            try await publicDB.save(reverseRecord)
        } catch {
            print("Failed to save reverse friendship: \(error)")
        }

        // Create local Friend entry
        let friend = Friend(
            name: request.fromName,
            username: request.fromUsername,
            avatarEmoji: request.fromEmoji,
            level: request.fromLevel
        )
        friend.cloudKitRecordName = request.fromUserID
        context.insert(friend)
        do {
            try context.save()
        } catch {
            print("Failed to save friend locally: \(error)")
            return false
        }

        // Remove from pending
        pendingRequests.removeAll { $0.recordID == request.recordID }

        return true
    }

    func declineFriendRequest(_ request: FriendRequest) async {
        do {
            let record = try await publicDB.record(for: request.recordID)
            record["status"] = "declined" as CKRecordValue
            try await publicDB.save(record)
            pendingRequests.removeAll { $0.recordID == request.recordID }
        } catch {
            print("Failed to decline request: \(error)")
        }
    }

    // MARK: - Sync Friend Data

    /// Fetches latest stats for all friends from CloudKit
    func syncFriendData(friends: [Friend], context: ModelContext) async {
        for friend in friends {
            guard let ckName = friend.cloudKitRecordName else { continue }
            let recordID = CKRecord.ID(recordName: ckName)

            do {
                let record = try await publicDB.record(for: recordID)
                friend.level = record["level"] as? Int ?? friend.level
                friend.currentStreak = record["currentStreak"] as? Int ?? friend.currentStreak
                friend.name = record["name"] as? String ?? friend.name
                friend.avatarEmoji = record["avatarEmoji"] as? String ?? friend.avatarEmoji
                friend.lastActive = record["lastActive"] as? Date
                friend.totalCompletions = record["totalCompletions"] as? Int ?? 0
                friend.habitsCompletedToday = record["habitsCompletedToday"] as? Int ?? 0
                friend.xp = record["xp"] as? Int ?? 0
            } catch {
                print("Failed to sync friend \(friend.name): \(error)")
            }
        }
        try? context.save()
    }

    // MARK: - Nudge

    func sendNudge(to friendRecordName: String, message: String) async -> Bool {
        guard let userID = currentUserRecordID else { return false }

        let record = CKRecord(recordType: RecordType.nudge)
        record["fromUserID"] = userID.recordName as CKRecordValue
        record["toUserID"] = friendRecordName as CKRecordValue
        record["message"] = message as CKRecordValue
        record["sentAt"] = Date() as CKRecordValue
        record["isRead"] = false as CKRecordValue

        do {
            try await publicDB.save(record)
            return true
        } catch {
            print("Failed to send nudge: \(error)")
            return false
        }
    }

    func fetchNudges() async -> [NudgeMessage] {
        guard let userID = currentUserRecordID else { return [] }

        let predicate = NSPredicate(format: "toUserID == %@ AND isRead == %@",
                                    userID.recordName, NSNumber(value: false))
        let query = CKQuery(recordType: RecordType.nudge, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "sentAt", ascending: false)]

        do {
            let (results, _) = try await publicDB.records(matching: query, resultsLimit: 20)
            let records = results.compactMap { try? $0.1.get() }

            var nudges: [NudgeMessage] = []
            for record in records {
                guard let fromUserID = record["fromUserID"] as? String else { continue }
                let profileID = CKRecord.ID(recordName: fromUserID)
                let senderName: String
                if let profile = try? await publicDB.record(for: profileID) {
                    senderName = profile["name"] as? String ?? "A friend"
                } else {
                    senderName = "A friend"
                }

                nudges.append(NudgeMessage(
                    recordID: record.recordID,
                    fromName: senderName,
                    message: record["message"] as? String ?? "",
                    sentAt: record["sentAt"] as? Date ?? Date()
                ))
            }
            return nudges
        } catch {
            print("Failed to fetch nudges: \(error)")
            return []
        }
    }

    func markNudgeRead(_ nudge: NudgeMessage) async {
        do {
            let record = try await publicDB.record(for: nudge.recordID)
            record["isRead"] = true as CKRecordValue
            try await publicDB.save(record)
        } catch {
            print("Failed to mark nudge read: \(error)")
        }
    }

    // MARK: - Challenges

    func createChallenge(name: String, description: String, icon: String,
                         durationDays: Int, habitCategory: String) async -> CKRecord? {
        guard let userID = currentUserRecordID else { return nil }

        let record = CKRecord(recordType: RecordType.challenge)
        record["name"] = name as CKRecordValue
        record["description"] = description as CKRecordValue
        record["icon"] = icon as CKRecordValue
        record["creatorID"] = userID.recordName as CKRecordValue
        record["startDate"] = Date() as CKRecordValue
        record["endDate"] = Date().addingTimeInterval(Double(durationDays) * 86400) as CKRecordValue
        record["habitCategory"] = habitCategory as CKRecordValue
        record["isActive"] = true as CKRecordValue

        do {
            let saved = try await publicDB.save(record)

            // Auto-join as participant
            await joinChallenge(challengeRecordName: saved.recordID.recordName)

            return saved
        } catch {
            print("Failed to create challenge: \(error)")
            return nil
        }
    }

    func joinChallenge(challengeRecordName: String) async {
        guard let userID = currentUserRecordID else { return }

        let record = CKRecord(recordType: RecordType.challengeParticipant)
        record["challengeID"] = challengeRecordName as CKRecordValue
        record["userID"] = userID.recordName as CKRecordValue
        record["progress"] = 0.0 as CKRecordValue
        record["joinedAt"] = Date() as CKRecordValue

        do {
            try await publicDB.save(record)
        } catch {
            print("Failed to join challenge: \(error)")
        }
    }

    func inviteFriendToChallenge(friendRecordName: String, challengeRecordName: String) async -> Bool {
        guard let userID = currentUserRecordID else { return false }

        // Send a nudge-style invitation
        let record = CKRecord(recordType: RecordType.nudge)
        record["fromUserID"] = userID.recordName as CKRecordValue
        record["toUserID"] = friendRecordName as CKRecordValue
        record["message"] = "challenge_invite:\(challengeRecordName)" as CKRecordValue
        record["sentAt"] = Date() as CKRecordValue
        record["isRead"] = false as CKRecordValue

        do {
            try await publicDB.save(record)
            return true
        } catch {
            return false
        }
    }

    func updateChallengeProgress(challengeRecordName: String, progress: Double) async {
        guard let userID = currentUserRecordID else { return }

        let predicate = NSPredicate(format: "challengeID == %@ AND userID == %@",
                                    challengeRecordName, userID.recordName)
        let query = CKQuery(recordType: RecordType.challengeParticipant, predicate: predicate)

        do {
            let (results, _) = try await publicDB.records(matching: query, resultsLimit: 1)
            guard let record = results.first.flatMap({ try? $0.1.get() }) else { return }
            record["progress"] = progress as CKRecordValue
            try await publicDB.save(record)
        } catch {
            print("Failed to update challenge progress: \(error)")
        }
    }

    func fetchChallengeParticipantCount(challengeRecordName: String) async -> Int {
        let predicate = NSPredicate(format: "challengeID == %@", challengeRecordName)
        let query = CKQuery(recordType: RecordType.challengeParticipant, predicate: predicate)

        do {
            let (results, _) = try await publicDB.records(matching: query, resultsLimit: 100)
            return results.count
        } catch {
            return 0
        }
    }

    // MARK: - Leaderboard

    /// Fetch XP-ranked data for the user's friends
    func fetchLeaderboardData(friendRecordNames: [String]) async -> [LeaderboardEntry] {
        guard let userID = currentUserRecordID else { return [] }

        var allIDs = friendRecordNames
        allIDs.append(userID.recordName)

        var entries: [LeaderboardEntry] = []

        for recordName in allIDs {
            let recordID = CKRecord.ID(recordName: recordName)
            do {
                let record = try await publicDB.record(for: recordID)
                entries.append(LeaderboardEntry(
                    recordName: recordName,
                    name: record["name"] as? String ?? "Unknown",
                    avatarEmoji: record["avatarEmoji"] as? String ?? "😊",
                    xp: record["xp"] as? Int ?? 0,
                    level: record["level"] as? Int ?? 1,
                    streak: record["currentStreak"] as? Int ?? 0,
                    isCurrentUser: recordName == userID.recordName
                ))
            } catch {
                // Skip unavailable records
            }
        }

        entries.sort { $0.xp > $1.xp }
        return entries
    }
}

// MARK: - Supporting Types

struct FriendRequest: Identifiable {
    var id: String { recordID.recordName }
    let recordID: CKRecord.ID
    let fromUserID: String
    let fromName: String
    let fromUsername: String
    let fromEmoji: String
    let fromLevel: Int
    let sentAt: Date
}

struct NudgeMessage: Identifiable {
    var id: String { recordID.recordName }
    let recordID: CKRecord.ID
    let fromName: String
    let message: String
    let sentAt: Date
}

// LeaderboardEntry is defined in Components/Social/LeaderboardRow.swift

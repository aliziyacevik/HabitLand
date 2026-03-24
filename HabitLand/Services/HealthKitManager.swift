import Foundation
import HealthKit
import os
import SwiftData

// MARK: - HealthKit Metric

enum HealthKitMetric: String, Codable, CaseIterable, Identifiable {
    case steps = "Steps"
    case water = "Water"
    case exerciseMinutes = "Exercise Minutes"
    case activeCalories = "Active Calories"
    case walkingDistance = "Walking Distance"
    case standHours = "Stand Hours"
    case mindfulMinutes = "Mindful Minutes"
    case sleepHours = "Sleep Hours"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .steps: return "figure.walk"
        case .water: return "drop.fill"
        case .exerciseMinutes: return "figure.run"
        case .activeCalories: return "flame.fill"
        case .walkingDistance: return "map.fill"
        case .standHours: return "figure.stand"
        case .mindfulMinutes: return "brain.head.profile"
        case .sleepHours: return "moon.fill"
        }
    }

    var unit: String {
        switch self {
        case .steps: return "steps"
        case .water: return "ml"
        case .exerciseMinutes: return "minutes"
        case .activeCalories: return "kcal"
        case .walkingDistance: return "km"
        case .standHours: return "hours"
        case .mindfulMinutes: return "minutes"
        case .sleepHours: return "hours"
        }
    }

    var defaultGoal: Int {
        switch self {
        case .steps: return 10000
        case .water: return 2000
        case .exerciseMinutes: return 30
        case .activeCalories: return 500
        case .walkingDistance: return 5
        case .standHours: return 12
        case .mindfulMinutes: return 10
        case .sleepHours: return 8
        }
    }

    var suggestedName: String {
        switch self {
        case .steps: return "10,000 Steps"
        case .water: return "Drink 2L Water"
        case .exerciseMinutes: return "30 Min Exercise"
        case .activeCalories: return "Burn 500 Calories"
        case .walkingDistance: return "Walk 5km"
        case .standHours: return "Stand 12 Hours"
        case .mindfulMinutes: return "10 Min Meditation"
        case .sleepHours: return "Sleep 8 Hours"
        }
    }

    var suggestedColorHex: String {
        switch self {
        case .steps, .exerciseMinutes, .activeCalories, .walkingDistance: return "#F24D4D" // fitness red
        case .water: return "#338FFF" // blue
        case .standHours: return "#34C759" // green
        case .mindfulMinutes: return "#9966E6" // mindfulness purple
        case .sleepHours: return "#6658B2" // sleep purple
        }
    }

    var suggestedCategory: String {
        switch self {
        case .steps, .exerciseMinutes, .activeCalories, .walkingDistance: return "Fitness"
        case .water: return "Health"
        case .standHours: return "Health"
        case .mindfulMinutes: return "Mindfulness"
        case .sleepHours: return "Sleep"
        }
    }

    var sampleType: HKQuantityType? {
        switch self {
        case .steps: return HKQuantityType(.stepCount)
        case .water: return HKQuantityType(.dietaryWater)
        case .exerciseMinutes: return HKQuantityType(.appleExerciseTime)
        case .activeCalories: return HKQuantityType(.activeEnergyBurned)
        case .walkingDistance: return HKQuantityType(.distanceWalkingRunning)
        case .standHours: return HKQuantityType(.appleStandTime)
        case .mindfulMinutes: return nil // uses category type (mindfulSession)
        case .sleepHours: return nil // uses category type (sleepAnalysis)
        }
    }

    var hkUnit: HKUnit {
        switch self {
        case .steps: return .count()
        case .water: return .literUnit(with: .milli)
        case .exerciseMinutes: return .minute()
        case .activeCalories: return .kilocalorie()
        case .walkingDistance: return .meterUnit(with: .kilo)
        case .standHours: return .hour()
        case .mindfulMinutes: return .minute()
        case .sleepHours: return .hour()
        }
    }
}

// MARK: - HealthKit Manager

@MainActor
final class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()
    @Published var isAuthorized = false

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    private init() {}

    // MARK: - Authorization

    func requestAuthorization(for metrics: [HealthKitMetric]) async -> Bool {
        guard isAvailable else { return false }

        var readTypes: Set<HKObjectType> = []

        for metric in metrics {
            if metric == .sleepHours {
                readTypes.insert(HKCategoryType(.sleepAnalysis))
            } else if metric == .mindfulMinutes {
                readTypes.insert(HKCategoryType(.mindfulSession))
            } else if let sampleType = metric.sampleType {
                readTypes.insert(sampleType)
            }
        }

        guard !readTypes.isEmpty else { return false }

        do {
            try await healthStore.requestAuthorization(toShare: [], read: readTypes)
            isAuthorized = true
            return true
        } catch {
            HLLogger.healthkit.error("HealthKit authorization failed: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    // MARK: - Query Today's Value

    func todayValue(for metric: HealthKitMetric) async -> Double {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return 0 }

        if metric == .sleepHours {
            return await querySleepHours(start: startOfDay, end: endOfDay)
        }

        if metric == .mindfulMinutes {
            return await queryMindfulMinutes(start: startOfDay, end: endOfDay)
        }

        guard let sampleType = metric.sampleType else { return 0 }

        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay)

        do {
            let descriptor = HKStatisticsQueryDescriptor(
                predicate: .quantitySample(type: sampleType, predicate: predicate),
                options: .cumulativeSum
            )
            let result = try await descriptor.result(for: healthStore)
            return result?.sumQuantity()?.doubleValue(for: metric.hkUnit) ?? 0
        } catch {
            HLLogger.healthkit.error("HealthKit query failed for \(metric.rawValue, privacy: .public): \(error.localizedDescription, privacy: .public)")
            return 0
        }
    }

    private func querySleepHours(start: Date, end: Date) async -> Double {
        let sleepType = HKCategoryType(.sleepAnalysis)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)

        do {
            let descriptor = HKSampleQueryDescriptor(
                predicates: [.categorySample(type: sleepType, predicate: predicate)],
                sortDescriptors: [SortDescriptor(\.startDate)]
            )
            let samples = try await descriptor.result(for: healthStore)

            // Sum asleep durations (exclude inBed)
            var totalSeconds: Double = 0
            for sample in samples {
                let value = HKCategoryValueSleepAnalysis(rawValue: sample.value)
                if value == .asleepCore || value == .asleepDeep || value == .asleepREM || value == .asleepUnspecified {
                    totalSeconds += sample.endDate.timeIntervalSince(sample.startDate)
                }
            }
            return totalSeconds / 3600.0
        } catch {
            return 0
        }
    }

    private func queryMindfulMinutes(start: Date, end: Date) async -> Double {
        let mindfulType = HKCategoryType(.mindfulSession)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)

        do {
            let descriptor = HKSampleQueryDescriptor(
                predicates: [.categorySample(type: mindfulType, predicate: predicate)],
                sortDescriptors: [SortDescriptor(\.startDate)]
            )
            let samples = try await descriptor.result(for: healthStore)

            var totalMinutes: Double = 0
            for sample in samples {
                totalMinutes += sample.endDate.timeIntervalSince(sample.startDate) / 60.0
            }
            return totalMinutes
        } catch {
            return 0
        }
    }

    // MARK: - Live Progress Query

    func currentValue(for metricRaw: String) async -> Double {
        guard let metric = HealthKitMetric(rawValue: metricRaw) else { return 0 }
        return await todayValue(for: metric)
    }

    // MARK: - Check & Auto-Complete Habits

    func syncHealthHabits(context: ModelContext) async {
        let descriptor = FetchDescriptor<Habit>()
        guard let habits = try? context.fetch(descriptor) else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for habit in habits {
            guard let metricRaw = habit.healthKitMetric,
                  let metric = HealthKitMetric(rawValue: metricRaw) else { continue }

            // Skip if already completed today
            let alreadyDone = habit.safeCompletions.contains { c in
                calendar.startOfDay(for: c.date) == today && c.isCompleted
            }
            if alreadyDone { continue }

            let value = await todayValue(for: metric)
            let goal = Double(habit.goalCount)

            if value >= goal {
                let completion = HabitCompletion(date: Date(), isCompleted: true, count: Int(value))
                completion.habit = habit
                context.insert(completion)
            }
        }

        do {
            try context.save()
        } catch {
            HLLogger.healthkit.error("Failed to save HealthKit auto-completions: \(error.localizedDescription, privacy: .public)")
        }
    }
}

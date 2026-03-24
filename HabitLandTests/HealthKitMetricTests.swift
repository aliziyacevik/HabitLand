import Testing
import Foundation
import HealthKit
@testable import HabitLand

// MARK: - HealthKitMetric Enum Tests

struct HealthKitMetricTests {

    @Test func allCasesExist() {
        #expect(HealthKitMetric.allCases.count == 8)
    }

    @Test func allMetricsHaveIcon() {
        for metric in HealthKitMetric.allCases {
            #expect(!metric.icon.isEmpty)
        }
    }

    @Test func allMetricsHaveUnit() {
        for metric in HealthKitMetric.allCases {
            #expect(!metric.unit.isEmpty)
        }
    }

    @Test func allMetricsHavePositiveDefaultGoal() {
        for metric in HealthKitMetric.allCases {
            #expect(metric.defaultGoal > 0)
        }
    }

    @Test func allMetricsHaveSuggestedName() {
        for metric in HealthKitMetric.allCases {
            #expect(!metric.suggestedName.isEmpty)
        }
    }

    @Test func allMetricsHaveSuggestedColorHex() {
        for metric in HealthKitMetric.allCases {
            #expect(metric.suggestedColorHex.hasPrefix("#"))
        }
    }

    @Test func allMetricsHaveSuggestedCategory() {
        for metric in HealthKitMetric.allCases {
            let cat = metric.suggestedCategory
            #expect(!cat.isEmpty)
            let valid = ["Fitness", "Health", "Mindfulness", "Sleep"]
            #expect(valid.contains(cat))
        }
    }

    @Test func allMetricsHaveHKUnit() {
        for metric in HealthKitMetric.allCases {
            let _ = metric.hkUnit // Should not crash
        }
    }

    @Test func allMetricsHaveId() {
        for metric in HealthKitMetric.allCases {
            #expect(metric.id == metric.rawValue)
        }
    }

    // MARK: - Specific Default Goals

    @Test func stepsDefaultGoal() {
        #expect(HealthKitMetric.steps.defaultGoal == 10000)
    }

    @Test func waterDefaultGoal() {
        #expect(HealthKitMetric.water.defaultGoal == 2000)
    }

    @Test func exerciseMinutesDefaultGoal() {
        #expect(HealthKitMetric.exerciseMinutes.defaultGoal == 30)
    }

    @Test func sleepHoursDefaultGoal() {
        #expect(HealthKitMetric.sleepHours.defaultGoal == 8)
    }

    // MARK: - Sample Type Mapping

    @Test func stepsSampleTypeNotNil() {
        #expect(HealthKitMetric.steps.sampleType != nil)
    }

    @Test func waterSampleTypeNotNil() {
        #expect(HealthKitMetric.water.sampleType != nil)
    }

    @Test func mindfulMinutesSampleTypeIsNil() {
        // Mindful minutes uses category type, not quantity type
        #expect(HealthKitMetric.mindfulMinutes.sampleType == nil)
    }

    @Test func sleepHoursSampleTypeIsNil() {
        // Sleep uses category type
        #expect(HealthKitMetric.sleepHours.sampleType == nil)
    }

    // MARK: - Unit Strings

    @Test func specificUnitStrings() {
        #expect(HealthKitMetric.steps.unit == "steps")
        #expect(HealthKitMetric.water.unit == "ml")
        #expect(HealthKitMetric.exerciseMinutes.unit == "minutes")
        #expect(HealthKitMetric.activeCalories.unit == "kcal")
        #expect(HealthKitMetric.walkingDistance.unit == "km")
        #expect(HealthKitMetric.standHours.unit == "hours")
        #expect(HealthKitMetric.mindfulMinutes.unit == "minutes")
        #expect(HealthKitMetric.sleepHours.unit == "hours")
    }

    // MARK: - Codable

    @Test func metricIsCodable() throws {
        let metric = HealthKitMetric.steps
        let data = try JSONEncoder().encode(metric)
        let decoded = try JSONDecoder().decode(HealthKitMetric.self, from: data)
        #expect(decoded == metric)
    }

    @Test func allMetricsRoundtripCodable() throws {
        for metric in HealthKitMetric.allCases {
            let data = try JSONEncoder().encode(metric)
            let decoded = try JSONDecoder().decode(HealthKitMetric.self, from: data)
            #expect(decoded == metric)
        }
    }

    // MARK: - Category Grouping

    @Test func fitnessMetricsShareCategory() {
        let fitnessMetrics: [HealthKitMetric] = [.steps, .exerciseMinutes, .activeCalories, .walkingDistance]
        for metric in fitnessMetrics {
            #expect(metric.suggestedCategory == "Fitness")
        }
    }

    @Test func healthMetricsShareCategory() {
        #expect(HealthKitMetric.water.suggestedCategory == "Health")
        #expect(HealthKitMetric.standHours.suggestedCategory == "Health")
    }

    @Test func mindfulnessCategory() {
        #expect(HealthKitMetric.mindfulMinutes.suggestedCategory == "Mindfulness")
    }

    @Test func sleepCategory() {
        #expect(HealthKitMetric.sleepHours.suggestedCategory == "Sleep")
    }
}

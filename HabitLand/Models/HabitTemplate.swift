import Foundation
import SwiftUI

// MARK: - Habit Template

struct HabitTemplate: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let colorHex: String
    let category: HabitCategory
    let frequency: HabitFrequency
    let targetDays: [Int]
    let goalCount: Int
    let unit: String
    let difficulty: Int // 1-3
    let description: String
    let tags: [String]

    init(
        _ name: String,
        icon: String,
        colorHex: String? = nil,
        category: HabitCategory,
        frequency: HabitFrequency = .daily,
        targetDays: [Int] = [0, 1, 2, 3, 4, 5, 6],
        goalCount: Int = 1,
        unit: String = "times",
        difficulty: Int = 1,
        description: String,
        tags: [String] = []
    ) {
        self.id = name.lowercased().replacingOccurrences(of: " ", with: "-")
        self.name = name
        self.icon = icon
        self.colorHex = colorHex ?? category.colorHex
        self.category = category
        self.frequency = frequency
        self.targetDays = targetDays
        self.goalCount = goalCount
        self.unit = unit
        self.difficulty = difficulty
        self.description = description
        self.tags = tags
    }

    var color: Color {
        Color(hex: colorHex) ?? .hlPrimary
    }

    var difficultyLabel: String {
        switch difficulty {
        case 1: return "Easy"
        case 2: return "Medium"
        default: return "Hard"
        }
    }

    func toHabit(sortOrder: Int = 0) -> Habit {
        Habit(
            name: name,
            icon: icon,
            colorHex: colorHex,
            category: category,
            frequency: frequency,
            targetDays: targetDays,
            goalCount: goalCount,
            unit: unit,
            sortOrder: sortOrder
        )
    }
}

// MARK: - Habit Template Pack

struct HabitTemplatePack: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let icon: String
    let colorHex: String
    let templates: [HabitTemplate]

    var color: Color {
        Color(hex: colorHex) ?? .hlPrimary
    }
}

// MARK: - Habit Template Library

enum HabitTemplateLibrary {

    // MARK: - All Templates by Category

    static let health: [HabitTemplate] = [
        HabitTemplate("Drink Water", icon: "drop.fill", category: .health, goalCount: 8, unit: "glasses", difficulty: 1,
                      description: "Stay hydrated throughout the day with regular water intake.",
                      tags: ["hydration", "essential", "beginner"]),
        HabitTemplate("Take Vitamins", icon: "pill.fill", category: .health, difficulty: 1,
                      description: "Never miss your daily vitamins and supplements.",
                      tags: ["supplements", "morning", "essential"]),
        HabitTemplate("Cold Shower", icon: "snowflake", category: .health, difficulty: 3,
                      description: "Build mental resilience with cold exposure therapy.",
                      tags: ["resilience", "advanced", "morning"]),
        HabitTemplate("No Alcohol", icon: "wineglass", category: .health, difficulty: 2,
                      description: "Track alcohol-free days for better health and sleep.",
                      tags: ["sobriety", "wellness"]),
        HabitTemplate("Skincare Routine", icon: "sparkles", category: .health, difficulty: 1,
                      description: "Take care of your skin with a consistent daily routine.",
                      tags: ["self-care", "morning", "evening"]),
        HabitTemplate("Posture Check", icon: "figure.stand", category: .health, goalCount: 5, unit: "checks", difficulty: 1,
                      description: "Pause throughout the day to correct your posture.",
                      tags: ["desk-work", "body"]),
        HabitTemplate("Floss Teeth", icon: "mouth.fill", category: .health, difficulty: 1,
                      description: "Protect your dental health with daily flossing.",
                      tags: ["hygiene", "evening", "essential"]),
        HabitTemplate("Eye Rest Breaks", icon: "eye", category: .health, goalCount: 4, unit: "breaks", difficulty: 1,
                      description: "Follow the 20-20-20 rule to reduce eye strain.",
                      tags: ["desk-work", "screen-time"]),
    ]

    static let fitness: [HabitTemplate] = [
        HabitTemplate("Walk 10k Steps", icon: "figure.walk", category: .fitness, goalCount: 10000, unit: "steps", difficulty: 2,
                      description: "Hit your daily step goal for cardiovascular health.",
                      tags: ["cardio", "outdoor", "popular"]),
        HabitTemplate("Strength Training", icon: "dumbbell.fill", category: .fitness, difficulty: 2,
                      description: "Build muscle and bone density with resistance training.",
                      tags: ["gym", "muscle", "intermediate"]),
        HabitTemplate("Stretch for 10 Min", icon: "figure.flexibility", category: .fitness, goalCount: 10, unit: "minutes", difficulty: 1,
                      description: "Improve flexibility and prevent injuries with daily stretching.",
                      tags: ["flexibility", "recovery", "beginner"]),
        HabitTemplate("Run", icon: "figure.run", category: .fitness, goalCount: 30, unit: "minutes", difficulty: 3,
                      description: "Build endurance and cardiovascular fitness with running.",
                      tags: ["cardio", "outdoor", "advanced"]),
        HabitTemplate("Yoga", icon: "figure.yoga", category: .fitness, goalCount: 20, unit: "minutes", difficulty: 1,
                      description: "Combine strength, flexibility, and mindfulness in one practice.",
                      tags: ["flexibility", "mindfulness", "popular"]),
        HabitTemplate("Morning Walk", icon: "figure.walk", colorHex: "#34C759", category: .fitness, goalCount: 20, unit: "minutes", difficulty: 1,
                      description: "Start your day with fresh air and gentle movement.",
                      tags: ["morning", "outdoor", "beginner"]),
        HabitTemplate("Cycling", icon: "bicycle", category: .fitness, goalCount: 30, unit: "minutes", difficulty: 2,
                      description: "Low-impact cardio that builds leg strength and endurance.",
                      tags: ["cardio", "outdoor", "intermediate"]),
        HabitTemplate("Core Workout", icon: "figure.core.training", category: .fitness, goalCount: 15, unit: "minutes", difficulty: 2,
                      description: "Strengthen your core for better posture and stability.",
                      tags: ["strength", "home-workout"]),
        HabitTemplate("Swimming", icon: "figure.pool.swim", category: .fitness, goalCount: 30, unit: "minutes", difficulty: 2,
                      description: "Full-body, low-impact exercise for all fitness levels.",
                      tags: ["cardio", "full-body"]),
    ]

    static let mindfulness: [HabitTemplate] = [
        HabitTemplate("Morning Meditation", icon: "brain.head.profile", category: .mindfulness, goalCount: 10, unit: "minutes", difficulty: 1,
                      description: "Start your day with calm focus through guided meditation.",
                      tags: ["morning", "focus", "popular"]),
        HabitTemplate("Practice Gratitude", icon: "heart.fill", colorHex: "#F27D8D", category: .mindfulness, goalCount: 3, unit: "things", difficulty: 1,
                      description: "Write down three things you're grateful for each day.",
                      tags: ["journaling", "positivity", "popular"]),
        HabitTemplate("Deep Breathing", icon: "wind", category: .mindfulness, goalCount: 5, unit: "minutes", difficulty: 1,
                      description: "Practice box breathing to calm your nervous system.",
                      tags: ["stress-relief", "quick"]),
        HabitTemplate("Digital Detox", icon: "iphone.slash", category: .mindfulness, goalCount: 60, unit: "minutes", difficulty: 3,
                      description: "Spend time fully device-free each day.",
                      tags: ["screen-time", "presence", "advanced"]),
        HabitTemplate("Journal", icon: "note.text", colorHex: "#FF9A1A", category: .mindfulness, goalCount: 10, unit: "minutes", difficulty: 1,
                      description: "Reflect on your day through free-form writing.",
                      tags: ["journaling", "evening", "popular"]),
        HabitTemplate("Body Scan", icon: "figure.mind.and.body", category: .mindfulness, goalCount: 10, unit: "minutes", difficulty: 1,
                      description: "Progressive relaxation technique to release tension.",
                      tags: ["relaxation", "evening"]),
        HabitTemplate("Mindful Walking", icon: "figure.walk", colorHex: "#9966E6", category: .mindfulness, goalCount: 15, unit: "minutes", difficulty: 1,
                      description: "Walk slowly with full attention to each step and breath.",
                      tags: ["outdoor", "presence"]),
        HabitTemplate("Affirmations", icon: "text.quote", category: .mindfulness, goalCount: 5, unit: "affirmations", difficulty: 1,
                      description: "Repeat positive affirmations to reshape your mindset.",
                      tags: ["morning", "positivity"]),
    ]

    static let productivity: [HabitTemplate] = [
        HabitTemplate("Plan Your Day", icon: "checklist", category: .productivity, difficulty: 1,
                      description: "Spend 10 minutes prioritizing your most important tasks.",
                      tags: ["morning", "planning", "essential"]),
        HabitTemplate("Pomodoro Sessions", icon: "timer", category: .productivity, goalCount: 4, unit: "sessions", difficulty: 2,
                      description: "Complete focused 25-minute work blocks with short breaks.",
                      tags: ["focus", "deep-work"]),
        HabitTemplate("Inbox Zero", icon: "tray.fill", category: .productivity, difficulty: 2,
                      description: "Process and clear your email inbox by end of day.",
                      tags: ["email", "organization"]),
        HabitTemplate("No Social Media", icon: "iphone.slash", category: .productivity, frequency: .weekdays, targetDays: [1, 2, 3, 4, 5], difficulty: 3,
                      description: "Avoid social media during work hours to protect focus.",
                      tags: ["screen-time", "focus", "advanced"]),
        HabitTemplate("Review Weekly Goals", icon: "calendar", category: .productivity, frequency: .weekends, targetDays: [0], difficulty: 1,
                      description: "Reflect on weekly progress and set goals for next week.",
                      tags: ["planning", "weekly-review"]),
        HabitTemplate("Single-Task Focus", icon: "scope", category: .productivity, goalCount: 3, unit: "blocks", difficulty: 2,
                      description: "Dedicate blocks of time to one task with zero multitasking.",
                      tags: ["focus", "deep-work"]),
        HabitTemplate("Clean Workspace", icon: "desktopcomputer", category: .productivity, difficulty: 1,
                      description: "Tidy your desk at end of day for a fresh start tomorrow.",
                      tags: ["evening", "organization"]),
        HabitTemplate("Learn One New Thing", icon: "lightbulb.fill", category: .productivity, difficulty: 1,
                      description: "Expand your skills with one new concept or technique daily.",
                      tags: ["growth", "learning"]),
    ]

    static let sleep: [HabitTemplate] = [
        HabitTemplate("Sleep by 11pm", icon: "moon.fill", category: .sleep, difficulty: 2,
                      description: "Maintain a consistent bedtime for better rest and recovery.",
                      tags: ["bedtime", "consistency"]),
        HabitTemplate("No Screens Before Bed", icon: "iphone.slash", colorHex: "#6659CC", category: .sleep, difficulty: 2,
                      description: "Avoid blue light 30 minutes before sleep.",
                      tags: ["screen-time", "evening"]),
        HabitTemplate("Wind Down Routine", icon: "zzz", category: .sleep, goalCount: 20, unit: "minutes", difficulty: 1,
                      description: "Follow a relaxing pre-sleep routine every night.",
                      tags: ["evening", "relaxation"]),
        HabitTemplate("Wake Up Early", icon: "sunrise.fill", category: .sleep, difficulty: 3,
                      description: "Rise early to gain productive morning hours.",
                      tags: ["morning", "advanced"]),
        HabitTemplate("No Caffeine After 2pm", icon: "cup.and.saucer.fill", category: .sleep, difficulty: 2,
                      description: "Cut caffeine early to protect your natural sleep drive.",
                      tags: ["nutrition", "afternoon"]),
        HabitTemplate("Evening Tea", icon: "mug.fill", category: .sleep, difficulty: 1,
                      description: "Wind down with a calming herbal tea before bed.",
                      tags: ["relaxation", "evening", "beginner"]),
    ]

    static let social: [HabitTemplate] = [
        HabitTemplate("Call a Friend", icon: "phone.fill", category: .social, difficulty: 1,
                      description: "Stay connected with someone you care about.",
                      tags: ["connection", "relationships"]),
        HabitTemplate("Random Act of Kindness", icon: "hand.raised.fill", category: .social, difficulty: 1,
                      description: "Do something nice for someone each day.",
                      tags: ["kindness", "positivity"]),
        HabitTemplate("Family Time", icon: "person.3.fill", category: .social, goalCount: 30, unit: "minutes", difficulty: 1,
                      description: "Dedicate quality time with family without distractions.",
                      tags: ["family", "presence"]),
        HabitTemplate("Send a Thank You", icon: "envelope.fill", category: .social, difficulty: 1,
                      description: "Express appreciation to someone who helped you.",
                      tags: ["gratitude", "connection"]),
        HabitTemplate("Active Listening", icon: "ear.fill", category: .social, difficulty: 2,
                      description: "Practice fully present listening in conversations.",
                      tags: ["communication", "presence"]),
    ]

    static let learning: [HabitTemplate] = [
        HabitTemplate("Read 30 Minutes", icon: "book.fill", colorHex: "#FFC207", category: .learning, goalCount: 30, unit: "minutes", difficulty: 1,
                      description: "Expand your knowledge with daily reading.",
                      tags: ["reading", "popular", "growth"]),
        HabitTemplate("Learn a Language", icon: "globe", category: .learning, goalCount: 15, unit: "minutes", difficulty: 2,
                      description: "Practice a new language consistently to build fluency.",
                      tags: ["language", "skill"]),
        HabitTemplate("Online Course", icon: "play.rectangle.fill", category: .learning, goalCount: 1, unit: "lessons", difficulty: 2,
                      description: "Complete one lesson from an online course each day.",
                      tags: ["skill", "career"]),
        HabitTemplate("Practice Instrument", icon: "music.note", category: .learning, goalCount: 20, unit: "minutes", difficulty: 2,
                      description: "Build musical skill with consistent daily practice.",
                      tags: ["music", "creative"]),
        HabitTemplate("Write 500 Words", icon: "pencil", category: .learning, goalCount: 500, unit: "words", difficulty: 2,
                      description: "Develop your writing habit with a daily word count.",
                      tags: ["writing", "creative"]),
        HabitTemplate("Solve a Puzzle", icon: "puzzlepiece.fill", category: .learning, difficulty: 1,
                      description: "Keep your mind sharp with a daily brain teaser.",
                      tags: ["brain-training", "fun"]),
        HabitTemplate("Listen to Podcast", icon: "headphones", category: .learning, goalCount: 1, unit: "episodes", difficulty: 1,
                      description: "Learn on the go with educational podcasts.",
                      tags: ["audio", "commute"]),
        HabitTemplate("Teach Someone", icon: "person.2.fill", colorHex: "#338FFF", category: .learning, difficulty: 2,
                      description: "Solidify your knowledge by explaining it to others.",
                      tags: ["sharing", "mastery"]),
    ]

    static let nutrition: [HabitTemplate] = [
        HabitTemplate("Eat Vegetables", icon: "leaf.fill", category: .nutrition, goalCount: 3, unit: "servings", difficulty: 1,
                      description: "Include vegetables in every meal for essential nutrients.",
                      tags: ["healthy-eating", "essential"]),
        HabitTemplate("No Sugar", icon: "xmark.circle", category: .nutrition, difficulty: 3,
                      description: "Avoid added sugars for better energy and focus.",
                      tags: ["sugar-free", "advanced"]),
        HabitTemplate("Meal Prep", icon: "frying.pan.fill", category: .nutrition, frequency: .weekends, targetDays: [0], difficulty: 2,
                      description: "Prepare healthy meals in advance to eat better all week.",
                      tags: ["planning", "weekly"]),
        HabitTemplate("Eat Breakfast", icon: "fork.knife", category: .nutrition, difficulty: 1,
                      description: "Fuel your morning with a nutritious breakfast.",
                      tags: ["morning", "essential", "beginner"]),
        HabitTemplate("Track Meals", icon: "list.bullet.clipboard", category: .nutrition, goalCount: 3, unit: "meals", difficulty: 1,
                      description: "Log what you eat to build awareness of nutrition.",
                      tags: ["tracking", "awareness"]),
        HabitTemplate("Cook at Home", icon: "oven.fill", category: .nutrition, difficulty: 2,
                      description: "Prepare at least one meal at home each day.",
                      tags: ["cooking", "savings"]),
        HabitTemplate("Eat Fruit", icon: "apple.logo", category: .nutrition, goalCount: 2, unit: "servings", difficulty: 1,
                      description: "Get natural vitamins and fiber from daily fruit.",
                      tags: ["healthy-eating", "snacking"]),
        HabitTemplate("Protein with Every Meal", icon: "fish.fill", category: .nutrition, goalCount: 3, unit: "meals", difficulty: 2,
                      description: "Ensure adequate protein intake for muscle recovery and satiety.",
                      tags: ["muscle", "healthy-eating"]),
    ]

    // MARK: - All Templates

    static var all: [HabitTemplate] {
        health + fitness + mindfulness + productivity + sleep + social + learning + nutrition
    }

    static func templates(for category: HabitCategory) -> [HabitTemplate] {
        switch category {
        case .health: return health
        case .fitness: return fitness
        case .mindfulness: return mindfulness
        case .productivity: return productivity
        case .sleep: return sleep
        case .social: return social
        case .learning: return learning
        case .nutrition: return nutrition
        }
    }

    static func search(_ query: String) -> [HabitTemplate] {
        guard !query.isEmpty else { return all }
        let q = query.lowercased()
        return all.filter { template in
            template.name.lowercased().contains(q) ||
            template.category.rawValue.lowercased().contains(q) ||
            template.description.lowercased().contains(q) ||
            template.tags.contains { $0.contains(q) }
        }
    }

    // MARK: - Curated Packs

    static let packs: [HabitTemplatePack] = [
        HabitTemplatePack(
            id: "morning-routine",
            name: "Morning Routine",
            subtitle: "Start every day with energy and intention",
            icon: "sunrise.fill",
            colorHex: "#FF9A1A",
            templates: [
                find("Wake Up Early"),
                find("Drink Water"),
                find("Morning Meditation"),
                find("Stretch for 10 Min"),
                find("Plan Your Day"),
            ].compactMap { $0 }
        ),
        HabitTemplatePack(
            id: "student-pack",
            name: "Student Focus",
            subtitle: "Build habits that boost academic performance",
            icon: "graduationcap.fill",
            colorHex: "#338FFF",
            templates: [
                find("Pomodoro Sessions"),
                find("Read 30 Minutes"),
                find("No Social Media"),
                find("Sleep by 11pm"),
                find("Plan Your Day"),
            ].compactMap { $0 }
        ),
        HabitTemplatePack(
            id: "fitness-starter",
            name: "Fitness Starter",
            subtitle: "Ease into an active lifestyle step by step",
            icon: "figure.run",
            colorHex: "#338FFF",
            templates: [
                find("Morning Walk"),
                find("Stretch for 10 Min"),
                find("Drink Water"),
                find("Core Workout"),
                find("Eat Vegetables"),
            ].compactMap { $0 }
        ),
        HabitTemplatePack(
            id: "stress-relief",
            name: "Stress Relief",
            subtitle: "Calm your mind and restore balance",
            icon: "brain.head.profile",
            colorHex: "#9966E6",
            templates: [
                find("Morning Meditation"),
                find("Deep Breathing"),
                find("Journal"),
                find("Digital Detox"),
                find("Evening Tea"),
            ].compactMap { $0 }
        ),
        HabitTemplatePack(
            id: "better-sleep",
            name: "Better Sleep",
            subtitle: "Improve your sleep quality naturally",
            icon: "moon.fill",
            colorHex: "#6659CC",
            templates: [
                find("Sleep by 11pm"),
                find("No Screens Before Bed"),
                find("Wind Down Routine"),
                find("No Caffeine After 2pm"),
                find("Evening Tea"),
            ].compactMap { $0 }
        ),
        HabitTemplatePack(
            id: "healthy-eating",
            name: "Healthy Eating",
            subtitle: "Transform your diet one meal at a time",
            icon: "leaf.fill",
            colorHex: "#34C759",
            templates: [
                find("Eat Breakfast"),
                find("Eat Vegetables"),
                find("Drink Water"),
                find("Cook at Home"),
                find("No Sugar"),
            ].compactMap { $0 }
        ),
    ]

    // MARK: - Starter Picks (for onboarding)

    static let starterPicks: [HabitTemplate] = [
        find("Drink Water"),
        find("Morning Walk"),
        find("Morning Meditation"),
        find("Read 30 Minutes"),
        find("Stretch for 10 Min"),
        find("Journal"),
        find("Eat Vegetables"),
        find("No Screens Before Bed"),
        find("Strength Training"),
        find("Learn a Language"),
        find("Take Vitamins"),
        find("Practice Gratitude"),
    ].compactMap { $0 }

    // MARK: - Popular (for discovery)

    static let popular: [HabitTemplate] = [
        find("Walk 10k Steps"),
        find("Read 30 Minutes"),
        find("Morning Meditation"),
        find("Drink Water"),
        find("No Sugar"),
        find("Cold Shower"),
        find("Practice Gratitude"),
        find("Stretch for 10 Min"),
    ].compactMap { $0 }

    // MARK: - Helpers

    private static func find(_ name: String) -> HabitTemplate? {
        all.first { $0.name == name }
    }
}

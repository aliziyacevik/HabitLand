import SwiftUI

// MARK: - Animal Avatar

enum AnimalAvatar: String, Codable, CaseIterable {
    case fox, bear, panda, cat, owl, tiger, butterfly, dolphin

    var sfSymbol: String {
        switch self {
        case .fox: return "hare.fill"
        case .bear: return "bear.fill"
        case .panda: return "pawprint.fill"
        case .cat: return "cat.fill"
        case .owl: return "owl"
        case .tiger: return "tortoise.fill"
        case .butterfly: return "ant.fill"
        case .dolphin: return "fish.fill"
        }
    }

    var displayName: String {
        rawValue.capitalized
    }

    var gradientColors: [Color] {
        switch self {
        case .fox: return [Color(red: 0.95, green: 0.5, blue: 0.2), Color(red: 0.85, green: 0.35, blue: 0.1)]
        case .bear: return [Color(red: 0.55, green: 0.35, blue: 0.2), Color(red: 0.4, green: 0.25, blue: 0.15)]
        case .panda: return [Color(red: 0.3, green: 0.3, blue: 0.3), Color(red: 0.15, green: 0.15, blue: 0.15)]
        case .cat: return [Color(red: 0.95, green: 0.65, blue: 0.3), Color(red: 0.85, green: 0.5, blue: 0.15)]
        case .owl: return [Color(red: 0.45, green: 0.35, blue: 0.7), Color(red: 0.3, green: 0.2, blue: 0.55)]
        case .tiger: return [Color(red: 0.95, green: 0.6, blue: 0.1), Color(red: 0.9, green: 0.4, blue: 0.05)]
        case .butterfly: return [Color(red: 0.7, green: 0.3, blue: 0.85), Color(red: 0.5, green: 0.15, blue: 0.7)]
        case .dolphin: return [Color(red: 0.2, green: 0.6, blue: 0.9), Color(red: 0.1, green: 0.4, blue: 0.75)]
        }
    }
}

// MARK: - Avatar Frame

enum AvatarFrame: String, Codable, CaseIterable {
    case flame, stars, rainbow, crown

    var displayName: String {
        rawValue.capitalized
    }

    var sfSymbol: String {
        switch self {
        case .flame: return "flame.fill"
        case .stars: return "sparkles"
        case .rainbow: return "rainbow"
        case .crown: return "crown.fill"
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .flame: return [Color(red: 1.0, green: 0.4, blue: 0.1), Color(red: 1.0, green: 0.2, blue: 0.0)]
        case .stars: return [Color(red: 1.0, green: 0.85, blue: 0.2), Color(red: 0.95, green: 0.6, blue: 0.1)]
        case .rainbow: return [Color(red: 0.9, green: 0.3, blue: 0.4), Color(red: 0.3, green: 0.5, blue: 0.95)]
        case .crown: return [Color(red: 1.0, green: 0.8, blue: 0.0), Color(red: 0.85, green: 0.6, blue: 0.0)]
        }
    }
}

// MARK: - Avatar Type

enum AvatarType: Equatable {
    case initial
    case animal(AnimalAvatar)
    case frame(AvatarFrame)

    var rawStorage: String {
        switch self {
        case .initial:
            return "initial"
        case .animal(let animal):
            return "animal.\(animal.rawValue)"
        case .frame(let frame):
            return "frame.\(frame.rawValue)"
        }
    }

    init?(rawStorage: String) {
        if rawStorage == "initial" {
            self = .initial
            return
        }
        let parts = rawStorage.split(separator: ".", maxSplits: 1)
        guard parts.count == 2 else { return nil }
        let prefix = String(parts[0])
        let value = String(parts[1])

        switch prefix {
        case "animal":
            guard let animal = AnimalAvatar(rawValue: value) else { return nil }
            self = .animal(animal)
        case "frame":
            guard let frame = AvatarFrame(rawValue: value) else { return nil }
            self = .frame(frame)
        default:
            return nil
        }
    }

    var displayName: String {
        switch self {
        case .initial: return "Default"
        case .animal(let animal): return animal.displayName
        case .frame(let frame): return frame.displayName
        }
    }

    var sfSymbol: String? {
        switch self {
        case .initial: return nil
        case .animal(let animal): return animal.sfSymbol
        case .frame(let frame): return frame.sfSymbol
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .initial:
            #if WIDGET_EXTENSION
            return [Color(red: 0.2, green: 0.78, blue: 0.6), Color(red: 0.1, green: 0.55, blue: 0.45)]
            #else
            return [.hlPrimary, .hlPrimary.opacity(0.7)]
            #endif
        case .animal(let animal): return animal.gradientColors
        case .frame(let frame): return frame.gradientColors
        }
    }
}

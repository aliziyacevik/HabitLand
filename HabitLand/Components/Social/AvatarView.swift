import SwiftUI

/// Displays a user avatar as a colored circle with their initial letter,
/// an animal SF Symbol, or an initial with animated frame border.
struct AvatarView: View {
    let name: String
    let size: CGFloat
    var avatarType: AvatarType = .initial

    @State private var frameRotation: Double = 0

    private var initial: String {
        String(name.prefix(1)).uppercased()
    }

    private var nameGradientColors: [Color] {
        let palettes: [[Color]] = [
            [Color(red: 0.2, green: 0.78, blue: 0.6), Color(red: 0.1, green: 0.55, blue: 0.45)],
            [Color(red: 0.95, green: 0.45, blue: 0.3), Color(red: 0.8, green: 0.25, blue: 0.2)],
            [Color(red: 0.4, green: 0.5, blue: 0.95), Color(red: 0.25, green: 0.3, blue: 0.75)],
            [Color(red: 0.95, green: 0.65, blue: 0.15), Color(red: 0.85, green: 0.45, blue: 0.1)],
            [Color(red: 0.85, green: 0.35, blue: 0.65), Color(red: 0.65, green: 0.2, blue: 0.5)],
            [Color(red: 0.3, green: 0.75, blue: 0.85), Color(red: 0.15, green: 0.5, blue: 0.7)],
        ]
        let index = abs(name.hashValue) % palettes.count
        return palettes[index]
    }

    var body: some View {
        switch avatarType {
        case .initial:
            initialAvatar
        case .animal(let animal):
            animalAvatar(animal)
        case .frame(let frame):
            framedAvatar(frame)
        }
    }

    // MARK: - Initial Avatar

    private var initialAvatar: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: nameGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)

            Text(initial)
                .font(.system(size: size * 0.42, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }

    // MARK: - Animal Avatar

    private func animalAvatar(_ animal: AnimalAvatar) -> some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: animal.gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)

            Image(systemName: animal.sfSymbol)
                .font(.system(size: size * 0.45, weight: .semibold))
                .foregroundColor(.white)
        }
    }

    // MARK: - Framed Avatar

    private func framedAvatar(_ frame: AvatarFrame) -> some View {
        ZStack {
            // Inner avatar (initial style)
            Circle()
                .fill(
                    LinearGradient(
                        colors: nameGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size - 6, height: size - 6)

            Text(initial)
                .font(.system(size: (size - 6) * 0.42, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            // Animated gradient border
            Circle()
                .stroke(
                    AngularGradient(
                        colors: frame.gradientColors + [frame.gradientColors.first ?? .clear],
                        center: .center
                    ),
                    lineWidth: 3
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(frameRotation))
        }
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                frameRotation = 360
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 12) {
            AvatarView(name: "Sarah", size: 56)
            AvatarView(name: "Mike", size: 56, avatarType: .animal(.fox))
            AvatarView(name: "Emma", size: 56, avatarType: .animal(.bear))
        }
        HStack(spacing: 12) {
            AvatarView(name: "Alex", size: 56, avatarType: .animal(.owl))
            AvatarView(name: "Lily", size: 56, avatarType: .frame(.stars))
            AvatarView(name: "James", size: 56, avatarType: .frame(.crown))
        }
    }
    .padding()
}

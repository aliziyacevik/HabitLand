import SwiftUI

/// Displays a user avatar as a colored circle with their initial letter.
/// Falls back to a gradient based on the name's hash for consistent coloring.
struct AvatarView: View {
    let name: String
    let size: CGFloat

    private var initial: String {
        String(name.prefix(1)).uppercased()
    }

    private var gradientColors: [Color] {
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
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: gradientColors,
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
}

#Preview {
    HStack(spacing: 12) {
        AvatarView(name: "Sarah", size: 56)
        AvatarView(name: "Mike", size: 56)
        AvatarView(name: "Emma", size: 56)
        AvatarView(name: "Alex", size: 56)
        AvatarView(name: "Lily", size: 56)
    }
    .padding()
}

import XCTest
import UIKit

/// Generates professional App Store-ready screenshots with device frames,
/// gradient backgrounds, and marketing copy — inspired by HabitKit style.
final class AppStoreCompositor: XCTestCase {

    private let rawDir6_7 = "/Users/azc/works/HabitLand/.appstore/screenshots/6.7/"
    private let rawDir6_5 = "/Users/azc/works/HabitLand/.appstore/screenshots/6.5/"
    private let outputDir6_7 = "/Users/azc/works/HabitLand/.appstore/ready/6.7/"
    private let outputDir6_5 = "/Users/azc/works/HabitLand/.appstore/ready/6.5/"

    private let size6_7 = CGSize(width: 1290, height: 2796)
    private let size6_5 = CGSize(width: 1284, height: 2778)

    // MARK: - Screenshot Config

    private struct ScreenshotConfig {
        let file: String
        let headline: String
        let subline: String
        let bgColors: (top: UIColor, bottom: UIColor)
    }

    private let screenshots: [ScreenshotConfig] = [
        ScreenshotConfig(
            file: "01_home_dashboard.png",
            headline: "Build Better Habits",
            subline: "Track your daily progress\nwith a beautiful dashboard",
            bgColors: (
                UIColor(red: 0.11, green: 0.11, blue: 0.14, alpha: 1),  // near black
                UIColor(red: 0.08, green: 0.22, blue: 0.18, alpha: 1)   // dark green tint
            )
        ),
        ScreenshotConfig(
            file: "02_habit_detail.png",
            headline: "Never Break\nthe Chain",
            subline: "Visualize your streaks\nand stay consistent",
            bgColors: (
                UIColor(red: 0.08, green: 0.22, blue: 0.18, alpha: 1),
                UIColor(red: 0.06, green: 0.16, blue: 0.24, alpha: 1)
            )
        ),
        ScreenshotConfig(
            file: "03_sleep_dashboard.png",
            headline: "Sleep Better,\nLive Better",
            subline: "Track sleep quality\nand find patterns",
            bgColors: (
                UIColor(red: 0.12, green: 0.10, blue: 0.22, alpha: 1),  // dark purple
                UIColor(red: 0.08, green: 0.08, blue: 0.18, alpha: 1)
            )
        ),
        ScreenshotConfig(
            file: "04_habits_list.png",
            headline: "All Your Habits\nin One Place",
            subline: "Organize, sort, and manage\neverything effortlessly",
            bgColors: (
                UIColor(red: 0.11, green: 0.11, blue: 0.14, alpha: 1),
                UIColor(red: 0.14, green: 0.18, blue: 0.12, alpha: 1)
            )
        ),
        ScreenshotConfig(
            file: "05_profile.png",
            headline: "Level Up\nEvery Day",
            subline: "Earn XP and unlock\nachievements as you grow",
            bgColors: (
                UIColor(red: 0.14, green: 0.18, blue: 0.12, alpha: 1),
                UIColor(red: 0.08, green: 0.22, blue: 0.18, alpha: 1)
            )
        ),
        ScreenshotConfig(
            file: "06_reminder.png",
            headline: "Smart\nReminders",
            subline: "Custom notifications\nfor every habit",
            bgColors: (
                UIColor(red: 0.06, green: 0.16, blue: 0.24, alpha: 1),
                UIColor(red: 0.12, green: 0.10, blue: 0.22, alpha: 1)
            )
        ),
        ScreenshotConfig(
            file: "07_pomodoro.png",
            headline: "Stay Focused",
            subline: "Built-in Pomodoro timer\nwith ambient sounds",
            bgColors: (
                UIColor(red: 0.11, green: 0.11, blue: 0.14, alpha: 1),
                UIColor(red: 0.06, green: 0.16, blue: 0.24, alpha: 1)
            )
        ),
    ]

    // MARK: - Tests

    @MainActor
    func testComposite_6_7() throws {
        try compositeAll(rawDir: rawDir6_7, outputDir: outputDir6_7, canvasSize: size6_7)
    }

    @MainActor
    func testComposite_6_5() throws {
        try compositeAll(rawDir: rawDir6_5, outputDir: outputDir6_5, canvasSize: size6_5)
    }

    // MARK: - Compositor

    private func compositeAll(rawDir: String, outputDir: String, canvasSize: CGSize) throws {
        let fm = FileManager.default
        try fm.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

        for (index, config) in screenshots.enumerated() {
            let inputPath = rawDir + config.file
            guard fm.fileExists(atPath: inputPath),
                  let rawImage = UIImage(contentsOfFile: inputPath) else {
                print("⚠️ Missing: \(inputPath)")
                continue
            }

            let composited = render(
                raw: rawImage,
                config: config,
                canvasSize: canvasSize
            )

            if let data = composited.pngData() {
                let outputName = config.file
                let outputPath = outputDir + outputName
                try data.write(to: URL(fileURLWithPath: outputPath))
                print("✅ \(outputName)")
            }
        }
    }

    // MARK: - Render

    private func render(raw: UIImage, config: ScreenshotConfig, canvasSize: CGSize) -> UIImage {
        let w = canvasSize.width
        let h = canvasSize.height

        // Layout ratios
        let textTopMargin = h * 0.06
        let headlineY = textTopMargin
        let phoneTopY = h * 0.34          // phone starts at 34% from top
        let phoneSideMargin = w * 0.10
        let maxPhoneWidth = w - (phoneSideMargin * 2)

        // Aspect-fit: preserve screenshot's real aspect ratio
        let rawAspect = raw.size.width / raw.size.height
        let availableHeight = h - phoneTopY + (h * 0.02)
        let phoneWidth: CGFloat
        let phoneHeight: CGFloat
        if maxPhoneWidth / availableHeight > rawAspect {
            // Height-constrained
            phoneHeight = availableHeight
            phoneWidth = phoneHeight * rawAspect
        } else {
            // Width-constrained
            phoneWidth = maxPhoneWidth
            phoneHeight = phoneWidth / rawAspect
        }

        let phoneCornerRadius: CGFloat = 44
        let phoneBorderWidth: CGFloat = 8

        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        return renderer.image { ctx in
            let context = ctx.cgContext

            // 1. Dark gradient background
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [config.bgColors.top.cgColor, config.bgColors.bottom.cgColor] as CFArray,
                locations: [0, 1]
            )!
            context.drawLinearGradient(
                gradient,
                start: CGPoint(x: w * 0.3, y: 0),
                end: CGPoint(x: w * 0.7, y: h),
                options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
            )

            // 2. Subtle radial glow behind phone
            let glowCenter = CGPoint(x: w * 0.5, y: phoneTopY + phoneHeight * 0.3)
            let glowGradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor(red: 0.20, green: 0.78, blue: 0.55, alpha: 0.08).cgColor,
                    UIColor.clear.cgColor
                ] as CFArray,
                locations: [0, 1]
            )!
            context.drawRadialGradient(
                glowGradient,
                startCenter: glowCenter, startRadius: 0,
                endCenter: glowCenter, endRadius: w * 0.7,
                options: []
            )

            // 3. Headline text
            drawText(
                config.headline,
                rect: CGRect(x: w * 0.08, y: headlineY, width: w * 0.84, height: h * 0.16),
                fontSize: w * 0.082,
                weight: .bold,
                color: .white,
                alignment: .center
            )

            // 4. Subline text
            let sublineY = headlineY + h * 0.17
            drawText(
                config.subline,
                rect: CGRect(x: w * 0.10, y: sublineY, width: w * 0.80, height: h * 0.10),
                fontSize: w * 0.036,
                weight: .regular,
                color: UIColor.white.withAlphaComponent(0.6),
                alignment: .center
            )

            // 5. Phone frame + screenshot
            let phoneX = (w - phoneWidth) / 2  // center horizontally
            let phoneRect = CGRect(x: phoneX, y: phoneTopY, width: phoneWidth, height: phoneHeight)
            let phonePath = UIBezierPath(roundedRect: phoneRect, cornerRadius: phoneCornerRadius)

            // Phone shadow
            context.saveGState()
            context.setShadow(
                offset: CGSize(width: 0, height: 16),
                blur: 60,
                color: UIColor.black.withAlphaComponent(0.5).cgColor
            )
            UIColor.black.setFill()
            phonePath.fill()
            context.restoreGState()

            // Phone border (subtle dark frame)
            context.saveGState()
            let borderColor = UIColor(white: 0.25, alpha: 1.0)
            borderColor.setStroke()
            phonePath.lineWidth = phoneBorderWidth
            phonePath.stroke()
            context.restoreGState()

            // Clip and draw screenshot inside phone
            let innerRect = phoneRect.insetBy(dx: phoneBorderWidth / 2, dy: phoneBorderWidth / 2)
            let innerPath = UIBezierPath(roundedRect: innerRect, cornerRadius: phoneCornerRadius - 2)

            context.saveGState()
            innerPath.addClip()
            raw.draw(in: innerRect)
            context.restoreGState()
        }
    }

    // MARK: - Text Drawing

    private func drawText(
        _ text: String,
        rect: CGRect,
        fontSize: CGFloat,
        weight: UIFont.Weight,
        color: UIColor,
        alignment: NSTextAlignment
    ) {
        let baseFont = UIFont.systemFont(ofSize: fontSize, weight: weight)
        let font: UIFont
        if let descriptor = baseFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: fontSize)
        } else {
            font = baseFont
        }

        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        style.lineHeightMultiple = 1.1

        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: style,
        ]
        (text as NSString).draw(in: rect, withAttributes: attrs)
    }

}

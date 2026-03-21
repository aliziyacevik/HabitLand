#!/usr/bin/env python3
"""
Generate professional App Store screenshots for HabitLand.
Uses REAL app screenshots captured from simulator, wrapped in
device frames with gradient backgrounds and headlines.

Produces 4 output directories:
  - AppStore_6.7/    (English, 1290x2796)
  - AppStore_5.5/    (English, 1242x2208)
  - AppStore_6.7_tr/ (Turkish, 1290x2796)
  - AppStore_5.5_tr/ (Turkish, 1242x2208)
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
RAW_DIR = os.path.join(BASE_DIR, "Screenshots")

# Output directories
OUTPUT_67 = os.path.join(BASE_DIR, "AppStore_6.7")
OUTPUT_55 = os.path.join(BASE_DIR, "AppStore_5.5")
OUTPUT_67_TR = os.path.join(BASE_DIR, "AppStore_6.7_tr")
OUTPUT_55_TR = os.path.join(BASE_DIR, "AppStore_5.5_tr")

for d in [OUTPUT_67, OUTPUT_55, OUTPUT_67_TR, OUTPUT_55_TR]:
    os.makedirs(d, exist_ok=True)

AVENIR = "/System/Library/Fonts/Avenir Next.ttc"


def font_heavy(size):
    return ImageFont.truetype(AVENIR, size, index=8)


def font_medium(size):
    return ImageFont.truetype(AVENIR, size, index=5)


def font_demibold(size):
    return ImageFont.truetype(AVENIR, size, index=2)


SIZES = {
    "6.7": (1290, 2796),
    "5.5": (1242, 2208),
}

# Screenshot definitions: (filename, headline, subtitle, bg_colors, accent)
# English headlines per D-05 from CONTEXT.md
SCREENSHOTS_EN = [
    ("01_home_dashboard", "Every Day,\nOne Step Closer",
     "Track your daily progress with beautiful insights",
     [(8, 47, 43), (10, 36, 34), (12, 24, 28), (15, 18, 25)],
     (52, 211, 153)),

    ("02_streaks_habits", "Start With 3,\nGo Unlimited",
     "Stay consistent and watch your progress grow",
     [(60, 25, 8), (45, 18, 10), (28, 14, 12), (18, 12, 18)],
     (249, 115, 22)),

    ("03_sleep_tracking", "Track Your Sleep,\nChange Your Life",
     "Optimize your rest with sleep insights",
     [(35, 15, 60), (28, 12, 52), (18, 10, 38), (14, 10, 25)],
     (139, 92, 246)),

    ("04_social_leaderboard", "Compete\nWith Friends",
     "Leaderboards, challenges and more",
     [(8, 22, 50), (6, 18, 42), (10, 14, 32), (12, 12, 22)],
     (59, 130, 246)),

    ("05_achievements_xp", "Earn Badges,\nLevel Up",
     "Gamified progress that keeps you going",
     [(50, 35, 8), (38, 25, 6), (24, 16, 8), (16, 12, 16)],
     (251, 191, 36)),

    ("06_premium_pro", "Unlimited\nExperience With Pro",
     "Go Pro for unlimited habits & features",
     [(8, 42, 35), (6, 32, 28), (10, 22, 22), (12, 15, 20)],
     (52, 211, 153)),
]

# Turkish headlines per D-10 from CONTEXT.md
SCREENSHOTS_TR = [
    ("01_home_dashboard", "Her Gün\nBir Adım Daha",
     "Günlük ilerlemenizi takip edin",
     [(8, 47, 43), (10, 36, 34), (12, 24, 28), (15, 18, 25)],
     (52, 211, 153)),

    ("02_streaks_habits", "Streak'ini\nKırma",
     "Tutarlı ol, ilerlemeyi gör",
     [(60, 25, 8), (45, 18, 10), (28, 14, 12), (18, 12, 18)],
     (249, 115, 22)),

    ("03_sleep_tracking", "Uykunu\nTakip Et",
     "Uyku kaliteni iyileştir",
     [(35, 15, 60), (28, 12, 52), (18, 10, 38), (14, 10, 25)],
     (139, 92, 246)),

    ("04_social_leaderboard", "Arkadaşlarınla\nYarış",
     "Liderlik tablosu ve meydan okumalar",
     [(8, 22, 50), (6, 18, 42), (10, 14, 32), (12, 12, 22)],
     (59, 130, 246)),

    ("05_achievements_xp", "Rozetler Kazan",
     "Seviye atla, başarılarını aç",
     [(50, 35, 8), (38, 25, 6), (24, 16, 8), (16, 12, 16)],
     (251, 191, 36)),

    ("06_premium_pro", "Sınırsız\nDeneyim",
     "Pro ile tüm özelliklere eriş",
     [(8, 42, 35), (6, 32, 28), (10, 22, 22), (12, 15, 20)],
     (52, 211, 153)),
]


def create_gradient_bg(size, colors):
    w, h = size
    img = Image.new("RGBA", (w, h))
    pixels = img.load()
    n = len(colors)
    for y in range(h):
        ratio = y / h
        seg = ratio * (n - 1)
        idx = min(int(seg), n - 2)
        local_ratio = seg - idx
        c1, c2 = colors[idx], colors[idx + 1]
        r = int(c1[0] + (c2[0] - c1[0]) * local_ratio)
        g = int(c1[1] + (c2[1] - c1[1]) * local_ratio)
        b = int(c1[2] + (c2[2] - c1[2]) * local_ratio)
        for x in range(w):
            pixels[x, y] = (r, g, b, 255)
    return img


def add_glow(canvas, cx, cy, radius, color, alpha=40):
    glow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(glow)
    for i in range(radius, 0, -3):
        a = int(alpha * (i / radius) ** 0.5 * (1 - i / radius))
        a = max(0, min(255, a))
        draw.ellipse((cx - i, cy - i, cx + i, cy + i),
                      fill=(color[0], color[1], color[2], a))
    canvas.paste(Image.alpha_composite(
        Image.new("RGBA", canvas.size, (0, 0, 0, 0)), glow
    ), (0, 0), glow)


def draw_phone_frame(canvas, screen_img, x, y, frame_w, frame_h, corner_radius=44):
    """Draw a modern iPhone-style device frame with Dynamic Island."""
    bezel = 6

    # Outer shadow (softer, more layers)
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow)
    for i in range(10):
        offset = (10 - i) * 3
        a = 4 + i * 3
        sdraw.rounded_rectangle(
            (x - bezel - offset, y - bezel - offset + 6,
             x + frame_w + bezel + offset, y + frame_h + bezel + offset + 10),
            radius=corner_radius + bezel + offset,
            fill=(0, 0, 0, a))
    canvas.paste(Image.alpha_composite(
        Image.new("RGBA", canvas.size, (0, 0, 0, 0)), shadow
    ), (0, 0), shadow)

    draw = ImageDraw.Draw(canvas)

    # Outer edge highlight (simulates metal frame catching light)
    draw.rounded_rectangle(
        (x - bezel - 3, y - bezel - 3, x + frame_w + bezel + 3, y + frame_h + bezel + 3),
        radius=corner_radius + bezel + 3, fill=(60, 60, 68, 255))

    # Main frame body
    draw.rounded_rectangle(
        (x - bezel, y - bezel, x + frame_w + bezel, y + frame_h + bezel),
        radius=corner_radius + bezel, fill=(18, 18, 22, 255))

    # Inner edge (subtle inset)
    draw.rounded_rectangle(
        (x - 1, y - 1, x + frame_w + 1, y + frame_h + 1),
        radius=corner_radius + 1, fill=(10, 10, 14, 255))

    # Screen area
    draw.rounded_rectangle((x, y, x + frame_w, y + frame_h), radius=corner_radius,
                            fill=(255, 255, 255, 255))

    # Auto-rotate landscape screenshots to portrait
    if screen_img.width > screen_img.height:
        screen_img = screen_img.rotate(90, expand=True)

    # Paste real screenshot
    resized = screen_img.resize((frame_w, frame_h), Image.LANCZOS)
    mask = Image.new("L", (frame_w, frame_h), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle((0, 0, frame_w, frame_h), radius=corner_radius, fill=255)

    if resized.mode != "RGBA":
        resized = resized.convert("RGBA")
    canvas.paste(resized, (x, y), mask)

    # Dynamic Island
    di_w = int(frame_w * 0.28)
    di_h = int(frame_h * 0.016)
    di_x = x + (frame_w - di_w) // 2
    di_y = y + int(frame_h * 0.014)
    di_radius = di_h // 2
    draw = ImageDraw.Draw(canvas)
    draw.rounded_rectangle(
        (di_x, di_y, di_x + di_w, di_y + di_h),
        radius=di_radius, fill=(0, 0, 0, 255))

    # Home indicator bar at bottom
    bar_w = int(frame_w * 0.35)
    bar_h = max(4, int(frame_h * 0.004))
    bar_x = x + (frame_w - bar_w) // 2
    bar_y = y + frame_h - int(frame_h * 0.016)
    draw.rounded_rectangle(
        (bar_x, bar_y, bar_x + bar_w, bar_y + bar_h),
        radius=bar_h // 2, fill=(255, 255, 255, 180))


def text_multiline_centered(draw, text, y, width, font, fill=(255, 255, 255), line_spacing=1.15):
    """Draw multi-line centered text. Supports \\n in text."""
    lines = text.split("\n")
    # Calculate total height
    line_heights = []
    for line in lines:
        bbox = draw.textbbox((0, 0), line, font=font)
        line_heights.append(bbox[3] - bbox[1])

    total_h = sum(line_heights) + int(line_heights[0] * (line_spacing - 1)) * (len(lines) - 1)

    current_y = y
    for i, line in enumerate(lines):
        bbox = draw.textbbox((0, 0), line, font=font)
        tw = bbox[2] - bbox[0]
        draw.text(((width - tw) // 2, current_y), line, font=font, fill=fill)
        current_y += int(line_heights[i] * line_spacing)

    return current_y


def create_store_screenshot(raw_filename, headline, subtitle, bg_colors, accent, dims):
    w, h = dims

    # Load real screenshot
    raw_path = os.path.join(RAW_DIR, raw_filename + ".png")
    if not os.path.exists(raw_path):
        print(f"  WARNING: {raw_path} not found, skipping")
        return None

    screen = Image.open(raw_path)

    # Create canvas with gradient background
    canvas = create_gradient_bg((w, h), bg_colors)

    # Add decorative glows
    add_glow(canvas, int(w * 0.15), int(h * 0.12), int(w * 0.45), accent, 30)
    add_glow(canvas, int(w * 0.85), int(h * 0.75), int(w * 0.35), accent, 25)
    add_glow(canvas, int(w * 0.5), int(h * 0.45), int(w * 0.25), accent, 15)

    draw = ImageDraw.Draw(canvas)

    # Headline — use multiline with centered alignment
    title_font = font_heavy(int(w * 0.078))
    sub_font = font_medium(int(w * 0.034))

    # Subtitle color: lighter version of accent
    sub_color = (
        min(255, accent[0] // 2 + 128),
        min(255, accent[1] // 2 + 128),
        min(255, accent[2] // 2 + 128),
    )

    # Calculate text position — headline starts at top with padding
    headline_y = int(h * 0.035)
    subtitle_y = text_multiline_centered(draw, headline, headline_y, w, title_font, (255, 255, 255))
    subtitle_y += int(h * 0.008)
    text_multiline_centered(draw, subtitle, subtitle_y, w, sub_font, sub_color)

    # Phone frame dimensions — larger phone, positioned lower
    frame_h = int(h * 0.72)
    frame_w = int(frame_h * 0.462)
    frame_x = (w - frame_w) // 2
    frame_y = h - frame_h - int(h * 0.02)  # phone extends to near bottom

    draw_phone_frame(canvas, screen, frame_x, frame_y, frame_w, frame_h)

    return canvas.convert("RGB")


def main():
    # Generate for each language and size combination
    language_configs = [
        ("English", SCREENSHOTS_EN, {
            "6.7": OUTPUT_67,
            "5.5": OUTPUT_55,
        }),
        ("Turkish", SCREENSHOTS_TR, {
            "6.7": OUTPUT_67_TR,
            "5.5": OUTPUT_55_TR,
        }),
    ]

    for lang_name, screenshots, output_dirs in language_configs:
        for size_name, dims in SIZES.items():
            output_dir = output_dirs[size_name]
            print(f"\nGenerating {lang_name} {size_name}\" screenshots ({dims[0]}x{dims[1]})...")

            for filename, headline, subtitle, bg_colors, accent in screenshots:
                img = create_store_screenshot(filename, headline, subtitle, bg_colors, accent, dims)
                if img:
                    path = os.path.join(output_dir, f"{filename}.png")
                    img.save(path, "PNG", quality=100)
                    print(f"  Done: {filename}.png")
                else:
                    print(f"  SKIPPED: {filename}.png (no raw screenshot)")

    print(f"\nAll screenshots generated!")
    print(f"  English 6.7\" -> {OUTPUT_67}")
    print(f"  English 5.5\" -> {OUTPUT_55}")
    print(f"  Turkish 6.7\" -> {OUTPUT_67_TR}")
    print(f"  Turkish 5.5\" -> {OUTPUT_55_TR}")


if __name__ == "__main__":
    main()

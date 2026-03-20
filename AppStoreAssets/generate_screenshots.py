#!/usr/bin/env python3
"""
Generate professional App Store screenshots for HabitLand.
Uses REAL app screenshots captured from simulator, wrapped in
device frames with gradient backgrounds and headlines.
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
RAW_DIR = os.path.join(BASE_DIR, "Screenshots")
OUTPUT_67 = os.path.join(BASE_DIR, "AppStore_6.7")
OUTPUT_55 = os.path.join(BASE_DIR, "AppStore_5.5")
os.makedirs(OUTPUT_67, exist_ok=True)
os.makedirs(OUTPUT_55, exist_ok=True)

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
SCREENSHOTS = [
    ("01_home_dashboard", "Build Better Habits",
     "Track your daily progress with beautiful insights",
     [(8, 47, 43), (10, 36, 34), (12, 24, 28), (15, 18, 25)],
     (52, 211, 153)),

    ("02_streaks_habits", "Never Break a Streak",
     "Stay consistent and watch your progress grow",
     [(60, 25, 8), (45, 18, 10), (28, 14, 12), (18, 12, 18)],
     (249, 115, 22)),

    ("03_sleep_tracking", "Sleep Better Tonight",
     "Track patterns and optimize your rest",
     [(35, 15, 60), (28, 12, 52), (18, 10, 38), (14, 10, 25)],
     (139, 92, 246)),

    ("04_social_leaderboard", "Compete With Friends",
     "Leaderboards, challenges and more",
     [(8, 22, 50), (6, 18, 42), (10, 14, 32), (12, 12, 22)],
     (59, 130, 246)),

    ("05_achievements_xp", "Earn XP & Level Up",
     "Gamified progress that keeps you going",
     [(50, 35, 8), (38, 25, 6), (24, 16, 8), (16, 12, 16)],
     (251, 191, 36)),

    ("06_premium_pro", "Unlock Everything",
     "Go Pro for unlimited habits & features",
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


def draw_phone_frame(canvas, screen_img, x, y, frame_w, frame_h, corner_radius=50):
    draw = ImageDraw.Draw(canvas)
    bezel = 8

    # Shadow
    shadow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow)
    for i in range(6):
        offset = (6 - i) * 5
        a = 8 + i * 4
        sdraw.rounded_rectangle(
            (x - bezel - offset, y - bezel - offset + 4,
             x + frame_w + bezel + offset, y + frame_h + bezel + offset + 8),
            radius=corner_radius + bezel + offset,
            fill=(0, 0, 0, a))
    canvas.paste(Image.alpha_composite(
        Image.new("RGBA", canvas.size, (0, 0, 0, 0)), shadow
    ), (0, 0), shadow)

    draw = ImageDraw.Draw(canvas)

    # Bezel
    draw.rounded_rectangle(
        (x - bezel - 2, y - bezel - 2, x + frame_w + bezel + 2, y + frame_h + bezel + 2),
        radius=corner_radius + bezel + 2, fill=(25, 25, 30, 255))
    draw.rounded_rectangle(
        (x - bezel, y - bezel, x + frame_w + bezel, y + frame_h + bezel),
        radius=corner_radius + bezel, fill=(40, 40, 48, 255))

    # Screen area
    draw.rounded_rectangle((x, y, x + frame_w, y + frame_h), radius=corner_radius,
                            fill=(255, 255, 255, 255))

    # Paste real screenshot
    resized = screen_img.resize((frame_w, frame_h), Image.LANCZOS)
    mask = Image.new("L", (frame_w, frame_h), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle((0, 0, frame_w, frame_h), radius=corner_radius, fill=255)

    if resized.mode != "RGBA":
        resized = resized.convert("RGBA")
    canvas.paste(resized, (x, y), mask)


def text_centered(draw, text, y, width, font, fill=(255, 255, 255)):
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    draw.text(((width - tw) // 2, y), text, font=font, fill=fill)


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

    # Headline
    title_font = font_heavy(int(w * 0.078))
    sub_font = font_medium(int(w * 0.034))

    # Subtitle color: lighter version of accent
    sub_color = (
        min(255, accent[0] // 2 + 128),
        min(255, accent[1] // 2 + 128),
        min(255, accent[2] // 2 + 128),
    )

    text_centered(draw, headline, int(h * 0.045), w, title_font, (255, 255, 255))
    text_centered(draw, subtitle, int(h * 0.1), w, sub_font, sub_color)

    # Phone frame dimensions
    frame_h = int(h * 0.68)
    frame_w = int(frame_h * 0.462)
    frame_x = (w - frame_w) // 2
    frame_y = int(h * 0.22)

    draw_phone_frame(canvas, screen, frame_x, frame_y, frame_w, frame_h)

    # Bottom pill badge
    draw = ImageDraw.Draw(canvas)
    pill_font = font_demibold(int(w * 0.024))
    pill_text = "HabitLand"
    bbox = draw.textbbox((0, 0), pill_text, font=pill_font)
    ptw = bbox[2] - bbox[0]
    px = (w - ptw - 24) // 2
    py = int(h * 0.945)
    draw.rounded_rectangle((px, py, px + ptw + 24, py + 28), radius=14,
                            fill=(255, 255, 255, 20))
    draw.text((px + 12, py + 4), pill_text, font=pill_font, fill=(255, 255, 255, 150))

    return canvas.convert("RGB")


def main():
    for size_name, dims in SIZES.items():
        output_dir = OUTPUT_67 if size_name == "6.7" else OUTPUT_55
        print(f"\nGenerating {size_name}\" screenshots ({dims[0]}x{dims[1]})...")

        for filename, headline, subtitle, bg_colors, accent in SCREENSHOTS:
            img = create_store_screenshot(filename, headline, subtitle, bg_colors, accent, dims)
            if img:
                path = os.path.join(output_dir, f"{filename}.png")
                img.save(path, "PNG", quality=100)
                print(f"  Done: {filename}.png")
            else:
                print(f"  SKIPPED: {filename}.png (no raw screenshot)")

    print(f"\nAll screenshots generated!")
    print(f"  6.7\" -> {OUTPUT_67}")
    print(f"  5.5\" -> {OUTPUT_55}")


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Generate professional App Store screenshots for HabitLand.
Creates 6.7" (1290x2796) and 5.5" (1242x2208) screenshot sets.
Uses only Pillow-renderable elements (no emojis - they don't render in Pillow).
"""

from PIL import Image, ImageDraw, ImageFont
import os
import math

# Directories
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
RAW_DIR = os.path.join(BASE_DIR, "Screenshots")
OUTPUT_67 = os.path.join(BASE_DIR, "AppStore_6.7")
OUTPUT_55 = os.path.join(BASE_DIR, "AppStore_5.5")

os.makedirs(OUTPUT_67, exist_ok=True)
os.makedirs(OUTPUT_55, exist_ok=True)

# Colors (HabitLand design system)
EMERALD = (52, 199, 89)
EMERALD_DARK = (30, 150, 60)
EMERALD_LIGHT = (235, 250, 238)
WHITE = (255, 255, 255)
NEAR_WHITE = (248, 248, 250)
DARK_TEXT = (26, 26, 31)
GRAY_TEXT = (115, 115, 128)
LIGHT_GRAY = (235, 235, 238)
GOLD = (255, 179, 0)
FLAME_ORANGE = (255, 100, 50)
SLEEP_PURPLE = (102, 89, 204)
SLEEP_LIGHT = (235, 230, 255)
BLUE = (51, 143, 255)
CORAL = (242, 77, 77)
PINK = (242, 125, 141)

SIZES = {
    "6.7": (1290, 2796),
    "5.5": (1242, 2208),
}


def get_font(size, bold=False):
    """Get system font at given size."""
    if bold:
        bold_paths = [
            "/Library/Fonts/SF-Pro-Display-Bold.otf",
            "/Library/Fonts/SF-Pro-Text-Bold.otf",
            "/System/Library/Fonts/SFNSDisplay-Bold.otf",
        ]
        for p in bold_paths:
            if os.path.exists(p):
                try:
                    return ImageFont.truetype(p, size)
                except:
                    pass
    regular_paths = [
        "/Library/Fonts/SF-Pro-Display-Regular.otf",
        "/Library/Fonts/SF-Pro-Text-Regular.otf",
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/SFNSDisplay.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/System/Library/Fonts/HelveticaNeue.ttc",
    ]
    for p in regular_paths:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except:
                pass
    return ImageFont.load_default()


def get_font_medium(size):
    """Get medium weight font."""
    medium_paths = [
        "/Library/Fonts/SF-Pro-Display-Medium.otf",
        "/Library/Fonts/SF-Pro-Text-Medium.otf",
        "/Library/Fonts/SF-Pro-Display-Semibold.otf",
    ]
    for p in medium_paths:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except:
                pass
    return get_font(size, bold=True)


def draw_rounded_rect(draw, xy, radius, fill=None, outline=None, width=1):
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)


def create_gradient(size, color_top, color_bottom):
    img = Image.new("RGB", size)
    pixels = img.load()
    w, h = size
    for y in range(h):
        ratio = y / h
        r = int(color_top[0] + (color_bottom[0] - color_top[0]) * ratio)
        g = int(color_top[1] + (color_bottom[1] - color_top[1]) * ratio)
        b = int(color_top[2] + (color_bottom[2] - color_top[2]) * ratio)
        for x in range(w):
            pixels[x, y] = (r, g, b)
    return img


def draw_icon_circle(draw, cx, cy, r, bg_color, letter, font, text_color=WHITE):
    """Draw a colored circle with a letter/symbol inside."""
    draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=bg_color)
    bbox = draw.textbbox((0, 0), letter, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    draw.text((cx - tw // 2, cy - th // 2 - 2), letter, font=font, fill=text_color)


def draw_device_frame(canvas, draw, screen_img, x, y, frame_w, frame_h, corner_radius=60):
    """Draw an iPhone-style device frame with the screen image inside."""
    bezel = 14
    bx1, by1 = x - bezel, y - bezel
    bx2, by2 = x + frame_w + bezel, y + frame_h + bezel

    # Outer shadow (multiple layers)
    for i in range(5):
        offset = (5 - i) * 4
        shadow_alpha = 20 + i * 8
        shadow_color = (shadow_alpha, shadow_alpha, shadow_alpha + 5)
        draw_rounded_rect(draw,
            (bx1 - offset, by1 - offset + 2, bx2 + offset, by2 + offset + 6),
            corner_radius + bezel + offset,
            fill=shadow_color)

    # Bezel
    draw_rounded_rect(draw, (bx1 - 3, by1 - 3, bx2 + 3, by2 + 3),
                       corner_radius + bezel + 3, fill=(15, 15, 18))
    draw_rounded_rect(draw, (bx1, by1, bx2, by2),
                       corner_radius + bezel, fill=(35, 35, 40))
    # Screen clip area
    draw_rounded_rect(draw, (x, y, x + frame_w, y + frame_h),
                       corner_radius, fill=WHITE)

    # Paste screen
    resized = screen_img.resize((frame_w, frame_h), Image.LANCZOS)
    mask = Image.new("L", (frame_w, frame_h), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle((0, 0, frame_w, frame_h), radius=corner_radius, fill=255)
    canvas.paste(resized, (x, y), mask)

    # Dynamic Island
    island_w = int(frame_w * 0.27)
    island_h = int(frame_h * 0.013)
    island_x = x + (frame_w - island_w) // 2
    island_y = y + int(frame_h * 0.013)
    draw_rounded_rect(draw, (island_x, island_y, island_x + island_w, island_y + island_h),
                       island_h // 2, fill=(0, 0, 0))


def draw_text_centered(draw, text, y, width, font, fill=WHITE):
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    x = (width - tw) // 2
    draw.text((x, y), text, font=font, fill=fill)


def get_frame_dims(w, h):
    """Calculate device frame dimensions for given canvas size."""
    frame_h = int(h * 0.72)
    frame_w = int(frame_h * 0.461)  # iPhone aspect ratio ~1179/2556
    frame_x = (w - frame_w) // 2
    frame_y = int(h * 0.17)
    return frame_x, frame_y, frame_w, frame_h


# ========================
# Screenshot 1: Home Dashboard (uses real screenshot)
# ========================
def create_screenshot_1(size_name, dims):
    w, h = dims
    canvas = create_gradient((w, h), (230, 248, 235), (195, 235, 208))
    draw = ImageDraw.Draw(canvas)

    title_font = get_font(int(w * 0.062), bold=True)
    sub_font = get_font_medium(int(w * 0.033))

    draw_text_centered(draw, "Build Better Habits", int(h * 0.055), w, title_font, DARK_TEXT)
    draw_text_centered(draw, "Track progress & stay motivated daily", int(h * 0.105), w, sub_font, GRAY_TEXT)

    raw_path = os.path.join(RAW_DIR, "raw_home.png")
    screen = Image.open(raw_path) if os.path.exists(raw_path) else Image.new("RGB", (1179, 2556), NEAR_WHITE)

    fx, fy, fw, fh = get_frame_dims(w, h)
    draw_device_frame(canvas, draw, screen, fx, fy, fw, fh)

    # Bottom branding
    brand_font = get_font_medium(int(w * 0.03))
    draw_text_centered(draw, "HabitLand", int(h * 0.935), w, brand_font, EMERALD_DARK)

    return canvas


# ========================
# Screenshot 2: Streak & Habits
# ========================
def create_screenshot_2(size_name, dims):
    w, h = dims
    canvas = create_gradient((w, h), (255, 243, 228), (255, 228, 195))
    draw = ImageDraw.Draw(canvas)

    title_font = get_font(int(w * 0.062), bold=True)
    sub_font = get_font_medium(int(w * 0.033))

    draw_text_centered(draw, "Never Break a Streak", int(h * 0.055), w, title_font, DARK_TEXT)
    draw_text_centered(draw, "Stay consistent & earn rewards", int(h * 0.105), w, sub_font, GRAY_TEXT)

    fx, fy, fw, fh = get_frame_dims(w, h)
    mock = create_mock_streak_screen(fw, fh)
    draw_device_frame(canvas, draw, mock, fx, fy, fw, fh)

    brand_font = get_font_medium(int(w * 0.03))
    draw_text_centered(draw, "Streaks & Rewards", int(h * 0.935), w, brand_font, FLAME_ORANGE)

    return canvas


def create_mock_streak_screen(w, h):
    img = Image.new("RGB", (w, h), NEAR_WHITE)
    draw = ImageDraw.Draw(img)

    header_font = get_font(int(w * 0.07), bold=True)
    name_font = get_font_medium(int(w * 0.042))
    cat_font = get_font(int(w * 0.032))
    streak_font = get_font(int(w * 0.038), bold=True)
    icon_font = get_font(int(w * 0.035), bold=True)

    margin = int(w * 0.06)
    y = int(h * 0.06)

    # Status bar placeholder
    y = int(h * 0.055)
    draw.text((margin, y), "My Habits", font=header_font, fill=DARK_TEXT)

    # Count + sort
    y += int(h * 0.055)
    count_font = get_font(int(w * 0.03))
    draw.text((margin, y), "5 habits", font=count_font, fill=GRAY_TEXT)
    draw.text((w - margin - int(w * 0.18), y), "Sort: Streak", font=count_font, fill=GRAY_TEXT)
    y += int(h * 0.035)

    habits = [
        ("M", "Meditate", "Mindfulness", 30, SLEEP_PURPLE, 0.8),
        ("E", "Eat Healthy", "Nutrition", 21, EMERALD, 1.0),
        ("D", "Drink Water", "Health", 14, BLUE, 1.0),
        ("W", "Morning Walk", "Fitness", 7, EMERALD, 1.0),
        ("R", "Read 20 min", "Learning", 5, GOLD, 0.6),
    ]

    card_h = int(h * 0.085)
    card_spacing = int(h * 0.012)

    for letter, name, cat, streak, color, progress in habits:
        cx1, cy1 = margin, y
        cx2, cy2 = w - margin, y + card_h
        draw_rounded_rect(draw, (cx1, cy1, cx2, cy2), int(w * 0.04), fill=WHITE, outline=LIGHT_GRAY, width=1)

        # Icon circle
        circle_r = int(card_h * 0.32)
        circle_cx = cx1 + int(w * 0.08)
        circle_cy = y + card_h // 2
        light_color = (color[0], color[1], color[2], 30)
        draw.ellipse((circle_cx - circle_r, circle_cy - circle_r,
                       circle_cx + circle_r, circle_cy + circle_r),
                      fill=(color[0] // 4 + 191, color[1] // 4 + 191, color[2] // 4 + 191))
        draw_icon_circle(draw, circle_cx, circle_cy, circle_r,
                         (color[0] // 4 + 191, color[1] // 4 + 191, color[2] // 4 + 191),
                         letter, icon_font, color)

        # Name + category
        name_x = cx1 + int(w * 0.17)
        draw.text((name_x, y + int(card_h * 0.18)), name, font=name_font, fill=DARK_TEXT)
        draw.text((name_x, y + int(card_h * 0.55)), cat, font=cat_font, fill=GRAY_TEXT)

        # Streak (flame triangle + number)
        streak_x = cx2 - int(w * 0.2)
        streak_cy = y + card_h // 2 - int(h * 0.008)

        # Draw a simple flame shape
        flame_color = FLAME_ORANGE if streak < 14 else GOLD if streak < 30 else CORAL
        fx = streak_x
        fy = streak_cy - 4
        flame_pts = [
            (fx, fy + 12), (fx + 4, fy + 4), (fx + 7, fy - 4),
            (fx + 8, fy), (fx + 10, fy - 6),
            (fx + 14, fy + 4), (fx + 16, fy + 12),
            (fx + 12, fy + 16), (fx + 4, fy + 16),
        ]
        draw.polygon(flame_pts, fill=flame_color)
        draw.text((streak_x + 20, streak_cy - 2), str(streak), font=streak_font, fill=DARK_TEXT)

        # Progress ring
        ring_cx = cx2 - int(w * 0.07)
        ring_cy = y + card_h // 2
        ring_r = int(w * 0.03)
        # BG ring
        draw.arc((ring_cx - ring_r, ring_cy - ring_r, ring_cx + ring_r, ring_cy + ring_r),
                 0, 360, fill=LIGHT_GRAY, width=4)
        # Progress arc
        end_angle = -90 + int(360 * progress)
        if progress > 0:
            draw.arc((ring_cx - ring_r, ring_cy - ring_r, ring_cx + ring_r, ring_cy + ring_r),
                     -90, end_angle, fill=color, width=4)
        if progress >= 1.0:
            check = get_font(int(w * 0.028), bold=True)
            bbox = draw.textbbox((0, 0), "✓", font=check)
            tw = bbox[2] - bbox[0]
            th = bbox[3] - bbox[1]
            draw.text((ring_cx - tw // 2, ring_cy - th // 2 - 1), "✓", font=check, fill=color)

        y += card_h + card_spacing

    # FAB button
    fab_r = int(w * 0.055)
    fab_cx = w - margin - fab_r - int(w * 0.02)
    fab_cy = int(h * 0.88)
    draw.ellipse((fab_cx - fab_r, fab_cy - fab_r, fab_cx + fab_r, fab_cy + fab_r), fill=EMERALD)
    plus_font = get_font(int(w * 0.06), bold=True)
    bbox = draw.textbbox((0, 0), "+", font=plus_font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    draw.text((fab_cx - tw // 2, fab_cy - th // 2 - 3), "+", font=plus_font, fill=WHITE)

    # Tab bar
    tab_y = int(h * 0.93)
    draw.rectangle((0, tab_y, w, h), fill=WHITE)
    draw.line((0, tab_y, w, tab_y), fill=LIGHT_GRAY, width=1)
    tab_labels = ["Home", "Habits", "Sleep", "Social", "Profile"]
    tab_colors = [GRAY_TEXT, EMERALD, GRAY_TEXT, GRAY_TEXT, GRAY_TEXT]
    tab_w = w // 5
    tab_font = get_font(int(w * 0.024))
    for i, (label, tc) in enumerate(zip(tab_labels, tab_colors)):
        bbox = draw.textbbox((0, 0), label, font=tab_font)
        tw = bbox[2] - bbox[0]
        tx = i * tab_w + (tab_w - tw) // 2
        draw.text((tx, tab_y + int(h * 0.02)), label, font=tab_font, fill=tc)
        # Small dot for active
        if i == 1:
            dot_cx = i * tab_w + tab_w // 2
            draw.ellipse((dot_cx - 3, tab_y + int(h * 0.01) - 1, dot_cx + 3, tab_y + int(h * 0.01) + 5), fill=EMERALD)

    return img


# ========================
# Screenshot 3: Sleep Tracking
# ========================
def create_screenshot_3(size_name, dims):
    w, h = dims
    canvas = create_gradient((w, h), (228, 222, 250), (198, 188, 238))
    draw = ImageDraw.Draw(canvas)

    title_font = get_font(int(w * 0.062), bold=True)
    sub_font = get_font_medium(int(w * 0.033))

    draw_text_centered(draw, "Sleep Better Tonight", int(h * 0.055), w, title_font, DARK_TEXT)
    draw_text_centered(draw, "Track patterns & optimize your rest", int(h * 0.105), w, sub_font, GRAY_TEXT)

    fx, fy, fw, fh = get_frame_dims(w, h)
    mock = create_mock_sleep_screen(fw, fh)
    draw_device_frame(canvas, draw, mock, fx, fy, fw, fh)

    brand_font = get_font_medium(int(w * 0.03))
    draw_text_centered(draw, "Sleep Insights", int(h * 0.935), w, brand_font, SLEEP_PURPLE)

    return canvas


def create_mock_sleep_screen(w, h):
    img = Image.new("RGB", (w, h), NEAR_WHITE)
    draw = ImageDraw.Draw(img)

    header_font = get_font(int(w * 0.07), bold=True)
    big_font = get_font(int(w * 0.13), bold=True)
    sub_font = get_font_medium(int(w * 0.038))
    small_font = get_font(int(w * 0.030))
    tiny_font = get_font(int(w * 0.026))

    margin = int(w * 0.06)
    y = int(h * 0.055)
    draw.text((margin, y), "Sleep", font=header_font, fill=DARK_TEXT)
    y += int(h * 0.065)

    # Duration card
    card_h = int(h * 0.2)
    draw_rounded_rect(draw, (margin, y, w - margin, y + card_h), int(w * 0.04),
                       fill=WHITE, outline=LIGHT_GRAY)
    draw.text((margin + int(w * 0.05), y + int(card_h * 0.12)), "Last Night", font=small_font, fill=GRAY_TEXT)
    draw.text((margin + int(w * 0.05), y + int(card_h * 0.30)), "7h 42m", font=big_font, fill=SLEEP_PURPLE)

    # Quality indicator - colored dot + text
    qy = y + int(card_h * 0.75)
    qx = margin + int(w * 0.05)
    draw.ellipse((qx, qy, qx + 12, qy + 12), fill=EMERALD)
    draw.text((qx + 18, qy - 2), "Good quality  |  11:15 PM - 6:57 AM", font=small_font, fill=GRAY_TEXT)

    y += card_h + int(h * 0.025)

    # Weekly chart
    draw.text((margin, y), "This Week", font=sub_font, fill=DARK_TEXT)
    y += int(h * 0.04)

    days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    hours = [7.5, 6.8, 8.1, 7.2, 6.5, 9.0, 7.8]
    bar_area_w = w - 2 * margin
    bar_spacing = bar_area_w // 7
    bar_w = int(bar_spacing * 0.55)
    max_bar_h = int(h * 0.18)

    for i, (day, hrs) in enumerate(zip(days, hours)):
        bx = margin + i * bar_spacing + (bar_spacing - bar_w) // 2
        bar_h = int(max_bar_h * (hrs / 10))
        by = y + max_bar_h - bar_h

        # Gradient-like color based on hours
        intensity = hrs / 10
        purple = (
            int(SLEEP_PURPLE[0] * intensity + 220 * (1 - intensity)),
            int(SLEEP_PURPLE[1] * intensity + 210 * (1 - intensity)),
            int(SLEEP_PURPLE[2] * intensity + 240 * (1 - intensity))
        )
        draw_rounded_rect(draw, (bx, by, bx + bar_w, y + max_bar_h), int(bar_w * 0.3), fill=purple)

        # Day label
        bbox = draw.textbbox((0, 0), day, font=tiny_font)
        tw = bbox[2] - bbox[0]
        draw.text((bx + (bar_w - tw) // 2, y + max_bar_h + 8), day, font=tiny_font, fill=GRAY_TEXT)

        # Hours label
        hrs_text = f"{hrs:.0f}h"
        bbox2 = draw.textbbox((0, 0), hrs_text, font=tiny_font)
        tw2 = bbox2[2] - bbox2[0]
        draw.text((bx + (bar_w - tw2) // 2, by - 20), hrs_text, font=tiny_font, fill=SLEEP_PURPLE)

    y += max_bar_h + int(h * 0.065)

    # Stats cards
    stats = [("Avg Duration", "7h 26m"), ("Best Night", "9h 00m"), ("Sleep Score", "82/100")]
    stat_w = (w - 2 * margin - int(w * 0.04)) // 3
    for i, (label, value) in enumerate(stats):
        sx = margin + i * (stat_w + int(w * 0.02))
        sy = y
        draw_rounded_rect(draw, (sx, sy, sx + stat_w, sy + int(h * 0.075)),
                           int(w * 0.025), fill=WHITE, outline=LIGHT_GRAY)
        draw.text((sx + int(w * 0.02), sy + int(h * 0.01)), label, font=tiny_font, fill=GRAY_TEXT)
        draw.text((sx + int(w * 0.02), sy + int(h * 0.035)), value, font=sub_font, fill=DARK_TEXT)

    return img


# ========================
# Screenshot 4: Achievements & XP
# ========================
def create_screenshot_4(size_name, dims):
    w, h = dims
    canvas = create_gradient((w, h), (255, 247, 222), (255, 232, 185))
    draw = ImageDraw.Draw(canvas)

    title_font = get_font(int(w * 0.062), bold=True)
    sub_font = get_font_medium(int(w * 0.033))

    draw_text_centered(draw, "Earn XP & Level Up", int(h * 0.055), w, title_font, DARK_TEXT)
    draw_text_centered(draw, "Gamified progress keeps you going", int(h * 0.105), w, sub_font, GRAY_TEXT)

    fx, fy, fw, fh = get_frame_dims(w, h)
    mock = create_mock_achievements_screen(fw, fh)
    draw_device_frame(canvas, draw, mock, fx, fy, fw, fh)

    brand_font = get_font_medium(int(w * 0.03))
    draw_text_centered(draw, "Gamified Progress", int(h * 0.935), w, brand_font, (180, 130, 0))

    return canvas


def create_mock_achievements_screen(w, h):
    img = Image.new("RGB", (w, h), NEAR_WHITE)
    draw = ImageDraw.Draw(img)

    header_font = get_font(int(w * 0.07), bold=True)
    level_font = get_font(int(w * 0.10), bold=True)
    sub_font = get_font_medium(int(w * 0.038))
    name_font = get_font_medium(int(w * 0.036))
    small_font = get_font(int(w * 0.030))
    stat_val_font = get_font(int(w * 0.05), bold=True)
    icon_font = get_font(int(w * 0.04), bold=True)

    margin = int(w * 0.06)
    y = int(h * 0.055)
    draw.text((margin, y), "Profile", font=header_font, fill=DARK_TEXT)
    y += int(h * 0.065)

    # Profile card
    card_h = int(h * 0.16)
    draw_rounded_rect(draw, (margin, y, w - margin, y + card_h), int(w * 0.04),
                       fill=WHITE, outline=LIGHT_GRAY)

    # Avatar
    avatar_r = int(card_h * 0.28)
    avatar_cx = margin + int(w * 0.11)
    avatar_cy = y + int(card_h * 0.45)
    draw.ellipse((avatar_cx - avatar_r, avatar_cy - avatar_r,
                   avatar_cx + avatar_r, avatar_cy + avatar_r), fill=EMERALD_LIGHT)
    leaf_font = get_font(int(w * 0.04), bold=True)
    draw_icon_circle(draw, avatar_cx, avatar_cy, avatar_r, EMERALD_LIGHT, "A", leaf_font, EMERALD)

    # Name + Level
    info_x = margin + int(w * 0.23)
    draw.text((info_x, y + int(card_h * 0.15)), "Alex Johnson", font=name_font, fill=DARK_TEXT)
    draw.text((info_x, y + int(card_h * 0.40)), "Level 5", font=level_font, fill=EMERALD)

    # XP bar
    bar_y = y + int(card_h * 0.78)
    bar_w_total = w - margin - info_x - int(w * 0.06)
    draw_rounded_rect(draw, (info_x, bar_y, info_x + bar_w_total, bar_y + 10),
                       5, fill=LIGHT_GRAY)
    draw_rounded_rect(draw, (info_x, bar_y, info_x + int(bar_w_total * 0.65), bar_y + 10),
                       5, fill=EMERALD)
    xp_font = get_font(int(w * 0.022))
    draw.text((info_x + bar_w_total + 6, bar_y - 3), "650/1000 XP", font=xp_font, fill=GRAY_TEXT)

    y += card_h + int(h * 0.025)

    # Stats
    draw.text((margin, y), "Stats", font=sub_font, fill=DARK_TEXT)
    y += int(h * 0.04)

    stats_data = [
        (FLAME_ORANGE, "42", "Day Streak"),
        (EMERALD, "186", "Completions"),
        (BLUE, "28", "Days Active"),
    ]
    stat_w = (w - 2 * margin - int(w * 0.04)) // 3
    for i, (color, val, label) in enumerate(stats_data):
        sx = margin + i * (stat_w + int(w * 0.02))
        stat_h = int(h * 0.09)
        draw_rounded_rect(draw, (sx, y, sx + stat_w, y + stat_h),
                           int(w * 0.025), fill=WHITE, outline=LIGHT_GRAY)
        # Colored top bar
        draw_rounded_rect(draw, (sx + 2, y + 2, sx + stat_w - 2, y + 6),
                           3, fill=color)
        draw_text_centered(draw, val, y + int(stat_h * 0.2), sx * 2 + stat_w, stat_val_font, DARK_TEXT)
        draw_text_centered(draw, label, y + int(stat_h * 0.6), sx * 2 + stat_w, small_font, GRAY_TEXT)

    y += int(h * 0.115)

    # Achievements
    draw.text((margin, y), "Achievements", font=sub_font, fill=DARK_TEXT)
    y += int(h * 0.04)

    achievements = [
        (GOLD, "*", "First Step", "Complete your first habit", True),
        (FLAME_ORANGE, "F", "On Fire", "7-day streak", True),
        (BLUE, "D", "Unstoppable", "30-day streak", False),
        (EMERALD, "C", "Century", "100 completions", False),
    ]

    ach_h = int(h * 0.065)
    for color, letter, name, desc, unlocked in achievements:
        bg = WHITE if unlocked else (245, 245, 247)
        draw_rounded_rect(draw, (margin, y, w - margin, y + ach_h),
                           int(w * 0.025), fill=bg, outline=LIGHT_GRAY)

        # Icon circle
        ir = int(ach_h * 0.3)
        icx = margin + int(w * 0.06)
        icy = y + ach_h // 2
        icon_bg = color if unlocked else (200, 200, 205)
        draw_icon_circle(draw, icx, icy, ir, icon_bg, letter, icon_font, WHITE)

        # Text
        txt_x = margin + int(w * 0.14)
        txt_color = DARK_TEXT if unlocked else (180, 180, 185)
        desc_color = GRAY_TEXT if unlocked else (200, 200, 205)
        draw.text((txt_x, y + int(ach_h * 0.15)), name, font=name_font, fill=txt_color)
        draw.text((txt_x, y + int(ach_h * 0.55)), desc, font=small_font, fill=desc_color)

        # Check mark
        if unlocked:
            check_font = get_font(int(w * 0.035), bold=True)
            draw.text((w - margin - int(w * 0.06), y + int(ach_h * 0.2)), "✓", font=check_font, fill=EMERALD)

        y += ach_h + int(h * 0.008)

    return img


# ========================
# Screenshot 5: Premium / Paywall
# ========================
def create_screenshot_5(size_name, dims):
    w, h = dims
    canvas = create_gradient((w, h), (232, 242, 255), (208, 222, 248))
    draw = ImageDraw.Draw(canvas)

    title_font = get_font(int(w * 0.062), bold=True)
    sub_font = get_font_medium(int(w * 0.033))

    draw_text_centered(draw, "Unlock Everything", int(h * 0.055), w, title_font, DARK_TEXT)
    draw_text_centered(draw, "Go Pro for unlimited habits & features", int(h * 0.105), w, sub_font, GRAY_TEXT)

    fx, fy, fw, fh = get_frame_dims(w, h)
    mock = create_mock_paywall_screen(fw, fh)
    draw_device_frame(canvas, draw, mock, fx, fy, fw, fh)

    brand_font = get_font_medium(int(w * 0.03))
    draw_text_centered(draw, "HabitLand Pro", int(h * 0.935), w, brand_font, (130, 100, 10))

    return canvas


def create_mock_paywall_screen(w, h):
    img = Image.new("RGB", (w, h), NEAR_WHITE)
    draw = ImageDraw.Draw(img)

    header_font = get_font(int(w * 0.08), bold=True)
    price_font = get_font(int(w * 0.065), bold=True)
    sub_font = get_font_medium(int(w * 0.038))
    feature_font = get_font_medium(int(w * 0.034))
    small_font = get_font(int(w * 0.028))
    badge_font = get_font(int(w * 0.022), bold=True)
    btn_font = get_font(int(w * 0.042), bold=True)

    margin = int(w * 0.08)
    y = int(h * 0.05)

    # Crown icon (drawn as a golden shape)
    crown_cx = w // 2
    crown_cy = y + int(h * 0.04)
    crown_r = int(w * 0.08)
    draw.ellipse((crown_cx - crown_r, crown_cy - crown_r,
                   crown_cx + crown_r, crown_cy + crown_r), fill=(255, 240, 200))
    crown_font = get_font(int(w * 0.06), bold=True)
    draw_icon_circle(draw, crown_cx, crown_cy, crown_r, (255, 240, 200), "P", crown_font, GOLD)

    y += int(h * 0.09)
    draw_text_centered(draw, "Go Pro", y, w, header_font, DARK_TEXT)
    y += int(h * 0.05)
    draw_text_centered(draw, "Unlock your full potential", y, w, sub_font, GRAY_TEXT)
    y += int(h * 0.055)

    # Feature list with checkmarks
    features = [
        (EMERALD, "Unlimited Habits"),
        (SLEEP_PURPLE, "Sleep Tracking"),
        (BLUE, "Social Features"),
        (FLAME_ORANGE, "Advanced Analytics"),
        (GOLD, "All Achievements"),
        (PINK, "Premium Effects"),
    ]

    for color, text in features:
        # Checkmark circle
        check_r = int(w * 0.025)
        check_cx = margin + check_r
        check_cy = y + int(h * 0.012)
        draw.ellipse((check_cx - check_r, check_cy - check_r,
                       check_cx + check_r, check_cy + check_r), fill=color)
        check_font = get_font(int(w * 0.02), bold=True)
        draw_icon_circle(draw, check_cx, check_cy, check_r, color, "✓", check_font, WHITE)

        draw.text((margin + int(w * 0.08), y), text, font=feature_font, fill=DARK_TEXT)
        y += int(h * 0.038)

    y += int(h * 0.025)

    # Plan cards
    card_gap = int(w * 0.04)
    card_w = (w - 2 * margin - card_gap) // 2
    card_h = int(h * 0.14)

    # Yearly card
    yx1, yy1 = margin, y
    yx2, yy2 = margin + card_w, y + card_h
    draw_rounded_rect(draw, (yx1, yy1, yx2, yy2), int(w * 0.035),
                       fill=WHITE, outline=(200, 200, 205), width=2)
    draw_text_centered(draw, "Yearly", yy1 + int(card_h * 0.12),
                        yx1 + yx2, small_font, GRAY_TEXT)
    draw_text_centered(draw, "$19.99", yy1 + int(card_h * 0.35),
                        yx1 + yx2, price_font, DARK_TEXT)
    draw_text_centered(draw, "/year", yy1 + int(card_h * 0.70),
                        yx1 + yx2, small_font, GRAY_TEXT)

    # Lifetime card (highlighted)
    lx1 = margin + card_w + card_gap
    lx2 = lx1 + card_w
    draw_rounded_rect(draw, (lx1, yy1, lx2, yy2), int(w * 0.035),
                       fill=EMERALD, outline=EMERALD_DARK, width=2)

    # Best Deal badge
    bdg_w = int(card_w * 0.65)
    bdg_h = int(h * 0.022)
    bdg_x = lx1 + (card_w - bdg_w) // 2
    bdg_y = yy1 - bdg_h // 2
    draw_rounded_rect(draw, (bdg_x, bdg_y, bdg_x + bdg_w, bdg_y + bdg_h),
                       bdg_h // 2, fill=GOLD)
    draw_text_centered(draw, "BEST DEAL", bdg_y + 1, bdg_x + bdg_x + bdg_w, badge_font, WHITE)

    draw_text_centered(draw, "Lifetime", yy1 + int(card_h * 0.12),
                        lx1 + lx2, small_font, (220, 255, 230))
    draw_text_centered(draw, "$39.99", yy1 + int(card_h * 0.35),
                        lx1 + lx2, price_font, WHITE)
    draw_text_centered(draw, "one-time", yy1 + int(card_h * 0.70),
                        lx1 + lx2, small_font, (200, 245, 215))

    y = yy2 + int(h * 0.035)

    # CTA button
    btn_h = int(h * 0.055)
    draw_rounded_rect(draw, (margin, y, w - margin, y + btn_h),
                       btn_h // 2, fill=EMERALD)
    draw_text_centered(draw, "Unlock Pro", y + int(btn_h * 0.18), w, btn_font, WHITE)

    y += btn_h + int(h * 0.02)
    draw_text_centered(draw, "Restore Purchases", y, w, small_font, GRAY_TEXT)

    return img


# ========================
# Screenshot 6: Social & Leaderboard
# ========================
def create_screenshot_6(size_name, dims):
    w, h = dims
    canvas = create_gradient((w, h), (228, 242, 255), (205, 228, 252))
    draw = ImageDraw.Draw(canvas)

    title_font = get_font(int(w * 0.062), bold=True)
    sub_font = get_font_medium(int(w * 0.033))

    draw_text_centered(draw, "Compete With Friends", int(h * 0.055), w, title_font, DARK_TEXT)
    draw_text_centered(draw, "Leaderboards, challenges & more", int(h * 0.105), w, sub_font, GRAY_TEXT)

    fx, fy, fw, fh = get_frame_dims(w, h)
    mock = create_mock_social_screen(fw, fh)
    draw_device_frame(canvas, draw, mock, fx, fy, fw, fh)

    brand_font = get_font_medium(int(w * 0.03))
    draw_text_centered(draw, "Social & Leaderboards", int(h * 0.935), w, brand_font, BLUE)

    return canvas


def create_mock_social_screen(w, h):
    img = Image.new("RGB", (w, h), NEAR_WHITE)
    draw = ImageDraw.Draw(img)

    header_font = get_font(int(w * 0.07), bold=True)
    name_font = get_font_medium(int(w * 0.040))
    sub_font = get_font(int(w * 0.032))
    rank_font = get_font(int(w * 0.038), bold=True)
    icon_font = get_font(int(w * 0.032), bold=True)

    margin = int(w * 0.06)
    y = int(h * 0.055)
    draw.text((margin, y), "Leaderboard", font=header_font, fill=DARK_TEXT)
    y += int(h * 0.065)

    # Segment control
    seg_h = int(h * 0.032)
    draw_rounded_rect(draw, (margin, y, w - margin, y + seg_h), seg_h // 2, fill=LIGHT_GRAY)
    seg_w = (w - 2 * margin) // 3
    draw_rounded_rect(draw, (margin + 2, y + 2, margin + seg_w - 2, y + seg_h - 2),
                       (seg_h - 4) // 2, fill=WHITE)
    seg_font = get_font(int(w * 0.026))
    labels = ["Weekly", "Monthly", "All Time"]
    for i, label in enumerate(labels):
        bbox = draw.textbbox((0, 0), label, font=seg_font)
        tw = bbox[2] - bbox[0]
        lx = margin + i * seg_w + (seg_w - tw) // 2
        color = DARK_TEXT if i == 0 else GRAY_TEXT
        draw.text((lx, y + int(seg_h * 0.2)), label, font=seg_font, fill=color)

    y += seg_h + int(h * 0.025)

    # Leaderboard entries
    leaders = [
        (1, "Alex", "A", (255, 200, 50), "Lvl 12", "42 day streak", (255, 248, 225)),
        (2, "Sarah", "S", (192, 192, 210), "Lvl 10", "28 day streak", WHITE),
        (3, "Mike", "M", (220, 160, 100), "Lvl 8", "21 day streak", WHITE),
    ]

    card_h = int(h * 0.08)
    for rank, name, letter, badge_color, level, streak, bg in leaders:
        cx1, cy1 = margin, y
        cx2, cy2 = w - margin, y + card_h
        draw_rounded_rect(draw, (cx1, cy1, cx2, cy2), int(w * 0.03), fill=bg, outline=LIGHT_GRAY)

        # Rank number
        rx = cx1 + int(w * 0.04)
        ry = y + card_h // 2
        draw.text((rx, ry - int(h * 0.012)), f"#{rank}", font=rank_font, fill=badge_color)

        # Avatar circle
        ar = int(card_h * 0.28)
        acx = cx1 + int(w * 0.14)
        acy = y + card_h // 2
        draw_icon_circle(draw, acx, acy, ar, badge_color, letter, icon_font, WHITE)

        # Name + details
        nx = cx1 + int(w * 0.24)
        draw.text((nx, y + int(card_h * 0.18)), name, font=name_font, fill=DARK_TEXT)
        draw.text((nx, y + int(card_h * 0.55)), f"{level}  |  {streak}", font=sub_font, fill=GRAY_TEXT)

        y += card_h + int(h * 0.01)

    y += int(h * 0.015)

    # More entries (including "You")
    others = [
        (4, "Emma", "E", PINK, "Lvl 7", "14 days", WHITE, False),
        (5, "You", "Y", EMERALD, "Lvl 5", "7 days", EMERALD_LIGHT, True),
        (6, "James", "J", BLUE, "Lvl 4", "5 days", WHITE, False),
        (7, "Lily", "L", SLEEP_PURPLE, "Lvl 3", "3 days", WHITE, False),
    ]

    for rank, name, letter, color, level, streak, bg, is_you in others:
        card_h2 = int(h * 0.07)
        border = EMERALD if is_you else LIGHT_GRAY
        bw = 2 if is_you else 1
        draw_rounded_rect(draw, (margin, y, w - margin, y + card_h2), int(w * 0.025),
                           fill=bg, outline=border, width=bw)

        rx = margin + int(w * 0.04)
        draw.text((rx, y + int(card_h2 * 0.25)), f"#{rank}", font=rank_font, fill=GRAY_TEXT)

        ar = int(card_h2 * 0.3)
        acx = margin + int(w * 0.14)
        acy = y + card_h2 // 2
        draw_icon_circle(draw, acx, acy, ar, color, letter, icon_font, WHITE)

        nx = margin + int(w * 0.24)
        name_color = EMERALD_DARK if is_you else DARK_TEXT
        draw.text((nx, y + int(card_h2 * 0.18)), name, font=name_font, fill=name_color)
        draw.text((nx, y + int(card_h2 * 0.55)), f"{level}  |  {streak}", font=sub_font, fill=GRAY_TEXT)

        y += card_h2 + int(h * 0.008)

    return img


# ========================
# Main
# ========================
def main():
    generators = [
        ("01_home_dashboard", create_screenshot_1),
        ("02_streaks_habits", create_screenshot_2),
        ("03_sleep_tracking", create_screenshot_3),
        ("04_achievements_xp", create_screenshot_4),
        ("05_premium_pro", create_screenshot_5),
        ("06_social_leaderboard", create_screenshot_6),
    ]

    for size_name, dims in SIZES.items():
        output_dir = OUTPUT_67 if size_name == "6.7" else OUTPUT_55
        print(f"\nGenerating {size_name}\" screenshots ({dims[0]}x{dims[1]})...")

        for filename, generator in generators:
            img = generator(size_name, dims)
            path = os.path.join(output_dir, f"{filename}.png")
            img.save(path, "PNG", quality=100)
            print(f"  Done: {filename}.png")

    print(f"\nAll screenshots generated!")
    print(f"  6.7\" -> {OUTPUT_67}")
    print(f"  5.5\" -> {OUTPUT_55}")


if __name__ == "__main__":
    main()

"""
Builds the Nexus header for Radio Blacklist.

The header is 1300x372, the size Nexus stores. Everything is drawn at 4x and
scaled down, so the bars, ticks and text are sharp. A second image simulates
the Nexus page overlay (transparent to black from 72 px down) for checking.

Requires Pillow and the Rajdhani font (Google Fonts, SIL OFL) installed for the
current user.

Usage:
    python art/make_header.py [--out nexus/header-v2.png] [--preview art/preview.png]
"""

import argparse
import math
import os
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

WIDTH, HEIGHT = 1300, 372
SCALE = 4

FONT_DIR = Path(os.environ["LOCALAPPDATA"]) / "Microsoft" / "Windows" / "Fonts"
FONT_TITLE = FONT_DIR / "Rajdhani-Bold.ttf"
FONT_SLOGAN = FONT_DIR / "Rajdhani-SemiBold.ttf"
FONT_SCALE = FONT_DIR / "Rajdhani-SemiBold.ttf"

BACKGROUND = (0, 0, 0)
TITLE_COLOR = (0xE0, 0x00, 0x1B)
SLOGAN_COLOR = (0x00, 0xFF, 0xFF)
BAR_ALLOWED = (0x16, 0x4A, 0xB8)
BAR_BLOCKED = (0xC8, 0x00, 0x1C)
TICK_ALLOWED = (0x3A, 0x6F, 0xB4)
TICK_BLOCKED = (0xE0, 0x00, 0x1B)

TITLE = "RADIO BLACKLIST"
SLOGAN = "Your radio. Your rules."
TEXT_LEFT = 72
TITLE_TOP = 100
TITLE_SIZE = 64
SLOGAN_GAP = 18
# The ink of "R" starts 3 px right of its box at this size, while the tips
# of "Y" start right at it: nudge the slogan so both share one left edge.
SLOGAN_NUDGE = 3
SLOGAN_SIZE = 25

BAR_CENTER_Y = 135
BAR_MAX = 194
BAR_WIDTH = 9
BAR_STEP = 30.5
BAR_FIRST_X = 22
BAR_LEVELS = (0.16, 0.27, 0.40, 0.55, 0.72, 0.87, 1.0)
AXIS_GAP = 3

RIGHT_SETTLE_FROM, RIGHT_SETTLE_TO = 760, 1060
RIGHT_HEIGHT_DROP = 0.28
RIGHT_ALPHA_DROP = 0.18

TEXT_CLEARANCE = 36
BEHIND_TEXT_ALPHA = 0.20

# One blocked station under the title ties the left part to the right one.
# It stays dim (behind the text) but a bit brighter than the blue bars there.
BLOCKED_BEHIND_TEXT = {7, 9}
BEHIND_TEXT_BLOCKED_BOOST = 1.8
RAMP_WIDTH = 110

SCALE_Y = 262
FREQ_MIN, FREQ_MAX = 88.0, 112.0
SCALE_LEFT, SCALE_RIGHT = 20, 1280
LABEL_MIN_GAP = 60
BLOCKED_SHARE = 0.27

SEED = 2077


def s(value):
    """
    Converts a 1x coordinate to the supersampled canvas.
    """
    return round(value * SCALE)


def x_to_freq(x):
    return FREQ_MIN + (x - SCALE_LEFT) / (SCALE_RIGHT - SCALE_LEFT) * (FREQ_MAX - FREQ_MIN)


def freq_to_x(freq):
    return SCALE_LEFT + (freq - FREQ_MIN) / (FREQ_MAX - FREQ_MIN) * (SCALE_RIGHT - SCALE_LEFT)


def blend(color, alpha):
    """
    Mixes a color with the black background.
    """
    return tuple(round(c * alpha) for c in color)


def edge_fade(x):
    """
    Fades the far left and right ends of the bars and the scale.
    """
    fade_in = min(1.0, max(0.0, (x - 0) / 90))
    fade_out = min(1.0, max(0.0, (WIDTH - x) / 140))
    return min(fade_in, fade_out) ** 1.2


def bar_heights(count, rng):
    """
    Heights follow a slow wave with some randomness: varied, but not noise.
    Two neighbours never share a height.
    """
    heights = []
    previous = None
    for i in range(count):
        wave = 0.55 + 0.25 * math.sin(i * 0.57 + 1.3) + 0.18 * math.sin(i * 0.23 + 0.4)
        level = round(wave * (len(BAR_LEVELS) - 1)) + rng.choice((-1, 0, 0, 1))
        level = max(0, min(len(BAR_LEVELS) - 1, level))
        if level == previous:
            level = level + 1 if level < len(BAR_LEVELS) - 1 else level - 1
        previous = level
        heights.append(BAR_LEVELS[level] * BAR_MAX)
    return heights


def bar_colors(count, first_open, rng):
    """
    Bars behind the text are always allowed (blue). After it, blocked (red)
    and allowed bars are mixed: at most 3 allowed bars in a row and at most
    2 blocked bars in a row.
    """
    blocked = []
    run_allowed = run_blocked = 0
    for i in range(count):
        if i < first_open:
            blocked.append(i in BLOCKED_BEHIND_TEXT)
            continue
        is_blocked = rng.random() < BLOCKED_SHARE
        if run_allowed >= 3:
            is_blocked = True
        if run_blocked >= 2:
            is_blocked = False
        blocked.append(is_blocked)
        run_blocked = run_blocked + 1 if is_blocked else 0
        run_allowed = 0 if is_blocked else run_allowed + 1
    return blocked


def draw_axis(draw):
    """
    A black line along the bars' center: the bars read as a mirrored signal,
    and the line cuts the title, which makes it part of the spectrum. The
    title is deliberately not centered on it; the cut sits low in the letters.
    """
    top = BAR_CENTER_Y - AXIS_GAP / 2
    draw.rectangle((0, s(top), s(WIDTH), s(top + AXIS_GAP) - 1), fill=BACKGROUND)


def draw_text(draw):
    title_font = ImageFont.truetype(str(FONT_TITLE), s(TITLE_SIZE))
    slogan_font = ImageFont.truetype(str(FONT_SLOGAN), s(SLOGAN_SIZE))
    title_box = draw.textbbox((0, 0), TITLE, font=title_font)
    slogan_box = draw.textbbox((0, 0), SLOGAN, font=slogan_font)
    title_x = s(TEXT_LEFT) - title_box[0]
    title_y = s(TITLE_TOP) - title_box[1]
    draw.text((title_x, title_y), TITLE, font=title_font, fill=TITLE_COLOR)
    draw_axis(draw)
    slogan_top = TITLE_TOP + (title_box[3] - title_box[1]) / SCALE + SLOGAN_GAP
    slogan_x = s(TEXT_LEFT + SLOGAN_NUDGE) - slogan_box[0]
    slogan_y = s(slogan_top) - slogan_box[1]
    draw.text((slogan_x, slogan_y), SLOGAN, font=slogan_font, fill=SLOGAN_COLOR)
    text_right = TEXT_LEFT + max(title_box[2] - title_box[0], slogan_box[2] - slogan_box[0]) / SCALE
    return text_right


def text_right_edge():
    probe = ImageDraw.Draw(Image.new("RGB", (1, 1)))
    title_font = ImageFont.truetype(str(FONT_TITLE), s(TITLE_SIZE))
    slogan_font = ImageFont.truetype(str(FONT_SLOGAN), s(SLOGAN_SIZE))
    title_box = probe.textbbox((0, 0), TITLE, font=title_font)
    slogan_box = probe.textbbox((0, 0), SLOGAN, font=slogan_font)
    return TEXT_LEFT + max(title_box[2] - title_box[0], slogan_box[2] - slogan_box[0]) / SCALE


def smoothstep(edge0, edge1, x):
    t = min(1.0, max(0.0, (x - edge0) / (edge1 - edge0)))
    return t * t * (3 - 2 * t)


def right_settle(x):
    """
    Lowers and slightly dims the bars on the right, so the busy right side
    does not outweigh the title on the left.
    """
    height = 1 - RIGHT_HEIGHT_DROP * smoothstep(RIGHT_SETTLE_FROM, RIGHT_SETTLE_TO, x)
    alpha = 1 - RIGHT_ALPHA_DROP * smoothstep(RIGHT_SETTLE_FROM, RIGHT_SETTLE_TO, x)
    return height, alpha


def draw_bars(draw, xs, heights, blocked, text_right):
    for x, height, is_blocked in zip(xs, heights, blocked):
        height_factor, alpha_factor = right_settle(x)
        height *= height_factor
        open_from = text_right + TEXT_CLEARANCE
        if x < open_from:
            alpha = BEHIND_TEXT_ALPHA * (BEHIND_TEXT_BLOCKED_BOOST if is_blocked else 1)
        else:
            alpha = BEHIND_TEXT_ALPHA + (1 - BEHIND_TEXT_ALPHA) * min(1.0, (x - open_from) / RAMP_WIDTH)
        alpha *= edge_fade(x) * alpha_factor
        color = blend(BAR_BLOCKED if is_blocked else BAR_ALLOWED, alpha)
        top = BAR_CENTER_Y - height / 2
        bottom = BAR_CENTER_Y + height / 2
        draw.rounded_rectangle(
            (s(x - BAR_WIDTH / 2), s(top), s(x + BAR_WIDTH / 2), s(bottom)),
            radius=s(BAR_WIDTH / 2),
            fill=color,
        )


def draw_scale(draw, xs, blocked, text_right):
    font = ImageFont.truetype(str(FONT_SCALE), s(15))
    freq = math.ceil(FREQ_MIN * 5) / 5
    while freq <= FREQ_MAX + 1e-9:
        x = freq_to_x(freq)
        major = abs(freq - round(freq)) < 1e-6
        length = 9 if major else 4
        color = blend(TICK_ALLOWED, (0.75 if major else 0.5) * edge_fade(x))
        draw.rectangle((s(x - 0.5), s(SCALE_Y), s(x + 0.5), s(SCALE_Y + length)), fill=color)
        freq = round(freq + 0.2, 1)

    last_label_x = -1000
    for i, (x, is_blocked) in enumerate(zip(xs, blocked)):
        open_bar = x > text_right + TEXT_CLEARANCE
        show_allowed = (not is_blocked) and open_bar and i % 3 == 0
        if not (is_blocked or show_allowed):
            continue
        fade = edge_fade(x)
        tick_color = blend(TICK_BLOCKED if is_blocked else TICK_ALLOWED, fade)
        draw.rectangle((s(x - 1), s(SCALE_Y - 3), s(x + 1), s(SCALE_Y + 13)), fill=tick_color)
        if x - last_label_x < LABEL_MIN_GAP:
            continue
        last_label_x = x
        label = f"{x_to_freq(x):.1f}"
        box = draw.textbbox((0, 0), label, font=font)
        label_x = s(x) - (box[0] + box[2]) / 2
        label_y = s(SCALE_Y - 8) - box[3]
        draw.text((label_x, label_y), label, font=font, fill=tick_color)


def nexus_overlay(image):
    """
    The Nexus mod page lays linear-gradient(transparent, black) over the header
    from 72 px to the bottom.
    """
    overlay = Image.new("RGBA", image.size, (0, 0, 0, 0))
    pixels = overlay.load()
    for y in range(image.height):
        a = 0 if y < 72 else round(255 * (y - 72) / (image.height - 72))
        for x in range(image.width):
            pixels[x, y] = (0, 0, 0, a)
    result = image.convert("RGBA")
    result.alpha_composite(overlay)
    return result.convert("RGB")


def build():
    rng = random.Random(SEED)
    count = int((WIDTH - 2 * BAR_FIRST_X) / BAR_STEP) + 1
    xs = [BAR_FIRST_X + i * BAR_STEP for i in range(count)]
    text_right = text_right_edge()
    first_open = next(i for i, x in enumerate(xs) if x > text_right + TEXT_CLEARANCE)
    heights = bar_heights(count, rng)
    blocked = bar_colors(count, first_open, rng)

    canvas = Image.new("RGB", (s(WIDTH), s(HEIGHT)), BACKGROUND)
    draw = ImageDraw.Draw(canvas)
    draw_bars(draw, xs, heights, blocked, text_right)
    draw_scale(draw, xs, blocked, text_right)
    draw_text(draw)
    return canvas.resize((WIDTH, HEIGHT), Image.LANCZOS)


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    root = Path(__file__).resolve().parent.parent
    parser.add_argument("--out", default=str(root / "nexus" / "header-v2.png"))
    parser.add_argument("--preview", default=str(root / "art" / "preview-v2.png"))
    args = parser.parse_args()
    header = build()
    header.save(args.out)
    nexus_overlay(header).save(args.preview)
    print(f"header  {args.out}")
    print(f"preview {args.preview}")


if __name__ == "__main__":
    main()

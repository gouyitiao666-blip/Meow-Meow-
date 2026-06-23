from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import math


ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "build" / "generated-assets" / "raw"
ASSETS = ROOT / "assets"
PREVIEW = ROOT / "build" / "additional_mvp_asset_pack_contact_sheet.png"


def remove_magenta(img: Image.Image) -> Image.Image:
    img = img.convert("RGBA")
    px = img.load()
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = px[x, y]
            if r > 170 and b > 140 and g < 110:
                px[x, y] = (r, g, b, 0)
    return img


def alpha_bbox(img: Image.Image):
    return img.getchannel("A").getbbox()


def save_fit(cell: Image.Image, rel: str, size: tuple[int, int], fill_ratio: float = 0.9) -> None:
    cell = remove_magenta(cell)
    bbox = alpha_bbox(cell)
    out = Image.new("RGBA", size, (0, 0, 0, 0))
    if bbox is not None:
        art = cell.crop(bbox)
        art.thumbnail((max(1, int(size[0] * fill_ratio)), max(1, int(size[1] * fill_ratio))), Image.Resampling.LANCZOS)
        out.alpha_composite(art, ((size[0] - art.width) // 2, (size[1] - art.height) // 2))
    path = ASSETS / rel
    path.parent.mkdir(parents=True, exist_ok=True)
    out.save(path)


def export_grid(raw_name: str, rows: int, cols: int, mapping: list[tuple[int, str, tuple[int, int], float]]) -> None:
    sheet = Image.open(RAW / raw_name).convert("RGBA")
    cw = sheet.width // cols
    ch = sheet.height // rows
    for index, rel, size, fill in mapping:
        row = index // cols
        col = index % cols
        cell = sheet.crop((col * cw, row * ch, (col + 1) * cw, (row + 1) * ch))
        save_fit(cell, rel, size, fill)


def tile_img(name: str) -> Image.Image:
    return Image.open(ASSETS / "tiles" / name).convert("RGBA").resize((32, 32), Image.Resampling.LANCZOS)


def blend_tiles(a: Image.Image, b: Image.Image, mask: Image.Image) -> Image.Image:
    return Image.composite(a, b, mask).convert("RGBA")


def water_edge(direction: str) -> Image.Image:
    grass = tile_img("grass_tile.png")
    water = tile_img("water_tile.png")
    mask = Image.new("L", (32, 32), 0)
    d = ImageDraw.Draw(mask)
    if direction == "top":
        pts = [(0, 0), (32, 0), (32, 13), (24, 16), (16, 14), (8, 17), (0, 14)]
    elif direction == "bottom":
        pts = [(0, 18), (8, 15), (16, 17), (24, 14), (32, 18), (32, 32), (0, 32)]
    elif direction == "left":
        pts = [(0, 0), (14, 0), (17, 8), (14, 16), (17, 24), (14, 32), (0, 32)]
    else:
        pts = [(18, 0), (32, 0), (32, 32), (18, 32), (15, 24), (18, 16), (15, 8)]
    d.polygon(pts, fill=255)
    return blend_tiles(grass, water, mask)


def water_corner(corner: str) -> Image.Image:
    grass = tile_img("grass_tile.png")
    water = tile_img("water_tile.png")
    mask = Image.new("L", (32, 32), 0)
    d = ImageDraw.Draw(mask)
    if corner == "top_left":
        d.pieslice((-20, -20, 34, 34), 0, 90, fill=255)
    elif corner == "top_right":
        d.pieslice((-2, -20, 52, 34), 90, 180, fill=255)
    elif corner == "bottom_left":
        d.pieslice((-20, -2, 34, 52), 270, 360, fill=255)
    else:
        d.pieslice((-2, -2, 52, 52), 180, 270, fill=255)
    return blend_tiles(grass, water, mask)


def dirt_edge(direction: str) -> Image.Image:
    grass = tile_img("grass_tile.png")
    dirt = tile_img("dirt_path_tile.png")
    mask = Image.new("L", (32, 32), 0)
    d = ImageDraw.Draw(mask)
    if direction == "top":
        d.rectangle((0, 0, 32, 16), fill=255)
    elif direction == "bottom":
        d.rectangle((0, 16, 32, 32), fill=255)
    elif direction == "left":
        d.rectangle((0, 0, 16, 32), fill=255)
    else:
        d.rectangle((16, 0, 32, 32), fill=255)
    return blend_tiles(dirt, grass, mask)


def soil_transition(corner: bool) -> Image.Image:
    grass = tile_img("grass_tile.png")
    soil = tile_img("farm_soil_tile.png")
    mask = Image.new("L", (32, 32), 0)
    d = ImageDraw.Draw(mask)
    if corner:
        d.rounded_rectangle((6, 6, 32, 32), radius=8, fill=255)
    else:
        d.rounded_rectangle((0, 7, 32, 32), radius=7, fill=255)
    return blend_tiles(soil, grass, mask)


def export_tiles() -> None:
    out = ASSETS / "tiles"
    out.mkdir(parents=True, exist_ok=True)
    for direction in ("top", "bottom", "left", "right"):
        water_edge(direction).save(out / f"water_edge_{direction}.png")
        dirt_edge(direction).save(out / f"dirt_edge_{direction}.png")
    for corner in ("top_left", "top_right", "bottom_left", "bottom_right"):
        water_corner(corner).save(out / f"water_corner_{corner}.png")
    soil_transition(False).save(out / "farm_soil_edge.png")
    soil_transition(True).save(out / "farm_soil_corner.png")


def translucent_square(path: str, color: tuple[int, int, int, int], outline: tuple[int, int, int, int]) -> None:
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle((3, 3, 28, 28), radius=4, fill=color, outline=outline, width=2)
    (ASSETS / path).parent.mkdir(parents=True, exist_ok=True)
    img.save(ASSETS / path)


def export_indicators_and_shadows() -> None:
    translucent_square("ui/tile_highlight_green.png", (77, 221, 122, 70), (78, 231, 130, 210))
    translucent_square("ui/tile_highlight_red.png", (238, 95, 95, 70), (255, 112, 112, 220))

    cursor = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(cursor)
    col = (255, 221, 84, 245)
    for x, y, sx, sy in ((2, 2, 1, 1), (30, 2, -1, 1), (2, 30, 1, -1), (30, 30, -1, -1)):
        d.line((x, y, x + sx * 9, y), fill=col, width=3)
        d.line((x, y, x, y + sy * 9), fill=col, width=3)
    cursor.save(ASSETS / "ui" / "selection_cursor.png")

    shadow = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.ellipse((8, 24, 56, 44), fill=(75, 56, 48, 75))
    shadow = shadow.filter(ImageFilter.GaussianBlur(5))
    shadow.save(ASSETS / "ui" / "build_preview_shadow.png")

    for rel, size, box, blur, alpha in [
        ("shadows/shadow_small.png", (32, 16), (3, 4, 29, 13), 3, 70),
        ("shadows/shadow_medium.png", (64, 32), (6, 8, 58, 25), 5, 70),
        ("shadows/shadow_large.png", (96, 48), (8, 12, 88, 37), 7, 72),
    ]:
        img = Image.new("RGBA", size, (0, 0, 0, 0))
        d = ImageDraw.Draw(img)
        d.ellipse(box, fill=(70, 52, 45, alpha))
        img = img.filter(ImageFilter.GaussianBlur(blur))
        path = ASSETS / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        img.save(path)


def build_preview() -> None:
    files = []
    prefixes = ["tiles", "characters", "tools", "ui", "shadows", "items", "effects"]
    names = {
        "tiles": [
            "water_edge_top.png", "water_edge_bottom.png", "water_edge_left.png", "water_edge_right.png",
            "water_corner_top_left.png", "water_corner_top_right.png", "water_corner_bottom_left.png", "water_corner_bottom_right.png",
            "dirt_edge_top.png", "dirt_edge_bottom.png", "dirt_edge_left.png", "dirt_edge_right.png", "farm_soil_edge.png", "farm_soil_corner.png",
        ],
        "characters": ["player_hold_fishing_rod.png", "player_fishing_pose.png", "player_use_watering_can.png", "player_use_hoe.png", "player_pickup_item.png"],
        "tools": ["hoe_icon.png", "watering_can_icon.png", "axe_icon.png", "hand_icon.png", "seed_bag_icon.png"],
        "ui": ["tile_highlight_green.png", "tile_highlight_red.png", "selection_cursor.png", "build_preview_shadow.png", "talk_prompt_icon.png", "fish_prompt_icon.png", "plant_prompt_icon.png", "harvest_prompt_icon.png", "pickup_prompt_icon.png", "sleep_prompt_icon.png"],
        "shadows": ["shadow_small.png", "shadow_medium.png", "shadow_large.png"],
        "items": ["carrot_drop.png", "small_fish_drop.png", "wood_drop.png", "stone_drop.png", "flower_drop.png", "coin_drop.png"],
        "effects": ["plant_effect.png", "harvest_effect.png", "pickup_sparkle.png", "water_splash_effect.png", "fish_bite_effect.png", "friendship_heart_effect.png"],
    }
    for prefix in prefixes:
        for name in names[prefix]:
            files.append(ASSETS / prefix / name)

    thumb = 112
    label = 20
    cols = 7
    rows = math.ceil(len(files) / cols)
    sheet = Image.new("RGBA", (cols * thumb, rows * (thumb + label)), (245, 242, 232, 255))
    d = ImageDraw.Draw(sheet)
    for i, p in enumerate(files):
        img = Image.open(p).convert("RGBA")
        t = img.copy()
        t.thumbnail((thumb - 14, thumb - 28), Image.Resampling.LANCZOS)
        x = (i % cols) * thumb + (thumb - t.width) // 2
        y = (i // cols) * (thumb + label) + 6
        sheet.alpha_composite(t, (x, y))
        d.text(((i % cols) * thumb + 4, (i // cols) * (thumb + label) + thumb - 10), p.name[:16], fill=(82, 65, 55, 255))
    PREVIEW.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(PREVIEW)


def main() -> None:
    export_grid(
        "additional_player_actions_2x3_raw.png",
        2,
        3,
        [
            (0, "characters/player_hold_fishing_rod.png", (64, 64), 0.96),
            (1, "characters/player_fishing_pose.png", (64, 64), 0.96),
            (2, "characters/player_use_watering_can.png", (64, 64), 0.96),
            (3, "characters/player_use_hoe.png", (64, 64), 0.96),
            (4, "characters/player_pickup_item.png", (64, 64), 0.96),
        ],
    )
    export_grid(
        "additional_tools_drops_3x4_raw.png",
        3,
        4,
        [
            (0, "tools/hoe_icon.png", (32, 32), 0.92),
            (1, "tools/watering_can_icon.png", (32, 32), 0.92),
            (2, "tools/axe_icon.png", (32, 32), 0.92),
            (3, "tools/hand_icon.png", (32, 32), 0.92),
            (4, "tools/seed_bag_icon.png", (32, 32), 0.92),
            (5, "items/carrot_drop.png", (32, 32), 0.92),
            (6, "items/small_fish_drop.png", (32, 32), 0.92),
            (7, "items/wood_drop.png", (32, 32), 0.92),
            (8, "items/stone_drop.png", (32, 32), 0.92),
            (9, "items/flower_drop.png", (32, 32), 0.92),
            (10, "items/coin_drop.png", (32, 32), 0.92),
        ],
    )
    export_grid(
        "additional_effects_prompts_3x4_raw.png",
        3,
        4,
        [
            (0, "effects/plant_effect.png", (64, 64), 0.94),
            (1, "effects/harvest_effect.png", (64, 64), 0.94),
            (2, "effects/pickup_sparkle.png", (64, 64), 0.94),
            (3, "effects/water_splash_effect.png", (64, 64), 0.94),
            (4, "effects/fish_bite_effect.png", (64, 64), 0.94),
            (5, "effects/friendship_heart_effect.png", (64, 64), 0.94),
            (6, "ui/talk_prompt_icon.png", (48, 48), 0.92),
            (7, "ui/fish_prompt_icon.png", (48, 48), 0.92),
            (8, "ui/plant_prompt_icon.png", (48, 48), 0.92),
            (9, "ui/harvest_prompt_icon.png", (48, 48), 0.92),
            (10, "ui/pickup_prompt_icon.png", (48, 48), 0.92),
            (11, "ui/sleep_prompt_icon.png", (48, 48), 0.92),
        ],
    )
    export_tiles()
    export_indicators_and_shadows()
    build_preview()


if __name__ == "__main__":
    main()

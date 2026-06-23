from __future__ import annotations

import json
import math
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "build" / "generated-assets" / "raw"
ASSETS = ROOT / "assets"
PREVIEW = ROOT / "build" / "full_asset_pack_contact_sheet.png"
MANIFEST = ROOT / "build" / "full_asset_pack_manifest.json"


PROMPTS = {
    "full_pack_buildings_3x4_raw.png": "3x4 clean-HD cozy village building sheet, magenta background, no text.",
    "full_pack_decor_4x5_raw.png": "4x5 clean-HD cozy decoration/world-object sheet, magenta background, no text.",
    "full_pack_vehicles_2x2_raw.png": "2x2 clean-HD cute village vehicle sheet, magenta background, no text.",
    "full_pack_utility_3x4_raw.png": "3x4 clean-HD utility/nature/effects sheet, magenta background, no text.",
    "full_pack_windmill_2x2_raw.png": "2x2 clean-HD cozy windmill looping animation sheet, magenta background, no text.",
}


def remove_magenta(img: Image.Image) -> Image.Image:
    img = img.convert("RGBA")
    px = img.load()
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = px[x, y]
            if r > 170 and b > 135 and g < 115:
                px[x, y] = (r, g, b, 0)
    return img


def alpha_bbox(img: Image.Image):
    return img.getchannel("A").getbbox()


def fit_to_canvas(img: Image.Image, size: tuple[int, int], fill: float = 0.9, anchor: str = "center") -> Image.Image:
    img = remove_magenta(img)
    bbox = alpha_bbox(img)
    out = Image.new("RGBA", size, (0, 0, 0, 0))
    if bbox is None:
        return out
    art = img.crop(bbox)
    art.thumbnail((max(1, int(size[0] * fill)), max(1, int(size[1] * fill))), Image.Resampling.LANCZOS)
    x = (size[0] - art.width) // 2
    if anchor == "bottom":
        y = max(0, size[1] - art.height - max(2, int(size[1] * 0.06)))
    else:
        y = (size[1] - art.height) // 2
    out.alpha_composite(art, (x, y))
    return out


def export_grid(raw_name: str, rows: int, cols: int, mapping: Iterable[tuple[int, str, tuple[int, int], float, str]]) -> list[str]:
    sheet = Image.open(RAW / raw_name).convert("RGBA")
    cw = sheet.width // cols
    ch = sheet.height // rows
    written: list[str] = []
    for index, rel, size, fill, anchor in mapping:
        row = index // cols
        col = index % cols
        cell = sheet.crop((col * cw, row * ch, (col + 1) * cw, (row + 1) * ch))
        out = fit_to_canvas(cell, size, fill, anchor)
        path = ASSETS / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        out.save(path)
        written.append(rel)
    return written


def save_copy_fit(src_rel: str, dst_rel: str, size: tuple[int, int], fill: float = 0.9, anchor: str = "center") -> str:
    out = fit_to_canvas(Image.open(ASSETS / src_rel).convert("RGBA"), size, fill, anchor)
    path = ASSETS / dst_rel
    path.parent.mkdir(parents=True, exist_ok=True)
    out.save(path)
    return dst_rel


def tile_variant(src_rel: str, dst_rel: str, tint: tuple[float, float, float], brightness: float = 1.0) -> str:
    img = Image.open(ASSETS / src_rel).convert("RGBA").resize((32, 32), Image.Resampling.LANCZOS)
    r, g, b, a = img.split()
    r = r.point(lambda p: max(0, min(255, int(p * tint[0]))))
    g = g.point(lambda p: max(0, min(255, int(p * tint[1]))))
    b = b.point(lambda p: max(0, min(255, int(p * tint[2]))))
    out = Image.merge("RGBA", (r, g, b, a))
    out = ImageEnhance.Brightness(out).enhance(brightness)
    path = ASSETS / dst_rel
    path.parent.mkdir(parents=True, exist_ok=True)
    out.save(path)
    return dst_rel


def make_loop_sheet(src_rel: str, dst_rel: str, frame_size: tuple[int, int], frames: int, mode: str) -> str:
    base = fit_to_canvas(Image.open(ASSETS / src_rel).convert("RGBA"), frame_size, 0.9, "center")
    sheet = Image.new("RGBA", (frame_size[0] * frames, frame_size[1]), (0, 0, 0, 0))
    for i in range(frames):
        frame = base.copy()
        if mode == "water":
            frame = ImageChops.offset(frame, i * 2, 0)
            frame = ImageEnhance.Brightness(frame).enhance(1.0 + (0.035 if i in (1, 2) else 0.0))
        elif mode == "sway":
            frame = ImageChops.offset(frame, int(math.sin(i / frames * math.tau) * 2), 0)
        elif mode == "glow":
            glow = base.filter(ImageFilter.GaussianBlur(4))
            glow = ImageEnhance.Brightness(glow).enhance(1.0 + i * 0.05)
            frame.alpha_composite(glow)
        elif mode == "fountain":
            frame = ImageEnhance.Brightness(frame).enhance(1.0 + (0.04 if i % 2 else 0.0))
            frame = ImageChops.offset(frame, 0, -i % 3)
        elif mode == "drive":
            frame = ImageChops.offset(frame, 0, int(math.sin(i / frames * math.tau) * 1))
        sheet.alpha_composite(frame, (frame_size[0] * i, 0))
    path = ASSETS / dst_rel
    path.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(path)
    return dst_rel


def make_windmill_sheet() -> str:
    raw_name = "full_pack_windmill_2x2_raw.png"
    sheet = remove_magenta(Image.open(RAW / raw_name).convert("RGBA"))
    cols = 2
    rows = 2
    frame_size = (128, 128)
    cw = sheet.width // cols
    ch = sheet.height // rows
    out = Image.new("RGBA", (frame_size[0] * 4, frame_size[1]), (0, 0, 0, 0))

    for index in range(4):
        row = index // cols
        col = index % cols
        cell = sheet.crop((col * cw, row * ch, (col + 1) * cw, (row + 1) * ch))
        frame = fit_to_canvas(cell, frame_size, 0.92, "center")
        out.alpha_composite(frame, (frame_size[0] * index, 0))

    path = ASSETS / "animated/windmill_rotation_animated.png"
    path.parent.mkdir(parents=True, exist_ok=True)
    out.save(path)
    return "animated/windmill_rotation_animated.png"


def build_preview(files: list[str]) -> None:
    thumb = 116
    label = 22
    cols = 8
    rows = math.ceil(len(files) / cols)
    sheet = Image.new("RGBA", (cols * thumb, rows * (thumb + label)), (245, 242, 232, 255))
    draw = ImageDraw.Draw(sheet)
    for i, rel in enumerate(files):
        path = ASSETS / rel
        if not path.exists():
            continue
        img = Image.open(path).convert("RGBA")
        t = img.copy()
        t.thumbnail((thumb - 12, thumb - 26), Image.Resampling.LANCZOS)
        x = (i % cols) * thumb + (thumb - t.width) // 2
        y = (i // cols) * (thumb + label) + 4
        sheet.alpha_composite(t, (x, y))
        draw.text(((i % cols) * thumb + 4, (i // cols) * (thumb + label) + thumb - 6), Path(rel).name[:17], fill=(82, 65, 55, 255))
    PREVIEW.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(PREVIEW)


def main() -> None:
    written: list[str] = []

    for raw_name, prompt in PROMPTS.items():
        (RAW / f"{raw_name}.prompt.txt").write_text(prompt + "\n", encoding="utf-8")

    written += export_grid(
        "full_pack_buildings_3x4_raw.png",
        3,
        4,
        [
            (0, "buildings/player_house_small.png", (192, 192), 0.94, "bottom"),
            (1, "buildings/village_house_medium.png", (224, 224), 0.94, "bottom"),
            (2, "buildings/farm_house.png", (224, 224), 0.94, "bottom"),
            (3, "buildings/shop_building.png", (224, 224), 0.94, "bottom"),
            (4, "buildings/cafe_building.png", (224, 224), 0.94, "bottom"),
            (5, "buildings/pet_shop_building.png", (224, 224), 0.94, "bottom"),
            (6, "buildings/greenhouse_building.png", (224, 224), 0.94, "bottom"),
            (7, "buildings/storage_shed.png", (160, 160), 0.94, "bottom"),
            (8, "buildings/barn_building.png", (224, 224), 0.94, "bottom"),
            (9, "buildings/town_hall_building.png", (256, 256), 0.94, "bottom"),
        ],
    )

    written += export_grid(
        "full_pack_decor_4x5_raw.png",
        5,
        4,
        [
            (0, "buildings/fence_straight.png", (64, 64), 0.9, "bottom"),
            (1, "buildings/fence_corner.png", (64, 64), 0.9, "bottom"),
            (2, "buildings/wooden_post.png", (48, 64), 0.9, "bottom"),
            (3, "buildings/wooden_bridge.png", (128, 96), 0.94, "center"),
            (4, "buildings/pet_bed.png", (64, 64), 0.92, "center"),
            (5, "buildings/bench.png", (96, 64), 0.92, "bottom"),
            (6, "buildings/flower_pot.png", (48, 48), 0.9, "center"),
            (7, "buildings/lantern.png", (48, 64), 0.9, "bottom"),
            (8, "buildings/picnic_mat.png", (96, 96), 0.92, "center"),
            (9, "buildings/mushroom_lamp.png", (64, 64), 0.9, "bottom"),
            (10, "buildings/signboard.png", (64, 64), 0.9, "bottom"),
            (11, "buildings/mailbox.png", (64, 64), 0.9, "bottom"),
            (12, "buildings/trash_bin.png", (64, 64), 0.9, "bottom"),
            (13, "buildings/round_table.png", (96, 96), 0.92, "center"),
            (14, "buildings/outdoor_chair.png", (64, 64), 0.9, "bottom"),
            (15, "buildings/sofa_outdoor.png", (128, 96), 0.92, "bottom"),
            (16, "buildings/fountain.png", (128, 128), 0.94, "bottom"),
            (17, "buildings/wooden_crate.png", (64, 64), 0.92, "center"),
        ],
    )

    written += export_grid(
        "full_pack_vehicles_2x2_raw.png",
        2,
        2,
        [
            (0, "vehicles/car_small_blue.png", (128, 96), 0.96, "center"),
            (1, "vehicles/car_small_yellow.png", (128, 96), 0.96, "center"),
            (2, "vehicles/delivery_van.png", (144, 96), 0.96, "center"),
            (3, "vehicles/bicycle.png", (96, 96), 0.96, "center"),
        ],
    )

    written += export_grid(
        "full_pack_utility_3x4_raw.png",
        3,
        4,
        [
            (0, "pets/cat_sleep.png", (48, 48), 0.94, "center"),
            (1, "nature/flower_white.png", (32, 32), 0.94, "center"),
            (2, "nature/flower_yellow.png", (32, 32), 0.94, "center"),
            (3, "nature/wood_stump.png", (48, 48), 0.94, "bottom"),
            (4, "tools/harvest_icon.png", (32, 32), 0.94, "center"),
            (5, "fishing/fishing_spot_marker.png", (48, 48), 0.94, "center"),
            (6, "effects/water_ripple_effect.png", (64, 64), 0.94, "center"),
            (7, "effects/item_pickup_effect.png", (64, 64), 0.94, "center"),
            (8, "effects/sparkle_effect.png", (64, 64), 0.94, "center"),
            (9, "effects/speech_bubble.png", (96, 64), 0.94, "center"),
            (10, "effects/exclamation_icon.png", (48, 48), 0.94, "center"),
            (11, "ui/pet_heart_emote.png", (48, 48), 0.94, "center"),
        ],
    )

    written.append(tile_variant("tiles/rock.png" if (ASSETS / "tiles/rock.png").exists() else "tiles/dirt_path_tile.png", "tiles/stone_path_tile.png", (0.92, 0.92, 1.0), 1.05))
    written.append(tile_variant("tiles/grass_tile.png", "tiles/sand_tile.png", (1.32, 1.18, 0.74), 1.1))
    written.append(save_copy_fit("ui/pet_emote_heart.png", "ui/pet_heart_emote.png", (48, 48), 0.94))
    written.append(save_copy_fit("effects/pickup_sparkle.png", "effects/item_pickup_effect.png", (64, 64), 0.94))
    written.append(save_copy_fit("effects/pickup_sparkle.png", "effects/sparkle_effect.png", (64, 64), 0.94))
    written.append(save_copy_fit("effects/fish_bite_effect.png", "fishing/fish_bite_effect.png", (64, 64), 0.94))
    written.append(save_copy_fit("effects/water_ripple_effect.png", "fishing/water_ripple_effect.png", (64, 64), 0.94))

    written += [
        make_loop_sheet("tiles/water_tile.png", "animated/water_tile_animated.png", (64, 64), 4, "water"),
        make_loop_sheet("tiles/water_tile.png", "animated/sea_wave_tile_animated.png", (64, 64), 4, "water"),
        make_loop_sheet("tiles/grass_tile.png", "animated/grass_sway_animated.png", (64, 64), 4, "sway"),
        make_loop_sheet("nature/flower.png", "animated/flower_sway_animated.png", (64, 64), 4, "sway"),
        make_loop_sheet("nature/bush.png", "animated/bush_sway_animated.png", (64, 64), 4, "sway"),
        make_loop_sheet("buildings/lantern.png", "animated/lantern_glow_animated.png", (64, 64), 4, "glow"),
        make_loop_sheet("buildings/mushroom_lamp.png", "animated/mushroom_lamp_glow_animated.png", (64, 64), 4, "glow"),
        make_loop_sheet("buildings/fountain.png", "animated/fountain_water_animated.png", (128, 128), 4, "fountain"),
        make_windmill_sheet(),
        make_loop_sheet("vehicles/car_small_blue.png", "animated/car_drive_animated.png", (128, 96), 4, "drive"),
    ]

    manifest = {
        "style": "clean_hd cozy top-down / 2.5D, transparent props, Godot 4-ready PNGs",
        "map_mode": "tile_mode",
        "engine_target": "Godot_TileMap",
        "generated_raw_sources": sorted(PROMPTS.keys()),
        "written_assets": sorted(set(written)),
    }
    MANIFEST.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    build_preview(sorted(set(written)))


if __name__ == "__main__":
    main()

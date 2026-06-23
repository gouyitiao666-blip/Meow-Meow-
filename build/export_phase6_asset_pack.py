from __future__ import annotations

import json
import math
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "build" / "generated-assets" / "raw"
ASSETS = ROOT / "assets"
PREVIEW = ROOT / "build" / "phase6_asset_pack_contact_sheet.png"
MANIFEST = ROOT / "build" / "phase6_asset_pack_manifest.json"


PROMPTS = {
    "phase6_pets_3x7_raw.png": "3x7 clean-HD cozy pet companion sheet: dog, duck, bunny poses/emotes, magenta background, no text.",
    "phase6_npc_sprites_2x4_raw.png": "2x4 clean-HD cozy village NPC sprite sheet: farmer, fisher, shopkeeper, villager idle/walk, magenta background, no text.",
    "phase6_npc_portraits_2x2_raw.png": "2x2 clean-HD cozy NPC dialogue portrait sheet, magenta background, no text.",
    "phase6_crops_4x6_raw.png": "4x6 clean-HD crop progression icon sheet: strawberry, tomato, pumpkin, catnip, magenta background, no text.",
    "phase6_icons_4x5_raw.png": "4x5 clean-HD fish/tool/resource icon sheet, magenta background, no text.",
    "phase6_ui_3x4_raw.png": "3x4 clean-HD cozy UI/placement sheet, magenta background, no text.",
    "phase6_decor_1x3_raw.png": "1x3 clean-HD cozy village decor sheet: garden arch, well, street lamp, magenta background, no text.",
    "phase6_player_actions_2x2_raw.png": "2x2 clean-HD chibi player action sheet: axe, pickaxe, hold item, magenta background, no text.",
}


def remove_magenta(img: Image.Image) -> Image.Image:
    img = img.convert("RGBA")
    px = img.load()
    for y in range(img.height):
        for x in range(img.width):
            r, g, b, a = px[x, y]
            if (r > 170 and b > 135 and g < 115) or (r > 135 and b > 115 and g < 155 and r > g * 1.25 and b > g * 1.15):
                px[x, y] = (r, g, b, 0)
    return img


def fit_to_canvas(img: Image.Image, size: tuple[int, int], fill: float = 0.9, anchor: str = "center") -> Image.Image:
    img = remove_magenta(img)
    bbox = img.getchannel("A").getbbox()
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

    pet_names = ["dog", "duck", "bunny"]
    pet_actions = ["idle", "walk_down", "walk_up", "walk_left", "walk_right", "sleep", "happy_emote"]
    written += export_grid(
        "phase6_pets_3x7_raw.png",
        3,
        7,
        [(row * 7 + col, f"pets/{pet}_{action}.png", (48, 48), 0.94, "center") for row, pet in enumerate(pet_names) for col, action in enumerate(pet_actions)],
    )

    written += export_grid(
        "phase6_npc_sprites_2x4_raw.png",
        2,
        4,
        [
            (0, "npc/npc_farmer_idle.png", (64, 64), 0.94, "bottom"),
            (1, "npc/npc_fisher_idle.png", (64, 64), 0.94, "bottom"),
            (2, "npc/npc_shopkeeper_idle.png", (64, 64), 0.94, "bottom"),
            (3, "npc/npc_villager_idle.png", (64, 64), 0.94, "bottom"),
            (4, "npc/npc_farmer_walk_down.png", (64, 64), 0.94, "bottom"),
            (5, "npc/npc_fisher_walk_down.png", (64, 64), 0.94, "bottom"),
            (6, "npc/npc_shopkeeper_walk_down.png", (64, 64), 0.94, "bottom"),
            (7, "npc/npc_villager_walk_down.png", (64, 64), 0.94, "bottom"),
        ],
    )

    written += export_grid(
        "phase6_npc_portraits_2x2_raw.png",
        2,
        2,
        [
            (0, "npc/farmer_portrait.png", (256, 256), 0.94, "center"),
            (1, "npc/fisher_portrait.png", (256, 256), 0.94, "center"),
            (2, "npc/shopkeeper_portrait.png", (256, 256), 0.94, "center"),
            (3, "npc/villager_portrait.png", (256, 256), 0.94, "center"),
        ],
    )

    crop_rows = ["strawberry", "tomato", "pumpkin", "catnip"]
    crop_suffixes = ["seed_icon", "stage_1", "stage_2", "stage_3", "ready", "icon"]
    written += export_grid(
        "phase6_crops_4x6_raw.png",
        4,
        6,
        [(row * 6 + col, f"farming/{crop}_{suffix}.png", (32, 32), 0.94, "center") for row, crop in enumerate(crop_rows) for col, suffix in enumerate(crop_suffixes)],
    )

    written += export_grid(
        "phase6_icons_4x5_raw.png",
        4,
        5,
        [
            (0, "fishing/golden_fish_icon.png", (32, 32), 0.94, "center"),
            (1, "fishing/catfish_icon.png", (32, 32), 0.94, "center"),
            (2, "fishing/sleepy_fish_icon.png", (32, 32), 0.94, "center"),
            (3, "fishing/bubble_fish_icon.png", (32, 32), 0.94, "center"),
            (4, "fishing/rare_fish_icon.png", (32, 32), 0.94, "center"),
            (5, "tools/pickaxe_icon.png", (32, 32), 0.94, "center"),
            (6, "tools/tool_upgrade_icon.png", (32, 32), 0.94, "center"),
            (7, "tools/tool_repair_icon.png", (32, 32), 0.94, "center"),
            (8, "items/wood_icon.png", (32, 32), 0.94, "center"),
            (9, "items/stone_icon.png", (32, 32), 0.94, "center"),
            (10, "items/shell_icon.png", (32, 32), 0.94, "center"),
            (11, "items/mushroom_icon.png", (32, 32), 0.94, "center"),
            (12, "items/flower_icon.png", (32, 32), 0.94, "center"),
            (13, "items/pet_food_icon.png", (32, 32), 0.94, "center"),
            (14, "items/shell_drop.png", (32, 32), 0.94, "center"),
            (15, "items/mushroom_drop.png", (32, 32), 0.94, "center"),
            (16, "items/pet_food_drop.png", (32, 32), 0.94, "center"),
        ],
    )

    written += export_grid(
        "phase6_ui_3x4_raw.png",
        3,
        4,
        [
            (0, "ui/shop_panel.png", (512, 384), 0.94, "center"),
            (1, "ui/shop_item_slot.png", (64, 64), 0.94, "center"),
            (2, "ui/buy_button.png", (192, 64), 0.94, "center"),
            (3, "ui/sell_button.png", (192, 64), 0.94, "center"),
            (4, "ui/price_tag.png", (96, 48), 0.94, "center"),
            (5, "ui/coin_small_icon.png", (32, 32), 0.94, "center"),
            (6, "ui/dialogue_choice_button.png", (256, 64), 0.94, "center"),
            (7, "ui/dialogue_choice_button_hover.png", (256, 64), 0.94, "center"),
            (8, "ui/npc_portrait_frame.png", (288, 288), 0.94, "center"),
            (9, "ui/question_mark_icon.png", (48, 48), 0.94, "center"),
            (10, "effects/placement_confirm_effect.png", (64, 64), 0.94, "center"),
            (11, "effects/placement_cancel_effect.png", (64, 64), 0.94, "center"),
        ],
    )

    written += export_grid(
        "phase6_decor_1x3_raw.png",
        1,
        3,
        [
            (0, "buildings/garden_arch.png", (128, 128), 0.94, "bottom"),
            (1, "buildings/small_well.png", (96, 96), 0.94, "bottom"),
            (2, "buildings/street_lamp.png", (64, 128), 0.94, "bottom"),
        ],
    )

    written += export_grid(
        "phase6_player_actions_2x2_raw.png",
        2,
        2,
        [
            (0, "characters/player_use_axe.png", (64, 64), 0.94, "bottom"),
            (1, "characters/player_use_pickaxe.png", (64, 64), 0.94, "bottom"),
            (2, "characters/player_hold_item.png", (64, 64), 0.94, "bottom"),
        ],
    )

    written.append(save_copy_fit("effects/exclamation_icon.png", "ui/exclamation_icon.png", (48, 48), 0.94))

    manifest = {
        "style": "clean_hd cozy top-down / 2.5D, transparent Godot 4-ready PNGs",
        "map_mode": "tile_mode",
        "engine_target": "Godot_TileMap",
        "generated_raw_sources": sorted(PROMPTS.keys()),
        "written_assets": sorted(set(written)),
    }
    MANIFEST.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    build_preview(sorted(set(written)))


if __name__ == "__main__":
    main()

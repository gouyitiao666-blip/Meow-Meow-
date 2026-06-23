from __future__ import annotations

import json
import math
import shutil
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
PACK = ROOT / "build" / "phase7_8_sprite_pack"
ASSETS = ROOT / "assets"
MANIFEST = ROOT / "build" / "phase7_8_asset_pack_manifest.json"
CONTACT = ROOT / "build" / "phase7_8_asset_pack_contact_sheet.png"


def copy_asset(src: Path, rel: str) -> str:
    dst = ASSETS / rel
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(src, dst)
    return rel


def frame(folder: str, index: int) -> Path:
    return PACK / folder / f"sheet-{index}.png"


def fx_frame(index: int) -> Path:
    return PACK / "phase7_fx" / f"fx-{index}.png"


def build_contact_sheet(files: list[str]) -> None:
    thumb = 112
    label = 24
    cols = 8
    rows = math.ceil(len(files) / cols)
    sheet = Image.new("RGBA", (cols * thumb, rows * (thumb + label)), (244, 239, 230, 255))
    draw = ImageDraw.Draw(sheet)
    for i, rel in enumerate(files):
        path = ASSETS / rel
        if not path.exists():
            continue
        img = Image.open(path).convert("RGBA")
        preview = img.copy()
        preview.thumbnail((thumb - 14, thumb - 30), Image.Resampling.LANCZOS)
        x = (i % cols) * thumb + (thumb - preview.width) // 2
        y = (i // cols) * (thumb + label) + 5
        sheet.alpha_composite(preview, (x, y))
        draw.text(
            ((i % cols) * thumb + 4, (i // cols) * (thumb + label) + thumb - 5),
            Path(rel).name[:17],
            fill=(72, 58, 49, 255),
        )
    CONTACT.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(CONTACT)


def main() -> None:
    written: list[str] = []

    icon_names = [
        "ui/time_morning_icon.png",
        "ui/time_afternoon_icon.png",
        "ui/time_evening_icon.png",
        "ui/time_night_icon.png",
        "ui/weather_sunny_icon.png",
        "ui/weather_cloudy_icon.png",
        "ui/weather_rain_icon.png",
        "ui/weather_storm_icon.png",
        "ui/season_spring_icon.png",
        "ui/season_summer_icon.png",
        "ui/season_autumn_icon.png",
        "ui/season_winter_icon.png",
        "ui/achievement_first_harvest_icon.png",
        "ui/achievement_best_fisher_icon.png",
        "ui/achievement_animal_lover_icon.png",
        "ui/festival_flower_icon.png",
    ]
    written += [copy_asset(frame("phase7_icons", i), rel) for i, rel in enumerate(icon_names, start=1)]

    fx_names = [
        "effects/weather_rain_overlay.png",
        "effects/weather_storm_overlay.png",
        "effects/weather_fog_overlay.png",
        "effects/weather_cloud_shadow_overlay.png",
        "effects/season_spring_petals.png",
        "effects/season_summer_fireflies.png",
        "effects/season_autumn_leaves.png",
        "effects/season_winter_snowflakes.png",
        "effects/pet_friendship_burst.png",
        "effects/fishing_festival_splash.png",
        "effects/flower_festival_burst.png",
        "effects/achievement_sparkle_burst.png",
    ]
    written += [copy_asset(fx_frame(i), rel) for i, rel in enumerate(fx_names, start=1)]

    prop_names = [
        "nature/beach_shell_pile.png",
        "fishing/crab_icon.png",
        "buildings/driftwood_decor.png",
        "buildings/coral_starfish_decor.png",
        "items/rare_blue_ore_icon.png",
        "items/rare_gold_ore_icon.png",
        "buildings/cave_entrance.png",
        "nature/mountain_pine_shrub.png",
        "nature/glowing_mushroom_cluster.png",
        "nature/giant_red_mushroom.png",
        "nature/rare_glowing_plant.png",
        "buildings/bunny_stump_house.png",
        "buildings/snowman.png",
        "nature/icy_crystal_cluster.png",
        "nature/frozen_pond_marker.png",
        "buildings/penguin_nest.png",
    ]
    written += [copy_asset(frame("phase8_props", i), rel) for i, rel in enumerate(prop_names, start=1)]

    tile_fish_names = [
        "tiles/beach_sand_tile.png",
        "tiles/ocean_water_tile.png",
        "tiles/mountain_ground_tile.png",
        "tiles/snow_tile.png",
        "tiles/mushroom_moss_tile.png",
        "tiles/frozen_pond_tile.png",
        "tiles/cave_floor_tile.png",
        "tiles/festival_grass_tile.png",
        "fishing/tropical_ocean_fish_icon.png",
        "fishing/ocean_fish_icon.png",
        "fishing/winter_fish_icon.png",
        "fishing/mountain_trout_icon.png",
        "items/rare_ore_shard.png",
        "items/snowball_icon.png",
        "items/glowing_mushroom_icon.png",
        "items/crab_drop.png",
    ]
    written += [copy_asset(frame("phase8_tiles_fish", i), rel) for i, rel in enumerate(tile_fish_names, start=1)]

    for pet in ["eagle", "penguin"]:
        pet_dir = PACK / f"{pet}_walk"
        for direction in ["down", "left", "right", "up"]:
            written.append(copy_asset(pet_dir / f"{direction}-strip.png", f"pets/{pet}_walk_{direction}.png"))
        written.append(copy_asset(pet_dir / "down-1.png", f"pets/{pet}_idle.png"))

    pipeline_meta: dict[str, object] = {}
    for meta_path in sorted(PACK.glob("*/pipeline-meta.json")):
        pipeline_meta[meta_path.parent.name] = json.loads(meta_path.read_text(encoding="utf-8"))

    build_contact_sheet(written)
    MANIFEST.write_text(
        json.dumps(
            {
                "pack": "phase7_8_asset_pack",
                "asset_count": len(written),
                "assets": written,
                "raw_dir": "build/generated-assets/raw/phase7_8",
                "processed_dir": "build/phase7_8_sprite_pack",
                "contact_sheet": str(CONTACT.relative_to(ROOT)),
                "pipeline_meta": pipeline_meta,
                "notes": [
                    "Raw art was generated with the generate2dsprite workflow and solid #FF00FF backgrounds.",
                    "Some raw sheets report edge-touch metadata, but processed outputs were visually checked before export.",
                    "No code, scenes, data contracts, or task statuses were changed by this asset export.",
                ],
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )

    print(f"Wrote {len(written)} assets")
    print(MANIFEST)
    print(CONTACT)


if __name__ == "__main__":
    main()

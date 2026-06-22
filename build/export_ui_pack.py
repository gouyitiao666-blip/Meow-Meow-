from pathlib import Path
from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "build" / "generated-assets" / "raw"
OUT = ROOT / "assets" / "ui"
PREVIEW = ROOT / "build" / "ui_asset_pack_contact_sheet.png"


PANELS = [
    ("inventory_panel.png", (512, 384)),
    ("tool_hotbar.png", (512, 96)),
    ("dialogue_box.png", (640, 160)),
    ("dialogue_nameplate.png", (220, 56)),
    ("pause_panel.png", (384, 384)),
    ("resume_button.png", (192, 64)),
    ("save_button.png", (192, 64)),
    ("toast_panel.png", (384, 80)),
    ("item_popup_panel.png", (256, 96)),
]

ICONS = [
    ("inventory_slot.png", (64, 64)),
    ("inventory_slot_selected.png", (64, 64)),
    ("tool_slot.png", (64, 64)),
    ("tool_slot_selected.png", (64, 64)),
    ("dialogue_next_arrow.png", (32, 32)),
    ("interact_key_icon.png", (48, 48)),
    ("pickup_icon.png", (48, 48)),
    ("plant_prompt_icon.png", (48, 48)),
    ("harvest_prompt_icon.png", (48, 48)),
    ("fishing_prompt_icon.png", (48, 48)),
    ("coin_icon.png", (32, 32)),
    ("heart_icon.png", (32, 32)),
    ("energy_icon.png", (32, 32)),
    ("settings_icon.png", (32, 32)),
    ("pet_friendship_heart.png", (32, 32)),
    ("pet_emote_heart.png", (48, 48)),
    ("pet_emote_happy.png", (48, 48)),
]


def remove_magenta(img: Image.Image) -> Image.Image:
    img = img.convert("RGBA")
    pixels = img.load()
    width, height = img.size
    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            if r > 175 and b > 145 and g < 95:
                pixels[x, y] = (r, g, b, 0)
    return img


def alpha_bbox(img: Image.Image):
    return img.getchannel("A").getbbox()


def export_cell(sheet: Image.Image, rows: int, cols: int, index: int, name: str, size: tuple[int, int], expand: int = 0) -> None:
    cell_w = sheet.width // cols
    cell_h = sheet.height // rows
    row = index // cols
    col = index % cols
    cell = sheet.crop((
        max(0, col * cell_w - expand),
        max(0, row * cell_h - expand),
        min(sheet.width, (col + 1) * cell_w + expand),
        min(sheet.height, (row + 1) * cell_h + expand),
    ))
    cell = remove_magenta(cell)

    bbox = alpha_bbox(cell)
    if bbox is None:
        art = Image.new("RGBA", size, (0, 0, 0, 0))
    else:
        art = cell.crop(bbox)
        max_w = max(1, int(size[0] * 0.92))
        max_h = max(1, int(size[1] * 0.88))
        art.thumbnail((max_w, max_h), Image.Resampling.LANCZOS)
        out = Image.new("RGBA", size, (0, 0, 0, 0))
        out.alpha_composite(art, ((size[0] - art.width) // 2, (size[1] - art.height) // 2))
        art = out

    OUT.mkdir(parents=True, exist_ok=True)
    art.save(OUT / name)


def export_box(sheet: Image.Image, box: tuple[int, int, int, int], name: str, size: tuple[int, int]) -> None:
    cell = sheet.crop(box)
    cell = remove_magenta(cell)

    bbox = alpha_bbox(cell)
    if bbox is None:
        art = Image.new("RGBA", size, (0, 0, 0, 0))
    else:
        art = cell.crop(bbox)
        max_w = max(1, int(size[0] * 0.92))
        max_h = max(1, int(size[1] * 0.88))
        art.thumbnail((max_w, max_h), Image.Resampling.LANCZOS)
        out = Image.new("RGBA", size, (0, 0, 0, 0))
        out.alpha_composite(art, ((size[0] - art.width) // 2, (size[1] - art.height) // 2))
        art = out

    OUT.mkdir(parents=True, exist_ok=True)
    art.save(OUT / name)


def component_boxes(img: Image.Image, min_area: int) -> list[tuple[int, int, int, int]]:
    keyed = remove_magenta(img)
    alpha = keyed.getchannel("A")
    width, height = keyed.size
    seen = bytearray(width * height)
    boxes: list[tuple[int, int, int, int, int]] = []

    for y in range(height):
        for x in range(width):
            idx = y * width + x
            if seen[idx] or alpha.getpixel((x, y)) == 0:
                continue

            stack = [(x, y)]
            seen[idx] = 1
            min_x = max_x = x
            min_y = max_y = y
            area = 0

            while stack:
                px, py = stack.pop()
                area += 1
                min_x = min(min_x, px)
                max_x = max(max_x, px)
                min_y = min(min_y, py)
                max_y = max(max_y, py)

                for nx, ny in ((px + 1, py), (px - 1, py), (px, py + 1), (px, py - 1)):
                    if nx < 0 or ny < 0 or nx >= width or ny >= height:
                        continue
                    nidx = ny * width + nx
                    if seen[nidx] or alpha.getpixel((nx, ny)) == 0:
                        continue
                    seen[nidx] = 1
                    stack.append((nx, ny))

            if area >= min_area:
                boxes.append((min_x, min_y, max_x + 1, max_y + 1, area))

    boxes.sort(key=lambda b: (b[1] + b[3]) / 2)
    rows: list[list[tuple[int, int, int, int, int]]] = []
    for box in boxes:
        cy = (box[1] + box[3]) / 2
        for row in rows:
            row_cy = sum((b[1] + b[3]) / 2 for b in row) / len(row)
            if abs(cy - row_cy) < height * 0.12:
                row.append(box)
                break
        else:
            rows.append([box])

    ordered: list[tuple[int, int, int, int]] = []
    for row in rows:
        row.sort(key=lambda b: (b[0] + b[2]) / 2)
        ordered.extend((b[0], b[1], b[2], b[3]) for b in row)

    return ordered


def export_component(sheet: Image.Image, box: tuple[int, int, int, int], name: str, size: tuple[int, int]) -> None:
    keyed = remove_magenta(sheet)
    pad = 16
    box = (
        max(0, box[0] - pad),
        max(0, box[1] - pad),
        min(sheet.width, box[2] + pad),
        min(sheet.height, box[3] + pad),
    )
    art = keyed.crop(box)
    bbox = alpha_bbox(art)
    if bbox is not None:
        art = art.crop(bbox)
    art.thumbnail((max(1, int(size[0] * 0.94)), max(1, int(size[1] * 0.88))), Image.Resampling.LANCZOS)
    out = Image.new("RGBA", size, (0, 0, 0, 0))
    out.alpha_composite(art, ((size[0] - art.width) // 2, (size[1] - art.height) // 2))
    OUT.mkdir(parents=True, exist_ok=True)
    out.save(OUT / name)


def build_preview(files: list[str]) -> None:
    thumb_w = 170
    thumb_h = 130
    cols = 4
    rows = (len(files) + cols - 1) // cols
    sheet = Image.new("RGBA", (cols * thumb_w, rows * thumb_h), (245, 242, 232, 255))
    draw = ImageDraw.Draw(sheet)

    for i, name in enumerate(files):
        img = Image.open(OUT / name).convert("RGBA")
        thumb = img.copy()
        thumb.thumbnail((thumb_w - 20, thumb_h - 36), Image.Resampling.LANCZOS)
        x = (i % cols) * thumb_w + (thumb_w - thumb.width) // 2
        y = (i // cols) * thumb_h + 8
        sheet.alpha_composite(thumb, (x, y))
        draw.text(((i % cols) * thumb_w + 6, (i // cols) * thumb_h + thumb_h - 22), name[:24], fill=(82, 65, 55, 255))

    PREVIEW.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(PREVIEW)


def main() -> None:
    panel_sheet = Image.open(RAW / "ui_pack_panels_3x3_raw.png")
    icon_sheet = Image.open(RAW / "ui_pack_icons_5x4_raw.png")

    panel_boxes = component_boxes(panel_sheet, min_area=2500)
    if len(panel_boxes) < len(PANELS):
        raise RuntimeError(f"Expected at least {len(PANELS)} panel components, found {len(panel_boxes)}")
    for box, (name, size) in zip(panel_boxes, PANELS):
        export_component(panel_sheet, box, name, size)

    x_edges = [0, 350, 700, 1050, icon_sheet.width]
    y_edges = [0, 290, 500, 710, 930, icon_sheet.height]
    for index, (name, size) in enumerate(ICONS):
        row = index // 4
        col = index % 4
        export_box(icon_sheet, (x_edges[col], y_edges[row], x_edges[col + 1], y_edges[row + 1]), name, size)

    build_preview([name for name, _size in PANELS + ICONS])


if __name__ == "__main__":
    main()

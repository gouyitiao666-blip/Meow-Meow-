class_name UiSkin
extends RefCounted
## Shared cozy-UI skinning helpers (visual polish pass). Turns assets/ui panel
## and slot art into StyleBoxTextures and applies them, so the priority panels
## (Inventory/Dialogue/Shop) get their bespoke look without copy-pasted code.
## The global look comes from scenes/ui/MeowTheme.tres; these are per-panel
## overrides on top of it.

## A 9-sliced panel StyleBox from an asset path. `tex_margin` is the 9-slice
## border (px); `content_margin` is the inner padding for child controls.
static func panel_box(path: String, content_margin := 16.0, tex_margin := 28.0) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	if path != "" and ResourceLoader.exists(path):
		sb.texture = load(path)
	sb.texture_margin_left = tex_margin
	sb.texture_margin_top = tex_margin
	sb.texture_margin_right = tex_margin
	sb.texture_margin_bottom = tex_margin
	sb.content_margin_left = content_margin
	sb.content_margin_top = content_margin
	sb.content_margin_right = content_margin
	sb.content_margin_bottom = content_margin
	return sb


## Overrides a PanelContainer/Panel's background with the given panel art.
static func apply_panel(panel: Control, path: String, content_margin := 16.0, tex_margin := 28.0) -> void:
	if panel == null:
		return
	panel.add_theme_stylebox_override("panel", panel_box(path, content_margin, tex_margin))


## A StyleBox for a 64px inventory/shop/tool slot (small, light 9-slice border).
static func slot_box(path: String) -> StyleBoxTexture:
	return panel_box(path, 6.0, 12.0)


## Overrides a slot PanelContainer's background with the given slot art.
static func apply_slot(panel: Control, path: String) -> void:
	if panel == null:
		return
	panel.add_theme_stylebox_override("panel", slot_box(path))


## A rounded cozy flat button box in a given colour. (The decorative button art
## doesn't 9-slice — its shape is centred with transparent padding — so buttons
## use a clean flat box instead.)
static func button_box(bg: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 3
	sb.border_color = Color(0.45, 0.32, 0.2)
	sb.corner_radius_top_left = 10
	sb.corner_radius_top_right = 10
	sb.corner_radius_bottom_right = 10
	sb.corner_radius_bottom_left = 10
	sb.content_margin_left = 16.0
	sb.content_margin_right = 16.0
	sb.content_margin_top = 8.0
	sb.content_margin_bottom = 8.0
	return sb


## Skins a Button with a warm flat box in `tint` (so e.g. shop buy/sell read
## distinctly). normal/hover/pressed/disabled are derived from the tint.
static func apply_button(button: Button, tint := Color(0.957, 0.886, 0.737)) -> void:
	if button == null:
		return
	button.add_theme_stylebox_override("normal", button_box(tint))
	button.add_theme_stylebox_override("hover", button_box(tint.lightened(0.1)))
	button.add_theme_stylebox_override("pressed", button_box(tint.darkened(0.12)))
	var dis := button_box(Color(tint.r, tint.g, tint.b, 0.5))
	dis.border_color = Color(0.55, 0.5, 0.45, 0.5)
	button.add_theme_stylebox_override("disabled", dis)
	button.add_theme_color_override("font_color", Color(0.2, 0.14, 0.08))

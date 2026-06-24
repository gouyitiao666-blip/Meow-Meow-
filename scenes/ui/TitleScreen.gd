extends Control
## Title screen (Phase 14.1). New Game / Continue / Quit, then flows into the
## world. Continue keeps the existing save; New Game clears it for a fresh start.
## Cozy look: warm background + the wooden signboard banner + clean flat buttons.

const WORLD_SCENE := "res://scenes/world/World.tscn"
const BG_COLOR := Color(0.79, 0.88, 0.66)  ## soft meadow green (never a blank grey screen)
const BTN_SIZE := Vector2(280, 60)


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = BG_COLOR
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(vbox)

	# Title on the wooden signboard banner.
	var banner := Control.new()
	banner.custom_minimum_size = Vector2(420, 210)
	vbox.add_child(banner)
	if ResourceLoader.exists("res://assets/ui/title_screen_panel.png"):
		var sign := TextureRect.new()
		sign.set_anchors_preset(Control.PRESET_FULL_RECT)
		sign.texture = load("res://assets/ui/title_screen_panel.png")
		sign.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sign.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		sign.mouse_filter = Control.MOUSE_FILTER_IGNORE
		banner.add_child(sign)
	var title := Label.new()
	title.text = "Meow Meow ~"
	title.set_anchors_preset(Control.PRESET_FULL_RECT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color(0.29, 0.19, 0.1))
	banner.add_child(title)

	var has_save := false
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager != null:
		has_save = bool(save_manager.call("has_save"))

	var continue_btn := _make_button("Continue")
	continue_btn.disabled = not has_save
	continue_btn.pressed.connect(_continue)
	vbox.add_child(continue_btn)

	var new_btn := _make_button("New Game")
	new_btn.pressed.connect(_new_game)
	vbox.add_child(new_btn)

	var quit_btn := _make_button("Quit")
	quit_btn.pressed.connect(func(): get_tree().quit())
	vbox.add_child(quit_btn)


## A centered, fixed-size cozy flat button.
func _make_button(text: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = BTN_SIZE
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.add_theme_font_size_override("font_size", 22)
	UiSkin.apply_button(btn)
	return btn


func _continue() -> void:
	get_tree().change_scene_to_file(WORLD_SCENE)


func _new_game() -> void:
	# Clear the save so the world starts fresh.
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager != null:
		DirAccess.remove_absolute(String(save_manager.call("get_save_path")))
	get_tree().change_scene_to_file(WORLD_SCENE)

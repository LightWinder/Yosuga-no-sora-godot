class_name ConfigPageBase
extends Control


## Shared 1920×1080 design-space page surface for the config tabs.  Pages emit
## typed setting patches; the shell owns values, preview and persistence.
signal patch_requested(patch: Dictionary, immediate: bool)

const DESIGN_SIZE := Vector2(1920.0, 1080.0)


func _ready() -> void:
	position = Vector2.ZERO
	size = DESIGN_SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func sync_from(_settings: Dictionary) -> void:
	pass


func add_page_background(texture_path: String) -> TextureRect:
	var background := TextureRect.new()
	background.name = "PageBackground"
	background.position = Vector2.ZERO
	background.size = DESIGN_SIZE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	background.texture = load(texture_path) as Texture2D
	add_child(background)
	return background


func add_dual_toggle(
		normal_path: String,
		selected_path: String,
		position_value: Vector2,
		normal_width := 0,
		hover_x := -1,
		hover_width := 0,
		selected_offset := Vector2.ZERO
) -> ConfigToggleButton:
	var button := ConfigToggleButton.new()
	button.configure_dual(normal_path, selected_path, normal_width, hover_x, hover_width, selected_offset)
	button.position = position_value
	add_child(button)
	return button


func add_strip_toggle(strip_path: String, position_value: Vector2) -> ConfigToggleButton:
	var button := ConfigToggleButton.new()
	button.configure_strip_toggle(strip_path)
	button.position = position_value
	add_child(button)
	return button


func add_check_box(
		texture: Texture2D,
		off_normal: Rect2,
		off_hover: Rect2,
		on_normal: Rect2,
		on_hover: Rect2,
		position_value: Vector2,
		checked_offset := Vector2.ZERO
) -> ConfigCheckButton:
	var button := ConfigCheckButton.new()
	button.configure_frames(
		_region(texture, off_normal),
		_region(texture, off_hover),
		_region(texture, on_normal),
		_region(texture, on_hover),
		checked_offset
	)
	button.position = position_value
	add_child(button)
	return button


func add_slider(
		key: String,
		from: Vector2,
		to: Vector2,
		min_scale := 1.0,
		max_scale := 1.0
) -> ConfigKnobSlider:
	var slider := ConfigKnobSlider.new()
	slider.name = key
	slider.configure_track(from, to, min_scale, max_scale)
	add_child(slider)
	return slider


func emit_patch(patch: Dictionary, immediate := false) -> void:
	patch_requested.emit(patch, immediate)


func _region(atlas: Texture2D, region: Rect2) -> Texture2D:
	var result := AtlasTexture.new()
	result.atlas = atlas
	result.region = region
	result.filter_clip = true
	return result

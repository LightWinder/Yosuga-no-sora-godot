class_name ConfigVisualTokens
extends RefCounted


## Resolution-independent visual tokens for configuration controls. Artwork
## remains texture based; panels, text and interaction states render at the
## target resolution instead of being baked into 1920×1080 sprite strips.
const ACCENT := Color(0.10, 0.55, 0.76, 1.0)
const TEXT := Color(0.96, 0.99, 1.0, 1.0)
const PANEL_FILL := Color(0.96, 0.99, 1.0, 0.48)
const DISPLAY_FONT_PATH := "res://assets/fonts/Xiaolai-Regular.fontdata"
const SECTION_TITLE_FONT_SIZE := 44
const CHOICE_FONT_SIZE := 32
const CHOICE_OUTLINE_SIZE := 3
const PANEL_RADIUS := 20
const EMBOLDEN := 0.2

static var _choice_font: FontVariation
static var _section_title_font: FontVariation
static var _choice_glow_texture: GradientTexture2D


static func apply_panel(panel: Control, alpha := 0.48, radius := PANEL_RADIUS) -> void:
	var fill := PANEL_FILL
	fill.a = alpha
	panel.add_theme_stylebox_override("panel", _style(fill, Color.TRANSPARENT, 0, radius))
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE


static func apply_choice_button(button: Button, font_size := CHOICE_FONT_SIZE) -> void:
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", choice_font())
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_color_override("font_focus_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", Color(0.78, 0.88, 0.93, 0.58))
	button.add_theme_color_override("font_outline_color", Color(0.05, 0.40, 0.62, 1.0))
	button.add_theme_constant_override("outline_size", CHOICE_OUTLINE_SIZE)
	var empty := StyleBoxEmpty.new()
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(state, empty)


static func apply_choice_glow(highlight: TextureRect, strength: float) -> void:
	highlight.texture = choice_glow_texture()
	highlight.modulate = Color(1.0, 1.0, 1.0, strength)


static func choice_font() -> FontVariation:
	if _choice_font == null:
		_choice_font = FontVariation.new()
		_choice_font.base_font = load(DISPLAY_FONT_PATH) as Font
		_choice_font.variation_embolden = EMBOLDEN
	return _choice_font


static func section_title_font() -> FontVariation:
	if _section_title_font == null:
		_section_title_font = FontVariation.new()
		_section_title_font.base_font = load(DISPLAY_FONT_PATH) as Font
		_section_title_font.variation_embolden = EMBOLDEN
	return _section_title_font


static func choice_glow_texture() -> GradientTexture2D:
	if _choice_glow_texture == null:
		var gradient := Gradient.new()
		gradient.offsets = PackedFloat32Array([0.0, 0.16, 0.5, 0.84, 1.0])
		gradient.colors = PackedColorArray([
			Color(0.16, 0.68, 0.86, 0.0),
			Color(0.16, 0.68, 0.86, 0.72),
			Color(0.34, 0.78, 0.91, 1.0),
			Color(0.16, 0.68, 0.86, 0.72),
			Color(0.16, 0.68, 0.86, 0.0),
		])
		_choice_glow_texture = GradientTexture2D.new()
		_choice_glow_texture.gradient = gradient
		_choice_glow_texture.width = 512
		_choice_glow_texture.height = 32
		_choice_glow_texture.fill_from = Vector2(0.0, 0.5)
		_choice_glow_texture.fill_to = Vector2(1.0, 0.5)
	return _choice_glow_texture


static func _style(fill: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	# Section cards own their padding through their child layout. Keeping the
	# style box content margins at zero makes local coordinates start exactly at
	# the visible panel edge and avoids double padding in PanelContainer.
	style.content_margin_left = 0.0
	style.content_margin_right = 0.0
	style.content_margin_top = 0.0
	style.content_margin_bottom = 0.0
	style.anti_aliasing = true
	return style

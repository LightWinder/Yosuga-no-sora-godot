class_name ConfigScreenPage
extends ConfigPageBase


## Behaviour for the screen-settings scene. The stable two-column hierarchy,
## section cards and headings live in config_screen_page.tscn; this script only
## creates repeatable option controls and owns their settings bindings.
## The preview textbox/avatar intentionally retain their source artwork.
const GRAPHIC_ROOT := "res://assets/content/settings/graphic/"

const CARD_DISPLAY_MODE := &"display_mode"
const CARD_WINDOW_SIZE := &"window_size"
const CARD_TEXTBOX_OPACITY := &"textbox_opacity"
const CARD_FONT_SELECTION := &"font_selection"
const CARD_DISPLAY_LANGUAGE := &"display_language"
const CARD_PREVIEW := &"preview"
const CARD_PORTRAIT_DISPLAY := &"portrait_display"
const CARD_READ_COLOR := &"read_color"
const CARD_SCREEN_EFFECT := &"screen_effect"

## The source atlas bakes its old “预览” heading into the top 57 pixels. Keep
## only the scenic portion so the live section title is never double-rendered.
const PREVIEW_ART_REGION := Rect2(1320, 361, 564, 256)
const FONT_OPTIONS: Array[Dictionary] = [
	{"label": "方正黑体", "font_type": 2, "rect": Rect2(132, 61, 220, 58)},
	{"label": "方正书宋", "font_type": 4, "rect": Rect2(380, 61, 220, 58)},
	{"label": "寒蝉圆黑体", "font_type": 0, "rect": Rect2(628, 61, 272, 58)},
	{"label": "方正楷体", "font_type": 3, "rect": Rect2(132, 141, 220, 58)},
	{"label": "方正仿宋", "font_type": 5, "rect": Rect2(380, 141, 220, 58)},
	{"label": "文泉驿点阵宋体", "font_type": 1, "rect": Rect2(628, 141, 272, 58)},
]
const WINDOW_WIDTH_OPTIONS: Array[Dictionary] = [
	{"label": "1920×1080", "width": 1920, "rect": Rect2(232, 41, 230, 58)},
	{"label": "1600×900", "width": 1600, "rect": Rect2(477, 41, 230, 58)},
	{"label": "1280×720", "width": 1280, "rect": Rect2(722, 41, 230, 58)},
]
const SCREEN_TOGGLES: Array[Dictionary] = [
	{"key": "portrait_visible", "card": CARD_PORTRAIT_DISPLAY, "x": 92.0},
	{"key": "read_color", "card": CARD_READ_COLOR, "x": 113.0},
	{"key": "screen_effect", "card": CARD_SCREEN_EFFECT, "x": 39.0},
]

var _window_mode_choices := ConfigChoiceGroup.new()
var _window_width_choices := ConfigChoiceGroup.new()
var _font_choices := ConfigChoiceGroup.new()
var _toggle_choices: Dictionary = {}
var _section_contents: Dictionary = {}
var _opacity_slider: ConfigKnobSlider
var _preview_textbox: TextureRect
var _preview_avatar: TextureRect
var _preview_text: Label


func _ready() -> void:
	super._ready()
	_bind_scene_nodes()
	_build_preview_art()
	_build_window_controls()
	_build_font_controls()
	_build_language_controls()
	_build_screen_toggles()
	_build_preview()
	_opacity_slider = add_vector_slider(
		"window_depth",
		Vector2(346, 78),
		Vector2(906, 78),
		_card_content(CARD_TEXTBOX_OPACITY)
	)
	_opacity_slider.value_changed.connect(_on_opacity_changed)
	if _is_mobile_platform():
		# Mobile platforms own window mode and size. Keep the informative layout,
		# but remove desktop-only controls from touch and focus traversal.
		_set_desktop_window_controls_visible(false)


func sync_from(settings: Dictionary) -> void:
	_window_mode_choices.select_value(str(settings.get("window_mode", "windowed")))
	_window_width_choices.select_value(int(settings.get("window_width", 1280)))
	_font_choices.select_value(int(settings.get("font_type", 0)))
	for key in _toggle_choices:
		(_toggle_choices[key] as ConfigChoiceGroup).select_value(bool(settings.get(key, true)))
	_opacity_slider.set_value_silent(float(settings.get("window_depth", 50)))
	_refresh_preview(settings)


func set_window_mode_for_test(mode: String) -> void:
	var normalized := "fullscreen" if mode == "fullscreen" else "windowed"
	emit_patch({"window_mode": normalized}, true)


func set_window_width_for_test(width: int) -> void:
	emit_patch({"window_width": width}, true)


func set_font_for_test(font_type: int) -> void:
	emit_patch({"font_type": font_type}, true)


func set_screen_toggle_for_test(key: String, enabled: bool) -> void:
	emit_patch({key: enabled}, true)


func _bind_scene_nodes() -> void:
	_section_contents = {
		CARD_DISPLAY_MODE: $MainColumns/LeftColumnMargin/LeftColumn/DisplayModeCard/Content,
		CARD_WINDOW_SIZE: $MainColumns/LeftColumnMargin/LeftColumn/WindowSizeCard/Content,
		CARD_TEXTBOX_OPACITY: $MainColumns/LeftColumnMargin/LeftColumn/TextboxOpacityCard/Content,
		CARD_FONT_SELECTION: $MainColumns/LeftColumnMargin/LeftColumn/FontSelectionCard/Content,
		CARD_DISPLAY_LANGUAGE: $MainColumns/RightColumn/UpperRow/DisplayLanguageCard/Content,
		CARD_PREVIEW: $MainColumns/RightColumn/UpperRow/PreviewCard/Content,
		CARD_PORTRAIT_DISPLAY: $MainColumns/RightColumn/LowerRow/PortraitDisplayCard/Content,
		CARD_READ_COLOR: $MainColumns/RightColumn/LowerRow/ReadColorCard/Content,
		CARD_SCREEN_EFFECT: $MainColumns/RightColumn/LowerRow/ScreenEffectCard/Content,
	}


func _card_content(key: StringName) -> Control:
	return _section_contents[key] as Control


func _build_preview_art() -> void:
	var source := load(GRAPHIC_ROOT + "bg.png") as Texture2D
	var cropped := AtlasTexture.new()
	cropped.atlas = source
	cropped.region = PREVIEW_ART_REGION
	cropped.filter_clip = true
	var art := TextureRect.new()
	art.name = "PreviewArtwork"
	art.position = Vector2(15, 75)
	art.size = PREVIEW_ART_REGION.size
	art.texture = cropped
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card_content(CARD_PREVIEW).add_child(art)


func _build_window_controls() -> void:
	var mode_content := _card_content(CARD_DISPLAY_MODE)
	_window_mode_choices.add_choice(_add_choice_button(mode_content, "全屏", Rect2(322, 41, 210, 58), 40), "fullscreen")
	_window_mode_choices.add_choice(_add_choice_button(mode_content, "窗口", Rect2(592, 41, 210, 58), 40), "windowed")
	_window_mode_choices.value_selected.connect(func(value: Variant) -> void:
		emit_patch({"window_mode": str(value)}, true)
	)
	var size_content := _card_content(CARD_WINDOW_SIZE)
	for definition in WINDOW_WIDTH_OPTIONS:
		var button := _add_choice_button(size_content, str(definition.label), definition.rect as Rect2, 34)
		_window_width_choices.add_choice(button, int(definition.width))
	_window_width_choices.value_selected.connect(func(value: Variant) -> void:
		emit_patch({"window_width": int(value)}, true)
	)


func _build_font_controls() -> void:
	var font_content := _card_content(CARD_FONT_SELECTION)
	for definition in FONT_OPTIONS:
		var button := _add_choice_button(font_content, str(definition.label), definition.rect as Rect2, 33)
		_font_choices.add_choice(button, int(definition.font_type))
	_font_choices.value_selected.connect(func(value: Variant) -> void:
		emit_patch({"font_type": int(value)}, true)
	)


func _build_language_controls() -> void:
	var content := _card_content(CARD_DISPLAY_LANGUAGE)
	var chinese := _add_choice_button(content, "中文", Rect2(48, 99, 176, 64), 40)
	chinese.selected = true
	chinese.focus_mode = Control.FOCUS_NONE
	chinese.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var japanese := _add_choice_button(content, "日文", Rect2(48, 207, 176, 64), 40)
	japanese.disabled = true
	japanese.focus_mode = Control.FOCUS_NONE
	japanese.refresh_visual()


func _build_screen_toggles() -> void:
	for definition in SCREEN_TOGGLES:
		var key := String(definition.key)
		var x := float(definition.x)
		var content := _card_content(StringName(definition.card))
		var on_button := _add_choice_button(content, "ON", Rect2(x, 75, 120, 54), 36)
		var off_button := _add_choice_button(content, "OFF", Rect2(x, 147, 120, 54), 36)
		var choices := ConfigChoiceGroup.new()
		choices.add_choice(on_button, true)
		choices.add_choice(off_button, false)
		choices.value_selected.connect(_on_screen_toggle_selected.bind(key))
		_toggle_choices[key] = choices


func _build_preview() -> void:
	var content := _card_content(CARD_PREVIEW)
	_preview_textbox = TextureRect.new()
	_preview_textbox.name = "PreviewTextbox"
	_preview_textbox.position = Vector2(16, 238)
	_preview_textbox.size = Vector2(563, 92)
	_preview_textbox.texture = load(GRAPHIC_ROOT + "textbox.png") as Texture2D
	_preview_textbox.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_preview_textbox.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_preview_textbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(_preview_textbox)
	_preview_avatar = TextureRect.new()
	_preview_avatar.name = "PreviewAvatar"
	_preview_avatar.position = Vector2(15, 233)
	_preview_avatar.texture = load(GRAPHIC_ROOT + "avatar.png") as Texture2D
	if _preview_avatar.texture != null:
		_preview_avatar.size = _preview_avatar.texture.get_size()
	_preview_avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_preview_avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_preview_avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(_preview_avatar)
	_preview_text = Label.new()
	_preview_text.name = "PreviewText"
	_preview_text.position = Vector2(150, 259)
	_preview_text.size = Vector2(405, 58)
	_preview_text.text = "这是已读文本显示效果。"
	_preview_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_preview_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_preview_text.add_theme_font_size_override("font_size", 30)
	_preview_text.add_theme_constant_override("outline_size", 3)
	_preview_text.add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.12, 0.85))
	_preview_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(_preview_text)


func _add_choice_button(parent: Control, text_value: String, rect: Rect2, font_size := 32) -> ConfigChoiceButton:
	var button := ConfigChoiceButton.new()
	button.name = text_value
	button.configure(text_value, rect, font_size)
	parent.add_child(button)
	return button


func _on_opacity_changed(value: float) -> void:
	emit_patch({"window_depth": int(value)})
	_preview_textbox.modulate.a = value / 100.0


func _on_screen_toggle_selected(value: Variant, key: String) -> void:
	emit_patch({key: bool(value)}, true)


func _refresh_preview(settings: Dictionary) -> void:
	_preview_textbox.modulate.a = float(settings.get("window_depth", 50)) / 100.0
	_preview_avatar.visible = bool(settings.get("portrait_visible", true))
	if bool(settings.get("read_color", true)):
		_preview_text.add_theme_color_override("font_color", Color(0.55, 0.72, 0.92, 1.0))
	else:
		_preview_text.add_theme_color_override("font_color", Color.WHITE)


func _set_desktop_window_controls_visible(visible_value: bool) -> void:
	_window_mode_choices.set_visible(visible_value)
	_window_width_choices.set_visible(visible_value)


func _is_mobile_platform() -> bool:
	return OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios")

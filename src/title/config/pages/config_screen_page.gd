class_name ConfigScreenPage
extends ConfigPageBase


## Screen tab rendered with Godot controls instead of the source's baked UI
## sprites. The scenic preview and avatar remain artwork; panels, labels,
## choices, switches, slider and section headings are resolution-independent.
## The preview textbox/avatar intentionally retain their source artwork.
const GRAPHIC_ROOT := "res://assets/content/settings/graphic/"
## The source atlas bakes its old “预览” heading into the top 57 pixels. Keep
## only the scenic portion so the live section title is never double-rendered.
const PREVIEW_ART_REGION := Rect2(1320, 361, 564, 256)
const SECTION_PANELS: Array[Dictionary] = [
	{"rect": Rect2(44, 288, 962, 111), "title_rect": Rect2(64, 298, 330, 70), "title": "显示模式", "name": "DisplayModeTitle"},
	{"rect": Rect2(44, 409, 962, 112), "title_rect": Rect2(64, 418, 350, 70), "title": "窗口大小", "name": "WindowSizeTitle"},
	{"rect": Rect2(44, 528, 962, 110), "title_rect": Rect2(64, 537, 420, 70), "title": "文本框不透明度", "name": "TextboxOpacityTitle"},
	{"rect": Rect2(44, 649, 962, 220), "title_rect": Rect2(64, 656, 330, 70), "title": "字体选择", "name": "FontSelectionTitle"},
	{"rect": Rect2(1019, 286, 271, 352), "title_rect": Rect2(1037, 298, 270, 70), "title": "显示语言", "name": "DisplayLanguageTitle"},
	{"rect": Rect2(1305, 286, 590, 351), "title_rect": Rect2(1323, 298, 230, 70), "title": "预览", "name": "PreviewTitle"},
	{"rect": Rect2(1019, 649, 307, 220), "title_rect": Rect2(1037, 653, 310, 70), "title": "人物头像显示", "name": "PortraitDisplayTitle"},
	{"rect": Rect2(1337, 649, 346, 220), "title_rect": Rect2(1355, 653, 345, 70), "title": "已读文本颜色变更", "name": "ReadColorTitle", "font_size": 38},
	{"rect": Rect2(1698, 649, 197, 220), "title_rect": Rect2(1716, 653, 204, 70), "title": "动画效果", "name": "ScreenEffectTitle", "font_size": 39},
]
const FONT_OPTIONS: Array[Dictionary] = [
	{"label": "方正黑体", "font_type": 2, "rect": Rect2(176, 710, 220, 58)},
	{"label": "方正书宋", "font_type": 4, "rect": Rect2(424, 710, 220, 58)},
	{"label": "寒蝉圆黑体", "font_type": 0, "rect": Rect2(672, 710, 272, 58)},
	{"label": "方正楷体", "font_type": 3, "rect": Rect2(176, 790, 220, 58)},
	{"label": "方正仿宋", "font_type": 5, "rect": Rect2(424, 790, 220, 58)},
	{"label": "文泉驿点阵宋体", "font_type": 1, "rect": Rect2(672, 790, 272, 58)},
]
const WINDOW_WIDTH_OPTIONS: Array[Dictionary] = [
	{"label": "1920×1080", "width": 1920, "rect": Rect2(276, 450, 230, 58)},
	{"label": "1600×900", "width": 1600, "rect": Rect2(521, 450, 230, 58)},
	{"label": "1280×720", "width": 1280, "rect": Rect2(766, 450, 230, 58)},
]
const SCREEN_TOGGLES: Array[Dictionary] = [
	{"key": "portrait_visible", "x": 1111.0},
	{"key": "read_color", "x": 1450.0},
	{"key": "screen_effect", "x": 1737.0},
]

var _window_mode_choices := ConfigChoiceGroup.new()
var _window_width_choices := ConfigChoiceGroup.new()
var _font_choices := ConfigChoiceGroup.new()
var _toggle_choices: Dictionary = {}
var _opacity_slider: ConfigKnobSlider
var _preview_textbox: TextureRect
var _preview_avatar: TextureRect
var _preview_text: Label


func _ready() -> void:
	super._ready()
	_build_surface()
	_build_window_controls()
	_build_font_controls()
	_build_language_controls()
	_build_screen_toggles()
	_build_preview()
	_opacity_slider = add_vector_slider("window_depth", Vector2(390, 606), Vector2(950, 606))
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


func _build_surface() -> void:
	for definition in SECTION_PANELS:
		var panel := Panel.new()
		var rect := definition.rect as Rect2
		panel.position = rect.position
		panel.size = rect.size
		ConfigVisualTokens.apply_panel(panel)
		add_child(panel)
	_build_preview_art()
	for definition in SECTION_PANELS:
		var title := ConfigSectionTitle.new()
		title.name = str(definition.name)
		title.configure(
			str(definition.title),
			definition.title_rect as Rect2,
			int(definition.get("font_size", 44))
		)
		add_child(title)


func _build_preview_art() -> void:
	var source := load(GRAPHIC_ROOT + "bg.png") as Texture2D
	var cropped := AtlasTexture.new()
	cropped.atlas = source
	cropped.region = PREVIEW_ART_REGION
	cropped.filter_clip = true
	var art := TextureRect.new()
	art.name = "PreviewArtwork"
	art.position = PREVIEW_ART_REGION.position
	art.size = PREVIEW_ART_REGION.size
	art.texture = cropped
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(art)


func _build_window_controls() -> void:
	_window_mode_choices.add_choice(_add_choice_button("全屏", Rect2(366, 329, 210, 58), 40), "fullscreen")
	_window_mode_choices.add_choice(_add_choice_button("窗口", Rect2(636, 329, 210, 58), 40), "windowed")
	_window_mode_choices.value_selected.connect(func(value: Variant) -> void:
		emit_patch({"window_mode": str(value)}, true)
	)
	for definition in WINDOW_WIDTH_OPTIONS:
		var button := _add_choice_button(str(definition.label), definition.rect as Rect2, 34)
		_window_width_choices.add_choice(button, int(definition.width))
	_window_width_choices.value_selected.connect(func(value: Variant) -> void:
		emit_patch({"window_width": int(value)}, true)
	)


func _build_font_controls() -> void:
	for definition in FONT_OPTIONS:
		var button := _add_choice_button(str(definition.label), definition.rect as Rect2, 33)
		_font_choices.add_choice(button, int(definition.font_type))
	_font_choices.value_selected.connect(func(value: Variant) -> void:
		emit_patch({"font_type": int(value)}, true)
	)


func _build_language_controls() -> void:
	var chinese := _add_choice_button("中文", Rect2(1067, 385, 176, 64), 40)
	chinese.selected = true
	chinese.focus_mode = Control.FOCUS_NONE
	chinese.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var japanese := _add_choice_button("日文", Rect2(1067, 493, 176, 64), 40)
	japanese.disabled = true
	japanese.focus_mode = Control.FOCUS_NONE
	japanese.refresh_visual()


func _build_screen_toggles() -> void:
	for definition in SCREEN_TOGGLES:
		var key := String(definition.key)
		var x := float(definition.x)
		var on_button := _add_choice_button("ON", Rect2(x, 724, 120, 54), 36)
		var off_button := _add_choice_button("OFF", Rect2(x, 796, 120, 54), 36)
		var choices := ConfigChoiceGroup.new()
		choices.add_choice(on_button, true)
		choices.add_choice(off_button, false)
		choices.value_selected.connect(_on_screen_toggle_selected.bind(key))
		_toggle_choices[key] = choices


func _build_preview() -> void:
	_preview_textbox = TextureRect.new()
	_preview_textbox.name = "PreviewTextbox"
	_preview_textbox.position = Vector2(1321, 524)
	_preview_textbox.size = Vector2(563, 92)
	_preview_textbox.texture = load(GRAPHIC_ROOT + "textbox.png") as Texture2D
	_preview_textbox.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_preview_textbox.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_preview_textbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_preview_textbox)
	_preview_avatar = TextureRect.new()
	_preview_avatar.name = "PreviewAvatar"
	_preview_avatar.position = Vector2(1320, 519)
	_preview_avatar.texture = load(GRAPHIC_ROOT + "avatar.png") as Texture2D
	if _preview_avatar.texture != null:
		_preview_avatar.size = _preview_avatar.texture.get_size()
	_preview_avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_preview_avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_preview_avatar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_preview_avatar)
	_preview_text = Label.new()
	_preview_text.name = "PreviewText"
	_preview_text.position = Vector2(1455, 545)
	_preview_text.size = Vector2(405, 58)
	_preview_text.text = "这是已读文本显示效果。"
	_preview_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_preview_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_preview_text.add_theme_font_size_override("font_size", 30)
	_preview_text.add_theme_constant_override("outline_size", 3)
	_preview_text.add_theme_color_override("font_outline_color", Color(0.1, 0.1, 0.12, 0.85))
	_preview_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_preview_text)


func _add_choice_button(text_value: String, rect: Rect2, font_size := 32) -> ConfigChoiceButton:
	var button := ConfigChoiceButton.new()
	button.configure(text_value, rect, font_size)
	add_child(button)
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

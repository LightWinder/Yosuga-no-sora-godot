class_name ConfigScreenPage
extends ConfigPageBase


## Screen tab: window mode, resolution, opacity, font, language, preview.
const GRAPHIC_ROOT := "res://assets/content/settings/graphic/"
const FONT_BUTTONS: Array[Dictionary] = [
	{"normal": "fangzhengheiti1.png", "selected": "fangzhengheiti2.png", "pos": Vector2(217, 720), "nw": 156, "hx": 156, "hw": 160, "ox": -2},
	{"normal": "fangzhengshusongi1.png", "selected": "fangzhengshusong2.png", "pos": Vector2(459, 720), "nw": 160, "hx": 160, "hw": 164, "ox": -3},
	{"normal": "hanchanti1.png", "selected": "hanchanti2.png", "pos": Vector2(677, 720), "nw": 207, "hx": 207, "hw": 211, "ox": -3},
	{"normal": "fangzhengkaiti1.png", "selected": "fangzhengkaiti2.png", "pos": Vector2(213, 797), "nw": 164, "hx": 164, "hw": 167, "ox": -6},
	{"normal": "fangzhengfangsong1.png", "selected": "fangzhengfangsong2.png", "pos": Vector2(458, 797), "nw": 168, "hx": 168, "hw": 171, "ox": -4},
	{"normal": "dianzhensongti1.png", "selected": "dianzhensongti2.png", "pos": Vector2(683, 797), "nw": 240, "hx": 240, "hw": 243, "ox": 0},
]
## Button array index → CONFIG.fontType (source HD_FONT_TYPE_MAP).
const FONT_TYPE_MAP: Array[int] = [2, 4, 0, 3, 5, 1]
const WINDOW_WIDTH_BUTTONS: Array[Dictionary] = [
	{"normal": "1080p1.png", "selected": "1080p2.png", "pos": Vector2(255, 462), "width": 1920},
	{"normal": "900p1.png", "selected": "900p2.png", "pos": Vector2(492, 462), "width": 1600},
	{"normal": "720p1.png", "selected": "720p2.png", "pos": Vector2(725, 462), "width": 1280},
]
const SCREEN_TOGGLES: Array[Dictionary] = [
	{"key": "portrait_visible", "on": Vector2(1137, 730), "off": Vector2(1140, 805)},
	{"key": "read_color", "on": Vector2(1506, 730), "off": Vector2(1509, 805)},
	{"key": "screen_effect", "on": Vector2(1736, 730), "off": Vector2(1739, 805)},
]

var _fullscreen_button: ConfigToggleButton
var _window_button: ConfigToggleButton
var _width_buttons: Array[Dictionary] = []
var _font_buttons: Array[ConfigToggleButton] = []
var _toggle_buttons: Dictionary = {}
var _opacity_slider: ConfigKnobSlider
var _preview_textbox: TextureRect
var _preview_avatar: TextureRect
var _preview_text: Label


func _ready() -> void:
	super._ready()
	add_page_background(GRAPHIC_ROOT + "bg.png")
	_fullscreen_button = add_dual_toggle(GRAPHIC_ROOT + "fullscreen1.png", GRAPHIC_ROOT + "fullscreen2.png", Vector2(395, 340))
	_window_button = add_dual_toggle(GRAPHIC_ROOT + "window1.png", GRAPHIC_ROOT + "window2.png", Vector2(665, 340))
	_fullscreen_button.pressed.connect(func() -> void: emit_patch({"window_mode": "fullscreen"}, true))
	_window_button.pressed.connect(func() -> void: emit_patch({"window_mode": "windowed"}, true))
	for entry in WINDOW_WIDTH_BUTTONS:
		var button := add_dual_toggle(GRAPHIC_ROOT + str(entry.normal), GRAPHIC_ROOT + str(entry.selected), entry.pos)
		button.pressed.connect(_on_width_pressed.bind(int(entry.width)))
		_width_buttons.append({"button": button, "width": int(entry.width)})
	for index in FONT_BUTTONS.size():
		var entry: Dictionary = FONT_BUTTONS[index]
		var button := add_dual_toggle(
			GRAPHIC_ROOT + str(entry.normal),
			GRAPHIC_ROOT + str(entry.selected),
			entry.pos,
			int(entry.nw),
			int(entry.hx),
			int(entry.hw),
			Vector2(float(entry.ox), 0.0)
		)
		button.pressed.connect(_on_font_pressed.bind(index))
		_font_buttons.append(button)
	_opacity_slider = add_slider("window_depth", Vector2(390, 606), Vector2(950, 606), 1.0, 1.0)
	_opacity_slider.value_changed.connect(_on_opacity_changed)
	var chinese := add_dual_toggle(GRAPHIC_ROOT + "chinese1.png", GRAPHIC_ROOT + "chinese2.png", Vector2(1098, 405))
	chinese.selected = true
	chinese.disabled = true
	var japanese := add_dual_toggle(GRAPHIC_ROOT + "japanese1.png", GRAPHIC_ROOT + "janpanese2.png", Vector2(1098, 515))
	japanese.disabled = true
	for entry in SCREEN_TOGGLES:
		var key := String(entry.key)
		var on_button := _add_on_off_button(true, entry.on)
		var off_button := _add_on_off_button(false, entry.off)
		on_button.pressed.connect(func() -> void: emit_patch({key: true}, true))
		off_button.pressed.connect(func() -> void: emit_patch({key: false}, true))
		_toggle_buttons[key] = {"on": on_button, "off": off_button}
	if _is_mobile_platform():
		# Godot mobile windows are always managed fullscreen by the platform;
		# remove desktop-only hit targets from focus and touch traversal.
		_set_desktop_window_controls_visible(false)
	_build_preview()


func sync_from(settings: Dictionary) -> void:
	var mode := str(settings.get("window_mode", "windowed"))
	_fullscreen_button.selected = mode == "fullscreen"
	_window_button.selected = mode != "fullscreen"
	var width := int(settings.get("window_width", 1280))
	# The source chooses the closest HD bucket for arbitrary persisted desktop
	# widths (1760+/1440+/otherwise), instead of leaving all choices unselected.
	var selected_width := 1280
	if width >= TitleSettingsModel.WINDOW_WIDTH_1080P_MIN:
		selected_width = 1920
	elif width >= TitleSettingsModel.WINDOW_WIDTH_900P_MIN:
		selected_width = 1600
	for entry in _width_buttons:
		(entry.button as ConfigToggleButton).selected = int(entry.width) == selected_width
	var font_type := int(settings.get("font_type", 0))
	for index in _font_buttons.size():
		_font_buttons[index].selected = FONT_TYPE_MAP[index] == font_type
	for key in _toggle_buttons:
		var enabled := bool(settings.get(key, true))
		_toggle_buttons[key].on.selected = enabled
		_toggle_buttons[key].off.selected = not enabled
	_opacity_slider.set_value_silent(float(settings.get("window_depth", 50)))
	_refresh_preview(settings)


func _add_on_off_button(is_on: bool, position_value: Vector2) -> ConfigToggleButton:
	if is_on:
		return add_dual_toggle(GRAPHIC_ROOT + "ON1.png", GRAPHIC_ROOT + "ON2.png", position_value, 59, 59, 65, Vector2(1, 0))
	return add_dual_toggle(GRAPHIC_ROOT + "OFF1.png", GRAPHIC_ROOT + "OFF2.png", position_value, 85, 85, 89, Vector2(-5, 0))


func _build_preview() -> void:
	_preview_textbox = TextureRect.new()
	_preview_textbox.name = "PreviewTextbox"
	_preview_textbox.position = Vector2(1321, 524)
	_preview_textbox.texture = load(GRAPHIC_ROOT + "textbox.png") as Texture2D
	_preview_textbox.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_preview_textbox.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_preview_textbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_preview_textbox)
	_preview_avatar = TextureRect.new()
	_preview_avatar.name = "PreviewAvatar"
	_preview_avatar.position = Vector2(1320, 519)
	_preview_avatar.texture = load(GRAPHIC_ROOT + "avatar.png") as Texture2D
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


func _on_width_pressed(width: int) -> void:
	emit_patch({"window_width": width}, true)


func set_window_mode_for_test(mode: String) -> void:
	var normalized := "fullscreen" if mode == "fullscreen" else "windowed"
	emit_patch({"window_mode": normalized}, true)
	_fullscreen_button.selected = normalized == "fullscreen"
	_window_button.selected = normalized != "fullscreen"


func set_window_width_for_test(width: int) -> void:
	emit_patch({"window_width": width}, true)
	for entry in _width_buttons:
		(entry.button as ConfigToggleButton).selected = int(entry.width) == width


func set_font_for_test(font_type: int) -> void:
	emit_patch({"font_type": font_type}, true)
	for index in _font_buttons.size():
		_font_buttons[index].selected = FONT_TYPE_MAP[index] == font_type


func set_screen_toggle_for_test(key: String, enabled: bool) -> void:
	emit_patch({key: enabled}, true)
	if _toggle_buttons.has(key):
		_toggle_buttons[key].on.selected = enabled
		_toggle_buttons[key].off.selected = not enabled


func _on_font_pressed(index: int) -> void:
	emit_patch({"font_type": FONT_TYPE_MAP[index]}, true)


func _on_opacity_changed(value: float) -> void:
	emit_patch({"window_depth": int(value)})
	_preview_textbox.modulate.a = float(value) / 100.0


func _refresh_preview(settings: Dictionary) -> void:
	var depth := float(settings.get("window_depth", 50))
	_preview_textbox.modulate.a = depth / 100.0
	_preview_avatar.visible = bool(settings.get("portrait_visible", true))
	if bool(settings.get("read_color", true)):
		_preview_text.add_theme_color_override("font_color", Color(0.55, 0.72, 0.92, 1.0))
	else:
		_preview_text.add_theme_color_override("font_color", Color.WHITE)


func _set_desktop_window_controls_visible(visible_value: bool) -> void:
	_fullscreen_button.visible = visible_value
	_window_button.visible = visible_value
	_fullscreen_button.focus_mode = Control.FOCUS_ALL if visible_value else Control.FOCUS_NONE
	_window_button.focus_mode = Control.FOCUS_ALL if visible_value else Control.FOCUS_NONE
	for entry in _width_buttons:
		var button := entry.button as ConfigToggleButton
		button.visible = visible_value
		button.focus_mode = Control.FOCUS_ALL if visible_value else Control.FOCUS_NONE


func _is_mobile_platform() -> bool:
	return OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios")

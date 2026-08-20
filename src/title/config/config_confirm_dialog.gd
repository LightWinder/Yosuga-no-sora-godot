class_name ConfigConfirmDialog
extends Control


## Source ui_1920/confirm window: full-screen dim background, centered message,
## yes/no image buttons and an "always ask" toggle.  The owner reads
## always_checked and decides whether the confirmation setting persists.
signal confirmed
signal canceled
signal always_toggled(checked: bool)

const CONFIRM_ROOT := "res://assets/content/confirm/"
const DESIGN_SIZE := Vector2(1920.0, 1080.0)
const YES_POSITION := Vector2(651.0, 581.0) - Vector2(4.0, 0.0)
const NO_POSITION := Vector2(1206.0, 578.0) - Vector2(4.0, 0.0)
const ALWAYS_POSITION := Vector2(1723.0, 657.0)
const MESSAGE_RECT := Rect2(200.0, 330.0, 1520.0, 180.0)

var always_checked := true

var _message: Label
var _always_button: ConfigCheckButton


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build_visual()
	visible = false


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if StartupInput.is_cancel_event(event):
		canceled.emit()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		var key := event as InputEventKey
		if key.keycode == KEY_Y or key.keycode == KEY_ENTER or key.keycode == KEY_KP_ENTER:
			confirmed.emit()
			get_viewport().set_input_as_handled()
		elif key.keycode == KEY_N:
			canceled.emit()
			get_viewport().set_input_as_handled()


func open(message: String, always_enabled: bool) -> void:
	_message.text = message
	always_checked = always_enabled
	_always_button.checked = always_enabled
	visible = true
	_always_button.grab_focus()


func close() -> void:
	visible = false


func is_open() -> bool:
	return visible


func _build_visual() -> void:
	var background := TextureRect.new()
	background.name = "ConfirmBackground"
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	background.texture = load(CONFIRM_ROOT + "bg.png") as Texture2D
	add_child(background)

	_message = Label.new()
	_message.position = MESSAGE_RECT.position
	_message.size = MESSAGE_RECT.size
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message.add_theme_font_size_override("font_size", 60)
	_message.add_theme_color_override("font_color", Color.WHITE)
	_message.add_theme_color_override("font_outline_color", Color(0.05, 0.08, 0.12, 0.9))
	_message.add_theme_constant_override("outline_size", 6)
	add_child(_message)

	var yes := _make_button("yes.png", YES_POSITION, 77)
	yes.pressed.connect(func() -> void: confirmed.emit())
	add_child(yes)

	var no := _make_button("no.png", NO_POSITION, 83)
	no.pressed.connect(func() -> void: canceled.emit())
	add_child(no)

	_always_button = ConfigCheckButton.new()
	var always_texture := load(CONFIRM_ROOT + "ask_always.png") as Texture2D
	var frame := Rect2(0, 0, float(always_texture.get_width()) / 4.0, always_texture.get_height())
	_always_button.configure_frames(
		_region(always_texture, Rect2(frame.size.x * 2, 0, frame.size.x, frame.size.y)),
		_region(always_texture, Rect2(frame.size.x * 3, 0, frame.size.x, frame.size.y)),
		_region(always_texture, Rect2(0, 0, frame.size.x, frame.size.y)),
		_region(always_texture, Rect2(frame.size.x, 0, frame.size.x, frame.size.y))
	)
	_always_button.position = ALWAYS_POSITION
	_always_button.toggled.connect(func(value: bool) -> void:
		always_checked = value
		always_toggled.emit(value)
	)
	add_child(_always_button)


func _make_button(texture_path: String, position_value: Vector2, frame_split: int) -> ConfigStripButton:
	var button := ConfigStripButton.new()
	button.configure_strip(CONFIRM_ROOT + texture_path, 2, frame_split)
	button.position = position_value
	return button


func _region(atlas: Texture2D, region: Rect2) -> Texture2D:
	var result := AtlasTexture.new()
	result.atlas = atlas
	result.region = region
	result.filter_clip = true
	return result

class_name ConfigConfirmDialog
extends Control


## Source ui_1920/confirm window: full-screen dim background, centered message,
## yes/no image buttons and an "always ask" toggle.  The owner reads
## always_checked and decides whether the confirmation setting persists.
signal confirmed
signal canceled
signal always_toggled(checked: bool)

const CONFIRM_ROOT := "res://assets/content/confirm/"

var always_checked := true

@onready var _message: Label = $Message
@onready var _confirm_button: ConfigStripButton = $Confirm
@onready var _cancel_button: ConfigStripButton = $Cancel
@onready var _always_button: ConfigCheckButton = $AlwaysAsk


func _ready() -> void:
	_configure_controls()
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


func _configure_controls() -> void:
	_message.add_theme_font_size_override("font_size", 60)
	_message.add_theme_color_override("font_color", Color.WHITE)
	_message.add_theme_color_override("font_outline_color", Color(0.05, 0.08, 0.12, 0.9))
	_message.add_theme_constant_override("outline_size", 6)
	_confirm_button.configure_strip(CONFIRM_ROOT + "yes.png", 2, 77)
	_confirm_button.pressed.connect(func() -> void: confirmed.emit())
	_cancel_button.configure_strip(CONFIRM_ROOT + "no.png", 2, 83)
	_cancel_button.pressed.connect(func() -> void: canceled.emit())
	var always_texture := load(CONFIRM_ROOT + "ask_always.png") as Texture2D
	var frame := Rect2(0, 0, float(always_texture.get_width()) / 4.0, always_texture.get_height())
	_always_button.configure_frames(
		_region(always_texture, Rect2(frame.size.x * 2, 0, frame.size.x, frame.size.y)),
		_region(always_texture, Rect2(frame.size.x * 3, 0, frame.size.x, frame.size.y)),
		_region(always_texture, Rect2(0, 0, frame.size.x, frame.size.y)),
		_region(always_texture, Rect2(frame.size.x, 0, frame.size.x, frame.size.y))
	)
	_always_button.toggled.connect(func(value: bool) -> void:
		always_checked = value
		always_toggled.emit(value)
	)


func _region(atlas: Texture2D, region: Rect2) -> Texture2D:
	var result := AtlasTexture.new()
	result.atlas = atlas
	result.region = region
	result.filter_clip = true
	return result

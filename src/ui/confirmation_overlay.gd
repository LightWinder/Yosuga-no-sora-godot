class_name ConfirmationOverlay
extends ModalOverlay


## Source ui_1920/confirm window: full-screen dim background, centered message,
## text action buttons and an optional "always ask" toggle. The owner reads
## always_checked and decides whether the confirmation setting persists.
signal confirmed
signal canceled
signal always_toggled(checked: bool)

const CONFIRM_ROOT := "res://assets/content/confirm/"
const CANVAS_HEIGHT := 1080.0
const MIN_BAND_HEIGHT := 313.0
const MAX_BAND_HEIGHT := 620.0
const CONTENT_VERTICAL_PADDING := 104.0
const MESSAGE_WIDTH := 1000.0

var always_checked := true
var _return_focus: Control

@onready var _message: Label = $Layout/VisualCanvas/DialogContent/Center/Main/Message
@onready var _confirm_button: TextActionButton = $Layout/VisualCanvas/DialogContent/Center/Main/Buttons/Confirm
@onready var _cancel_button: TextActionButton = $Layout/VisualCanvas/DialogContent/Center/Main/Buttons/Cancel
@onready var _always_button: ImageCheckButton = $Layout/VisualCanvas/DialogContent/AlwaysAsk
@onready var _backdrop: TextureRect = $Layout/VisualCanvas/BackdropArtwork
@onready var _center: CenterContainer = $Layout/VisualCanvas/DialogContent/Center
@onready var _main: VBoxContainer = $Layout/VisualCanvas/DialogContent/Center/Main


func _ready() -> void:
	super._ready()
	_configure_controls()


func _input(event: InputEvent) -> void:
	if not is_active():
		return
	if StartupInput.is_cancel_event(event):
		if is_open():
			canceled.emit()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_Y or event.keycode == KEY_N:
			if is_open():
				if event.keycode == KEY_Y:
					confirmed.emit()
				else:
					canceled.emit()
			get_viewport().set_input_as_handled()


func open(
		message: String = "要结束游戏吗？",
		confirm_text: String = "结束游戏",
		cancel_text: String = "取消",
		show_always: bool = false,
		always_enabled: bool = true
) -> void:
	if not is_open():
		_return_focus = get_viewport().gui_get_focus_owner()
	_message.text = message
	_update_layout(tr(message))
	_confirm_button.text = confirm_text
	_cancel_button.text = cancel_text
	always_checked = always_enabled
	_always_button.checked = always_enabled
	_always_button.visible = show_always
	var controls: Array[Control] = [_confirm_button, _cancel_button]
	if show_always:
		controls.append(_always_button)
	for index in controls.size():
		var control := controls[index]
		var next := control.get_path_to(controls[(index + 1) % controls.size()])
		var previous := control.get_path_to(controls[(index + controls.size() - 1) % controls.size()])
		control.focus_next = next
		control.focus_previous = previous
		control.focus_neighbor_left = previous
		control.focus_neighbor_right = next
		control.focus_neighbor_top = previous
		control.focus_neighbor_bottom = next
	show_modal()
	_cancel_button.grab_focus()


func _update_layout(message: String) -> void:
	var font := _message.get_theme_font("font")
	var font_size := _message.get_theme_font_size("font_size")
	var measured := font.get_multiline_string_size(
		message,
		HORIZONTAL_ALIGNMENT_CENTER,
		MESSAGE_WIDTH,
		font_size
	)
	var message_height := maxf(60.0, ceilf(measured.y) + 12.0)
	_message.custom_minimum_size = Vector2(MESSAGE_WIDTH, message_height)
	var content_height := message_height + float(_main.get_theme_constant("separation")) + 60.0
	var band_height := clampf(content_height + CONTENT_VERTICAL_PADDING, MIN_BAND_HEIGHT, MAX_BAND_HEIGHT)
	var band_top := roundf((CANVAS_HEIGHT - band_height) * 0.5)
	var band_bottom := band_top + band_height
	_blur_layer.position.y = band_top
	_blur_layer.size.y = band_height
	_backdrop.position.y = band_top
	_backdrop.size.y = band_height
	_center.position.y = band_top + CONTENT_VERTICAL_PADDING * 0.5
	_center.size.y = band_height - CONTENT_VERTICAL_PADDING
	_always_button.position.y = band_bottom - 33.0


func close() -> void:
	hide_modal()
	var focus_owner := get_viewport().gui_get_focus_owner()
	if focus_owner != null and is_ancestor_of(focus_owner):
		focus_owner.release_focus()
	var return_focus := _return_focus
	_return_focus = null
	if is_instance_valid(return_focus) and return_focus.is_visible_in_tree() and return_focus.focus_mode != Control.FOCUS_NONE:
		if not (return_focus is BaseButton and return_focus.disabled):
			return_focus.call_deferred("grab_focus")


func is_open() -> bool:
	return is_modal_open()


func is_active() -> bool:
	return is_modal_active()


func _configure_controls() -> void:
	_confirm_button.pressed.connect(func() -> void:
		if is_open(): confirmed.emit())
	_cancel_button.pressed.connect(func() -> void:
		if is_open(): canceled.emit())
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

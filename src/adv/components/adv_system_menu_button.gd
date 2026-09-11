@tool
class_name AdvSystemMenuButton
extends TextureButton


const NORMAL_BACKGROUND := Color8(128, 176, 192, 173)
const ACTIVE_BACKGROUND := Color8(22, 87, 104, 173)
const CORNER_RADIUS := 9


class BackgroundLayer extends Control:
	var source_button: TextureButton
	var normal_style := StyleBoxFlat.new()
	var active_style := StyleBoxFlat.new()


	func configure(button: TextureButton) -> void:
		source_button = button
		_configure_style(normal_style, NORMAL_BACKGROUND)
		_configure_style(active_style, ACTIVE_BACKGROUND)


	func _draw() -> void:
		if not is_instance_valid(source_button):
			return
		var active := (
			not source_button.disabled
			and (source_button.button_pressed or source_button.is_hovered())
		)
		draw_style_box(active_style if active else normal_style, Rect2(Vector2.ZERO, size))


	func _configure_style(style: StyleBoxFlat, color: Color) -> void:
		style.bg_color = color
		style.corner_radius_top_left = CORNER_RADIUS
		style.corner_radius_top_right = CORNER_RADIUS
		style.corner_radius_bottom_right = CORNER_RADIUS
		style.corner_radius_bottom_left = CORNER_RADIUS
		style.anti_aliasing = true


var _background_layer: BackgroundLayer


func is_visually_active() -> bool:
	return not disabled and (button_pressed or is_hovered())


func _ready() -> void:
	_background_layer = BackgroundLayer.new()
	_background_layer.name = "StateBackground"
	_background_layer.show_behind_parent = true
	_background_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background_layer)
	_background_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background_layer.configure(self)

	mouse_entered.connect(_queue_background_redraw)
	mouse_exited.connect(_queue_background_redraw)
	focus_entered.connect(_queue_background_redraw)
	focus_exited.connect(_queue_background_redraw)
	button_down.connect(_queue_background_redraw)
	button_up.connect(_queue_background_redraw)
	toggled.connect(func(_pressed: bool) -> void: _queue_background_redraw())


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAW and is_instance_valid(_background_layer):
		_background_layer.queue_redraw()


func _queue_background_redraw() -> void:
	if is_instance_valid(_background_layer):
		_background_layer.queue_redraw()

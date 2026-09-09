class_name ModalOverlay
extends Control


## Shared modal presentation. Concrete dialogs
## keep their own buttons and signals; this base owns only screen blur, shade
## and the opening/closing motion.
signal closed

@export_range(0.05, 0.5, 0.01) var open_duration := 0.22
@export_range(0.05, 0.5, 0.01) var close_duration := 0.16
@export_range(0.8, 1.0, 0.01) var initial_scale := 0.94
@export_range(0.8, 1.0, 0.01) var closing_scale := 0.97
@export_range(0.0, 5.0, 0.1) var target_blur_lod := 2.4
@export var blur_layer_path: NodePath = ^"BlurLayer"
@export var backdrop_path: NodePath = ^"BackdropArtwork"
@export var motion_target_path: NodePath = ^"DialogContent"

var _motion_tween: Tween
var _blur_material: ShaderMaterial
var _backdrop_artwork: CanvasItem
var _backdrop_artwork_alpha := 1.0
var _current_blur_lod := 0.0
var _is_open := false

@onready var _blur_layer: ColorRect = get_node(blur_layer_path) as ColorRect
@onready var _shade: ColorRect = $Shade
@onready var _dialog_content: Control = get_node(motion_target_path) as Control


func _ready() -> void:
	# Each modal animates its own uniform value. Duplicate defensively even
	# though the external material is marked local-to-scene.
	_blur_material = _blur_layer.material.duplicate() as ShaderMaterial
	_blur_layer.material = _blur_material
	# The screen texture is populated during rendering. Keep the blur layer
	# transparent until its first valid back-buffer copy has been drawn so an
	# uninitialized texture can never flash black when the modal appears.
	_blur_layer.modulate.a = 0.0
	_backdrop_artwork = get_node_or_null(backdrop_path) as CanvasItem
	if _backdrop_artwork != null:
		_backdrop_artwork_alpha = _backdrop_artwork.modulate.a
	visible = false


func show_modal() -> void:
	_stop_motion()
	_is_open = true
	visible = true

	_dialog_content.pivot_offset = _dialog_content.size * 0.5
	_dialog_content.scale = Vector2.ONE * initial_scale
	_dialog_content.modulate.a = 0.0
	_blur_layer.modulate.a = 0.0
	_shade.modulate.a = 0.0
	_set_blur_lod(0.0)
	if _backdrop_artwork != null:
		_backdrop_artwork.modulate.a = 0.0

	_motion_tween = create_tween().set_parallel(true)
	_motion_tween.tween_property(
		_blur_layer,
		"modulate:a",
		1.0,
		open_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_motion_tween.tween_property(
		_shade,
		"modulate:a",
		1.0,
		open_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_motion_tween.tween_property(
		_dialog_content,
		"modulate:a",
		1.0,
		open_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_motion_tween.tween_property(
		_dialog_content,
		"scale",
		Vector2.ONE,
		open_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_motion_tween.tween_method(
		Callable(self, "_set_blur_lod"),
		0.0,
		target_blur_lod,
		open_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if _backdrop_artwork != null:
		_motion_tween.tween_property(
			_backdrop_artwork,
			"modulate:a",
			_backdrop_artwork_alpha,
			open_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func hide_modal() -> void:
	if not _is_open:
		return
	_is_open = false
	_stop_motion()

	_motion_tween = create_tween().set_parallel(true)
	_motion_tween.tween_property(
		_blur_layer,
		"modulate:a",
		0.0,
		close_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_motion_tween.tween_property(
		_shade,
		"modulate:a",
		0.0,
		close_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_motion_tween.tween_property(
		_dialog_content,
		"modulate:a",
		0.0,
		close_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_motion_tween.tween_property(
		_dialog_content,
		"scale",
		Vector2.ONE * closing_scale,
		close_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_motion_tween.tween_method(
		Callable(self, "_set_blur_lod"),
		_current_blur_lod,
		0.0,
		close_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	if _backdrop_artwork != null:
		_motion_tween.tween_property(
			_backdrop_artwork,
			"modulate:a",
			0.0,
			close_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_motion_tween.finished.connect(_finish_close)


func is_modal_open() -> bool:
	return _is_open


func is_modal_active() -> bool:
	return visible


func _stop_motion() -> void:
	if _motion_tween != null and _motion_tween.is_valid():
		_motion_tween.kill()
	_motion_tween = null


func _finish_close() -> void:
	if _is_open:
		return
	visible = false
	_blur_layer.modulate.a = 0.0
	_dialog_content.scale = Vector2.ONE
	_motion_tween = null
	closed.emit()


func _set_blur_lod(value: float) -> void:
	_current_blur_lod = value
	_blur_material.set_shader_parameter(&"blur_lod", value)

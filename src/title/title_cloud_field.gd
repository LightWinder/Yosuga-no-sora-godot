@tool
class_name TitleCloudField
extends Control


var _scroll_phase := 0.0
var _distortion_phase := 0.0
@onready var _projection: ColorRect = $PerspectiveCloudProjection


func _ready() -> void:
	set_process(not Engine.is_editor_hint())
	set_animation_phase(0.0)
	set_distortion_phase(0.0)


func _process(delta: float) -> void:
	advance_animation(delta)


func advance_animation(delta: float) -> void:
	if not is_visible_in_tree():
		return
	var cloud_material := _projection.material as ShaderMaterial
	var speed := float(cloud_material.get_shader_parameter(&"speed"))
	var distortion_speed := float(cloud_material.get_shader_parameter(&"distortion_speed"))
	var uv_scale: Vector2 = cloud_material.get_shader_parameter(&"uv_scale")
	set_animation_phase(_scroll_phase + delta * speed * uv_scale.y)
	set_distortion_phase(_distortion_phase + delta * distortion_speed)


## One normalized texture period. Wrapping is sampling-equivalent, never a
## scene restart or a cloud respawn. GDScript retains double precision.
func set_animation_phase(value: float) -> void:
	_scroll_phase = fposmod(value, 1.0)
	var cloud_material := _projection.material as ShaderMaterial
	cloud_material.set_shader_parameter(&"scroll_phase", _scroll_phase)


## Independent periodic clock for the subtle shape drift. Keeping this outside
## the shader avoids the engine's global time rollover and preserves pausing.
func set_distortion_phase(value: float) -> void:
	_distortion_phase = fposmod(value, 1.0)
	var cloud_material := _projection.material as ShaderMaterial
	cloud_material.set_shader_parameter(&"distortion_phase", _distortion_phase)


func cloud_material() -> ShaderMaterial:
	return _projection.material as ShaderMaterial

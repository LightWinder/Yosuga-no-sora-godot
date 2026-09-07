@tool
class_name TitleCloudField
extends Control


var _scroll_phase := 0.0
@onready var _projection: ColorRect = $PerspectiveCloudProjection


func _ready() -> void:
	set_process(not Engine.is_editor_hint())
	set_animation_phase(0.0)


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	var cloud_material := _projection.material as ShaderMaterial
	var speed := float(cloud_material.get_shader_parameter(&"speed"))
	var uv_scale: Vector2 = cloud_material.get_shader_parameter(&"uv_scale")
	set_animation_phase(_scroll_phase + delta * speed * uv_scale.y)


## One normalized texture period. Wrapping is sampling-equivalent, never a
## scene restart or a cloud respawn. GDScript retains double precision.
func set_animation_phase(value: float) -> void:
	_scroll_phase = fposmod(value, 1.0)
	var cloud_material := _projection.material as ShaderMaterial
	cloud_material.set_shader_parameter(&"scroll_phase", _scroll_phase)


func cloud_material() -> ShaderMaterial:
	return _projection.material as ShaderMaterial

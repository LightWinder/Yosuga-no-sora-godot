@tool
class_name TitleTreeSwayBackground
extends TextureRect


var _sway_phase := 0.0


func _ready() -> void:
	set_process(not Engine.is_editor_hint())
	set_sway_phase(0.0)


func _process(delta: float) -> void:
	advance_animation(delta)


func advance_animation(delta: float) -> void:
	if not is_visible_in_tree():
		return
	var tree_material := sway_material()
	var speed := float(tree_material.get_shader_parameter(&"sway_speed"))
	set_sway_phase(_sway_phase + delta * speed)


func set_sway_phase(value: float) -> void:
	_sway_phase = fposmod(value, 1.0)
	var tree_material := sway_material()
	tree_material.set_shader_parameter(&"sway_phase", _sway_phase)


func sway_material() -> ShaderMaterial:
	return material as ShaderMaterial

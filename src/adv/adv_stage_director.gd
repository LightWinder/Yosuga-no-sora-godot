class_name AdvStageDirector
extends Node


signal missing_asset(kind: String, resource_id: String)
signal cg_presented(resource_id: String)
signal character_presented(resource_id: String)
signal transition_started(duration_seconds: float)
signal transition_finished
signal action_finished(target_id: String)
signal camera_finished


const DESIGN_SIZE := Vector2(1920.0, 1080.0)
const CHARACTER_LAYOUT_PATH := "res://assets/content/adv/character_layout.csv"
const SOURCE_POSITION_SCALE := 1.8
const SOURCE_LOGICAL_WIDTH := 800.0
const NORMAL_CAMERA_COORDINATE_SCALE := 2.0
const OVERSIZE_HD_SCALE := 1.8
const OVERSIZE_CAMERA_COORDINATE_SCALE := NORMAL_CAMERA_COORDINATE_SCALE * OVERSIZE_HD_SCALE
const CAMERA_DEPTH_RANGE := 128.0
const CAMERA_PROJECTION_DEPTH := 256.0
const DEFAULT_UPDATE_MILLISECONDS := 500
const DEFAULT_ACTION_MILLISECONDS := 500
const CHARACTER_CROSSFADE_SHADER: Shader = preload(
	"res://assets/shaders/adv/character_crossfade.gdshader"
)
const STAGE_TAGS: Array[StringName] = [
	&"cg", &"char", &"clearchar", &"tone", &"move", &"leave",
	&"autoposition", &"update", &"action", &"stopaction", &"movecamera",
	&"bgscroll",
]
const SUPPORTED_ACTION_NAMES: Array[StringName] = [
	&"actionadvhop", &"actionadvjump", &"actionadvwave", &"actionwave",
]
const CHARACTER_NAMES := {
	"ca": "穹",
	"cb": "奈绪",
	"cc": "瑛",
	"cd": "一叶",
	"ce": "初佳",
	"cf": "亮平",
	"cg": "依媛",
	"ch": "梢",
	"cj": "隆之",
	"ck": "繁治",
}
const CHARACTER_ALIASES := {
	"穹": "穹", "そら": "穹",
	"奈緒": "奈绪", "奈绪": "奈绪",
	"瑛": "瑛",
	"一葉": "一叶", "一叶": "一叶",
	"初佳": "初佳",
	"亮平": "亮平",
	"やひろ": "依媛", "八寻": "依媛", "八尋": "依媛", "依媛": "依媛",
	"梢": "梢",
	"隆之": "隆之",
	"繁治": "繁治",
}
const CHARACTER_RELATES := {
	"瑛": 10, "繁治": 20, "一叶": 30, "梢": 40, "亮平": 50,
	"奈绪": 60, "初佳": 70, "穹": 80, "依媛": 90, "隆之": 100,
}
const CHARACTER_BASE_ORDERS := {
	"ca": 100, "cc": 90, "ch": 80, "ce": 70, "cb": 60,
	"cd": 50, "cg": 40, "cf": 30, "ck": 20, "cj": 10,
}
const DEFAULT_PORTRAIT_ASSETS := {
	"穹": "CA02_01T",
	"奈绪": "CB01_01T",
	"瑛": "CC01_01T",
	"一叶": "CD01_01T",
	"初佳": "CE01_01T",
	"亮平": "CF01_01T",
	"依媛": "CG01_01T",
	"梢": "CH01_01T",
}

@export_node_path("Control") var camera_canvas_path: NodePath
@export_node_path("ColorRect") var fallback_path: NodePath
@export_node_path("TextureRect") var background_path: NodePath
@export_node_path("Control") var background_scroll_layer_path: NodePath
@export_node_path("Control") var background_scroll_tiles_path: NodePath
@export_node_path("Control") var character_layer_path: NodePath
@export_node_path("Control") var transition_snapshot_path: NodePath
@export_node_path("CanvasGroup") var snapshot_group_path: NodePath
@export_node_path("Control") var snapshot_camera_path: NodePath
@export_node_path("ColorRect") var snapshot_fallback_path: NodePath
@export_node_path("TextureRect") var snapshot_background_path: NodePath
@export_node_path("Control") var snapshot_background_scroll_path: NodePath
@export_node_path("Control") var snapshot_background_scroll_tiles_path: NodePath
@export_node_path("Control") var snapshot_characters_path: NodePath

@onready var _camera_canvas := get_node(camera_canvas_path) as Control
@onready var _fallback := get_node(fallback_path) as ColorRect
@onready var _background := get_node(background_path) as TextureRect
@onready var _background_scroll_layer := get_node(background_scroll_layer_path) as Control
@onready var _background_scroll_tiles := get_node(background_scroll_tiles_path) as Control
@onready var _character_layer := get_node(character_layer_path) as Control
@onready var _transition_snapshot := get_node(transition_snapshot_path) as Control
@onready var _snapshot_group := get_node(snapshot_group_path) as CanvasGroup
@onready var _snapshot_camera := get_node(snapshot_camera_path) as Control
@onready var _snapshot_fallback := get_node(snapshot_fallback_path) as ColorRect
@onready var _snapshot_background := get_node(snapshot_background_path) as TextureRect
@onready var _snapshot_background_scroll := get_node(snapshot_background_scroll_path) as Control
@onready var _snapshot_background_scroll_tiles := get_node(snapshot_background_scroll_tiles_path) as Control
@onready var _snapshot_characters := get_node(snapshot_characters_path) as Control

var _asset_resolver := AdvAssetResolver.new()
var _tone_catalog := AdvToneCatalog.load_default()
var _character_layouts: Dictionary = {}
var _pending_orders: Array[KrkrScenarioInstruction] = []
var _character_nodes: Dictionary = {}
var _character_assets: Dictionary = {}
var _character_tones: Dictionary = {}
var _character_world_positions: Dictionary = {}
var _character_action_offsets: Dictionary = {}
var _character_removal_tweens: Dictionary = {}
var _character_transition_tweens: Dictionary = {}
var _characters_pending_removal: Dictionary = {}
var _background_asset := ""
var _background_spec: Dictionary = {}
var _environment_tone := "normal"
var _background_tone := "normal"
var _fallback_base_color := Color.BLACK
var _background_coordinate_scale := NORMAL_CAMERA_COORDINATE_SCALE
var _auto_positioning := true
var _transition_tween: Tween
var _transition_active := false
var _action_tweens: Dictionary = {}
var _action_origins: Dictionary = {}
var _active_action_specs: Dictionary = {}
var _camera_tween: Tween
var _camera_world_position := Vector3(0.0, 0.0, -CAMERA_DEPTH_RANGE)
var _camera_move_start_world_position := Vector3(0.0, 0.0, -CAMERA_DEPTH_RANGE)
var _camera_target_world_position := Vector3(0.0, 0.0, -CAMERA_DEPTH_RANGE)
var _camera_move_duration_milliseconds := 0
var _camera_action_offset := Vector2.ZERO
var _background_scroll_tween: Tween
var _background_scroll_spec: Dictionary = {}
var _background_scroll_started_msec := 0
var _screen_effects_enabled := true
var _transition_material: ShaderMaterial
var _applying_instant := false


func _ready() -> void:
	_asset_resolver.rebuild()
	_load_character_layouts()
	_transition_snapshot.visible = false
	_camera_canvas.pivot_offset = DESIGN_SIZE * 0.5
	_snapshot_camera.pivot_offset = DESIGN_SIZE * 0.5
	_transition_material = _snapshot_group.material as ShaderMaterial
	_apply_camera_projection()


func asset_resolver() -> AdvAssetResolver:
	return _asset_resolver


func portrait_texture_for_speaker(speaker: String) -> Texture2D:
	var normalized_speaker := speaker.strip_edges().replace("＆", "&")
	if normalized_speaker.is_empty():
		return null
	var first_speaker := normalized_speaker.split("&", false, 1)[0]
	var character_id := _normalize_character_id(first_speaker)
	var resource_id := ""
	var character_details: Variant = _character_assets.get(character_id)
	if character_details is Dictionary:
		resource_id = str(character_details.get("file", ""))
	if resource_id.is_empty():
		resource_id = str(DEFAULT_PORTRAIT_ASSETS.get(character_id, ""))
	if resource_id.is_empty():
		return null
	var basename := resource_id.get_file().get_basename()
	if basename.right(1).to_upper() in ["L", "M", "S", "T", "F"]:
		basename = basename.left(-1)
	for suffix in ["T", "L", "S", "M"]:
		var texture := _asset_resolver.texture_for_character("%s%s" % [basename, suffix])
		if texture != null:
			return texture
	return null


func handles(tag_name: StringName) -> bool:
	return tag_name in STAGE_TAGS


static func handles_action(action_name: String) -> bool:
	return StringName(action_name.to_lower()) in SUPPORTED_ACTION_NAMES


func set_screen_effects_enabled(enabled: bool) -> void:
	_screen_effects_enabled = enabled
	if not enabled:
		finish_transition()
		_finish_all_character_transitions()


func execute(instruction: KrkrScenarioInstruction) -> bool:
	match instruction.tag_name:
		&"cg":
			_pending_orders.append(instruction)
			cg_presented.emit(instruction.string_argument("file"))
		&"char":
			_pending_orders.append(instruction)
			character_presented.emit(instruction.string_argument("file"))
		&"clearchar", &"tone", &"move", &"leave":
			_pending_orders.append(instruction)
		&"autoposition":
			_auto_positioning = true
		&"update":
			commit_pending(instruction)
		&"action":
			_start_action(instruction)
		&"stopaction":
			stop_action(instruction.string_argument("id"))
		&"movecamera":
			_start_camera_move(instruction)
		&"bgscroll":
			_start_background_scroll(instruction)
		_:
			return false
	return true


func has_pending_orders() -> bool:
	return not _pending_orders.is_empty()


func commit_pending(update_instruction: KrkrScenarioInstruction = null, instant: bool = false) -> void:
	if _pending_orders.is_empty():
		return
	if _transition_active:
		finish_transition()
	var milliseconds := DEFAULT_UPDATE_MILLISECONDS
	if update_instruction != null:
		milliseconds = maxi(update_instruction.int_argument("time", DEFAULT_UPDATE_MILLISECONDS), 0)
	if instant or not _screen_effects_enabled:
		milliseconds = 0
	var requires_full_stage_transition := _pending_requires_full_stage_transition()
	if requires_full_stage_transition:
		_finish_all_character_transitions()
	if requires_full_stage_transition and milliseconds > 0:
		_capture_transition_snapshot()
	# Source bust-up updates own their local transition. A full-stage update
	# applies the new bust-up state immediately underneath the composed snapshot.
	_applying_instant = milliseconds <= 0 or requires_full_stage_transition
	for instruction in _pending_orders:
		_apply_order(instruction)
	_applying_instant = false
	_pending_orders.clear()
	if _auto_positioning:
		_apply_auto_positions()
	if requires_full_stage_transition and milliseconds > 0:
		_start_transition(milliseconds, update_instruction)
	else:
		_hide_transition_snapshot()


func _pending_requires_full_stage_transition() -> bool:
	for instruction in _pending_orders:
		# The source marks CG and tone changes as UPDATE_CG. Plain bust-up,
		# clear, move, and leave orders stay local to their character layers.
		if instruction.tag_name in [&"cg", &"tone"]:
			return true
	return false


## Reduces a navigation scan without resolving any intermediate texture. Only
## the final presentation is materialized, matching the source engine's jump
## buffers instead of replaying normal scene updates at zero duration.
func apply_navigation_instructions(instructions: Array[KrkrScenarioInstruction]) -> void:
	var has_stage_change := false
	for instruction in instructions:
		if instruction.tag_name != &"update":
			has_stage_change = true
			break
	if not has_stage_change:
		return
	var presentation := presentation_state().duplicate(true)
	presentation["_navigation_camera_arguments"] = {}
	for instruction in instructions:
		_reduce_navigation_instruction(presentation, instruction)
	_reduce_navigation_auto_positions(presentation)
	var camera_arguments := (
		presentation.get("_navigation_camera_arguments", {}) as Dictionary
	).duplicate(true)
	presentation.erase("_navigation_camera_arguments")
	clear()
	# Choice navigation materializes the final buffered frame immediately. It
	# must not restart a long-running camera move captured at the source frame.
	restore_presentation(presentation, false)
	if not camera_arguments.is_empty():
		camera_arguments["time"] = 0
		_start_camera_move(_instruction(&"movecamera", camera_arguments))
	var final_background := str(presentation.get("background", ""))
	if not final_background.is_empty():
		cg_presented.emit(final_background)
	var final_characters := presentation.get("characters", {}) as Dictionary
	for character_value in final_characters.values():
		if character_value is Dictionary:
			var final_character := str(character_value.get("file", ""))
			if not final_character.is_empty():
				character_presented.emit(final_character)


func is_transitioning() -> bool:
	return _transition_active


func finish_transition() -> void:
	if not _transition_active:
		return
	if _transition_tween != null and _transition_tween.is_valid():
		_transition_tween.kill()
	_transition_tween = null
	_transition_active = false
	_reset_transition_material()
	_hide_transition_snapshot()
	transition_finished.emit()


func is_action_running(target_id: String) -> bool:
	return _action_tweens.has(_normalize_character_id(target_id))


func is_action_looping(target_id: String) -> bool:
	var normalized := _normalize_character_id(target_id)
	var action_spec: Variant = _active_action_specs.get(normalized)
	return action_spec is Dictionary and int(action_spec.get("count", 1)) < 0


func stop_action(target_id: String) -> void:
	var normalized := _normalize_character_id(target_id)
	if not _action_tweens.has(normalized):
		return
	var tween := _action_tweens.get(normalized) as Tween
	if tween != null and tween.is_valid():
		tween.kill()
	_restore_action_origin(normalized)
	_clear_action_offset(normalized)
	_action_tweens.erase(normalized)
	_action_origins.erase(normalized)
	_active_action_specs.erase(normalized)
	action_finished.emit(normalized)


func is_camera_moving() -> bool:
	return _camera_tween != null and _camera_tween.is_valid()


func finish_camera_move() -> void:
	if not is_camera_moving():
		return
	_camera_tween.kill()
	_camera_tween = null
	_apply_camera_world_position(_camera_target_world_position)
	_camera_move_duration_milliseconds = 0
	camera_finished.emit()


func clear(immediate: bool = true) -> void:
	_pending_orders.clear()
	finish_transition()
	_stop_all_actions()
	if is_camera_moving():
		_camera_tween.kill()
	_camera_tween = null
	_clear_background_scroll()
	_clear_characters()
	_background.texture = null
	_background.modulate = Color.WHITE
	_background_asset = ""
	_background_spec.clear()
	_environment_tone = "normal"
	_background_tone = "normal"
	_background_coordinate_scale = NORMAL_CAMERA_COORDINATE_SCALE
	_configure_background_rect(DESIGN_SIZE * 0.5, DESIGN_SIZE)
	_fallback_base_color = Color.BLACK
	_refresh_background_tone()
	_reset_camera_transform()
	if not immediate:
		_start_transition(DEFAULT_UPDATE_MILLISECONDS)


func presentation_state() -> Dictionary:
	var characters: Dictionary = {}
	for character_id in _character_nodes:
		if _characters_pending_removal.has(character_id):
			continue
		var node := _character_nodes[character_id] as TextureRect
		var details := (_character_assets.get(character_id, {}) as Dictionary).duplicate(true)
		var world_position := _character_world_positions.get(character_id, Vector3.ZERO) as Vector3
		details["world_position"] = [world_position.x, world_position.y, world_position.z]
		details["position"] = [node.position.x, node.position.y]
		details["modulate"] = _color_to_array(node.modulate)
		details["tone"] = str(_character_tones.get(character_id, "normal"))
		details["z_index"] = node.z_index
		characters[str(character_id)] = details
	var background_scroll := _background_scroll_spec.duplicate(true)
	if not background_scroll.is_empty():
		var cycle_milliseconds := maxi(int(background_scroll.get("cycle", 10000)), 1)
		background_scroll["phase"] = fmod(
			float(Time.get_ticks_msec() - _background_scroll_started_msec) / float(cycle_milliseconds),
			1.0
		)
	var camera_move: Dictionary = {}
	if is_camera_moving():
		# Source Savedata records the original start, final target, and base
		# duration. Loading then replays the whole camera move from its start.
		camera_move = {
			"start_world_position": _vector3_to_array(_camera_move_start_world_position),
			"target_world_position": _vector3_to_array(_camera_target_world_position),
			"duration_milliseconds": _camera_move_duration_milliseconds,
		}
	return {
		"background": _background_asset,
		"background_spec": _background_spec.duplicate(true),
		"background_modulate": _color_to_array(_background.modulate),
		"environment_tone": _environment_tone,
		"background_tone": _background_tone,
		"characters": characters,
		"camera_world_position": [
			_camera_world_position.x, _camera_world_position.y, _camera_world_position.z,
		],
		"camera_position": [_camera_canvas.position.x, _camera_canvas.position.y],
		"camera_scale": _camera_canvas.scale.x,
		"camera_move": camera_move,
		"auto_positioning": _auto_positioning,
		"background_scroll": background_scroll,
		"actions": _active_action_specs.duplicate(true),
	}


func restore_presentation(presentation: Dictionary, resume_camera_move: bool = true) -> void:
	if presentation.is_empty():
		return
	_cancel_camera_move()
	var background_id := str(presentation.get("background", ""))
	if not background_id.is_empty():
		var background_arguments: Dictionary = {"file": background_id}
		var saved_background_spec: Variant = presentation.get("background_spec", {})
		if saved_background_spec is Dictionary:
			var source_center := str(saved_background_spec.get("source_center", ""))
			if not source_center.is_empty():
				background_arguments["center"] = source_center
		_apply_cg(_instruction(&"cg", background_arguments))
	_environment_tone = str(presentation.get("environment_tone", _environment_tone))
	_background_tone = str(presentation.get("background_tone", "normal"))
	if presentation.has("background_tone"):
		_refresh_background_tone()
	else:
		_background.modulate = _color_from_variant(
			presentation.get("background_modulate", []),
			Color.WHITE
		)
	var characters: Variant = presentation.get("characters", {})
	var previous_applying_instant := _applying_instant
	# Save/load and choice-navigation restoration materialize an already settled
	# frame. The source restore path forces effect speed to zero here.
	_applying_instant = true
	if characters is Dictionary:
		for character_id in characters:
			var value: Variant = characters[character_id]
			var arguments: Dictionary = {"id": str(character_id)}
			if value is Dictionary:
				arguments.merge(value, true)
			else:
				arguments["file"] = str(value)
			_apply_character(_instruction(&"char", arguments))
			var node := _character_nodes.get(_normalize_character_id(str(character_id))) as TextureRect
			if node != null and value is Dictionary:
				var normalized_id := _normalize_character_id(str(character_id))
				var saved_world_position: Variant = value.get("world_position", [])
				if saved_world_position is Array and saved_world_position.size() >= 3:
					_character_world_positions[normalized_id] = Vector3(
						float(saved_world_position[0]),
						float(saved_world_position[1]),
						float(saved_world_position[2])
					)
					_update_character_projection(normalized_id)
				else:
					var saved_position: Variant = value.get("position", [])
					if saved_position is Array and saved_position.size() >= 2:
						node.position = Vector2(float(saved_position[0]), float(saved_position[1]))
				if value.has("tone"):
					var saved_alpha := _color_from_variant(
						value.get("modulate", []), Color.WHITE
					).a
					node.modulate.a = saved_alpha
					_refresh_character_tone(normalized_id)
				else:
					node.modulate = _color_from_variant(value.get("modulate", []), Color.WHITE)
				node.z_index = int(value.get("z_index", node.z_index))
	_applying_instant = previous_applying_instant
	var restored_camera_world := _camera_world_position
	var saved_camera_world: Variant = presentation.get("camera_world_position", [])
	if saved_camera_world is Array and saved_camera_world.size() >= 3:
		restored_camera_world = Vector3(
			float(saved_camera_world[0]),
			float(saved_camera_world[1]),
			float(saved_camera_world[2])
		)
	else:
		var camera_position: Variant = presentation.get("camera_position", [])
		var legacy_position := Vector2.ZERO
		if camera_position is Array and camera_position.size() >= 2:
			legacy_position = Vector2(float(camera_position[0]), float(camera_position[1]))
		var camera_scale := maxf(float(presentation.get("camera_scale", 1.0)), 0.01)
		restored_camera_world = _camera_world_from_visual(legacy_position, camera_scale)
	var saved_camera_move: Variant = presentation.get("camera_move", {})
	if resume_camera_move and saved_camera_move is Dictionary \
			and not saved_camera_move.is_empty():
		var move_start := _vector3_from_variant(
			saved_camera_move.get("start_world_position", []), restored_camera_world
		)
		var move_target := _vector3_from_variant(
			saved_camera_move.get("target_world_position", []), restored_camera_world
		)
		var move_duration := maxi(
			int(saved_camera_move.get("duration_milliseconds", 0)), 0
		)
		_apply_camera_world_position(move_start)
		_start_camera_world_move(move_target, move_duration, 2)
	else:
		_apply_camera_world_position(restored_camera_world)
	_auto_positioning = bool(presentation.get("auto_positioning", true))
	var background_scroll: Variant = presentation.get("background_scroll", {})
	if background_scroll is Dictionary and not background_scroll.is_empty():
		_start_background_scroll(_instruction(&"bgscroll", background_scroll))
	var actions: Variant = presentation.get("actions", {})
	if actions is Dictionary:
		for target_id in actions:
			var spec: Variant = actions[target_id]
			if not spec is Dictionary:
				continue
			var arguments := (spec as Dictionary).duplicate(true)
			arguments["id"] = str(target_id)
			_start_action(_instruction(&"action", arguments))


func _reduce_navigation_instruction(
		presentation: Dictionary,
		instruction: KrkrScenarioInstruction
) -> void:
	var characters := presentation.get("characters", {}) as Dictionary
	var actions := presentation.get("actions", {}) as Dictionary
	match instruction.tag_name:
		&"cg", &"blackout", &"whiteout":
			var resource_id := instruction.string_argument("file")
			if instruction.tag_name == &"blackout":
				resource_id = "BLACK"
			elif instruction.tag_name == &"whiteout":
				resource_id = "WHITE"
			presentation["background"] = resource_id
			presentation["background_spec"] = {
				"file": resource_id,
				"source_center": instruction.string_argument("center"),
			}
			presentation["environment_tone"] = instruction.string_argument(
				"envtone", _tone_catalog.tone_for_background(resource_id)
			).to_lower()
			presentation["background_tone"] = "normal"
			presentation["camera_world_position"] = [0.0, 0.0, -CAMERA_DEPTH_RANGE]
			presentation["camera_position"] = [0.0, 0.0]
			presentation["camera_scale"] = 1.0
			presentation["_navigation_camera_arguments"] = {}
			presentation["background_scroll"] = {}
			presentation["actions"] = {}
			presentation["auto_positioning"] = true
			if not instruction.arguments.has("clear") or instruction.int_argument("clear", 1) != 0:
				characters.clear()
			presentation["characters"] = characters
		&"char":
			var resource_id := instruction.string_argument("file")
			if resource_id.is_empty():
				return
			var character_id := _normalize_character_id(
				instruction.string_argument("id", _character_id_for_asset(resource_id))
			)
			var previous := characters.get(character_id, {}) as Dictionary
			var previous_world := previous.get("world_position", []) as Array
			var world_x := 0.0
			var world_y := 0.0
			if previous_world.size() >= 2:
				world_x = float(previous_world[0])
				world_y = float(previous_world[1])
			var has_explicit_position := (
				instruction.arguments.has("x") or instruction.arguments.has("y")
			)
			if has_explicit_position:
				world_x = instruction.float_argument("x") * SOURCE_POSITION_SCALE
				world_y = instruction.float_argument("y")
				presentation["auto_positioning"] = false
			var depth := _character_depth(resource_id)
			var order := (
				instruction.int_argument("order")
				if instruction.arguments.has("order")
				else _character_z_index(resource_id)
			)
			characters[character_id] = {
				"file": resource_id,
				"x": world_x / SOURCE_POSITION_SCALE,
				"y": world_y,
				"z": depth,
				"order": order,
				"world_position": [world_x, world_y, depth],
				"modulate": [1.0, 1.0, 1.0, 1.0],
				"tone": instruction.string_argument("tone", "normal").to_lower(),
				"z_index": order,
			}
			presentation["characters"] = characters
			actions.erase(character_id)
			presentation["actions"] = actions
		&"clearchar":
			var requested_id := instruction.string_argument("id", "-1")
			if requested_id.is_empty() or requested_id == "-1":
				characters.clear()
				actions.clear()
				presentation["auto_positioning"] = true
			else:
				var character_id := _normalize_character_id(requested_id)
				characters.erase(character_id)
				actions.erase(character_id)
			presentation["characters"] = characters
			presentation["actions"] = actions
		&"move", &"leave":
			var character_id := _normalize_character_id(instruction.string_argument("id"))
			if not characters.has(character_id):
				return
			if instruction.tag_name == &"leave":
				characters.erase(character_id)
				actions.erase(character_id)
				presentation["characters"] = characters
				presentation["actions"] = actions
				presentation["auto_positioning"] = false
				return
			var details := (characters.get(character_id, {}) as Dictionary).duplicate(true)
			var world := details.get("world_position", [0.0, 0.0, 20.0]) as Array
			var world_x := float(world[0]) if world.size() >= 1 else 0.0
			var world_y := float(world[1]) if world.size() >= 2 else 0.0
			var world_z := float(world[2]) if world.size() >= 3 else 20.0
			if instruction.arguments.has("x"):
				world_x = instruction.float_argument("x") * SOURCE_POSITION_SCALE
			else:
				var movement_x := instruction.float_argument("mx")
				if instruction.arguments.has("left"):
					movement_x = -instruction.float_argument("left")
				elif instruction.arguments.has("right"):
					movement_x = instruction.float_argument("right")
				world_x += movement_x * SOURCE_POSITION_SCALE
			if instruction.arguments.has("y"):
				world_y = instruction.float_argument("y")
			else:
				var movement_y := instruction.float_argument("my")
				if instruction.arguments.has("top"):
					movement_y = -instruction.float_argument("top")
				elif instruction.arguments.has("bottom"):
					movement_y = instruction.float_argument("bottom")
				world_y += movement_y
			details["x"] = world_x / SOURCE_POSITION_SCALE
			details["y"] = world_y
			details["world_position"] = [world_x, world_y, world_z]
			characters[character_id] = details
			presentation["characters"] = characters
			presentation["auto_positioning"] = false
			actions.erase(character_id)
			presentation["actions"] = actions
		&"tone":
			_reduce_navigation_tone(presentation, instruction)
		&"autoposition":
			presentation["auto_positioning"] = true
		&"update":
			_reduce_navigation_auto_positions(presentation)
		&"action":
			var target_id := _normalize_character_id(instruction.string_argument("id"))
			if handles_action(instruction.string_argument("action")) \
				and instruction.int_argument("count", 1) < 0:
				actions[target_id] = instruction.arguments.duplicate(true)
			else:
				actions.erase(target_id)
			presentation["actions"] = actions
		&"stopaction":
			actions.erase(_normalize_character_id(instruction.string_argument("id")))
			presentation["actions"] = actions
		&"movecamera":
			presentation["_navigation_camera_arguments"] = instruction.arguments.duplicate(true)
		&"bgscroll":
			presentation["background_scroll"] = instruction.arguments.duplicate(true)


func _reduce_navigation_tone(
		presentation: Dictionary,
		instruction: KrkrScenarioInstruction
) -> void:
	var tone_name := instruction.string_argument("type", "normal").to_lower()
	var has_id := instruction.arguments.has("id")
	var targets_all := instruction.has_flag("all")
	var is_reset := not has_id and not targets_all and not instruction.has_flag("once")
	var characters := presentation.get("characters", {}) as Dictionary
	if is_reset or targets_all:
		presentation["background_tone"] = "normal" if is_reset else tone_name
		for character_id in characters:
			var details := (characters[character_id] as Dictionary).duplicate(true)
			details["tone"] = "normal" if is_reset else tone_name
			characters[character_id] = details
		presentation["characters"] = characters
		return
	if not has_id:
		return
	var requested_id := instruction.string_argument("id")
	if requested_id == "背景":
		presentation["background_tone"] = tone_name
		return
	var character_id := _normalize_character_id(requested_id)
	if characters.has(character_id):
		var details := (characters[character_id] as Dictionary).duplicate(true)
		details["tone"] = tone_name
		characters[character_id] = details
		presentation["characters"] = characters


func _reduce_navigation_auto_positions(presentation: Dictionary) -> void:
	if not bool(presentation.get("auto_positioning", true)):
		return
	var characters := presentation.get("characters", {}) as Dictionary
	var ids: Array = characters.keys()
	if ids.is_empty():
		return
	ids.sort_custom(
		func(left: Variant, right: Variant) -> bool:
			return int(CHARACTER_RELATES.get(str(left), 1000)) \
				< int(CHARACTER_RELATES.get(str(right), 1000))
	)
	var positions := _auto_positions(ids.size())
	for index in ids.size():
		var character_id := str(ids[index])
		var details := (characters[character_id] as Dictionary).duplicate(true)
		var world := details.get("world_position", [0.0, 0.0, 20.0]) as Array
		var world_y := float(world[1]) if world.size() >= 2 else 0.0
		var world_z := float(world[2]) if world.size() >= 3 else 20.0
		var world_x := positions[index] * SOURCE_POSITION_SCALE
		details["x"] = positions[index]
		details["world_position"] = [world_x, world_y, world_z]
		characters[character_id] = details
	presentation["characters"] = characters


func _apply_order(instruction: KrkrScenarioInstruction) -> void:
	match instruction.tag_name:
		&"cg":
			_apply_cg(instruction)
		&"char":
			_apply_character(instruction)
		&"clearchar":
			_start_clear_character(instruction)
		&"tone":
			_apply_tone(instruction)
		&"move":
			_start_move(instruction, false)
		&"leave":
			_start_move(instruction, true)


func _apply_cg(instruction: KrkrScenarioInstruction) -> void:
	var resource_id := instruction.string_argument("file")
	_environment_tone = instruction.string_argument(
		"envtone", _tone_catalog.tone_for_background(resource_id)
	).to_lower()
	_background_tone = "normal"
	_stop_all_actions()
	_clear_background_scroll()
	_reset_camera_transform()
	_auto_positioning = true
	if not instruction.arguments.has("clear") or instruction.int_argument("clear", 1) != 0:
		_clear_characters()
	_background_asset = resource_id
	match resource_id.to_upper():
		"BLACK":
			_configure_color_background(resource_id, Color.BLACK)
			return
		"WHITE":
			_configure_color_background(resource_id, Color.WHITE)
			return
	var literal_color := _cg_literal_color(resource_id)
	if literal_color.a >= 0.0:
		_configure_color_background(resource_id, literal_color)
		return
	var texture := _asset_resolver.texture_for_cg(resource_id)
	if texture == null:
		missing_asset.emit("背景", resource_id)
		return
	_background.texture = texture
	_fallback_base_color = Color.BLACK
	_refresh_background_tone()
	_configure_texture_background(instruction, texture, resource_id)


func _configure_color_background(resource_id: String, color: Color) -> void:
	_background.texture = null
	_fallback_base_color = color
	_refresh_background_tone()
	_background_coordinate_scale = NORMAL_CAMERA_COORDINATE_SCALE
	_configure_background_rect(DESIGN_SIZE * 0.5, DESIGN_SIZE)
	_background_spec = {
		"file": resource_id,
		"center": [DESIGN_SIZE.x * 0.5, DESIGN_SIZE.y * 0.5],
		"size": [DESIGN_SIZE.x, DESIGN_SIZE.y],
		"position": [0.0, 0.0],
		"coordinate_scale": _background_coordinate_scale,
		"oversize_hd": false,
	}


func _configure_texture_background(
	instruction: KrkrScenarioInstruction,
	texture: Texture2D,
	resource_id: String
) -> void:
	var texture_size := Vector2(float(texture.get_width()), float(texture.get_height()))
	var prefix := resource_id.get_file().left(1).to_upper()
	var is_fullscreen := is_equal_approx(texture_size.x, DESIGN_SIZE.x) \
		and is_equal_approx(texture_size.y, DESIGN_SIZE.y)
	var is_tall_pan_background := prefix == "B" and texture_size.y > DESIGN_SIZE.y
	var is_oversize_hd_event := prefix == "E" and not is_fullscreen
	var is_oversize_hd := is_tall_pan_background or is_oversize_hd_event
	_background_coordinate_scale = (
		OVERSIZE_CAMERA_COORDINATE_SCALE
		if is_oversize_hd
		else NORMAL_CAMERA_COORDINATE_SCALE
	)

	var source_center := instruction.string_argument("center")
	var center := _resolve_background_center(
		prefix,
		texture_size,
		is_tall_pan_background,
		is_oversize_hd,
		source_center
	)
	_configure_background_rect(center, texture_size)
	_background_spec = {
		"file": resource_id,
		"source_center": source_center,
		"center": [center.x, center.y],
		"size": [texture_size.x, texture_size.y],
		"position": [_background.position.x, _background.position.y],
		"coordinate_scale": _background_coordinate_scale,
		"oversize_hd": is_oversize_hd,
	}


func _resolve_background_center(
	prefix: String,
	texture_size: Vector2,
	is_tall_pan_background: bool,
	is_oversize_hd: bool,
	source_center: String
) -> Vector2:
	if (prefix == "B" and not is_tall_pan_background) \
		or ((prefix == "E" or prefix == "S") and texture_size.is_equal_approx(DESIGN_SIZE)):
		return DESIGN_SIZE * 0.5
	if source_center == "-1":
		return texture_size * 0.5
	var parsed_center: Variant = _parse_source_point(source_center)
	if parsed_center != null:
		var center := parsed_center as Vector2
		if is_oversize_hd and center.x <= SOURCE_LOGICAL_WIDTH:
			center.x *= DESIGN_SIZE.x / SOURCE_LOGICAL_WIDTH
			center.y *= OVERSIZE_HD_SCALE
		return center
	if is_oversize_hd:
		return Vector2(DESIGN_SIZE.x * 0.5, 300.0 * OVERSIZE_HD_SCALE)
	return Vector2(400.0, 300.0)


func _configure_background_rect(center: Vector2, texture_size: Vector2) -> void:
	_background.size = texture_size
	_background.position = DESIGN_SIZE * 0.5 - center
	_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background.stretch_mode = TextureRect.STRETCH_KEEP


func _parse_source_point(value: String) -> Variant:
	if value.is_empty():
		return null
	var components := value.split(",", false)
	if components.size() < 2:
		return null
	var x_text := components[0].strip_edges()
	var y_text := components[1].strip_edges()
	if not x_text.is_valid_float() or not y_text.is_valid_float():
		return null
	return Vector2(x_text.to_float(), y_text.to_float())


func _apply_character(instruction: KrkrScenarioInstruction) -> void:
	var resource_id := instruction.string_argument("file")
	var texture := _asset_resolver.texture_for_character(resource_id)
	if texture == null:
		missing_asset.emit("立绘", resource_id)
		return
	var character_id := instruction.string_argument("id", _character_id_for_asset(resource_id))
	character_id = _normalize_character_id(character_id)
	var node := _character_nodes.get(character_id) as TextureRect
	var previous_texture: Texture2D = node.texture if node != null else null
	var was_transitioning := _character_transition_tweens.has(character_id)
	_cancel_character_transition(character_id)
	_cancel_character_removal(character_id)
	if node != null and _action_tweens.has(character_id):
		stop_action(character_id)
	if node == null:
		node = TextureRect.new()
		node.name = "Character%s" % character_id.to_pascal_case()
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		node.stretch_mode = TextureRect.STRETCH_KEEP
		_character_layer.add_child(node)
		_character_nodes[character_id] = node
	node.texture = texture
	var texture_size := Vector2(float(texture.get_width()), float(texture.get_height()))
	node.size = texture_size
	var guide_center := _character_guide_center(resource_id, texture_size)
	node.pivot_offset = guide_center
	var has_explicit_position := instruction.arguments.has("x") or instruction.arguments.has("y")
	var world_position := Vector3(0.0, 0.0, _character_depth(resource_id))
	if not has_explicit_position and _character_world_positions.has(character_id):
		var previous_world := _character_world_positions[character_id] as Vector3
		world_position.x = previous_world.x
		world_position.y = previous_world.y
	else:
		world_position.x = instruction.float_argument("x") * SOURCE_POSITION_SCALE
		world_position.y = instruction.float_argument("y")
	if has_explicit_position:
		_auto_positioning = false
	_character_world_positions[character_id] = world_position
	_character_action_offsets[character_id] = Vector2.ZERO
	_character_tones[character_id] = instruction.string_argument("tone", "normal").to_lower()
	node.modulate = Color.WHITE
	_refresh_character_tone(character_id)
	node.visible = true
	if instruction.arguments.has("order"):
		node.z_index = instruction.int_argument("order")
	else:
		node.z_index = _character_z_index(resource_id)
	_character_assets[character_id] = {
		"file": resource_id,
		"x": world_position.x / SOURCE_POSITION_SCALE,
		"y": world_position.y,
		"z": world_position.z,
		"order": node.z_index,
	}
	_update_character_projection(character_id)
	var transition_milliseconds := (
		0
		if _applying_instant
		else maxi(instruction.int_argument("time", DEFAULT_UPDATE_MILLISECONDS), 0)
	)
	if transition_milliseconds <= 0:
		return
	if previous_texture != null and not was_transitioning:
		_start_character_crossfade(
			character_id, node, previous_texture, transition_milliseconds
		)
	else:
		_start_character_activation(character_id, node, transition_milliseconds)


func _start_character_crossfade(
	character_id: String,
	node: TextureRect,
	previous_texture: Texture2D,
	milliseconds: int
) -> void:
	var material := ShaderMaterial.new()
	material.shader = CHARACTER_CROSSFADE_SHADER
	material.set_shader_parameter("previous_texture", previous_texture)
	material.set_shader_parameter("progress", 0.0)
	node.material = material
	var tween := create_tween()
	_character_transition_tweens[character_id] = tween
	tween.tween_method(
		func(value: float) -> void:
			if _character_nodes.get(character_id) == node and node.material == material:
				material.set_shader_parameter("progress", value),
		0.0,
		1.0,
		float(milliseconds) / 1000.0
	)
	tween.finished.connect(
		func() -> void:
			if _character_transition_tweens.get(character_id) == tween:
				_character_transition_tweens.erase(character_id)
			if _character_nodes.get(character_id) == node and node.material == material:
				node.material = null
	)


func _start_character_activation(
	character_id: String,
	node: TextureRect,
	milliseconds: int
) -> void:
	node.modulate.a = 0.0
	var tween := create_tween()
	_character_transition_tweens[character_id] = tween
	tween.tween_property(node, "modulate:a", 1.0, float(milliseconds) / 1000.0)
	tween.finished.connect(
		func() -> void:
			if _character_transition_tweens.get(character_id) == tween:
				_character_transition_tweens.erase(character_id)
			if _character_nodes.get(character_id) == node:
				node.modulate.a = 1.0
	)


func _cancel_character_transition(character_id: String) -> void:
	var tween := _character_transition_tweens.get(character_id) as Tween
	if tween != null and tween.is_valid():
		tween.kill()
	_character_transition_tweens.erase(character_id)
	var node := _character_nodes.get(character_id) as TextureRect
	if node != null:
		node.material = null
		node.modulate.a = 1.0


func _finish_all_character_transitions() -> void:
	for character_id in _character_transition_tweens.keys().duplicate():
		_cancel_character_transition(str(character_id))


func _remove_character(requested_id: String) -> void:
	if requested_id.is_empty() or requested_id == "-1":
		_auto_positioning = true
		_clear_characters()
		return
	var character_id := _normalize_character_id(requested_id)
	_cancel_character_transition(character_id)
	_cancel_character_removal(character_id)
	if _action_tweens.has(character_id):
		stop_action(character_id)
	var node := _character_nodes.get(character_id) as TextureRect
	if node != null:
		_character_layer.remove_child(node)
		node.queue_free()
	_character_nodes.erase(character_id)
	_character_assets.erase(character_id)
	_character_tones.erase(character_id)
	_character_world_positions.erase(character_id)
	_character_action_offsets.erase(character_id)


func _start_clear_character(instruction: KrkrScenarioInstruction) -> void:
	var requested_id := instruction.string_argument("id", "-1")
	var target_ids: Array = []
	if requested_id.is_empty() or requested_id == "-1":
		_auto_positioning = true
		target_ids = _character_nodes.keys().duplicate()
	else:
		target_ids.append(_normalize_character_id(requested_id))
	var milliseconds := 0 if _applying_instant else maxi(instruction.int_argument("time", 500), 0)
	for target_variant in target_ids:
		var target_id := str(target_variant)
		_cancel_character_transition(target_id)
		var node := _character_nodes.get(target_id) as TextureRect
		if node == null:
			continue
		if milliseconds <= 0:
			_remove_character(target_id)
			continue
		_cancel_character_removal(target_id)
		_characters_pending_removal[target_id] = true
		var tween := create_tween()
		_character_removal_tweens[target_id] = tween
		tween.tween_property(node, "modulate:a", 0.0, float(milliseconds) / 1000.0)
		tween.finished.connect(_finish_character_removal.bind(target_id, node))


func _finish_character_removal(character_id: String, node: TextureRect) -> void:
	_character_removal_tweens.erase(character_id)
	_characters_pending_removal.erase(character_id)
	_detach_character_node(character_id, node)


func _cancel_character_removal(character_id: String) -> void:
	var tween := _character_removal_tweens.get(character_id) as Tween
	if tween != null and tween.is_valid():
		tween.kill()
	_character_removal_tweens.erase(character_id)
	_characters_pending_removal.erase(character_id)
	var node := _character_nodes.get(character_id) as TextureRect
	if node != null:
		node.modulate.a = 1.0


func _detach_character_node(character_id: String, expected_node: TextureRect) -> void:
	var node := _character_nodes.get(character_id) as TextureRect
	if node == null or node != expected_node:
		return
	_character_layer.remove_child(node)
	node.queue_free()
	_character_nodes.erase(character_id)
	_character_assets.erase(character_id)
	_character_tones.erase(character_id)
	_character_world_positions.erase(character_id)
	_character_action_offsets.erase(character_id)


func _clear_characters() -> void:
	_finish_all_character_transitions()
	for character_id in _character_removal_tweens.keys().duplicate():
		var removal_tween := _character_removal_tweens.get(character_id) as Tween
		if removal_tween != null and removal_tween.is_valid():
			removal_tween.kill()
	_character_removal_tweens.clear()
	_characters_pending_removal.clear()
	for target_id in _action_tweens.keys().duplicate():
		if str(target_id) != "カメラ":
			stop_action(str(target_id))
	for character_id in _character_nodes.keys():
		var node := _character_nodes[character_id] as TextureRect
		if node != null:
			_character_layer.remove_child(node)
			node.queue_free()
	_character_nodes.clear()
	_character_assets.clear()
	_character_tones.clear()
	_character_world_positions.clear()
	_character_action_offsets.clear()


func _apply_auto_positions() -> void:
	var ids: Array = _character_nodes.keys()
	if ids.is_empty():
		return
	ids.sort_custom(
		func(left: Variant, right: Variant) -> bool:
			return int(CHARACTER_RELATES.get(str(left), 1000)) \
				< int(CHARACTER_RELATES.get(str(right), 1000))
	)
	var positions := _auto_positions(ids.size())
	for index in ids.size():
		var character_id := str(ids[index])
		var world_position := _character_world_positions.get(character_id, Vector3.ZERO) as Vector3
		world_position.x = positions[index] * SOURCE_POSITION_SCALE
		_character_world_positions[character_id] = world_position
		_update_character_projection(character_id)


func _auto_positions(count: int) -> Array[float]:
	match count:
		1: return [0.0]
		2: return [-200.0, 200.0]
		3: return [-300.0, 0.0, 300.0]
		4: return [-300.0, -100.0, 100.0, 300.0]
		5: return [-400.0, -200.0, 0.0, 200.0, 400.0]
	var result: Array[float] = []
	var start := -float(count - 1) * 87.5
	for index in count:
		result.append(start + float(index) * 175.0)
	return result


func _apply_tone(instruction: KrkrScenarioInstruction) -> void:
	var tone_name := instruction.string_argument("type", "normal").to_lower()
	var has_id := instruction.arguments.has("id")
	var targets_all := instruction.has_flag("all")
	var is_reset := not has_id and not targets_all and not instruction.has_flag("once")
	if is_reset or targets_all:
		_background_tone = "normal" if is_reset else tone_name
		_refresh_background_tone()
		for character_id in _character_nodes:
			_character_tones[character_id] = "normal" if is_reset else tone_name
			_refresh_character_tone(str(character_id))
		return
	if not has_id:
		return
	var requested_id := instruction.string_argument("id")
	if requested_id == "背景":
		_background_tone = tone_name
		_refresh_background_tone()
		return
	var character_id := _normalize_character_id(requested_id)
	if _character_nodes.has(character_id):
		_character_tones[character_id] = tone_name
		_refresh_character_tone(character_id)


func _refresh_background_tone() -> void:
	var tone_color := _tone_catalog.color_for_tone(_background_tone)
	var alpha := _background.modulate.a
	_background.modulate = Color(tone_color.r, tone_color.g, tone_color.b, alpha)
	_fallback.color = Color(
		_fallback_base_color.r * tone_color.r,
		_fallback_base_color.g * tone_color.g,
		_fallback_base_color.b * tone_color.b,
		_fallback_base_color.a
	)


func _refresh_character_tone(character_id: String) -> void:
	var node := _character_nodes.get(character_id) as TextureRect
	if node == null:
		return
	var environment_color := _tone_catalog.color_for_tone(_environment_tone)
	var explicit_color := _tone_catalog.color_for_tone(
		str(_character_tones.get(character_id, "normal"))
	)
	var alpha := node.modulate.a
	node.modulate = Color(
		environment_color.r * explicit_color.r,
		environment_color.g * explicit_color.g,
		environment_color.b * explicit_color.b,
		alpha
	)


func _start_move(instruction: KrkrScenarioInstruction, remove_after: bool) -> void:
	var target_id := _normalize_character_id(instruction.string_argument("id"))
	var node := _character_nodes.get(target_id) as TextureRect
	if node == null:
		return
	_auto_positioning = false
	stop_action(target_id)
	var start_world := _character_world_positions.get(target_id, Vector3.ZERO) as Vector3
	var target_world := start_world
	if instruction.arguments.has("x"):
		target_world.x = instruction.float_argument("x") * SOURCE_POSITION_SCALE
	else:
		var source_movement_x := instruction.float_argument("mx")
		if instruction.arguments.has("left"):
			source_movement_x = -instruction.float_argument("left")
		elif instruction.arguments.has("right"):
			source_movement_x = instruction.float_argument("right")
		elif remove_after and not instruction.arguments.has("mx"):
			source_movement_x = 100.0
		target_world.x += source_movement_x * SOURCE_POSITION_SCALE
	var source_movement_y := instruction.float_argument("my")
	if instruction.arguments.has("top"):
		source_movement_y = -instruction.float_argument("top")
	elif instruction.arguments.has("bottom"):
		source_movement_y = instruction.float_argument("bottom")
	if remove_after:
		# The source Leave wrapper always materializes an absolute y+my target
		# before dispatching ActionAdvMoveFadeOut.
		target_world.y = instruction.float_argument("y") + source_movement_y
	elif instruction.arguments.has("y"):
		target_world.y = instruction.float_argument("y")
	else:
		target_world.y += source_movement_y
	# Move/Leave are wrappers around source Action sequences. Their duration is
	# `cycle` (default 500 ms); a stray `time` field in one source Move tag is
	# deliberately not interpreted as an alias.
	var milliseconds := maxi(instruction.int_argument("cycle", DEFAULT_ACTION_MILLISECONDS), 0)
	_action_origins[target_id] = {"world_position": target_world, "modulate": node.modulate}
	if milliseconds <= 0:
		_character_world_positions[target_id] = target_world
		_update_character_projection(target_id)
		_action_tweens.erase(target_id)
		_action_origins.erase(target_id)
		if remove_after:
			_remove_character(target_id)
		action_finished.emit(target_id)
		return
	var tween := create_tween()
	_action_tweens[target_id] = tween
	var duration := float(milliseconds) / 1000.0
	var movement := tween.tween_method(
		func(value: Vector3) -> void:
			_character_world_positions[target_id] = value
			_update_character_projection(target_id),
		start_world,
		target_world,
		duration
	)
	_apply_method_easing(movement, instruction.int_argument("accel", 2))
	if remove_after:
		tween.parallel().tween_property(node, "modulate:a", 0.0, duration)
	tween.finished.connect(
		func() -> void:
			_character_world_positions[target_id] = target_world
			_update_character_projection(target_id)
			_action_tweens.erase(target_id)
			_action_origins.erase(target_id)
			if remove_after and _character_nodes.get(target_id) == node:
				_remove_character(target_id)
			action_finished.emit(target_id)
	)


func _start_action(instruction: KrkrScenarioInstruction) -> void:
	var target_id := _normalize_character_id(instruction.string_argument("id"))
	var target := _action_target(target_id)
	if target == null:
		return
	var action_name := instruction.string_argument("action")
	if not handles_action(action_name):
		return
	stop_action(target_id)
	var origin_modulate := target.modulate
	if target_id == "カメラ":
		_action_origins[target_id] = {
			"camera_world_position": _camera_world_position,
			"modulate": origin_modulate,
		}
	else:
		_action_origins[target_id] = {
			"world_position": _character_world_positions.get(target_id, Vector3.ZERO),
			"modulate": origin_modulate,
		}
	_active_action_specs[target_id] = instruction.arguments.duplicate(true)
	var cycle := maxi(instruction.int_argument("cycle", DEFAULT_ACTION_MILLISECONDS), 1)
	var source_count := instruction.int_argument("count", 1)
	var repeats_forever := source_count < 0
	var count := maxi(source_count, 1)
	var duration := float(cycle) / 1000.0 if repeats_forever else float(cycle * count) / 1000.0
	var width := instruction.float_argument("width")
	var height := instruction.float_argument("height")
	var tween := create_tween()
	if repeats_forever:
		tween.set_loops()
	_action_tweens[target_id] = tween
	match action_name.to_lower():
		"actionadvjump":
			tween.tween_method(
				func(progress: float) -> void:
					_set_action_offset(
						target_id,
						Vector2(0.0, -absf(sin(progress * PI * float(count))) * height)
					),
				0.0,
				1.0,
				duration
			)
		"actionadvhop":
			tween.tween_method(
				func(progress: float) -> void:
					var phase := progress * TAU * float(count)
					_set_action_offset(
						target_id,
						Vector2(sin(phase) * width, -absf(sin(phase * 2.0)) * height)
					),
				0.0,
				1.0,
				duration
			)
		"actionadvwave", "actionwave":
			tween.tween_method(
				func(progress: float) -> void:
					var phase_count := 1.0 if repeats_forever else float(count)
					var phase := progress * TAU * phase_count
					_set_action_offset(
						target_id,
						Vector2(sin(phase) * width, sin(phase) * height)
					),
				0.0,
				1.0,
				duration
			)
		_:
			_action_tweens.erase(target_id)
			_action_origins.erase(target_id)
			_active_action_specs.erase(target_id)
			return
	tween.finished.connect(
		func() -> void:
			_clear_action_offset(target_id)
			target.modulate = origin_modulate
			_action_tweens.erase(target_id)
			_action_origins.erase(target_id)
			_active_action_specs.erase(target_id)
			action_finished.emit(target_id)
	)


func _action_target(target_id: String) -> Control:
	if target_id == "カメラ":
		return _camera_canvas
	return _character_nodes.get(target_id) as Control


func _restore_action_origin(target_id: String) -> void:
	var target := _action_target(target_id)
	var origin: Variant = _action_origins.get(target_id)
	if target == null or not origin is Dictionary:
		return
	if target_id == "カメラ":
		var camera_origin: Variant = origin.get("camera_world_position")
		if camera_origin is Vector3:
			_camera_world_position = camera_origin
	else:
		var character_origin: Variant = origin.get("world_position")
		if character_origin is Vector3:
			_character_world_positions[target_id] = character_origin
	target.modulate = origin.get("modulate", target.modulate)
	_apply_camera_projection()


func _start_camera_move(instruction: KrkrScenarioInstruction) -> void:
	if is_camera_moving():
		finish_camera_move()
	if is_action_running("カメラ"):
		stop_action("カメラ")
	var target_world_position := Vector3(
		instruction.float_argument("x") * _background_coordinate_scale,
		instruction.float_argument("y") * _background_coordinate_scale,
		instruction.float_argument("z") - CAMERA_DEPTH_RANGE
	)
	var milliseconds := maxi(instruction.int_argument("time", DEFAULT_UPDATE_MILLISECONDS), 0)
	if not _screen_effects_enabled:
		milliseconds = 0
	_start_camera_world_move(
		target_world_position,
		milliseconds,
		instruction.int_argument("accel", 2)
	)


func _start_camera_world_move(
		target_world_position: Vector3,
		milliseconds: int,
		acceleration: int
) -> void:
	_camera_move_start_world_position = _camera_world_position
	_camera_target_world_position = target_world_position
	_camera_move_duration_milliseconds = milliseconds
	if milliseconds <= 0:
		_apply_camera_world_position(_camera_target_world_position)
		_camera_move_duration_milliseconds = 0
		camera_finished.emit()
		return
	_camera_tween = create_tween()
	var camera_tweener := _camera_tween.tween_method(
		_apply_camera_world_position,
		_camera_world_position,
		_camera_target_world_position,
		float(milliseconds) / 1000.0
	)
	_apply_method_easing(camera_tweener, acceleration)
	_camera_tween.finished.connect(
		func() -> void:
			_apply_camera_world_position(_camera_target_world_position)
			_camera_tween = null
			_camera_move_duration_milliseconds = 0
			camera_finished.emit()
	)


func _cancel_camera_move() -> void:
	if is_camera_moving():
		_camera_tween.kill()
	_camera_tween = null
	_camera_move_duration_milliseconds = 0


func _vector3_to_array(value: Vector3) -> Array[float]:
	return [value.x, value.y, value.z]


func _vector3_from_variant(value: Variant, fallback: Vector3) -> Vector3:
	if value is Array and value.size() >= 3:
		return Vector3(float(value[0]), float(value[1]), float(value[2]))
	return fallback


func _apply_camera_world_position(value: Vector3) -> void:
	_camera_world_position = value
	_apply_camera_projection()


func _apply_camera_projection() -> void:
	var effective_camera := _camera_world_position + Vector3(
		_camera_action_offset.x,
		_camera_action_offset.y,
		0.0
	)
	var denominator := maxf(CAMERA_DEPTH_RANGE - effective_camera.z, 1.0)
	var zoom := maxf(CAMERA_PROJECTION_DEPTH / denominator, 0.01)
	_camera_canvas.position = -Vector2(effective_camera.x, effective_camera.y) \
		* CAMERA_DEPTH_RANGE / denominator
	_camera_canvas.scale = Vector2.ONE * zoom
	for character_id in _character_nodes:
		_update_character_projection(str(character_id), effective_camera)


func _update_character_projection(
	character_id: String,
	effective_camera: Vector3 = Vector3(INF, INF, INF)
) -> void:
	var node := _character_nodes.get(character_id) as TextureRect
	if node == null:
		return
	if is_inf(effective_camera.x):
		effective_camera = _camera_world_position + Vector3(
			_camera_action_offset.x,
			_camera_action_offset.y,
			0.0
		)
	var world_position := _character_world_positions.get(character_id, Vector3.ZERO) as Vector3
	var action_offset := _character_action_offsets.get(character_id, Vector2.ZERO) as Vector2
	world_position += Vector3(action_offset.x, action_offset.y, 0.0)
	var denominator := maxf(world_position.z - effective_camera.z, 1.0)
	var screen_offset := (
		Vector2(world_position.x, world_position.y)
		- Vector2(effective_camera.x, effective_camera.y)
	) * CAMERA_DEPTH_RANGE / denominator
	var zoom := maxf((world_position.z + CAMERA_DEPTH_RANGE) / denominator, 0.01)
	node.position = DESIGN_SIZE * 0.5 + screen_offset - node.pivot_offset
	node.scale = Vector2.ONE * zoom


func _set_action_offset(target_id: String, offset: Vector2) -> void:
	if target_id == "カメラ":
		_camera_action_offset = offset
		_apply_camera_projection()
		return
	_character_action_offsets[target_id] = offset
	_update_character_projection(target_id)


func _clear_action_offset(target_id: String) -> void:
	if target_id == "カメラ":
		_camera_action_offset = Vector2.ZERO
		_apply_camera_projection()
		return
	_character_action_offsets[target_id] = Vector2.ZERO
	_update_character_projection(target_id)


func _camera_world_from_visual(position: Vector2, zoom: float) -> Vector3:
	var safe_zoom := maxf(zoom, 0.01)
	return Vector3(
		-position.x * 2.0 / safe_zoom,
		-position.y * 2.0 / safe_zoom,
		CAMERA_DEPTH_RANGE - CAMERA_PROJECTION_DEPTH / safe_zoom
	)


func _start_background_scroll(instruction: KrkrScenarioInstruction) -> void:
	_clear_background_scroll()
	var resource_id := instruction.string_argument("file")
	var texture := _asset_resolver.texture_for_cg(resource_id)
	if texture == null:
		missing_asset.emit("滚动背景", resource_id)
		return
	# EnvEffectBgScroll consumes its coordinates directly in the 1920x1080
	# surface. Unlike character X positions, these values are not legacy
	# 1280-wide coordinates and must not use SOURCE_POSITION_SCALE.
	var origin := Vector2(
		instruction.float_argument("x"),
		instruction.float_argument("y")
	)
	var distance := Vector2(
		instruction.float_argument("mx"),
		instruction.float_argument("my")
	)
	var cycle_milliseconds := maxi(instruction.int_argument("cycle", 10000), 1)
	var phase := clampf(instruction.float_argument("phase", 0.0), 0.0, 0.999999)
	_background_scroll_spec = {
		"file": resource_id,
		"x": instruction.float_argument("x"),
		"y": instruction.float_argument("y"),
		"mx": instruction.float_argument("mx"),
		"my": instruction.float_argument("my"),
		"cycle": cycle_milliseconds,
	}
	_populate_scroll_tiles(_background_scroll_tiles, texture, distance)
	_background_scroll_layer.visible = true
	_background_scroll_tiles.position = origin + distance * phase
	_background_scroll_started_msec = Time.get_ticks_msec() - int(float(cycle_milliseconds) * phase)
	if phase > 0.0:
		var remaining_seconds := maxf(float(cycle_milliseconds) * (1.0 - phase) / 1000.0, 0.001)
		_background_scroll_tween = create_tween()
		_background_scroll_tween.tween_property(
			_background_scroll_tiles,
			"position",
			origin + distance,
			remaining_seconds
		).from(_background_scroll_tiles.position)
		_background_scroll_tween.finished.connect(
			func() -> void:
				_begin_background_scroll_loop(origin, distance, cycle_milliseconds)
		)
	else:
		_begin_background_scroll_loop(origin, distance, cycle_milliseconds)


func _capture_transition_snapshot() -> void:
	_clear_snapshot_characters()
	_clear_children(_snapshot_background_scroll_tiles)
	_snapshot_camera.position = _camera_canvas.position
	_snapshot_camera.scale = _camera_canvas.scale
	_snapshot_fallback.color = _fallback.color
	_snapshot_background.texture = _background.texture
	_snapshot_background.position = _background.position
	_snapshot_background.size = _background.size
	_snapshot_background.expand_mode = _background.expand_mode
	_snapshot_background.stretch_mode = _background.stretch_mode
	_snapshot_background.modulate = _background.modulate
	_snapshot_background_scroll.visible = _background_scroll_layer.visible
	_snapshot_background_scroll_tiles.position = _background_scroll_tiles.position
	for source_tile in _background_scroll_tiles.get_children():
		var source_texture := source_tile as TextureRect
		if source_texture == null:
			continue
		var snapshot_tile := _clone_texture_rect(source_texture)
		_snapshot_background_scroll_tiles.add_child(snapshot_tile)
	for character_id in _character_nodes:
		var source := _character_nodes[character_id] as TextureRect
		var snapshot := _clone_texture_rect(source)
		snapshot.name = "Snapshot%s" % str(character_id).to_pascal_case()
		_snapshot_characters.add_child(snapshot)
	_snapshot_group.self_modulate = Color.WHITE
	_transition_snapshot.visible = true


func _start_transition(milliseconds: int, instruction: KrkrScenarioInstruction = null) -> void:
	_transition_active = true
	var duration := maxf(float(milliseconds) / 1000.0, 0.01)
	transition_started.emit(duration)
	_transition_tween = create_tween()
	var transition_type := instruction.string_argument("transition", "crossfade").to_lower() if instruction != null else "crossfade"
	var rule_id := instruction.string_argument("rule") if instruction != null else ""
	var rule_texture := _asset_resolver.texture_for_rule(rule_id) if not rule_id.is_empty() else null
	var use_rule := transition_type == "universal" and rule_texture != null and _transition_material != null
	if use_rule:
		_transition_material.set_shader_parameter("rule_texture", rule_texture)
		_transition_material.set_shader_parameter("use_rule", true)
		_transition_material.set_shader_parameter("progress", -0.05)
		_transition_tween.tween_method(
			func(value: float) -> void:
				_transition_material.set_shader_parameter("progress", value),
			-0.05,
			1.05,
			duration
		)
	else:
		_reset_transition_material()
		_transition_tween.tween_property(_snapshot_group, "self_modulate:a", 0.0, duration)
	_transition_tween.finished.connect(
		func() -> void:
			_transition_tween = null
			_transition_active = false
			_reset_transition_material()
			_hide_transition_snapshot()
			transition_finished.emit()
	)


func _reset_transition_material() -> void:
	if _transition_material == null:
		return
	_transition_material.set_shader_parameter("use_rule", false)
	_transition_material.set_shader_parameter("progress", -0.05)


func _hide_transition_snapshot() -> void:
	_transition_snapshot.visible = false
	_snapshot_group.self_modulate = Color.WHITE
	_snapshot_background_scroll.visible = false
	_clear_children(_snapshot_background_scroll_tiles)
	_clear_snapshot_characters()


func _clear_snapshot_characters() -> void:
	_clear_children(_snapshot_characters)


func _begin_background_scroll_loop(origin: Vector2, distance: Vector2, cycle_milliseconds: int) -> void:
	if not is_inside_tree() or _background_scroll_spec.is_empty():
		return
	_background_scroll_tiles.position = origin
	_background_scroll_started_msec = Time.get_ticks_msec()
	_background_scroll_tween = create_tween().set_loops()
	_background_scroll_tween.tween_property(
		_background_scroll_tiles,
		"position",
		origin + distance,
		float(cycle_milliseconds) / 1000.0
	).from(origin)


func _clear_background_scroll() -> void:
	if _background_scroll_tween != null and _background_scroll_tween.is_valid():
		_background_scroll_tween.kill()
	_background_scroll_tween = null
	_background_scroll_spec.clear()
	_background_scroll_started_msec = 0
	if is_instance_valid(_background_scroll_layer):
		_background_scroll_layer.visible = false
	if is_instance_valid(_background_scroll_tiles):
		_background_scroll_tiles.position = Vector2.ZERO
		_clear_children(_background_scroll_tiles)


func _populate_scroll_tiles(container: Control, texture: Texture2D, distance: Vector2) -> void:
	_clear_children(container)
	var tile_size := Vector2(texture.get_width(), texture.get_height())
	if tile_size.x <= 0.0 or tile_size.y <= 0.0:
		return
	var horizontal_padding := absf(distance.x) + tile_size.x
	var vertical_padding := absf(distance.y) + tile_size.y
	var start := Vector2(-horizontal_padding, -vertical_padding)
	var end := DESIGN_SIZE + Vector2(horizontal_padding, vertical_padding)
	var row := 0
	var y := start.y
	while y < end.y:
		var column := 0
		var x := start.x
		while x < end.x:
			var tile := TextureRect.new()
			tile.name = "Tile%02d_%02d" % [row, column]
			tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
			tile.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tile.stretch_mode = TextureRect.STRETCH_KEEP
			tile.texture = texture
			tile.position = Vector2(x, y)
			tile.size = tile_size
			container.add_child(tile)
			x += tile_size.x
			column += 1
		y += tile_size.y
		row += 1


func _clone_texture_rect(source: TextureRect) -> TextureRect:
	var result := TextureRect.new()
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result.expand_mode = source.expand_mode
	result.stretch_mode = source.stretch_mode
	result.texture = source.texture
	result.position = source.position
	result.size = source.size
	result.pivot_offset = source.pivot_offset
	result.scale = source.scale
	result.rotation = source.rotation
	result.modulate = source.modulate
	result.z_index = source.z_index
	return result


func _reset_camera_transform() -> void:
	_cancel_camera_move()
	_camera_action_offset = Vector2.ZERO
	_camera_world_position = Vector3(0.0, 0.0, -CAMERA_DEPTH_RANGE)
	_camera_move_start_world_position = _camera_world_position
	_camera_target_world_position = _camera_world_position
	_apply_camera_projection()


func _clear_children(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()


func _stop_all_actions() -> void:
	for target_id in _action_tweens.keys().duplicate():
		stop_action(str(target_id))
	_active_action_specs.clear()


func _color_to_array(color: Color) -> Array[float]:
	return [color.r, color.g, color.b, color.a]


func _color_from_variant(value: Variant, fallback: Color) -> Color:
	if value is Array and value.size() >= 4:
		return Color(float(value[0]), float(value[1]), float(value[2]), float(value[3]))
	return fallback


func _cg_literal_color(resource_id: String) -> Color:
	var components := resource_id.split(",", false)
	if components.size() != 3:
		return Color(0.0, 0.0, 0.0, -1.0)
	for component in components:
		if not component.strip_edges().is_valid_int():
			return Color(0.0, 0.0, 0.0, -1.0)
	return Color8(
		clampi(components[0].strip_edges().to_int(), 0, 255),
		clampi(components[1].strip_edges().to_int(), 0, 255),
		clampi(components[2].strip_edges().to_int(), 0, 255),
		255
	)


func _normalize_character_id(source_id: String) -> String:
	return str(CHARACTER_ALIASES.get(source_id, source_id))


func _character_id_for_asset(resource_id: String) -> String:
	var prefix := resource_id.get_file().get_basename().left(2).to_lower()
	return str(CHARACTER_NAMES.get(prefix, prefix.to_upper()))


func _load_character_layouts() -> void:
	_character_layouts.clear()
	var file := FileAccess.open(CHARACTER_LAYOUT_PATH, FileAccess.READ)
	if file == null:
		return
	var first_row := true
	while not file.eof_reached():
		var row := file.get_csv_line()
		if first_row:
			first_row = false
			continue
		if row.size() < 3 or row[0].is_empty():
			continue
		_character_layouts[row[0].to_upper()] = Vector2(
			row[1].to_float() * SOURCE_POSITION_SCALE,
			row[2].to_float() * SOURCE_POSITION_SCALE
		)


func _character_guide_center(resource_id: String, texture_size: Vector2) -> Vector2:
	var key := resource_id.get_file().get_basename().to_upper()
	var center: Variant = _character_layouts.get(key)
	if center is Vector2:
		return center
	return Vector2(texture_size.x * 0.5, texture_size.y - 50.0)


func _character_depth(resource_id: String) -> float:
	match resource_id.get_basename().right(1).to_upper():
		"L": return 25.0
		"M": return 30.0
		"S": return 35.0
	return 20.0


func _character_z_index(resource_id: String) -> int:
	var prefix := resource_id.get_file().get_basename().left(2).to_lower()
	var base_order := int(CHARACTER_BASE_ORDERS.get(prefix, 0))
	match resource_id.get_basename().right(1).to_upper():
		"S": return 500 + base_order
		"M": return 700 + base_order
		"L": return 900 + base_order
	return 900 + base_order


func _apply_method_easing(tweener: MethodTweener, acceleration: int) -> void:
	match acceleration:
		-1, 0, 1:
			tweener.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		-2:
			tweener.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		-3:
			tweener.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		-4:
			tweener.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
		2:
			tweener.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		3:
			tweener.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		4:
			tweener.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		_:
			tweener.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func _instruction(tag_name: StringName, arguments: Dictionary) -> KrkrScenarioInstruction:
	var flags: Array[StringName] = []
	return KrkrScenarioInstruction.tag(tag_name, arguments, flags, 0, "")

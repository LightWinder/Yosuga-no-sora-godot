class_name KrkrScenarioRuntime
extends Node


signal scenario_changed(scenario_id: String)
signal instruction_executed(instruction: KrkrScenarioInstruction)
signal dialogue_ready(speaker: String, message: String, voice_id: String, anchor: String, already_read: bool)
signal choices_ready(choices: Array[Dictionary])
signal wait_started(milliseconds: int, cancellable: bool)
signal external_wait_started(wait_reason: StringName, cancellable: bool)
signal external_skip_requested(wait_reason: StringName)
signal playback_finished
signal runtime_error(message: String)


enum PauseReason {
	NONE,
	DIALOGUE,
	CHOICE,
	TIMER,
	EXTERNAL,
	FINISHED,
}

const DEFAULT_SCENARIO_DIRECTORY := "res://assets/scenario"
const MAX_INSTRUCTIONS_PER_TICK := 100000
const CONTROL_TAGS: Array[StringName] = [
	&"talk", &"hitret", &"change",
	&"addselect", &"startselect", &"selectterminate",
	&"if", &"elsif", &"else", &"endif",
	&"onflag", &"offflag", &"onglobalflag", &"offglobalflag",
	&"setparam", &"addparam", &"clearparam",
	&"wait", &"playmovie", &"recollect",
	&"staffroll",
	&"terminate", &"tologo", &"totitle", &"torecollect",
	&"macro", &"endmacro",
]

var scenario_directory := DEFAULT_SCENARIO_DIRECTORY
var current_scenario_id: String = ""
var current_anchor: String = ""
var local_flags: Dictionary = {}
var global_flags: Dictionary = {}
var parameters: Dictionary = {}
var read_text_ids: Array[String] = []
var is_recollection := false

var _parser := KrkrScenarioParser.new()
var _document: KrkrScenarioDocument
var _instruction_index := 0
var _pause_reason: PauseReason = PauseReason.NONE
var _speaker := ""
var _voice_id := ""
var _message_lines: Array[String] = []
var _pending_choices: Array[Dictionary] = []
var _selected_choice := 0
## One-based selection results for the current scenario. The source ADV saves
## this list and replays it while returning to a saved Hitret boundary.
var _choice_history: Array[int] = []
var _condition_stack: Array[Dictionary] = []
var _scenario_paths: Dictionary = {}
var _macro_definitions: Dictionary = {}
var _injected_instructions: Array[KrkrScenarioInstruction] = []
var _wait_generation := 0
var _wait_cancellable := false
var _external_wait_reason: StringName = &""
var _external_cancellable := false
var _anchor_restore_active := false
var _anchor_restore_target_id := ""
var _anchor_restore_choice_index := 0
var _anchor_restore_local_flags: Dictionary = {}
var _anchor_restore_global_flags: Dictionary = {}
var _anchor_restore_parameters: Dictionary = {}


func configure(directory: String = DEFAULT_SCENARIO_DIRECTORY) -> void:
	scenario_directory = directory.trim_suffix("/")
	_rebuild_scenario_catalog()
	_rebuild_macro_definitions()


func handles(tag_name: StringName) -> bool:
	return tag_name in CONTROL_TAGS or _macro_definitions.has(tag_name)


func start_scenario(
		scenario_id: String,
		anchor: String = "",
		save_data: SaveData = null,
		recollection: bool = false,
		start_label: String = ""
) -> bool:
	_reset_playback_state()
	is_recollection = recollection
	if save_data != null:
		local_flags = save_data.local_flags.duplicate(true)
		global_flags = save_data.global_flags.duplicate(true)
		parameters = save_data.scenario_parameters.duplicate(true)
		read_text_ids = save_data.read_text_ids.duplicate()
	if not _load_document(scenario_id, start_label):
		return false
	if save_data != null:
		_choice_history = save_data.choice_history.duplicate()
	if not anchor.is_empty():
		if not _restore_anchor(anchor):
			_emit_error("剧本 %s 中不存在存档锚点 %s。" % [scenario_id, anchor])
			return false
		return true
	_run_until_pause()
	return true


func advance() -> void:
	match _pause_reason:
		PauseReason.DIALOGUE:
			_pause_reason = PauseReason.NONE
			_run_until_pause()
		PauseReason.TIMER:
			if not _wait_cancellable:
				return
			_wait_generation += 1
			_pause_reason = PauseReason.NONE
			_run_until_pause()
		PauseReason.EXTERNAL:
			if _external_cancellable:
				external_skip_requested.emit(_external_wait_reason)


func suspend_external(wait_reason: StringName, cancellable: bool = true) -> bool:
	if _pause_reason != PauseReason.NONE:
		return false
	_external_wait_reason = wait_reason
	_external_cancellable = cancellable
	_pause_reason = PauseReason.EXTERNAL
	external_wait_started.emit(wait_reason, cancellable)
	return true


func resume_external(wait_reason: StringName = &"") -> void:
	if _pause_reason != PauseReason.EXTERNAL:
		return
	if not wait_reason.is_empty() and wait_reason != _external_wait_reason:
		return
	_external_wait_reason = &""
	_external_cancellable = false
	_pause_reason = PauseReason.NONE
	_run_until_pause()


func choose(choice_index: int) -> void:
	if _pause_reason != PauseReason.CHOICE:
		return
	if choice_index < 0 or choice_index >= _pending_choices.size():
		_emit_nonfatal_error("选项索引越界：%d" % choice_index)
		return
	var choice := _pending_choices[choice_index]
	if bool(choice.get("disabled", false)):
		_emit_nonfatal_error("不能选择已禁用的选项：%d" % choice_index)
		return
	_selected_choice = choice_index + 1
	_choice_history.append(_selected_choice)
	_pending_choices.clear()
	_injected_instructions.clear()
	_pause_reason = PauseReason.NONE
	var target := str(choice.get("target", ""))
	var label := str(choice.get("label", ""))
	if not target.is_empty():
		_load_document(target, label)
	elif not label.is_empty():
		var label_index := _document.instruction_index_for_label(label)
		if label_index < 0:
			_emit_error("选项目标标签不存在：%s" % label)
			return
		_instruction_index = label_index + 1
	_run_until_pause()


func pause_reason() -> PauseReason:
	return _pause_reason


func is_waiting_for_dialogue() -> bool:
	return _pause_reason == PauseReason.DIALOGUE


func is_waiting_for_choice() -> bool:
	return _pause_reason == PauseReason.CHOICE


func is_waiting_external(wait_reason: StringName = &"") -> bool:
	if _pause_reason != PauseReason.EXTERNAL:
		return false
	return wait_reason.is_empty() or wait_reason == _external_wait_reason


func external_wait_reason() -> StringName:
	return _external_wait_reason


func current_instruction_index() -> int:
	return _instruction_index


func current_document() -> KrkrScenarioDocument:
	return _document


func current_speaker() -> String:
	return _speaker


func current_voice_id() -> String:
	return _voice_id


func build_save_data(content_version: String = "") -> SaveData:
	var data := SaveData.create_empty(content_version)
	data.scenario_id = current_scenario_id
	data.instruction_anchor = current_anchor
	data.local_flags = local_flags.duplicate(true)
	data.global_flags = global_flags.duplicate(true)
	data.scenario_parameters = parameters.duplicate(true)
	data.choice_history = _choice_history.duplicate()
	data.read_text_ids = read_text_ids.duplicate()
	return data


## Captures the exact in-memory instruction cursor used by ADV-only navigation.
## Unlike SaveData this checkpoint is deliberately session-local: persistent
## saves continue to use stable Hitret anchors and contain no parser internals.
func build_navigation_checkpoint() -> Dictionary:
	if _document == null or _pause_reason not in [PauseReason.DIALOGUE, PauseReason.CHOICE]:
		return {}
	return {
		"scenario_id": current_scenario_id,
		"instruction_index": _instruction_index,
		"pause_reason": int(_pause_reason),
		"current_anchor": current_anchor,
		"local_flags": local_flags.duplicate(true),
		"global_flags": global_flags.duplicate(true),
		"parameters": parameters.duplicate(true),
		"read_text_ids": read_text_ids.duplicate(),
		"speaker": _speaker,
		"voice_id": _voice_id,
		"message_lines": _message_lines.duplicate(),
		"pending_choices": _pending_choices.duplicate(true),
		"selected_choice": _selected_choice,
		"choice_history": _choice_history.duplicate(),
		"condition_stack": _condition_stack.duplicate(true),
		"is_recollection": is_recollection,
	}


## Restores an exact session-local dialogue/choice boundary. The method emits
## the same typed boundary signal as normal playback so presentation code has a
## single update path.
func restore_navigation_checkpoint(checkpoint: Dictionary) -> bool:
	if checkpoint.is_empty():
		return false
	# Read state is profile-like progress and must not roll back when returning to
	# an earlier choice. Persisted choice checkpoints intentionally omit this
	# potentially large array and inherit the current runtime's accumulated set.
	var accumulated_read_text_ids := read_text_ids.duplicate()
	var scenario_id := str(checkpoint.get("scenario_id", ""))
	var instruction_index := int(checkpoint.get("instruction_index", -1))
	var restored_pause := int(checkpoint.get("pause_reason", PauseReason.NONE))
	if scenario_id.is_empty() or instruction_index < 0:
		return false
	if restored_pause not in [PauseReason.DIALOGUE, PauseReason.CHOICE]:
		return false

	_reset_playback_state()
	is_recollection = bool(checkpoint.get("is_recollection", false))
	if not _load_document(scenario_id):
		return false
	if _document == null or instruction_index > _document.instructions.size():
		_emit_error("导航检查点超出剧本范围：%s / %d。" % [scenario_id, instruction_index])
		return false

	_instruction_index = instruction_index
	current_anchor = str(checkpoint.get("current_anchor", ""))
	local_flags = _dictionary_copy(checkpoint.get("local_flags", {}))
	global_flags = _dictionary_copy(checkpoint.get("global_flags", {}))
	parameters = _dictionary_copy(checkpoint.get("parameters", {}))
	read_text_ids = _string_array_copy(
		checkpoint.get("read_text_ids", accumulated_read_text_ids)
	)
	merge_read_text_ids(accumulated_read_text_ids)
	_speaker = str(checkpoint.get("speaker", ""))
	_voice_id = str(checkpoint.get("voice_id", ""))
	_message_lines = _string_array_copy(checkpoint.get("message_lines", []))
	_pending_choices = _dictionary_array_copy(checkpoint.get("pending_choices", []))
	_selected_choice = int(checkpoint.get("selected_choice", 0))
	_choice_history = _int_array_copy(checkpoint.get("choice_history", []))
	_condition_stack = _dictionary_array_copy(checkpoint.get("condition_stack", []))
	_pause_reason = restored_pause

	if restored_pause == PauseReason.CHOICE:
		if _pending_choices.is_empty():
			return false
		choices_ready.emit(_pending_choices.duplicate(true))
	else:
		var message := "\n".join(_message_lines)
		if message.ends_with("／"):
			message = message.trim_suffix("／")
		dialogue_ready.emit(
			_display_speaker(_speaker),
			message,
			_voice_id,
			current_anchor,
			true
		)
	return true


## Selection-jump scanning must not wait in real time for a KRKR Wait tag.
## Normal input still respects the original cancellable flag through advance().
func finish_timer_wait_for_navigation() -> bool:
	if _pause_reason != PauseReason.TIMER:
		return false
	_wait_generation += 1
	_wait_cancellable = false
	_pause_reason = PauseReason.NONE
	_run_until_pause()
	return true


func merge_read_text_ids(source: Array[String]) -> void:
	for read_id in source:
		if not read_text_ids.has(read_id):
			read_text_ids.append(read_id)


func _dictionary_copy(value: Variant) -> Dictionary:
	return value.duplicate(true) if value is Dictionary else {}


func _string_array_copy(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item in value:
			result.append(str(item))
	return result


func _dictionary_array_copy(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if value is Array:
		for item in value:
			if item is Dictionary:
				result.append(item.duplicate(true))
	return result


func _int_array_copy(value: Variant) -> Array[int]:
	var result: Array[int] = []
	if value is Array:
		for item in value:
			result.append(int(item))
	return result


func _reset_playback_state() -> void:
	_wait_generation += 1
	_wait_cancellable = false
	_external_wait_reason = &""
	_external_cancellable = false
	_document = null
	_instruction_index = 0
	_pause_reason = PauseReason.NONE
	current_scenario_id = ""
	current_anchor = ""
	local_flags = {}
	global_flags = {}
	parameters = {}
	read_text_ids = []
	_speaker = ""
	_voice_id = ""
	_message_lines.clear()
	_pending_choices.clear()
	_selected_choice = 0
	_choice_history.clear()
	_condition_stack.clear()
	_clear_anchor_restore_state()


func _run_until_pause() -> void:
	var processed := 0
	while _pause_reason == PauseReason.NONE:
		processed += 1
		if processed > MAX_INSTRUCTIONS_PER_TICK:
			_emit_error("剧本连续执行超过安全上限，可能存在无等待跳转循环：%s" % current_scenario_id)
			return
		if _injected_instructions.is_empty() and (
			_document == null or _instruction_index >= _document.instructions.size()
		):
			_finish_playback()
			return
		var instruction: KrkrScenarioInstruction
		if not _injected_instructions.is_empty():
			instruction = _injected_instructions.pop_front()
		else:
			instruction = _document.instructions[_instruction_index]
			_instruction_index += 1
		_execute_instruction(instruction)


func _execute_instruction(instruction: KrkrScenarioInstruction) -> void:
	if instruction.kind == KrkrScenarioInstruction.Kind.LABEL:
		return
	if instruction.kind == KrkrScenarioInstruction.Kind.TEXT:
		if _is_branch_active():
			_message_lines.append(instruction.text)
		return

	var tag := String(instruction.tag_name)
	if tag in ["if", "elsif", "else", "endif"]:
		_execute_condition(instruction)
		return
	if not _is_branch_active():
		return

	match tag:
		"talk":
			_speaker = instruction.string_argument("name")
			_voice_id = instruction.string_argument("voice")
			_message_lines.clear()
		"hitret":
			if _anchor_restore_active:
				_restore_hitret(instruction)
			else:
				_pause_for_dialogue(instruction)
		"change":
			var destination := _change_destination(instruction)
			var target := str(destination.target)
			var label := str(destination.label)
			if not _load_document(target, label):
				return
		"addselect":
			_pending_choices.append({
				"text": instruction.string_argument("text"),
				"hint": instruction.string_argument("hint"),
				"target": instruction.string_argument("target"),
				"label": instruction.string_argument("label"),
				"disabled": instruction.has_flag("invalid") or not _choice_flag_is_enabled(instruction),
			})
		"startselect":
			parameters["select_terminated"] = instruction.has_flag("terminate")
			if _anchor_restore_active:
				_replay_saved_choice()
			else:
				_pause_for_choices()
		"selectterminate":
			parameters["select_terminated"] = true
		"onflag":
			local_flags[str(instruction.int_argument("id"))] = true
		"offflag":
			local_flags[str(instruction.int_argument("id"))] = false
		"onglobalflag":
			global_flags[str(instruction.int_argument("id"))] = true
		"offglobalflag":
			global_flags[str(instruction.int_argument("id"))] = false
		"setparam":
			_apply_parameter(instruction.string_argument("arg"), false)
		"addparam":
			_apply_parameter(instruction.string_argument("arg"), true)
		"clearparam":
			parameters.clear()
		"wait":
			if not _anchor_restore_active:
				instruction_executed.emit(instruction)
				_start_wait(instruction)
		"playmovie", "staffroll":
			if not _anchor_restore_active:
				suspend_external(&"movie", true)
				instruction_executed.emit(instruction)
		"recollect":
			if not _anchor_restore_active:
				instruction_executed.emit(instruction)
				if is_recollection:
					_finish_playback()
				else:
					var recollection_id := instruction.int_argument("id", -1)
					if recollection_id >= 0:
						global_flags[str(recollection_id)] = true
		"terminate", "tologo", "totitle", "torecollect":
			if not _anchor_restore_active:
				instruction_executed.emit(instruction)
				_finish_playback()
		"macro", "endmacro":
			pass
		_:
			if not _expand_macro(instruction):
				if not _anchor_restore_active:
					instruction_executed.emit(instruction)


func _pause_for_dialogue(instruction: KrkrScenarioInstruction) -> void:
	var hitret_id := instruction.string_argument("id", str(instruction.line_number))
	current_anchor = "hitret:%s" % hitret_id
	var read_key := "%s:%s" % [current_scenario_id, hitret_id]
	var was_read := read_text_ids.has(read_key)
	if not was_read:
		read_text_ids.append(read_key)
	var message := "\n".join(_message_lines)
	var newline := message.ends_with("／")
	if newline:
		message = message.trim_suffix("／")
	var display_speaker := _display_speaker(_speaker)
	_pause_reason = PauseReason.DIALOGUE
	dialogue_ready.emit(
		display_speaker,
		message,
		_voice_id,
		current_anchor,
		was_read
	)


func _pause_for_choices() -> void:
	if _pending_choices.is_empty():
		_emit_error("StartSelect 前没有 AddSelect。")
		return
	_pause_reason = PauseReason.CHOICE
	choices_ready.emit(_pending_choices.duplicate(true))


func _start_wait(instruction: KrkrScenarioInstruction) -> void:
	var milliseconds := maxi(instruction.int_argument("time"), 0)
	if milliseconds <= 0:
		return
	# In the source engine the presence of HitCancel disables click-to-finish.
	var cancellable := not instruction.has_flag("hitcancel")
	_wait_cancellable = cancellable
	_pause_reason = PauseReason.TIMER
	_wait_generation += 1
	var generation := _wait_generation
	wait_started.emit(milliseconds, cancellable)
	get_tree().create_timer(float(milliseconds) / 1000.0).timeout.connect(
		func() -> void:
			if generation != _wait_generation or _pause_reason != PauseReason.TIMER:
				return
			_pause_reason = PauseReason.NONE
			_run_until_pause()
	)


func _execute_condition(instruction: KrkrScenarioInstruction) -> void:
	var tag := String(instruction.tag_name)
	match tag:
		"if":
			var parent_active := _is_branch_active()
			var matched := parent_active and _evaluate_expression(instruction.string_argument("exp"))
			_condition_stack.append({
				"parent_active": parent_active,
				"matched": matched,
				"active": matched,
			})
		"elsif":
			if _condition_stack.is_empty():
				_emit_error("第 %d 行出现没有 if 的 elsif。" % instruction.line_number)
				return
			var frame := _condition_stack[-1]
			var active := bool(frame.parent_active) and not bool(frame.matched)
			active = active and _evaluate_expression(instruction.string_argument("exp"))
			frame.active = active
			frame.matched = bool(frame.matched) or active
			_condition_stack[-1] = frame
		"else":
			if _condition_stack.is_empty():
				_emit_error("第 %d 行出现没有 if 的 else。" % instruction.line_number)
				return
			var frame := _condition_stack[-1]
			frame.active = bool(frame.parent_active) and not bool(frame.matched)
			frame.matched = true
			_condition_stack[-1] = frame
		"endif":
			if _condition_stack.is_empty():
				_emit_error("第 %d 行出现没有 if 的 endif。" % instruction.line_number)
				return
			_condition_stack.pop_back()


func _is_branch_active() -> bool:
	return _condition_stack.is_empty() or bool(_condition_stack[-1].active)


func _evaluate_expression(expression: String) -> bool:
	var value := expression.strip_edges()
	if value.begins_with("(") and value.ends_with(")"):
		value = value.substr(1, value.length() - 2).strip_edges()
	if value.contains("||"):
		for part in value.split("||"):
			if _evaluate_expression(part):
				return true
		return false
	if value.contains("&&"):
		for part in value.split("&&"):
			if not _evaluate_expression(part):
				return false
		return true
	if value.begins_with("!"):
		return not _evaluate_expression(value.substr(1))
	if value.to_lower() == "true":
		return true
	if value.to_lower() == "false" or value.is_empty():
		return false
	if value.begins_with("IsRecollect("):
		return is_recollection
	if value.begins_with("ChkFlagOn("):
		return bool(local_flags.get(str(_function_int_argument(value)), false))
	if value.begins_with("ChkGlobalFlagOn("):
		return bool(global_flags.get(str(_function_int_argument(value)), false))
	if value.begins_with("ChkSelect("):
		return _selected_choice == _function_int_argument(value)
	_emit_error("暂不支持的 KRKR 条件表达式：%s" % expression)
	return false


func _function_int_argument(expression: String) -> int:
	var open_index := expression.find("(")
	var close_index := expression.rfind(")")
	if open_index < 0 or close_index <= open_index:
		return 0
	return expression.substr(open_index + 1, close_index - open_index - 1).strip_edges().to_int()


func _apply_parameter(argument: String, additive: bool) -> void:
	var parts := argument.split(",", false, 1)
	if parts.size() != 2:
		_emit_error("参数指令 arg 格式无效：%s" % argument)
		return
	var key := parts[0].strip_edges()
	var value := parts[1].strip_edges()
	if additive:
		parameters[key] = float(parameters.get(key, 0.0)) + value.to_float()
	else:
		parameters[key] = value


func _choice_flag_is_enabled(instruction: KrkrScenarioInstruction) -> bool:
	if not instruction.arguments.has("flag"):
		return true
	var flag_id := instruction.int_argument("flag")
	return flag_id == 0 or bool(local_flags.get(str(flag_id), false))


func _change_destination(instruction: KrkrScenarioInstruction) -> Dictionary:
	var target := instruction.string_argument("target")
	var label := instruction.string_argument("label")
	if label.is_empty() and target.contains(",/"):
		var parts := target.split(",/", false, 1)
		target = parts[0]
		label = parts[1] if parts.size() > 1 else ""
	target = _resolve_common_route_target(target)
	return {"target": target, "label": label.trim_prefix("*")}


func _resolve_common_route_target(target: String) -> String:
	var normalized := target.strip_edges().get_file().get_basename().to_lower()
	if normalized != "00_z015" and normalized != "00_e000":
		return target
	var route_targets := {
		"1": "00_a001",
		"2": "00_b001",
		"3": "00_c001",
		"4": "00_d001",
	}
	for flag_id in ["1", "2", "3", "4"]:
		if bool(local_flags.get(flag_id, false)):
			return str(route_targets[flag_id])
	return target


func _display_speaker(source_name: String) -> String:
	var names := source_name.split("/", false, 1)
	return names[1] if names.size() > 1 else source_name


func _load_document(scenario_id: String, label: String = "") -> bool:
	if _scenario_paths.is_empty():
		_rebuild_scenario_catalog()
	var normalized_id := scenario_id.strip_edges().get_file().get_basename().to_lower()
	var path := str(_scenario_paths.get(normalized_id, ""))
	if path.is_empty():
		_emit_error("找不到 KRKR 剧本：%s" % scenario_id)
		return false
	var document := _parser.parse_file(path, path.get_file().get_basename())
	if document == null or not _parser.last_errors.is_empty():
		_emit_error("解析 %s 失败：%s" % [path, "；".join(_parser.last_errors)])
		return false
	_document = document
	current_scenario_id = document.scenario_id
	_instruction_index = 0
	_injected_instructions.clear()
	_condition_stack.clear()
	_choice_history.clear()
	_speaker = ""
	_voice_id = ""
	_message_lines.clear()
	if not label.is_empty():
		var label_index := document.instruction_index_for_label(label)
		if label_index < 0:
			_emit_error("剧本 %s 中不存在标签 %s。" % [scenario_id, label])
			return false
		_instruction_index = label_index + 1
	scenario_changed.emit(current_scenario_id)
	return true


func _restore_anchor(anchor: String) -> bool:
	if _document == null:
		return false
	var requested_id := anchor.trim_prefix("hitret:")
	var target_index := _hitret_instruction_index(requested_id)
	if target_index < 0:
		return false

	# The source engine does not seek directly to a saved line. It starts the
	# current scenario again, skips prior Hitret boundaries and replays its saved
	# one-based selection log. That rebuilds the KAG if/elsif/endif stack exactly
	# before the saved dialogue is exposed. Presentation commands stay silent;
	# AdvScreen restores their saved snapshot independently.
	if _choice_history.is_empty():
		# Saves written by schema 2 predate the source selection log. The shipped
		# corpus has four direct ChkSelect blocks, so their branch at the saved
		# anchor can be recovered once and then persisted in schema 3.
		_choice_history = _infer_legacy_choice_history(target_index)
	_anchor_restore_active = true
	_anchor_restore_target_id = requested_id
	_anchor_restore_choice_index = 0
	_anchor_restore_local_flags = local_flags.duplicate(true)
	_anchor_restore_global_flags = global_flags.duplicate(true)
	_anchor_restore_parameters = parameters.duplicate(true)
	_instruction_index = 0
	_injected_instructions.clear()
	_condition_stack.clear()
	_pending_choices.clear()
	_selected_choice = 0
	_speaker = ""
	_voice_id = ""
	_message_lines.clear()
	current_anchor = ""
	_pause_reason = PauseReason.NONE
	_run_until_pause()
	var restored := (
		not _anchor_restore_active
		and _pause_reason == PauseReason.DIALOGUE
		and current_anchor == "hitret:%s" % requested_id
	)
	if not restored:
		_clear_anchor_restore_state()
	return restored


func _hitret_instruction_index(requested_id: String) -> int:
	for index in _document.instructions.size():
		var instruction := _document.instructions[index]
		if (
			instruction.kind == KrkrScenarioInstruction.Kind.TAG
			and instruction.tag_name == &"hitret"
			and instruction.string_argument("id") == requested_id
		):
			return index
	return -1


func _restore_hitret(instruction: KrkrScenarioInstruction) -> void:
	if instruction.string_argument("id") != _anchor_restore_target_id:
		return
	local_flags = _anchor_restore_local_flags.duplicate(true)
	global_flags = _anchor_restore_global_flags.duplicate(true)
	parameters = _anchor_restore_parameters.duplicate(true)
	_anchor_restore_active = false
	_anchor_restore_target_id = ""
	_anchor_restore_choice_index = 0
	_anchor_restore_local_flags.clear()
	_anchor_restore_global_flags.clear()
	_anchor_restore_parameters.clear()
	_pause_for_dialogue(instruction)


func _replay_saved_choice() -> void:
	if _anchor_restore_choice_index >= _choice_history.size():
		_emit_error("存档缺少返回 %s 所需的选项记录。" % _anchor_restore_target_id)
		return
	var selected_number := _choice_history[_anchor_restore_choice_index]
	_anchor_restore_choice_index += 1
	if selected_number <= 0 or selected_number > _pending_choices.size():
		_emit_error("存档中的选项记录越界：%d。" % selected_number)
		return
	_selected_choice = selected_number
	var choice := _pending_choices[selected_number - 1]
	_pending_choices.clear()
	var target := str(choice.get("target", ""))
	var label := str(choice.get("label", ""))
	if not target.is_empty():
		_load_document(target, label)
	elif not label.is_empty():
		var label_index := _document.instruction_index_for_label(label)
		if label_index < 0:
			_emit_error("存档选项目标标签不存在：%s" % label)
			return
		_instruction_index = label_index + 1


func _infer_legacy_choice_history(target_index: int) -> Array[int]:
	var result: Array[int] = []
	var pending_choice_slot := -1
	for index in mini(target_index + 1, _document.instructions.size()):
		var instruction := _document.instructions[index]
		if instruction.kind != KrkrScenarioInstruction.Kind.TAG:
			continue
		match instruction.tag_name:
			&"startselect":
				result.append(1)
				pending_choice_slot = result.size() - 1
			&"if", &"elsif":
				if pending_choice_slot < 0:
					continue
				var selected_number := _choice_number_from_expression(
					instruction.string_argument("exp")
				)
				if selected_number > 0:
					result[pending_choice_slot] = selected_number
	return result


func _choice_number_from_expression(expression: String) -> int:
	var normalized := expression.strip_edges()
	var marker_index := normalized.find("ChkSelect(")
	if marker_index < 0:
		return 0
	var open_index := normalized.find("(", marker_index)
	var close_index := normalized.find(")", open_index + 1)
	if open_index < 0 or close_index <= open_index:
		return 0
	var number := normalized.substr(open_index + 1, close_index - open_index - 1).strip_edges()
	return number.to_int() if number.is_valid_int() else 0


func _clear_anchor_restore_state() -> void:
	_anchor_restore_active = false
	_anchor_restore_target_id = ""
	_anchor_restore_choice_index = 0
	_anchor_restore_local_flags.clear()
	_anchor_restore_global_flags.clear()
	_anchor_restore_parameters.clear()


func _message_before(hitret_index: int) -> Dictionary:
	var speaker := ""
	var voice := ""
	var lines: Array[String] = []
	var index := hitret_index - 1
	while index >= 0:
		var instruction := _document.instructions[index]
		if instruction.kind == KrkrScenarioInstruction.Kind.TAG:
			if instruction.tag_name == &"talk":
				speaker = instruction.string_argument("name")
				voice = instruction.string_argument("voice")
				break
			if instruction.tag_name == &"hitret":
				break
		elif instruction.kind == KrkrScenarioInstruction.Kind.TEXT:
			lines.push_front(instruction.text)
		index -= 1
	var text := "\n".join(lines)
	if text.ends_with("／"):
		text = text.trim_suffix("／")
	return {"speaker": _display_speaker(speaker), "voice": voice, "text": text}


func _rebuild_scenario_catalog() -> void:
	_scenario_paths.clear()
	var directory := DirAccess.open(scenario_directory)
	if directory == null:
		return
	for file_name in directory.get_files():
		if file_name.get_extension().to_lower() != "ks":
			continue
		_scenario_paths[file_name.get_basename().to_lower()] = "%s/%s" % [scenario_directory, file_name]


func _rebuild_macro_definitions() -> void:
	_macro_definitions.clear()
	var macro_path := "%s/macro.ks" % scenario_directory
	if not FileAccess.file_exists(macro_path):
		return
	var document := _parser.parse_file(macro_path, "macro")
	if document == null or not _parser.last_errors.is_empty():
		return
	var active_name: StringName = &""
	var active_body: Array[KrkrScenarioInstruction] = []
	for instruction in document.instructions:
		if instruction.kind != KrkrScenarioInstruction.Kind.TAG:
			if not active_name.is_empty():
				active_body.append(instruction)
			continue
		if instruction.tag_name == &"macro":
			active_name = StringName(instruction.string_argument("name").to_lower())
			active_body = []
			continue
		if instruction.tag_name == &"endmacro":
			if not active_name.is_empty():
				_macro_definitions[active_name] = active_body.duplicate()
			active_name = &""
			active_body = []
			continue
		if not active_name.is_empty():
			active_body.append(instruction)


func _expand_macro(invocation: KrkrScenarioInstruction) -> bool:
	var body: Variant = _macro_definitions.get(invocation.tag_name)
	if not body is Array:
		return false
	var expanded: Array[KrkrScenarioInstruction] = []
	for source_instruction in body:
		expanded.append(_clone_macro_instruction(source_instruction, invocation.arguments))
	expanded.append_array(_injected_instructions)
	_injected_instructions = expanded
	return true


func _clone_macro_instruction(
		source: KrkrScenarioInstruction,
		invocation_arguments: Dictionary
) -> KrkrScenarioInstruction:
	if source.kind == KrkrScenarioInstruction.Kind.TEXT:
		return KrkrScenarioInstruction.message(
			_substitute_macro_value(source.text, invocation_arguments),
			source.line_number,
			source.raw_line
		)
	if source.kind == KrkrScenarioInstruction.Kind.LABEL:
		return KrkrScenarioInstruction.label(
			_substitute_macro_value(source.text, invocation_arguments),
			source.line_number,
			source.raw_line
		)
	var arguments: Dictionary = {}
	for key in source.arguments:
		arguments[key] = _substitute_macro_value(str(source.arguments[key]), invocation_arguments)
	return KrkrScenarioInstruction.tag(
		source.tag_name,
		arguments,
		source.flags.duplicate(),
		source.line_number,
		source.raw_line
	)


func _substitute_macro_value(value: String, invocation_arguments: Dictionary) -> String:
	var result := value
	for key in invocation_arguments:
		result = result.replace("%%%s" % str(key), str(invocation_arguments[key]))
	return result


func _finish_playback() -> void:
	if _pause_reason == PauseReason.FINISHED:
		return
	_pause_reason = PauseReason.FINISHED
	playback_finished.emit()


func _emit_error(message: String) -> void:
	_pause_reason = PauseReason.FINISHED
	runtime_error.emit(message)


func _emit_nonfatal_error(message: String) -> void:
	runtime_error.emit(message)

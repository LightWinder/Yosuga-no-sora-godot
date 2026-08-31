extends SceneTree


const SCENARIO_DIRECTORY := "res://assets/scenario"

var _failures: Array[String] = []


func _initialize() -> void:
	_test_parser_contract()
	_test_runtime_contract()
	_test_asset_and_request_contract()
	if _failures.is_empty():
		print("KRKR scenario parser/runtime test passed.")
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)


func _test_parser_contract() -> void:
	var parser := KrkrScenarioParser.new()
	var directory := DirAccess.open(SCENARIO_DIRECTORY)
	_expect(directory != null, "Scenario directory must be readable.")
	if directory == null:
		return
	var files: Array[String] = []
	for file_name in directory.get_files():
		if file_name.get_extension().to_lower() == "ks":
			files.append(file_name)
	files.sort()
	_expect(files.size() == 306, "All 306 converted KRKR scenarios must ship with the project.")

	var talk_count := 0
	var hitret_count := 0
	var change_count := 0
	var corpus_tags: Dictionary = {}
	var corpus_actions: Dictionary = {}
	var message_frame_types: Dictionary = {}
	var tone_types: Dictionary = {}
	var eye_catch_types: Dictionary = {}
	for file_name in files:
		var path := "%s/%s" % [SCENARIO_DIRECTORY, file_name]
		var document := parser.parse_file(path)
		_expect(document != null, "Parser must load %s." % file_name)
		_expect(parser.last_errors.is_empty(), "Parser errors in %s: %s" % [file_name, parser.last_errors])
		if document == null:
			continue
		for instruction in document.instructions:
			if instruction.kind == KrkrScenarioInstruction.Kind.TAG:
				corpus_tags[instruction.tag_name] = true
				match instruction.tag_name:
					&"action":
						corpus_actions[instruction.string_argument("action")] = true
					&"messageframe":
						message_frame_types[instruction.string_argument("type", "0")] = true
					&"tone":
						tone_types[instruction.string_argument("type", "NORMAL").to_upper()] = true
					&"eyecatch":
						eye_catch_types[instruction.string_argument("type", "TIME").to_upper()] = true
		talk_count += document.tag_count(&"talk")
		hitret_count += document.tag_count(&"hitret")
		change_count += document.tag_count(&"change")
	_expect(talk_count == 39344, "Converted corpus must retain all 39,344 Talk tags.")
	_expect(hitret_count == 39344, "Converted corpus must retain all 39,344 Hitret anchors.")
	_expect(change_count == 304, "Converted corpus must retain all 304 scenario changes.")
	var expected_tags: Array[StringName] = [
		&"talk", &"hitret", &"char", &"cg", &"clearchar", &"update",
		&"playse", &"playbgm", &"waitupdate", &"stopbgm", &"blackout",
		&"waitaction", &"hide", &"action", &"change", &"wait", &"eyecatch",
		&"stopenvse", &"move", &"playenvse", &"flash", &"messageframe",
		&"movecamera", &"stopse", &"tone", &"font", &"waitse", &"recollect",
		&"leave", &"if", &"endif", &"waitcamera", &"restartbgm", &"pausebgm",
		&"onglobalflag", &"addselect", &"elsif", &"whiteout", &"autoposition",
		&"setparam", &"bgscroll", &"startselect", &"onflag", &"else",
		&"selectterminate", &"playmovie", &"staffroll", &"macro", &"endmacro",
		&"僗僞僢僼儘乕儖",
	]
	_expect(corpus_tags.size() == expected_tags.size(), "Converted corpus tag vocabulary changed unexpectedly.")
	for tag_name in expected_tags:
		_expect(corpus_tags.has(tag_name), "Converted corpus is missing source tag %s." % tag_name)
	_expect(
		corpus_actions.size() == 4,
		"Source action vocabulary must remain the four migrated action families, found %s." % [corpus_actions.keys()]
	)
	for action_name in corpus_actions:
		_expect(
			AdvStageDirector.handles_action(str(action_name)),
			"Source action %s has no stage implementation." % action_name
		)
	_expect(
		message_frame_types.size() == 2
		and message_frame_types.has("0")
		and message_frame_types.has("1"),
		"Source message-frame vocabulary must remain the normal frame variants 0/1."
	)
	_expect(
		tone_types.size() == 4
		and tone_types.has("NORMAL")
		and tone_types.has("MONOCHROME")
		and tone_types.has("MONO_NEGATIVE")
		and tone_types.has("NEGATIVE"),
		"Source tone vocabulary changed unexpectedly: %s." % [tone_types.keys()]
	)
	_expect(
		eye_catch_types.size() == 2
		and eye_catch_types.has("TIME")
		and eye_catch_types.has("DATE"),
		"Source eye-catch vocabulary must remain TIME/DATE."
	)
	var coverage_runtime := KrkrScenarioRuntime.new()
	coverage_runtime.configure(SCENARIO_DIRECTORY)
	var implemented_tags: Dictionary = {}
	for tag_name in AdvStageDirector.STAGE_TAGS:
		implemented_tags[tag_name] = true
	for tag_name in AdvScreen.PRESENTATION_TAGS:
		implemented_tags[tag_name] = true
	for tag_name in corpus_tags:
		_expect(
			coverage_runtime.handles(tag_name) or implemented_tags.has(tag_name),
			"Source tag %s has no runtime/stage/presentation owner." % tag_name
		)
	coverage_runtime.free()

	var sample := parser.parse_text(
		"@Talk name=\"春日野 悠\" voice=SR000001 flush\n"
		+ "带 空格 的正文\n"
		+ "@Hitret id=42 hitCancel\n"
		+ "*resume|存档标签\n",
		"sample"
	)
	_expect(parser.last_errors.is_empty(), "Quoted parameters and bare flags must parse without errors.")
	_expect(sample.instructions.size() == 4, "Sample parser must preserve tag/text/label instructions.")
	var talk := sample.instructions[0]
	_expect(talk.string_argument("name") == "春日野 悠", "Quoted parameter whitespace must be preserved.")
	_expect(talk.has_flag("flush"), "Bare tag flags must be preserved.")
	var hitret := sample.instructions[2]
	_expect(hitret.int_argument("id") == 42 and hitret.has_flag("hitcancel"), "Numeric arguments and HitCancel must parse.")
	_expect(sample.instruction_index_for_label("resume") == 3, "Document must index labels case-insensitively.")

	var comma_sample := parser.parse_text(
		"@action id=カメラ action=ActionWave width=32, height=0, count=2 cycle=150\n",
		"comma-sample"
	)
	_expect(parser.last_errors.is_empty(), "Comma-separated source parameters must parse without errors.")
	var camera_action := comma_sample.instructions[0]
	_expect(
		camera_action.int_argument("width", -1) == 32
		and camera_action.int_argument("height", -1) == 0
		and camera_action.int_argument("count", -1) == 2,
		"Trailing source commas must not turn numeric action arguments into zero/default values."
	)


func _test_runtime_contract() -> void:
	var runtime := KrkrScenarioRuntime.new()
	runtime.name = "KrkrScenarioRuntime"
	root.add_child(runtime)
	runtime.configure(SCENARIO_DIRECTORY)
	var dialogue_events: Array[Dictionary] = []
	var executed_tags: Array[StringName] = []
	var runtime_errors: Array[String] = []
	runtime.dialogue_ready.connect(
		func(speaker: String, message: String, voice_id: String, anchor: String, already_read: bool) -> void:
			dialogue_events.append({
				"speaker": speaker,
				"message": message,
				"voice": voice_id,
				"anchor": anchor,
				"read": already_read,
			})
	)
	runtime.instruction_executed.connect(func(instruction: KrkrScenarioInstruction) -> void: executed_tags.append(instruction.tag_name))
	runtime.runtime_error.connect(func(message: String) -> void: runtime_errors.append(message))

	_expect(runtime.start_scenario("00_z000"), "New Game scenario must start from 00_z000.")
	_expect(runtime_errors.is_empty(), "New Game startup must not produce runtime errors.")
	_expect(dialogue_events.size() == 1, "Runtime must stop on the first Hitret boundary.")
	if not dialogue_events.is_empty():
		var first := dialogue_events[0]
		_expect(first.speaker == "心の声", "First source speaker must be preserved.")
		_expect(str(first.message).begins_with("蔚蓝的天空"), "First source dialogue must be decoded as UTF-8.")
		_expect(first.anchor == "hitret:1", "First source Hitret must become the save anchor.")
	_expect(executed_tags.has(&"playenvse") and executed_tags.has(&"cg"), "Runtime must dispatch visual/audio tags before dialogue.")

	var save := runtime.build_save_data("scenario-contract")
	_expect(save.scenario_id == "00_z000" and save.instruction_anchor == "hitret:1", "Runtime save snapshot must preserve scenario and anchor.")
	runtime.advance()
	_expect(dialogue_events.size() == 2 and dialogue_events[1].anchor == "hitret:2", "Advance must run to exactly the next Hitret.")

	dialogue_events.clear()
	_expect(runtime.start_scenario("00_z000", "hitret:14", save), "Runtime must restore a real source Hitret anchor.")
	_expect(dialogue_events.size() == 1, "Anchor restore must expose the saved dialogue before advancing.")
	if not dialogue_events.is_empty():
		_expect(dialogue_events[0].speaker == "悠", "Anchor restore must recover the preceding Talk speaker.")
		_expect(str(dialogue_events[0].message).contains("不吃点东西"), "Anchor restore must recover the preceding source text.")

	var choice_runtime := KrkrScenarioRuntime.new()
	root.add_child(choice_runtime)
	choice_runtime.configure("res://tests/fixtures/scenario")
	var choice_events: Array[Array] = []
	var choice_dialogue_events: Array[String] = []
	choice_runtime.choices_ready.connect(func(choices: Array[Dictionary]) -> void: choice_events.append(choices))
	choice_runtime.dialogue_ready.connect(
		func(_speaker: String, message: String, _voice: String, _anchor: String, _read: bool) -> void:
			choice_dialogue_events.append(message)
	)
	_expect(choice_runtime.start_scenario("choice"), "Synthetic choice scenario must start.")
	_expect(choice_events.size() == 1 and choice_events[0].size() == 2 and choice_runtime.is_waiting_for_choice(), "StartSelect must pause with both choices.")
	var choice_checkpoint := choice_runtime.build_navigation_checkpoint()
	choice_runtime.choose(1)
	_expect(bool(choice_runtime.local_flags.get("7", false)), "Selected conditional branch must mutate its local flag.")
	_expect(choice_dialogue_events == ["选择成功"], "Selected branch must run to its dialogue boundary.")
	var branch_save := choice_runtime.build_save_data("choice-restore")
	_expect(
		branch_save.choice_history == [2],
		"Runtime saves must retain the source ADV's one-based selection log."
	)
	_expect(
		choice_runtime.restore_navigation_checkpoint(choice_checkpoint)
		and choice_runtime.is_waiting_for_choice()
		and choice_events.size() == 2,
		"Session navigation checkpoints must restore the exact choice cursor without replaying the prior Hitret."
	)
	choice_runtime.choose(0)
	_expect(
		not bool(choice_runtime.local_flags.get("7", false)),
		"Restoring a choice checkpoint must also restore pre-branch flags."
	)
	choice_runtime.free()

	var restored_branch_runtime := KrkrScenarioRuntime.new()
	root.add_child(restored_branch_runtime)
	restored_branch_runtime.configure("res://tests/fixtures/scenario")
	var restored_branch_errors: Array[String] = []
	var restored_branch_dialogue: Array[String] = []
	restored_branch_runtime.runtime_error.connect(
		func(message: String) -> void: restored_branch_errors.append(message)
	)
	restored_branch_runtime.dialogue_ready.connect(
		func(_speaker: String, message: String, _voice: String, _anchor: String, _read: bool) -> void:
			restored_branch_dialogue.append(message)
	)
	_expect(
		restored_branch_runtime.start_scenario("choice", branch_save.instruction_anchor, branch_save),
		"Loading inside a selected branch must replay the source selection log to its Hitret."
	)
	restored_branch_runtime.advance()
	_expect(
		restored_branch_errors.is_empty()
		and restored_branch_dialogue == ["选择成功"]
		and restored_branch_runtime.pause_reason() == KrkrScenarioRuntime.PauseReason.FINISHED,
		"A restored branch must cross its closing endif without stalling."
	)
	restored_branch_runtime.free()

	# Schema-2 saves did not contain the source selection log. Preserve them by
	# inferring the enclosing ChkSelect branch once during migration.
	var legacy_branch_save := SaveData.create_empty("legacy-choice-restore")
	legacy_branch_save.scenario_id = "00_z008"
	legacy_branch_save.instruction_anchor = "hitret:1194"
	var legacy_branch_runtime := KrkrScenarioRuntime.new()
	root.add_child(legacy_branch_runtime)
	legacy_branch_runtime.configure(SCENARIO_DIRECTORY)
	var legacy_branch_errors: Array[String] = []
	var legacy_branch_dialogue: Array[String] = []
	legacy_branch_runtime.runtime_error.connect(
		func(message: String) -> void: legacy_branch_errors.append(message)
	)
	legacy_branch_runtime.dialogue_ready.connect(
		func(_speaker: String, message: String, _voice: String, _anchor: String, _read: bool) -> void:
			legacy_branch_dialogue.append(message)
	)
	_expect(
		legacy_branch_runtime.start_scenario(
			legacy_branch_save.scenario_id,
			legacy_branch_save.instruction_anchor,
			legacy_branch_save
		),
		"A legacy save inside 00_z008's second choice branch must still load."
	)
	legacy_branch_runtime.advance()
	_expect(
		legacy_branch_errors.is_empty()
		and legacy_branch_dialogue == ["嗯，谢谢。", "好了，到了哦。"],
		"The exact 00_z008 save boundary must continue past line 336 without an orphan endif."
	)
	legacy_branch_runtime.free()
	runtime.free()


func _test_asset_and_request_contract() -> void:
	var resolver := AdvAssetResolver.new()
	resolver.rebuild()
	_expect(resolver.texture_for_cg("b27a") != null, "ADV resolver must match imported backgrounds case-insensitively.")
	_expect(resolver.texture_for_cg("ea01E") != null, "ADV resolver must reuse existing event artwork.")
	_expect(resolver.texture_for_character("ca02_01m") != null, "ADV resolver must load opening character artwork.")
	_expect(resolver.stream_for_voice("sr000001") != null, "ADV resolver must load opening voice resources.")
	_expect(resolver.stream_for_bgm("bgm05") != null, "ADV resolver must reuse the shared BGM directory.")
	_expect(resolver.path_for_video("YOSUGACN").ends_with("yosugacn.ogv"), "ADV resolver must match OGV videos case-insensitively.")
	var new_game := ScenarioLaunchRequest.new_game()
	_expect(new_game.is_new_game() and new_game.scenario_id == "00_z000", "New Game request must target the source entry scenario.")
	var recollection := ScenarioLaunchRequest.for_recollection("01_z010", "测试回想", 1)
	_expect(recollection.is_recollection() and recollection.start_label == "recollect", "Recollections must enter through their source recollect label.")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)

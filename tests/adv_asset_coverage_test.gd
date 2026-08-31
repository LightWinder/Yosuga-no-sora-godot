extends SceneTree


const SCENARIO_DIRECTORY := "res://assets/scenario"
const EXPECTED_SCENARIO_COUNT := 306
const STAFF_ROLL_ASSETS: Array[String] = [
	"staff_roll_sora",
	"staff_roll_nao",
	"staff_roll_akira",
	"staff_roll_kazuha",
	"staff_roll_motoka",
]

var _failures: Array[String] = []
var _missing_references: Dictionary = {}
var _reference_counts: Dictionary = {
	"background": 0,
	"character": 0,
	"voice": 0,
	"effect": 0,
	"bgm": 0,
	"rule": 0,
	"video": 0,
}


func _initialize() -> void:
	_run()
	if _failures.is_empty():
		print("ADV asset coverage test passed: %s" % _reference_counts)
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)


func _run() -> void:
	var directory := DirAccess.open(SCENARIO_DIRECTORY)
	_expect(directory != null, "Scenario directory must be readable for asset coverage.")
	if directory == null:
		return
	var scenario_files: Array[String] = []
	for file_name in directory.get_files():
		if file_name.get_extension().to_lower() == "ks":
			scenario_files.append(file_name)
	scenario_files.sort()
	_expect(
		scenario_files.size() == EXPECTED_SCENARIO_COUNT,
		"Asset coverage must audit all %d UTF-8 scenarios, found %d." % [
			EXPECTED_SCENARIO_COUNT,
			scenario_files.size(),
		]
	)

	var parser := KrkrScenarioParser.new()
	var resolver := AdvAssetResolver.new()
	resolver.rebuild()
	for file_name in scenario_files:
		var document := parser.parse_file("%s/%s" % [SCENARIO_DIRECTORY, file_name])
		_expect(document != null, "Asset coverage could not parse %s." % file_name)
		_expect(parser.last_errors.is_empty(), "Asset coverage parser errors in %s: %s" % [file_name, parser.last_errors])
		if document == null:
			continue
		for instruction in document.instructions:
			if instruction.kind != KrkrScenarioInstruction.Kind.TAG:
				continue
			_audit_instruction(file_name, instruction, resolver)

	for video_id in STAFF_ROLL_ASSETS:
		_record_reference("video")
		_require_asset("video", video_id, resolver.path_for_video(video_id), "staff-roll mapping")

	if not _missing_references.is_empty():
		var missing_lines: Array[String] = []
		var missing_keys: Array = _missing_references.keys()
		missing_keys.sort()
		for key in missing_keys:
			missing_lines.append("%s (%s)" % [key, _missing_references[key]])
		_failures.append("Scenario assets are missing:\n%s" % "\n".join(missing_lines))


func _audit_instruction(
	scenario_file: String,
	instruction: KrkrScenarioInstruction,
	resolver: AdvAssetResolver
) -> void:
	var source := "%s:%d" % [scenario_file, instruction.line_number]
	match instruction.tag_name:
		&"cg", &"bgscroll":
			var background_id := instruction.string_argument("file")
			if _is_literal_background(background_id):
				return
			_record_reference("background")
			_require_asset("background", background_id, resolver.path_for_cg(background_id), source)
		&"char":
			var character_id := instruction.string_argument("file")
			_record_reference("character")
			_require_asset("character", character_id, resolver.path_for_character(character_id), source)
		&"talk":
			for voice_id in instruction.string_argument("voice").split("/", false):
				var normalized_voice_id := voice_id.strip_edges()
				if normalized_voice_id.is_empty():
					continue
				_record_reference("voice")
				_require_asset("voice", normalized_voice_id, resolver.path_for_voice(normalized_voice_id), source)
		&"playse", &"playenvse":
			var effect_id := instruction.string_argument("file")
			_record_reference("effect")
			_require_asset("effect", effect_id, resolver.path_for_effect(effect_id), source)
		&"playbgm":
			var bgm_id := instruction.string_argument("file")
			_record_reference("bgm")
			_require_asset("bgm", bgm_id, resolver.path_for_bgm(bgm_id), source)
		&"update":
			var rule_id := instruction.string_argument("rule")
			if rule_id.is_empty():
				return
			_record_reference("rule")
			_require_asset("rule", rule_id, resolver.path_for_rule(rule_id), source)
		&"playmovie":
			var video_id := instruction.string_argument("file")
			_record_reference("video")
			_require_asset("video", video_id, resolver.path_for_video(video_id), source)


func _is_literal_background(resource_id: String) -> bool:
	var normalized := resource_id.strip_edges().to_upper()
	if normalized in ["BLACK", "WHITE"]:
		return true
	var channels := resource_id.split(",", false)
	if channels.size() not in [3, 4]:
		return false
	for channel in channels:
		if not channel.strip_edges().is_valid_int():
			return false
	return true


func _record_reference(kind: String) -> void:
	_reference_counts[kind] = int(_reference_counts.get(kind, 0)) + 1


func _require_asset(kind: String, resource_id: String, path: String, source: String) -> void:
	if not resource_id.is_empty() and not path.is_empty() and FileAccess.file_exists(path):
		return
	var key := "%s:%s" % [kind, resource_id]
	if not _missing_references.has(key):
		_missing_references[key] = source


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)

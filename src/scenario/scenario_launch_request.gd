class_name ScenarioLaunchRequest
extends RefCounted


enum RequestKind {
	NEW_GAME,
	CONTINUE,
	RECOLLECTION,
}

var kind: RequestKind = RequestKind.CONTINUE
var scenario_id: String = ""
var label: String = ""
var save_path: String = ""
var instruction_anchor: String = ""
var start_label: String = ""
var unlock_flag: int = 0
var save_data: SaveData
## Compatibility note for older callers; routing no longer displays an
## unavailable-runner notice now that AdvScreen owns execution.
var availability_message: String = ""


static func new_game(scenario: String = "00_z000") -> ScenarioLaunchRequest:
	var result := ScenarioLaunchRequest.new()
	result.kind = RequestKind.NEW_GAME
	result.scenario_id = scenario
	return result


static func from_save(data: SaveData, path: String = "") -> ScenarioLaunchRequest:
	var result := ScenarioLaunchRequest.new()
	result.kind = RequestKind.CONTINUE
	if data != null:
		result.scenario_id = data.scenario_id
		result.instruction_anchor = data.instruction_anchor
		result.save_path = path
		result.save_data = data
	return result


static func for_recollection(
		scenario: String,
		request_label: String,
		request_unlock_flag: int
) -> ScenarioLaunchRequest:
	var result := ScenarioLaunchRequest.new()
	result.kind = RequestKind.RECOLLECTION
	result.scenario_id = scenario
	result.label = request_label
	result.start_label = "recollect"
	result.unlock_flag = request_unlock_flag
	return result


func is_recollection() -> bool:
	return kind == RequestKind.RECOLLECTION


func is_new_game() -> bool:
	return kind == RequestKind.NEW_GAME


func summary() -> String:
	if is_recollection():
		return "回想：%s / %s" % [scenario_id, label]
	if is_new_game():
		return "新游戏：%s" % scenario_id
	return "存档：%s / %s" % [scenario_id, instruction_anchor]

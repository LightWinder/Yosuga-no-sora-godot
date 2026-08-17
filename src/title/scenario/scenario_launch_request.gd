class_name ScenarioLaunchRequest
extends RefCounted


enum RequestKind {
	CONTINUE,
	RECOLLECTION,
}

var kind: RequestKind = RequestKind.CONTINUE
var scenario_id: String = ""
var label: String = ""
var save_path: String = ""
var instruction_anchor: String = ""
var unlock_flag: int = 0
var availability_message: String = "正文运行层待迁移"


static func from_save(data: SaveData, path: String = "") -> ScenarioLaunchRequest:
	var result := ScenarioLaunchRequest.new()
	result.kind = RequestKind.CONTINUE
	if data != null:
		result.scenario_id = data.scenario_id
		result.instruction_anchor = data.instruction_anchor
		result.save_path = path
	return result


static func from_memory(memory: TitleMemoryEntry) -> ScenarioLaunchRequest:
	var result := ScenarioLaunchRequest.new()
	result.kind = RequestKind.RECOLLECTION
	if memory != null:
		result.scenario_id = memory.scenario_id
		result.label = memory.label
		result.unlock_flag = memory.unlock_flag
	return result


func is_recollection() -> bool:
	return kind == RequestKind.RECOLLECTION


func summary() -> String:
	if is_recollection():
		return "回想：%s / %s" % [scenario_id, label]
	return "存档：%s / %s" % [scenario_id, instruction_anchor]

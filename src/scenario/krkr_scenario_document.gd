class_name KrkrScenarioDocument
extends RefCounted


var scenario_id: String = ""
var source_path: String = ""
var instructions: Array[KrkrScenarioInstruction] = []
var labels: Dictionary = {}


func add_instruction(instruction: KrkrScenarioInstruction) -> void:
	if instruction.kind == KrkrScenarioInstruction.Kind.LABEL:
		labels[instruction.text.to_lower()] = instructions.size()
	instructions.append(instruction)


func instruction_index_for_label(label_name: String) -> int:
	var normalized := label_name.strip_edges().trim_prefix("*").to_lower()
	return int(labels.get(normalized, -1))


func tag_count(tag_name: StringName) -> int:
	var count := 0
	for instruction in instructions:
		if instruction.kind == KrkrScenarioInstruction.Kind.TAG and instruction.tag_name == tag_name:
			count += 1
	return count

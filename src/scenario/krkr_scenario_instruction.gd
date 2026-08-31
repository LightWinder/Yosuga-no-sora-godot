class_name KrkrScenarioInstruction
extends RefCounted


enum Kind {
	TAG,
	TEXT,
	LABEL,
}

var kind: Kind = Kind.TEXT
var tag_name: StringName = &""
var arguments: Dictionary = {}
var flags: Array[StringName] = []
var text: String = ""
var line_number: int = 0
var raw_line: String = ""


static func tag(
		name: StringName,
		tag_arguments: Dictionary,
		tag_flags: Array[StringName],
		source_line: int,
		raw: String
) -> KrkrScenarioInstruction:
	var instruction := KrkrScenarioInstruction.new()
	instruction.kind = Kind.TAG
	instruction.tag_name = name
	instruction.arguments = tag_arguments
	instruction.flags = tag_flags
	instruction.line_number = source_line
	instruction.raw_line = raw
	return instruction


static func message(content: String, source_line: int, raw: String) -> KrkrScenarioInstruction:
	var instruction := KrkrScenarioInstruction.new()
	instruction.kind = Kind.TEXT
	instruction.text = content
	instruction.line_number = source_line
	instruction.raw_line = raw
	return instruction


static func label(label_name: String, source_line: int, raw: String) -> KrkrScenarioInstruction:
	var instruction := KrkrScenarioInstruction.new()
	instruction.kind = Kind.LABEL
	instruction.text = label_name
	instruction.line_number = source_line
	instruction.raw_line = raw
	return instruction


func argument(name: String, default_value: Variant = "") -> Variant:
	return arguments.get(name.to_lower(), default_value)


func string_argument(name: String, default_value: String = "") -> String:
	return str(argument(name, default_value))


func int_argument(name: String, default_value: int = 0) -> int:
	var value := string_argument(name)
	return value.to_int() if value.is_valid_int() else default_value


func float_argument(name: String, default_value: float = 0.0) -> float:
	var value := string_argument(name)
	return value.to_float() if value.is_valid_float() else default_value


func has_flag(name: String) -> bool:
	return flags.has(StringName(name.to_lower()))

class_name KrkrScenarioParser
extends RefCounted


var last_errors: Array[String] = []


func parse_file(path: String, scenario_id: String = "") -> KrkrScenarioDocument:
	last_errors.clear()
	if not FileAccess.file_exists(path):
		last_errors.append("剧本文件不存在：%s" % path)
		return null

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		last_errors.append("无法打开剧本文件：%s" % path)
		return null
	var bytes := file.get_buffer(file.get_length())
	if bytes.size() >= 2 and (
			(bytes[0] == 0xff and bytes[1] == 0xfe)
			or (bytes[0] == 0xfe and bytes[1] == 0xff)
	):
		last_errors.append("剧本必须先转换为 UTF-8：%s" % path)
		return null

	var content := bytes.get_string_from_utf8()
	if content.contains("\uFFFD"):
		last_errors.append("剧本不是有效的 UTF-8 文本：%s" % path)
		return null
	if content.begins_with("\uFEFF"):
		content = content.trim_prefix("\uFEFF")
	var resolved_id := scenario_id
	if resolved_id.is_empty():
		resolved_id = path.get_file().get_basename()
	return parse_text(content, resolved_id, path)


func parse_text(
		content: String,
		scenario_id: String = "memory",
		source_path: String = ""
) -> KrkrScenarioDocument:
	last_errors.clear()
	var document := KrkrScenarioDocument.new()
	document.scenario_id = scenario_id
	document.source_path = source_path

	var normalized := content.replace("\r\n", "\n").replace("\r", "\n")
	var lines := normalized.split("\n", true)
	for line_index in lines.size():
		var raw_line := lines[line_index]
		var stripped := raw_line.strip_edges()
		if stripped.is_empty() or stripped.begins_with(";"):
			continue
		if stripped.begins_with("@"):
			var instruction := _parse_tag(stripped, line_index + 1)
			if instruction != null:
				document.add_instruction(instruction)
			continue
		if stripped.begins_with("*"):
			var label_name := _parse_label_name(stripped)
			if label_name.is_empty():
				last_errors.append("第 %d 行标签为空。" % (line_index + 1))
			else:
				document.add_instruction(KrkrScenarioInstruction.label(label_name, line_index + 1, raw_line))
			continue
		document.add_instruction(KrkrScenarioInstruction.message(stripped, line_index + 1, raw_line))

	return document


func _parse_tag(line: String, line_number: int) -> KrkrScenarioInstruction:
	var cursor := 1
	cursor = _skip_spaces(line, cursor)
	var name_start := cursor
	while cursor < line.length() and not _is_space(_character(line, cursor)):
		cursor += 1
	var original_name := line.substr(name_start, cursor - name_start)
	if original_name.is_empty():
		last_errors.append("第 %d 行标签名为空。" % line_number)
		return null

	var tag_arguments: Dictionary = {}
	var tag_flags: Array[StringName] = []
	while cursor < line.length():
		cursor = _skip_spaces(line, cursor)
		if cursor >= line.length():
			break
		var key_start := cursor
		while cursor < line.length():
			var key_character := _character(line, cursor)
			if _is_space(key_character) or key_character == "=":
				break
			cursor += 1
		var key := line.substr(key_start, cursor - key_start).to_lower()
		if key.is_empty():
			last_errors.append("第 %d 行存在无法解析的标签参数：%s" % [line_number, line])
			break
		cursor = _skip_spaces(line, cursor)
		if cursor >= line.length() or _character(line, cursor) != "=":
			tag_flags.append(StringName(key))
			continue
		cursor += 1
		cursor = _skip_spaces(line, cursor)
		var parsed_value := _parse_value(line, cursor, line_number)
		tag_arguments[key] = parsed_value[0]
		cursor = int(parsed_value[1])

	return KrkrScenarioInstruction.tag(
		StringName(original_name.to_lower()),
		tag_arguments,
		tag_flags,
		line_number,
		line
	)


func _parse_value(line: String, cursor: int, line_number: int) -> Array:
	if cursor >= line.length():
		return ["", cursor]
	if _character(line, cursor) != "\"":
		var value_start := cursor
		while cursor < line.length() and not _is_space(_character(line, cursor)):
			cursor += 1
		var value := line.substr(value_start, cursor - value_start)
		# Some source scripts use JavaScript-style commas between parameters
		# (`width=32, height=0,`). The comma is syntax, not part of the value;
		# embedded commas such as SetParam's `arg=Date,16` remain untouched.
		if value.ends_with(","):
			value = value.trim_suffix(",")
		return [value, cursor]

	cursor += 1
	var value := ""
	var terminated := false
	while cursor < line.length():
		var character := _character(line, cursor)
		if character == "\"":
			cursor += 1
			terminated = true
			break
		if character == "\\" and cursor + 1 < line.length():
			var escaped := _character(line, cursor + 1)
			if escaped == "\"" or escaped == "\\":
				value += escaped
				cursor += 2
				continue
		value += character
		cursor += 1
	if not terminated:
		last_errors.append("第 %d 行的引号参数没有闭合。" % line_number)
	return [value, cursor]


func _parse_label_name(line: String) -> String:
	var value := line.trim_prefix("*")
	var separator := value.find("|")
	if separator >= 0:
		value = value.left(separator)
	separator = value.find(" ")
	if separator >= 0:
		value = value.left(separator)
	return value.strip_edges()


func _skip_spaces(value: String, cursor: int) -> int:
	while cursor < value.length() and _is_space(_character(value, cursor)):
		cursor += 1
	return cursor


func _character(value: String, index: int) -> String:
	return value.substr(index, 1)


func _is_space(character: String) -> bool:
	return character == " " or character == "\t"

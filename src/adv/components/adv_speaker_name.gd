@tool
class_name AdvSpeakerName
extends Control
## Vector-style speaker name treatment matching the former 197x61 PNGs.
## The principal cast keeps the source romanized reading beside the name;
## every other speaker is fitted and centered as live text.


const NAME_FONT: Font = preload("res://assets/themes/fonts/settings_choice_font.tres")
const NAME_COLOR := Color(0.98, 0.995, 1.0, 1.0)
const OUTLINE_COLOR := Color(0.035, 0.30, 0.38, 1.0)
const NAME_REGION_WIDTH := 118.0
const READING_X := 123.0
const NAME_FONT_SIZE := 49
const READING_FONT_SIZE := 20
const NAME_OUTLINE_SIZE := 5
const READING_OUTLINE_SIZE := 3
const MIN_NAME_FONT_SIZE := 24
const READINGS := {
	"穹": "SORA",
	"奈绪": "NAO",
	"瑛": "AKIRA",
	"一叶": "KAZUHA",
	"初佳": "MOTOKA",
	"亮平": "RYOUHEI",
	"八寻": "YAHIRO",
	"梢": "KOZUE",
	"悠": "HARUKA",
}

var _speaker := ""
var _reading := ""


func _ready() -> void:
	resized.connect(queue_redraw)
	queue_redraw()


func set_speaker(value: String) -> void:
	_speaker = value.strip_edges().replace("＆", "&")
	_reading = str(READINGS.get(_speaker, ""))
	queue_redraw()


func speaker_text() -> String:
	return _speaker


func reading_text() -> String:
	return _reading


func _draw() -> void:
	if _speaker.is_empty():
		return
	var has_reading := not _reading.is_empty()
	var region_width := NAME_REGION_WIDTH if has_reading else size.x
	var font_size := _fitted_font_size(_speaker, NAME_FONT_SIZE, region_width - NAME_OUTLINE_SIZE * 2.0)
	var text_size := NAME_FONT.get_string_size(
		_speaker, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size
	)
	var name_x := maxf(NAME_OUTLINE_SIZE, region_width - text_size.x - NAME_OUTLINE_SIZE) \
		if has_reading else maxf(NAME_OUTLINE_SIZE, (size.x - text_size.x) * 0.5)
	var name_baseline := (size.y - NAME_FONT.get_height(font_size)) * 0.5 \
		+ NAME_FONT.get_ascent(font_size)
	_draw_outlined_text(
		NAME_FONT,
		Vector2(name_x, name_baseline),
		_speaker,
		font_size,
		NAME_OUTLINE_SIZE
	)
	if not has_reading:
		return
	var reading_width := maxf(1.0, size.x - READING_X - READING_OUTLINE_SIZE)
	var reading_size := _fitted_font_size(
		_reading, READING_FONT_SIZE, reading_width, 13
	)
	var reading_baseline := size.y - 5.0
	_draw_outlined_text(
		NAME_FONT,
		Vector2(READING_X, reading_baseline),
		_reading,
		reading_size,
		READING_OUTLINE_SIZE
	)


func _draw_outlined_text(
		font: Font,
		baseline: Vector2,
		value: String,
		font_size: int,
		outline_size: int
) -> void:
	draw_string_outline(
		font,
		baseline,
		value,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		font_size,
		outline_size,
		OUTLINE_COLOR
	)
	draw_string(
		font,
		baseline,
		value,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1.0,
		font_size,
		NAME_COLOR
	)


func _fitted_font_size(
		value: String,
		preferred_size: int,
		available_width: float,
		minimum_size: int = MIN_NAME_FONT_SIZE
) -> int:
	var result := preferred_size
	while result > minimum_size and NAME_FONT.get_string_size(
			value, HORIZONTAL_ALIGNMENT_LEFT, -1.0, result
	).x > available_width:
		result -= 1
	return result

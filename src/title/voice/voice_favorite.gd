class_name VoiceFavorite
extends Resource


@export var favorite_id: String = ""
@export var voice_path: String = ""
@export var display_name: String = ""
@export var transcript: String = ""
@export var saved_at_unix: int = 0
@export var date_label: String = ""
@export var thumbnail_path: String = ""
@export var face: String = ""
@export var save_path: String = ""


static func create(
		id: String,
		path: String,
		name: String,
		text: String = "",
		thumb: String = "",
		save_file: String = ""
) -> VoiceFavorite:
	var result := VoiceFavorite.new()
	result.favorite_id = id
	result.voice_path = path
	result.display_name = name
	result.transcript = text
	result.thumbnail_path = thumb
	result.save_path = save_file
	result.saved_at_unix = Time.get_unix_time_from_system()
	return result


func to_dictionary() -> Dictionary:
	return {
		"favorite_id": favorite_id,
		"voice_path": voice_path,
		"display_name": display_name,
		"transcript": transcript,
		"saved_at_unix": saved_at_unix,
		"date_label": date_label,
		"thumbnail_path": thumbnail_path,
		"face": face,
		"save_path": save_path,
	}


static func from_dictionary(raw: Dictionary) -> VoiceFavorite:
	var result := VoiceFavorite.new()
	result.favorite_id = str(raw.get("favorite_id", raw.get("id", "")))
	result.voice_path = str(raw.get("voice_path", raw.get("voiceFile", "")))
	result.display_name = str(raw.get("display_name", raw.get("name", "")))
	result.transcript = str(raw.get("transcript", raw.get("text", "")))
	result.thumbnail_path = str(raw.get("thumbnail_path", raw.get("thumb", "")))
	result.save_path = str(raw.get("save_path", raw.get("saveFile", "")))
	var raw_date: Variant = raw.get("saved_at_unix", 0)
	if raw_date is int or raw_date is float:
		result.saved_at_unix = int(raw_date)
	else:
		# The source VoiceCollect contract stores a human-readable date.  Keep it
		# as display data instead of accidentally converting a year to a timestamp.
		result.date_label = str(raw.get("date_label", raw.get("date", "")))
	result.face = str(raw.get("face", ""))
	return result

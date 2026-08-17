class_name TitleContentManifest
extends RefCounted


const PATH := "res://assets/manifests/title_content_manifest.json"

var schema_version: int = 0
var album_groups: Array[TitleAlbumGroup] = []
var music_tracks: Array[TitleMusicTrack] = []
var memory_entries: Array[TitleMemoryEntry] = []
var source_contract: Dictionary = {}
var load_error: String = ""


static func load_default() -> TitleContentManifest:
	var result := TitleContentManifest.new()
	if not FileAccess.file_exists(PATH):
		result.load_error = "缺少内容 manifest：%s" % PATH
		return result
	var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if not raw is Dictionary:
		result.load_error = "内容 manifest 不是 JSON object。"
		return result
	result._decode(raw as Dictionary)
	return result


func album_card_count() -> int:
	var count := 0
	for group in album_groups:
		count += group.cards.size()
	return count


func album_variant_count() -> int:
	var count := 0
	for group in album_groups:
		count += group.variant_count()
	return count


func _decode(raw: Dictionary) -> void:
	schema_version = int(raw.get("schema_version", 0))
	source_contract = _dictionary_or_empty(raw.get("source_contract", {}))
	if schema_version != 1:
		load_error = "不支持的内容 manifest schema：%d" % schema_version
		return
	var raw_groups: Variant = raw.get("album_groups", [])
	if raw_groups is Array:
		for value in raw_groups:
			if value is Dictionary:
				album_groups.append(_decode_album_group(value as Dictionary))
	var raw_music: Variant = raw.get("music", [])
	if raw_music is Array:
		for value in raw_music:
			if value is Dictionary:
				music_tracks.append(_decode_music(value as Dictionary))
	var raw_memories: Variant = raw.get("memories", [])
	if raw_memories is Array:
		for value in raw_memories:
			if value is Dictionary:
				memory_entries.append(_decode_memory(value as Dictionary))
	if album_groups.is_empty() or music_tracks.is_empty() or memory_entries.is_empty():
		load_error = "内容 manifest 缺少相册、音乐或回忆清单。"


func _decode_album_group(raw: Dictionary) -> TitleAlbumGroup:
	var group := TitleAlbumGroup.new()
	group.group_id = StringName(str(raw.get("id", "")))
	group.title = str(raw.get("title", ""))
	group.source_index = int(raw.get("source_index", 0))
	var raw_cards: Variant = raw.get("cards", [])
	if raw_cards is Array:
		for value in raw_cards:
			if value is Dictionary:
				group.cards.append(_decode_album_card(value as Dictionary))
	return group


func _decode_album_card(raw: Dictionary) -> TitleAlbumCard:
	var card := TitleAlbumCard.new()
	card.card_id = str(raw.get("id", ""))
	card.unlock_flag = int(raw.get("unlock_flag", 0))
	var raw_variants: Variant = raw.get("variants", [])
	if raw_variants is Array:
		for value in raw_variants:
			if value is Dictionary:
				card.variants.append(TitleAlbumVariant.from_dictionary(value as Dictionary))
	return card


func _decode_music(raw: Dictionary) -> TitleMusicTrack:
	var track := TitleMusicTrack.new()
	track.track_id = StringName(str(raw.get("id", "")))
	track.title_id = str(raw.get("title_id", ""))
	track.stream_path = str(raw.get("path", ""))
	track.loop_enabled = bool(raw.get("loop", false))
	track.loop_sample = int(raw.get("loop_sample", 0))
	track.sample_rate = int(raw.get("sample_rate", 44100))
	return track


func _decode_memory(raw: Dictionary) -> TitleMemoryEntry:
	var memory := TitleMemoryEntry.new()
	memory.entry_id = StringName(str(raw.get("id", "")))
	memory.title = str(raw.get("title", ""))
	memory.group = str(raw.get("group", ""))
	memory.unlock_flag = int(raw.get("unlock_flag", 0))
	memory.kind = TitleMemoryEntry.EntryKind.VIDEO if str(raw.get("kind", "adv")) == "video" else TitleMemoryEntry.EntryKind.ADV
	memory.scenario_id = str(raw.get("scenario_id", ""))
	memory.label = str(raw.get("label", ""))
	memory.video_path = str(raw.get("video", ""))
	memory.thumbnail_path = str(raw.get("thumbnail", ""))
	return memory


func _dictionary_or_empty(value: Variant) -> Dictionary:
	return value.duplicate(true) if value is Dictionary else {}

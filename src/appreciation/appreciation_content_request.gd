class_name AppreciationContentRequest
extends RefCounted


enum RequestKind {
	ALBUM_VARIANT,
	MUSIC_TRACK,
	MEMORY_VIDEO,
	MEMORY_ADV,
	VOICE_FAVORITE,
}

var catalog_id: StringName
var entry_id: StringName
var group_id: StringName = &""
var kind: RequestKind = RequestKind.ALBUM_VARIANT
var media_path: String = ""
var scenario_id: String = ""
var scenario_label: String = ""
var save_path: String = ""


static func create(catalog: StringName, entry: StringName) -> AppreciationContentRequest:
	var request := AppreciationContentRequest.new()
	request.catalog_id = catalog
	request.entry_id = entry
	return request


static func for_album(group_id: StringName, variant: AppreciationAlbumVariant) -> AppreciationContentRequest:
	var request := create(&"album", StringName(variant.variant_id if variant != null else ""))
	request.group_id = group_id
	request.kind = RequestKind.ALBUM_VARIANT
	request.media_path = variant.texture_path if variant != null else ""
	return request


static func for_music(track: AppreciationMusicTrack) -> AppreciationContentRequest:
	var request := create(&"music", track.track_id if track != null else &"")
	request.kind = RequestKind.MUSIC_TRACK
	request.media_path = track.stream_path if track != null else ""
	return request


static func for_memory(memory: AppreciationMemoryEntry) -> AppreciationContentRequest:
	var request := create(&"memories", memory.entry_id if memory != null else &"")
	if memory != null:
		request.kind = AppreciationContentRequest.RequestKind.MEMORY_VIDEO if memory.is_video() else AppreciationContentRequest.RequestKind.MEMORY_ADV
		request.media_path = memory.video_path
		request.scenario_id = memory.scenario_id
		request.scenario_label = memory.label
	return request


static func for_voice(favorite: VoiceFavorite) -> AppreciationContentRequest:
	var request := create(&"voice", StringName(favorite.favorite_id if favorite != null else ""))
	request.kind = RequestKind.VOICE_FAVORITE
	request.media_path = favorite.voice_path if favorite != null else ""
	return request

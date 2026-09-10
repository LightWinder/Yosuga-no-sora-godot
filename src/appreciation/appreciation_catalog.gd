class_name AppreciationCatalog
extends RefCounted


const ALBUM: StringName = &"album"
const MUSIC: StringName = &"music"
const MEMORIES: StringName = &"memories"
const VOICE: StringName = &"voice"


static func load_manifest() -> AppreciationContentManifest:
	return AppreciationContentManifest.load_default()


static func entries(catalog_id: StringName, profile: ProfileData) -> Array[AppreciationCatalogEntry]:
	var result: Array[AppreciationCatalogEntry] = []
	var manifest := load_manifest()
	match catalog_id:
		ALBUM:
			for group in manifest.album_groups:
				result.append(AppreciationCatalogEntry.create(
					group.group_id,
					group.title,
					"%d 张卡片 / %d 个差分" % [group.cards.size(), group.variant_count()],
					true,
					"",
					0,
					{"card_count": group.cards.size(), "variant_count": group.variant_count()}
				))
		MUSIC:
			for track in manifest.music_tracks:
				result.append(AppreciationCatalogEntry.create(
					track.track_id,
					track.track_id,
					track.title_id,
					true,
					track.stream_path,
					0,
					{"loop": track.loop_enabled, "loop_offset": track.loop_offset_seconds()}
				))
		MEMORIES:
			for memory in manifest.memory_entries:
				result.append(AppreciationCatalogEntry.create(
					memory.entry_id,
					memory.title,
					memory.group,
					memory.unlocked(profile),
					memory.thumbnail_path,
					memory.unlock_flag,
					{"kind": "video" if memory.is_video() else "adv", "scenario_id": memory.scenario_id}
				))
	return result

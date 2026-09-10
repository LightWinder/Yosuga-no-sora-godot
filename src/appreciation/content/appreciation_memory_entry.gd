class_name AppreciationMemoryEntry
extends Resource


enum EntryKind {
	ADV,
	VIDEO,
}

@export var entry_id: StringName = &""
@export var title: String = ""
@export var group: String = ""
@export var unlock_flag: int = 0
@export var kind: EntryKind = EntryKind.ADV
@export var scenario_id: String = ""
@export var label: String = ""
@export var video_path: String = ""
@export var thumbnail_path: String = ""


func unlocked(profile: ProfileData) -> bool:
	return unlock_flag == 0 or (profile != null and profile.is_global_flag_set(unlock_flag))


func is_video() -> bool:
	return kind == EntryKind.VIDEO

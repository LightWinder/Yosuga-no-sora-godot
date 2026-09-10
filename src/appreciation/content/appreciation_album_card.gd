class_name AppreciationAlbumCard
extends Resource


@export var card_id: String = ""
@export var unlock_flag: int = 0
@export var variants: Array[AppreciationAlbumVariant] = []


func first_variant() -> AppreciationAlbumVariant:
	return variants[0] if not variants.is_empty() else null


func unlocked(profile: ProfileData) -> bool:
	return unlock_flag == 0 or (profile != null and profile.is_global_flag_set(unlock_flag))


func unlocked_variants(profile: ProfileData) -> Array[AppreciationAlbumVariant]:
	var result: Array[AppreciationAlbumVariant] = []
	for variant in variants:
		if variant.unlock_flag == 0 or (profile != null and profile.is_global_flag_set(variant.unlock_flag)):
			result.append(variant)
	return result

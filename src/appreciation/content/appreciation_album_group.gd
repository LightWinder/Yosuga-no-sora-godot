class_name AppreciationAlbumGroup
extends Resource


@export var group_id: StringName = &""
@export var title: String = ""
@export var source_index: int = 0
@export var cards: Array[AppreciationAlbumCard] = []


func unlocked_card_count(profile: ProfileData) -> int:
	var count := 0
	for card in cards:
		if card.unlocked(profile):
			count += 1
	return count


func variant_count() -> int:
	var count := 0
	for card in cards:
		count += card.variants.size()
	return count

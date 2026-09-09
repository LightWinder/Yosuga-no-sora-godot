class_name RouteProgress
extends RefCounted


## Cross-feature route progress shared by ADV and Title. Scenario files still
## own the moment at which a route is cleared; this table owns the stable
## relationship between that route, its Title character, and its staff roll.
const CLEARED_GAME_FLAG: int = 1

const ROUTES: Dictionary = {
	&"sora": {
		"title_character_node": &"CharacterSora",
		"completion_flag": 21,
		"staff_roll_flag": 11,
		"staff_roll_video_id": "staff_roll_sora",
	},
	&"nao": {
		"title_character_node": &"CharacterNao",
		"completion_flag": 22,
		"staff_roll_flag": 12,
		"staff_roll_video_id": "staff_roll_nao",
	},
	&"akira": {
		"title_character_node": &"CharacterAkira",
		"completion_flag": 23,
		"staff_roll_flag": 13,
		"staff_roll_video_id": "staff_roll_akira",
	},
	&"kazuha": {
		"title_character_node": &"CharacterKazuha",
		"completion_flag": 24,
		"staff_roll_flag": 14,
		"staff_roll_video_id": "staff_roll_kazuha",
	},
	&"motoka": {
		"title_character_node": &"CharacterMotoka",
		"completion_flag": 25,
		"staff_roll_flag": 15,
		"staff_roll_video_id": "staff_roll_motoka",
	},
}

const ROUTE_ALIASES: Dictionary = {
	"穹": &"sora",
	"奈緒": &"nao",
	"奈绪": &"nao",
	"瑛": &"akira",
	"一葉": &"kazuha",
	"一叶": &"kazuha",
	"初佳": &"motoka",
}


static func title_character_flags() -> Dictionary:
	var result: Dictionary = {}
	for route_id: StringName in ROUTES:
		var route := ROUTES[route_id] as Dictionary
		result[route.get("title_character_node", &"")] = int(route.get("completion_flag", 0))
	return result


static func route_for_name(display_name: String) -> Dictionary:
	var route_id := ROUTE_ALIASES.get(display_name, &"") as StringName
	if route_id.is_empty():
		return {}
	return (ROUTES.get(route_id, {}) as Dictionary).duplicate(true)

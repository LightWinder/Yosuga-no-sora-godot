class_name TitleMenuItem
extends Resource


@export var id: StringName = &""
@export var label: String = ""
@export var texture: Texture2D
@export var is_bonus_item: bool = false


static func create(item_id: StringName, item_label: String, item_texture: Texture2D, bonus: bool = false) -> TitleMenuItem:
	var item := TitleMenuItem.new()
	item.id = item_id
	item.label = item_label
	item.texture = item_texture
	item.is_bonus_item = bonus
	return item

@tool
class_name PageTitle
extends Control


## Reusable decorative page heading. The scene owns all layout and styling;
## this script only exposes the text content used by scene instances.

@export_group("Content")
@export var title := "设置":
	set(value):
		title = value
		_sync_content()

@export var subtitle := "SYSTEM.":
	set(value):
		subtitle = value
		_sync_content()

func _ready() -> void:
	_sync_content()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_sync_content()


func _sync_content() -> void:
	var first_character := get_node_or_null("TextRow/ChineseTitle/FirstChar") as Label
	var trailing_characters := get_node_or_null("TextRow/ChineseTitle/SecondChar") as Label
	var subtitle_label := get_node_or_null("TextRow/SubtitleSlot/SubTitle") as Label
	if first_character == null or trailing_characters == null or subtitle_label == null:
		return

	# The two-slot layout assumes a two-glyph heading, so localized titles must
	# stay two characters wide (see the 存档/读取 entries in ui.csv).
	var display_title := tr(title)
	first_character.text = display_title.substr(0, 1) if not display_title.is_empty() else ""
	trailing_characters.text = display_title.substr(1)
	subtitle_label.text = subtitle

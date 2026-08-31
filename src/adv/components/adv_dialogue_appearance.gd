class_name AdvDialogueAppearance
extends RefCounted
## Shared presentation values, independent of settings ownership and gameplay.

const MESSAGE_FONT: Font = preload("res://assets/fonts/Xiaolai-Regular.fontdata")
const READ_COLOR := Color(0.72, 0.91, 1.0, 1.0)
const UNREAD_COLOR := Color(0.98, 0.995, 1.0, 1.0)


static func message_font(_font_type: int) -> Font:
	# The six source families have not been imported into Godot yet. Preserve
	# gameplay's bundled font fallback for every ID, including in the preview.
	return MESSAGE_FONT


static func message_color(already_read: bool, distinguish_read: bool) -> Color:
	return READ_COLOR if already_read and distinguish_read else UNREAD_COLOR

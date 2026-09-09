@tool
class_name AppreciationPageButton
extends BaseButton


## Draws the source `pgup.png` states without rebuilding an atlas at runtime.
## The source cells have irregular widths, so equal-width AtlasTextures crop
## the arrows.  Keeping the geometry here also makes mirroring deterministic.
@export_enum("Previous:-1", "Next:1") var direction := 1:
	set(value):
		direction = -1 if value < 0 else 1
		queue_redraw()

@export var source_texture: Texture2D = preload("res://assets/content/appreciation/pgup.png"):
	set(value):
		source_texture = value
		queue_redraw()

const DESIGN_SIZE := Vector2(45.0, 66.0)
const SOURCE_X := [39.0, 84.0, 129.0]
const SOURCE_WIDTH := [45.0, 45.0, 40.0]


func _init() -> void:
	custom_minimum_size = DESIGN_SIZE
	size = DESIGN_SIZE
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	button_down.connect(queue_redraw)
	button_up.connect(queue_redraw)


func _draw() -> void:
	if source_texture == null:
		return
	var state := 2 if disabled else (1 if is_hovered() or has_focus() or is_pressed() else 0)
	var source_width: float = SOURCE_WIDTH[state]
	var destination := Rect2((DESIGN_SIZE.x - source_width) * 0.5, 0.0, source_width, DESIGN_SIZE.y)
	var source := Rect2(SOURCE_X[state], 0.0, source_width, DESIGN_SIZE.y)
	if direction < 0:
		draw_set_transform(Vector2(DESIGN_SIZE.x, 0.0), 0.0, Vector2(-1.0, 1.0))
	draw_texture_rect_region(source_texture, destination, source)
	if direction < 0:
		draw_set_transform(Vector2.ZERO)


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		queue_redraw()


func _has_point(point: Vector2) -> bool:
	return Rect2(-14.0, -14.0, size.x + 28.0, size.y + 28.0).has_point(point)

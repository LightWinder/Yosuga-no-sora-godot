class_name AppreciationGallery
extends Control


var interaction_blocked := false
var _page_tween: Tween

@onready var _previous: AppreciationPageButton = %PreviousPage
@onready var _next: AppreciationPageButton = %NextPage
@onready var _panel: Control = $ContentPanel


func _process(delta: float) -> void:
	update_hover(get_local_mouse_position(), delta)


## Pointer-only reveal: focus from a prior click must never keep an arrow open.
## Disabled arrows stop receiving input immediately, then finish fading away.
func update_hover(point: Vector2, delta: float) -> void:
	var panel_rect := _panel.get_rect()
	var pointer_inside := panel_rect.has_point(point)
	_update_arrow(_previous, pointer_inside, delta)
	_update_arrow(_next, pointer_inside, delta)


func _update_arrow(button: AppreciationPageButton, pointer_inside: bool, delta: float) -> void:
	var reveal := pointer_inside and not button.disabled and not interaction_blocked
	button.mouse_filter = Control.MOUSE_FILTER_STOP if reveal else Control.MOUSE_FILTER_IGNORE
	button.modulate.a = move_toward(button.modulate.a, 1.0 if reveal else 0.0, delta / 0.16)


func play_page_transition(content: Control, direction: int) -> void:
	if _page_tween != null and _page_tween.is_valid():
		_page_tween.kill()
	var rest_position := content.position
	content.position = rest_position + Vector2(float(signi(direction)) * 72.0, 0.0)
	content.modulate.a = 0.25
	_page_tween = create_tween().set_parallel(true)
	_page_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_page_tween.tween_property(content, "position", rest_position, 0.22)
	_page_tween.tween_property(content, "modulate:a", 1.0, 0.18)

extends SceneTree


const VIEW_SCENE: PackedScene = preload("res://src/adv/components/adv_dialogue_view.tscn")
const THEME: Theme = preload("res://assets/themes/yosuga_theme.tres")

var _failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var surface := Control.new()
	surface.name = "DialogueTestSurface"
	surface.size = Vector2(1920, 1080)
	root.add_child(surface)
	var view := VIEW_SCENE.instantiate() as AdvDialogueView
	var other := VIEW_SCENE.instantiate() as AdvDialogueView
	other.name = "OtherDialogueView"
	surface.add_child(view)
	surface.add_child(other)
	await process_frame
	_test_presentation(view, other)
	_test_input_seam(view)
	_test_reveal(view)
	_test_frame_transitions(view)
	_test_permanent_frame_layout(view)
	# Check that queued callbacks cannot alter a replacement line/restored frame.
	view.reveal_message("old line", 100)
	view.set_frame_visible(false, 0.02)
	view.set_message("replacement line")
	view.restore_frame_state(Vector2(40, 650), 0.8, true)
	await create_timer(0.08).timeout
	var label := view.get_node("%MessageLabel") as RichTextLabel
	_expect(label.text == "replacement line" and label.visible_characters == -1, "Canceled reveal must not touch the replacement line.")
	_expect(view.frame_position() == Vector2(40, 650) and is_equal_approx(view.frame_alpha(), 0.8) and view.is_frame_visible(), "Restoration must cancel old frame callbacks.")
	# Free active animations as well, exercising the view's own cleanup boundary.
	view.reveal_message("dispose while revealing", 100)
	view.set_chrome_visible(false)
	surface.queue_free()
	await process_frame
	await process_frame
	if _failures.is_empty():
		print("ADV dialogue view test passed.")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func _test_presentation(view: AdvDialogueView, other: AdvDialogueView) -> void:
	var panel := view.get_node("%MessagePanel") as PanelContainer
	var label := view.get_node("%MessageLabel") as RichTextLabel
	var speaker := view.get_node("%SpeakerLabel") as Label
	var name_image := view.get_node("%SpeakerNameImage") as TextureRect
	var portrait := view.get_node("%Portrait") as TextureRect
	_expect(view.size == Vector2(1920, 1080), "The component must fill its design surface.")
	_expect(panel.position == Vector2(0, 760) and panel.size == Vector2(1920, 320), "Extraction must retain the bottom frame layout.")
	_expect(panel.z_index == 1100 and portrait.z_index == 2, "Extraction must retain frame and portrait ordering.")
	_expect(label.position == Vector2(450, 80) and label.size == Vector2(1170, 238), "Extraction must retain the text rectangle.")
	_expect(speaker.position == Vector2(380, 0) and portrait.position == Vector2(0, -40), "Extraction must retain speaker and portrait placement.")
	_expect(panel.theme_type_variation == &"AdvMessagePanel" and label.theme_type_variation == &"AdvMessageLabel", "Dialogue must reuse the existing Theme variations.")
	var texture := GradientTexture2D.new()
	view.set_speaker("穹", texture, true)
	view.set_portrait(texture)
	view.set_message("……别把我当小孩子。")
	_expect(not speaker.visible and name_image.visible and name_image.texture == texture, "Resolved name artwork must replace the fallback label.")
	_expect(portrait.visible and portrait.texture == texture and label.text == "……别把我当小孩子。", "The view must display supplied portrait and message data.")
	view.set_speaker("fallback", null, true)
	_expect(speaker.visible and speaker.text == "fallback" and not name_image.visible, "Missing name artwork must retain the fallback label.")
	view.set_speaker("心の声", null, false)
	_expect(not speaker.visible and not name_image.visible, "The caller must be able to suppress names for monologues.")
	view.set_portrait(null)
	_expect(not portrait.visible and portrait.texture == null, "Disabling portraits must remove their presentation.")
	view.set_portrait(texture)
	view.set_message_font_size(48)
	view.set_message_color(Color(0.72, 0.91, 1.0, 1.0))
	_expect(label.get_theme_font_size("normal_font_size") == 48 and label.get_theme_color("default_color").is_equal_approx(Color(0.72, 0.91, 1.0, 1.0)), "Font size and read color must apply only to message text.")
	var style := panel.get_theme_stylebox("panel") as StyleBoxTexture
	var other_style := (other.get_node("%MessagePanel") as PanelContainer).get_theme_stylebox("panel") as StyleBoxTexture
	var shared_style := THEME.get_stylebox("panel", &"AdvMessagePanel") as StyleBoxTexture
	var other_alpha := other_style.modulate_color.a
	var shared_alpha := shared_style.modulate_color.a
	view.set_frame_opacity(0.25)
	_expect(style != other_style and style != shared_style, "Each view must own a distinct mutable frame style.")
	_expect(is_equal_approx(style.modulate_color.a, 0.25) and is_equal_approx(other_style.modulate_color.a, other_alpha) and is_equal_approx(shared_style.modulate_color.a, shared_alpha), "Frame opacity must not mutate other views or the shared Theme.")
	_expect(panel.modulate == Color.WHITE and label.modulate == Color.WHITE and portrait.modulate == Color.WHITE and speaker.modulate == Color.WHITE, "Frame opacity must not fade text, speaker, or portrait.")
	_expect(label.get_theme_font("normal_font") == THEME.default_font, "Extraction must retain the project's message font.")


func _test_input_seam(view: AdvDialogueView) -> void:
	var hidden: Array[bool] = []
	var events: Array[InputEvent] = []
	view.hide_requested.connect(func() -> void: hidden.append(true))
	view.frame_gui_input.connect(func(event: InputEvent) -> void: events.append(event))
	var button := view.get_node("%MessageHideButton") as TextureButton
	var panel := view.get_node("%MessagePanel") as PanelContainer
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	button.pressed.emit()
	panel.gui_input.emit(event)
	_expect(hidden.size() == 1 and events == [event] and view.is_frame_visible(), "The view emits requests without implementing gameplay policy.")
	view.set_interactive(false)
	button.pressed.emit()
	panel.gui_input.emit(event)
	_expect(hidden.size() == 1 and events.size() == 1 and button.disabled and panel.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Read-only mode must suppress input and hide requests.")
	view.set_interactive(true)
	_expect(not button.disabled and button.focus_mode == Control.FOCUS_CLICK and panel.mouse_filter == Control.MOUSE_FILTER_PASS, "Interactive mode must restore original button/panel input behavior.")


func _test_reveal(view: AdvDialogueView) -> void:
	var completions: Array[bool] = []
	view.reveal_finished.connect(func() -> void: completions.append(true))
	var label := view.get_node("%MessageLabel") as RichTextLabel
	view.reveal_message("0123456789", 100)
	_expect(view.is_revealing() and label.visible_characters == 0, "Reveal must start at zero.")
	# Deterministic Tween stepping avoids wall-clock/frame-rate sensitive tests.
	view._reveal_tween.custom_step(0.3)
	_expect(label.visible_characters == 3 and completions.is_empty(), "Reveal must progressively display the current message.")
	var old_tween := view._reveal_tween
	view.set_reveal_speed(200)
	_expect(label.visible_characters == 3 and not old_tween.is_valid(), "A live speed change must retain progress and cancel the old timeline.")
	view._reveal_tween.custom_step(0.2)
	_expect(label.visible_characters == 4, "The new speed must apply to the remaining characters.")
	view.set_reveal_speed(10)
	view._reveal_tween.custom_step(0.02)
	_expect(label.visible_characters == 6, "Speeding up must continue, not restart, the same line.")
	view.finish_reveal()
	view.finish_reveal()
	_expect(not view.is_revealing() and label.visible_characters == -1 and label.text == "0123456789" and completions.size() == 1, "Finishing reveal must retain the line and emit exactly once.")
	view.reveal_message("old", 100)
	old_tween = view._reveal_tween
	view.reveal_message("new", 100)
	_expect(not old_tween.is_valid() and label.text == "new" and label.visible_characters == 0 and completions.size() == 1, "Replacing a reveal must not complete or retain the previous animation.")
	view._reveal_tween.custom_step(0.3)
	_expect(not view.is_revealing() and label.visible_characters == -1 and completions.size() == 2, "Natural completion must emit once and fully reveal the line.")
	view.reveal_message("cancel", 100)
	view._reveal_tween.custom_step(0.2)
	old_tween = view._reveal_tween
	view.cancel_reveal()
	_expect(not view.is_revealing() and not old_tween.is_valid() and label.visible_characters == 2 and completions.size() == 2, "Cancel must freeze presentation without a completion signal.")
	view.reveal_message("instant", 100)
	view.set_reveal_speed(0)
	view._reveal_tween.custom_step(0.002)
	_expect(not view.is_revealing() and completions.size() == 3, "Zero-speed reveal must complete once without per-character timers.")
	view.reveal_message("", 20)
	view.finish_reveal()
	_expect(not view.is_revealing() and completions.size() == 4, "Empty dialogue must finish exactly once.")


func _test_frame_transitions(view: AdvDialogueView) -> void:
	var rest := Vector2(0, 760)
	view.restore_frame_state(rest, 1.0, true)
	view.set_frame_visible(false, 0.3)
	view._frame_tween.custom_step(0.15)
	_expect(view.is_frame_visible() and is_equal_approx(view.frame_alpha(), 0.5) and view.frame_position() == rest, "Script hide must fade without sliding.")
	view.finish_frame_transition()
	_expect(not view.is_frame_visible() and is_zero_approx(view.frame_alpha()), "Script hide must settle hidden and transparent.")
	view.set_frame_visible(true, 0.3)
	view._frame_tween.custom_step(0.15)
	_expect(view.is_frame_visible() and is_equal_approx(view.frame_alpha(), 0.5) and view.frame_position() == rest, "Script show must fade without sliding.")
	view._frame_tween.custom_step(0.15)
	_expect(view.is_frame_visible() and is_equal_approx(view.frame_alpha(), 1.0), "Animated show must settle fully opaque.")
	view.set_frame_visible(false, 0.0)
	_expect(not view.is_frame_visible() and view._frame_tween == null, "Immediate hide must not allocate a Tween.")
	view.set_frame_visible(true, 0.0)
	_expect(view.is_frame_visible() and is_equal_approx(view.frame_alpha(), 1.0) and view._frame_tween == null, "Immediate show must finish synchronously.")
	view.restore_frame_state(Vector2(25, 650), 0.8, true)
	view.set_chrome_visible(false, 0.3)
	view._frame_tween.custom_step(0.15)
	_expect(view.frame_position().y > 650 and view.frame_alpha() < 0.8, "Manual hide must slide downward and fade.")
	view.finish_frame_transition()
	_expect(not view.is_frame_visible() and view.frame_position() == Vector2(25, 650) and is_equal_approx(view.frame_alpha(), 0.8), "Hidden chrome must retain its resting position and alpha.")
	view.set_chrome_visible(true, 0.3)
	_expect(view.frame_position() == Vector2(25, 770) and is_zero_approx(view.frame_alpha()), "Manual show must begin below the resting frame.")
	view._frame_tween.custom_step(0.3)
	_expect(view.is_frame_visible() and view.frame_position() == Vector2(25, 650) and is_equal_approx(view.frame_alpha(), 0.8), "Manual show must restore the saved resting frame.")
	view.set_chrome_visible(false, 0.0)
	_expect(not view.is_frame_visible() and view._frame_tween == null, "Overlay hide must finish synchronously.")
	view.set_chrome_visible(true, 0.0)
	_expect(view.is_frame_visible() and view.frame_position() == Vector2(25, 650) and is_equal_approx(view.frame_alpha(), 0.8) and view._frame_tween == null, "Overlay return must synchronously restore the same frame.")
	var panel := view.get_node("%MessagePanel") as Control
	for frame_type in ["10", "ノベル"]:
		view.apply_frame_type(frame_type)
		_expect(panel.position == Vector2.ZERO and panel.size == Vector2(1920, 1080), "Novel frames must fill the design surface.")
	view.apply_frame_type("0")
	_expect(panel.position == rest and panel.size == Vector2(1920, 320), "Normal frame must restore the original bottom rectangle.")
	view.set_frame_position(Vector2(30, 700))
	view.set_frame_displayed(false)
	_expect(view.frame_position() == Vector2(30, 700) and not view.is_frame_visible() and is_equal_approx(view.frame_alpha(), 0.8), "Move/display operations must preserve scenario alpha.")


func _test_permanent_frame_layout(view: AdvDialogueView) -> void:
	var panel := view.get_node("%MessagePanel") as Control
	view.restore_frame_state(Vector2(0, 760), 1.0, true)
	view.set_frame_position(Vector2(30, 700))
	# Direct show must also respect a permanent move without first hiding.
	view.set_chrome_visible(true, 0.0)
	_expect(view.frame_position() == Vector2(30, 700), "Permanent moves must immediately update rest position.")
	for frame_type in ["10", "ノベル", "0"]:
		view.apply_frame_type(frame_type)
		var expected_position := Vector2(0, 760) if frame_type == "0" else Vector2.ZERO
		var expected_size := Vector2(1920, 320) if frame_type == "0" else Vector2(1920, 1080)
		view.set_chrome_visible(true, 0.0)
		_expect(view.frame_position() == expected_position, "Frame type must immediately update rest position.")
		view.set_chrome_visible(false)
		view.finish_frame_transition()
		view.set_chrome_visible(true)
		view.finish_frame_transition()
		_expect(view.frame_position() == expected_position and panel.size == expected_size, "Frame types must survive animated hide/show.")
	view.set_frame_position(Vector2(40, 680))
	view.set_chrome_visible(false)
	view._frame_tween.custom_step(0.15)
	_expect(view._rest_position == Vector2(40, 680) and view.frame_position().y > 680, "Temporary slide positions must not replace rest state.")
	view.set_chrome_visible(true)
	view.finish_frame_transition()
	_expect(view.frame_position() == Vector2(40, 680), "Custom movewindow must survive interrupted hide/show.")
	view.set_chrome_visible(false)
	view._frame_tween.custom_step(0.15)
	var old_tween := view._frame_tween
	view.set_frame_position(Vector2(30, 700))
	_expect(not old_tween.is_valid() and view.frame_position() == Vector2(30, 700), "Permanent moves must cancel an old slide.")
	view.set_chrome_visible(false, 0.0)
	view.set_chrome_visible(true, 0.0)
	_expect(view.frame_position() == Vector2(30, 700) and is_equal_approx(view.frame_alpha(), 1.0), "An interrupted animation must not become the next rest position or opacity.")
	view.set_chrome_visible(false)
	view._frame_tween.custom_step(0.15)
	view.apply_frame_type("10")
	view.set_chrome_visible(true, 0.0)
	_expect(view.frame_position() == Vector2.ZERO and panel.size == Vector2(1920, 1080), "Frame type changes during a slide must replace its resting layout.")


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)

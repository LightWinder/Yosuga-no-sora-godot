extends SceneTree

var _failures: Array[String] = []
var _test_root := "/tmp/yosuga-save-load-contract-%d" % Time.get_ticks_usec()


class TrackingSaveService extends SaveService:
	var quick_history_reads := 0

	func load_quick_history() -> Array[SaveData]:
		quick_history_reads += 1
		return super.load_quick_history()


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var service := TrackingSaveService.new()
	service.name = "ContractSaveService"
	service.configure_storage(_test_root)
	root.add_child(service)
	var source := SaveData.create_empty("save-contract")
	source.scenario_id = "00_z001"
	source.instruction_anchor = "hitret:1"
	source.choice_history = [1, 2]
	source.comment = SaveData.default_comment("穹", "当前对话")
	source.preview_image = Image.create(1920, 1080, false, Image.FORMAT_RGB8)
	source.preview_image.fill(Color.CORNFLOWER_BLUE)
	_expect(SaveService.MAX_SLOT_COUNT == 900, "Original manual capacity is 900.")
	_expect(service.save_slot(899, source), "Last manual slot must be writable.")
	var saved := service.load_slot(899)
	_expect(saved != null and not saved.thumbnail_webp.is_empty(), "Save includes compressed screenshot.")
	var preview := Image.new()
	_expect(preview.load_webp_from_buffer(Marshalls.base64_to_raw(saved.thumbnail_webp)) == OK, "Screenshot decodes independently of imported resources.")
	_expect(preview.get_size() == Vector2i(960, 540), "Thumbnail covers the 4K preview without storing a full framebuffer.")
	_expect(source.thumbnail_webp.is_empty(), "Service must not mutate the caller's snapshot.")
	_expect(service.copy_slot(899, 0), "Copy can target a different manual slot.")
	var copied := service.load_slot(0)
	_expect(copied.saved_at_unix == saved.saved_at_unix and copied.thumbnail_webp == saved.thumbnail_webp and copied.choice_history == saved.choice_history, "Copy preserves time, screenshot and replay state.")
	_expect(service.set_slot_locked(0, true), "Occupied manual slots can be locked.")
	var previous_print_errors := Engine.print_error_messages
	Engine.print_error_messages = false
	var locked_save := service.save_slot(0, source)
	Engine.print_error_messages = previous_print_errors
	_expect(not locked_save, "Lock prevents overwrite.")
	Engine.print_error_messages = false
	var locked_copy := service.copy_slot(899, 0)
	Engine.print_error_messages = previous_print_errors
	_expect(not locked_copy, "Lock prevents copy overwrite.")
	Engine.print_error_messages = false
	var locked_clear := service.clear_slot(0)
	Engine.print_error_messages = previous_print_errors
	_expect(not locked_clear, "Lock prevents deletion.")
	Engine.print_error_messages = false
	var locked_move := service.move_slot(0, 1)
	Engine.print_error_messages = previous_print_errors
	_expect(not locked_move, "Lock prevents moving its source.")
	_expect(service.set_slot_locked(0, false), "Unlock restores management.")
	_expect(service.set_slot_comment(0, "我的备注"), "Manual comments persist.")
	_expect(service.load_slot(0).comment_edit, "Manual comment replacement sets the source-compatible edit marker.")
	_expect(service.move_slot(0, 1), "Move commits destination then removes source.")
	_expect(service.load_slot(0) == null and service.load_slot(1).comment == "我的备注", "Move preserves annotation and removes original.")
	source.instruction_anchor = "hitret:2"
	source.preview_image.fill(Color.TOMATO)
	_expect(service.save_slot(899, source), "Overwrite saves a new matching image.")
	_expect(service.restore_slot_backup(899), "Backup recovery remains available.")
	var recovered := service.load_slot(899)
	_expect(recovered.instruction_anchor == "hitret:1" and recovered.thumbnail_webp == saved.thumbnail_webp, "Backup restores story and its own screenshot together.")
	_expect(service.save_autosave(source), "Continue autosave remains independent.")
	for index in 12:
		source.instruction_anchor = "quick:%d" % index
		_expect(service.save_quick(source), "Quick save writes successfully.")
	_expect(service.load_quick(0).instruction_anchor == "quick:11", "Quick history starts with newest.")
	_expect(service.load_quick(8).instruction_anchor == "quick:3", "Quick ring retains nine newest saves.")
	_expect(service.load_quick(9) == null, "Quick ring is bounded.")
	var quick_history := service.load_quick_history()
	_expect(
		quick_history.size() == SaveService.QUICK_SAVE_COUNT
		and quick_history[0].instruction_anchor == "quick:11"
		and quick_history[8].instruction_anchor == "quick:3",
		"The complete quick history can be loaded in one ordered storage pass."
	)
	_expect(service.load_autosave().instruction_anchor == "hitret:2", "Quick save must not replace Continue autosave.")
	_expect(service.load_path(service.quick_save_path()).instruction_anchor == "quick:11", "Quick paths resolve through the neutral service contract.")
	service.free()
	service = TrackingSaveService.new()
	service.name = "ReopenedSaveService"
	service.configure_storage(_test_root)
	root.add_child(service)
	_expect(service.load_quick().instruction_anchor == "quick:11", "Quick ordering survives service restart.")
	var legacy := SaveData.from_dictionary({
		"schema_version": 4,
		"scenario_id": "legacy",
		"instruction_anchor": "hitret:1",
		"autosave_meta": {"label": "旧版对话"},
	})
	_expect(legacy != null and not legacy.locked and legacy.thumbnail_webp.is_empty(), "Old saves migrate with optional defaults.")
	_expect(
		legacy.comment == "旧版对话"
		and not legacy.comment_edit
		and not legacy.autosave_meta.has("label"),
		"Old dialogue labels migrate into the single editable comment field."
	)
	await _test_page(service)
	await _test_confirmation_preferences(service)
	service.free()
	_remove_tree(ProjectSettings.globalize_path(_test_root))
	if _failures.is_empty():
		print("Save/load storage contracts passed.")
	quit(0 if _failures.is_empty() else 1)


func _test_page(service: SaveService) -> void:
	var scene := load("res://src/save_load/save_load_page.tscn") as PackedScene
	var page := scene.instantiate() as SaveLoadPage
	page.name = "ContractSavePage"
	page.configure(SaveLoadPage.Mode.LOAD, service)
	root.add_child(page)
	await process_frame
	var preview := page.get_node("VisualCanvas/PageLayout/ContentMargin/Main/PreviewPanel/PreviewMargin/PreviewColumn/PreviewAspect/PreviewFrame") as Control
	var details := page.get_node("VisualCanvas/PageLayout/ContentMargin/Main/PreviewPanel/PreviewMargin/PreviewColumn/DetailsMargin") as Control
	var move_button := page.get_node("%Move") as Button
	var copy_button := page.get_node("%Copy") as Button
	_expect(absf(preview.size.x / preview.size.y - 16.0 / 9.0) < 0.01, "Left preview stays 16:9.")
	_expect(details.global_position.y >= preview.global_position.y + preview.size.y * preview.get_global_transform().get_scale().y, "Aspect preview must reserve vertical space before its metadata.")
	_expect(
		move_button.get_parent() == copy_button.get_parent()
		and move_button.get_parent().get_parent() is PanelContainer
		and page.get_node_or_null("%Lock") == null,
		"Move belongs with copy/delete in the shared footer action panel, while locking remains card-owned."
	)
	var delete_button := page.get_node("%Delete") as Button
	var action_row := move_button.get_parent() as HBoxContainer
	_expect(
		action_row.get_theme_constant("separation") > move_button.get_theme_constant("h_separation"),
		"Footer buttons must sit farther apart than each icon sits from its label."
	)
	_expect(
		delete_button.get_theme_constant("icon_max_width") == 36
		and copy_button.get_theme_constant("icon_max_width") == 28
		and move_button.get_theme_constant("icon_max_width") == 28
		and delete_button.icon.get_width() >= 72
		and copy_button.icon.get_width() >= 56
		and move_button.icon.get_width() >= 56,
		"Footer icons must use high-resolution sources with normalized visual widths."
	)
	var empty_card: SaveSlotCard
	for card in page.slot_cards():
		if card.slot_id == 2:
			empty_card = card
			break
	_expect(
		empty_card != null
		and (empty_card.get_node("%EmptyPreview") as Control).visible
		and not (empty_card.get_node("%Plus") as Label).visible
		and empty_card.disabled
		and not (empty_card.get_node("%MissingPreview") as Control).visible
		and not (empty_card.get_node("%MetadataMargin") as Control).visible,
		"Load mode must center a plain empty state without selecting it or showing a destination plus."
	)
	var occupied_card: SaveSlotCard
	for card in page.slot_cards():
		if card.slot_id == 1:
			occupied_card = card
			break
	_expect(
		occupied_card != null
		and (occupied_card.get_node("%Thumbnail") as TextureRect).visible
		and (occupied_card.get_node("%BlurredThumbnail") as TextureRect).visible
		and (occupied_card.get_node("%MetadataMargin") as Control).visible
		and occupied_card.get_node("%MetadataMargin").get_parent().get_parent() == occupied_card.get_node("%Thumbnail").get_parent()
		and (occupied_card.get_node("%Thumbnail") as TextureRect).size.y
			> (occupied_card.get_node("%Thumbnail") as TextureRect).size.x * 9.0 / 16.0
		and (occupied_card.get_node("%Thumbnail") as TextureRect).stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_COVERED
		and (occupied_card.get_node("%MetadataMargin") as Control).position.y
			> (occupied_card.get_node("%Thumbnail") as TextureRect).size.y * 0.5,
		"Occupied slots must cover the taller image well and place metadata over its gradient-blurred lower edge."
	)
	_expect(
		SaveThumbnail.texture_for(occupied_card.save_data) == (occupied_card.get_node("%Thumbnail") as TextureRect).texture,
		"A bound save reuses its decoded thumbnail for the card and selected preview."
	)
	var occupied_preview := occupied_card.get_node("%PreviewFrame") as Control
	_expect(
		is_equal_approx(
			occupied_preview.global_position.y - occupied_card.global_position.y,
			occupied_preview.global_position.x - occupied_card.global_position.x
		),
		"Occupied slot images must reach the same card inset at the top and sides."
	)
	var first_card := page.slot_cards()[0]
	var next_column := page.slot_cards()[1]
	var next_row := page.slot_cards()[4]
	var horizontal_gap := next_column.position.x - first_card.position.x - first_card.size.x
	var vertical_gap := next_row.position.y - first_card.position.y - first_card.size.y
	var slot_panel := page.get_node("VisualCanvas/PageLayout/ContentMargin/Main/SlotPanel") as Control
	var top_margin := first_card.global_position.y - slot_panel.global_position.y
	var bottom_margin := slot_panel.global_position.y + slot_panel.size.y - (page.slot_cards()[11].global_position.y + page.slot_cards()[11].size.y)
	_expect(
		is_equal_approx(horizontal_gap, vertical_gap)
		and is_equal_approx(top_margin, bottom_margin),
		"The 4×3 save grid must use equal row/column gaps and equal outer-panel top/bottom margins."
	)
	var comment_edit := page.get_node("%CommentEdit") as LineEdit
	_expect(
		page.selected_slot_id() >= 0
		and comment_edit.text == service.load_slot(page.selected_slot_id()).comment
		and comment_edit.max_length == SaveData.COMMENT_MAX_LENGTH,
		"Load mode selects the first occupied entry and exposes its source-compatible comment."
	)
	page.scroll_to_entry(899)
	await process_frame
	_expect(
		comment_edit.text == service.load_slot(899).comment,
		"Selecting a save loads its dialogue comment into that same field."
	)
	for card in page.slot_cards():
		if card.slot_id == 899:
			var lock_button := card.get_node("%LockButton") as Button
			var slot_number := card.get_node("%SlotNumber") as Label
			var card_button := card.get_node("%CardButton") as Button
			_expect(
				lock_button.visible
				and lock_button.global_position.x > slot_number.global_position.x
				and lock_button.mouse_filter == Control.MOUSE_FILTER_STOP
				and lock_button.get_parent() == card
				and card_button.get_parent() == card
				and card.focus_mode == Control.FOCUS_NONE
				and card_button.focus_mode == Control.FOCUS_ALL
				and lock_button.get_index() > card_button.get_index()
				and absf(
					slot_number.global_position.x - card.global_position.x
					- (slot_number.global_position.y - card.global_position.y)
				) < 0.5
				and absf(
					card.global_position.x + card.size.x
					- (lock_button.global_position.x + lock_button.size.x)
					- (lock_button.global_position.y - card.global_position.y)
				) < 0.5,
				"The lock and focusable full-card action must be sibling buttons, with the lock owning the upper-right hit area."
			)
			_expect(page.get("_selected_data") == card.save_data, "Selecting a visible slot reuses its loaded data instead of performing synchronous I/O again.")
	(page.get_node("%Copy") as Button).pressed.emit()
	page.scroll_to_entry(2)
	for card in page.slot_cards():
		if card.slot_id == 2:
			_expect(not card.disabled and (card.get_node("%Plus") as Label).visible, "Transfer mode marks empty manual destinations with a plus and enables selection.")
			(card.get_node("%CardButton") as Button).pressed.emit()
	_expect(page.is_confirmation_visible(), "Copy destination requires a reviewable confirmation.")
	page.cancel_delete_confirmation()
	_expect(service.load_slot(2) == null, "Cancel must not write the copy destination.")
	for card in page.slot_cards():
		if card.slot_id == 2:
			(card.get_node("%CardButton") as Button).pressed.emit()
	page.confirm_delete_confirmation()
	_expect(service.load_slot(2) != null and service.load_slot(899) != null, "UI copy writes the destination and preserves its source.")
	(page.get_node("%Move") as Button).pressed.emit()
	for card in page.slot_cards():
		if card.slot_id == 3:
			(card.get_node("%CardButton") as Button).pressed.emit()
	page.confirm_delete_confirmation()
	_expect(service.load_slot(2) == null and service.load_slot(3) != null, "UI move commits the target then removes its source.")
	var requests: Array[String] = []
	page.load_requested.connect(func(_data: SaveData, path: String) -> void: requests.append(path))
	page.scroll_to_entry(3)
	for card in page.slot_cards():
		if card.slot_id == 3:
			var card_button := card.get_node("%CardButton") as Button
			var play_layer := card.get_node("%LoadActionLayer") as Control
			var play_indicator := card.get_node("%LoadIndicator") as Control
			var play_icon := card.get_node("%LoadIcon") as TextureRect
			if card._load_action_tween != null:
				card._load_action_tween.custom_step(0.11)
			card.set_selected(false)
			card_button.release_focus()
			_expect(play_layer.visible and not card_button.disabled, "Deselecting fades the load cue while keeping the full-card selection action available.")
			card._load_action_tween.custom_step(0.05)
			_expect(play_layer.modulate.a > 0.0 and play_layer.modulate.a < 1.0, "The load action must fade out over time.")
			card._load_action_tween.custom_step(0.06)
			_expect(not play_layer.visible and is_zero_approx(play_layer.modulate.a), "The load action hides after its 100 ms fade-out.")
			card_button.pressed.emit()
			_expect(requests.is_empty(), "The first full-card activation selects an unselected slot without loading it.")
			_expect(play_layer.visible and is_zero_approx(play_layer.modulate.a), "Selection starts the load cue from transparent.")
			card._load_action_tween.custom_step(0.05)
			_expect(play_layer.modulate.a > 0.0 and play_layer.modulate.a < 1.0, "The load action must fade in over time.")
			card._load_action_tween.custom_step(0.06)
			_expect(is_equal_approx(play_layer.modulate.a, 1.0), "The load action reaches full opacity after its 100 ms fade-in.")
			_expect(
				absf(
					play_indicator.position.y + play_indicator.size.y * 0.5 + 5.0
					- play_layer.size.y * 0.5
				) < 0.5,
				"The selected load icon must sit five pixels above the full-card center."
			)
			card_button.pressed.emit()
	_expect(page.is_confirmation_visible() and requests.is_empty(), "Read waits for confirmation.")
	page.confirm_delete_confirmation()
	_expect(requests == [service.slot_path(3)], "The image action loads its own slot without a footer action.")
	page.scroll_to_entry(899)
	await process_frame
	for card in page.slot_cards():
		if card.slot_id == 899:
			var right := InputEventAction.new()
			right.action = &"ui_right"
			right.pressed = true
			right.device = 0
			(card.get_node("%CardButton") as Button).gui_input.emit(right)
	_expect(page.selected_slot_id() == SaveService.MAX_SLOT_COUNT, "Keyboard movement selects the next occupied logical slot across a virtual list.")
	var list := page.get_node("%SlotList") as SaveSlotList
	_expect(list.get_node("%Items").get_child_count() == 20, "900 slots must use a bounded 20-card pool.")
	var quick_history_reads_before_scroll := int(service.get("quick_history_reads"))
	page.scroll_to_entry(SaveService.MAX_SLOT_COUNT)
	await process_frame
	_expect(
		int(service.get("quick_history_reads")) == quick_history_reads_before_scroll,
		"Scrolling into quick saves reuses the page snapshot instead of rescanning storage."
	)
	var quick_badge_found := false
	for card in page.slot_cards():
		if card.is_quick_save():
			var kind_badge := card.get_node("%KindBadge") as Label
			quick_badge_found = quick_badge_found or (
				kind_badge.visible
				and kind_badge.text == "快速"
				and kind_badge.get_theme_color("font_color").r > 0.95
				and kind_badge.get_theme_color("font_color").g > 0.95
				and kind_badge.get_theme_color("font_color").b > 0.95
			)
			_expect(
				not (card.get_node("%LockButton") as Button).visible,
				"Quick-save cards must not expose the manual-slot lock action."
			)
	_expect(quick_badge_found, "Quick-save cards label their kind in white at the upper right.")
	page.scroll_to_entry(SaveService.MAX_SLOT_COUNT + SaveService.QUICK_SAVE_COUNT)
	await process_frame
	var autosave_badge_hidden := false
	for card in page.slot_cards():
		if card.is_autosave:
			autosave_badge_hidden = not (card.get_node("%KindBadge") as Label).visible
			break
	_expect(autosave_badge_hidden, "The autosave card omits the redundant upper-right kind label.")
	page.free()
	await process_frame


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error(message)


func _remove_tree(path: String) -> void:
	for file in DirAccess.get_files_at(path):
		DirAccess.remove_absolute(path.path_join(file))
	for directory in DirAccess.get_directories_at(path):
		_remove_tree(path.path_join(directory))
	DirAccess.remove_absolute(path)


func _test_confirmation_preferences(service: SaveService) -> void:
	var settings := SettingsRepository.new()
	settings.configure_storage(_test_root + "/confirmations.json")
	var payload := SaveData.create_empty("confirmation-test")
	payload.scenario_id = "00_z001"
	payload.comment = "new"
	var page := load("res://src/save_load/save_load_page.tscn").instantiate() as SaveLoadPage
	page.configure(SaveLoadPage.Mode.SAVE, service, payload, settings)
	root.add_child(page)
	await process_frame
	var dialog := page.get_node("%ConfirmationOverlay") as ConfirmationOverlay
	for key in ["overwrite", "delete", "copy", "move", "load"]:
		var old := SaveData.create_empty("old")
		old.scenario_id = "00_z001"
		old.comment = "old"
		service.save_slot(10, old)
		service.clear_slot(11)
		page.mode = SaveLoadPage.Mode.LOAD if key == "load" else SaveLoadPage.Mode.SAVE
		page._on_slot_pressed(10, false)
		var loaded: Array[String] = []
		var listener := func(_data: SaveData, path: String) -> void: loaded.append(path)
		page.load_requested.connect(listener)
		var request: Callable
		match key:
			"overwrite": request = page._on_primary_pressed
			"delete": request = page._request_delete
			"copy", "move":
				page._begin_transfer(key == "move")
				request = page._choose_transfer_destination.bind(11, false)
			"load": request = page._on_slot_load_requested.bind(10, false)
		request.call()
		_expect(dialog.is_open(), key + " opens confirmation when enabled")
		_expect(service.has_slot(10) and not service.has_slot(11) and loaded.is_empty(), key + " must not execute before acceptance")
		page.cancel_delete_confirmation()
		_expect(service.load_slot(10).comment == "old" and loaded.is_empty(), key + " cancel preserves source")
		request.call()
		dialog.always_toggled.emit(false)
		page.cancel_delete_confirmation()
		var reopened := SettingsRepository.new()
		reopened.configure_storage(_test_root + "/confirmations.json")
		_expect(not reopened.confirmation_enabled(key), key + " always-ask persists even on cancel")
		request.call()
		_expect(not dialog.is_open(), key + " disabled runs without a dialog")
		match key:
			"overwrite": _expect(service.load_slot(10).comment == "new", "Disabled overwrite writes payload")
			"delete": _expect(not service.has_slot(10), "Disabled delete removes source")
			"copy": _expect(service.has_slot(10) and service.has_slot(11), "Disabled copy preserves source")
			"move": _expect(not service.has_slot(10) and service.has_slot(11), "Disabled move removes source")
			"load": _expect(loaded == [service.slot_path(10)], "Disabled load emits once")
		page.load_requested.disconnect(listener)
	page.free()

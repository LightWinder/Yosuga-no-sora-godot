extends SceneTree

var _failures: Array[String] = []
var _test_root := "/tmp/yosuga-save-load-contract-%d" % Time.get_ticks_usec()


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var service := SaveService.new()
	service.name = "ContractSaveService"
	service.configure_storage(_test_root)
	root.add_child(service)
	var source := SaveData.create_empty("save-contract")
	source.scenario_id = "00_z001"
	source.instruction_anchor = "hitret:1"
	source.choice_history = [1, 2]
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
	_expect(not service.save_slot(0, source), "Lock prevents overwrite.")
	_expect(not service.copy_slot(899, 0), "Lock prevents copy overwrite.")
	_expect(not service.clear_slot(0), "Lock prevents deletion.")
	_expect(not service.move_slot(0, 1), "Lock prevents moving its source.")
	_expect(service.set_slot_locked(0, false), "Unlock restores management.")
	_expect(service.set_slot_comment(0, "我的备注"), "Manual comments persist.")
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
	_expect(service.load_autosave().instruction_anchor == "hitret:2", "Quick save must not replace Continue autosave.")
	_expect(service.load_path(service.quick_save_path()).instruction_anchor == "quick:11", "Quick paths resolve through the neutral service contract.")
	service.free()
	service = SaveService.new()
	service.name = "ReopenedSaveService"
	service.configure_storage(_test_root)
	root.add_child(service)
	_expect(service.load_quick().instruction_anchor == "quick:11", "Quick ordering survives service restart.")
	var legacy := SaveData.from_dictionary({"schema_version": 4, "scenario_id": "legacy", "instruction_anchor": "hitret:1"})
	_expect(legacy != null and not legacy.locked and legacy.thumbnail_webp.is_empty(), "Old saves migrate with optional defaults.")
	await _test_page(service)
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
	_expect(absf(preview.size.x / preview.size.y - 16.0 / 9.0) < 0.01, "Left preview stays 16:9.")
	_expect(details.global_position.y >= preview.global_position.y + preview.size.y * preview.get_global_transform().get_scale().y, "Aspect preview must reserve vertical space before its metadata.")
	page.scroll_to_entry(899)
	await process_frame
	(page.get_node("%Copy") as Button).pressed.emit()
	page.scroll_to_entry(2)
	for card in page.slot_cards():
		if card.slot_id == 2:
			card.pressed.emit()
	_expect(page.is_confirmation_visible(), "Copy destination requires a reviewable confirmation.")
	page.cancel_delete_confirmation()
	_expect(service.load_slot(2) == null, "Cancel must not write the copy destination.")
	for card in page.slot_cards():
		if card.slot_id == 2:
			card.pressed.emit()
	page.confirm_delete_confirmation()
	_expect(service.load_slot(2) != null and service.load_slot(899) != null, "UI copy writes the destination and preserves its source.")
	(page.get_node("%Move") as Button).pressed.emit()
	for card in page.slot_cards():
		if card.slot_id == 3:
			card.pressed.emit()
	page.confirm_delete_confirmation()
	_expect(service.load_slot(2) == null and service.load_slot(3) != null, "UI move commits the target then removes its source.")
	var requests: Array[String] = []
	page.load_requested.connect(func(_data: SaveData, path: String) -> void: requests.append(path))
	page.scroll_to_entry(3)
	for card in page.slot_cards():
		if card.slot_id == 3:
			var play := card.get_node("%LoadButton") as Button
			card.set_selected(false)
			card.release_focus()
			play.mouse_entered.emit()
			_expect(not play.visible and play.disabled, "Unselected slots must not reveal a load action on hover.")
			play.pressed.emit()
			_expect(requests.is_empty(), "An unselected slot cannot trigger loading.")
			card.set_selected(true)
			_expect(play.visible and not play.disabled, "Selection reveals and enables the image load action.")
			play.pressed.emit()
	_expect(requests == [service.slot_path(3)], "The image action loads its own slot without a footer action.")
	page.scroll_to_entry(450)
	await process_frame
	for card in page.slot_cards():
		if card.slot_id == 450:
			var right := InputEventAction.new()
			right.action = &"ui_right"
			right.pressed = true
			card.gui_input.emit(right)
	_expect(page.selected_slot_id() == 451, "Keyboard movement selects the next logical slot across a virtual list.")
	var list := page.get_node("%SlotList") as SaveSlotList
	_expect(list.get_node("%Items").get_child_count() == 20, "900 slots must use a bounded 20-card pool.")
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

class_name SettingsScreen
extends Control


## Route-level owner for the settings UI. It binds the editor to the
## feature-owned repository while SettingsPage remains persistence-agnostic.
signal back_requested
signal title_requested
signal read_flags_reset_requested
signal open_transition_finished

@export_range(0.0, 1.0, 0.01) var open_transition_seconds := 0.30
@export_range(0.0, 1.0, 0.01) var close_transition_seconds := 0.30
@export_range(0.0, 80.0, 1.0) var transition_offset_y := 18.0

@onready var _settings_page: SettingsPage = $SettingsPage

var _settings_repository: SettingsRepository
var _transition_tween: Tween
var _page_rest_position := Vector2.ZERO
var _closing := false
var _start_hidden := false
var _activated := false
var _gameplay_context := false


func configure(settings_repository: SettingsRepository, gameplay_context := false) -> void:
	_settings_repository = settings_repository
	_gameplay_context = gameplay_context
	if is_node_ready():
		_settings_page.set_gameplay_context(_gameplay_context)


func set_gameplay_context(gameplay_context: bool) -> void:
	_gameplay_context = gameplay_context
	if is_node_ready():
		_settings_page.set_gameplay_context(_gameplay_context)


func is_closing() -> bool:
	return _closing


## Completes scene construction, theme resolution and dynamic control creation
## ahead of the first open while remaining invisible and input-disabled.
func prepare_hidden() -> void:
	_start_hidden = true
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	(get_node("SettingsPage") as SettingsPage).prepare_hidden()


func _ready() -> void:
	if _settings_repository == null:
		_settings_repository = SettingsRepository.new()
	_settings_page.configure(_settings_repository.read_settings())
	_settings_page.set_gameplay_context(_gameplay_context)
	_settings_page.settings_preview_changed.connect(_on_settings_preview)
	_settings_page.settings_commit_requested.connect(_on_settings_commit)
	_settings_page.close_requested.connect(func() -> void: back_requested.emit())
	_settings_page.return_title_requested.connect(func() -> void: title_requested.emit())
	_settings_page.read_flags_reset_requested.connect(func() -> void: read_flags_reset_requested.emit())
	_page_rest_position = _settings_page.position
	if not _start_hidden:
		activate()


func _exit_tree() -> void:
	_kill_transition_tween()


func settings_page() -> SettingsPage:
	return _settings_page


func activate() -> void:
	if _activated:
		return
	_activated = true
	process_mode = Node.PROCESS_MODE_INHERIT
	visible = true
	_settings_page.call_deferred("grab_settings_focus")
	_play_open_transition()


func play_close_transition() -> void:
	if _closing:
		return
	_closing = true
	_kill_transition_tween()
	var tween := create_tween().set_parallel(true)
	_transition_tween = tween
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, close_transition_seconds)
	tween.tween_property(
		_settings_page,
		"position",
		_page_rest_position + Vector2(0.0, transition_offset_y),
		close_transition_seconds
	)
	await tween.finished
	if _transition_tween == tween:
		_transition_tween = null


func _play_open_transition() -> void:
	var start_modulate := modulate
	start_modulate.a = 0.0
	modulate = start_modulate
	_settings_page.position = _page_rest_position + Vector2(0.0, transition_offset_y)
	var tween := create_tween().set_parallel(true)
	_transition_tween = tween
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, open_transition_seconds)
	tween.tween_property(_settings_page, "position", _page_rest_position, open_transition_seconds)
	await tween.finished
	if _transition_tween == tween:
		_transition_tween = null
		open_transition_finished.emit()


func _kill_transition_tween() -> void:
	if _transition_tween != null and _transition_tween.is_valid():
		_transition_tween.kill()
	_transition_tween = null


func _on_settings_preview(settings: Dictionary) -> void:
	_settings_repository.preview_settings(settings)


func _on_settings_commit(settings: Dictionary) -> void:
	if _settings_repository.write_settings(settings):
		return
	var write_error := _settings_repository.last_error
	# Restore the durable snapshot so the visible selection never claims a
	# failed write was saved.
	var persisted := _settings_repository.read_settings()
	_settings_page.configure(persisted)
	_settings_page.report_error(tr("设置保存失败：%s") % write_error)

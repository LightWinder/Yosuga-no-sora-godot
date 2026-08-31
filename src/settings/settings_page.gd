class_name SettingsPage
extends DesignCanvasPage


## Settings editor coordinator. The three tab pages own their controls,
## SettingsChrome owns navigation/overlays, and this node owns only settings
## state, preview emission, persistence timing and reset business rules.
signal settings_preview_changed(settings: Dictionary)
signal settings_commit_requested(settings: Dictionary)
signal status_changed(message: String)
signal close_requested
signal read_flags_reset_requested

const COMMIT_DELAY := 0.25
const RESET_SETTINGS_ACTION := &"reset_settings"
const RESET_READ_ACTION := &"reset_read"

var _values: Dictionary = {}
var _pending_commit := false
var _defer_initial_focus := false

@onready var _commit_timer: Timer = $SettingsCommitTimer
@onready var _display_page: DisplaySettingsPage = $VisualCanvas/ContentContainer/DisplayPage
@onready var _system_page: SystemSettingsPage = $VisualCanvas/ContentContainer/SystemPage
@onready var _audio_page: AudioSettingsPage = $VisualCanvas/ContentContainer/AudioPage
@onready var _chrome: SettingsChrome = $VisualCanvas/Chrome


func configure(settings: Dictionary) -> void:
	_values = SettingsModel.normalize(settings)
	if is_inside_tree():
		_sync_pages()
		# Reconfiguration also covers rollback after a failed write. Publish the
		# restored snapshot without treating it as an edit or scheduling a commit.
		settings_preview_changed.emit(_values.duplicate(true))


## Lets the route owner finish this page's one-time scene setup in the
## background without stealing focus from the currently visible screen.
func prepare_hidden() -> void:
	_defer_initial_focus = true


func _ready() -> void:
	super._ready()
	_commit_timer.timeout.connect(_commit)
	for page in _all_pages():
		page.patch_requested.connect(_on_patch)
		page.commit_requested.connect(_commit)
	_connect_chrome()
	_sync_pages()
	_show_tab(SettingsChrome.Tab.DISPLAY)
	if not _defer_initial_focus:
		_chrome.grab_tab_focus()


func _exit_tree() -> void:
	if _pending_commit:
		_commit()


func _input(event: InputEvent) -> void:
	if _chrome.is_confirmation_active():
		return
	if _chrome.is_key_popup_active():
		if StartupInput.is_cancel_event(event):
			_chrome.close_key_popup()
			get_viewport().set_input_as_handled()
		return
	if StartupInput.is_cancel_event(event):
		close_requested.emit()
		get_viewport().set_input_as_handled()


## --- Public API ---

func get_current_settings() -> Dictionary:
	return _values.duplicate(true)


func find_setting_slider(key: String) -> SettingsKnobSlider:
	for page in _all_pages():
		var slider := page.find_setting_slider(key)
		if slider != null:
			return slider
	return null


func display_page() -> DisplaySettingsPage:
	return _display_page


func system_page() -> SystemSettingsPage:
	return _system_page


func audio_page() -> AudioSettingsPage:
	return _audio_page


func show_tab(index: int) -> void:
	_show_tab(index)


func current_tab() -> int:
	return _chrome.current_tab()


func grab_settings_focus() -> void:
	_chrome.grab_tab_focus()


func open_key_popup() -> void:
	_chrome.open_key_popup()


func close_key_popup() -> void:
	_chrome.close_key_popup()


func is_key_popup_visible() -> bool:
	return _chrome.is_key_popup_open()


func is_confirm_visible() -> bool:
	return _chrome.is_confirmation_open()


func report_error(message: String) -> void:
	_set_status(message)


func request_reset_settings() -> void:
	if not _confirmation_enabled("default"):
		_run_reset_settings()
		return
	_chrome.open_confirmation(RESET_SETTINGS_ACTION, "要初始化设定吗？", true)


func request_reset_read() -> void:
	if not _confirmation_enabled("clear_read"):
		_run_reset_read()
		return
	_chrome.open_confirmation(RESET_READ_ACTION, "要初始化已读情报吗？", true)


func confirm_pending_action() -> void:
	_chrome.accept_confirmation()


func cancel_pending_action() -> void:
	_chrome.cancel_confirmation()


## --- Scene coordination ---

func _connect_chrome() -> void:
	_chrome.tab_selected.connect(_show_tab)
	_chrome.reset_settings_requested.connect(request_reset_settings)
	_chrome.reset_read_requested.connect(request_reset_read)
	_chrome.close_requested.connect(func() -> void: close_requested.emit())
	_chrome.confirmation_accepted.connect(_run_action)
	_chrome.confirmation_canceled.connect(_on_confirmation_canceled)
	_chrome.confirmation_preference_changed.connect(_on_confirmation_preference_changed)


func _all_pages() -> Array[SettingsPageBase]:
	var pages: Array[SettingsPageBase] = []
	pages.assign([_display_page, _system_page, _audio_page])
	return pages


func _sync_pages() -> void:
	for page in _all_pages():
		page.sync_from(_values)


func _show_tab(index: int) -> void:
	var pages := _all_pages()
	index = clampi(index, SettingsChrome.Tab.DISPLAY, SettingsChrome.Tab.AUDIO)
	for page_index in pages.size():
		pages[page_index].visible = page_index == index
	_chrome.select_tab(index)
	_chrome.close_key_popup()


## --- Settings state ---

func _on_patch(patch: Dictionary, immediate: bool) -> void:
	_values = SettingsModel.apply_patch(_values, patch)
	# Sliders already own the value currently under the pointer. Re-syncing all
	# three pages for every drag event needlessly updates hidden controls and can
	# reload preview state dozens of times per second. Immediate button/toggle
	# changes still sync so programmatic callers receive the same visible state.
	if immediate:
		_sync_pages()
	_preview_and_debounce()
	if immediate:
		_commit()


func _preview_and_debounce() -> void:
	_pending_commit = true
	settings_preview_changed.emit(_values.duplicate(true))
	_commit_timer.start(COMMIT_DELAY)


func _commit() -> void:
	if not _pending_commit:
		return
	_commit_timer.stop()
	_pending_commit = false
	settings_commit_requested.emit(_values.duplicate(true))


## --- Confirmation and reset actions ---

func _confirmation_enabled(key: String) -> bool:
	var confirmations: Dictionary = _values.get("confirmations", {})
	return bool(confirmations.get(key, true))


func _confirmation_key_for_action(action: StringName) -> String:
	match action:
		RESET_SETTINGS_ACTION:
			return "default"
		RESET_READ_ACTION:
			return "clear_read"
	return ""


func _on_confirmation_preference_changed(action: StringName, checked: bool) -> void:
	var key := _confirmation_key_for_action(action)
	if not key.is_empty():
		_on_patch({"confirmations": {key: checked}}, true)


func _on_confirmation_canceled(_action: StringName) -> void:
	_set_status("已取消。")


func _run_action(action: StringName) -> void:
	match action:
		RESET_SETTINGS_ACTION:
			_run_reset_settings()
		RESET_READ_ACTION:
			_run_reset_read()


func _run_reset_settings() -> void:
	var preserved_mode: Variant = _values.get("window_mode", "windowed")
	var preserved_width: Variant = _values.get("window_width", 1280)
	_values = SettingsModel.defaults()
	_values["window_mode"] = preserved_mode
	_values["window_width"] = preserved_width
	_sync_pages()
	_set_status("已恢复初始设定。")
	_preview_and_debounce()
	_commit()


func _run_reset_read() -> void:
	read_flags_reset_requested.emit()
	_set_status("已读情报初始化请求已发出（正文运行层待迁移）。")


func _set_status(message: String) -> void:
	status_changed.emit(message)
	_chrome.show_status(message)

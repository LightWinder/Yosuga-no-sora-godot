class_name TitleConfigurationScreen
extends Control


## Route-level owner for the configuration UI. It keeps persistence and
## runtime preview wiring out of both StartupFlow and the generic feature
## browser, while TitleConfigurationPage remains a pure settings editor.
signal back_requested
signal read_flags_reset_requested

@onready var _configuration_page: TitleConfigurationPage = $ConfigurationPage

var _save_service: SaveService


func configure(save_service: SaveService) -> void:
	_save_service = save_service


func _ready() -> void:
	if _save_service == null:
		_save_service = SaveService.new()
		_save_service.name = "SaveService"
		add_child(_save_service)
	_configuration_page.configure(_save_service.read_settings())
	_configuration_page.settings_preview_changed.connect(_on_settings_preview)
	_configuration_page.settings_commit_requested.connect(_on_settings_commit)
	_configuration_page.close_requested.connect(func() -> void: back_requested.emit())
	_configuration_page.read_flags_reset_requested.connect(func() -> void: read_flags_reset_requested.emit())
	_configuration_page.call_deferred("grab_config_focus")


func configuration_page() -> TitleConfigurationPage:
	return _configuration_page


func _on_settings_preview(settings: Dictionary) -> void:
	_save_service.preview_settings(settings)


func _on_settings_commit(settings: Dictionary) -> void:
	if _save_service.write_settings(settings):
		return
	var write_error := _save_service.last_error
	# Restore the durable snapshot so the visible selection never claims a
	# failed write was saved.
	var persisted := _save_service.read_settings()
	_configuration_page.configure(persisted)
	_save_service.preview_settings(persisted)
	_configuration_page.report_error("设置保存失败：%s" % write_error)

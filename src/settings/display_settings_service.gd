class_name DisplaySettingsService
extends RefCounted


## Applies window-related settings to DisplayServer.  Keeps platform calls out
## of the settings pages; only mode/width are applied here, and only when the
## values actually change so slider previews never churn the OS window.
## window_depth (message box opacity) is preview-only until the ADV layer
## consumes it.
var _applied_mode := ""
var _applied_size := Vector2i.ZERO


func apply(settings: Dictionary) -> void:
	# Android/iOS own the window and safe-area policy. Never issue desktop
	# DisplayServer mode/size calls on those platforms.
	if _is_mobile_platform():
		return
	# Contract and visual-capture runs use Godot's headless display server. The
	# settings model still previews/persists normally, but there is no host
	# window to mutate in that environment.
	if DisplayServer.get_name() == "headless":
		return
	var mode := str(settings.get("window_mode", "windowed"))
	if mode != _applied_mode:
		_applied_mode = mode
		match mode:
			"fullscreen":
				DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			_:
				DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	var width := int(settings.get("window_width", 1280))
	if mode != "fullscreen" and width > 0 and not _is_mobile_platform():
		var target := Vector2i(width, int(float(width) * 9.0 / 16.0))
		if target != _applied_size:
			_applied_size = target
			DisplayServer.window_set_size(target)


func _is_mobile_platform() -> bool:
	return OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios")

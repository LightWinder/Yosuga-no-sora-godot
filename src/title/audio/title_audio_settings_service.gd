class_name TitleAudioSettingsService
extends RefCounted


## UI talks to this seam instead of reaching into AudioServer.  The service
## only applies buses that are already declared in default_bus_layout.tres.
func apply(settings: Dictionary) -> void:
	var names := {
		"master_volume": "Master",
		"bgm_volume": "BGM",
		"voice_volume": "Voice",
		"system_voice_volume": "SystemVoice",
		"env_se_volume": "EnvSE",
		"se_volume": "SE",
		"movie_volume": "Movie",
	}
	var mute_keys := {
		"master_volume": "mute_master",
		"bgm_volume": "mute_bgm",
		"voice_volume": "mute_voice",
		"system_voice_volume": "mute_system_voice",
		"env_se_volume": "mute_env_se",
		"se_volume": "mute_se",
		"movie_volume": "mute_movie",
	}
	for key in names:
		var bus_name := str(names[key])
		var bus_index := AudioServer.get_bus_index(bus_name)
		if bus_index < 0:
			continue
		AudioServer.set_bus_volume_db(bus_index, _volume_to_db(float(settings.get(key, 1.0))))
		AudioServer.set_bus_mute(bus_index, bool(settings.get(mute_keys[key], false)))


func _volume_to_db(value: float) -> float:
	if value <= 0.001:
		return -80.0
	return linear_to_db(clampf(value, 0.0, 1.0))

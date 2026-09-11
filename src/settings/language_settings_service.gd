class_name LanguageSettingsService
extends RefCounted


## Applies the UI language setting to TranslationServer. Locale switching is
## safe on every platform including headless runs, and re-translating standard
## Control text properties is handled by the engine itself. Keep the locale
## codes aligned with the columns of assets/locales/ui.csv.
var _applied_language := ""


func apply(settings: Dictionary) -> void:
	var language := str(settings.get("language", "zh"))
	if language == _applied_language:
		return
	_applied_language = language
	TranslationServer.set_locale(language)

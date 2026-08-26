#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
godot_executable="${GODOT_EXECUTABLE:-godot}"
verification_log="$(mktemp -t yosuga-godot-verify.XXXXXX.log)"
trap 'rm -f "$verification_log"' EXIT

required_files=(
	".gitattributes"
	"project.godot"
	"export_presets.cfg"
	"src/core/input/input_actions.gd"
	"src/core/audio/audio_settings_applier.gd"
	"src/core/persistence/atomic_json_store.gd"
	"src/core/save/save_data.gd"
	"src/core/save/profile_data.gd"
	"src/core/save/save_service.gd"
	"src/title/title_feature_screen.tscn"
	"src/title/title_exit_confirmation.tscn"
	"src/title/title_catalog.gd"
	"src/title/content/title_content_manifest.gd"
	"src/title/content/title_album_page.gd"
	"src/title/content/title_album_page.tscn"
	"src/title/content/title_album_viewer.gd"
	"src/title/content/title_album_viewer.tscn"
	"src/title/content/title_music_page.gd"
	"src/title/content/title_music_page.tscn"
	"src/title/content/title_memories_page.gd"
	"src/title/content/title_memories_page.tscn"
	"src/title/content/title_voice_page.gd"
	"src/title/content/title_voice_page.tscn"
	"src/title/voice/voice_collection_service.gd"
	"src/ui/design_canvas_page.gd"
	"src/ui/design_viewport_layout.gd"
	"src/settings/settings_page.gd"
	"src/settings/settings_page.tscn"
	"src/settings/settings_screen.gd"
	"src/settings/settings_screen.tscn"
	"src/settings/settings_model.gd"
	"src/settings/settings_chrome.gd"
	"src/settings/settings_chrome.tscn"
	"src/settings/settings_confirm_dialog.gd"
	"src/settings/settings_confirm_dialog.tscn"
	"src/settings/settings_key_popup.gd"
	"src/settings/settings_key_popup.tscn"
	"src/settings/settings_voice_sample.gd"
	"src/settings/display_settings_service.gd"
	"src/settings/persistence/settings_repository.gd"
	"src/settings/pages/settings_page_base.gd"
	"src/settings/pages/display_settings_page.gd"
	"src/settings/pages/display_settings_page.tscn"
	"src/settings/pages/system_settings_page.gd"
	"src/settings/pages/system_settings_page.tscn"
	"src/settings/pages/audio_settings_page.gd"
	"src/settings/pages/audio_settings_page.tscn"
	"src/settings/ui/settings_text_button.gd"
	"src/settings/ui/settings_tab_button.gd"
	"src/settings/ui/settings_check_button.gd"
	"src/settings/ui/settings_check_choice_button.gd"
	"src/settings/ui/settings_check_choice_button.tscn"
	"src/settings/ui/settings_selectable_button.gd"
	"src/settings/ui/settings_choice_button.gd"
	"src/settings/ui/settings_choice_group.gd"
	"src/settings/ui/settings_voice_choice_button.gd"
	"src/settings/ui/settings_voice_choice_button.tscn"
	"src/settings/ui/settings_section_title.gd"
	"src/settings/ui/settings_section_title.tscn"
	"src/settings/ui/settings_knob_slider.gd"
	"src/settings/ui/settings_knob_slider.tscn"
	"src/settings/ui/settings_modal.gd"
	"src/ui/page_title.gd"
	"src/ui/page_title.tscn"
	"src/scenario/scenario_launch_request.gd"
	"src/title/components/scenario_unavailable_notice.tscn"
	"assets/manifests/title_content_manifest.json"
	"assets/fonts/Xiaolai-Regular.fontdata"
	"assets/fonts/Xiaolai-Regular-OFL-1.1.txt"
	"assets/themes/yosuga_theme.tres"
	"assets/themes/fonts/settings_choice_font.tres"
	"assets/themes/fonts/settings_section_title_font.tres"
	"assets/themes/settings/common/empty_style.tres"
	"assets/themes/settings/choice/check_choice_empty.tres"
	"assets/themes/settings/choice/state_glow.tres"
	"assets/themes/settings/footer/focus.tres"
	"assets/themes/settings/footer/hover.tres"
	"assets/themes/settings/footer/pressed.tres"
	"assets/themes/settings/footer/primary_normal.tres"
	"assets/themes/settings/popup/action_row.tres"
	"assets/themes/settings/popup/key_row.tres"
	"assets/themes/settings/popup/panel.tres"
	"assets/themes/settings/section/portrait_frame.tres"
	"assets/themes/settings/section/title_strip.tres"
	"assets/themes/settings/slider/track.tres"
	"assets/themes/settings/slider/track_gradient.svg"
	"assets/themes/settings/slider/grabber.tres"
	"assets/themes/settings/slider/grabber_hover.tres"
	"assets/themes/settings/slider/grabber_disabled.tres"
	"assets/themes/ui/page_title/dot.tres"
	"assets/shaders/ui/settings_modal_blur.gdshader"
	"assets/shaders/ui/settings_modal_blur_material.tres"
	"assets/shaders/ui/settings_background_blur_material.tres"
	"assets/content/confirm/bg.png"
	"assets/content/confirm/yes.png"
	"assets/content/confirm/no.png"
	"assets/content/confirm/ask_always.png"
	"assets/content/settings/bg.png"
	"assets/content/settings/graphic/bg.png"
	"assets/content/event_1920/EA01E.png"
	"assets/audio/voice_samples/SR000029.ogg"
	"assets/audio/voice_samples/AK000006.ogg"
	"assets/audio/voice_samples/NO000009.ogg"
	"assets/audio/voice_samples/NP210001.ogg"
	"default_bus_layout.tres"
)
for required_file in "${required_files[@]}"; do
	if [[ ! -f "$project_root/$required_file" ]]; then
		echo "Missing required file: $required_file" >&2
		exit 1
	fi
done

for settings_asset in \
	"graphic/fullscreen1.png" "graphic/fullscreen2.png" \
	"graphic/window1.png" "graphic/window2.png" \
	"graphic/1080p1.png" "graphic/1080p2.png" \
	"graphic/900p1.png" "graphic/900p2.png" \
	"graphic/720p1.png" "graphic/720p2.png" \
	"graphic/ON1.png" "graphic/ON2.png" \
	"graphic/OFF1.png" "graphic/OFF2.png" \
	"graphic/textbox.png" "graphic/avatar.png" \
	"voices/portraits/sora.png" "voices/portraits/nao.png" "voices/portraits/akira.png" "voices/portraits/kazuha.png" "voices/portraits/motoka.png" "voices/portraits/ryohei.png" "voices/portraits/yahiro.png" "voices/portraits/kozue.png" "voices/portraits/npc.png"; do
	if [[ ! -f "$project_root/assets/content/settings/$settings_asset" ]]; then
		echo "Missing source HD settings visual asset: $settings_asset" >&2
		exit 1
	fi
done

for voice_sample in SR000029 AK000006 NO000009 KA000054 MT000006 RH000003 YH000005 KO000004 YM000002 SH040002 NP210001; do
	if [[ ! -f "$project_root/assets/audio/voice_samples/$voice_sample.ogg" ]]; then
		echo "Missing settings voice sample: $voice_sample.ogg" >&2
		exit 1
	fi
done

for video_name in yosugacn staff_roll_sora staff_roll_nao staff_roll_akira staff_roll_kazuha staff_roll_motoka; do
	if [[ ! -f "$project_root/assets/video/$video_name.ogv" ]]; then
		echo "Missing migrated video: $video_name.ogv" >&2
		exit 1
	fi
done
for music_name in BGM01 BGM02_S BGM03 BGM04 BGM05 BGM06 BGM07 BGM08 BGM09 BGM10 BGM11 BGM12 BGM13 BGM14 BGM15 BGM16 BGM17 BGM18 BGM19 BGM20 BGM21; do
	if [[ ! -f "$project_root/assets/audio/bgm/$music_name.ogg" ]]; then
		echo "Missing migrated BGM: $music_name.ogg" >&2
		exit 1
	fi
done

if rg -q '\.mp4(["/]|$)' "$project_root/assets/manifests/title_content_manifest.json"; then
	echo "Content manifest must not reference MP4 files; use Godot-decodable OGV assets." >&2
	exit 1
fi

for preset_name in "Windows Desktop" "macOS" "Android" "iOS"; do
	if ! rg -q "name=\"$preset_name\"" "$project_root/export_presets.cfg"; then
		echo "Missing export preset: $preset_name" >&2
		exit 1
	fi
done

require_pattern() {
	local pattern="$1"
	local target="$2"
	local message="$3"
	if ! rg -q "$pattern" "$target"; then
		echo "$message" >&2
		exit 1
	fi
}

require_pattern 'pointing/emulate_mouse_from_touch=true' "$project_root/project.godot" "Touch-to-mouse emulation must remain enabled."
require_pattern '\*\.ogv filter=lfs' "$project_root/.gitattributes" "Large video assets must remain covered by Git LFS."
require_pattern '\*\.png filter=lfs' "$project_root/.gitattributes" "Image assets must remain covered by Git LFS."
require_pattern 'vn_advance=' "$project_root/project.godot" "The vn_advance input action is missing."
require_pattern 'schema_version' "$project_root/src/core/save/save_data.gd" "SaveData must expose schema migration metadata."
require_pattern 'com.lightwinder.yosuganosora.hdremake' "$project_root/export_presets.cfg" "Export bundle identifiers are missing."
require_pattern 'theme/custom="res://assets/themes/yosuga_theme.tres"' "$project_root/project.godot" "The project CJK theme is not configured."
require_pattern 'default_bus_layout="res://default_bus_layout.tres"' "$project_root/project.godot" "The project audio bus layout is not configured."
require_pattern '"album_cards": 79' "$project_root/assets/manifests/title_content_manifest.json" "Album card manifest count changed unexpectedly."
require_pattern '"album_variants": 214' "$project_root/assets/manifests/title_content_manifest.json" "Album variant manifest count changed unexpectedly."
require_pattern '"memories": 24' "$project_root/assets/manifests/title_content_manifest.json" "Memory manifest count changed unexpectedly."
require_pattern '"music_tracks": 21' "$project_root/assets/manifests/title_content_manifest.json" "Music manifest count changed unexpectedly."
if rg -q 'title_screen_v2|title_screen_legacy|LegacyTitleScreen' "$project_root/src"; then
	echo "Obsolete Title implementation remains under src/." >&2
	exit 1
fi
if rg -q 'SettingsPage' "$project_root/src/title/title_feature_screen.gd"; then
	echo "The generic feature host must not own the settings route." >&2
	exit 1
fi
if rg -q 'ScenarioUnavailableNotice\.new|Title(Album|Music|Memories|Voice)Page\.new' "$project_root/src/title"; then
	echo "Reusable Title pages and overlays must be instantiated from scene resources." >&2
	exit 1
fi
require_pattern 'display_settings_page\.tscn' "$project_root/src/settings/settings_page.tscn" "Screen settings must remain a scene-owned subpage."
require_pattern 'settings_chrome\.tscn' "$project_root/src/settings/settings_page.tscn" "Settings navigation and overlays must remain a scene-owned chrome component."
require_pattern 'settings_screen\.tscn' "$project_root/src/app/startup_flow.gd" "StartupFlow must route settings through its dedicated scene."
require_pattern 'name="ContinueGame".*instance=' "$project_root/src/title/title_screen.tscn" "Title menu buttons must be declared as scene instances."
require_pattern 'parent="DesignRoot/CharacterLayer"' "$project_root/src/title/title_screen.tscn" "Title character layers must be declared by the scene."
require_pattern '^@tool' "$project_root/src/title/title_menu_button.gd" "Scene-owned Title buttons must preview their serialized artwork in the editor."
require_pattern 'name="CardList"' "$project_root/src/title/content/title_album_page.tscn" "Album fixed layout must be declared by its scene."
require_pattern 'name="TrackList"' "$project_root/src/title/content/title_music_page.tscn" "Music fixed layout must be declared by its scene."
require_pattern 'name="MemoryList"' "$project_root/src/title/content/title_memories_page.tscn" "Memories fixed layout must be declared by its scene."
require_pattern 'name="FavoriteList"' "$project_root/src/title/content/title_voice_page.tscn" "Voice fixed layout must be declared by its scene."
if rg -q '_build_shell|add_design_(label|button)' "$project_root/src/title/content" "$project_root/src/ui/design_canvas_page.gd"; then
	echo "Stable Title page chrome must remain scene-owned."
	exit 1
fi
if rg -q 'res://src/(settings|title)' "$project_root/src/core"; then
	echo "Core modules must not import feature-owned settings or title resources."
	exit 1
fi
require_pattern 'AtomicJsonStore\.new' "$project_root/src/core/save/save_service.gd" "SaveService must use the shared atomic JSON store."
require_pattern 'AtomicJsonStore\.new' "$project_root/src/title/voice/voice_collection_service.gd" "Voice favorites must use the shared atomic JSON store."
require_pattern 'SettingsRepository\.new' "$project_root/src/app/startup_flow.gd" "Settings persistence must be composed outside SaveService."
if rg -q 'add_page_background|add_dual_toggle|add_strip_toggle|add_check_box|settings/(system|voices)/bg\.png|settings/system/(YES|NO|checkbox)|settings/voices/(sora|nao|akira|kazuha|motoka|ryohei|yahiro|kozue|npc)\.png' \
	"$project_root/src/settings/pages/system_settings_page.gd" "$project_root/src/settings/pages/system_settings_page.tscn" \
	"$project_root/src/settings/pages/audio_settings_page.gd" "$project_root/src/settings/pages/audio_settings_page.tscn"; then
	echo "System and audio settings chrome must not depend on baked page backgrounds or sliced UI state textures." >&2
	exit 1
fi
if rg -q '\.png|Texture2D|load\(|preload\(' "$project_root/src/settings/ui/settings_check_choice_button.gd" "$project_root/src/settings/ui/settings_check_choice_button.tscn"; then
	echo "System confirmation checkbox visuals must be drawn from Canvas primitives without image assets." >&2
	exit 1
fi
if rg -q '\.png|Texture2D|load\(|preload\(' "$project_root/src/settings/ui/settings_voice_choice_button.gd" "$project_root/src/settings/ui/settings_voice_choice_button.tscn"; then
	echo "Audio voice choice visuals must be drawn from Canvas primitives without image assets." >&2
	exit 1
fi
if rg -q 'SettingsVisualTokens|static var _.*(font|texture)|apply_(choice|footer|popup|section)' "$project_root/src/settings"; then
	echo "Settings visuals must come from Theme resources, not script-side static style caches." >&2
	exit 1
fi
require_pattern 'SettingsChoiceButton/base_type' "$project_root/assets/themes/yosuga_theme.tres" "Settings choice button Theme variation is missing."
require_pattern 'SettingsOptionLabel/base_type' "$project_root/assets/themes/yosuga_theme.tres" "Settings option-label Theme variation is missing."
require_pattern 'SettingsPortraitFrame/base_type' "$project_root/assets/themes/yosuga_theme.tres" "Settings portrait-frame Theme variation is missing."
require_pattern 'SettingsCheckChoiceButton/base_type' "$project_root/assets/themes/yosuga_theme.tres" "Settings code-drawn checkbox Theme variation is missing."
require_pattern 'draw_style_box' "$project_root/src/settings/ui/settings_check_choice_button.gd" "Settings checkbox must draw its source-style box from Canvas primitives."
require_pattern 'settings_check_choice_button\.tscn' "$project_root/src/settings/pages/system_settings_page.tscn" "System confirmations must instantiate the reusable code-drawn checkbox scene."
require_pattern 'SettingsVoiceChoiceButton/base_type' "$project_root/assets/themes/yosuga_theme.tres" "Settings code-drawn voice choice Theme variation is missing."
require_pattern 'draw_style_box' "$project_root/src/settings/ui/settings_voice_choice_button.gd" "Audio voice choice must draw its rounded keylines from Canvas primitives."
require_pattern 'settings_voice_choice_button\.tscn' "$project_root/src/settings/pages/audio_settings_page.tscn" "Audio character choices must instantiate the reusable code-drawn choice scene."
require_pattern 'SettingsSectionTitleForeground/base_type' "$project_root/assets/themes/yosuga_theme.tres" "Settings section title Theme variation is missing."
require_pattern 'SettingsFooterButton/base_type' "$project_root/assets/themes/yosuga_theme.tres" "Settings footer Theme variation is missing."
require_pattern 'assets/themes/settings/footer/hover\.tres' "$project_root/assets/themes/yosuga_theme.tres" "Settings footer hover style must remain an external centralized Theme resource."
require_pattern 'SettingsFooterButton/styles/hover = ExtResource\("5_empty_style"\)' "$project_root/assets/themes/yosuga_theme.tres" "Text-only footer buttons must not render a hover frame."
require_pattern 'hint_screen_texture' "$project_root/assets/shaders/ui/settings_modal_blur.gdshader" "Settings modal blur must read the captured screen texture."
require_pattern 'type="BackBufferCopy"' "$project_root/src/settings/settings_screen.tscn" "Settings route must capture the live scene rendered behind it."
require_pattern 'settings_background_blur_material\.tres' "$project_root/src/settings/settings_screen.tscn" "Settings route must render its live backdrop through the blur material."
require_pattern 'type="BackBufferCopy"' "$project_root/src/settings/settings_key_popup.tscn" "Shortcut popup must capture the page behind its blur layer."
require_pattern 'type="BackBufferCopy"' "$project_root/src/settings/settings_confirm_dialog.tscn" "Confirmation popup must capture the page behind its blur layer."
require_pattern 'name="DisplayTab" type="Button"' "$project_root/src/settings/settings_chrome.tscn" "Settings display tab must remain a native scene-owned Button."
require_pattern 'name="SystemTab" type="Button"' "$project_root/src/settings/settings_chrome.tscn" "Settings system tab must remain a native scene-owned Button."
require_pattern 'name="AudioTab" type="Button"' "$project_root/src/settings/settings_chrome.tscn" "Settings audio tab must remain a native scene-owned Button."
require_pattern 'theme_type_variation = &"SettingsTabButton"' "$project_root/src/settings/settings_chrome.tscn" "Settings tabs must use the centralized Theme variation."
if rg -q 'configure_dual\(SETTINGS_ROOT|TAB_BUTTONS.*Dictionary' "$project_root/src/settings/settings_page.gd"; then
	echo "Settings tabs must serialize artwork in the scene instead of loading it at runtime." >&2
	exit 1
fi
if rg -q 'key_popup\.png|reset_seetting\.png|reset_text\.png|settings/key\.png|settings/title\.png' "$project_root/src/settings/settings_page.gd" "$project_root/src/settings/settings_page.tscn" "$project_root/src/settings/settings_chrome.gd" "$project_root/src/settings/settings_chrome.tscn"; then
	echo "Settings footer and shortcut popup text must remain code rendered." >&2
	exit 1
fi

if ! command -v "$godot_executable" >/dev/null 2>&1 && [[ ! -x "$godot_executable" ]]; then
	echo "Godot executable not found; static project checks passed. Set GODOT_EXECUTABLE to run runtime tests."
	exit 0
fi

check_runtime_log() {
	if rg -n -i 'parse error|parser error|script error|objectdb[[:space:]]+leaked|resources still in use' "$verification_log"; then
		echo "Godot verification log contains a fatal parser/runtime/leak marker." >&2
		return 1
	fi
}

"$godot_executable" --headless --audio-driver Dummy --rendering-method gl_compatibility --editor --quit --log-file "$verification_log" --path "$project_root"
check_runtime_log
"$godot_executable" --headless --audio-driver Dummy --rendering-method gl_compatibility --log-file "$verification_log" --path "$project_root" --script res://tests/startup_flow_smoke_test.gd
check_runtime_log
"$godot_executable" --headless --audio-driver Dummy --rendering-method gl_compatibility --log-file "$verification_log" --path "$project_root" --script res://tests/title_migration_contract_test.gd
check_runtime_log

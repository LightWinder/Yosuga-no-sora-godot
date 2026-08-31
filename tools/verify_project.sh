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
	"src/ui/confirmation_overlay.gd"
	"src/ui/confirmation_overlay.tscn"
	"src/save_load/save_load_page.gd"
	"src/save_load/save_load_page.tscn"
	"src/save_load/save_slot_card.gd"
	"src/save_load/save_slot_card.tscn"
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
	"src/scenario/krkr_scenario_instruction.gd"
	"src/scenario/krkr_scenario_document.gd"
	"src/scenario/krkr_scenario_parser.gd"
	"src/scenario/krkr_scenario_runtime.gd"
	"src/adv/adv_asset_resolver.gd"
	"src/adv/adv_progress_catalog.gd"
	"src/adv/adv_tone_catalog.gd"
	"src/adv/adv_stage_director.gd"
	"src/adv/adv_screen.gd"
	"src/adv/adv_screen.tscn"
	"src/adv/components/adv_choice_button.gd"
	"src/adv/components/adv_choice_button.tscn"
	"src/adv/components/adv_dialogue_view.gd"
	"src/adv/components/adv_dialogue_view.tscn"
	"tests/adv_dialogue_view_test.gd"
	"tools/import_krkr_scenarios.sh"
	"tools/import_krkr_adv_assets.sh"
	"tools/import_krkr_adv_sample_assets.sh"
	"tools/validate_utf8_scenarios.sh"
	"assets/content/adv/ui/speaker_name_manifest.csv"
	"assets/content/adv/cg_unlock_flags.csv"
	"assets/content/adv/background_tones.csv"
	"assets/content/adv/ui/name/MP-01.png"
	"assets/content/adv/ui/DHK-01.png"
	"assets/content/adv/ui/DHK-16.png"
	"assets/content/adv/ui/DHK-17.png"
	"assets/content/adv/ui/DHK-18.png"
	"assets/content/adv/ui/DHK-19.png"
	"assets/content/adv/ui/DHK-20.png"
	"assets/content/adv/ui/DHK-21.png"
	"assets/content/adv/ui/DHK-22.png"
	"assets/content/adv/ui/DHK-23.png"
	"assets/content/adv/ui/DHK-24.png"
	"assets/content/adv/ui/DHK-25.png"
	"assets/content/adv/ui/DHK-26.png"
	"assets/content/adv/ui/DHK-58.png"
	"assets/content/adv/ui/DHK-60.png"
	"assets/ui/title/FRM_0513_title_logo.png"
	"assets/shaders/adv/universal_transition.gdshader"
	"assets/shaders/adv/universal_transition_material.tres"
	"assets/themes/adv/eyecatch_panel.tres"
	"assets/manifests/title_content_manifest.json"
	"assets/fonts/Xiaolai-Regular.fontdata"
	"assets/fonts/Xiaolai-Regular-OFL-1.1.txt"
	"assets/themes/yosuga_theme.tres"
	"assets/themes/fonts/settings_choice_font.tres"
	"assets/themes/fonts/settings_section_title_font.tres"
	"assets/themes/settings/common/empty_style.tres"
	"assets/themes/settings/choice/check_choice_empty.tres"
	"assets/themes/settings/choice/state_glow.tres"
	"assets/themes/ui/action_button/focus.tres"
	"assets/themes/ui/action_button/hover.tres"
	"assets/themes/ui/action_button/pressed.tres"
	"assets/themes/ui/action_button/primary_normal.tres"
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
	"assets/themes/ui/glass_panel.tres"
	"assets/themes/save_load/preview_frame.tres"
	"assets/themes/save_load/slot_normal.tres"
	"assets/themes/save_load/slot_hover.tres"
	"assets/themes/save_load/slot_pressed.tres"
	"assets/themes/save_load/slot_disabled.tres"
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

# Godot's default is true and the editor may omit settings equal to their
# default. Only an explicit opt-out changes project behavior.
if rg -q '^[[:space:]]*pointing/emulate_mouse_from_touch[[:space:]]*=[[:space:]]*false[[:space:]]*$' "$project_root/project.godot"; then
	echo "Touch-to-mouse emulation must not be disabled." >&2
	exit 1
fi
require_pattern '\*\.ogv filter=lfs' "$project_root/.gitattributes" "Large video assets must remain covered by Git LFS."
require_pattern '\*\.png filter=lfs' "$project_root/.gitattributes" "Image assets must remain covered by Git LFS."
require_pattern 'vn_advance=' "$project_root/project.godot" "The vn_advance input action is missing."
require_pattern 'schema_version' "$project_root/src/core/save/save_data.gd" "SaveData must expose schema migration metadata."
require_pattern 'com.lightwinder.yosuganosora.hdremake' "$project_root/export_presets.cfg" "Export bundle identifiers are missing."
require_pattern 'theme/custom="res://assets/themes/yosuga_theme.tres"' "$project_root/project.godot" "The project CJK theme is not configured."
require_pattern '\*\.ks text eol=lf' "$project_root/.gitattributes" "Converted KRKR scripts must be normalized as UTF-8 text."
scenario_count="$(find "$project_root/assets/scenario" -maxdepth 1 -type f -name '*.ks' | wc -l | tr -d ' ')"
if [[ "$scenario_count" != "306" ]]; then
	echo "Expected 306 converted UTF-8 KRKR scenarios, found $scenario_count." >&2
	exit 1
fi
"$project_root/tools/validate_utf8_scenarios.sh" "$project_root/assets/scenario"
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
if rg -q 'Title(Album|Music|Memories|Voice)Page\.new' "$project_root/src/title"; then
	echo "Reusable Title pages and overlays must be instantiated from scene resources." >&2
	exit 1
fi
require_pattern 'display_settings_page\.tscn' "$project_root/src/settings/settings_page.tscn" "Screen settings must remain a scene-owned subpage."
require_pattern 'settings_chrome\.tscn' "$project_root/src/settings/settings_page.tscn" "Settings navigation and overlays must remain a scene-owned chrome component."
require_pattern 'settings_screen\.tscn' "$project_root/src/app/startup_flow.gd" "StartupFlow must route settings through its dedicated scene."
require_pattern 'adv_screen\.tscn' "$project_root/src/app/startup_flow.gd" "StartupFlow must route scenario requests to the ADV scene."
require_pattern 'scenario_finished\.connect\(_return_to_title_from_adv\)' "$project_root/src/app/startup_flow.gd" "Completed ADV routes must use the deferred return transition before constructing Title."
require_pattern 'await source_adv\.play_title_exit\(\)' "$project_root/src/app/startup_flow.gd" "StartupFlow must await ADV's source-style black exit before constructing Title."
require_pattern 'name="RouteBackdrop" type="ColorRect"' "$project_root/src/app/startup_flow.tscn" "New Game must retain the scene-owned black route base, separate from the blue load cover."
require_pattern 'name="LoadTransitionCover" type="TextureRect"' "$project_root/src/app/startup_flow.tscn" "Continue must retain the scene-owned source load cover."
require_pattern 'FRM_0501\.png' "$project_root/src/app/startup_flow.tscn" "Route transitions must reuse the source FRM_0501 artwork."
require_pattern '_transition_saved_title_to_adv\(\)' "$project_root/src/app/startup_flow.gd" "Continue must use the source 300/500 ms load-cover hand-off."
require_pattern 'ScenarioLaunchRequest\.new_game' "$project_root/src/title/title_screen.gd" "Title New Game must emit the typed ADV request."
require_pattern 'name="Background" type="TextureRect"' "$project_root/src/adv/adv_screen.tscn" "ADV background must remain scene-owned."
require_pattern 'adv_dialogue_view\.tscn' "$project_root/src/adv/adv_screen.tscn" "ADV must instance the shared dialogue presentation scene."
require_pattern 'name="DialogueView".*instance=' "$project_root/src/adv/adv_screen.tscn" "DialogueView must remain a normal scene instance."
require_pattern 'name="MessagePanel" type="PanelContainer"' "$project_root/src/adv/components/adv_dialogue_view.tscn" "ADV message panel must remain owned by its presentation scene."
if rg -q 'editable path=.*DialogueView|parent="VisualCanvas/DialogueView/' "$project_root/src/adv/adv_screen.tscn"; then
	echo "ADV must not customize the dialogue component through Editable Children." >&2
	exit 1
fi
if rg -q '%(MessagePanel|MessageLabel|SpeakerLabel|SpeakerNameImage|Portrait|MessageHideButton)|_message_panel[.]|_message_label[.]|visible_characters|MessageColumn/' "$project_root/src/adv/adv_screen.gd"; then
	echo "ADV must use the dialogue view API rather than reach into presentation nodes." >&2
	exit 1
fi
if rg -q 'Krkr|ScenarioRuntime|ScenarioLaunchRequest|SaveData|SettingsModel|SettingsRepository|AdvStageDirector|AudioStreamPlayer|res://src/(scenario|settings|core|app)' "$project_root/src/adv/components/adv_dialogue_view.gd" "$project_root/src/adv/components/adv_dialogue_view.tscn"; then
	echo "Dialogue presentation must not depend on gameplay, persistence, settings, or media resolution." >&2
	exit 1
fi
require_pattern 'name="BackgroundScrollLayer" type="Control"' "$project_root/src/adv/adv_screen.tscn" "ADV tiled background-scroll layer must remain scene-owned."
require_pattern 'func is_action_looping\(target_id: String\) -> bool:' "$project_root/src/adv/adv_stage_director.gd" "ADV stage must expose source infinite-loop action semantics."
require_pattern '_stage_director\.is_action_looping\(target_id\)' "$project_root/src/adv/adv_screen.gd" "WaitAction must ignore source infinite-loop actions."
require_pattern 'Tween\.TRANS_QUAD\)\.set_ease\(Tween\.EASE_OUT\)' "$project_root/src/adv/adv_stage_director.gd" "Source accel=2 must remain a quadratic ease-out, not an ease-in-out curve."
require_pattern 'name="TransitionSnapshot" type="Control"' "$project_root/src/adv/adv_screen.tscn" "ADV transition snapshot must remain scene-owned."
require_pattern 'name="EyeCatchOverlay" type="PanelContainer"' "$project_root/src/adv/adv_screen.tscn" "ADV eye-catch overlay must remain scene-owned."
require_pattern 'name="EyeCatchTopBand" type="ColorRect"' "$project_root/src/adv/adv_screen.tscn" "ADV time eye-catch bands must remain scene-owned."
require_pattern 'name="EyeCatchDateBlack" type="ColorRect"' "$project_root/src/adv/adv_screen.tscn" "ADV date eye-catch blackout must remain scene-owned."
require_pattern 'name="EyeCatchLogo" type="TextureRect"' "$project_root/src/adv/adv_screen.tscn" "ADV eye-catch must reuse the source title-logo scene node."
eye_catch_logo_fades="$(rg -c 'parallel\(\)\.tween_property\(_eye_catch_logo, "modulate:a", 0\.0' "$project_root/src/adv/adv_screen.gd")"
if [[ "$eye_catch_logo_fades" != "2" ]]; then
	echo "Both TIME and DATE eye-catches must fade the source logo during their final phase." >&2
	exit 1
fi
require_pattern 'adv_choice_button\.tscn' "$project_root/src/adv/adv_screen.gd" "ADV variable choice rows must reuse their dedicated scene component."
require_pattern 'name="SystemMenu" type="Control"' "$project_root/src/adv/adv_screen.tscn" "ADV system menu must remain scene-owned."
require_pattern 'name="PreviousChoiceButton" type="TextureButton"' "$project_root/src/adv/adv_screen.tscn" "ADV previous-choice icon must remain scene-owned."
require_pattern 'name="NextChoiceButton" type="TextureButton"' "$project_root/src/adv/adv_screen.tscn" "ADV next-choice icon must remain scene-owned."
require_pattern 'name="MenuLockButton" type="TextureButton"' "$project_root/src/adv/adv_screen.tscn" "ADV system-menu lock must remain scene-owned."
require_pattern 'name="AutoModeIndicator" type="TextureRect"' "$project_root/src/adv/adv_screen.tscn" "ADV automatic-mode animation must remain scene-owned."
require_pattern 'name="SystemMenuRecallButton" type="TextureButton"' "$project_root/src/adv/adv_screen.tscn" "ADV system-menu recall strip must remain scene-owned."
require_pattern 'name="QuickSaveButton" type="TextureButton"' "$project_root/src/adv/adv_screen.tscn" "ADV source-style quick-save icon must remain scene-owned."
require_pattern 'name="SpeakerNameImage" type="TextureRect"' "$project_root/src/adv/components/adv_dialogue_view.tscn" "ADV speaker-name artwork must remain scene-owned."
require_pattern 'name="Portrait" type="TextureRect" parent="MessagePanel/MessageColumn"' "$project_root/src/adv/components/adv_dialogue_view.tscn" "ADV dialogue portrait must remain on the free-layout message content layer."
require_pattern 'name="ScenarioRuntime" type="Node"' "$project_root/src/adv/adv_screen.tscn" "ADV parser runtime must be declared by the scene."
require_pattern 'AdvMessagePanel/base_type' "$project_root/assets/themes/yosuga_theme.tres" "ADV message styling must come from the centralized Theme."
require_pattern 'assets/scenario/\*\.ks' "$project_root/export_presets.cfg" "Export presets must include raw UTF-8 KRKR scenario files."
cg_unlock_count="$(awk -F, 'NR > 1 && $1 != "" && ($2 + 0) > 0 {count++} END {print count + 0}' "$project_root/assets/content/adv/cg_unlock_flags.csv")"
if [[ "$cg_unlock_count" != "942" ]]; then
	echo "Expected 942 unique nonzero source CgFlag mappings, found $cg_unlock_count." >&2
	exit 1
fi
require_pattern 'AdvProgressCatalog\.load_default' "$project_root/src/adv/adv_screen.gd" "ADV must load the imported CgFlag progress catalog."
background_tone_count="$(awk -F, 'NR > 1 && $1 != "" && $2 != "" {count++} END {print count + 0}' "$project_root/assets/content/adv/background_tones.csv")"
if [[ "$background_tone_count" != "95" ]]; then
	echo "Expected 95 source background-tone mappings, found $background_tone_count." >&2
	exit 1
fi
require_pattern 'AdvToneCatalog\.load_default' "$project_root/src/adv/adv_stage_director.gd" "ADV stage must load normalized UTF-8 CgSetupInfo tone metadata."
require_pattern 'cg_presented\.connect' "$project_root/src/adv/adv_screen.gd" "Event CG progress must be wired to the runtime profile."
require_pattern 'name="ContinueGame".*instance=' "$project_root/src/title/title_screen.tscn" "Title menu buttons must be declared as scene instances."
require_pattern 'parent="DesignRoot/CharacterLayer"' "$project_root/src/title/title_screen.tscn" "Title character layers must be declared by the scene."
require_pattern '^@tool' "$project_root/src/title/title_menu_button.gd" "Scene-owned Title buttons must preview their serialized artwork in the editor."
require_pattern 'name="CardList"' "$project_root/src/title/content/title_album_page.tscn" "Album fixed layout must be declared by its scene."
require_pattern 'name="TrackList"' "$project_root/src/title/content/title_music_page.tscn" "Music fixed layout must be declared by its scene."
require_pattern 'name="MemoryList"' "$project_root/src/title/content/title_memories_page.tscn" "Memories fixed layout must be declared by its scene."
require_pattern 'name="FavoriteList"' "$project_root/src/title/content/title_voice_page.tscn" "Voice fixed layout must be declared by its scene."
require_pattern 'name="Slot01".*instance=' "$project_root/src/save_load/save_load_page.tscn" "Save/Load slot cards must remain scene-owned instances."
require_pattern 'name="Slot12".*instance=' "$project_root/src/save_load/save_load_page.tscn" "Save/Load must serialize the complete 4x3 slot page."
require_pattern 'confirmation_overlay\.tscn' "$project_root/src/save_load/save_load_page.tscn" "Save/Load must use the shared confirmation overlay."
require_pattern 'confirmation_overlay\.tscn' "$project_root/src/title/title_screen.gd" "Title must use the shared confirmation overlay."
require_pattern '_save_service\.autosave_path\(\)' "$project_root/src/title/title_screen.gd" "Title Continue must respect configured SaveService storage."
if rg -q '_build_shell|add_design_(label|button)' "$project_root/src/title/content" "$project_root/src/ui/design_canvas_page.gd"; then
	echo "Stable Title page chrome must remain scene-owned."
	exit 1
fi
if rg -q 'res://src/(settings|title|save_load)' "$project_root/src/core"; then
	echo "Core modules must not import feature-owned resources."
	exit 1
fi
if rg -q 'res://src/title' "$project_root/src/save_load"; then
	echo "Save/Load must not import Title-owned resources." >&2
	exit 1
fi
if rg -q 'save_load_hd' "$project_root/src/save_load"; then
	echo "Save/Load must not depend on the removed baked HD chrome assets." >&2
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
require_pattern 'ConfirmationOverlayPanel/base_type' "$project_root/assets/themes/yosuga_theme.tres" "Shared confirmation-panel Theme variation is missing."
require_pattern 'SaveLoadSlotButton/base_type' "$project_root/assets/themes/yosuga_theme.tres" "Save/Load slot Theme variation is missing."
require_pattern 'theme_type_variation = &"SaveLoadPreviewFrame"' "$project_root/src/save_load/save_load_page.tscn" "Save/Load preview styling must come from the centralized Theme."
require_pattern 'theme_type_variation = &"SaveLoadPreviewFrame"' "$project_root/src/save_load/save_slot_card.tscn" "Save slot preview styling must come from the centralized Theme."
require_pattern 'assets/themes/ui/action_button/hover\.tres' "$project_root/assets/themes/yosuga_theme.tres" "Shared action-button hover style must remain an external centralized Theme resource."
require_pattern 'SettingsFooterButton/styles/hover = ExtResource\("5_empty_style"\)' "$project_root/assets/themes/yosuga_theme.tres" "Text-only footer buttons must not render a hover frame."
require_pattern 'hint_screen_texture' "$project_root/assets/shaders/ui/settings_modal_blur.gdshader" "Settings modal blur must read the captured screen texture."
require_pattern 'type="BackBufferCopy"' "$project_root/src/settings/settings_screen.tscn" "Settings route must capture the live scene rendered behind it."
require_pattern 'settings_background_blur_material\.tres' "$project_root/src/settings/settings_screen.tscn" "Settings route must render its live backdrop through the blur material."
require_pattern 'name="PreviewViewport" type="SubViewport"' "$project_root/src/settings/pages/display_settings_page.tscn" "Settings must own a fixed ADV preview viewport."
require_pattern 'gui_disable_input = true' "$project_root/src/settings/pages/display_settings_page.tscn" "Settings preview must reject GUI input."
require_pattern 'func configure_preview' "$project_root/src/adv/adv_screen.gd" "ADV must expose a read-only presentation mode without starting gameplay."
require_pattern 'preview.configure_preview\(settings\)' "$project_root/src/app/startup_flow.gd" "The app must configure the fixed Settings preview with settings only."
require_pattern '^func install_preview\(content: Control\)' "$project_root/src/settings/pages/display_settings_page.gd" "Display must only install the supplied preview Control, not accept a settings callback."
require_pattern 'settings_page\.settings_preview_changed\.connect\(preview\.apply_preview_settings\)' "$project_root/src/app/startup_flow.gd" "The app must connect the ADV preview directly to SettingsPage's complete settings state."
if rg -q 'preview_settings_changed|_preview_settings|func _refresh_preview' "$project_root/src/settings/pages/display_settings_page.gd"; then
	echo "Display must not own a private preview settings cache or update signal." >&2
	exit 1
fi
if rg -q 'capture_preview_presentation|_preview_presentation|preview_choices|preview_route_hints|func refresh_preview' "$project_root/src/app" "$project_root/src/adv"; then
	echo "Settings preview must not capture, accept or restore current gameplay state." >&2
	exit 1
fi
if rg -q 'res://src/adv|PreviewTextbox|PreviewAvatar' "$project_root/src/settings"; then
	echo "Settings must receive the real ADV renderer from the app, not import gameplay or maintain a second fake dialogue frame." >&2
	exit 1
fi
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
"$godot_executable" --headless --audio-driver Dummy --rendering-method gl_compatibility --log-file "$verification_log" --path "$project_root" --script res://tests/adv_dialogue_view_test.gd
check_runtime_log
"$godot_executable" --headless --audio-driver Dummy --rendering-method gl_compatibility --log-file "$verification_log" --path "$project_root" --script res://tests/startup_flow_smoke_test.gd
check_runtime_log
"$godot_executable" --headless --audio-driver Dummy --rendering-method gl_compatibility --log-file "$verification_log" --path "$project_root" --script res://tests/title_migration_contract_test.gd
check_runtime_log
"$godot_executable" --headless --audio-driver Dummy --rendering-method gl_compatibility --log-file "$verification_log" --path "$project_root" --script res://tests/krkr_scenario_test.gd
check_runtime_log
"$godot_executable" --headless --audio-driver Dummy --rendering-method gl_compatibility --log-file "$verification_log" --path "$project_root" --script res://tests/adv_asset_coverage_test.gd
check_runtime_log
"$godot_executable" --headless --audio-driver Dummy --rendering-method gl_compatibility --log-file "$verification_log" --path "$project_root" --script res://tests/adv_migration_contract_test.gd
check_runtime_log

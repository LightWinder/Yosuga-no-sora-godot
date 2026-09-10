#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
godot_executable="${GODOT_EXECUTABLE:-godot}"
verification_log_dir=""
trap 'if [[ -n "$verification_log_dir" ]]; then rm -rf "$verification_log_dir"; fi' EXIT

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
	"src/appreciation/appreciation_screen.gd"
	"src/appreciation/appreciation_screen.tscn"
	"src/appreciation/appreciation_catalog.gd"
	"src/appreciation/appreciation_content_request.gd"
	"src/appreciation/content/appreciation_content_manifest.gd"
	"src/appreciation/content/appreciation_album_page.gd"
	"src/appreciation/content/appreciation_album_page.tscn"
	"src/appreciation/content/appreciation_album_viewer.gd"
	"src/appreciation/content/appreciation_album_viewer.tscn"
	"src/appreciation/content/appreciation_music_page.gd"
	"src/appreciation/content/appreciation_music_page.tscn"
	"src/appreciation/content/appreciation_memories_page.gd"
	"src/appreciation/content/appreciation_memories_page.tscn"
	"src/appreciation/content/appreciation_voice_page.gd"
	"src/appreciation/content/appreciation_voice_page.tscn"
	"src/appreciation/ui/appreciation_navigation.gd"
	"src/appreciation/ui/appreciation_navigation.tscn"
	"src/appreciation/ui/appreciation_page_button.gd"
	"src/appreciation/ui/appreciation_visual_card.gd"
	"src/appreciation/ui/appreciation_music_button.tscn"
	"assets/content/appreciation/appreciation_landscape.png"
	"src/appreciation/voice/voice_collection_service.gd"
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
	"src/ui/image_check_button.gd"
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
	"src/ui/modal_overlay.gd"
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
	"src/adv/components/adv_system_menu_button.gd"
	"src/adv/components/adv_dialogue_backdrop.gd"
	"src/adv/components/adv_quick_settings_backdrop.gd"
	"src/adv/components/adv_quick_settings_popovers.gd"
	"src/adv/components/adv_quick_settings_popovers.tscn"
	"src/adv/components/adv_dialogue_icon_button.gd"
	"src/adv/components/adv_speaker_name.gd"
	"src/adv/components/adv_dialogue_view.gd"
	"src/adv/components/adv_dialogue_view.tscn"
	"tests/adv_dialogue_view_test.gd"
	"tests/cloud_test.tscn"
	"tests/cloud_loop_capture.gd"
	"assets/shaders/title/cloud_vertical_loop.gdshader"
	"assets/shaders/title/cloud_vertical_loop_material.tres"
	"assets/ui/title/clouds/cloud_loop_test.png"
	"docs/cloud_loop_validation.md"
	"tests/cloud_radial_test.tscn"
	"tests/cloud_radial_viewports.tscn"
	"tests/cloud_radial_capture.gd"
	"tests/title_cloud_field_test.gd"
	"src/title/title_cloud_field.gd"
	"src/title/title_cloud_field.tscn"
	"tests/title_tree_sway_test.gd"
	"src/title/title_tree_sway_background.gd"
	"src/title/title_tree_sway_background.tscn"
	"assets/shaders/title/title_tree_sway.gdshader"
	"assets/shaders/title/title_tree_sway_material.tres"
	"assets/ui/title/background/title_tree_sway_mask.png"
	"assets/shaders/title/title_perspective_clouds.gdshader"
	"assets/shaders/title/title_perspective_clouds_material.tres"
	"assets/ui/title/clouds/title_cloud_radial_atlas.png"
	"assets/ui/title/clouds/title_cloud_radial_atlas.png.import"
	"assets/ui/title/clouds/sky_mask.svg"
	"src/adv/components/adv_dialogue_appearance.gd"
	"src/adv/preview/adv_settings_preview.gd"
	"src/adv/preview/adv_settings_preview.tscn"
	"tests/adv_settings_preview_test.gd"
	"tools/import_krkr_scenarios.sh"
	"tools/import_krkr_adv_assets.sh"
	"tools/import_krkr_adv_sample_assets.sh"
	"tools/validate_utf8_scenarios.sh"
	"assets/content/adv/ui/speaker_name_manifest.csv"
	"assets/content/adv/cg_unlock_flags.csv"
	"assets/content/adv/background_tones.csv"
	"assets/content/adv/ui/name/MP-01.png"
	"assets/content/adv/ui/DHK-01.png"
	"assets/content/adv/ui/DHK-13.svg"
	"assets/content/adv/ui/DHK-14.svg"
	"assets/content/adv/ui/DHK-15.svg"
	"assets/content/adv/ui/DHK-16.png"
	"assets/content/adv/ui/DHK-16.svg"
	"assets/content/adv/ui/DHK-17.png"
	"assets/content/adv/ui/DHK-17.svg"
	"assets/content/adv/ui/DHK-18.png"
	"assets/content/adv/ui/DHK-18.svg"
	"assets/content/adv/ui/DHK-19.png"
	"assets/content/adv/ui/DHK-19.svg"
	"assets/content/adv/ui/DHK-20.png"
	"assets/content/adv/ui/DHK-20.svg"
	"assets/content/adv/ui/DHK-21.png"
	"assets/content/adv/ui/DHK-21.svg"
	"assets/content/adv/ui/DHK-22.png"
	"assets/content/adv/ui/DHK-22.svg"
	"assets/content/adv/ui/DHK-23.png"
	"assets/content/adv/ui/DHK-23.svg"
	"assets/content/adv/ui/DHK-24.png"
	"assets/content/adv/ui/DHK-24.svg"
	"assets/content/adv/ui/DHK-25.png"
	"assets/content/adv/ui/DHK-25.svg"
	"assets/content/adv/ui/DHK-26.png"
	"assets/content/adv/ui/DHK-26.svg"
	"assets/content/adv/ui/DHK-58.png"
	"assets/content/adv/ui/DHK-60.png"
	"assets/content/adv/ui/DHK-60.svg"
	"assets/content/adv/ui/DHK-65.svg"
	"assets/content/adv/ui/DHK-66.svg"
	"assets/ui/title/FRM_0513_title_logo.png"
	"assets/shaders/adv/universal_transition.gdshader"
	"assets/shaders/adv/universal_transition_material.tres"
	"assets/themes/adv/eyecatch_panel.tres"
	"assets/manifests/appreciation_content_manifest.json"
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
	"assets/themes/settings/section/frame.tres"
	"assets/themes/settings/section/portrait_frame.tres"
	"assets/themes/settings/section/preview_panel.tres"
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

if rg -q '\.mp4(["/]|$)' "$project_root/assets/manifests/appreciation_content_manifest.json"; then
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
require_pattern '"album_cards": 79' "$project_root/assets/manifests/appreciation_content_manifest.json" "Album card manifest count changed unexpectedly."
require_pattern '"album_variants": 214' "$project_root/assets/manifests/appreciation_content_manifest.json" "Album variant manifest count changed unexpectedly."
require_pattern '"memories": 24' "$project_root/assets/manifests/appreciation_content_manifest.json" "Memory manifest count changed unexpectedly."
require_pattern '"music_tracks": 21' "$project_root/assets/manifests/appreciation_content_manifest.json" "Music manifest count changed unexpectedly."
if rg -q 'title_screen_v2|title_screen_legacy|LegacyTitleScreen' "$project_root/src"; then
	echo "Obsolete Title implementation remains under src/." >&2
	exit 1
fi
if [[ -d "$project_root/src/title/content" || -d "$project_root/src/title/voice" ]]; then
	echo "Appreciation content and voice ownership must not remain under Title." >&2
	exit 1
fi
if rg -q 'res://src/appreciation|class_name Appreciation' "$project_root/src/title"; then
	echo "Title must route through the app composition root instead of importing Appreciation directly." >&2
	exit 1
fi
if rg -q 'res://src/(title|settings|save_load)' "$project_root/src/appreciation"; then
	echo "Appreciation must not import sibling feature implementations." >&2
	exit 1
fi
if rg -q 'Appreciation(Album|Music|Memories|Voice)Page\.new' "$project_root/src/appreciation"; then
	echo "Reusable Appreciation pages and overlays must be instantiated from scene resources." >&2
	exit 1
fi
require_pattern 'display_settings_page\.tscn' "$project_root/src/settings/settings_page.tscn" "Screen settings must remain a scene-owned subpage."
require_pattern 'settings_chrome\.tscn' "$project_root/src/settings/settings_page.tscn" "Settings navigation and overlays must remain a scene-owned chrome component."
require_pattern 'settings_screen\.tscn' "$project_root/src/app/startup_flow.gd" "StartupFlow must route settings through its dedicated scene."
require_pattern 'appreciation_screen\.tscn' "$project_root/src/app/startup_flow.gd" "StartupFlow must route Appreciation through its dedicated scene."
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
if rg -q '%(MessagePanel|MessageBackdrop|MessageLabel|SpeakerName|Portrait|MessageHideButton)|_message_panel[.]|_message_label[.]|visible_characters|MessageColumn/' "$project_root/src/adv/adv_screen.gd"; then
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
require_pattern 'name="MessageBackdrop" type="Control"' "$project_root/src/adv/components/adv_dialogue_view.tscn" "ADV code-drawn message backdrop must remain scene-owned."
require_pattern 'adv_dialogue_backdrop\.gd' "$project_root/src/adv/components/adv_dialogue_view.tscn" "ADV message backdrop must use its vector drawing component."
require_pattern 'name="SpeakerName" type="Control"' "$project_root/src/adv/components/adv_dialogue_view.tscn" "ADV code-drawn speaker name must remain scene-owned."
require_pattern 'adv_speaker_name\.gd' "$project_root/src/adv/components/adv_dialogue_view.tscn" "ADV speaker name must use its vector text component."
require_pattern 'adv_quick_settings_popovers\.tscn' "$project_root/src/adv/adv_screen.tscn" "AdvScreen must own the source-style inline settings panels."
if rg -q 'AdvQuickSettingsPopovers|QuickSettingsPopovers|settings_(preview|commit)_requested' \
		"$project_root/src/adv/components/adv_dialogue_view.gd" \
		"$project_root/src/adv/components/adv_dialogue_view.tscn"; then
	echo "Dialogue presentation must emit shortcut intents without owning Settings UI or state." >&2
	exit 1
fi
require_pattern 'audio_settings_requested\.connect\(_quick_settings\.toggle_audio\)' "$project_root/src/adv/adv_screen.gd" "AdvScreen must route the dialogue audio shortcut to its inline panel."
require_pattern 'text_settings_requested\.connect\(_quick_settings\.toggle_text\)' "$project_root/src/adv/adv_screen.gd" "AdvScreen must route the dialogue text shortcut to its inline panel."
require_pattern 'name="AudioQuickSettingsPanel" type="Control"' "$project_root/src/adv/components/adv_quick_settings_popovers.tscn" "ADV volume quick settings must remain fixed scene content."
require_pattern 'name="TextQuickSettingsPanel" type="Control"' "$project_root/src/adv/components/adv_quick_settings_popovers.tscn" "ADV text quick settings must remain fixed scene content."
for quick_slider in master_volume bgm_volume voice_volume se_volume env_se_volume message_speed auto_speed window_depth; do
	require_pattern "name=\"$quick_slider\" type=\"HSlider\"" "$project_root/src/adv/components/adv_quick_settings_popovers.tscn" "ADV inline settings slider must remain native scene content: $quick_slider."
done
for quick_choice in SkipReadChoice SkipAllChoice; do
	require_pattern "name=\"$quick_choice\" type=\"CheckBox\"" "$project_root/src/adv/components/adv_quick_settings_popovers.tscn" "ADV inline skip choice must remain native scene content: $quick_choice."
done
if rg -q 'settings_section_requested|_open_adv_settings_section' \
		"$project_root/src/adv" "$project_root/src/app/startup_flow.gd"; then
	echo "ADV dialogue quick settings must stay inline instead of routing to the full Settings screen." >&2
	exit 1
fi
for dialogue_button in VoiceReplayButton VoiceFavoriteButton VoiceSettingsButton TextSettingsButton MessageHideButton; do
	require_pattern "name=\"$dialogue_button\" type=\"TextureButton\"" "$project_root/src/adv/components/adv_dialogue_view.tscn" "ADV dialogue shortcut must remain scene-owned: $dialogue_button."
done
require_pattern 'adv_dialogue_icon_button\.gd' "$project_root/src/adv/components/adv_dialogue_view.tscn" "ADV dialogue shortcuts must share code-owned state tinting."
require_pattern 'self_modulate = (DISABLED|ACTIVE|NORMAL)_TINT' "$project_root/src/adv/components/adv_dialogue_icon_button.gd" "ADV dialogue shortcut states must tint one foreground texture from code."
for dialogue_icon_id in 13 14 15 65 66; do
	dialogue_icon="$project_root/assets/content/adv/ui/DHK-$dialogue_icon_id.svg"
	require_pattern 'fill="#fff"|stroke="#fff"' "$dialogue_icon" "ADV dialogue SVG must contain a single white foreground: DHK-$dialogue_icon_id."
	require_pattern "DHK-$dialogue_icon_id\\.svg" "$project_root/src/adv/components/adv_dialogue_view.tscn" "ADV dialogue must use SVG DHK-$dialogue_icon_id."
	if rg -q '<image|#999|#9[0-9a-fA-F]{5}' "$dialogue_icon"; then
		echo "ADV dialogue SVGs must contain one untinted vector state: DHK-$dialogue_icon_id." >&2
		exit 1
	fi
done
if rg -q 'DHK-(13|14|15|65|66)\.png' "$project_root/src/adv/components/adv_dialogue_view.tscn"; then
	echo "ADV dialogue shortcuts must not render paired PNG state atlases." >&2
	exit 1
fi
if rg -q 'DHK-28\.png|ui/name/MP-|speaker_name_manifest' \
		"$project_root/src/adv/adv_screen.gd" \
		"$project_root/src/adv/components/adv_dialogue_view.gd" \
		"$project_root/src/adv/components/adv_dialogue_view.tscn" \
		"$project_root/src/adv/preview/adv_settings_preview.gd" \
		"$project_root/assets/themes/adv/message_panel.tres"; then
	echo "ADV dialogue chrome must be drawn from code instead of the former frame/name PNGs." >&2
	exit 1
fi
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
require_pattern '^@tool' "$project_root/src/title/title_menu_button.gd" "Scene-owned Title buttons must preview their native drawing in the editor."
require_pattern 'appreciation_gallery\.tscn' "$project_root/src/appreciation/content/appreciation_album_page.tscn" "Album must instance the shared gallery layout."
require_pattern 'name="TrackList"' "$project_root/src/appreciation/content/appreciation_music_page.tscn" "Music fixed layout must be declared by its scene."
require_pattern 'appreciation_gallery\.tscn' "$project_root/src/appreciation/content/appreciation_memories_page.tscn" "Memories must instance the shared gallery layout."
require_pattern 'name="FavoriteList"' "$project_root/src/appreciation/content/appreciation_voice_page.tscn" "Voice fixed layout must be declared by its scene."
for appreciation_page in appreciation_album_page appreciation_music_page appreciation_memories_page appreciation_voice_page; do
	require_pattern 'page_title\.tscn' "$project_root/src/appreciation/content/$appreciation_page.tscn" "Appreciation pages must reuse the shared PageTitle component: $appreciation_page."
	require_pattern 'appreciation_navigation\.tscn' "$project_root/src/appreciation/content/$appreciation_page.tscn" "Appreciation pages must reuse the shared bottom navigation: $appreciation_page."
done
require_pattern 'if not _locked and _thumbnail' "$project_root/src/appreciation/ui/appreciation_visual_card.gd" "Locked appreciation cards must not load their real artwork."
require_pattern 'settings_background_blur_material\.tres' "$project_root/src/appreciation/appreciation_screen.tscn" "Appreciation must share Save/Load background blur."
require_pattern 'type="BackBufferCopy"' "$project_root/src/appreciation/appreciation_screen.tscn" "Appreciation must copy the live Title route before applying background blur."
require_pattern '_appreciation_overlay = APPRECIATION_SCENE\.instantiate' "$project_root/src/app/startup_flow.gd" "StartupFlow must compose Appreciation as an overlay above the live Title route."
if rg -q '_replace_screen\(APPRECIATION_SCENE\)|QD-13-BG|name="CollectionBackground"' \
	"$project_root/src/app/startup_flow.gd" \
	"$project_root/src/appreciation/appreciation_screen.gd" \
	"$project_root/src/appreciation/appreciation_screen.tscn" \
	"$project_root/src/appreciation/content/appreciation_voice_page.tscn"; then
	echo "Appreciation must not replace or cover its live Title underlay." >&2
	exit 1
fi
require_pattern 'name="SlotList".*instance=' "$project_root/src/save_load/save_load_page.tscn" "Save/Load must own its reusable scrolling list scene."
require_pattern 'extends ScrollContainer' "$project_root/src/save_load/save_slot_list.gd" "Save/Load must use native scrolling with a bounded card pool."
require_pattern 'confirmation_overlay\.tscn' "$project_root/src/save_load/save_load_page.tscn" "Save/Load must use the shared confirmation overlay."
require_pattern 'confirmation_overlay\.tscn' "$project_root/src/title/title_screen.gd" "Title must use the shared confirmation overlay."
require_pattern '_save_service\.autosave_path\(\)' "$project_root/src/title/title_screen.gd" "Title Continue must respect configured SaveService storage."
if rg -q '_build_shell|add_design_(label|button)' "$project_root/src/appreciation/content" "$project_root/src/ui/design_canvas_page.gd"; then
	echo "Stable Appreciation page chrome must remain scene-owned."
	exit 1
fi
if rg -q 'res://src/(appreciation|settings|title|save_load)' "$project_root/src/core"; then
	echo "Core modules must not import feature-owned resources."
	exit 1
fi
if rg -q 'res://src/(appreciation|title)' "$project_root/src/save_load"; then
	echo "Save/Load must not import Title- or Appreciation-owned resources." >&2
	exit 1
fi
if rg -q 'save_load_hd' "$project_root/src/save_load"; then
	echo "Save/Load must not depend on the removed baked HD chrome assets." >&2
	exit 1
fi
require_pattern 'AtomicJsonStore\.new' "$project_root/src/core/save/save_service.gd" "SaveService must use the shared atomic JSON store."
require_pattern 'AtomicJsonStore\.new' "$project_root/src/appreciation/voice/voice_collection_service.gd" "Voice favorites must use the shared atomic JSON store."
require_pattern 'SettingsRepository\.new' "$project_root/src/app/startup_flow.gd" "Settings persistence must be composed outside SaveService."
require_pattern 'adv_system_menu_button\.gd' "$project_root/src/adv/adv_screen.tscn" "ADV system-menu buttons must share the code-drawn state background."
require_pattern 'draw_style_box' "$project_root/src/adv/components/adv_system_menu_button.gd" "ADV system-menu backgrounds must be drawn in code."
for adv_icon_id in 16 17 18 19 20 21 22 23 24 25 26 60; do
	adv_icon="$project_root/assets/content/adv/ui/DHK-$adv_icon_id.svg"
	require_pattern 'width="55" height="56"' "$adv_icon" "ADV system-menu foreground SVG must contain one 55x56 icon: DHK-$adv_icon_id."
	require_pattern "DHK-$adv_icon_id\\.svg" "$project_root/src/adv/adv_screen.tscn" "ADV system menu must use foreground SVG DHK-$adv_icon_id."
	if rg -q '#80b0c0|#165768|width="110"|<image' "$adv_icon"; then
		echo "ADV system-menu SVGs must contain only one vector foreground; backgrounds belong to AdvSystemMenuButton: DHK-$adv_icon_id." >&2
		exit 1
	fi
done
require_pattern '<circle cx="14\.5" cy="9\.5" r="5\.5"' "$project_root/assets/content/adv/ui/DHK-22.svg" "Quick Save foreground must retain its Q mark."
require_pattern '<circle cx="14\.5" cy="9\.5" r="5\.5"' "$project_root/assets/content/adv/ui/DHK-23.svg" "Quick Load foreground must retain its Q mark."
if rg -q 'DHK-(16|17|18|19|20|21|22|23|24|25|26|60)\.png' "$project_root/src/adv/adv_screen.tscn"; then
	echo "ADV system-menu buttons must not render the former paired PNG state atlases." >&2
	exit 1
fi
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
require_pattern 'ConfirmationOverlayMessage/base_type' "$project_root/assets/themes/yosuga_theme.tres" "Shared confirmation-panel Theme variation is missing."
require_pattern 'SaveLoadSlotButton/base_type' "$project_root/assets/themes/yosuga_theme.tres" "Save/Load slot Theme variation is missing."
require_pattern 'theme_type_variation = &"SaveLoadPreviewFrame"' "$project_root/src/save_load/save_load_page.tscn" "Save/Load preview styling must come from the centralized Theme."
require_pattern 'theme_type_variation = &"SaveLoadSlotPreviewFrame"' "$project_root/src/save_load/save_slot_card.tscn" "Save slot preview styling must come from the centralized Theme."
require_pattern 'assets/themes/ui/action_button/hover\.tres' "$project_root/assets/themes/yosuga_theme.tres" "Shared action-button hover style must remain an external centralized Theme resource."
require_pattern 'SettingsFooterButton/styles/hover = ExtResource\("5_empty_style"\)' "$project_root/assets/themes/yosuga_theme.tres" "Text-only footer buttons must not render a hover frame."
require_pattern 'hint_screen_texture' "$project_root/assets/shaders/ui/settings_modal_blur.gdshader" "Settings modal blur must read the captured screen texture."
require_pattern 'type="BackBufferCopy"' "$project_root/src/settings/settings_screen.tscn" "Settings route must capture the live scene rendered behind it."
require_pattern 'settings_background_blur_material\.tres' "$project_root/src/settings/settings_screen.tscn" "Settings route must render its live backdrop through the blur material."
require_pattern 'name="PreviewViewport" type="SubViewport"' "$project_root/src/settings/pages/display_settings_page.tscn" "Settings must own a fixed ADV preview viewport."
require_pattern 'gui_disable_input = true' "$project_root/src/settings/pages/display_settings_page.tscn" "Settings preview must reject GUI input."
require_pattern 'adv_settings_preview\.tscn' "$project_root/src/app/startup_flow.gd" "Settings must instantiate the lightweight preview scene."
require_pattern 'preview.configure\(settings\)' "$project_root/src/app/startup_flow.gd" "The app must configure the fixed Settings preview with settings only."
require_pattern '^func install_preview\(content: Control\)' "$project_root/src/settings/pages/display_settings_page.gd" "Display must only install the supplied preview Control, not accept a settings callback."
require_pattern 'settings_page\.settings_preview_changed\.connect\(preview\.apply_settings\)' "$project_root/src/app/startup_flow.gd" "The app must connect the lightweight preview directly to SettingsPage's complete settings state."
require_pattern 'adv_dialogue_view\.tscn' "$project_root/src/adv/preview/adv_settings_preview.tscn" "Preview must reuse the actual dialogue scene."
require_pattern 'name="DialogueView".*instance=' "$project_root/src/adv/preview/adv_settings_preview.tscn" "Preview dialogue must remain a normal scene instance."
require_pattern 'name="ReplayTimer" type="Timer"' "$project_root/src/adv/preview/adv_settings_preview.tscn" "Preview must own a cancellable replay timer."
require_pattern 'EA01E\.png' "$project_root/src/adv/preview/adv_settings_preview.tscn" "Preview must reference the existing fixed train CG."
if rg -q 'Krkr|ScenarioRuntime|ScenarioLaunchRequest|SaveData|SaveService|SettingsRepository|AdvStageDirector|AudioStreamPlayer|VideoStreamPlayer|ChoiceOverlay|HistoryOverlay|SystemMenu|adv_screen|res://src/(scenario|core|app)|\.ks["\x27]|editable path=|parent="DialogueView/' "$project_root/src/adv/preview"; then
	echo "Settings preview must not contain gameplay dependencies or override dialogue internals." >&2
	exit 1
fi
if rg -q '_preview_only|configure_preview|apply_preview_settings|_initialize_preview|_disable_preview_input' "$project_root/src/adv/adv_screen.gd"; then
	echo "AdvScreen must no longer contain a Settings-preview mode." >&2
	exit 1
fi
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
require_pattern 'type="BackBufferCopy"' "$project_root/src/ui/confirmation_overlay.tscn" "Confirmation popup must capture the page behind its blur layer."
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

require_pattern '^extends Button$' "$project_root/src/title/title_menu_button.gd" "Title menu entries must use native Buttons, not baked texture states."
require_pattern 'repeat_enable' "$project_root/assets/shaders/title/title_perspective_clouds.gdshader" "Title clouds must repeat the whole texture."
require_pattern 'title_cloud_radial_atlas\.png' "$project_root/assets/shaders/title/title_perspective_clouds_material.tres" "Title clouds must use the radial atlas texture."
require_pattern 'mipmaps/generate=true' "$project_root/assets/ui/title/clouds/title_cloud_radial_atlas.png.import" "Radial cloud minification requires persistent mipmap import settings."
if rg -q 'cloud_strip|cycle_seconds|for \(int (lane|bank)|\bTIME\b' "$project_root/assets/shaders/title/title_perspective_clouds.gdshader"; then
	echo "Title clouds must not regress to individual ribbon instances or the global shader clock." >&2
	exit 1
fi
require_pattern 'run/max_fps=60' "$project_root/project.godot" "The main UI and input loop must use Godot's built-in 60 FPS cap."
require_pattern 'renderer/rendering_method="mobile"' "$project_root/project.godot" "The project must use Godot's Mobile renderer on desktop and mobile targets."
require_pattern 'renderer/rendering_method.mobile="mobile"' "$project_root/project.godot" "Mobile targets must use Godot's Mobile renderer."
require_pattern 'title_tree_sway_background\.tscn' "$project_root/src/title/title_screen.tscn" "Title must instance the animated background directly in the main viewport."
require_pattern 'title_cloud_field\.tscn' "$project_root/src/title/title_screen.tscn" "Title must instance the animated cloud field directly in the main viewport."
require_pattern 'title_tree_sway_mask\.png' "$project_root/assets/shaders/title/title_tree_sway_material.tres" "Tree sway must remain limited by the PSD-derived canopy mask."
if rg -q '\bTIME\b' "$project_root/assets/shaders/title/title_tree_sway.gdshader"; then
	echo "Title tree sway must use its scene-local phase clock." >&2
	exit 1
fi
require_pattern 'TitleMenuButton/fonts/font = ExtResource\("1_xiaolai"\)' "$project_root/assets/themes/yosuga_theme.tres" "Title menu typography must use Xiaolai through the project Theme."

require_pattern 'name="PageLayout" type="VBoxContainer"' "$project_root/src/save_load/save_load_page.tscn" "Save/Load must retain its container-owned page layout."
require_pattern 'res://assets/themes/ui/frame.tres' "$project_root/assets/themes/yosuga_theme.tres" "Save/Load must reuse the shared Settings outer frame."
require_pattern 'res://src/ui/page_tab_button.gd' "$project_root/src/save_load/save_load_page.tscn" "Save/Load tabs must reuse neutral page-tab behavior."

require_pattern 'settings_background_blur_material.tres' "$project_root/src/save_load/save_load_page.tscn" "Save/Load must share Settings live background blur."
require_pattern 'clip_children = 1' "$project_root/src/save_load/save_slot_card.tscn" "Slot thumbnails must retain rounded masking."

require_pattern 'name="PreviewAspect" type="AspectRatioContainer"' "$project_root/src/save_load/save_load_page.tscn" "Save/Load left preview must keep a native 16:9 aspect container."
require_pattern 'type="SubViewport"' "$project_root/src/adv/components/adv_background_preview.tscn" "Save thumbnails must render background-only in a dedicated viewport."

require_pattern 'SAVE_LOAD_SCENE.instantiate' "$project_root/src/app/startup_flow.gd" "Title Load must be composed as a live overlay by StartupFlow."

echo "[PASS] Static project checks"

if ! command -v "$godot_executable" >/dev/null 2>&1 && [[ ! -x "$godot_executable" ]]; then
	echo "Godot executable not found; static project checks passed. Set GODOT_EXECUTABLE to run runtime tests."
	exit 0
fi

check_runtime_log() {
	local log_file="$1"
	if rg -q -i 'parse error|parser error|script error|objectdb[[:space:]]+leaked|resources still in use' "$log_file"; then
		echo "Godot verification log contains a fatal parser/runtime/leak marker." >&2
		return 1
	fi
}

run_godot() {
	local test_name="$1"
	shift
	verification_log_dir="$(mktemp -d -t yosuga-godot-verify.XXXXXX)"
	local engine_log="$verification_log_dir/engine.log"
	local console_log="$verification_log_dir/console.log"
	local status=0
	"$godot_executable" --headless --audio-driver Dummy --rendering-method mobile \
		--quiet --no-header --log-file "$engine_log" --path "$project_root" "$@" \
		>"$console_log" 2>&1 || status=$?
	if [[ -f "$engine_log" ]]; then
		check_runtime_log "$engine_log" || status=1
	fi
	check_runtime_log "$console_log" || status=1
	if [[ "$status" -ne 0 ]]; then
		echo "[FAIL] $test_name (exit $status)" >&2
		cat "$console_log" >&2
		if [[ -f "$engine_log" ]]; then
			echo "--- Godot engine log ---" >&2
			cat "$engine_log" >&2
		fi
	else
		echo "[PASS] $test_name"
	fi
	rm -rf "$verification_log_dir"
	verification_log_dir=""
	return "$status"
}

run_godot_test() {
	run_godot "$1" --script "$2"
}

run_godot "Godot import" --import
run_godot_test "ADV dialogue" res://tests/adv_dialogue_view_test.gd
run_godot_test "Title clouds" res://tests/title_cloud_field_test.gd
run_godot_test "Title tree sway" res://tests/title_tree_sway_test.gd
run_godot_test "Settings preview" res://tests/adv_settings_preview_test.gd
run_godot_test "Startup flow" res://tests/startup_flow_smoke_test.gd
run_godot_test "Save/Load contracts" res://tests/save_load_contract_test.gd
run_godot_test "Title contracts" res://tests/title_migration_contract_test.gd
run_godot_test "KRKR runtime" res://tests/krkr_scenario_test.gd
run_godot_test "ADV asset coverage" res://tests/adv_asset_coverage_test.gd
run_godot_test "ADV contracts" res://tests/adv_migration_contract_test.gd

echo "Verification passed."

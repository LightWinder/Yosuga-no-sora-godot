#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
godot_executable="${GODOT_EXECUTABLE:-godot}"
verification_log="$(mktemp -t yosuga-godot-verify.XXXXXX.log)"
trap 'rm -f "$verification_log"' EXIT

required_files=(
	"project.godot"
	"export_presets.cfg"
	"src/core/input/input_actions.gd"
	"src/core/save/save_data.gd"
	"src/core/save/profile_data.gd"
	"src/core/save/save_service.gd"
	"src/title/title_feature_screen.tscn"
	"src/title/title_catalog.gd"
	"src/title/content/title_content_manifest.gd"
	"src/title/content/title_album_page.gd"
	"src/title/content/title_album_viewer.gd"
	"src/title/content/title_music_page.gd"
	"src/title/content/title_memories_page.gd"
	"src/title/content/title_voice_page.gd"
	"src/title/voice/voice_collection_service.gd"
	"src/title/config/title_configuration_page.gd"
	"src/title/scenario/scenario_launch_request.gd"
	"assets/manifests/title_content_manifest.json"
	"assets/fonts/Xiaolai-Regular.fontdata"
	"assets/fonts/Xiaolai-Regular-OFL-1.1.txt"
	"assets/themes/yosuga_theme.tres"
	"default_bus_layout.tres"
)
for required_file in "${required_files[@]}"; do
	if [[ ! -f "$project_root/$required_file" ]]; then
		echo "Missing required file: $required_file" >&2
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

rg -q 'pointing/emulate_mouse_from_touch=true' "$project_root/project.godot"
rg -q 'vn_advance=' "$project_root/project.godot"
rg -q 'schema_version' "$project_root/src/core/save/save_data.gd"
rg -q 'com.lightwinder.yosuganosora.hdremake' "$project_root/export_presets.cfg"
rg -q 'theme/custom="res://assets/themes/yosuga_theme.tres"' "$project_root/project.godot"
rg -q 'default_bus_layout="res://default_bus_layout.tres"' "$project_root/project.godot"
rg -q '"album_cards": 79' "$project_root/assets/manifests/title_content_manifest.json"
rg -q '"album_variants": 214' "$project_root/assets/manifests/title_content_manifest.json"
rg -q '"memories": 24' "$project_root/assets/manifests/title_content_manifest.json"
rg -q '"music_tracks": 21' "$project_root/assets/manifests/title_content_manifest.json"
if rg -q 'title_screen_v2|title_screen_legacy|LegacyTitleScreen' "$project_root/src"; then
	echo "Obsolete Title implementation remains under src/." >&2
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

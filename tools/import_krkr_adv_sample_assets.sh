#!/usr/bin/env bash
set -euo pipefail

# Compatibility implementation for the former sample-only command name.
# New documentation and automation call tools/import_krkr_adv_assets.sh.

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_project="${1:-$project_root/../yosuga-no-sora-remake}"
shift || true
scenario_ids=("$@")

background_destination="$project_root/assets/content/adv/backgrounds"
character_destination="$project_root/assets/content/adv/characters"
voice_destination="$project_root/assets/audio/adv/voice"
effect_destination="$project_root/assets/audio/adv/effects"
rule_destination="$project_root/assets/content/adv/rules"
ui_destination="$project_root/assets/content/adv/ui"
speaker_name_destination="$ui_destination/name"
speaker_name_manifest="$ui_destination/speaker_name_manifest.csv"
character_layout_destination="$project_root/assets/content/adv/character_layout.csv"
cg_unlock_manifest="$project_root/assets/content/adv/cg_unlock_flags.csv"
background_tone_manifest="$project_root/assets/content/adv/background_tones.csv"
mkdir -p \
	"$background_destination" "$character_destination" "$voice_destination" \
	"$effect_destination" "$rule_destination" "$ui_destination" \
	"$speaker_name_destination"

resolve_case_insensitive() {
	local search_directory="$1"
	local expected_name="$2"
	local uppercase_name
	uppercase_name="$(printf '%s' "$expected_name" | tr '[:lower:]' '[:upper:]')"
	if [[ -f "$search_directory/$uppercase_name" ]]; then
		printf '%s\n' "$search_directory/$uppercase_name"
		return
	fi
	find "$search_directory" -maxdepth 1 -type f -iname "$expected_name" -print -quit
}

copy_resolved() {
	local search_directory="$1"
	local asset_id="$2"
	local extension="$3"
	local destination_directory="$4"
	local source_file
	source_file="$(resolve_case_insensitive "$search_directory" "$asset_id.$extension")"
	if [[ -z "$source_file" ]]; then
		echo "Missing source asset: $search_directory/$asset_id.$extension" >&2
		return 1
	fi
	cp -p "$source_file" "$destination_directory/$(basename "$source_file")"
}

asset_list="$(mktemp -t yosuga-adv-assets.XXXXXX)"
character_layout_rows="$(mktemp -t yosuga-adv-character-layout.XXXXXX)"
trap 'rm -f "$asset_list" "$character_layout_rows"' EXIT

# Source bust-up CSVs define the image-space guide point used as each
# character's visual anchor. Keep the imported table in logical source units;
# the runtime applies the same 1.8x HD guide scale as SetupBustup.
for layout_csv in "$source_project"/data/c*.csv; do
	awk -F, '
		NR > 1 && NF >= 9 && $1 !~ /^#/ && $1 != "" {
			printf "%s,%d,%d\n", toupper($1), $8, $9
		}
	' "$layout_csv" >> "$character_layout_rows"
done
{
	printf 'asset_id,guidex,guidey\n'
	LC_ALL=C sort -t, -k1,1 -u "$character_layout_rows"
} > "$character_layout_destination"

# SetupCg/SetupBustup raise persistent CgFlag entries as soon as artwork is
# presented. Normalize the source UTF-16 TJS table into a small UTF-8 runtime
# manifest; shipped GDScript never needs to decode or evaluate source TJS.
{
	printf 'asset_id,flag_id\n'
	iconv -f UTF-16LE -t UTF-8 "$source_project/data/system/CgFlag.tjs" \
		| tr -d '\r' \
		| sed -nE 's/^[[:space:]]*([A-Z][A-Z0-9_]*)[[:space:]]*:[[:space:]]*([1-9][0-9]*)[[:space:]]*,.*$/\1,\2/p' \
		| awk -F, '!seen[$1]++'
} > "$cg_unlock_manifest"

# CgSetupInfo assigns an environmental gamma profile to each background. The
# runtime only needs the normalized profile name, so convert this UTF-16 TJS
# table to a BOM-free UTF-8 CSV at the same import boundary as the scenarios.
{
	printf 'asset_id,tone\n'
	iconv -f UTF-16LE -t UTF-8 "$source_project/data/system/CgSetupInfo.tjs" \
		| tr -d '\r' \
		| sed -nE 's/^[[:space:]]*([A-Z][A-Z0-9_]*)[[:space:]]*:[[:space:]]*%\[tone:BG_TONE\.([a-z_]+)\].*$/\1,\2/p'
} > "$background_tone_manifest"
scenario_paths=()
if [[ ${#scenario_ids[@]} -eq 0 ]]; then
	scenario_paths=("$project_root"/assets/scenario/*.ks)
	"$project_root/tools/convert_krkr_tlg_assets.sh" \
		"$source_project" "$background_destination"
else
	for scenario_id in "${scenario_ids[@]}"; do
		scenario_path="$project_root/assets/scenario/$scenario_id.ks"
		if [[ ! -f "$scenario_path" ]]; then
			echo "Converted scenario not found: $scenario_path" >&2
			exit 1
		fi
		scenario_paths+=("$scenario_path")
	done
fi
for scenario_path in "${scenario_paths[@]}"; do
	sed -n \
		-e 's/^[[:space:]]*@Cg[[:space:]].*file=\([^[:space:]]*\).*/cg \1/p' \
		-e 's/^[[:space:]]*@BgScroll[[:space:]].*file=\([^[:space:]]*\).*/cg \1/p' \
		-e 's/^[[:space:]]*@Char[[:space:]].*file=\([^[:space:]]*\).*/character \1/p' \
		-e 's/^[[:space:]]*@Talk[[:space:]].*voice=\([^[:space:]]*\).*/voice \1/p' \
		-e 's/^[[:space:]]*@PlaySe[[:space:]].*file=\([^[:space:]]*\).*/effect \1/p' \
		-e 's/^[[:space:]]*@PlayEnvSe[[:space:]].*file=\([^[:space:]]*\).*/effect \1/p' \
		"$scenario_path" >> "$asset_list"
done

sort -u "$asset_list" | while read -r asset_kind asset_id; do
	case "$asset_kind" in
		cg)
			asset_id_upper="$(printf '%s' "$asset_id" | tr '[:lower:]' '[:upper:]')"
			if [[ "$asset_id_upper" == "BLACK" || "$asset_id_upper" == "WHITE" || "$asset_id" == *,* ]]; then
				continue
			fi
			if [[ -n "$(resolve_case_insensitive "$project_root/assets/content/event_1920" "$asset_id.png")" ]]; then
				continue
			fi
			if [[ -n "$(resolve_case_insensitive "$background_destination" "$asset_id.png")" ]]; then
				continue
			fi
			copy_resolved "$source_project/data/bg_1920" "$asset_id" png "$background_destination"
			;;
		character)
			copy_resolved "$source_project/data/character_1920" "$asset_id" png "$character_destination"
			;;
		voice)
			IFS='/' read -r -a voice_ids <<< "$asset_id"
			for voice_id in "${voice_ids[@]}"; do
				copy_resolved "$source_project/data/audio_ogg" "$voice_id" ogg "$voice_destination"
			done
			;;
		effect)
			copy_resolved "$source_project/data/audio_ogg" "$asset_id" ogg "$effect_destination"
			;;
	esac
done

# The dialogue portrait follows the current bust-up costume but prefers the
# source T crop. Import that companion for every referenced L/M/S drawing.
for imported_character in "$character_destination"/*.[Pp][Nn][Gg]; do
	[[ -f "$imported_character" ]] || continue
	character_name="$(basename "$imported_character")"
	character_stem="${character_name%.*}"
	case "${character_stem: -1}" in
		L|l|M|m|S|s|F|f|T|t) dress_id="${character_stem%?}" ;;
		*) dress_id="$character_stem" ;;
	esac
	portrait_source="$(resolve_case_insensitive \
		"$source_project/data/character_1920" "${dress_id}T.png")"
	if [[ -n "$portrait_source" ]]; then
		cp -p "$portrait_source" "$character_destination/$(basename "$portrait_source")"
	fi
done

# These are the complete fixed UI/transition dependencies referenced by the
# 306 converted scripts. Keeping the explicit list makes the import boundary
# auditable without copying the source project's entire rule/UI directories.
for rule_id in \
	WIP_LR WIP_RL WIP_BT WIP_MOZV WIP_TB WIP_MOZH CLOUD_A WIP_TLBR \
	WIP_MOZBT MOZCIR WIP_MOZRL WIP_MOZTB WIP_BRTL MOZCIR_; do
	copy_resolved "$source_project/data/rule" "$rule_id" png "$rule_destination"
done

for ui_file in \
	DHK-01.png DHK-16.png DHK-17.png DHK-18.png DHK-19.png \
	DHK-20.png DHK-21.png DHK-22.png DHK-23.png DHK-24.png DHK-25.png \
	DHK-26.png DHK-28.png DHK-58.png DHK-60.png DHK-65.png \
	gameoption.png gameoption.sora.png gameoption.nao.png gameoption.akira.png \
	gameoption.kuzuha.png gameoption.motoka.png; do
	if [[ "$ui_file" == DHK-* ]]; then
		cp -p "$source_project/data/ui_1920/adv_menu/$ui_file" "$ui_destination/$ui_file"
	else
		cp -p "$source_project/data/ui_1920/$ui_file" "$ui_destination/$ui_file"
	fi
done

# Speaker-name artwork is fixed dialogue chrome, while the mapping remains
# data-driven. Generate the CSV from the source MessageFrame table so future
# source corrections do not need to be duplicated in GDScript.
cp -p "$source_project"/data/ui_1920/name/*.png "$speaker_name_destination/"
{
	printf 'speaker,file\n'
	LC_ALL=C sed -nE \
		'/var ROLE_NAME_IMAGES = \[/,/^\];/ s/^[[:space:]]*\["([^"]+)",[[:space:]]*"([^"]+)"\],?[[:space:]]*$/\1,\2/p' \
		"$source_project/data/system/MessageFrame.tjs"
} > "$speaker_name_manifest"

for indicator_file in M2_MSG_BLINK.png M2_MSG_BLINK_AUTO.png; do
	cp -p "$source_project/data/frame_m2/$indicator_file" "$ui_destination/$indicator_file"
done

if [[ ${#scenario_ids[@]} -eq 0 ]]; then
	echo "Imported all ADV assets referenced by the 306 UTF-8 scenarios."
else
	echo "Imported ADV assets for: ${scenario_ids[*]}"
fi

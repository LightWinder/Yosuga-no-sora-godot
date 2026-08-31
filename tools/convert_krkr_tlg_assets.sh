#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_project="${1:-$project_root/../yosuga-no-sora-remake}"
destination="${2:-$project_root/assets/content/adv/backgrounds}"
krkr_executable="$source_project/build/dev/macos-sdl2/krkrsdl2"
template="$project_root/tools/tlg_converter_startup.tjs"

if [[ ! -x "$krkr_executable" ]]; then
	echo "KiriKiri decoder executable not found: $krkr_executable" >&2
	exit 1
fi
if [[ ! -f "$template" ]]; then
	echo "TLG converter startup template not found: $template" >&2
	exit 1
fi

conversion_directory="$(mktemp -d -t yosuga-tlg-convert.XXXXXX)"
cleanup() {
	find "$conversion_directory" -type f -delete
	rmdir "$conversion_directory"
}
trap cleanup EXIT

for asset_name in \
	SP01 SP02 SP03 SP04 SP05 SP06 SP07 SP08 SP09 SP10 SP11 SP12 SP51 SP52; do
	source_file="$source_project/data/char/$asset_name.tlg"
	if [[ ! -f "$source_file" ]]; then
		echo "Missing source TLG asset: $source_file" >&2
		exit 1
	fi
	cp -p "$source_file" "$conversion_directory/$asset_name.tlg"
done

# KiriKiri's startup script is UTF-16. The template remains reviewable UTF-8
# in this repository and is converted only inside the temporary workspace.
iconv -f UTF-8 -t UTF-16 "$template" > "$conversion_directory/startup.tjs"
"$krkr_executable" "$conversion_directory"

mkdir -p "$destination"
for asset_name in \
	SP01 SP02 SP03 SP04 SP05 SP06 SP07 SP08 SP09 SP10 SP11 SP12 SP51 SP52; do
	bmp_file="$conversion_directory/$asset_name.bmp"
	if [[ ! -f "$bmp_file" ]]; then
		echo "KiriKiri did not produce the expected bitmap: $bmp_file" >&2
		exit 1
	fi
	sips -s format png "$bmp_file" --out "$destination/$asset_name.png" >/dev/null
done

echo "Converted 14 referenced TLG special images to PNG."

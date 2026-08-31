#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_project="${1:-$project_root/../yosuga-no-sora-remake}"
source_directory="$source_project/data/scenario"
destination_directory="$project_root/assets/scenario"

if [[ ! -d "$source_directory" ]]; then
	echo "KRKR scenario directory not found: $source_directory" >&2
	exit 1
fi

mkdir -p "$destination_directory"

imported_count=0
temporary_file=""
cleanup() {
	if [[ -n "$temporary_file" && -f "$temporary_file" ]]; then
		rm -f "$temporary_file"
	fi
}
trap cleanup EXIT
for source_file in "$source_directory"/*.ks; do
	file_name="$(basename "$source_file")"
	destination_file="$destination_directory/$file_name"
	temporary_file="$(mktemp "$destination_directory/.${file_name}.XXXXXX")"
	byte_order_mark="$(od -An -tx1 -N2 "$source_file" | tr -d '[:space:]')"
	if [[ "$byte_order_mark" == "fffe" ]]; then
		source_encoding="UTF-16"
	else
		source_encoding="UTF-16LE"
	fi
	iconv -f "$source_encoding" -t UTF-8 "$source_file" | tr -d '\r' > "$temporary_file"
	mv "$temporary_file" "$destination_file"
	temporary_file=""
	imported_count=$((imported_count + 1))
done

"$project_root/tools/validate_utf8_scenarios.sh" "$destination_directory"
echo "Imported $imported_count KRKR scenarios as UTF-8/LF into $destination_directory"

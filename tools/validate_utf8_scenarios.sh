#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
scenario_directory="${1:-$project_root/assets/scenario}"

if [[ ! -d "$scenario_directory" ]]; then
	echo "Scenario directory not found: $scenario_directory" >&2
	exit 1
fi

scenario_count=0
for scenario_file in "$scenario_directory"/*.ks; do
	if [[ ! -f "$scenario_file" ]]; then
		continue
	fi
	scenario_count=$((scenario_count + 1))
	# macOS iconv may try to query the output descriptor when it is /dev/null,
	# so consume stdout through a pipe while preserving iconv's exit status.
	if ! iconv -f UTF-8 -t UTF-8 "$scenario_file" | wc -c >/dev/null; then
		echo "Scenario is not valid UTF-8: $scenario_file" >&2
		exit 1
	fi
	byte_order_mark="$(od -An -tx1 -N3 "$scenario_file" | tr -d '[:space:]')"
	case "$byte_order_mark" in
		efbbbf*|fffe*|feff*)
			echo "Scenario must not contain a byte-order mark: $scenario_file" >&2
			exit 1
			;;
	esac
	if LC_ALL=C grep -q $'\r' "$scenario_file"; then
		echo "Scenario must use LF line endings: $scenario_file" >&2
		exit 1
	fi
done

echo "Validated $scenario_count UTF-8/LF KRKR scenarios in $scenario_directory"

#!/usr/bin/env bash
set -euo pipefail

# Canonical entry point. The legacy filename remains as a compatibility shim
# for earlier migration notes and delegates the same full-corpus importer.
script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$script_directory/import_krkr_adv_sample_assets.sh" "$@"

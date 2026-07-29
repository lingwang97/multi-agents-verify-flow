#!/usr/bin/env bash
################################################################################
# file_manage.sh - deploy flow files from script/ into their runtime locations.
# Runs on Linux and on Windows (Git Bash / WSL / MSYS).
# Safe to run from any working directory; paths are resolved relative to this
# script so `bash script/file_manage.sh` and `./file_manage.sh` both work.
################################################################################

set -euo pipefail

# Resolve the directory this script lives in (verify/script), portably.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
root_dir="$(cd "$script_dir/.." && pwd)"   # verify/

# copy <src> <dst>: ensure the destination's parent dir exists, then copy.
copy() {
    src="$1"
    dst="$2"
    if [ ! -e "$src" ]; then
        echo "ERROR: source not found: $src" >&2
        exit 1
    fi
    mkdir -p "$(dirname "$dst")"
    cp -R "$src" "$dst"
    echo "  $src -> $dst"
}

echo "Deploying flow files (root: $root_dir)"
copy "$script_dir/utils"                  "$root_dir/utils"
copy "$script_dir/sflow/wsim"             "$root_dir/sim/wsim"
copy "$script_dir/sflow/project_name"     "$root_dir/sim/project_name"
copy "$script_dir/sflow/testjson2lst.py"  "$root_dir/tb_top/scripts/testjson2lst.py"
copy "$script_dir/sflow/Makefile"         "$root_dir/tb_top/scripts/Makefile"
copy "$script_dir/sflow/Makefile.rtdbg.tcl" "$root_dir/tb_top/scripts/Makefile.rtdbg.tcl"
copy "$script_dir/sflow/Makefile.run.tcl"   "$root_dir/tb_top/scripts/Makefile.run.tcl"
echo "Done."

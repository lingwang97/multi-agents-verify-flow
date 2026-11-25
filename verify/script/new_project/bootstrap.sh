#!/usr/bin/env bash
# bootstrap.sh <new-repo-root> [--force]
#
# Copy this verification framework into a new chip repo: framework files are
# carried, chip-specific state is reset, everything --guvc regenerates is left
# out (classification: manifest.txt). Run it once by hand - it writes outside
# this repo, which the agents' path guard does not allow. Then start Claude
# Code in <new-repo-root>/verify and run /new-project.
set -e
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
py="$(command -v python3 || command -v python)" || { echo "bootstrap: python3 is required" >&2; exit 1; }
if [ $# -lt 1 ]; then
    echo "usage: $0 <new-repo-root> [--force]" >&2
    exit 1
fi
dst="$1"; shift
exec "$py" "$here/new_project.py" bootstrap --dst "$dst" "$@"

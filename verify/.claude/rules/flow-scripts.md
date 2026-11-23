---
paths:
  - "script/sflow/**"
  - "script/file_manage.*"
  - "script/utils/**"
  - "utils/**"
  - "tb_top/scripts/**"
---

# Flow scripts, deploy and flow settings

## Source of truth and deploy

- `script/` is the source of truth. `script/file_manage.sh` (Linux / Git Bash / WSL) or `script/file_manage.ps1` (native Windows) deploys it: repo-root `sim/` (`wsim`, `wsim_oeda`, `project_name`), `tb_top/scripts/` (`Makefile*`, `testjson2lst.py`) and the whole `utils/` tree (identical copy of `script/utils/`). Both scripts are cwd-independent.
- Never edit the deployed copies; edit under `script/` and rerun the deploy.
- `wsim` is a CRLF file — normalize line endings before string-matching edits, restore CRLF afterwards.

## Flow settings: two kinds, never mixed

- **Project-level** (one value for everyone): only in `script/sflow/flow_env.sh`, assigned directly and sourced by `wsim`/`wsim_oeda` (not deployed, not shell-overridable): `WSIM_REG_TABLE`, plus the VCS-server site section `WSIM_PYTHON`, `WSIM_LSF_QUEUE`, `WSIM_LSF_HOSTS_FILE`, `WSIM_DPO_DB` (review at the Linux migration). Changing a value is a source-of-truth change.
- `wsim` forwards `WSIM_PYTHON`/`DPO_DATABASE_DIR` to the Makefile on the make command line; the Makefile holds no copies and warns when run without `wsim`.
- **Machine-level** (differs per install): `UVM_HOME`, the OSS CAD Suite `environment`, `VERDI_HOME`, the WSL `/usr/bin/python3` openpyxl fallback — environment variables with in-script defaults; never pin them in `flow_env.sh`.
- Still hard-coded site logic, to settle at the migration (taskboard): LSF enable is guessed from the hostname (`cch`/`gat0` in `wsim`); `host=sinh1` is passed to make with no known consumer.

## Gotchas

- Makefile: keep `$(error ...)` inside conditionals space-indented; a tab-indented one is parsed as a recipe line ("recipe commences before first target").
- When a Python/shell patch writes a trailing backslash (line continuation), avoid `\"`-style escapes in heredocs — a mis-escaped backslash leaves a dangling quote and `bash -n` reports "unexpected EOF while looking for matching ...".
- Validate edits with `bash -n` locally; `wsim`/Makefile behaviour on VCS/LSF can only be checked on the Linux server.

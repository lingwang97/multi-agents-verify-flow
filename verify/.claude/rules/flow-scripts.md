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

- `script/` is the source of truth. `script/file_manage.sh` deploys it: repo-root `sim/` (`wsim`, `wsim_oeda`, `project_name`), `tb_top/scripts/` (`Makefile*`, `testjson2lst.py`) and the whole `utils/` tree (identical copy of `script/utils/`). It is cwd-independent.
- Never edit the deployed copies; edit under `script/` and rerun the deploy.
- `wsim`, `wsim_oeda`, the Makefiles and `*.sh` are LF, pinned by the repo-root `.gitattributes` (a CRLF copy fails on Linux with `bash\r: bad interpreter`). A script's `#!` line must be line 1 - otherwise csh runs `./wsim` as a csh script.

## Flow settings: two kinds, never mixed

- **Project-level** (one value for everyone): only in `script/sflow/flow_env.sh`, assigned directly and sourced by `wsim`/`wsim_oeda` (not deployed, not shell-overridable): `WSIM_REG_TABLE`, plus the VCS-server site section `WSIM_PYTHON`, `WSIM_LSF_QUEUE`, `WSIM_LSF_HOSTS_FILE`, `WSIM_DPO_DB` and the LSF policy `WSIM_LSF_ENABLE` (master switch), `WSIM_LSF_SUBMIT_HOSTS` (host-name fragments allowed to submit; empty = any host), `WSIM_LSF_EXEC_HOST_REGEX` (execution hosts in the hosts file), `WSIM_LSF_QUEUE_SED` (host-group → queue name). The site values are set by `/new-project` (P3); review them whenever the server changes. Changing a value is a source-of-truth change.
- `wsim` forwards `WSIM_PYTHON`/`DPO_DATABASE_DIR` to the Makefile on the make command line; the Makefile holds no copies and warns when run without `wsim`.
- **Machine-level** (differs per install): `UVM_HOME`, the OSS CAD Suite `environment`, `VERDI_HOME`, `/usr/bin/python3` (RalGen fallback when `WSIM_PYTHON` has no openpyxl) — environment variables with in-script defaults; never pin them in `flow_env.sh`.
- `wsim` holds no site literals: every server-specific value comes from `flow_env.sh`. Keep it that way — a new site value goes into `flow_env.sh` (and the new-project variable registry), never into the script.

## Gotchas

- Makefile: keep `$(error ...)` inside conditionals space-indented; a tab-indented one is parsed as a recipe line ("recipe commences before first target").
- When a Python/shell patch writes a trailing backslash (line continuation), avoid `\"`-style escapes in heredocs — a mis-escaped backslash leaves a dangling quote and `bash -n` reports "unexpected EOF while looking for matching ...".
- Makefile recipes call `./simv`, `./simv_cmd`, `./com_cmd` - never rely on `.` in `PATH`.
- Validate edits with `bash -n` locally; `wsim`/Makefile behaviour can only be checked on a host with VCS (and LSF when enabled).

# fw_env_memory (json2env_agent)

Environment framework build & update log. Entry format: date / change / reason / impact.
The current environment state (module table, generation rules) lives in `arch_memory.md` §0; the generation-rules canon is `verify/CLAUDE.md` ("Regenerating the environment"). Per R6: framework changes are logged **here** — arch's Last-updated chain records only rule/doc changes.

## 2026-11-17 Initialization
- Change: multi-agent flow deployed; this memory created. No environment change.
- Reason: flow deployment (`docs/ops/multi_agent_ops.md`).
- Impact: none.

## Framework-change history (migrated from arch_memory.md on 2026-11-19; pre-multi-agent records, dates taken from the arch changelog)

- ≤2026-11-11 Template lifts into `gen_uvm_env.py`: OPEN_EDA guards (`top_pkg`, `tb_top_*`, `dump_wave`, `vif_declare`), `TB_TOP=tb_top`, clk/rst generation in both tb_top templates.
- ≤2026-11-11 `hdl/rtl/soc_stub.sv` removed — the system flow has no DUT until the SoC RTL lands; VCS Makefile gained the `block_env` branch (`uvm_blk_<mod>.f` selection).
- 2026-11-11 `enable_ral` config knob added (chip-global + per-module) with its generator-enforced rules.
- 2026-11-11 oEDA rename: `wsim_local` → `wsim_oeda`; scratch `uvm_scratch_oeda_<case>/`; isolation define `+define+OPEN_EDA`; old `_local` on-disk artifacts kept as-is.
- 2026-11-12 Width macros derived from the register table: RalGen (`gen_reg_model.py`) writes `verify/ral/ral_reg_width`; the old `chip_define.sv` + CORE_NUM parsing removed.
- 2026-11-20 Placeholder reg-table CSV removed from the tree (together with the placeholder-derived `verify/ral/ral_reg_model.sv` + `ral_reg_width`); reg-table dependency strictly gated by enable_ral (spec2json intake gate; RalGen dies "register table not found" if the CSV is missing when needed).
- Reason: eliminate the silent-placeholder channel (user decision).
- Impact: RAL-requiring runs fail fast until the real CSV is added; width injection defaults to 64 with a warning.

## 2026-11-23 Register-table location becomes a project-level variable
- Change: new `verify/script/sflow/flow_env.sh` defines `WSIM_REG_TABLE` (sourced directly by `wsim`/`wsim_oeda`; not deployed, not shell-overridable). RalGen reworked in both flows to read it. `wsim` now skips RalGen with a warning when the CSV is absent — it used to run RalGen unconditionally, so after the 2026-11-20 placeholder removal every VCS run (non-RAL cases included) would have aborted. mtime staleness replaces the broken git-diff check (a missing `$` made it always regenerate; git diff cannot see files outside the repo). `gen_reg_model.py` writes the md table view into `verify/ral/` (was: next to the CSV, assuming a `_reg_list.csv` suffix). `wsim_oeda` honours `WSIM_OEDA_COV` (legacy `WSIM_LOCAL_COV` still accepted). Placeholder byproduct `hdl/common/reg_table/reg_table.md` gone.
- Reason: one definition point for the table location instead of literal paths in 2 scripts + 7 docs (user decision); also fixes the VCS regression above.
- Impact: moving the table = one line in flow_env.sh. Verified on oEDA: RAL case without CSV dies with a WSIM_REG_TABLE pointer; an external CSV via the variable generates model/width/md into `verify/ral/` and efuse_smoke_block_test PASSes; apb_master smoke PASS (RalGen skipped). `wsim` (VCS) checked with `bash -n` only — server-side check queued on the taskboard.

## 2026-11-23 Site settings centralized in flow_env.sh
- Change: `flow_env.sh` gains a site section — `WSIM_PYTHON` (`/opt/anaconda3/bin/python`), `WSIM_LSF_QUEUE` (`amd7t83`), `WSIM_LSF_HOSTS_FILE`, `WSIM_DPO_DB` — with values identical to the former literals. `wsim` reads them (queue default, 4 queue-discovery greps, hosts file, RalGen + testjson2lst python, DPO merge) and forwards `WSIM_PYTHON`/`DPO_DATABASE_DIR` on the make command line; the Makefile drops its copies (DPO path, `python2` seed — now `print()`-style, works on python 3) and warns when run without wsim. Dead `--define .../chip_define.sv` argument removed (file gone since 2026-11-12; testjson2lst never read it). `wsim` seed test fixed: the unquoted `[ -n $OPTS_SEED_VALUE ]` was always true, so make always got an empty `seed=` and the random-seed branch was dead.
- Reason: one definition point per site value ahead of the Linux migration (user decision); `python2` likely absent on the new server.
- Impact: three different python interpreters unified into one; migration = edit one file. Verified: `bash -n`; GNU make probe in WSL (vars flow in from the command line, DPO dbdir expands, seed generated on python3, explicit `seed=42` honoured, warning when make runs without wsim); stale-literal scan clean; oEDA apb_master smoke PASS. Not verified: a real VCS/LSF run (server-only). Open: hostname-based LSF enable, `host=sinh1` consumer — settle at the migration.

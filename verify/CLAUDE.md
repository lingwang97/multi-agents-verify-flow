# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A UVM (SystemVerilog, UVM-1.2) chip verification environment for an SoC named `soc` (project id `PID 003`). The environment is largely **auto-generated** from JSON descriptions by Python scripts, then hand-extended. There are per-module UVCs (current module list and per-module status: `docs/memory/arch_memory.md` §0), a top-level env that assembles them, and a shell/Makefile flow (`wsim`) that drives Synopsys VCS + Verdi, with LSF (`bsub`) dispatch and DPO support.

This working directory (`verify/`) is the single UVM verification tree in the repo. Standing rules, lessons and the current architecture state live in `docs/memory/arch_memory.md` — read it before structural changes (new module, new flow branch, skill/script edits) and append new rules there.

## Commands

The VCS flow compiles and simulates on Linux with VCS/Verdi/LSF — **not natively on this Windows dev box** (use the local open-source flow below for that). `wsim` is the single entry point; it generates the RAL model, expands the test list from JSON, then compiles and simulates each case in `sim/uvm_scratch_*/` scratch dirs under the repo-root `sim/`.

Run from the repo-root `sim/` (a sibling of `verify/`, where `wsim` and `project_name` are deployed by `file_manage.sh`; `-uvm` in the examples is accepted by `wsim` but is a no-op in this environment):

```bash
./wsim -c reg_smoke_test -uvm            # run one test case
./wsim -c reg_smoke_test -uvm -fsdb      # + dump FSDB waveform (forces iteration=1)
./wsim -c reg_smoke_test -seed 12345     # fixed seed (default: random)
./wsim -m reg                            # run all tests for module 'reg'
./wsim -smoke | -stage1 | -stage2 | -full   # regression groups (from case JSON flags)
./wsim -l gate|post -corner typ|bst|wst  # gate/post-layout sim with SDF
./wsim -cm                               # enable code coverage
./wsim -gui                              # launch Verdi GUI
./wsim -h                                # full option list
```

Pass/fail is decided by grepping `UVM_ERROR`/`UVM_FATAL` counts in `sim.log`; results roll up into `result.txt` and re-run commands for failures land in `fail_wave.txt`. The Makefile (`tb_top/scripts/Makefile`, source in `script/sflow/Makefile`) builds the actual `vcs`/`simv` command lines from `wsim`'s options; look there to understand what a given switch expands to.

## Open-source EDA flow (oEDA: `wsim_oeda`, WSL2 + Verilator)

A second, fully open-source flow runs **locally on the Windows box** inside WSL2 (Ubuntu 24.04): Verilator (from OSS CAD Suite) + UVM-1.2 + FST waveforms + `verilator_coverage`. **The VCS/Verdi/LSF flow above stays the golden reference** — the local flow is for bring-up, smoke runs, stimulus development and line/toggle code coverage. Two hard limits: Verilator does **not** collect covergroup-based functional coverage (parsed only, so `*_coverage.sv`/`cg_addr`/`cg_bits` stay VCS-only), and its constraint solver handles only simple constraints.

One-time WSL2/OSS-CAD-Suite setup, the Surfer waveform viewer and the Windows-side invocation caveats (full `wsl.exe` path, Git Bash quoting / `MSYS_NO_PATHCONV`) are machine-specific and live in `docs/ops/oeda_local_setup.md`.

Usage — deploy like any flow script, run from the repo-root `sim/` in WSL (single case only; `-m`/regression groups stay on VCS):

```bash
bash script/file_manage.sh                # deploys sim/wsim_oeda (like sim/wsim)
./wsim_oeda -c reg_smoke_test            # build + run (FST dump on by default)
./wsim_oeda -c reg_smoke_test -seed 1    # fixed base seed
./wsim_oeda -c reg_smoke_test -nowave    # no waveform dump
./wsim_oeda -c reg_smoke_test -covrpt    # + verilator_coverage report in cov_report/
```

Scratch is `sim/uvm_scratch_oeda_<case>/comp_<case>/` (compile+run cwd — deliberately three levels below the repo root, matching VCS's `comp_<test>/` convention, because the `.f` files' `../../../verify/...` paths are written against that depth): `compile.log`, `uvm_oeda.f` (preprocessed filelist — `-f` expanded, `//` comments stripped, per-directory `+incdir` added), `run_iterN/{sim.log,wave.fst,coverage.dat}`, `cov_report/`. Pass criterion (oEDA): simv exit 0 and no `UVM_ERROR`/`UVM_FATAL` in `run_iterN/sim.log`; the `Coverage Summary` printed by `-covrpt` mixes TB+UVC+DUT — read the annotated `cov_report/<dut>.v` for DUT-only numbers (counts prefixed `%000000` = zero-hit, `~` = partially covered). RalGen runs automatically (mtime-based regen, unlike `wsim`'s git-diff check) and is invoked with `/usr/bin/python3` when needed, because OSS CAD Suite bundles its own python3 without openpyxl; `WSIM_OEDA_COV=none ./wsim_oeda ...` regenerates the RAL without covergroups if a Verilator build chokes on them.

**Block-level flow.** A case whose `VCS_MACRO_OPT` carries `+<MOD>_BLOCK_TEST` makes `wsim_oeda` (via `WL_DEFINES`) and the VCS Makefile select `tb_top/filelist/uvm_blk_<mod>.f` instead of `uvm.f`, with `tb_top/tb_top/tb_top_<mod>.sv` as the sim top (which modules currently have block-level support: the §0 table in `docs/memory/arch_memory.md`). DUT specifics, case macros and quirks per module: `docs/modules/<mod>.md`; campaign reports: `docs/reports/` (template + conventions there). The system-level flow (`tb_top_soc.sv` + `uvm.f`) has no DUT and is not runnable locally until the SoC RTL lands.

`OPEN_EDA`-ifdef differences from the VCS flow (all VCS-safe): `tb_top_soc.sv` and `tb_top_apb_master.sv` guard the `sdf_annotate` `program` block (unsupported by Verilator), and `tb_top_apb_master.sv` additionally generates clk/rst and instantiates the DUT (the system-level top has no DUT); `dump_wave.sv` adds an FST branch; `top_pkg.sv` skips `` `include "uvm_pkg.sv" `` (VCS resolves it via `-ntb_opts uvm-1.2`, Verilator compiles `$UVM_HOME/src/uvm_pkg.sv` explicitly); `vif_declare.sv` assigns vifs and sets `uvm_config_db` in one `initial` (Verilator gives no initial-block ordering guarantees). Property checks are dual-tracked (2026-11-18): real SVA in `*_if_pc.sv` sits under `` `ifndef OPEN_EDA `` (VCS-only execution), and its oEDA-side equivalent procedural checks live in the monitor/scoreboard under `` `ifdef OPEN_EDA `` — keep the two in sync. The build also passes `+define+UVM_NO_DPI` and does **not** compile UVM's `dpi/uvm_dpi.cc` — UVM-1.2's `uvm_hdl.c` has only vendor simulator backends and `#error`s out otherwise; with `UVM_NO_DPI` the library falls back to its pure-SV implementations (the project's own `dpi_func.c` is unaffected). Two Verilator comment pitfalls to remember when editing sources: a comment beginning `// verilator ...` is parsed as a lint pragma (`%Error-BADVLTPRAGMA` on unknown ones), and relative `+incdir+`/file paths in `.f` files resolve against the compile cwd — hence the depth-3 scratch dir above.

## Regenerating the environment

The SV files are templates emitted by Python. **Module-private files are generated once and never overwritten**: `gen_uvm_env.py` skips any existing `uvc/<mod>/` dir, `<mod>_seq/test.sv`, `<mod>_block_base_*`, `json/case/<mod>.json`, `tb_top_<mod>.sv`, `uvm_blk_<mod>.f`, `tb_top_<mod>.f` and `<mod>_if_conn*` (hand-extended files like apb_master's are safe). **Assembly files** (top_env, top_vseqr, top_pkg, vif_declare, base_seq/test, soc_sequence_lib, uvm.f, tb_define, tb_top_soc) are template-pure and are rewritten on every run — never hand-edit them; lift needed changes into `script/gen_uvm_env.py` templates instead.

Module add/remove workflow: edit the config, then run `--guvc` (new module files are generated, existing ones skipped), check `git diff`, then smoke one case. To remove a module, delete it from the config, rerun `--guvc`, then `--prune` lists the orphaned module files and `--prune --yes` deletes them. After any regen, verify with `git diff` + one smoke run (`./wsim_oeda -c apb_master_smoke_block_test`); commit (or be ready to `git checkout --`) before regenerating.

```bash
# from script/
python gen_uvm_env.py --gcfg                          # emit a config template (uvm_env_config_template.json)
python gen_uvm_env.py -c uvm_env_config_template.json --guvc [--overwrite]  # generate all UVCs + base_seq + base_test
python gen_uvc.py -n <name> -o <dir> [-t <bus_type>]  # generate a single UVC (adapter only if -t given; -p overrides parent dir, default uvc/)
python gen_uvm_env.py -c ... --prune [--yes]         # list/delete module files whose module is gone from the config
```

- `script/uvm_env_config_template.json` is the **source of truth** for which modules exist and their attributes (`is_active`, `has_interface`, `has_config`, `adapter_type` — empty string means no adapter, non-empty generates the `reg2<bus>` adapter, `enable_ral` — default true, false drops the RAL from block-level files (requires `adapter_type` empty), `has_tb_top`). Add a module here, regenerate, then wire it into filelists. Generator-enforced rules: non-empty `adapter_type` requires the module `enable_ral: true`; top-level `enable_ral: false` requires every module `enable_ral: false` and `adapter_type: ""` (the system flow builds ONE chip model from the whole reg-table CSV, so per-module RAL cannot survive a chip without one).
- `script/file_manage.sh` (Linux / Git Bash / WSL) or `script/file_manage.ps1` (native Windows) deploys flow files out of `script/` into their runtime locations: the repo-root `sim/` (`wsim`, `project_name`), `tb_top/scripts/` (`Makefile*`, `testjson2lst.py`), and the whole `utils/` tree. Both are script-relative (runnable from any cwd) and do the same copies. **`script/` is the source of truth**: `utils/` is deployed output of `script/utils/` (the two trees are identical copies), so edit under `script/` and re-run the deploy instead of editing deployed copies.
- The RAL model (`verify/ral/ral_reg_model.sv`) is generated by the `RalGen` step of `wsim`/`wsim_oeda` (via `utils/reg/gen_reg_model.py`) from the register-table CSV at **`$WSIM_REG_TABLE`** — a project-level variable defined once in `verify/script/sflow/flow_env.sh`, sourced directly by both flow scripts (not deployed, not overridable from the shell). Moving the table = edit that one line (source-of-truth change). **The reg table is a conditional dependency gated by `enable_ral`**: no CSV is checked in; `wsim_oeda` runs RalGen only when the selected filelist references the RAL model and dies with a pointer to `WSIM_REG_TABLE` if the CSV is missing; `wsim` skips RalGen with a warning when the CSV is absent (a RAL-compiling case then fails at compile time). When a config enables `enable_ral`, the spec2json intake gate asks the user for the table's location. RalGen regenerates when the model is older than the CSV or the generator (mtime) and writes the model, `ral_reg_width` and a `<csv-name>.md` table view into `verify/ral/` — never into the CSV's directory. testjson2lst derives the reg-width macros from `ral_reg_width` and defaults to 64 with a warning when it is absent. Everything under `verify/ral/` is generated output (do not edit or commit) and absent from a fresh checkout until a flow runs (`tb_top/filelist/uvm.f` already references `../../../verify/ral/ral_reg_model.sv`).
- `--guvc` also emits, per module, a `<mod>_smoke_test`/`<mod>_smoke_seq` pair (and `<mod>_smoke_block_test`/`<mod>_smoke_block_seq` for block-level) with empty stimulus — a runnable-but-inert starting point, not a real regression test.

## Writing a new test case

`.claude/skills/add-test-case/test_case_dev_manual.md` is the task-oriented guide for adding a leaf test case (which base class to extend, how to start a sequence on `top_virtual_sequencer`, JSON case-entry rules, and the per-layer state of the template UVCs; the maintained list of current blockers lives in `docs/memory/arch_memory.md` §9). Read it before hand-writing a new `test/`/`seq/` class. `.claude/skills/add-test-case/` automates the mechanical scaffolding (test class + sequence class + JSON entry, system or block level) that manual describes in its §3/§4 — real stimulus still has to be filled in by hand. Prefer invoking this skill over hand-writing leaf classes. Adding or removing a module also requires syncing the skill (`MODULES` + `SKILL.md`), this file and the manual — checklist in `docs/memory/arch_memory.md` R1/R2.

## Test case definition (JSON → test list)

Test cases are **not** enumerated in SV. They live in `json/case/<module>.json`, indexed by `json/module.json`. `tb_top/scripts/testjson2lst.py` (source `script/sflow/testjson2lst.py`) reads these plus the chip define file and emits a `.list` that `wsim` iterates.

Each case entry carries: regression-group booleans (`stage1`/`stage2`/`smoke`/`full`, plus `codecoverage`), `iteration`, `UVM_TESTNAME` (the actual `+UVM_TESTNAME` — note the JSON *key* is a logical case name that can differ from `UVM_TESTNAME`), `VCS_MACRO_OPT` (compile `+define+`s), and `VCS_PLUSARGS_OPT` (runtime `+plusargs`). Global/UVM-wide macros live in `json/module.json`. To add a test: add an entry to the module's case JSON — do not hand-edit list files.

## Architecture

**UVC pattern (per module, under `uvc/<name>/`).** Every UVC is generated to the same shape by `gen_uvc.py`: `src/` holds `*_agent`, `*_driver`, `*_monitor`, `*_scoreboard`, `*_coverage`, `*_sequencer`, `*_sequence_item`, `*_item`, `*_coverage_item`, `*_base_cfg`/`*_cfg`, `*_if`(+`*_if_pc` for props/cover), and optionally `*_reg2<bus>_adapter`; `env/` holds `*_env` + `*_pkg` (the include manifest); `script/uvm.f` is the compile filelist. `*_agent`/`*_env`/`*_monitor`/`*_scoreboard` all extend the shared `base_*` classes in `utils/base_uvc/` (e.g. `drv_is_active` lives on `base_env`, not the per-module env). The agent's monitor/scoreboard handles are named `<mod>_monitor_h`/`<mod>_scoreboard_h` (not `m_monitor`/`m_scoreboard`) — that naming is what `set_mon_checks_enable(.name("<mod>_monitor_h"), ...)` etc. expect. When adding signals or logic, follow the generated skeleton — e.g. a new interface signal must be added in `*_if.sv`, sampled in the monitor, and covered in `*_coverage.sv`.

**Top assembly.** `env/top_env.sv` instantiates every `*_env`, sets `drv_is_active = UVM_ACTIVE` on the active ones, builds the virtual sequencer `top_virtual_sequencer` (`env/top_vseqr.sv`) and connects each module sequencer into it, and builds/locks the RAL model (`ral.set_hdl_path_root(...)` points into the DUT hierarchy). `env/top_pkg.sv` is the top include manifest; `env/top_if.sv` the top interface.

**Test/sequence base.** `test/base_test.sv` and `seq/base_seq.sv` are the generated bases that declare a handle + virtual interface + base_cfg for **every** module and fetch them from `uvm_config_db`. Per-module tests (`test/<mod>_test.sv`) and sequences (`seq/<mod>_seq.sv`) extend these. `base_test` uses the full UVM runtime phase set (reset/configure/main/shutdown) with objections; put reset in `reset_phase`, register/warm-up init in `configure_phase`, stimulus in `main_phase`. Shared per-module sequence helpers live in `seq/comm_<mod>_methods.sv` and are `` `include ``-d into `base_seq`.

**Config & runtime toggles.** `base_cfg` objects are created and `uvm_config_db`-set in `base_test.build_phase`, then randomized in `start_of_simulation_phase`; `set_<mod>_cfg_type()` does type overrides. `utils/global_pkg.sv` declares string-keyed associative arrays (`MON_CHECKS_ENABLE`, `SB_CHECKS_ENABLE`, `IF_CHECKS_ENABLE`, `MON_COVERAGE_ENABLE`, `IF_COVERAGE_ENABLE`) that gate checkers/coverage at runtime; `base_test::set_*_enable()` are the accessors (`set_enable_flag_debug()` dumps the current state of all five arrays for debug). `*_if.sv`'s `checks_enable`/`coverage_enable` signals track `IF_CHECKS_ENABLE`/`IF_COVERAGE_ENABLE` live via `always@` blocks; in `*_monitor.sv`, `cov_enable` gates whether a sampled transaction is forwarded to `coverage_ap` at all (checks/scoreboard delivery is unaffected).

**Interface connection.** `intf/*_if_conn*.sv` bind UVC interfaces to the DUT; `*_gpls.sv` variants are for gate/post-layout (netlist) simulation. `tb_top/tb_top/tb_top_<scope>.sv` are the sim top modules; `tb_top/filelist/*.f` select RTL vs. gate vs. IP sources per sim level.

**Filelist layering.** `tb_top/filelist/uvm.f` is the UVM env filelist: base pkgs (`global_pkg` → `reg_mdl_pkg` → `ral_reg_model` → `base_uvc_pkg`) first, then each UVC's `uvm.f`, then `tb_top_soc.f` and `top_pkg.sv`. Block-level flows use `uvm_blk_<mod>.f` (e.g. `uvm_blk_apb_master.f`, `uvm_blk_efuse.f`) instead, with a per-module `tb_top_<mod>.f`. Package/include ordering matters in SV — respect the existing order when adding files.

## Conventions

- Naming is strict and load-bearing: a module `foo` implies class prefix `foo_`, package `foo_pkg`, interface `foo_if`, config-db keys `foo_vif`/`foo_cfg`, macro guards `__FOO_*__`. The generators assume it; keep it.
- Block-level vs. system-level sim is selected by a `+define+<MOD>_BLOCK_TEST` macro (selection mechanics in the oEDA "Block-level flow" paragraph above) — block tests use different filelists and register-init config.
- Filelist paths are relative to the scratch run dir (both `comp_<testname>/` and the `sim_*` scene dirs sit three levels below the repo root) and use the `../../../verify/...` prefix; keep that when editing `.f` files.
- **Flow settings come in two kinds — never mix them.** *Project-level* values (one value for everyone on this project) live only in `verify/script/sflow/flow_env.sh`, assigned directly and sourced by `wsim`/`wsim_oeda` (not deployed, not shell-overridable): `WSIM_REG_TABLE`, plus the VCS-server site section `WSIM_PYTHON` (flow helper python), `WSIM_LSF_QUEUE`, `WSIM_LSF_HOSTS_FILE`, `WSIM_DPO_DB` — review that section at the Linux migration. `wsim` forwards `WSIM_PYTHON`/`DPO_DATABASE_DIR` to the Makefile on the make command line (the Makefile holds no copies and warns when run without wsim). *Machine-level* values that differ per install (`UVM_HOME`, the OSS CAD Suite `environment`, `VERDI_HOME`, the WSL `/usr/bin/python3` openpyxl fallback) stay environment variables with in-script defaults — never pin them in `flow_env.sh`. Still hard-coded site logic to settle at the migration: LSF enable is guessed from the hostname (`cch`/`gat0` in `wsim`), and `host=sinh1` is passed to make with no known consumer.

## Multi-agent verification flow

An orchestrated agent flow runs on this tree — the main session is the **leader**, scheduling the subagents defined in `.claude/agents/` (spec2json/json2env/dev/debug/deliver/review; one dev/debug instance per module) and never editing code itself. **Canonical rules** (roles & call rights, tiered confirmation, scheduling, passrate/coverage policy, hooks, full doc map): `docs/ops/multi_agent_ops.md`; deployment record: `docs/memory/arch_memory.md` §8. Hard rails: agents write only under `verify/`/`deliver_bridge/`/`sim/` (path_guard hook) and never `git commit` (hook-blocked; the leader commits with a `COMMIT_APPROVED=1` prefix after user approval). Per-module DUT knowledge canon: `docs/modules/<mod>.md`; role memories and taskboard per the ops doc map. Language: agent conversational output (replies, reports) is in Chinese; every file written into the project is in English. On a brand-new verification request the leader runs the intake procedure (ops §8): propose the standard pipeline (spec2json → json2env → dev/debug → review → deliver) with per-stage scope and skip hints, and the user decides to adopt, skip named stages, or override.

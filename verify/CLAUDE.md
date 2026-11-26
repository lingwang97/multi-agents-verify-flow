# CLAUDE.md

UVM-1.2 (SystemVerilog) verification environment for the SoC `chip`. Mostly generated from JSON by Python scripts, then hand-extended: per-module UVCs, a top env that assembles them, and the `wsim` shell/Makefile flow (VCS + Verdi, LSF dispatch, DPO).

- Launch Claude Code from `verify/` (this directory). Hooks, settings, agents, skills and rules all live in `verify/.claude/`; the repo root has no Claude config.
- Design database (RTL, IP, netlists, register table): repo-root relative (design root: `hdl`); a new project records its own with `/new-project`.
- `verify/` is the single UVM tree in the repo. Module list/state, standing rules and lessons: `docs/memory/arch_memory.md` — read it before structural changes (new module, flow branch, skill/script edit) and append new rules there.
- Path-scoped rules in `.claude/rules/` load when you open matching files: `oeda-verilator.md` (`*.sv`), `generated-assembly.md` (template-pure assembly files), `filelists.md` (`*.f`), `flow-scripts.md` (`script/sflow`, deploy, `utils/`).

## Commands

VCS flow — the golden reference (Linux host with VCS/Verdi; LSF dispatch optional). Run from the repo-root `sim/` (sibling of `verify/`; `wsim` and `project_name` are deployed there by `file_manage.sh`):

```bash
./wsim -c <case> -uvm                    # run one test case (-uvm is accepted but a no-op)
./wsim -c <case> -uvm -fsdb              # + dump FSDB waveform (forces iteration=1)
./wsim -c <case> -seed 12345             # fixed seed (default: random)
./wsim -m <mod>                          # run all tests of module <mod>
./wsim -smoke | -stage1 | -stage2 | -full   # regression groups (from case JSON flags)
./wsim -l gate|post -corner typ|bst|wst  # gate/post-layout sim with SDF
./wsim -cm                               # enable code coverage
./wsim -gui                              # launch Verdi GUI
./wsim -h                                # full option list
```

- `wsim` generates the RAL model, expands the test list from JSON, then compiles and simulates each case in `sim/uvm_scratch_<case>/`.
- Pass = no `UVM_ERROR`/`UVM_FATAL` in `sim.log`. Results roll up into `result.txt`; rerun commands for failures land in `fail_wave.txt`.
- What a switch expands to: the Makefile (source `script/sflow/Makefile`, deployed to `tb_top/scripts/`).

## Open-source EDA flow (oEDA: `wsim_oeda`, Verilator)

Local fast-iteration flow, run natively on Linux: Verilator (OSS CAD Suite) + UVM-1.2 + FST waves + `verilator_coverage`. Machine setup and the waveform viewer: `docs/ops/oeda_local_setup.md`.

```bash
# from the repo-root sim/; single case only (-m / regression groups stay on VCS)
bash ../verify/script/file_manage.sh     # deploys sim/wsim_oeda next to sim/wsim
./wsim_oeda -c <case>                    # build + run (FST dump on by default)
./wsim_oeda -c <case> -seed 1            # fixed base seed
./wsim_oeda -c <case> -nowave            # no waveform dump
./wsim_oeda -c <case> -covrpt            # + verilator_coverage report in cov_report/
```

- Limits: covergroups are parsed but not collected (`*_coverage.sv` converges on VCS only); only simple constraints; no SVA (dual-track rule: `.claude/rules/oeda-verilator.md`). VCS stays the sign-off flow (arch §5).
- Scratch: `sim/uvm_scratch_oeda_<case>/comp_<case>/` — the compile+run cwd, three levels below the repo root to match the `.f` path depth. It holds `compile.log`, `uvm_oeda.f`, `run_iterN/{sim.log,wave.fst,coverage.dat}` and `cov_report/`.
- Pass = simv exit 0 and no `UVM_ERROR`/`UVM_FATAL` in `run_iterN/sim.log`. The `-covrpt` summary mixes TB+UVC+DUT; DUT-only numbers are in the annotated `cov_report/<dut>.v` (`%000000` = zero-hit, `~` = partial).
- `WSIM_OEDA_COV=none ./wsim_oeda ...` regenerates the RAL without covergroups if a Verilator build chokes on them.
- **Block-level flow**: a case whose `VCS_MACRO_OPT` carries `+<MOD>_BLOCK_TEST` makes both flows compile `tb_top/filelist/uvm_blk_<mod>.f` with top `tb_top/tb_top/tb_top_<mod>.sv` instead of `uvm.f` (supported modules: arch §0). Block tests also use their own register-init config.
- The system-level flow (`tb_top_chip.sv` + `uvm.f`) has no DUT and is not runnable until the SoC RTL lands.
- Per-module DUT facts, case macros and quirks: `docs/modules/<mod>.md`. Campaign reports: `docs/reports/`.

## Regenerating the environment

- `script/uvm_env_config_template.json` is the source of truth for which modules exist. Per-module knobs: `is_active`, `has_interface`, `has_config`, `adapter_type`, `enable_ral`, `has_tb_top`.
  - `adapter_type`: `""` = no adapter; non-empty generates the `reg2<bus>` adapter and requires the module's `enable_ral: true`.
  - `enable_ral` (default true): false drops the RAL from block-level files. A top-level `enable_ral: false` requires every module `enable_ral: false` and `adapter_type: ""` — the system flow builds ONE chip model from the whole reg table. Both rules are generator-enforced.
- **Module-private files are generated once, never overwritten**: `gen_uvm_env.py` skips existing `uvc/<mod>/`, `<mod>_seq/test.sv`, `<mod>_block_base_*`, `json/case/<mod>.json`, `tb_top_<mod>.sv`, `uvm_blk_<mod>.f`, `tb_top_<mod>.f`, `<mod>_if_conn*`.
- **Assembly files are template-pure, rewritten on every run**: top_env, top_vseqr, top_pkg, top_if/top_if_pc, base_seq/test, chip_sequence_lib, `json/module.json`, uvm.f, tb_define, tb_top_chip, and `tb_top/component/` (vif_declare, dump_wave, if_conn, tb_sdf). Never hand-edit them; lift changes into the `script/gen_uvm_env.py` templates.
- **User-maintained skeletons are generated once, never overwritten**: `tb_top/filelist/` source lists (`rtl_file_lst.f`, `ip_file_lst.f`, `gate_file_lst.f`, `gate_ip_file_lst.f`, `lib_lst.f`, `gpls_lib_lst.f`, `include.f`), `tb_top/macro/rtl_define.f` and `tb_top/config/*.cfg`. The generator only writes the empty skeleton; the design content (sources, include dirs, defines) is filled by the `/new-verification` design-input step (scan → suggestions → user confirms), VCS configs by hand.
- Commit (or be ready to `git checkout --`) before regenerating; afterwards check `git diff` + one smoke run (`./wsim_oeda -c <mod>_smoke_block_test` for a block-capable module).
- Module add/remove (`--guvc`, then `--prune [--yes]` for orphans): json2env_agent charter. No instruction file names modules (the add-test-case skill reads `json/module.json`); only the state docs change - arch R1/R2.
- `--guvc` also emits inert `<mod>_smoke_test`/`_seq` (and `_smoke_block_` for block level) — a runnable starting point, not a real test.

```bash
# from script/
python gen_uvm_env.py --gcfg                          # emit a config template
python gen_uvm_env.py -c uvm_env_config_template.json --guvc [--overwrite]  # generate UVCs + base_seq + base_test
python gen_uvc.py -n <name> -o <dir> [-t <bus_type>]  # single UVC (adapter only with -t; -p overrides parent dir)
python gen_uvm_env.py -c ... --prune [--yes]         # list/delete files of modules gone from the config
```

## Flow scripts and the register table

- `script/` is the source of truth; `sim/wsim*`, `tb_top/scripts/` and `utils/` are deployed copies — edit under `script/`, then rerun `script/file_manage.sh`.
- Flow settings: project-level values live only in `script/sflow/flow_env.sh`; machine-level values stay environment variables. Details: `.claude/rules/flow-scripts.md`.
- The RAL model `verify/ral/ral_reg_model.sv` is generated by the `RalGen` step of both flows (`utils/reg/gen_reg_model.py`) from the CSV at `$WSIM_REG_TABLE`, defined once in `script/sflow/flow_env.sh`.
  - The reg table is a conditional dependency gated by `enable_ral`; no CSV is checked in. When a config enables `enable_ral`, the spec2json intake gate asks the user for its location.
  - `wsim_oeda` runs RalGen only when the selected filelist references the RAL model, using `WSIM_PYTHON` - or `/usr/bin/python3` - whichever has openpyxl (OSS CAD Suite's python lacks it). It dies with a `WSIM_REG_TABLE` pointer if the CSV is missing.
  - `wsim` skips RalGen with a warning when the CSV is absent; a RAL-compiling case then fails at compile time.
  - Both regenerate when the model is older than the CSV or the generator (mtime). Output goes to `verify/ral/`: the model, `ral_reg_width` and a `<csv-name>.md` table view.
  - `verify/ral/` is generated output: never edit or commit it; it is absent until a flow runs.

## Test cases

- Cases are JSON, not SV: `json/case/<mod>.json`, indexed by `json/module.json` (global/UVM-wide macros live there). `testjson2lst.py` (source `script/sflow/`) turns them into the `.list` that `wsim` iterates, adding reg-width macros from `verify/ral/ral_reg_width` (64 with a warning when absent). Never hand-edit list files.
- Entry fields: regression booleans `stage1`/`stage2`/`smoke`/`full` plus `codecoverage`; `iteration`; `UVM_TESTNAME` (the JSON key is a logical case name and may differ); `VCS_MACRO_OPT` (compile `+define+`s); `VCS_PLUSARGS_OPT` (runtime plusargs).
- New leaf test: use the add-test-case skill (scaffolds test + seq + JSON entry, system or block level), guided by `.claude/skills/add-test-case/test_case_dev_manual.md`. Current blockers: arch §9.

## Architecture (what the code does not make obvious)

- **UVC pattern**: every `uvc/<mod>/` has the `gen_uvc.py` shape (`src/`, `env/<mod>_env` + `<mod>_pkg`, `script/uvm.f`). Follow it: a new interface signal goes into `*_if.sv`, is sampled in the monitor and covered in `*_coverage.sv`.
- Agent/env/monitor/scoreboard extend `utils/base_uvc/base_*`; `drv_is_active` lives on `base_env`. Monitor/scoreboard handles are named `<mod>_monitor_h`/`<mod>_scoreboard_h` — `set_mon_checks_enable(.name("<mod>_monitor_h"), ...)` etc. depend on it.
- **Top assembly**: `env/top_env.sv` builds every `*_env`, the virtual sequencer `top_virtual_sequencer` (`env/top_vseqr.sv`) and the RAL model (`ral.set_hdl_path_root(...)`).
- **Test/sequence base**: `test/base_test.sv` / `seq/base_seq.sv` hold a handle + vif + base_cfg for every module. Reset goes in `reset_phase`, register/warm-up init in `configure_phase`, stimulus in `main_phase`. `seq/comm_<mod>_methods.sv` is `` `include ``-d inside `base_seq`'s class body.
- **Runtime toggles**: `base_cfg` objects are set in `base_test.build_phase` and randomized in `start_of_simulation_phase`; `set_<mod>_cfg_type()` does type overrides. The `utils/global_pkg.sv` arrays `MON_CHECKS_ENABLE`, `SB_CHECKS_ENABLE`, `IF_CHECKS_ENABLE`, `MON_COVERAGE_ENABLE`, `IF_COVERAGE_ENABLE` gate checks/coverage via `base_test::set_*_enable()` (`set_enable_flag_debug()` dumps them). The monitor's `cov_enable` gates only the `coverage_ap` path, not checks/scoreboard.
- **Interface connection** (block level): `tb_top_<mod>.sv` holds the interface instance and its initialization (vif + `uvm_config_db` in one `initial`), clk/rst and the DUT instance, whose ports bind only to `dut_<port>` nets. `intf/<mod>_if_conn.sv` declares those nets and connects them to the interface (Part 1 ports, Part 2 gray-box internals read hierarchically); `<mod>_if_conn_gpls.sv` is the gate/post-layout variant, selected by `GPL_SIM`. The include sits before the DUT instance. System level: `tb_top/component/if_conn.sv` includes the per-module files.

## Conventions

- Naming is load-bearing: module `foo` ⇒ class prefix `foo_`, package `foo_pkg`, interface `foo_if`, config-db keys `foo_vif`/`foo_cfg`, macro guards `__FOO_*__`. The generators assume it.
- Language: conversational output (replies, reports) is in Chinese; every file written into the project is in English.

## Multi-agent verification flow

- The main session is the **leader**: it schedules the `.claude/agents/` subagents (spec2json/json2env/dev/debug/deliver/review; one dev/debug instance per module) and never edits code. debug_agent runs VCS within the ops §3 tiers (auto / proposed / confirm). Rules (roles, tiered confirmation, scheduling, passrate/coverage, hooks, doc map): `docs/ops/multi_agent_ops.md`; deployment record: arch §8.
- Hard rails (path_guard hook, ops §6): agents write only under `verify/`, `deliver_bridge/`, `sim/`; sub-agent edits of source-of-truth files and new reference models need the user (prompt in default mode, blocked in auto mode); only the leader commits, with a `COMMIT_APPROVED=1` prefix after user approval; in doc mode sub-agents read the design RTL only with a per-dispatch grant the user approved (ops §1 RTL access).
- On a brand-new verification request the leader runs the intake procedure (ops §8, `/new-verification`). A new chip project is bootstrapped by `script/new_project/bootstrap.sh` and parameterized with `/new-project` first; later framework versions come in with `/new-project sync <framework-repo>`.

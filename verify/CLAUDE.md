# CLAUDE.md

UVM-1.2 (SystemVerilog) verification environment for the SoC `chip`. Mostly generated from JSON by Python scripts, then hand-extended: per-module UVCs, a top env that assembles them, and the `wsim` shell/Makefile flow (VCS + Verdi, LSF dispatch, DPO).

- Launch Claude Code from `verify/` (this directory). Hooks, settings, agents, skills and rules all live in `verify/.claude/`; the repo root has no Claude config.
- Design database (RTL, IP, netlists, register table): repo-root relative (design root: `hdl`); a new project records its own with `/new-project`.
- `verify/` is the single UVM tree in the repo. Module list/state, bring-up checklist and open gaps: `docs/memory/arch_memory.md` — read it before structural changes (new module, flow branch, skill/script edit); framework maintenance rules R1–R7 live in `.claude/rules/maintenance.md`.
- Path-scoped rules in `.claude/rules/` load when you open matching files: `oeda-verilator.md` + `uvm-architecture.md` (`*.sv`), `generated-assembly.md` (template-pure assembly files), `filelists.md` (`*.f`), `flow-scripts.md` (`script/sflow`, deploy, `utils/`), `ral.md` (RAL / register table).

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

- One directory per invocation: `sim/uvm_scratch_<case|mod|group>_<timestamp>_<mtm>_<corner>_<level>/` (`-tag <t>` replaces the timestamp part, `-nopostfix` drops it) with `comp_<case>/` (compile; `simv.vdb` with `-cm`), one `sim.log` per run, `result.txt` (every run + pass rate) and `fail_wave.txt` (rerun commands for failures).
- Pass = no `UVM_ERROR`/`UVM_FATAL` in `sim.log`. Runtime plusargs: `./wsim -c <case> +NAME=value ...` (also `wsim_oeda`; placed before the case JSON plusargs, so they win).

## Open-source EDA flow (oEDA: `wsim_oeda`, Verilator)

Local fast-iteration flow, run natively on Linux: Verilator (OSS CAD Suite) + UVM-1.2 + FST waves + `verilator_coverage`. Machine setup: `docs/ops/oeda_local_setup.md`.

```bash
# from the repo-root sim/
bash ../verify/script/file_manage.sh     # deploys sim/wsim_oeda next to sim/wsim
./wsim_oeda -c <case>                    # build + run one case (FST dump on by default)
./wsim_oeda -c <case> -seed 1            # fixed seed (iteration forced to 1, like wsim)
./wsim_oeda -m <mod>                     # all cases of a module (waves off; -wave to dump)
./wsim_oeda -smoke | -stage1 | -stage2 | -full   # regression groups (same selection as wsim)
./wsim_oeda -m <mod> -j 4                # parallel simulations (default 2; builds run one at a time)
./wsim_oeda ... -nowave | -covrpt        # no waves / + verilator_coverage report
```

- Limits: covergroups are parsed but not collected (`*_coverage.sv` converges on VCS only); only simple constraints; no SVA (dual-track rule: `.claude/rules/oeda-verilator.md`); no gate/post level. VCS stays the sign-off flow (`.claude/rules/two-flow.md`).
- Builds are shared: cases with the same filelist, defines and wave/coverage flags use one Verilator build in `sim/oeda_build/`, rebuilt automatically when a source changes (`WSIM_OEDA_COV=none` regenerates the RAL without covergroups). Per case: `sim/uvm_scratch_oeda_<case>/result.txt` + `comp_<case>/run_iterN/`; a `-m`/group run also writes `sim/oeda_result.txt`, `sim/oeda_fail_rerun.txt` and (with `-covrpt`) the merged `sim/oeda_cov_<mod|group>/`. Exit status 0 only when every run passed.
- Pass = simv exit 0 and no `UVM_ERROR`/`UVM_FATAL` in `run_iterN/sim.log`. The `-covrpt` summary mixes TB+UVC+DUT; DUT-only numbers are in the annotated `cov_report/<dut>.v` (`%000000` = zero-hit, `~` = partial).
- **Block-level flow**: a case whose `VCS_MACRO_OPT` carries `+<MOD>_BLOCK_TEST` makes both flows compile `tb_top/filelist/uvm_blk_<mod>.f` with top `tb_top/tb_top/tb_top_<mod>.sv` instead of `uvm.f` (supported modules: arch §0). Block tests also use their own register-init config. The system-level flow (`tb_top_chip.sv` + `uvm.f`) has no DUT and is not runnable until the SoC RTL lands.
- Per-module DUT facts, case macros and quirks: `docs/modules/<mod>.md`. Campaign reports: `docs/reports/`.

## Regenerating the environment

- `script/uvm_env_config_template.json` is the source of truth for which modules exist. Per-module knobs: `is_active`, `has_interface`, `has_config`, `adapter_type`, `enable_ral`, `has_tb_top`; `adapter_type: ""` = no adapter, non-empty generates the `reg2<bus>` adapter and requires `enable_ral: true`; `enable_ral: false` (default true) drops the RAL from block-level files, and a top-level `false` requires every module `false` + `adapter_type: ""` (ONE chip model) — both rules are generator-enforced. RalGen / reg-table behaviour: `.claude/rules/ral.md`.
- **Module-private files are generated once, never overwritten**: `gen_uvm_env.py` skips existing `uvc/<mod>/`, `<mod>_seq/test.sv`, `<mod>_block_base_*`, `json/case/<mod>.json`, `tb_top_<mod>.sv`, `uvm_blk_<mod>.f`, `tb_top_<mod>.f`, `<mod>_if_conn*` — hand extension is safe.
- **Assembly files are template-pure, rewritten on every run**: top_env, top_vseqr, top_pkg, top_if/top_if_pc, base_seq/test, chip_sequence_lib, `json/module.json`, uvm.f, tb_define, tb_top_chip, and `tb_top/component/` (vif_declare, dump_wave, if_conn, tb_sdf). Never hand-edit them; lift changes into the `script/gen_uvm_env.py` templates.
- **User-maintained skeletons are generated once, never overwritten**: `tb_top/filelist/` source lists, `tb_top/macro/rtl_define.f`, `tb_top/config/*.cfg`. The generator writes only the skeleton; the design content comes from the `/new-verification` design-input step, VCS configs by hand.
- Commit (or be ready to `git checkout --`) before regenerating; afterwards check `git diff` + one smoke run (`./wsim_oeda -c <mod>_smoke_block_test` for a block-capable module). `--guvc` also emits inert `<mod>_smoke_test`/`_seq` — a runnable starting point, not a real test.
- Module add/remove (`--guvc`, then `--prune [--yes]` for orphans): json2env_agent charter. No instruction file names modules (the add-test-case skill reads `json/module.json`); only the state docs change - `.claude/rules/maintenance.md` R1/R2.

```bash
# from script/
python gen_uvm_env.py --gcfg                          # emit a config template
python gen_uvm_env.py -c uvm_env_config_template.json --guvc [--overwrite]  # generate UVCs + base_seq + base_test
python gen_uvc.py -n <name> -o <dir> [-t <bus_type>]  # single UVC (adapter only with -t; -p overrides parent dir)
python gen_uvm_env.py -c ... --prune [--yes]         # list/delete files of modules gone from the config
```

## Test cases

- Cases are JSON, not SV: `json/case/<mod>.json`, indexed by `json/module.json` (global/UVM-wide macros live there). Entry fields: regression booleans `stage1`/`stage2`/`smoke`/`full` plus `codecoverage`; `iteration`; `UVM_TESTNAME` (the key may differ from the class name); `VCS_MACRO_OPT` (compile `+define+`s); `VCS_PLUSARGS_OPT` (runtime plusargs). Never hand-edit list files.
- New leaf test: use the add-test-case skill (scaffolds test + seq + JSON entry, system or block level), guided by `.claude/skills/add-test-case/test_case_dev_manual.md`. Current blockers: arch §2.

## Conventions

- Naming is load-bearing: module `foo` ⇒ class prefix `foo_`, package `foo_pkg`, interface `foo_if`, config-db keys `foo_vif`/`foo_cfg`, macro guards `__FOO_*__`. The generators assume it. Structural UVM facts (UVC pattern, top assembly, base classes, runtime toggles, DUT/interface wiring): `.claude/rules/uvm-architecture.md`.
- `script/` is the source of truth; `sim/wsim*`, `tb_top/scripts/` and `utils/` are deployed copies — edit under `script/`, then rerun `script/file_manage.sh`. Project-level flow settings live only in `script/sflow/flow_env.sh`; details: `.claude/rules/flow-scripts.md`, RAL: `.claude/rules/ral.md`.
- Language: conversational output (replies, reports) is in Chinese; every file written into the project is in English.

## Multi-agent verification flow

- The main session is the **leader**: it schedules the `.claude/agents/` subagents (spec2json/json2env/dev/debug/deliver/review; one dev/debug instance per module) and never edits verification code (exceptions - registry writes and user-approved framework maintenance: ops §0). debug_agent runs VCS within the ops §3 tiers (auto / proposed / confirm). Rules (roles, tiered confirmation, scheduling, passrate/coverage, hooks, doc map): `docs/ops/multi_agent_ops.md`; deployment record: `docs/memory/fw_env_memory.md` (2026-11-17 entry).
- Hard rails (path_guard hook, ops §6): agents write only under `verify/`, `deliver_bridge/`, `sim/`; sub-agent edits of source-of-truth files and new reference models need the user (prompt in default mode, blocked in auto mode); only the leader commits, with a `COMMIT_APPROVED=1` prefix after user approval; in doc mode sub-agents read the design RTL only with a per-dispatch grant the user approved (ops §1 RTL access).
- On a brand-new verification request the leader runs the intake procedure (ops §8, `/new-verification`). A new chip project is bootstrapped by `script/new_project/bootstrap.sh` and parameterized with `/new-project` first; later framework versions come in with `/new-project sync <framework-repo>`.

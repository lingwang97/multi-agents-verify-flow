# arch_memory

Architecture state, standing rules and lessons for developing this verify tree. Project-wide and tool-independent: read before structural changes, append when a new rule or lesson is learned (one entry = rule, why, how to apply). Stable "what/how" guidance lives in `verify/CLAUDE.md`; this file holds what changes with the project. Last updated 2026-11-11 (enable_ral; oEDA rename + OPEN_EDA define; closed loop 5/6; R5 regen rule + section 7 system checklist).

---

## 0. Current architecture state

| Module | UVC state (adapter_type / enable_ral) | Block-level support | Notes |
|---|---|---|---|
| `apb_master` | **fully customised** (real if/driver/monitor/scoreboard/coverage); `enable_ral: false`, no adapter | yes (`uvm_blk_apb_master.f`, `+APB_MASTER_BLOCK_TEST`) | UVC for DUT `hdl/rtl/apb_v3_sram.v`; replaced the former `jls` module; worked reference for new UVCs |
| `efuse` | generated template | yes (`uvm_blk_efuse.f`, `+EFUSE_BLOCK_TEST`) | block base pair has RAL wiring, never exercised |
| `reg`, `ro`, `uart` | generated template | no | no block filelist / base pair |

- Module source of truth: `script/uvm_env_config_template.json` and `json/module.json`. Config knobs: top-level `enable_ral` (chip-global; gates top_env/top_vseqr/base_seq/uvm.f) and per-module `adapter_type` (empty = no adapter) + `enable_ral` (default true; false drops the RAL from the block base test/seq and `uvm_blk_<mod>.f`). `wsim_oeda` skips RalGen when the selected filelist has no `ral_reg_model` line - works for both levels automatically. Generator-enforced rules: `adapter_type` non-empty requires module `enable_ral: true`; top-level `enable_ral: false` requires every module `enable_ral: false` and `adapter_type: ""` (the system flow has ONE chip model built from the whole reg table CSV, so per-module RAL cannot survive a chip without one). Caveat: the VCS Makefile `init_reg_cfg` (+vcs+initreg+...) is NOT gated - backdoor register init depends on the chip model, handle manually if top-level enable_ral is ever set false.
- System-level flow (`tb_top_soc.sv` + `uvm.f`) has no DUT (old `hdl/rtl/soc_stub.sv` removed); not runnable locally until the SoC RTL lands. `hdl/common/reg_table/reg_table_reg_list.csv` is a placeholder reg table (one `soc_reg` block).
- RAL model `verify/ral/ral_reg_model.sv` is generated output (by `wsim`/`wsim_oeda` RalGen); never edit or commit it.
- Leaf test classes: only `apb_master` has real ones (6 block tests + system smoke); other modules' JSON entries are placeholders (see `.claude/skills/add-test-case/test_case_dev_manual.md` §7 for the gap list).

---

## 1. Maintenance rules (keep documents and skills in sync)

### R1. Adding or removing a module → sync the add-test-case skill
- **Rule:** any change that adds/removes a module (`script/uvm_env_config_template.json`, `json/module.json`, `gen_uvm_env.py --guvc`) must update, in the same change:
  1. `MODULES` in `.claude/skills/add-test-case/add_test_case.py`;
  2. every module enumeration in `.claude/skills/add-test-case/SKILL.md` (frontmatter `description`, intro sentence, `--module` usage line, block-level Gotcha, Troubleshooting row);
  3. the block-level support list (does the module have `test/<mod>_block_base_test.sv` + `seq/<mod>_block_base_seq.sv` + `tb_top/filelist/uvm_blk_<mod>.f`? The flow scripts need no per-module branch, see §3).
- **Why:** the jls → apb_master migration left the skill stale; the script rejected apb_master and its test cases were hand-written instead of scaffolded.
- **Check:** `python .claude/skills/add-test-case/add_test_case.py --module <new> ...` must be accepted; the old module must be rejected.
- **Automatic reminder:** the project hook `.claude/hooks/arch_memory_check.sh` (wired in `.claude/settings.json`, `PreToolUse`/`Bash`) fires once per state when `script/uvm_env_config_template.json`, `json/module.json` or `script/gen_uvm_env.py` have uncommitted changes, or when `MODULES` in `add_test_case.py` differs from the modules in `json/module.json`. It only injects a reminder to evaluate this file, the skill (`add_test_case.py`, `SKILL.md`, `test_case_dev_manual.md`) and `CLAUDE.md`; nothing is edited until the user confirms. State is kept in `.git/arch_memory_hook.state` (delete it to re-trigger).

### R2. Adding or removing a module → sync CLAUDE.md, the dev manual and §0 above
- **Rule:** also update `verify/CLAUDE.md` (filelist notes, local-flow notes), `.claude/skills/add-test-case/test_case_dev_manual.md` (module list, adapter/block-level gap table; lives inside the skill directory since 2026-11-09) and the module table in §0 of this file.
- **Why:** these are the first documents a new session reads; stale module names mislead tooling and people.
- **Status:** manual refreshed on 2026-11-09 (jls → apb_master, §7 gaps re-verified against the tree). Re-verify the §7 gap table whenever RAL, adapters, block-level flow or JSON placeholders change.

### R3. Prefer the skill over hand-writing leaf test cases
- **Rule:** create new leaf tests/seqs/JSON entries with `add-test-case` (`python .claude/skills/add-test-case/add_test_case.py --module <mod> --function <name> --level system|block ...`), then fill in the `body()` TODO.
- **apb_master naming:** existing block tests are `apb_master_<fp>_block_test`, so pass `--function <fp>_block`. Extra compile defines go through `--macro-opt` (e.g. `+APB_SRAM_EN_WAIT`); the script prepends `+<MODULE>_BLOCK_TEST`.
- **Note:** the apb_master block tests/seqs in this repo were hand-written (script did not know the module yet); they follow the same structure as the skill templates, except the test class uses `uvm_component_utils_begin/_end` + `report_id` like the existing smoke class.

### R5. Regeneration is safe only through the template-pure assembly rule
- Module-private files (uvc/, `<mod>_seq/test`, `<mod>_block_base_*`, case json, `tb_top_<mod>.sv`, `uvm_blk_<mod>.f`, if_conn) are **skip-if-exists** — hand-extended content is never overwritten.
- Assembly files (top_env, top_vseqr, top_pkg, vif_declare, base_seq/test, soc_sequence_lib, uvm.f, tb_define, tb_top_soc) are rewritten unconditionally from templates — **never hand-edit them; lift changes into `gen_uvm_env.py` templates** (precedents: OPEN_EDA guards, TB_TOP=tb_top, clk/rst in both tb_top templates).
- Workflow: edit config -> `--guvc` -> `git diff` -> smoke one case; removal via `--prune [--yes]`.

### R4. Edit `script/`, then deploy
- `script/` is the source of truth; `sim/wsim*`, `tb_top/scripts/` and `utils/` are deployed copies. After editing `script/sflow/*`, re-run `script/file_manage.sh` (or edit and copy both when the deploy step is unavailable).

---

## 2. Open-source (WSL2 + Verilator) flow: dev-box setup and lessons

### Dev-box setup (machine-specific)
- One-time: right-click-run `C:\Users\wangling\tools\wsl-setup\enable_wsl2.bat` as administrator (VirtualMachinePlatform; one UAC + one reboot), then import the distro: `"C:\Program Files\WSL\wsl.exe" --import Ubuntu-24.04 C:\Users\wangling\wsl\Ubuntu-24.04 C:\Users\wangling\tools\wsl-setup\ubuntu-24.04-wsl-rootfs.tar.gz --version 2` (WSL 2.7.14 MSI already installed).
- Inside WSL add `source ~/tools/oss-cad-suite/environment` and `export UVM_HOME=$HOME/tools/uvm-1.2` to `~/.bashrc` (automated by `C:\Users\wangling\tools\wsl-setup\bootstrap_ubuntu.sh`).
- Waveforms: native-Windows Surfer `C:\Users\wangling\tools\surfer\surfer.exe` (FST/VCD) opening `\\wsl.localhost\Ubuntu-24.04\...` paths (SourceForge-hosted GTKWave is unreachable on this network).

### Invoking from Windows
- **Use the full path** `"/c/Program Files/WSL/wsl.exe" -d Ubuntu-24.04 -- ...` (the `system32` shim lacks the inbox kernel; symptom: exit 127 and garbled UTF-16 error).
- **Git Bash quoting:** `wsl ... bash -c '...$c...'` loses `$c` (expanded to empty on the Windows side → `wsim_oeda -c  -seed 1` "invalid option"). Put multi-command runs in a script file and call it with `MSYS_NO_PATHCONV=1` so `/mnt/c/...` is not rewritten.

### Verilator rules for UVC/tb code
- No `program` block (guard `sdf_annotate` with `` `ifndef VERILATOR ``), no SVA concurrent assertions (use procedural monitor checks), vif assign + `uvm_config_db::set` in ONE `initial`, comments must not begin with "verilator", functional covergroups are not collected (VCS only), keep constraints simple.

### Results and coverage
- **Pass criterion:** simv exit 0 and no `UVM_ERROR :`/`UVM_FATAL :` in `sim.log`. Scratch: `sim/uvm_scratch_oeda_<case>/comp_<case>/run_iterN/`.
- **Reading coverage:** the `Coverage Summary` printed by `wsim_oeda -covrpt` is a TB+UVC+DUT mixture; for DUT-only numbers read the annotated `cov_report/<dut>.v` (counts prefixed `%000000` = zero-hit, `~` = partially covered).

---

## 3. Block-level flow conventions

- Block cases carry `+<MOD>_BLOCK_TEST` in `VCS_MACRO_OPT`; `wsim_oeda` (`WL_DEFINES`) and the VCS Makefile select `tb_top/filelist/uvm_blk_<mod>.f` instead of `uvm.f`. Both derive the filelist from the `<MOD>_BLOCK_TEST` token (lower-cased module name), so a new block-level module only needs its `uvm_blk_<mod>.f`; a missing file stops with a clear error (Makefile `$(error)` / `wsim_oeda` `die`).
- Makefile gotcha: keep `$(error ...)` inside conditionals space-indented; a tab-indented one is parsed as a recipe line ("recipe commences before first target").
- Generator vs generated files: VERILATOR guards (`top_pkg`, `tb_top_*`, `dump_wave`, `vif_declare`) are defined in the `gen_uvm_env.py` templates; fix the template and sync the generated file together, otherwise a regeneration silently drops the local-flow support.
- Block tb top is `tb_top/tb_top/tb_top_<mod>.sv`; module name stays `tb_top` (`` `define TB_TOP tb_top `` in `tb_define.sv`).

---

## 4. apb_master / apb_v3_sram specifics

- **DUT:** `hdl/rtl/apb_v3_sram.v` (APB3 slave SRAM, listed in `tb_top/filelist/rtl_file_lst.f`); tb top `tb_top/tb_top/tb_top_apb_master.sv` generates clock/reset and instantiates the DUT. Instantiate with `.MEM_BLOCK_SIZE(32)` — default 8 breaks `wr_data2mem` (ignores `PADDR`). Reset must be asserted from t=0 (memory only initialised in the reset branch).
- **Cases:** `+APB_MASTER_BLOCK_TEST` in `VCS_MACRO_OPT`; the wait-state case adds `+APB_SRAM_EN_WAIT` (DUT `EN_WAIT_DELAY_FUNC=1`). Run e.g. `./wsim_oeda -c apb_master_rw_rand_block_test -seed 1 -covrpt`.
- **DUT quirks that shaped the UVC:** early PREADY in SETUP; one-phase lag after each transfer (driver inserts ≥1 idle cycle); `wait_cyc_limit` randomised once at t=0; out-of-range reads keep stale PRDATA with PSLVERR=1. Driver/monitor sample on **negedge** (DUT uses blocking assigns on posedge).
- **Sequence helpers** live in `seq/apb_master_block_base_seq.sv` (`apb_write`/`apb_read`/`apb_idle`); every helper must `get_response` because the driver does `item_done(rsp)`.
- The apb_master DUT has no registers: `enable_ral: false`, `adapter_type: ""` (the former stub adapter was deleted). Full findings and results: `docs/apb_v3_sram_verify_report.md`.

---

## 5. Two-flow closed loop: oEDA first, VCS sign-off (rules since 2026-11-11)

Naming: the open-source flow is **oEDA** (script `wsim_oeda`, scratch `sim/uvm_scratch_oeda_<case>/`, isolation define `+define+OPEN_EDA`); the business flow is VCS (`wsim`, `sim/uvm_scratch_<case>/`). Old `_local` artifacts on disk are historical and are not renamed.

**Loop:** develop/debug a case with `./wsim_oeda -c <case> [-seed 1]` (fast iteration, FST waves) -> once stable, confirm the same case on VCS with `./wsim -c <case> -uvm` -> converge with VCS regression groups (`-smoke/-stage1/-stage2/-full`) and coverage (`-cm`, functional covergroups via `-fm`).

**Sign-off rule: an oEDA PASS is necessary but never sufficient.** Convergence is signed off on VCS only. Equivalence between flows is judged by pass/fail plus coverage, never by cycle-accurate waveform comparison (randomization seed streams differ between simulators).

**Capability gaps of oEDA - re-check each at convergence time:**
1. Functional covergroups are NOT collected by Verilator - VCS `-fm`/`-cm` only.
2. SVA concurrent assertions are not supported - none exist today; if added later they are VCS-only (deferred item, see section 6).
3. Constraint solver: keep constraints simple enough for Verilator (repo convention); complex-constraint tests must pass on VCS.
4. Width macros are **derived from the register table** (since 2026-11-12): RalGen (`gen_reg_model.py`) parses the CSV (field `BitEnd+1`, `Label REG_<n>`, byte span `(EndAddr-OffsetAddr+1)*8` - max of all three per register) and writes `verify/ral/ral_reg_width`; `testjson2lst.py` injects `max(64, derived)` into BOTH flows, and `wsim_oeda` no longer filters them. The old `chip_define.sv` + CORE_NUM parsing is gone (that file also no longer exists). Residual check when the real register table lands: confirm the derived value covers the real design's widest register - sliced registers depend on the Label/EndAddr columns being populated per slice; if they are not, the derivation undercounts and the number must be revisited.
5. Gate/post-layout (`-l gate|post`) and DPO flows are VCS-only.

**Local batch loop (no dedicated tool):** `wsim_oeda` keeps `comp_<case>/obj_dir` across runs and skips verilator when the build key (verilator version + defines + uvm_oeda.f hash + wave/cov flags) is unchanged, so a plain shell loop is enough for a local pre-regression: `for c in apb_master_smoke_block_test apb_master_wait_block_test; do ./wsim_oeda -c "$c" -seed 1 -nowave; done` - only the first case pays the full compile; per-run artifacts (run_iter*, result.txt) are cleared each run.

## 7. System-level bring-up checklist (blocked on SoC RTL; do not start early)

1. SoC RTL lands in `hdl/` and is listed in `tb_top/filelist/rtl_file_lst.f` (system top `tb_top_soc.sv` already has clk/rst from the template; DUT/stub instantiation is hand work, not generatable).
2. Real `hdl/common/reg_table/reg_table_reg_list.csv` replaces the placeholder -> triggers RalGen real model AND the derived-width validation (section 5 item 4: check `verify/ral/ral_reg_width` covers the real widest register, especially sliced registers).
3. `tb_top/config/Makefile.initreg.cfg` is referenced by the VCS Makefile but does not exist - create it when register init is first needed.
4. DUT-to-UVC wiring in `intf/<mod>_if_conn.sv` skeletons (hand work per DUT).
5. System smoke stimuli: the `reg/uart/efuse_smoke_test` classes exist but are inert; fill bodies (add-test-case skill covers scaffolding).
6. Replace the fake tokens (`+DEFINE1...`) still present in reg/ro/uart/efuse case JSONs when real system cases are added.

## 6. Deferred items

- SVA protocol assertions (VCS-only, `*_if_pc.sv`-style): intentionally not implemented (2026-11-11). Revisit when protocol sign-off needs concurrent assertions.
- Width-macro alignment: see item 4 in section 5.
- Full compile cache (native-FS scratch, hash-keyed obj_dir): superseded by obj_dir reuse for as long as the primary environment is server Linux; revisit only if the WSL box becomes the primary debug environment again.

- Stale system-level path: `top_env.sv` sets `ral.set_hdl_path_root("tb_top.C[0].btnode.btc")` - a pre-apb_master chip hierarchy. Harmless while the placeholder RAL is unused, but it MUST be updated to the real hierarchy before any backdoor register access in the revived system flow.
- Makefile gotcha: when a Python/shell patch writes a trailing backslash (line continuation) avoid `\"`-style escapes in heredocs; a mis-escaped backslash leaves a dangling quote and `bash -n` reports "unexpected EOF while looking for matching `"'"".

# arch_memory

Architecture state, standing rules and lessons for developing this verify tree. Project-wide and tool-independent: read before structural changes, append when a new rule or lesson is learned (one entry = rule, why, how to apply). Stable "what/how" guidance lives in `verify/CLAUDE.md`; this file holds what changes with the project. Last updated 2026-11-23 (reg-table location is the project-level `WSIM_REG_TABLE` in `verify/script/sflow/flow_env.sh`; §0/§7.2 repointed; §6 parameterization item resolved). Earlier: 2026-11-20 (reg-table dependency gated by enable_ral: spec2json intake REG TABLE CONFIRMATION gate, CLAUDE.md canon; placeholder CSV + derived RAL artifacts REMOVED; §6 registers the path-parameterization follow-up). Previous: 2026-11-19 (dedup pass: R5/§3/§0/§8 slims to CLAUDE.md canon; framework-change history migrated to `docs/memory/fw_env_memory.md`; R6 amended — framework changes are logged there, this chain records only rule/doc changes). Older: 2026-11-18 (R6 doc governance: header TOC, canonical homes, §2→`docs/ops/oeda_local_setup.md`+CLAUDE.md, §4→`docs/modules/apb_master.md`; dual-track property policy). Oldest: 2026-11-17 (multi-agent flow deployed, §8; §6 SVA deferral lifted). Oldest: 2026-11-11 (enable_ral; oEDA rename + OPEN_EDA define; closed loop 5/6; R5 regen rule + section 7 system checklist — framework details migrated to fw_env_memory).

**TOC** (section numbers are frozen per R6 — never renumber, only append; physical order preserved; logical reading order below): §0 module/architecture state → §1 maintenance rules R1–R6 → §5 two-flow closed loop → §3 block-level conventions → §7 system bring-up checklist (blocked) → §6 deferred items → §8 multi-agent deployment (2026-11-17/18) → §2 *(moved 2026-11-18: machine setup → `docs/ops/oeda_local_setup.md`; Verilator rules → CLAUDE.md oEDA/OPEN_EDA)* → §4 *(moved 2026-11-18: apb_master details → `docs/modules/apb_master.md`)*.

---

## 0. Current architecture state

| Module | UVC state (adapter_type / enable_ral) | Block-level support | Notes |
|---|---|---|---|
| `apb_master` | **fully customised** (real if/driver/monitor/scoreboard/coverage); `enable_ral: false`, no adapter | yes (`uvm_blk_apb_master.f`, `+APB_MASTER_BLOCK_TEST`) | UVC for DUT `hdl/rtl/apb_v3_sram.v`; replaced the former `jls` module; worked reference for new UVCs |
| `efuse` | generated template | yes (`uvm_blk_efuse.f`, `+EFUSE_BLOCK_TEST`) | block base pair has RAL wiring, never exercised |
| `reg`, `ro`, `uart` | generated template | no | no block filelist / base pair |

- Module source of truth: `script/uvm_env_config_template.json` and `json/module.json`. Config-knob semantics and the generator-enforced rules are canonized in `verify/CLAUDE.md` ("Regenerating the environment"). RalGen gating (`wsim_oeda`: runs only when the selected filelist references `ral_reg_model`; `wsim`: skips with a warning when the `$WSIM_REG_TABLE` CSV is absent) is canonized in CLAUDE.md. Caveat: the VCS Makefile `init_reg_cfg` (+vcs+initreg+...) is NOT gated - backdoor register init depends on the chip model, handle manually if top-level enable_ral is ever set false.
- System-level flow (`tb_top_soc.sv` + `uvm.f`) has no DUT (old `hdl/rtl/soc_stub.sv` removed); not runnable locally until the SoC RTL lands. No reg-table CSV is checked in (placeholder removed 2026-11-20); its location is the project-level `WSIM_REG_TABLE` (see CLAUDE.md), and the real CSV is provided when a config enables `enable_ral` (spec2json intake gate). The root-level `hdl/` design database currently holds only `apb_v3_sram.v`.
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
- **Rule:** canon is `verify/CLAUDE.md` "Regenerating the environment" (module-private files skip-if-exists; assembly files are template-pure and rewritten on every regen — never hand-edit, lift changes into `gen_uvm_env.py` templates). The enforcement subset is inlined in the json2env_agent charter.
- **History (framework lifts):** logged in `docs/memory/fw_env_memory.md` (OPEN_EDA guards, TB_TOP=tb_top, clk/rst in both tb_top templates, etc.).

### R4. Edit `script/`, then deploy
- `script/` is the source of truth; `sim/wsim*`, `tb_top/scripts/` and `utils/` are deployed copies. After editing `script/sflow/*`, re-run `script/file_manage.sh` (or edit and copy both when the deploy step is unavailable).

### R6. Documentation governance: canonical homes, summary+link, frozen anchors (2026-11-18)
- **Rule:** every fact class has ONE canonical home; other docs keep a short summary plus a pointer, never a full restatement. Canonical map: Verilator/OPEN_EDA coding rules & oEDA usage/pass criterion & regeneration/config-knob rules → `verify/CLAUDE.md`; two-flow sign-off & coverage split → §5 here; multi-agent process/metrics/doc map → `docs/ops/multi_agent_ops.md`; per-module DUT knowledge → `docs/modules/<mod>.md` (cross-agent reference truth); machine setup → `docs/ops/oeda_local_setup.md` (operational, not project knowledge); framework-change history (env/template/generator changes) → `docs/memory/fw_env_memory.md` — the Last-updated chain of this file records only rule/doc changes.
- **Promotion:** per-agent logs (`fw_env_memory`, `dev/`, `debug/`, `deliver/`, taskboard) record *what happened*; a stable fact distilled from a log is **promoted** into `docs/modules/<mod>.md` and the log entry marked "promoted" — never copy canon into logs.
- **Anchors:** section numbers in this file are frozen once referenced elsewhere — never renumber, only append (the §6/§7 historical order is kept on purpose; the header TOC gives the logical view). When a policy changes: edit the canonical home first, then sync the summaries.
- **Why:** the dual-track property policy (2026-11-17/18) required 7–8 synchronized edits; §-number references already drifted once (§7/§6 ordering).
- **Check:** before editing a rule, find its canonical home via the doc map (ops §4); grep the old wording afterwards to catch missed summaries.

---

## 2. (moved 2026-11-18, per R6)

Machine/dev-box setup and Windows invocation pitfalls → `docs/ops/oeda_local_setup.md`; Verilator coding rules, oEDA pass criterion and coverage reading → canonical in `verify/CLAUDE.md` (oEDA / OPEN_EDA sections). Kept as an anchor stub because several docs referenced "arch §2".

---

## 3. Block-level flow conventions

- Selection mechanics are canonized in `verify/CLAUDE.md` (oEDA "Block-level flow"). Unique bits: both flow scripts derive the filelist from the `<MOD>_BLOCK_TEST` token (lower-cased module name), so a new block-level module only needs its `uvm_blk_<mod>.f`; a missing file stops with a clear error (Makefile `$(error)` / `wsim_oeda` `die`).
- Makefile gotcha: keep `$(error ...)` inside conditionals space-indented; a tab-indented one is parsed as a recipe line ("recipe commences before first target").
- Generator vs generated files: VERILATOR guards (`top_pkg`, `tb_top_*`, `dump_wave`, `vif_declare`) are defined in the `gen_uvm_env.py` templates; fix the template and sync the generated file together, otherwise a regeneration silently drops the local-flow support.
- Block tb top is `tb_top/tb_top/tb_top_<mod>.sv`; module name stays `tb_top` (`` `define TB_TOP tb_top `` in `tb_define.sv`).

---

## 4. (moved 2026-11-18, per R6)

apb_master / apb_v3_sram DUT details, quirks, case macros and config rationale → `docs/modules/apb_master.md` (cross-agent per-module canon). Kept as an anchor stub; per-module UVC/adapter/block support state stays in §0.

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
2. The real register-table CSV is provided at the `WSIM_REG_TABLE` location (`verify/script/sflow/flow_env.sh`; or repoint the variable — location confirmed via the spec2json intake gate; placing a file under `hdl/` is the user's action) -> triggers RalGen real model AND the derived-width validation (section 5 item 4: check `verify/ral/ral_reg_width` covers the real widest register, especially sliced registers).
3. `tb_top/config/Makefile.initreg.cfg` is referenced by the VCS Makefile but does not exist - create it when register init is first needed.
4. DUT-to-UVC wiring in `intf/<mod>_if_conn.sv` skeletons (hand work per DUT).
5. System smoke stimuli: the `reg/uart/efuse_smoke_test` classes exist but are inert; fill bodies (add-test-case skill covers scaffolding).
6. Replace the fake tokens (`+DEFINE1...`) still present in reg/ro/uart/efuse case JSONs when real system cases are added.

## 6. Deferred items

- ~~Reg-table path parameterization~~ **resolved 2026-11-23**: the location is the project-level `WSIM_REG_TABLE` in `verify/script/sflow/flow_env.sh` (mechanism: CLAUDE.md RAL bullet; change log: fw_env_memory).

- SVA protocol assertions: the 2026-11-11 deferral was lifted (2026-11-17/18) — property checks are **dual-tracked**; the mechanism canon is `verify/CLAUDE.md` (OPEN_EDA differences paragraph), summaries in ops §3 and §8. Status note kept here because this section tracks deferred items: Verilator must never see SVA outside the guard.
- Width-macro alignment: see item 4 in section 5.
- Full compile cache (native-FS scratch, hash-keyed obj_dir): superseded by obj_dir reuse for as long as the primary environment is server Linux; revisit only if the WSL box becomes the primary debug environment again.

- Stale system-level path: `top_env.sv` sets `ral.set_hdl_path_root("tb_top.C[0].btnode.btc")` - a pre-apb_master chip hierarchy. Harmless while the placeholder RAL is unused, but it MUST be updated to the real hierarchy before any backdoor register access in the revived system flow.
- Makefile gotcha: when a Python/shell patch writes a trailing backslash (line continuation) avoid `\"`-style escapes in heredocs; a mis-escaped backslash leaves a dangling quote and `bash -n` reports "unexpected EOF while looking for matching `"'"".

## 8. Multi-agent verification flow (deployed 2026-11-17)

Roles defined in `.claude/agents/` (spec2json = opus; json2env/dev/debug/deliver/review = sonnet); **the main session is the leader** — runbook `docs/ops/multi_agent_ops.md` (the original spec `docs/multi_agent_flow.txt` was absorbed into the agents/runbook and removed on 2026-11-18). User decisions baked into the deployment:

- **Tiered confirmation**: sub-agents edit module-private/rollbackable files directly; source-of-truth files need a user-approved change plan; commits are leader-only with `COMMIT_APPROVED=1` after user approval — full rules: ops §1.
- **Writable roots** `verify/` + `deliver_bridge/` + `sim/`, enforced by the `path_guard` hook (`.claude/hooks/path_guard.py`, wired in `.claude/settings.json` PreToolUse; Bash/PowerShell path writes stay advisory — only the `git commit` rule is hard there).
- **VCS-first**: the VCS flow is the next setup item and will be deployed on Linux by the user; simulations run server-side (no local parallel cap). oEDA stays the local fast-iteration flow; passrate ≥ 80% (pass = exit 0 + no UVM_ERROR/FATAL) gates the VCS stage; VCS results are returned by the user into `sim/vcs_results/<date>/` for debug_agent analysis + conv-report.
- **Coverage split (decided 2026-11-17/18)**: property checks dual-tracked, function covergroups VCS-only — canon: `verify/CLAUDE.md` OPEN_EDA paragraph; summaries: ops §3, §6 above.
- **Memories/taskboard**: `docs/memory/fw_env_memory.md` (json2env), `docs/modules/<mod>.md` (cross-agent per-module canon, R6 promotion; first instance apb_master), `docs/memory/dev|debug|deliver/<mod>.md` (per-agent logs, from `_template.md`), `docs/memory/leader_taskboard.md` (leader), features in `docs/features/<mod>/`, reviews in `docs/review/`; `deliver_bridge/` recreated with a README (interface conventions).

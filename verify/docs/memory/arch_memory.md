# arch_memory

Architecture state, standing rules and lessons for developing this verify tree. Project-wide and tool-independent: read before structural changes, append when a new rule or lesson is learned (one entry = rule, why, how to apply). Stable "what/how" guidance lives in `verify/CLAUDE.md` and the path-scoped `.claude/rules/`; this file holds what changes with the project. Last updated 2026-11-26. Change history: `git log -- docs/memory/arch_memory.md` (framework changes: `docs/memory/fw_env_memory.md`).

**TOC** (section numbers are frozen per R6 — never renumber, only append; physical order preserved; logical reading order below): §0 module/architecture state → §1 maintenance rules R1–R7 → §5 two-flow closed loop → §3 block-level conventions → §7 system bring-up checklist → §6 deferred items → §8 multi-agent deployment → §9 open development gaps. §2 and §4 are retired and their numbers are not reused (content moved: machine setup → `docs/ops/oeda_local_setup.md`; Verilator rules → `.claude/rules/oeda-verilator.md`).

---

## 0. Current architecture state

This repository is the **framework**: `script/uvm_env_config_template.json` lists no modules, and nothing generated (`uvc/ env/ test/ seq/ intf/ json/ tb_top/ utils/`, `sim/`) or chip-specific (`hdl/`, `docs/modules/`, module logs and feature lists) is committed. A chip project gets its modules through `/new-verification` (spec2json → json2env) after `bootstrap.sh` and `/new-project`; there this section holds the chip's module table.

- **Local test fixture** (framework development only, never committed): a five-module environment kept on disk and excluded through `.git/info/exclude` (pattern list there) - `apb_master` (fully customised UVC, DUT `hdl/rtl/apb_v3_sram.v`, `enable_ral: false`, block level), `efuse` (template, block level, RAL), `reg`/`ro`/`uart` (templates). Config: `verify/local/uvm_env_config.json`. Regenerate from `script/` with `python gen_uvm_env.py -c ../local/uvm_env_config.json --guvc`, deploy with `file_manage.sh`; the framework smoke is `./wsim_oeda -c apb_master_smoke_block_test -seed 1` (block cases of RAL modules also need a register-table CSV). A fresh clone has no fixture: restore it from tag `soc-pid003-snapshot` (`git checkout soc-pid003-snapshot -- verify/uvc verify/env verify/test verify/seq verify/intf verify/json verify/tb_top hdl`, then `git reset -q` on the same paths so they stay untracked; the old config is `git show soc-pid003-snapshot:verify/script/uvm_env_config_template.json`, with `project_name` set to the framework's), then regenerate.
- Module source of truth (in a project): `script/uvm_env_config_template.json` and `json/module.json`. Config-knob semantics and the generator-enforced rules are canonized in `verify/CLAUDE.md` ("Regenerating the environment"). RalGen gating is canonized in `.claude/rules/ral.md`. Caveat: the VCS Makefile `init_reg_cfg` (+vcs+initreg+...) is NOT gated - backdoor register init depends on the chip model, handle manually if top-level enable_ral is ever set false.

---

## 1. Maintenance rules (keep documents and skills in sync)

### R1. Instruction files stay module-agnostic
- **Rule:** no instruction file (CLAUDE.md, `.claude/rules/`, `.claude/agents/`, the add-test-case skill and its manual) names the chip's modules - examples use `<mod>` / `<case>`. The add-test-case script reads the valid modules from `json/module.json` and detects block-level support from the block base files, so adding or removing a module needs no instruction-file edit.
- **Why:** a module rename once left the skill's hard-coded module list stale (the script rejected the new module), and a bootstrapped chip inherited the previous chip's module names in every instruction file.
- **Check:** `python .claude/skills/add-test-case/add_test_case.py --module <new> ...` is accepted right after `--guvc`; `grep` for the module names over the instruction files finds nothing.

### R2. Adding or removing a module → update the state documents
- **Rule:** in the same change, update the module table in §0, the open-gap list in §9 and `docs/modules/<mod>.md` (create it for a new module when DUT facts exist; remove it with the module).
- **Why:** these hold the per-module state every agent reads first; stale rows mislead tooling and people.
- **Automatic reminder:** the `arch_memory_check.sh` hook (triggers and state: ops §6) injects a once-per-state reminder when the module-defining files change; nothing is edited until the user confirms.
- **Check:** re-verify §9 whenever RAL, adapters, block-level flow or JSON placeholders change.

### R3. Prefer the skill over hand-writing leaf test cases
- New leaf tests/seqs/JSON entries are scaffolded with the add-test-case skill, then the `body()` TODO is filled in - canon CLAUDE.md "Test cases"; usage, naming (`--function <fp>_block` style) and `--macro-opt` behaviour live in the skill and its manual; per-module naming conventions in `docs/modules/<mod>.md`. dev_agent enforces this (charter).

### R5. Regeneration is safe only through the template-pure assembly rule
- **Rule:** canon is `verify/CLAUDE.md` "Regenerating the environment" (module-private files skip-if-exists; assembly files are template-pure and rewritten on every regen — never hand-edit, lift changes into `gen_uvm_env.py` templates). The enforcement subset is inlined in the json2env_agent charter.
- **History (framework lifts):** logged in `docs/memory/fw_env_memory.md` (OPEN_EDA guards, TB_TOP=tb_top, clk/rst in both tb_top templates, etc.).

### R4. Edit `script/`, then deploy
- Canon: CLAUDE.md Conventions + `.claude/rules/flow-scripts.md`. `script/` is the source of truth; the deployed copies (`sim/wsim*`, `tb_top/scripts/`, `utils/`) are refreshed only by rerunning `script/file_manage.sh`.

### R6. Documentation governance: canonical homes, summary+link, frozen anchors
- **Rule:** every fact class has ONE canonical home; other docs keep a short summary plus a pointer, never a full restatement. The canonical map - the home of every fact class - is the doc map in `docs/ops/multi_agent_ops.md` §4; keep it there, not a second list here. Rule/doc change history is the git log (this file keeps only a Last-updated date).
- **Promotion:** per-agent logs (`fw_env_memory`, `dev/`, `debug/`, `deliver/`, taskboard) record *what happened*; a stable fact distilled from a log is **promoted** into `docs/modules/<mod>.md` and the log entry marked "promoted" — never copy canon into logs.
- **Anchors:** section numbers in this file are frozen once referenced elsewhere — never renumber, only append (the §6/§7 historical order is kept on purpose; the header TOC gives the logical view). When a policy changes: edit the canonical home first, then sync the summaries.
- **Why:** the dual-track property policy once required 7–8 synchronized edits; §-number references already drifted once (§7/§6 ordering).
- **Check:** before editing a rule, find its canonical home via the doc map (ops §4); grep the old wording afterwards to catch missed summaries.


### R7. New project values are registered in `script/new_project/vars.json`
- **Rule:** any new value a project must define (a `flow_env.sh` setting, a top-level config knob, a filelist the user fills, an identity token in docs) is added to `vars.json` in the same change, with its `stage` (project → `/new-project`, verification → `/new-verification`), target, prompt, validation and deferrability; files a new chip must carry or reset go into `manifest.txt`.
- **Why:** `/new-project` interviews exactly what the registry lists - an unregistered value is silently skipped and the new project inherits the old chip's value.
- **Check:** `python script/new_project/new_project.py audit` before committing any framework change (every tracked file classified in `manifest.txt`, no module names in carried text, every carried `.md` in the ops §4 doc map, every `flow_env.sh` variable / config key registered, every occurrence of a registered value inside its rewrite files; bootstrap refuses to run while it fails). For bigger changes also bootstrap into a scratch dir under `sim/`, `new_project.py set/apply/check`, `--guvc` one module, one oEDA smoke.

---

## 3. Block-level flow conventions

- Selection mechanics are canonized in `verify/CLAUDE.md` (oEDA "Block-level flow"). Unique bits: both flow scripts derive the filelist from the `<MOD>_BLOCK_TEST` token (lower-cased module name), so a new block-level module only needs its `uvm_blk_<mod>.f`; a missing file stops with a clear error (Makefile `$(error)` / `wsim_oeda` `die`).
- Generator vs generated files and Makefile gotchas: `.claude/rules/generated-assembly.md` and `.claude/rules/flow-scripts.md`.
- Block tb top is `tb_top/tb_top/tb_top_<mod>.sv`; module name stays `tb_top` (`` `define TB_TOP tb_top `` in `tb_define.sv`).

---

## 5. Two-flow closed loop: oEDA first, VCS sign-off

Naming: the open-source flow is **oEDA** (script `wsim_oeda`, scratch `sim/uvm_scratch_oeda_<case>/`, isolation define `+define+OPEN_EDA`); the business flow is VCS (`wsim`, one `sim/uvm_scratch_<case|mod|group>_<timestamp>_.../` per invocation; layout in CLAUDE.md Commands).

**Loop:** develop/debug a case with `./wsim_oeda -c <case> [-seed 1]` (fast iteration, FST waves) -> once stable, confirm the same case on VCS with `./wsim -c <case> -uvm` -> converge with VCS regression groups (`-smoke/-stage1/-stage2/-full`) and coverage (`-cm`, functional covergroups via `-fm`). Which VCS runs the agents start on their own: ops §3 tiers.

**Sign-off rule: an oEDA PASS is necessary but never sufficient.** Convergence is signed off on VCS only. Equivalence between flows is judged by pass/fail plus coverage, never by cycle-accurate waveform comparison (randomization seed streams differ between simulators).

**Capability gaps of oEDA - re-check each at convergence time:** the limits canonized in CLAUDE.md (oEDA "Limits": functional covergroups collected on VCS only, simple constraints only, no SVA - dual-track per `.claude/rules/oeda-verilator.md`, no gate/post or DPO), plus the width-macro derivation below.

**Width macros are derived from the register table**: RalGen (`gen_reg_model.py`) parses the CSV (field `BitEnd+1`, `Label REG_<n>`, byte span `(EndAddr-OffsetAddr+1)*8` - max of all three per register) and writes `verify/ral/ral_reg_width`; `testjson2lst.py` injects `max(64, derived)` into BOTH flows. Residual check when the real register table lands: confirm the derived value covers the real design's widest register - sliced registers depend on the Label/EndAddr columns being populated per slice; if they are not, the derivation undercounts and the number must be revisited.

**Local regression:** `./wsim_oeda -m <mod>` (or a regression group) selects cases exactly like `wsim` and gives the module's oEDA pass rate in `sim/oeda_result.txt` - case selection, shared builds, the build key and parallelism are canonized in CLAUDE.md (oEDA section) and `docs/ops/oeda_local_setup.md`.

## 7. System-level bring-up checklist (once the chip RTL lands; do not start early)

1. The chip RTL lands under the design root and is listed in `tb_top/filelist/rtl_file_lst.f` through the `/new-verification` design-input step (ops §8 stage 2b) (the generated system top `tb_top_<project>.sv` has clk/rst from the template; DUT instantiation is hand work, not generatable).
2. The real register-table CSV is provided at the `WSIM_REG_TABLE` location (`verify/script/sflow/flow_env.sh`; the location is asked in the `/new-verification` register-table step and written through `new_project.py set/apply`; placing the file is the user's action) -> triggers RalGen real model AND the derived-width validation (the width item in section 5: check `verify/ral/ral_reg_width` covers the real widest register, especially sliced registers).
3. `tb_top/config/Makefile.initreg.cfg` is referenced by the VCS Makefile but is not generated - create it when register init is first needed.
4. Chip DUT instance in `tb_top_<project>.sv`, its wiring to the UVC interfaces in `intf/<mod>_if_conn.sv` / `top_if_conn.sv` (included through `tb_top/component/if_conn.sv`; same `dut_*` net convention as the block level, `.claude/rules/uvm-architecture.md` "Interface connection") - hand work per DUT.
5. System smoke stimuli: the generated `<mod>_smoke_test` classes are inert; fill their bodies (add-test-case skill covers scaffolding).
6. Replace the fake tokens (`+DEFINE1...`) of the generated case JSONs when real system cases are added.

## 6. Deferred items

- SVA protocol assertions: the deferral was lifted — property checks are **dual-tracked**; the mechanism canon is `.claude/rules/oeda-verilator.md`, summary in ops §3. Status note kept here because this section tracks deferred items: Verilator must never see SVA outside the guard.
- Width-macro alignment: see the width item in section 5.
- Placeholder system-level path: the `gen_uvm_env.py` top_env template sets `ral.set_hdl_path_root("tb_top.C[0].btnode.btc")` - not the chip's hierarchy. Harmless while no system-level RAL model exists, but it MUST be updated to the real hierarchy before any backdoor register access in the revived system flow.

## 8. Multi-agent verification flow

Roles and models live in `.claude/agents/` and ops §0; **the main session is the leader**. The process canon — tiered confirmation, writable roots and hook guardrails, VCS-first scheduling, passrate gate, coverage split, memory/taskboard map — is `docs/ops/multi_agent_ops.md` (§1–§4, §6). The original spec `docs/multi_agent_flow.txt` was absorbed into the charters/runbook and removed.

## 9. Open development gaps

Confirmed gaps of the generated environment that a developer hits when writing tests. Former `test_case_dev_manual.md` §7 table (section removed from the manual); IDs keep the old row numbers for traceability. **Lifecycle:** when a gap closes, delete its row here, log the fix in `docs/memory/fw_env_memory.md` (state lives here, history there), and, for G3, remove the RAL-macro-naming caveat in `test_case_dev_manual.md` §3.4 (the manual describes the generated skeleton generically; the other gaps have no caveat there). Placeholder JSON tokens are tracked in §7 item 6.

| ID | Gap | Where | Done looks like |
|---|---|---|---|
| G3 | `reg_<name>` handle-naming assumption unconfirmed | `utils/reg/uvm_reg_macros.sv:15-25` assumes handles named `reg_<regname>`; nothing has used the macros yet | One real register access confirms the names (or generator/macros adjusted) |
| G4 | Generated adapters are unvalidated stubs | every `reg2<bus>` adapter does a bare `we`/`addr`/`data` copy ("Please complete the conversion logic of the bus...") | The adapter written/validated against the real protocol semantics |
| G5 | `comm_<mod>_methods.sv` is generated empty | placeholder comments only | Populated as real tests are written |
| G6 | Generated `UVM_TESTNAME`s mostly have no leaf class | the `<mod>_smoke_test` / `<mod>_smoke_block_test` classes are inert; `<mod>_random_test` etc. have no class | Leaf classes written (add-test-case skill), JSON updated |
| G8 | Generated block-base RAL wiring never exercised | `<mod>_block_base_test/_seq` wire `ral`/adapter/sequencer, but no `ral.<reg>.write()/read()` has gone through them | One register access through this path succeeds |
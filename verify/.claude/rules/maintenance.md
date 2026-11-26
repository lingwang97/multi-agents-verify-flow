---
paths:
  - "CLAUDE.md"
  - ".claude/**"
  - "docs/**"
  - "script/**"
  - "json/**"
---

# Maintenance rules (R1-R7)

Framework maintenance policy, moved from `docs/memory/arch_memory.md` §1 (the section number is retired there). Project state - module table, deferred items, bring-up checklist, open gaps - stays in `docs/memory/arch_memory.md`; these rules govern how documents, generators and the project registry are kept in sync. They load when a CLAUDE.md, `.claude/`, `docs/`, `script/` or `json/` file is opened, i.e. exactly when source-of-truth files or documentation are being changed.

### R1. Instruction files stay module-agnostic
- **Rule:** no instruction file (CLAUDE.md, `.claude/rules/`, `.claude/agents/`, the add-test-case skill and its manual) names the chip's modules - examples use `<mod>` / `<case>`. The add-test-case script reads the valid modules from `json/module.json` and detects block-level support from the block base files, so adding or removing a module needs no instruction-file edit.
- **Why:** a module rename once left the skill's hard-coded module list stale (the script rejected the new module), and a bootstrapped chip inherited the previous chip's module names in every instruction file.
- **Check:** `python .claude/skills/add-test-case/add_test_case.py --module <new> ...` is accepted right after `--guvc`; `grep` for the module names over the instruction files finds nothing.

### R2. Adding or removing a module → update the state documents
- **Rule:** in the same change, update the module table in arch_memory §0, the open-gap list in §2 and `docs/modules/<mod>.md` (create it for a new module when DUT facts exist; remove it with the module).
- **Why:** these hold the per-module state every agent reads first; stale rows mislead tooling and people.
- **Automatic reminder:** the `arch_memory_check.sh` hook (triggers and state: ops §6) injects a once-per-state reminder when the module-defining files change; nothing is edited until the user confirms.
- **Check:** re-verify arch §2 whenever RAL, adapters, block-level flow or JSON placeholders change.

### R3. Prefer the skill over hand-writing leaf test cases
- New leaf tests/seqs/JSON entries are scaffolded with the add-test-case skill, then the `body()` TODO is filled in - canon CLAUDE.md "Test cases"; usage, naming (`--function <fp>_block` style) and `--macro-opt` behaviour live in the skill and its manual; per-module naming conventions in `docs/modules/<mod>.md`. dev_agent enforces this (charter).

### R4. Edit `script/`, then deploy
- Canon: CLAUDE.md Conventions + `.claude/rules/flow-scripts.md`. `script/` is the source of truth; the deployed copies (`sim/wsim*`, `tb_top/scripts/`, `utils/`) are refreshed only by rerunning `script/file_manage.sh`.

### R5. Regeneration is safe only through the template-pure assembly rule
- **Rule:** canon is `verify/CLAUDE.md` "Regenerating the environment" (module-private files skip-if-exists; assembly files are template-pure and rewritten on every regen — never hand-edit, lift changes into `gen_uvm_env.py` templates). The enforcement subset is inlined in the json2env_agent charter.
- **History (framework lifts):** logged in `docs/memory/fw_env_memory.md` (OPEN_EDA guards, TB_TOP=tb_top, clk/rst in both tb_top templates, etc.).

### R6. Documentation governance: canonical homes, summary+link, frozen anchors
- **Rule:** every fact class has ONE canonical home; other docs keep a short summary plus a pointer, never a full restatement. The canonical map - the home of every fact class - is the doc map in `docs/ops/multi_agent_ops.md` §4; keep it there, not a second list here. Rule/doc change history is the git log (arch_memory keeps only a Last-updated date).
- **Promotion:** per-agent logs (`fw_env_memory`, `dev/`, `debug/`, `deliver/`, taskboard) record *what happened*; a stable fact distilled from a log is **promoted** into `docs/modules/<mod>.md` and the log entry marked "promoted" — never copy canon into logs.
- **Anchors:** arch_memory holds only project state and is renumbered on cleanup (2026-11-26, user decision - the old freeze was lifted); renumbering requires a grep-guided citation sweep over all `arch §N` references. When a policy changes: edit the canonical home first, then sync the summaries.
- **Why:** the dual-track property policy once required 7–8 synchronized edits; §-number references already drifted once (§7/§6 ordering).
- **Check:** before editing a rule, find its canonical home via the doc map (ops §4); grep the old wording afterwards to catch missed summaries.

### R7. New project values are registered in `script/new_project/vars.json`
- **Rule:** any new value a project must define (a `flow_env.sh` setting, a top-level config knob, a filelist the user fills, an identity token in docs) is added to `vars.json` in the same change, with its `stage` (project → `/new-project`, verification → `/new-verification`), target, prompt, validation and deferrability; files a new chip must carry or reset go into `manifest.txt`.
- **Why:** `/new-project` interviews exactly what the registry lists - an unregistered value is silently skipped and the new project inherits the old chip's value.
- **Check:** `python script/new_project/new_project.py audit` before committing any framework change (every tracked file classified in `manifest.txt`, no module names in carried text, every carried `.md` in the ops §4 doc map, every `flow_env.sh` variable / config key registered, every occurrence of a registered value inside its rewrite files; bootstrap refuses to run while it fails). For bigger changes also bootstrap into a scratch dir under `sim/`, `new_project.py set/apply/check`, `--guvc` one module, one oEDA smoke.

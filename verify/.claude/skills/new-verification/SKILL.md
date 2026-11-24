---
name: new-verification
description: Intake procedure for a brand-new verification requirement. The leader checks the project setup, asks for the verification inputs (specification / RTL location), proposes the standard pipeline (spec2json → json2env → design inputs → dev/debug → review → deliver) with per-stage scope and skip hints, then drives the interactive steps - config and register-table confirmation, and the design-input step that scans the design sources and proposes the file lists for the user to confirm. Use when a new module/feature-set/level verification effort starts, or when the user invokes /new-verification.
argument-hint: "<requirement>"
---

Run the new-requirement intake procedure canonized in `docs/ops/multi_agent_ops.md` §8 for the requirement below. Summary (the ops section is the reference; `NP` = `python script/new_project/new_project.py`, run from `verify/`):

1. **Trigger test + light state check** - new effort vs continuation; arch §0, taskboard, `docs/features/<mod>/`.
2. **Project check** - in a bootstrapped repo, `NP status --stage project`; pending project values → offer `/new-project` first.
3. **Verification inputs (interactive)** - `NP detect --stage verification`; ask `spec_dir` (doc mode, or `none` = pre-research) and `rtl_dir` with the detected candidates + "defer"; `NP set`. The mode decides the RTL-access rule (ops §1).
4. **Plan table + decision** - seven stages incl. 2b design inputs; AskUserQuestion adopt / skip named stages / custom; record in the taskboard.
5. **After spec2json** - AskUserQuestion on the config proposal incl. top-level `enable_ral` / `has_top_if_cfg`; if `enable_ral`, the register-table question (candidates from `NP scan`: CSVs with the RalGen columns) → `NP set reg_table=…`, `NP apply --stage verification`. spec2json then writes the approved config.
6. **After json2env, when modules were added or removed** - the R1/R2 sync rewrote add-test-case's SKILL.md, CLAUDE.md module mentions and arch §0: ask the user to run `/doctor prompt-audit` and `/doctor prompt-audit docs/` (user-typed); fix findings with approval. Skip when only design lists changed.
7. **Stage 2b design inputs (after json2env's `--guvc`)** - `NP scan --markdown`; per list variable show the scan suggestion, its reasons/confidence and, on a re-run, the +added/-removed diff; options accept / accept-with-edits (Other) / keep current / defer; round A `rtl_files` (design filelist `-f` vs explicit list), `include_dirs`, `rtl_define_files`, `ip_files`, `rtl_tops`; round B gate level (default defer). Summary → confirm → `NP apply --stage verification` → `NP check --stage verification --lint` (where Verilator is not on PATH, run the printed lint command where it is) → deferred items to the taskboard, an fw_env entry.

Existing gates stay in force - the pipeline never auto-executes; every value is confirmed by the user before it is written. Questions to the user are in the conversation language.

Requirement: $ARGUMENTS

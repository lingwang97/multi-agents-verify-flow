---
name: new-verification
description: Intake procedure for a brand-new verification requirement. The leader checks the project setup, asks for the verification inputs (specification / RTL location), proposes the standard pipeline (spec2json → json2env → design inputs → dev/debug → review → deliver) with per-stage scope and skip hints, then drives the interactive steps - config and register-table confirmation, and the design-input step that scans the design sources and proposes the file lists for the user to confirm. Use when a new module/feature-set/level verification effort starts, or when the user invokes /new-verification.
argument-hint: "<requirement>"
---

# New-requirement intake (leader)

The leader runs this procedure on every brand-new verification request, for the requirement at the end. This skill is the canon of the intake; roles, tiers and gates are in `docs/ops/multi_agent_ops.md`.

`NP` = `python script/new_project/new_project.py`, run from `verify/`. Every value the procedure needs is a registry variable of stage `verification` (`script/new_project/vars.json`), read with `NP detect|scan`, recorded with `NP set` and written with `NP apply --stage verification` only after the user confirms. Interview style everywhere: AskUserQuestion, at most 4 questions per call, options = detected/scanned candidates (with where they came from), "keep current", default, "defer"; free text through "Other". Questions to the user are in the conversation language.

## Trigger test

Run this only when the request starts a NEW verification effort (new module, new feature set, new level). A continuation request ("continue debugging <mod>") gets only a next-step proposal, never the full pipeline. Before proposing, do a light state check: arch §0 (does the module exist? block support?), taskboard (in-flight work), `docs/features/<mod>/` (existing feature lists), relevant memories.

## Step 0 - project check

In a bootstrapped repo (`script/new_project/answers.json` has `bootstrapped_from`) run `NP status --stage project`; if project values are still pending, offer `/new-project` first (run it now / continue anyway).

## Step 1 - verification inputs

`NP detect --stage verification`; ask `spec_dir` (architecture/design/plan documents, or `none` = pre-research mode on reference RTL) and `rtl_dir` (inside the design root (design root: `hdl`)); `NP set`. `spec_dir` sets the RTL-access mode (ops §1); both go into the plan table and the spec2json task.

## Step 2 - plan table and decision

Present the stages as a plan table personalized to the requirement; per stage state what it would do HERE, the inputs it uses, expected outputs, and whether it can be skipped with the reason:

| Stage | Agent | What it does here | Skip when |
|---|---|---|---|
| 1 | spec2json_agent | level partition → `docs/features/sys_function_splits.md` + config proposal | module & levels already partitioned |
| 2 | json2env_agent | env build/update (`--guvc`, deploy, smoke) | env for the target already exists (check arch §0 / fw_env_memory) |
| 2b | leader | design inputs: scan → suggested design file lists → user confirms → apply + check + lint | no RTL yet (defer all; rerun when it lands) |
| 3 | dev_agent_N | confirmed feature list + UVC/test/seq/coverage development | — (core stage) |
| 4 | debug_agent_N | oEDA debug → passrate ≥ 80% → VCS stage & convergence | — (core stage) |
| 5 | review_agent | code review, P0/P1/P2 report | optional — user decides |
| 6 | deliver_agent | status feedback to the design side | optional — user decides |

Ask via AskUserQuestion: (a) adopt the full pipeline; (b) adopt with named stages skipped; (c) custom instructions. The pipeline is an entry suggestion only - **it never bypasses existing gates** (spec2json/json2env invocation approvals, feature-list confirmation, source-of-truth approvals all still apply, per ops §1 and the charters). Write the decision and the final plan to `docs/memory/leader_taskboard.md` and update it at every stage transition.

## After stage 1 - config and register table

AskUserQuestion on spec2json's config proposal, including the top-level `enable_ral` / `has_top_if_cfg` (registry owner spec2json). If `enable_ral` is true, ask `reg_table`: candidates from `NP scan` (CSVs carrying the RalGen columns), current value, "defer"; `NP set reg_table=...` and `NP apply --stage verification` (writes `WSIM_REG_TABLE`). spec2json then writes the approved config; `NP check --stage verification` compares the top-level values.

## After stage 2 - when modules were added or removed

The R2 sync rewrote the state docs (arch §0/§2, `docs/modules/`): ask the user to run `/doctor prompt-audit docs/` (user-typed); findings are fixed with approval. Instruction files name no modules (maintenance.md R1), so they need no audit here. Not needed when only design lists changed. (`/new-project` asks for the same audit once, before this intake.)

## Stage 2b - design inputs (after json2env's `--guvc` created `tb_top/`)

`NP scan --markdown`, then per list variable present the scan suggestion with its reasons and confidence and, on a rerun, the +added/-removed diff against the current list (option previews).

- Round A: `rtl_files` (a design-side filelist referenced with `-f` vs the explicit scanned list), `include_dirs`, `rtl_define_files`, `ip_files`, `rtl_tops`.
- Round B (gate level, default "defer"): `gate_files`, `gate_ip_files`, `std_libs`, `gpls_libs`.

Summary table → confirm → `NP apply --stage verification` → `NP check --stage verification --lint` (Verilator lint of the lists; where Verilator is not on PATH, run the printed command where it is) → deferred items become taskboard rows, one fw_env entry. These lists are user-maintained skeletons - later `--guvc` runs keep them. The scan reads structure only (file, module, package, include names); it is not RTL behaviour reading, so the ops §1 RTL-access rule does not apply - in doc mode its hierarchy output feeds the file lists and the tb_top DUT wiring, not the spec analysis.

## New chip

A new chip project is first bootstrapped (`script/new_project/bootstrap.sh`, run by the user) and parameterized with `/new-project` (project stage: identity, design root, tools, server settings, language); that skill ends by asking whether to start this intake. A newer framework version is pulled into an existing project with `/new-project sync <framework-repo>`.

Requirement: $ARGUMENTS

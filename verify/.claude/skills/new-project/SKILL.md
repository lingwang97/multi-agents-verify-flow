---
name: new-project
description: Guided setup of a new chip project bootstrapped from this verification framework - interviews the user for every value the flow needs (project identity, spec/RTL/register-table inputs, tool environment, VCS/LSF server settings, filelists, agent language), writes them, and checks readiness before the verification flow starts. Use right after `script/new_project/bootstrap.sh`, or when the user invokes /new-project or asks to set up / re-parameterize a project.
argument-hint: "[phase number to revisit]"
---

# New project setup (interview → apply → check)

The leader (main session) runs this. Every value lives in the registry `script/new_project/vars.json`; every write goes through `script/new_project/new_project.py` (alias `NP` below = `python script/new_project/new_project.py`, run from `verify/`). Never edit the target files by hand during this procedure. Questions to the user are in the conversation language; files stay in the project file language.

## 0. Preconditions

- `script/new_project/answers.json` must contain `bootstrapped_from`. If it does not, this is the source project: stop and tell the user to run, by hand, `bash verify/script/new_project/bootstrap.sh <new-repo-root>` (optionally `--with apb-master`), then start Claude Code in `<new-repo-root>/verify` and rerun `/new-project`. `apply` refuses to run here anyway.
- On a Windows box with Git Bash, prefix `NP set` with `MSYS_NO_PATHCONV=1` when a value is an absolute POSIX path, otherwise Git Bash rewrites it into a Windows path.

## 1. Interview

1. Run `NP status` and `NP detect`; read the registry (`vars.json`) for each variable's prompt, choices, default and whether it may be deferred.
2. Go phase by phase (1 identity · 2 inputs · 3 machine tools · 4 VCS server · 5 filelists · 6 agent language), skipping variables already answered unless the user asked to revisit a phase (`$ARGUMENTS`).
3. Ask with AskUserQuestion, at most 4 questions per call. Options, in this order: the detected candidates (note in the description where each came from), the value currently in the target file ("keep current"), the registry default, and "defer" for deferrable variables. Free text comes through "Other". List variables (`rtl_files`, `include_dirs`, `ip_files`): show the detected list in the option preview; "none" means an empty list.
4. Phase 3 (`detect_only`) writes nothing: report what was found; for a missing tool give the export/install hint from `docs/ops/oeda_local_setup.md` and let the user choose "fix later" (it stays a WARN in the check).
5. Record each answered round right away: `NP set id=value ...` and `NP set --defer id` for deferrals (the call validates; on an error re-ask that question). Answers survive an interrupted session.
6. Site values carried from the source project (phase 4) belong to the old server - say so when offering "keep current".

## 2. Confirm and apply

1. Show one summary table: phase, variable, new value, current value, deferred items. AskUserQuestion: apply / revise a phase / stop. These targets are source-of-truth files; this confirmation is the user approval (ops §1).
2. `NP apply --dry-run`, show the planned changes, then `NP apply`. A `WARN ... snippet not found` line means a text the registry expected was edited by hand - show it and fix that spot with the user.
3. `NP check`. FAIL items must be resolved (usually: re-run apply, or a wrong path); PENDING and WARN items are reported, not blockers.

## 3. Record

- `docs/memory/leader_taskboard.md`: close the "New-project setup" row (done, date) and add one pending row per deferred variable / missing tool (trigger: when the input or tool lands).
- `docs/memory/fw_env_memory.md`: one entry "date / project parameterized by /new-project / values (summary) / pending items".
- Put the `NP check --markdown` table in the report to the user.

## 4. Next stage

Ask (AskUserQuestion) whether to start the verification intake now: yes → invoke the `new-verification` skill with the chip as the requirement (module partition by spec2json, config + register-table gate, json2env `--guvc`, R1/R2 sync); no → stop and say `/new-verification` starts it later. Do not continue without the answer.

Commit only after the user approves (leader, `COMMIT_APPROVED=1`), with `answers.json` included - it is the project's record of these values.

## Gotchas

- A new framework variable must be registered in `vars.json` in the same change that introduces it (arch_memory R7), otherwise this interview silently skips it.
- `project_name` and `pid` rewrite identity tokens in docs/rules/the path guard (`rewrites` in the registry); `apply` does it, never hand-edit those tokens.
- Module-level values (module list, per-module knobs, adapters) are not asked here - they belong to spec2json in `/new-verification`.
- `json/module.json` global macros are generator-owned (rewritten by every `--guvc`); change them in the `gen_uvm_env.py` template, not here.

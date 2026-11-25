---
name: new-project
description: Guided framework migration for a new chip project bootstrapped from this verification framework - interviews the user for the project-level values (project identity and design-database root, machine tools, VCS/LSF server settings, agent language), writes them and checks readiness. Design inputs, register table and file lists come later in /new-verification. Use right after `script/new_project/bootstrap.sh`, or when the user invokes /new-project or asks to re-parameterize the project.
argument-hint: "[phase number to revisit]"
---

# New project setup (project stage: interview → apply → check)

The leader (main session) runs this. Every value lives in the registry `script/new_project/vars.json` (stage `project`); every write goes through `script/new_project/new_project.py` (alias `NP` below = `python script/new_project/new_project.py`, run from `verify/`). Never edit the target files by hand during this procedure. Questions to the user are in the conversation language; files stay in the project file language.

## 0. Preconditions

- `script/new_project/answers.json` must contain `bootstrapped_from`. If it does not, this is the framework repo itself: stop and tell the user to run, by hand, `bash verify/script/new_project/bootstrap.sh <new-repo-root>`, then start Claude Code in `<new-repo-root>/verify` and rerun `/new-project`. `apply --stage project` refuses to run here anyway.
- On Windows with Git Bash, prefix `NP set` with `MSYS_NO_PATHCONV=1` when a value is an absolute POSIX path (Git Bash would rewrite it into a Windows path).
- The bootstrapped repo has no `tb_top/` yet - the first `--guvc` (in `/new-verification`) generates it.

## 1. Interview (phases P1-P4)

1. Run `NP status --stage project` and `NP detect --stage project`; read each variable's prompt, choices, default and deferrability in `vars.json`.
2. Go phase by phase, skipping variables already answered unless the user asked to revisit a phase (`$ARGUMENTS`):
   - **P1 identity + design root**: `project_name`, `pid`, `design_root` - the root of the design database (RTL, IP, netlists, register table), repo-root relative or absolute. The repo's `hdl/` is only a placeholder: always ask, offering the directories `detect` found (with their HDL file counts) and "Other" for a path that does not exist yet (allowed; check warns until it lands).
   - **P2 machine tools**: `uvm_home`, `verilator`, `vcs`, `verdi_home` are check-only - report what was found and, for a missing tool, the hint from `docs/ops/oeda_local_setup.md`, with "fix later" as an option. Then ask `oeda_platform`.
   - **P3 VCS server**: `wsim_python`, `lsf_enable`, `lsf_queue`, `lsf_hosts_file`, `lsf_submit_hosts`, `lsf_exec_host_regex`, `lsf_queue_sed`, `dpo_db`. Bootstrap resets this section (`WSIM_PYTHON=python3`, LSF off, the rest empty) - no old-server value survives; offer the detected candidates.
   - **P4 language**: `reply_language`, `file_language`.
3. Ask with AskUserQuestion, at most 4 questions per call. Options in this order: detected candidates (say in the description where each came from), the value currently in the target ("keep current"), the registry default, "defer" for deferrable variables; free text through "Other".
4. Record each answered round right away: `NP set id=value ...`, `NP set --defer id` for deferrals (the call validates; on an error re-ask). Answers survive an interrupted session.

## 2. Confirm and apply

1. Show one summary table: phase, variable, new value, current value, deferred items. AskUserQuestion: apply / revise a phase / stop. These targets are source-of-truth files; this confirmation is the user approval (ops §1).
2. `NP apply --stage project --dry-run`, show the planned changes, then `NP apply --stage project`. A `WARN ... snippet not found` line means an expected text was edited by hand - show it and fix that spot with the user.
3. `NP check --stage project`. FAIL items must be resolved; PENDING and WARN items are reported, not blockers. A `platform` WARN lists file:line spots still describing the other oEDA platform - fix them (usually by rewording platform-neutral) and register a snippet in `vars.json` if the text must stay platform-specific.

## 3. Record

- `docs/memory/leader_taskboard.md`: close the "New-project setup" row (done, date); add one pending row per deferred variable / missing tool (trigger: when it lands).
- `docs/memory/fw_env_memory.md`: one entry "date / project parameterized by /new-project / values (summary) / pending items".
- Put the `NP check --stage project --markdown` table in the report to the user.

## 4. Next stage

First ask the user to run `/doctor prompt-audit` (user-typed - Claude cannot invoke it): `apply` just rewrote CLAUDE.md, the charters, rules and the ops runbook, and this is the cheapest moment to catch leftovers of the old project (`check` already covers the platform phrases). Fix its findings with the user's approval.

Then ask (AskUserQuestion) whether to start the verification intake now: yes → invoke the `new-verification` skill with the chip as the requirement; no → stop and say `/new-verification` starts it later. Tell the user what comes there: specification/RTL inputs, module partition and config (spec2json), register table, `--guvc`, then the design-input step that scans the design root and proposes the file lists for confirmation. Do not continue without the answer.

Commit only after the user approves (leader, `COMMIT_APPROVED=1`), including `answers.json` - the project's record of these values.

## Gotchas

- A new framework value must be registered in `vars.json` (with its `stage`) in the same change that introduces it (arch_memory R7), otherwise no interview asks it.
- `project_name`, `pid` and `design_root` rewrite identity tokens in docs/rules/the path guard (`rewrites` in the registry); `apply` does it, never hand-edit those tokens.
- Module-level values and everything under `tb_top/` belong to `/new-verification`.

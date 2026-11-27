---
name: new-project
description: Guided framework migration for a new chip project bootstrapped from this verification framework - interviews the user for the project-level values (project identity and design-database root, machine tools, VCS/LSF server settings, agent language), writes them and checks readiness. Design inputs, register table and file lists come later in /new-verification. Use right after `script/new_project/bootstrap.sh`, or when the user invokes /new-project or asks to re-parameterize the project. With `sync <framework-repo>` it pulls a newer framework version into this project (3-way per carried file, project values kept, only new variables interviewed).
argument-hint: "[phase number to revisit] | sync <framework-repo>"
---

# New project setup (project stage: interview → apply → check)

`$ARGUMENTS` starting with `sync` → skip to "Sync mode" at the end; otherwise run sections 0-4.

The leader (main session) runs this. Every value lives in the registry `script/new_project/vars.json` (stage `project`); every write goes through `script/new_project/new_project.py` (alias `NP` below = `python script/new_project/new_project.py`, run from `verify/`). Never edit the target files by hand during this procedure. Questions to the user are in the conversation language; files stay in the project file language.

## 0. Preconditions

- `script/new_project/answers.json` must contain `bootstrapped_from`. If it does not, this is the framework repo itself: stop and tell the user to run, by hand, `bash verify/script/new_project/bootstrap.sh <new-repo-root>`, then start Claude Code in `<new-repo-root>/verify` and rerun `/new-project`. `apply --stage project` refuses to run here anyway.
- The bootstrapped repo has no `tb_top/` yet - the first `--guvc` (in `/new-verification`) generates it.

## 1. Interview (phases P1-P4)

1. Run `NP status --stage project` and `NP detect --stage project`; read each variable's prompt, choices, default and deferrability in `vars.json`.
2. Go phase by phase, skipping variables already answered unless the user asked to revisit a phase (`$ARGUMENTS`):
   - **P1 identity + design root**: `project_name` (also the project id: `apply` writes it as `` `define PID <name> `` into `script/sflow/project_name`), `design_root` - the root of the design database (RTL, IP, netlists, register table), repo-root relative or absolute. The repo's `hdl/` is only a placeholder: always ask, offering the directories `detect` found (with their HDL file counts) and "Other" for a path that does not exist yet (allowed; check warns until it lands).
   - **P2 machine tools**: `uvm_home`, `verilator`, `lz4`, `wave_viewer`, `vcs`, `verdi_home` are check-only - report what was found and, for a missing tool, the hint from `docs/ops/oeda_local_setup.md`, with "fix later" as an option. For `verilator`, `uvm_home`, `lz4` (link probe: FST waveform builds need the lz4/zlib dev libraries) and `wave_viewer` (Surfer/GTKWave, optional), `NP detect` adds `status` and `advice` against the recommended toolchain (Verilator >= 5.054, Accellera UVM-1.2; canon: `docs/ops/oeda_local_setup.md`): READY → recommend using it (for UVM, the `export UVM_HOME=...` line); WARN → explain the compatibility risk from `advice` and offer "follow the advice" / "fix later". Record the outcome in the "This machine" section of `docs/ops/oeda_local_setup.md`.
   - **P3 VCS server**: `wsim_python`, `lsf_enable`, `lsf_queue`, `lsf_hosts_file`, `lsf_submit_hosts`, `lsf_exec_host_regex`, `lsf_queue_sed`, `dpo_db`, `agent_vcs_max_jobs` (concurrent agent-started VCS runs, default 3). Bootstrap resets this section (`WSIM_PYTHON=python3`, LSF off, `WSIM_AGENT_VCS_MAX_JOBS=3`, the rest empty) - no old-server value survives; offer the detected candidates.
   - **P4 language**: `reply_language`, `file_language`.
3. Ask with AskUserQuestion, at most 4 questions per call. Options in this order: detected candidates (say in the description where each came from), the value currently in the target ("keep current"), the registry default, "defer" for deferrable variables; free text through "Other".
4. Record each answered round right away: `NP set id=value ...`, `NP set --defer id` for deferrals (the call validates; on an error re-ask). Answers survive an interrupted session.

## 2. Confirm and apply

1. Show one summary table: phase, variable, new value, current value, deferred items. AskUserQuestion: apply / revise a phase / stop. These targets are source-of-truth files; this confirmation is the user approval (ops §1).
2. `NP apply --stage project --dry-run`, show the planned changes, then `NP apply --stage project`. A `WARN ... snippet not found` line means an expected text was edited by hand - show it and fix that spot with the user.
3. `NP check --stage project`. FAIL items must be resolved; PENDING and WARN items are reported, not blockers. A `source-value` WARN is an identity value of the source project (recorded at bootstrap) left outside the rewrite files, a `source-module` WARN a module name of the source project - reword the spot generically (maintenance.md R1) and, in the framework repo, add the file to that variable's rewrite files.

## 3. Record

- `docs/memory/leader_taskboard.md`: close the "New-project setup" row (done, date); add one pending row per deferred variable / missing tool (trigger: when it lands).
- `docs/memory/fw_env_memory.md`: one entry "date / project parameterized by /new-project / values (summary) / pending items".
- Put the `NP check --stage project --markdown` table in the report to the user.

## 4. Next stage

First ask the user to run `/doctor prompt-audit` (user-typed - Claude cannot invoke it): `apply` just rewrote CLAUDE.md, the charters, rules and the ops runbook, and this is the cheapest moment to catch leftovers of the old project (`check` already covers the source project's identity values and its module names). Fix its findings with the user's approval.

Then ask (AskUserQuestion) whether to start the verification intake now: yes → invoke the `new-verification` skill with the chip as the requirement; no → stop and say `/new-verification` starts it later. Tell the user what comes there: specification/RTL inputs, module partition and config (spec2json), register table, `--guvc`, then the design-input step that scans the design root and proposes the file lists for confirmation. Do not continue without the answer.

Commit only after the user approves (leader, `COMMIT_APPROVED=1`), including `answers.json` - the project's record of these values.

## Sync mode (`/new-project sync <framework-repo>`)

Pulls the framework's committed HEAD into this project. Only carried files and the framework part of one reset file (`flow_env.sh`) are touched; `arch_memory` (project state), generated files and chip state never are. Alias `FW` = `python <framework-repo>/verify/script/new_project/new_project.py --root .` (run from this `verify/`) - always the FRAMEWORK's script: this project's copy may predate sync, and the sync replaces it.

1. **Preconditions**: `answers.json` has `bootstrapped_from`; the project's working tree is committed (or the user accepts syncing onto uncommitted edits); `<framework-repo>` is a git repo - ask for its path if `$ARGUMENTS` has none.
2. **Plan**: `FW resync --dry-run --markdown`; show the table and the NOTE lines. Actions: `take` (framework change, untouched here), `merge` (both changed, merged cleanly), `add` (new framework file), `keep` (changed here only), `conflict` (framework version will be written to `<file>.fw-new`, the project file stays), `delete?` (removed in the framework, unchanged here), `removed-modified` (removed there, edited here - kept). Every file is shown with the project's own values already applied, so identity tokens never show up as differences.
3. **Confirm**: AskUserQuestion - sync / stop. These are source-of-truth files; this confirmation is the user approval (ops §1). Then ask about **each** `delete?` file separately (delete / keep; at most 4 per call) - never delete in bulk.
4. **Run**: `FW resync --delete <file> ...` (one `--delete` per confirmed file). It records `synced_from` (framework commit, date, its values) in `answers.json`; the next sync compares against that commit.
5. **Conflicts**: for each `<file>.fw-new`: show `git diff --no-index <file> <file>.fw-new`, propose the merged text (keep the project's own edits, take the framework's), apply it after the user agrees, delete the `.fw-new`. A `removed-modified` file: ask keep or delete.
6. **New variables** (NOTE line): interview only those, by their phase (section 1 of this skill), then `NP set` / `NP apply --stage project` / `NP check --stage project` with this project's (now synced) `NP`.
7. **Follow-ups** from the NOTE lines:
   - flow scripts changed → `bash script/file_manage.sh`;
   - generator/templates changed → propose a json2env dispatch: (a) commit first, `--guvc`, `git diff`, one smoke run - this refreshes the assembly files; (b) module-private files of modules that already exist are never regenerated, so json2env copies `script/` to a scratch tree (`sim/_tpl_check/verify/script/`), runs `--guvc` there with this project's config, diffs every module-private file of the existing modules against the project's copy and reports the template-side hunks per module; after the user approves, dev_agent ports them module by module (hand extensions stay); new config keys are part of the same dispatch;
   - `hand migration [<entry>]: <action>` → the framework logged a step it cannot carry (module-private files, reset or state files such as arch_memory, a one-time conflict). Show the list, check each against this project (skip what is already done), and do the rest with the user's approval - edits of source-of-truth or module-private files go through the owning agent.
8. **Record**: `docs/memory/fw_env_memory.md` entry (date / synced framework `<old>` → `<new>` / take-merge-add-delete counts, conflicts and how resolved / follow-ups and hand migrations done or open); taskboard rows for open follow-ups. Ask the user to run `/doctor prompt-audit`, then commit with approval (`COMMIT_APPROVED=1`, including `answers.json`).

## Gotchas

- A new framework value must be registered in `vars.json` (with its `stage`) in the same change that introduces it (`.claude/rules/maintenance.md` R7), otherwise no interview asks it.
- `project_name` and `design_root` rewrite identity tokens in docs/rules/the path guard (`rewrites` in the registry); `apply` does it, never hand-edit those tokens.
- Module-level values and everything under `tb_top/` belong to `/new-verification`.
- Sync takes the framework's last commit, not its uncommitted edits (a NOTE says so). If the recorded base commit is gone from the framework repo (rewritten history), every difference becomes a conflict - pass `--base <sha>` when the user knows the right one.

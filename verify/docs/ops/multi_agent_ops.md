# multi_agent_ops — multi-agent verification flow runbook

Roles are defined in `verify/.claude/agents/`; this runbook targets the **leader (the main session)**. Deployment record: `docs/memory/arch_memory.md` §8.

**Language rule (2026-11-19):** all conversational output — leader/agent replies, reports, AskUserQuestion — is in Chinese; every file written into the project (this one included) is in English.

## 0. Roles and call rights

| Agent | Definition | Model | Invocation |
|---|---|---|---|
| leader | **the main session itself** (runs by this runbook, no dedicated memory) | user's `/model` choice | — |
| spec2json_agent | `.claude/agents/spec2json_agent.md` | opus | explicit user call; leader relays only after AskUserQuestion approval |
| json2env_agent | `.claude/agents/json2env_agent.md` | sonnet | same as above |
| dev_agent | `.claude/agents/dev_agent.md` | sonnet | leader auto-dispatch; parallel instances, **one instance per module** |
| debug_agent | `.claude/agents/debug_agent.md` | sonnet | leader auto-dispatch; parallel instances |
| deliver_agent | `.claude/agents/deliver_agent.md` | sonnet | leader auto-dispatch |
| review_agent | `.claude/agents/review_agent.md` | sonnet | leader dispatch after user confirmation |

Leader duties: analyze user needs, schedule and manage the other agents, analyze returned results and compile reports, execute commits after approval. **The leader never edits code**; the other agents may edit code but never commit.

## 1. Tiered confirmation mode

Sub-agents cannot ask the user mid-run, so file confirmation is tiered:

- **Sub-agents may edit directly** (rollbackable artifacts): their own module's module-private files (`uvc/<mod>/`, `<mod>_seq/test`, `<mod>_block_base_*`, `json/case/<mod>.json`, `tb_top_<mod>.sv`, `uvm_blk_<mod>.f`, `<mod>_if_conn*`), newly written test/seq/coverage code, `docs/features/`, `docs/review/`, agent memories under `docs/memory/`, `deliver_bridge/` reports. Exception: a new reference model (`uvc/<mod>/src/<mod>_ref_model.sv`) is approval-gated — plan first, develop only after user approval (dev_agent charter).
- **Change plan + user approval required first**: anything under `script/` (generators/flow), `script/uvm_env_config_template.json`, `tb_top/filelist/*.f`, assembly/base template-pure files, `CLAUDE.md`, rule-bearing entries of `arch_memory.md`, cross-module shared files.
- **git commit always requires user approval**: agents never commit (hook-hard-blocked); the leader compiles the impact analysis → user approves → the leader runs `COMMIT_APPROVED=1 git commit ...` (the hook's only escape hatch, leader-only).

## 2. Scheduling discipline

- Parallel agents **≤ 6**.
- One dev/debug instance per module at a time (avoids file-conflict surface); cross-module parallelism is fine.
- Simulations mainly run on the Linux-server VCS (no parallel quota once deployed); local WSL/Verilator is for oEDA fast iteration only (heavy compiles — batch loops for consecutive cases).

## 3. Dual-flow and coverage policy

- **VCS flow setup is the near-term priority** (the user will deploy `wsim` on Linux); oEDA (`wsim_oeda`) is the local fast-iteration flow and leads during early iteration. Migration backlog and triggers: `docs/memory/leader_taskboard.md`.
- **Passrate definition**: pass cases / total cases; pass = simv exit 0 and no `UVM_ERROR`/`UVM_FATAL` in `sim.log`. The VCS stage starts at passrate ≥ 80%.
- **Coverage ownership**: function coverage (covergroups) runs and converges on VCS only (`-cm`/`-fm`); property checks are dual-track — VCS runs the `<mod>_if_pc.sv` SVA (`` `ifndef OPEN_EDA `` guard), oEDA runs the logic-equivalent procedural checks in monitor/scoreboard (`` `ifdef OPEN_EDA `` guard, counted in the oEDA passrate); both sides are convergence-compared and any one-side change must be mirrored on the other.
- **VCS result return**: the user runs `wsim` on Linux and drops `result.txt`/`fail_wave.txt` into `sim/vcs_results/<date>/`; debug_agent analyzes them and produces the convergence report via the conv-report skill.
- Sign-off rule unchanged (arch_memory §5): an oEDA PASS is necessary but never sufficient; convergence sign-off is VCS-only.

## 4. Doc map (canonical index for the whole tree)

Retrieval entry point: **look up this table first** to find the canonical home of a fact class, then read that spot; other documents may keep a summary plus a pointer, never a full restatement (arch_memory R6).

| File | Owner | Content (canonical level) |
|---|---|---|
| `verify/CLAUDE.md` | whole project (loaded every session) | overview/commands/stable conventions; **canon of Verilator/OPEN_EDA coding rules, oEDA usage and pass criterion** |
| `docs/ops/multi_agent_ops.md` | leader | **process canon**: roles/tiered confirmation/scheduling/passrate/hooks/this table |
| `docs/ops/oeda_local_setup.md` | environment | local WSL2/Verilator machine setup and Windows invocation pitfalls (machine-specific ops manual) |
| `docs/memory/arch_memory.md` | whole project (spec2json owns the verification-strategy parts) | **architecture state §0, maintenance rules R1-R6, two-flow closed loop §5, deployment history §8** (section numbers frozen, header TOC) |
| `docs/modules/<mod>.md` | cross-agent | **per-module DUT-knowledge canon** (instance: apb_master); stable facts distilled from process logs are promoted here per R6 |
| `docs/memory/fw_env_memory.md` | json2env_agent | environment framework change log |
| `docs/memory/dev/<mod>.md` | dev_agent | module development log (copy-create from `dev/_template.md`) |
| `docs/memory/debug/<mod>.md` | debug_agent | issue & fix log (copy-create from `debug/_template.md`) |
| `docs/memory/deliver/<mod>.md` | deliver_agent | delivery log (copy-create from `deliver/_template.md`) |
| `docs/memory/leader_taskboard.md` | leader | task board (updated on every dispatch/recall) |
| `docs/features/<mod>/` | dev_agent | feature list (`proposed` status requires user confirmation) + PROGRESS |
| `docs/review/` | review_agent | review report archive |
| `.claude/agents/*.md` | each agent | charter: role/flow/inline constraints/report format (enforcement subset of the canons) |
| `.claude/skills/` (add-test-case, conv-report) | skills | ops manuals (open gaps: arch_memory §9) |
| `docs/sys_function_splits.md` | spec2json | level-partition plan (exists once produced) |
| `docs/reports/` | reports | verification campaign reports (`report_template.md` outline + conventions; one per campaign, append-only; leader compiles from agent outputs) |
| `deliver_bridge/README.md` | interface | design↔verification directory conventions |

**Key entries per hot file** (retrieval goes to file + section, not just the file):

- `verify/CLAUDE.md`: Commands (wsim/wsim_oeda usage, pass criterion) · "Regenerating the environment" (R5 canon: skip-if-exists vs template-pure, add/remove workflow, config knobs + generator-enforced rules) · oEDA/OPEN_EDA sections (Verilator rules + dual-track property canon) · Architecture (UVC pattern, filelist layering) · Multi-agent section (leader pointer).
- `docs/memory/arch_memory.md`: §0 module/state table · R1/R2 module-sync rules (hook-referenced) · R3 skill preference · R6 doc governance · §5 two-flow closed loop · §6 deferred status · §7 system bring-up checklist · §8 deployment history · §9 open development gaps.
- `docs/ops/multi_agent_ops.md`: §0 roles · §1 tiered confirmation · §2 scheduling · §3 passrate/coverage · §4 this map · §5 escalation · §6 hooks · §7 dispatch input · §8 new-requirement intake.
- `docs/modules/<mod>.md`: DUT details/quirks/case macros per module (first instance: apb_master).

**Task routing** (what am I trying to do → where to look):

| Task | Look at |
|---|---|
| Add/remove a module | arch R1/R2 + CLAUDE "Regenerating the environment" + log the change in fw_env_memory |
| Run/simulate a case | CLAUDE Commands (wsim / wsim_oeda) + pass criterion |
| Write a leaf test/seq | add-test-case manual (§3/§4) + arch §9 open gaps + arch R3 |
| Check a DUT behavior/quirk | `docs/modules/<mod>.md` |
| Change the framework/generator | CLAUDE Regen canon + arch R5 → log to fw_env_memory |
| Dual-track property / coverage questions | CLAUDE OPEN_EDA canon + ops §3 + arch §6 status |
| Locate any document | this map + the key-entries list above |
| Change the multi-agent process | this file (ops) — then sync the charter summaries |

Entry format everywhere: **date / change (or symptom) / reason / impact**. The leader may read all memories; agents cross-reference as needed (review_agent must read dev/debug memories; deliver_agent reads debug memories and features progress). To change a rule: edit the canon first, sync the summaries, then grep the old wording for missed spots (R6).

## 5. Escalation paths (agent never decides alone)

| Trigger | Handling |
|---|---|
| Feature point contradicts the spec docs | agent stops and reports → leader AskUserQuestion → proceed only on user decision |
| oEDA/VCS flow or script defect | propose → user approval → fix (sources in `script/`) |
| New feature point | deliver_agent proposes the plan → user confirms → leader dispatches dev_agent |
| Module add/remove | spec2json proposes the config → user approves → json2env runs `--guvc`/`--prune` + R1/R2 sync |

## 6. Hook guardrails

- **path_guard** (`.claude/hooks/path_guard.py`): Write/Edit outside `verify/`, `deliver_bridge/`, `sim/` → hard block (`~/.claude/projects` is whitelisted for session/memory state); Bash/PowerShell `git commit` without `COMMIT_APPROVED=1` → hard block. The hook applies to the main session too — the leader's legitimate commits must carry the approval prefix.
- File-path writes inside Bash/PowerShell are advisory only (string-level checks misfire too often): discipline comes from the agent charters + leader review; out-of-root file changes are done by the user, or on explicit user instruction.
- `arch_memory_check.sh` keeps its original duty (R1/R2 module-sync reminders), independent of this flow.

## 7. Standard leader dispatch input

A sub-agent task prompt must contain: target module/scope, spec basis (doc paths or a "pre-research mode" declaration), whether it carries user approval (source-of-truth operations), expected outputs and report requirements, and the relevant memory/features file paths. Check the returned report against the charter's report format; ask for missing items before folding into the user report.

## 8. New-requirement intake procedure (leader, on every brand-new verification request)

**Trigger test** — run this only when the request starts a NEW verification effort (new module, new feature set, new level). A continuation request ("continue debugging apb_master") gets only a next-step proposal, never the full pipeline. Before proposing, the leader does a light state check: arch §0 (does the module exist? block support?), taskboard (in-flight work), `docs/features/<mod>/` (existing feature lists), relevant memories.

**Recommended pipeline** — present the six stages as a plan table personalized to the requirement; per stage state what it would do HERE, the inputs needed (spec doc paths or a "pre-research mode" declaration), expected outputs, and whether it can be skipped with the reason:

| Stage | Agent | What it does here | Skip when |
|---|---|---|---|
| 1 | spec2json_agent | level partition → `sys_function_splits.md` + config proposal | module & levels already partitioned |
| 2 | json2env_agent | env build/update (`--guvc`, deploy, smoke) | env for the target already exists (check §0 / fw_env_memory) |
| 3 | dev_agent_N | confirmed feature list + UVC/test/seq/coverage development | — (core stage) |
| 4 | debug_agent_N | oEDA debug → passrate ≥ 80% → VCS stage & convergence | — (core stage) |
| 5 | review_agent | code review, P0/P1/P2 report | optional — user decides |
| 6 | deliver_agent | status feedback to the design side | optional — user decides |

**Decision interaction** — ask via AskUserQuestion: (a) adopt the full pipeline; (b) adopt with named stages skipped; (c) custom instructions. The pipeline is an entry suggestion only — **it never bypasses existing gates** (spec2json/json2env invocation approvals, feature-list confirmation, source-of-truth approvals all still apply, per §1 and the charters).

**Recording** — write the decision + final plan to `docs/memory/leader_taskboard.md` and update it at every stage transition.

**Explicit invocation** — `/new-verification <requirement>` (skill `.claude/skills/new-verification/`) runs this procedure with the given requirement.

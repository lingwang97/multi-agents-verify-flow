# multi_agent_ops — multi-agent verification flow runbook

Roles are defined in `verify/.claude/agents/`; this runbook targets the **leader (the main session)**.

**Language rule:** all conversational output — leader/agent replies, reports, AskUserQuestion — is in Chinese; every file written into the project (this one included) is in English.

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

Leader duties: analyze user needs, schedule and manage the other agents, analyze returned results and compile reports, execute commits after approval. **The leader never edits code** — two exceptions: writing registry values through `new_project.py apply` / `resync` after the user confirms them (§1), and framework maintenance (generators, flow scripts, new_project, hooks, instruction files and docs) the user asked for and approved, in the framework repo or a project; the other agents may edit code but never commit.

## 1. Tiered confirmation mode

Sub-agents cannot ask the user mid-run, so file confirmation is tiered:

- **Sub-agents may edit directly** (rollbackable artifacts): their own module's module-private files (`uvc/<mod>/`, `<mod>_seq/test`, `<mod>_block_base_*`, `json/case/<mod>.json`, `tb_top_<mod>.sv`, `uvm_blk_<mod>.f`, `<mod>_if_conn*`), newly written test/seq/coverage code, `docs/features/`, `docs/review/`, agent memories under `docs/memory/`, `deliver_bridge/` reports. Exception: a new reference model (`uvc/<mod>/src/<mod>_ref_model.sv`) is approval-gated — plan first, develop only after user approval (dev_agent charter).
- **Change plan + user approval required first**: anything under `script/` (generators/flow), `script/uvm_env_config_template.json`, `tb_top/filelist/*.f`, assembly/base template-pure files, `CLAUDE.md`, `.claude/rules/`, `docs/ops/`, cross-module shared files. Exception: the leader writes registry values into these files through `new_project.py apply` after the user confirms the summary table — `/new-project` (project stage) and the intake's register-table and design-input steps (verification stage) — and pulls a newer framework through `new_project.py resync` after the user confirms its dry-run table (`/new-project sync`). Sub-agent Write/Edit of these paths is gated by path_guard (§6: prompt in default mode, block in auto-like modes); Bash-side writes stay advisory.
**RTL access** — the mode comes from the intake's `spec_dir` (`/new-verification` step 1):

- **Pre-research mode** (`spec_dir` none/unset): the reference RTL under the design root is the basis — agents read it freely.
- **Doc mode** (`spec_dir` is a document directory): verification is black-box by default — agents do not read the design RTL. Three reasons allow a request: **spec ambiguity** (a behaviour the documents allow to read two ways), **suspected issue** (contradictory spec, or failure localization pointing into the DUT), **gray-box verification** (internal signals/state: bound internal SVA, internal FSM coverage, hierarchical probes).
- **Request** — the agent stops and puts an RTL ACCESS REQUEST in its report: category, the exact question, the smallest file/module scope, how the answer will be used, and the no-RTL alternative (asking the design side).
- **Approval** — the leader relays it via AskUserQuestion: approve (scope may be narrowed) / reject / ask the design side instead (deliver_agent through `deliver_bridge/`). On approval the leader records a grant for that one dispatch — `python .claude/hooks/rtl_access.py grant --agent <agent> --path <scope> --category <c> --reason <r> --task <id>` — names it in the task prompt (§7), and revokes it (`rtl_access.py revoke --task <id>`) when the report is back; the grant also gets a taskboard row.
- **Independence** — expected behaviour still comes from the specification. What the RTL shows may resolve an ambiguity or localize a problem, but an ambiguity resolution becomes a spec clarification confirmed by the user or the design side (sent through deliver_agent); the current RTL behaviour is never copied into a reference model or scoreboard expectation.
- **Records** — the agent logs reason, scope and findings in its module log (`docs/memory/dev|debug/<mod>.md`); gray-box feature points carry the method tag `gray-box (RTL access approved <date>)` in `docs/features/<mod>/`.
- **Enforcement** — path_guard blocks a sub-agent's Read/Grep/Glob of the design root (or a search rooted above it) in doc mode without a matching grant (§6); Bash reads stay advisory. The structural design scan of intake stage 2b is not RTL behaviour reading and needs no grant.

- **VCS runs**: auto / proposed / confirm tiers - §3.

- **git commit always requires user approval**: agents never commit (hook-hard-blocked); the leader compiles the impact analysis → user approves → the leader runs `COMMIT_APPROVED=1 git commit ...` (the hook's only escape hatch, leader-only).

## 2. Scheduling discipline

- Parallel agents **≤ 6**.
- One dev/debug instance per module at a time (avoids file-conflict surface); cross-module parallelism is fine.
- Simulation load: VCS runs follow §3 (tiers, `WSIM_AGENT_VCS_MAX_JOBS`, background runs); oEDA compiles are heavy - consecutive cases run as one `wsim_oeda -m <mod>` regression (shared builds, `-j` parallel simulations).

## 3. Dual-flow and coverage policy

- **Flow order**: oEDA (`wsim_oeda`) leads early iteration; VCS (`wsim`) confirms and converges.
- **Passrate definition**: pass runs / total runs (every iteration counts); pass = simv exit 0 and no `UVM_ERROR`/`UVM_FATAL` in `sim.log`. The oEDA passrate of a module comes from `./wsim_oeda -m <mod>` (`sim/oeda_result.txt`), the VCS one from the `result.txt` of the wsim invocation dir (CLAUDE.md Commands). The VCS stage starts at oEDA passrate ≥ 80%.
- **Coverage ownership**: function coverage (covergroups) runs and converges on VCS only (`-cm`/`-fm`); property checks are dual-track — VCS runs the `<mod>_if_pc.sv` SVA (`` `ifndef OPEN_EDA `` guard), oEDA runs the logic-equivalent procedural checks in monitor/scoreboard (`` `ifdef OPEN_EDA `` guard, counted in the oEDA passrate); both sides are convergence-compared and any one-side change must be mirrored on the other.
- **VCS runs by agents** (canonical here): debug_agent runs `wsim`, the leader schedules it, by tier:

  | Tier | Runs | Decision |
  |---|---|---|
  | auto | VCS confirmation of a case that passes on oEDA; `-fsdb` reproduction of a VCS-only failure | debug_agent runs it and reports afterwards |
  | proposed | module regression `-m <mod>`, `-smoke`, `-stage1`, once the module's oEDA passrate is ≥ 80% | the leader proposes, the user approves once per module and campaign |
  | confirm | `-stage2`, `-full`, coverage (`-cm`, `-fm`), gate/post-layout (`-l gate|post`), DPO | the user confirms every run |

- **VCS execution rules**: at most `WSIM_AGENT_VCS_MAX_JOBS` (`script/sflow/flow_env.sh`) concurrent `wsim` invocations across all agents, the leader giving each dispatch its share, and at most one regression-group invocation (`-m`/`-smoke`/`-stage*`/`-full`) at a time - `wsim` parallelizes a group's cases itself (through LSF when enabled).
- Runs start from the repo-root `sim/` in the background (a compile + run outlasts one tool call) with `-timeout <seconds>`, so a license wait cannot hang the agent; results are read from the invocation dir `sim/uvm_scratch_<case|mod|group>_<timestamp>_.../` (`result.txt`, `fail_wave.txt`, per-run `sim.log`), where the conv-report skill finds them too. No `vcs` on the host: debug_agent writes the `wsim` command list instead and the user runs it into the same `sim/` locations.
- Sign-off rule (`.claude/rules/two-flow.md`): an oEDA PASS is necessary but never sufficient; convergence sign-off is VCS-only and stays the user's decision.

## 4. Doc map (canonical index for the whole tree)

Retrieval entry point: **look up this table first** to find the canonical home of a fact class, then read that spot (framework policy additionally loads on demand from the path-scoped rules it names); other documents may keep a summary plus a pointer, never a full restatement (maintenance.md R6).

| File | Owner | Content (canonical level) |
|---|---|---|
| `verify/README.md` | people | quick start for engineers (setup, run, flow diagrams, checkpoints) - summary + pointers only, no canon |
| `verify/CLAUDE.md` | whole project (loaded every session) | overview/commands and pass criteria; **canon of regeneration config-knob rules and the three file classes** |
| `.claude/rules/*.md` | whole project (path-scoped, load when matching files are opened) | **canon of Verilator/OPEN_EDA coding rules + dual-track property mechanism** (`oeda-verilator.md`), UVM architecture facts (UVC pattern, top assembly, runtime toggles, DUT/interface wiring; `uvm-architecture.md`), RAL/reg-table flow behaviour (`ral.md`), two-flow closed-loop policy (`two-flow.md`), maintenance rules R1-R9 (`maintenance.md`), flow settings/deploy/script gotchas (`flow-scripts.md`), filelist conventions (`filelists.md`); assembly-file reminder (`generated-assembly.md`, marks the template-pure files) |
| `docs/ops/multi_agent_ops.md` | leader | **process canon**: roles/tiered confirmation/scheduling/passrate/hooks/this table |
| `docs/ops/oeda_local_setup.md` | environment | local oEDA (Verilator) machine setup and invocation pitfalls (carried; only its "This machine" section is project state) |
| `docs/memory/arch_memory.md` | whole project (spec2json and json2env update the module rows, R2) | **project state only**: architecture/module table §0, system bring-up §1, open gaps §2 (header TOC; framework policy lives in `.claude/rules/maintenance.md` / `two-flow.md`) |
| `docs/modules/<mod>.md` | cross-agent | **per-module DUT-knowledge canon**; stable facts distilled from process logs are promoted here per R6 |
| `docs/memory/fw_env_memory.md` | json2env_agent | environment framework change log |
| `docs/memory/dev/<mod>.md` | dev_agent | module development log (copy-create from `dev/_template.md`) |
| `docs/memory/debug/<mod>.md` | debug_agent | issue & fix log (copy-create from `debug/_template.md`) |
| `docs/memory/deliver/<mod>.md` | deliver_agent | delivery log (copy-create from `deliver/_template.md`) |
| `docs/memory/leader_taskboard.md` | leader | task board (updated on every dispatch/recall) |
| `docs/features/<mod>/`, `docs/features/README.md` | dev_agent | feature list (`proposed` status requires user confirmation) + PROGRESS |
| `docs/review/` | review_agent | review report archive |
| `.claude/agents/*.md` | each agent | charter: role/flow/inline constraints/report format (enforcement subset of the canons) |
| `.claude/skills/` (add-test-case, conv-report, new-verification, new-project) | skills | ops manuals, the new-chip setup and **the intake canon** (`new-verification`) (open gaps: arch_memory §2) |
| `script/new_project/` | leader | new-chip bootstrap: `manifest.txt` (carry/reset/regen/state/exclude classification of every tracked file), `vars.json` (registry of every project value), `new_project.py` (+ `scan`: design-source suggestions, `check --lint`; `audit`: framework self-check - manifest/module-name/doc-map/registry coverage; `resync`: pull a newer framework into a project) and `bootstrap.sh`, `answers.json` (this project's recorded values) |
| `docs/features/sys_function_splits.md` | spec2json | level-partition plan (project state: generated per project by stage 1, never carried by the framework) |
| `docs/reports/` | reports | verification campaign reports (`report_template.md` outline + conventions; one per campaign, append-only; leader compiles from agent outputs) |
| `deliver_bridge/README.md` | interface | design↔verification directory conventions |

**Key entries per hot file** (retrieval goes to file + section, not just the file):

- `verify/CLAUDE.md`: Commands (wsim usage, pass criterion) · oEDA section (wsim_oeda usage, pass criterion, block-level flow) · "Regenerating the environment" (R5 canon: skip-if-exists vs template-pure, config knobs + generator-enforced rules) · Conventions (naming, deploy rule, language) · Multi-agent section (leader pointer). Non-obvious UVM facts and RalGen/reg-table behaviour live in `.claude/rules/uvm-architecture.md` / `ral.md`.
- `docs/memory/arch_memory.md`: §0 module/state table · §1 system bring-up checklist · §2 open development gaps. Maintenance rules R1-R9 and the two-flow policy live in `.claude/rules/maintenance.md` / `two-flow.md`.
- `docs/ops/multi_agent_ops.md`: §0 roles · §1 tiered confirmation + RTL access · §2 scheduling · §3 passrate/coverage · §4 this map · §5 escalation · §6 hooks · §7 dispatch input · §8 intake pointer (canon: `new-verification` skill).
- `docs/modules/<mod>.md`: DUT details/quirks/case macros per module.

**Task routing** (what am I trying to do → where to look):

| Task | Look at |
|---|---|
| Add/remove a module | CLAUDE "Regenerating the environment" + maintenance.md R2 (state docs) + log the change in fw_env_memory |
| Run/simulate a case | CLAUDE Commands (wsim / wsim_oeda) + pass criterion |
| Write a leaf test/seq | add-test-case manual (§3/§4) + arch §2 open gaps + maintenance.md R3 |
| Check a DUT behavior/quirk | `docs/modules/<mod>.md` |
| Change the framework/generator | CLAUDE Regen canon + `.claude/rules/generated-assembly.md` / `flow-scripts.md` + maintenance.md R5 → log to fw_env_memory |
| Dual-track property / coverage questions | `.claude/rules/oeda-verilator.md` + ops §3 + `.claude/rules/two-flow.md` |
| Locate any document | this map + the key-entries list above |
| Change the multi-agent process | this file (ops) — then sync the charter summaries |

Entry format: a dated heading plus the fields of the log's `_template.md` (fw_env_memory and dev: change / reason / impact; debug: symptom / root cause / fix / impact; deliver: status / design-side input / open items). The leader may read all memories; agents cross-reference as needed (review_agent must read dev/debug memories; deliver_agent reads debug memories and features progress). To change a rule: edit the canon first, sync the summaries, then grep the old wording for missed spots (R6); after changing `CLAUDE.md` or anything under `.claude/`, run `/doctor prompt-audit` in an interactive session (read-only report; default scope = CLAUDE.md + `.claude/` rules/skills/agents, pass `docs/` to cover the docs tree) and route its findings through the normal approval.

## 5. Escalation paths (agent never decides alone)

| Trigger | Handling |
|---|---|
| RTL access needed in doc mode (spec ambiguity / suspected issue / gray-box) | agent stops with an RTL ACCESS REQUEST → leader AskUserQuestion (approve / narrow / reject / ask the design side) → per-dispatch grant (`rtl_access.py`), revoked when the report is back (§1 RTL access) |
| Feature point contradicts the spec docs | agent stops and reports → leader AskUserQuestion → proceed only on user decision |
| oEDA/VCS flow or script defect | propose → user approval → fix (sources in `script/`) |
| New feature point | deliver_agent proposes the plan → user confirms → leader dispatches dev_agent |
| Module add/remove | spec2json proposes the config → user approves → json2env runs `--guvc`/`--prune` + R2 state sync |

## 6. Hook guardrails

- **path_guard** (`.claude/hooks/path_guard.py`; a call is a sub-agent call when the hook input carries `agent_id`):
  - Write/Edit outside `verify/`, `deliver_bridge/`, `sim/` → hard block for everyone (`~/.claude/projects` is whitelisted for session/memory state).
  - `git commit` from a sub-agent → hard block, even with `COMMIT_APPROVED=1`; from the main session → blocked unless the command carries `COMMIT_APPROVED=1` (leader-only, after user approval).
  - Tiered confirmation (§1): a sub-agent Write/Edit of a source-of-truth file (`script/**`, `.claude/**`, `utils/**`, `docs/ops/**`, `CLAUDE.md`, `json/module.json`, `tb_top/filelist/*.f` except module-private `uvm_blk_*`/`tb_top_*`, the template-pure assembly files) or the creation of `uvc/<mod>/src/<mod>_ref_model.sv` needs the user. The hook decides by the session's permission mode:
    - **default/plan** → permission prompt in the main session naming the agent (the user's answer is the approval; even with a leader-relayed approval the user is asked once more - intended);
    - **auto/acceptEdits/bypassPermissions/dontAsk** → hard block: those modes settle prompts without a human (in auto mode an `ask` goes through unprompted).
  After such a block the agent stops and reports; the user switches to default mode (Shift+Tab) and the leader re-dispatches. `arch_memory.md` stays ungated: it holds project state that json2env/spec2json update (maintenance.md R2).
  - After any edit of the hook run `python .claude/hooks/test_path_guard.py` (decision matrix; a syntax error makes the hook fail open silently).
  - RTL access (§1): in doc mode a sub-agent Read/Grep/Glob of the design root - or a search rooted above it - is blocked unless `.claude/state/rtl_access.json` holds a grant for that agent and path (leader-only helper `.claude/hooks/rtl_access.py`; sub-agents cannot write `.claude/`). Mode and design root come from `script/new_project/answers.json` (`spec_dir`, `design_root`); pre-research mode is not gated.
- File-path writes inside Bash (generators, sed, scripts) are advisory only (string-level checks misfire too often): discipline comes from the agent charters + leader review; out-of-root file changes are done by the user, or on explicit user instruction.
- `arch_memory_check.sh` (PreToolUse/Bash) keeps its original duty, the R2 module-state reminder, independent of this flow: it fires once per state when `script/uvm_env_config_template.json`, `json/module.json` or `script/gen_uvm_env.py` have uncommitted changes. It only injects a reminder (nothing is edited until the user confirms); state is kept in `.git/arch_memory_hook.state` (delete it to re-trigger).

## 7. Standard leader dispatch input

A sub-agent task prompt must contain: target module/scope, spec basis (doc paths or a "pre-research mode" declaration), RTL access (pre-research: free; doc mode: "none" or the approved grant - category, scope, task id), whether it carries user approval (source-of-truth operations), for debug_agent the VCS tier the user approved and the job share (§3), expected outputs and report requirements, and the relevant memory/features file paths. Check the returned report against the charter's report format; ask for missing items before folding into the user report.

## 8. New-requirement intake

On every brand-new verification request the leader runs the intake procedure; its canon is the `new-verification` skill (`.claude/skills/new-verification/SKILL.md`, `/new-verification <requirement>`): trigger test, project check, verification inputs (`spec_dir` sets the RTL-access mode of §1), the plan table (stages 1-6 incl. 2b design inputs) and its decision, the config/register-table and design-input steps. It never bypasses the gates of §1 and the charters.

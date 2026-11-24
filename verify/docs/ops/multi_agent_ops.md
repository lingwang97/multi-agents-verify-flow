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

Leader duties: analyze user needs, schedule and manage the other agents, analyze returned results and compile reports, execute commits after approval. **The leader never edits code** — the one exception is writing registry values through `new_project.py apply` after the user confirms them (§1); the other agents may edit code but never commit.

## 1. Tiered confirmation mode

Sub-agents cannot ask the user mid-run, so file confirmation is tiered:

- **Sub-agents may edit directly** (rollbackable artifacts): their own module's module-private files (`uvc/<mod>/`, `<mod>_seq/test`, `<mod>_block_base_*`, `json/case/<mod>.json`, `tb_top_<mod>.sv`, `uvm_blk_<mod>.f`, `<mod>_if_conn*`), newly written test/seq/coverage code, `docs/features/`, `docs/review/`, agent memories under `docs/memory/`, `deliver_bridge/` reports. Exception: a new reference model (`uvc/<mod>/src/<mod>_ref_model.sv`) is approval-gated — plan first, develop only after user approval (dev_agent charter).
- **Change plan + user approval required first**: anything under `script/` (generators/flow), `script/uvm_env_config_template.json`, `tb_top/filelist/*.f`, assembly/base template-pure files, `CLAUDE.md`, `.claude/rules/`, rule-bearing entries of `arch_memory.md`, cross-module shared files. Exception: the leader writes registry values into these files through `new_project.py apply` after the user confirms the summary table — `/new-project` (project stage) and the §8 register-table and design-input steps (verification stage). Sub-agent Write/Edit of these paths (except `arch_memory.md`) is gated by path_guard (§6: prompt in default mode, block in auto-like modes); Bash-side writes stay advisory.
**RTL access (user decision 2026-11-24)** — the mode comes from the intake's `spec_dir` (§8 step 1):

- **Pre-research mode** (`spec_dir` none/unset): the reference RTL under the design root is the basis — agents read it freely.
- **Doc mode** (`spec_dir` is a document directory): verification is black-box by default — agents do not read the design RTL. Three reasons allow a request: **spec ambiguity** (a behaviour the documents allow to read two ways), **suspected issue** (contradictory spec, or failure localization pointing into the DUT), **gray-box verification** (internal signals/state: bound internal SVA, internal FSM coverage, hierarchical probes).
- **Request** — the agent stops and puts an RTL ACCESS REQUEST in its report: category, the exact question, the smallest file/module scope, how the answer will be used, and the no-RTL alternative (asking the design side).
- **Approval** — the leader relays it via AskUserQuestion: approve (scope may be narrowed) / reject / ask the design side instead (deliver_agent through `deliver_bridge/`). On approval the leader records a grant for that one dispatch — `python .claude/hooks/rtl_access.py grant --agent <agent> --path <scope> --category <c> --reason <r> --task <id>` — names it in the task prompt (§7), and revokes it (`rtl_access.py revoke --task <id>`) when the report is back; the grant also gets a taskboard row.
- **Independence** — expected behaviour still comes from the specification. What the RTL shows may resolve an ambiguity or localize a problem, but an ambiguity resolution becomes a spec clarification confirmed by the user or the design side (sent through deliver_agent); the current RTL behaviour is never copied into a reference model or scoreboard expectation.
- **Records** — the agent logs reason, scope and findings in its module log (`docs/memory/dev|debug/<mod>.md`); gray-box feature points carry the method tag `gray-box (RTL access approved <date>)` in `docs/features/<mod>/`.
- **Enforcement** — path_guard blocks a sub-agent's Read/Grep/Glob of the design root (or a search rooted above it) in doc mode without a matching grant (§6); Bash reads stay advisory. The structural design scan of §8 stage 2b is not RTL behaviour reading and needs no grant.

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
| `verify/README.md` | people | quick start for engineers (setup, run, flow diagrams, checkpoints) - summary + pointers only, no canon |
| `verify/CLAUDE.md` | whole project (loaded every session) | overview/commands/stable conventions; **canon of oEDA usage and pass criterion, regeneration/config-knob rules, RalGen/reg-table behaviour** |
| `.claude/rules/*.md` | whole project (path-scoped, load when matching files are opened) | **canon of Verilator/OPEN_EDA coding rules + dual-track property mechanism** (`oeda-verilator.md`), flow settings/deploy/script gotchas (`flow-scripts.md`), filelist conventions (`filelists.md`); assembly-file reminder (`generated-assembly.md`, summary of the CLAUDE.md regen canon) |
| `docs/ops/multi_agent_ops.md` | leader | **process canon**: roles/tiered confirmation/scheduling/passrate/hooks/this table |
| `docs/ops/oeda_local_setup.md` | environment | local WSL2/Verilator machine setup and Windows invocation pitfalls (machine-specific ops manual) |
| `docs/memory/arch_memory.md` | whole project (spec2json owns the verification-strategy parts) | **architecture state §0, maintenance rules R1-R7, two-flow closed loop §5, deployment history §8** (section numbers frozen, header TOC) |
| `docs/modules/<mod>.md` | cross-agent | **per-module DUT-knowledge canon** (instance: apb_master); stable facts distilled from process logs are promoted here per R6 |
| `docs/memory/fw_env_memory.md` | json2env_agent | environment framework change log |
| `docs/memory/dev/<mod>.md` | dev_agent | module development log (copy-create from `dev/_template.md`) |
| `docs/memory/debug/<mod>.md` | debug_agent | issue & fix log (copy-create from `debug/_template.md`) |
| `docs/memory/deliver/<mod>.md` | deliver_agent | delivery log (copy-create from `deliver/_template.md`) |
| `docs/memory/leader_taskboard.md` | leader | task board (updated on every dispatch/recall) |
| `docs/features/<mod>/` | dev_agent | feature list (`proposed` status requires user confirmation) + PROGRESS |
| `docs/review/` | review_agent | review report archive |
| `.claude/agents/*.md` | each agent | charter: role/flow/inline constraints/report format (enforcement subset of the canons) |
| `.claude/skills/` (add-test-case, conv-report, new-verification, new-project) | skills | ops manuals, the intake procedure and the new-chip setup (open gaps: arch_memory §9) |
| `script/new_project/` | leader | new-chip bootstrap: `manifest.txt` (carry/reset/regenerate classification), `vars.json` (registry of every project value), `new_project.py` (+ `scan`: design-source suggestions, `check --lint`) and `bootstrap.sh`, `answers.json` (this project's recorded values) |
| `docs/sys_function_splits.md` | spec2json | level-partition plan (exists once produced) |
| `docs/reports/` | reports | verification campaign reports (`report_template.md` outline + conventions; one per campaign, append-only; leader compiles from agent outputs) |
| `deliver_bridge/README.md` | interface | design↔verification directory conventions |

**Key entries per hot file** (retrieval goes to file + section, not just the file):

- `verify/CLAUDE.md`: Commands (wsim usage, pass criterion) · oEDA section (wsim_oeda usage, pass criterion, block-level flow) · "Regenerating the environment" (R5 canon: skip-if-exists vs template-pure, config knobs + generator-enforced rules) · "Flow scripts and the register table" (RalGen gating) · Architecture (non-obvious UVC/base facts) · Multi-agent section (leader pointer).
- `docs/memory/arch_memory.md`: §0 module/state table · R1/R2 module-sync rules (hook-referenced) · R3 skill preference · R6 doc governance · §5 two-flow closed loop · §6 deferred status · §7 system bring-up checklist · §8 deployment history · §9 open development gaps.
- `docs/ops/multi_agent_ops.md`: §0 roles · §1 tiered confirmation + RTL access · §2 scheduling · §3 passrate/coverage · §4 this map · §5 escalation · §6 hooks · §7 dispatch input · §8 new-requirement intake.
- `docs/modules/<mod>.md`: DUT details/quirks/case macros per module (first instance: apb_master).

**Task routing** (what am I trying to do → where to look):

| Task | Look at |
|---|---|
| Add/remove a module | arch R1/R2 + CLAUDE "Regenerating the environment" + log the change in fw_env_memory |
| Run/simulate a case | CLAUDE Commands (wsim / wsim_oeda) + pass criterion |
| Write a leaf test/seq | add-test-case manual (§3/§4) + arch §9 open gaps + arch R3 |
| Check a DUT behavior/quirk | `docs/modules/<mod>.md` |
| Change the framework/generator | CLAUDE Regen canon + `.claude/rules/generated-assembly.md` / `flow-scripts.md` + arch R5 → log to fw_env_memory |
| Dual-track property / coverage questions | `.claude/rules/oeda-verilator.md` + ops §3 + arch §6 status |
| Locate any document | this map + the key-entries list above |
| Change the multi-agent process | this file (ops) — then sync the charter summaries |

Entry format everywhere: **date / change (or symptom) / reason / impact**. The leader may read all memories; agents cross-reference as needed (review_agent must read dev/debug memories; deliver_agent reads debug memories and features progress). To change a rule: edit the canon first, sync the summaries, then grep the old wording for missed spots (R6); after changing `CLAUDE.md` or anything under `.claude/`, run `/doctor prompt-audit` in an interactive session (read-only report; default scope = CLAUDE.md + `.claude/` rules/skills/agents, pass `docs/` to cover the docs tree) and route its findings through the normal approval.

## 5. Escalation paths (agent never decides alone)

| Trigger | Handling |
|---|---|
| RTL access needed in doc mode (spec ambiguity / suspected issue / gray-box) | agent stops with an RTL ACCESS REQUEST → leader AskUserQuestion (approve / narrow / reject / ask the design side) → per-dispatch grant (`rtl_access.py`), revoked when the report is back (§1 RTL access) |
| Feature point contradicts the spec docs | agent stops and reports → leader AskUserQuestion → proceed only on user decision |
| oEDA/VCS flow or script defect | propose → user approval → fix (sources in `script/`) |
| New feature point | deliver_agent proposes the plan → user confirms → leader dispatches dev_agent |
| Module add/remove | spec2json proposes the config → user approves → json2env runs `--guvc`/`--prune` + R1/R2 sync |

## 6. Hook guardrails

- **path_guard** (`.claude/hooks/path_guard.py`; a call is a sub-agent call when the hook input carries `agent_id`):
  - Write/Edit outside `verify/`, `deliver_bridge/`, `sim/` → hard block for everyone (`~/.claude/projects` is whitelisted for session/memory state).
  - `git commit` from a sub-agent → hard block, even with `COMMIT_APPROVED=1`; from the main session → blocked unless the command carries `COMMIT_APPROVED=1` (leader-only, after user approval).
  - Tiered confirmation (§1), enforced 2026-11-23: a sub-agent Write/Edit of a source-of-truth file (`script/**`, `.claude/**`, `utils/**`, `CLAUDE.md`, `json/module.json`, `tb_top/filelist/*.f` except module-private `uvm_blk_*`/`tb_top_*`, the template-pure assembly files) or the creation of `uvc/<mod>/src/<mod>_ref_model.sv` needs the user, and the hook decides by the session's permission mode: **default/plan** → permission prompt in the main session naming the agent (the user's answer is the approval; even with a leader-relayed approval the user is asked once more — intended); **auto/acceptEdits/bypassPermissions/dontAsk** → hard block, because those modes settle prompts without a human (verified live 2026-11-23: in auto mode an `ask` went through unprompted). After such a block the agent stops and reports; the user switches to default mode (Shift+Tab) and the leader re-dispatches. `arch_memory.md` stays advisory (rule vs state entries cannot be told apart).
  - After any edit of the hook run `python .claude/hooks/test_path_guard.py` (decision matrix; a syntax error makes the hook fail open silently).
  - RTL access (§1): in doc mode a sub-agent Read/Grep/Glob of the design root - or a search rooted above it - is blocked unless `.claude/state/rtl_access.json` holds a grant for that agent and path (leader-only helper `.claude/hooks/rtl_access.py`; sub-agents cannot write `.claude/`). Mode and design root come from `script/new_project/answers.json` (`spec_dir`, `design_root`); pre-research mode is not gated.
- File-path writes inside Bash/PowerShell (generators, sed, scripts) are advisory only (string-level checks misfire too often): discipline comes from the agent charters + leader review; out-of-root file changes are done by the user, or on explicit user instruction.
- `arch_memory_check.sh` (PreToolUse/Bash) keeps its original duty, the R1/R2 module-sync reminder, independent of this flow: it fires once per state when `script/uvm_env_config_template.json`, `json/module.json` or `script/gen_uvm_env.py` have uncommitted changes, or when `MODULES` in `add_test_case.py` differs from `json/module.json`. It only injects a reminder (nothing is edited until the user confirms); state is kept in `.git/arch_memory_hook.state` (delete it to re-trigger).

## 7. Standard leader dispatch input

A sub-agent task prompt must contain: target module/scope, spec basis (doc paths or a "pre-research mode" declaration), RTL access (pre-research: free; doc mode: "none" or the approved grant - category, scope, task id), whether it carries user approval (source-of-truth operations), expected outputs and report requirements, and the relevant memory/features file paths. Check the returned report against the charter's report format; ask for missing items before folding into the user report.

## 8. New-requirement intake procedure (leader, on every brand-new verification request)

**Trigger test** — run this only when the request starts a NEW verification effort (new module, new feature set, new level). A continuation request ("continue debugging apb_master") gets only a next-step proposal, never the full pipeline. Before proposing, the leader does a light state check: arch §0 (does the module exist? block support?), taskboard (in-flight work), `docs/features/<mod>/` (existing feature lists), relevant memories.

Every value the procedure needs is a registry variable of stage `verification` (`script/new_project/vars.json`), read with `new_project.py detect|scan`, recorded with `set` and written with `apply --stage verification` only after the user confirms. Interview style everywhere: AskUserQuestion, at most 4 questions per call, options = detected/scanned candidates (with where they came from), "keep current", default, "defer"; free text through "Other".

**Step 0 — project check** — in a bootstrapped repo (`script/new_project/answers.json` has `bootstrapped_from`) run `new_project.py status --stage project`; if project values are still pending, offer `/new-project` first (run it now / continue anyway).

**Step 1 — verification inputs** — `new_project.py detect --stage verification`; ask `spec_dir` (architecture/design/plan documents, or `none` = pre-research mode on reference RTL) and `rtl_dir` (inside the design root (design root: `hdl`)); `set`. `spec_dir` sets the RTL-access mode of §1; both go into the plan table and the spec2json task.

**Recommended pipeline** — present the stages as a plan table personalized to the requirement; per stage state what it would do HERE, the inputs it uses, expected outputs, and whether it can be skipped with the reason:

| Stage | Agent | What it does here | Skip when |
|---|---|---|---|
| 1 | spec2json_agent | level partition → `sys_function_splits.md` + config proposal | module & levels already partitioned |
| 2 | json2env_agent | env build/update (`--guvc`, deploy, smoke) | env for the target already exists (check §0 / fw_env_memory) |
| 2b | leader | design inputs: scan → suggested design file lists → user confirms → apply + check + lint | no RTL yet (defer all; rerun when it lands) |
| 3 | dev_agent_N | confirmed feature list + UVC/test/seq/coverage development | — (core stage) |
| 4 | debug_agent_N | oEDA debug → passrate ≥ 80% → VCS stage & convergence | — (core stage) |
| 5 | review_agent | code review, P0/P1/P2 report | optional — user decides |
| 6 | deliver_agent | status feedback to the design side | optional — user decides |

**Decision interaction** — ask via AskUserQuestion: (a) adopt the full pipeline; (b) adopt with named stages skipped; (c) custom instructions. The pipeline is an entry suggestion only — **it never bypasses existing gates** (spec2json/json2env invocation approvals, feature-list confirmation, source-of-truth approvals all still apply, per §1 and the charters).

**After stage 1 (config + register table)** — AskUserQuestion on spec2json's config proposal, including the top-level `enable_ral` / `has_top_if_cfg` (registry owner spec2json). If `enable_ral` is true, ask `reg_table`: candidates from `new_project.py scan` (CSVs carrying the RalGen columns), current value, "defer"; `set reg_table=...` and `apply --stage verification` (writes `WSIM_REG_TABLE`). spec2json then writes the approved config; `check --stage verification` compares the top-level values.

**Stage 2b — design inputs (leader, after json2env's `--guvc` created `tb_top/`)** — `new_project.py scan --markdown`, then per list variable present the scan suggestion with its reasons and confidence and, on a rerun, the +added/-removed diff against the current list (option previews). Round A: `rtl_files` (a design-side filelist referenced with `-f` vs the explicit scanned list), `include_dirs`, `rtl_define_files`, `ip_files`, `rtl_tops`. Round B (gate level, default "defer"): `gate_files`, `gate_ip_files`, `std_libs`, `gpls_libs`. Summary table → confirm → `apply --stage verification` → `check --stage verification --lint` (Verilator lint of the lists; on a Windows box run the printed command in WSL) → deferred items become taskboard rows, one fw_env entry. These lists are user-maintained skeletons — later `--guvc` runs keep them. The scan reads structure only (file, module, package, include names); it is not RTL behaviour reading, so the §1 RTL-access rule does not apply — in doc mode its hierarchy output feeds the file lists and the tb_top DUT wiring, not the spec analysis.

**Recording** — write the decision + final plan to `docs/memory/leader_taskboard.md` and update it at every stage transition.

**Explicit invocation** — `/new-verification <requirement>` (skill `.claude/skills/new-verification/`) runs this procedure with the given requirement.

**New chip** — a new chip project is first bootstrapped (`script/new_project/bootstrap.sh`, run by the user) and parameterized with `/new-project` (project stage: identity, design root, tools, server settings, language); that skill ends by asking whether to start this intake.

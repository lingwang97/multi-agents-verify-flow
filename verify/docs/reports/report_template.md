# Verification report template

Compiled by the leader at campaign milestones (convergence/sign-off or a user-designated point), from the agent outputs noted per section in brackets. Convention: `README.md` in this directory. Fill every section; where a section does not apply write "N/A" with a one-line reason. Copy this file to `<YYYY-MM-DD>_<dut>_<scope>_report.md` and fill it in.

# <YYYY-MM-DD> <dut> <scope> verification report

## 0. Header

| Item | Content |
|---|---|
| DUT | |
| Branch | |
| Level | block / subsystem / system (ref `docs/sys_function_splits.md`) |
| Simulator(s) | oEDA (Verilator) / VCS |
| Report date | |
| Compiled by | leader |
| Contributing agents | spec2json / json2env / dev / debug / review / deliver |
| Intake pipeline | stages run & skipped (per `docs/memory/leader_taskboard.md`) |

## 1. Scope & intake [leader + spec2json]

Requirement summary; spec basis (doc paths or a pre-research RTL-mode declaration); levels covered.

## 2. DUT analysis [spec2json]

Ports / parameters / behavior summary; the full DUT canon lives in `docs/modules/<mod>.md` — summarize here, point there.

## 3. Verification environment [json2env + leader design inputs]

Env structure per level (json2env); design file lists and register table (leader, ops §8 stage 2b; `script/new_project/answers.json`); config-knob state (history ref `docs/memory/fw_env_memory.md`).

## 4. Feature points & verification mapping [dev_agent]

| FP | Description | Method | Covering case | Status |
|---|---|---|---|---|

Method ∈ {property assertion, uvm_component check, reference model, directed, random}; list ref `docs/features/<mod>/`.

## 5. Simulation results [debug_agent]

Per-case table: case / iters / seeds / macros / result per flow; passrate per flow; oEDA↔VCS convergence (ref the conv-report output); VCS results in the wsim invocation dirs `sim/uvm_scratch_<case|mod|group>_<timestamp>_.../result.txt`.

## 6. Coverage [debug_agent]

Code coverage (oEDA DUT-only annotated lines + VCS `-cm`); functional covergroups (VCS `-fm`); property dual-track status (oEDA procedural checks + VCS SVA in `*_if_pc.sv`).

## 7. DUT issues & risks (for design review) [debug_agent]

Defects / quirks, graded; cross-ref `deliver_bridge/design_issue_<mod>_<date>.md` where filed.

## 8. Review summary [review_agent]

P0/P1/P2 findings and fix status; ref `docs/review/`.

## 9. Delivery status [deliver_agent]

What was reported to the design side; open items; baseline (ref `deliver_bridge/`).

## 10. Limitations & follow-up [leader]

## 11. Appendix [leader]

Repro commands; artifact paths (`sim/uvm_scratch_oeda_<case>/`, `sim/uvm_scratch_<case|mod|group>_<timestamp>_.../`); related documents.

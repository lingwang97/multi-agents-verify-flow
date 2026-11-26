---
paths:
  - "script/sflow/**"
  - "**/*.f"
  - "**/*.sv"
  - "**/*.svh"
  - "ral/**"
---

# Two-flow closed loop: oEDA first, VCS sign-off

Closed-loop policy, moved from `docs/memory/arch_memory.md` §5 (the section number is retired there). Neighbouring canons: usage and pass criteria `verify/CLAUDE.md` (Commands / oEDA section); Verilator/OPEN_EDA coding rules `.claude/rules/oeda-verilator.md`; process tiers, passrate accounting and coverage ownership `docs/ops/multi_agent_ops.md` §3; RAL/reg-table behaviour `.claude/rules/ral.md`.

Naming: the open-source flow is **oEDA** (script `wsim_oeda`, scratch `sim/uvm_scratch_oeda_<case>/`, isolation define `+define+OPEN_EDA`); the business flow is VCS (`wsim`, one `sim/uvm_scratch_<case|mod|group>_<timestamp>_.../` per invocation; layout in CLAUDE.md Commands).

**Loop:** develop/debug a case with `./wsim_oeda -c <case> [-seed 1]` (fast iteration, FST waves) -> once stable, confirm the same case on VCS with `./wsim -c <case> -uvm` -> converge with VCS regression groups (`-smoke/-stage1/-stage2/-full`) and coverage (`-cm`, functional covergroups via `-fm`). Which VCS runs the agents start on their own: ops §3 tiers.

**Sign-off rule: an oEDA PASS is necessary but never sufficient.** Convergence is signed off on VCS only. Equivalence between flows is judged by pass/fail plus coverage, never by cycle-accurate waveform comparison (randomization seed streams differ between simulators).

**Capability gaps of oEDA - re-check each at convergence time:** the limits canonized in CLAUDE.md (oEDA "Limits": functional covergroups collected on VCS only, simple constraints only, no SVA - dual-track per `.claude/rules/oeda-verilator.md`, no gate/post or DPO), plus the width-macro derivation in `.claude/rules/ral.md`.

**Local regression:** `./wsim_oeda -m <mod>` (or a regression group) selects cases exactly like `wsim` and gives the module's oEDA pass rate in `sim/oeda_result.txt` - case selection, shared builds, the build key and parallelism are canonized in CLAUDE.md (oEDA section) and `docs/ops/oeda_local_setup.md`.

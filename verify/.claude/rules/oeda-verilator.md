---
paths:
  - "**/*.sv"
  - "**/*.svh"
  - "script/gen_uvm_env.py"
  - "script/gen_uvc.py"
---

# Verilator / OPEN_EDA coding rules (canonical home)

Every SV source must compile on both flows: VCS (sign-off) and oEDA (Verilator, `+define+OPEN_EDA`). Usage and pass criteria: `verify/CLAUDE.md`; sign-off policy: `docs/memory/arch_memory.md` §5.

## Coding rules

- No `program` blocks outside an `` `ifndef OPEN_EDA `` guard (Verilator does not support them).
- Assign a vif and `uvm_config_db::set` it in ONE `initial` block — Verilator gives no ordering guarantee between initial blocks.
- Keep constraints simple; tests that need complex constraints must pass on VCS.
- Never start a comment with `verilator` (`// verilator ...` is parsed as a lint pragma → `%Error-BADVLTPRAGMA`).
- Covergroups are fine to write (Verilator parses them) but are collected on VCS only.

## Property checks are dual-tracked (user decision 2026-11-18)

- VCS side: SVA concurrent assertions / property coverage live only in `<mod>_if_pc.sv`, wholly wrapped in `` `ifndef OPEN_EDA ``.
- oEDA side: logic-equivalent procedural checks live in the monitor/scoreboard, wrapped in `` `ifdef OPEN_EDA ``; they count toward the oEDA passrate.
- Bare SVA must never appear in an unguarded file. A change on one side must be mirrored on the other (review-enforced).

## Existing `OPEN_EDA` differences (all VCS-safe)

- `tb_top_soc.sv`, `tb_top_apb_master.sv`: guard the `sdf_annotate` `program` block; `tb_top_apb_master.sv` also generates clk/rst and instantiates the DUT.
- `dump_wave.sv`: adds an FST branch.
- `top_pkg.sv`: skips `` `include "uvm_pkg.sv" `` (VCS resolves it via `-ntb_opts uvm-1.2`; Verilator compiles `$UVM_HOME/src/uvm_pkg.sv` explicitly).
- `vif_declare.sv`: vif assignment + `uvm_config_db` in one `initial`.
- The oEDA build passes `+define+UVM_NO_DPI` and does not compile UVM's `dpi/uvm_dpi.cc` (UVM-1.2 `uvm_hdl.c` has only vendor backends); the library falls back to pure-SV implementations. The project's own `dpi_func.c` is unaffected.
- These guards in generated files are defined in the `gen_uvm_env.py` templates — see `.claude/rules/generated-assembly.md`.

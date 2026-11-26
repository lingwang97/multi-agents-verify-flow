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

- A VCS/Verilator compatibility difference is isolated with `` `ifdef OPEN_EDA `` / `` `else ``: the Verilator form goes in the `OPEN_EDA` branch, the `` `else `` branch keeps the VCS form unchanged (never rewrite VCS sign-off code for Verilator's sake). Verilator versions differ in what they accept, so the guard holds even where the new form looks portable.
- No `program` blocks outside an `` `ifndef OPEN_EDA `` guard (Verilator does not support them).
- Assign a vif and `uvm_config_db::set` it in ONE `initial` block — Verilator gives no ordering guarantee between initial blocks.
- Keep constraints simple; tests that need complex constraints must pass on VCS.
- Never start a comment with `verilator` (`// verilator ...` is parsed as a lint pragma → `%Error-BADVLTPRAGMA`).
- Covergroups are fine to write (Verilator parses them) but are collected on VCS only.

## Property checks are dual-tracked

- VCS side: SVA concurrent assertions / property coverage live only in `<mod>_if_pc.sv`, wholly wrapped in `` `ifndef OPEN_EDA ``.
- oEDA side: logic-equivalent procedural checks live in the monitor/scoreboard, wrapped in `` `ifdef OPEN_EDA ``; they count toward the oEDA passrate.
- Bare SVA must never appear in an unguarded file. A change on one side must be mirrored on the other (review-enforced).

## Existing `OPEN_EDA` differences (all VCS-safe)

- `tb_top_chip.sv` and the block tops `tb_top_<mod>.sv`: guard the `sdf_annotate` `program` block; a block top also generates clk/rst; its DUT instance is hand work (port wiring through `intf/<mod>_if_conn.sv`: CLAUDE.md "Interface connection").
- `dump_wave.sv`: adds an FST branch.
- `top_pkg.sv`: skips `` `include "uvm_pkg.sv" `` (VCS resolves it via `-ntb_opts uvm-1.2`; Verilator compiles `$UVM_HOME/src/uvm_pkg.sv` explicitly).
- `vif_declare.sv`: vif assignment + `uvm_config_db` in one `initial`.
- `base_seq` / `base_test` and the block bases `<mod>_block_base_seq/_test`: `uvm_config_db #(<mod>_cfg_t)` through a class-scope typedef - Verilator (5.040) cannot parse a package-scoped type (`<mod>_pkg::<mod>_base_cfg`) as the type argument of `uvm_config_db #(...)::get/set`.
- `<mod>_monitor`: `print_monitor_status` declares `void` (Verilator rejects a function without a return type).
- The oEDA build passes `+define+UVM_NO_DPI` and does not compile UVM's `dpi/uvm_dpi.cc` (UVM-1.2 `uvm_hdl.c` has only vendor backends); the library falls back to pure-SV implementations. The project's own `dpi_func.c` is unaffected.
- These guards in generated files are defined in the `gen_uvm_env.py` templates — see `.claude/rules/generated-assembly.md`.

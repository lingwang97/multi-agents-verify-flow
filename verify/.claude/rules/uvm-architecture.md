---
paths:
  - "**/*.sv"
  - "**/*.svh"
---

# UVM architecture facts (what the code does not make obvious)

Summary + pointers live in `verify/CLAUDE.md` (Conventions: naming; Commands: usage). This file is the canon for the structural facts below; the Verilator/OPEN_EDA coding rules are `.claude/rules/oeda-verilator.md`.

- **UVC pattern**: every `uvc/<mod>/` has the `gen_uvc.py` shape (`src/`, `env/<mod>_env` + `<mod>_pkg`, `script/uvm.f`). Follow it: a new interface signal goes into `*_if.sv`, is sampled in the monitor and covered in `*_coverage.sv`.
- Agent/env/monitor/scoreboard extend `utils/base_uvc/base_*`; `drv_is_active` lives on `base_env`. Monitor/scoreboard handles are named `<mod>_monitor_h`/`<mod>_scoreboard_h` — `set_mon_checks_enable(.name("<mod>_monitor_h"), ...)` etc. depend on it.
- **Top assembly**: `env/top_env.sv` builds every `*_env`, the virtual sequencer `top_virtual_sequencer` (`env/top_vseqr.sv`) and the RAL model (`ral.set_hdl_path_root(...)`).
- **Test/sequence base**: `test/base_test.sv` / `seq/base_seq.sv` hold a handle + vif + base_cfg for every module. Reset goes in `reset_phase`, register/warm-up init in `configure_phase`, stimulus in `main_phase`. `seq/comm_<mod>_methods.sv` is `` `include ``-d inside `base_seq`'s class body.
- **Runtime toggles**: `base_cfg` objects are set in `base_test.build_phase` and randomized in `start_of_simulation_phase`; `set_<mod>_cfg_type()` does type overrides. The `utils/global_pkg.sv` arrays `MON_CHECKS_ENABLE`, `SB_CHECKS_ENABLE`, `IF_CHECKS_ENABLE`, `MON_COVERAGE_ENABLE`, `IF_COVERAGE_ENABLE` gate checks/coverage via `base_test::set_*_enable()` (`set_enable_flag_debug()` dumps them). The monitor's `cov_enable` gates only the `coverage_ap` path, not checks/scoreboard.
- The block tb top is `tb_top/tb_top/tb_top_<mod>.sv`; the module name stays `tb_top` (`` `define TB_TOP tb_top `` in `tb_define.sv`).
- **Interface connection** (block level): `tb_top_<mod>.sv` holds the interface instance and its initialization (vif + `uvm_config_db` in one `initial`), clk/rst and the DUT instance, whose ports bind only to `dut_<port>` nets. `intf/<mod>_if_conn.sv` declares those nets and connects them to the interface (Part 1 ports, Part 2 gray-box internals read hierarchically); `<mod>_if_conn_gpls.sv` is the gate/post-layout variant, selected by `GPL_SIM`. The include sits before the DUT instance. System level: `tb_top/component/if_conn.sv` includes the per-module files.

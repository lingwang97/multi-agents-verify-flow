`ifndef __SPD_PKG__SV__
`define __SPD_PKG__SV__

package spd_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import global_pkg::*;
  import reg_addr::*;
  import base_uvc_pkg::*;

  `include "spd_base_config.sv"
  `include "spd_config.sv"

  `include "spd_base_refmdl.sv"
  `include "spd_legacy_refmdl.sv"
  `include "spd_new_refmdl.sv"
  `include "spd_gbp_checker.sv"
  `include "spd_lfb_refmdl.sv"
  `include "spd_gbp_refmdl.sv"

  `include "spd_item.sv"
  `include "spd_sequence_item.sv"
  `include "spd_coverage_item.sv"
  `include "spd_sequencer.sv"
  `include "spd_driver.sv"
  `include "spd_monitor.sv"
  `include "spd_coverage.sv"
  `include "spd_scoreboard.sv"
  `include "spd_agent.sv"
  `include "spd_env.sv"

endpackage: spd_pkg

`endif //`ifndef __SPD_PKG__SV__

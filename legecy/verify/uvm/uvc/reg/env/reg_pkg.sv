`ifndef __REG_PKG__SV__
`define __REG_PKG__SV__

package reg_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import global_pkg::*;
  import reg_addr::*;
  import base_uvc_pkg::*;

  `include "reg_base_config.sv"
  `include "reg_config.sv"

  `include "reg_item.sv"
  `include "reg_sequence_item.sv"
  `include "reg_coverage_item.sv"
  `include "reg_sequencer.sv"
  `include "reg_driver.sv"
  `include "reg_monitor.sv"
  `include "reg_coverage.sv"
  `include "reg_scoreboard.sv"
  `include "reg_agent.sv"
  `include "reg_env.sv"

endpackage: reg_pkg

`endif //`ifndef __REG_PKG__SV__

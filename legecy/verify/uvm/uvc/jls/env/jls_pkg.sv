`ifndef __JLM_PKG__SV__
`define __JLM_PKG__SV__

package jls_pkg;
  //import jamlink_pkg::jamlink_sequence_item;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import global_pkg::*;
import reg_addr::*;
  import base_uvc_pkg::*;

  `include "jls_base_config.sv"
  `include "jls_config.sv"
  import jamlink_pkg::jamlink_sequence_item;
  `include "jls_item.sv"
  `include "jls_sequence_item.sv"
  `include "jls_coverage_item.sv"
   `include "reg2apb_adapter.sv"
  `include "jls_sequencer.sv"
  `include "jls_driver.sv"
  `include "jls_monitor.sv"
  `include "jls_coverage.sv"
  `include "jls_scoreboard.sv"
  `include "jls_agent.sv"
  `include "jls_env.sv"
  //`include "jamlink_sequence_item.sv"

endpackage: jls_pkg

`endif //`ifndef __JLM_PKG__SV__

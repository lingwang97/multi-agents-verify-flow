`ifndef __JAMLINK_PKG__SV__
`define __JAMLINK_PKG__SV__

package jamlink_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import global_pkg::*;
import reg_addr::*;
  import base_uvc_pkg::*;

  `include "jamlink_base_config.sv"
  `include "jamlink_config.sv"

  `include "jamlink_item.sv"
  `include "jamlink_sequence_item.sv"
  `include "jamlink_adapter.sv"
  `include "jamlink_coverage_item.sv"
  `include "jamlink_sequencer.sv"
  `include "jamlink_driver.sv"
  `include "jamlink_monitor.sv"
  `include "jamlink_coverage.sv"
  `include "jamlink_scoreboard.sv"
  `include "jamlink_agent.sv"
  `include "jamlink_env.sv"

endpackage: jamlink_pkg

`endif //`ifndef __JAMLINK_PKG__SV__

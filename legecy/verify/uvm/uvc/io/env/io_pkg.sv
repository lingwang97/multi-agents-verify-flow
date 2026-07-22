`ifndef __IO_PKG__SV__
`define __IO_PKG__SV__

package io_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import global_pkg::*;
import reg_addr::*;
  import base_uvc_pkg::*;

  `include "io_base_config.sv"
  `include "io_config.sv"

  `include "io_item.sv"
  `include "io_sequence_item.sv"
  `include "io_coverage_item.sv"
  `include "io_sequencer.sv"
  `include "io_driver.sv"
  `include "io_monitor.sv"
  `include "io_coverage.sv"
  `include "io_scoreboard.sv"
  `include "io_agent.sv"
  `include "io_env.sv"

endpackage: io_pkg

`endif //`ifndef __IO_PKG__SV__

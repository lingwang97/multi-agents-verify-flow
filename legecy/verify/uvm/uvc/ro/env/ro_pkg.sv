`ifndef __RO_PKG__SV__
`define __RO_PKG__SV__

package ro_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import global_pkg::*;
import reg_addr::*;
  import base_uvc_pkg::*;

  typedef class ro_callback;
  typedef class ro_scoreboard;

  typedef uvm_callbacks#(ro_scoreboard, ro_callback) ro_scb_pool;


  `include "ro_callback.sv"

  `include "ro_base_config.sv"
  `include "ro_config.sv"

  `include "ro_item.sv"
  `include "ro_sequence_item.sv"
  `include "ro_coverage_item.sv"
  `include "ro_sequencer.sv"
  `include "ro_driver.sv"
  `include "ro_monitor.sv"
  `include "ro_coverage.sv"
  `include "ro_scoreboard.sv"
  `include "ro_agent.sv"
  `include "ro_env.sv"

endpackage: ro_pkg

`endif //`ifndef __RO_PKG__SV__

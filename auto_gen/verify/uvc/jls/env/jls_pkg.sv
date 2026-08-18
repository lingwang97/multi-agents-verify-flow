`ifndef __JLS_PKG__SV__
`define __JLS_PKG__SV__
package jls_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
import global_pkg::*;
//import reg_addr::*;   //USE YOUR REG DEFINE PKG IF YOU HAS ONE
import base_uvc_pkg::*;

`include "jls_base_cfg.sv"
`include "jls_cfg.sv"
`include "jls_item.sv"
`include "jls_sequence_item.sv"
`include "jls_coverage_item.sv"
`include "jls_sequencer.sv"
`include "jls_driver.sv"
`include "jls_monitor.sv"
`include "jls_scoreboard.sv"
`include "jls_coverage.sv"
`include "jls_agent.sv"
`include "jls_env.sv"
`include "jls_reg2apb_adapter.sv"


endpackage : jls_pkg
`endif //`ifndef __JLS_PKG__SV__

`ifndef __CPFT_PKG__SV__
`define __CPFT_PKG__SV__
package cpft_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
import global_pkg::*;
//import reg_addr::*;   //USE YOUR REG DEFINE PKG IF YOU HAS ONE
import base_uvc_pkg::*;

`include "cpft_base_cfg.sv"
`include "cpft_cfg.sv"
`include "cpft_item.sv"
`include "cpft_sequence_item.sv"
`include "cpft_coverage_item.sv"
`include "cpft_sequencer.sv"
`include "cpft_driver.sv"
`include "cpft_monitor.sv"
`include "cpft_scoreboard.sv"
`include "cpft_coverage.sv"
`include "cpft_agent.sv"
`include "cpft_env.sv"



endpackage : cpft_pkg
`endif //`ifndef __CPFT_PKG__SV__

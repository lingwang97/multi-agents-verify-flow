`ifndef __RO_PKG__SV__
`define __RO_PKG__SV__
package ro_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
import global_pkg::*;
//import reg_addr::*;   //USE YOUR REG DEFINE PKG IF YOU HAS ONE
import base_uvc_pkg::*;

`include "ro_base_cfg.sv"
`include "ro_cfg.sv"
`include "ro_item.sv"
`include "ro_sequence_item.sv"
`include "ro_coverage_item.sv"
`include "ro_sequencer.sv"
`include "ro_driver.sv"
`include "ro_monitor.sv"
`include "ro_scoreboard.sv"
`include "ro_coverage.sv"
`include "ro_agent.sv"
`include "ro_env.sv"



endpackage : ro_pkg
`endif //`ifndef __RO_PKG__SV__

`ifndef __APB_MASTER_PKG__SV__
`define __APB_MASTER_PKG__SV__
package apb_master_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
import global_pkg::*;
//import reg_addr::*;   //USE YOUR REG DEFINE PKG IF YOU HAS ONE
import base_uvc_pkg::*;

`include "apb_master_base_cfg.sv"
`include "apb_master_cfg.sv"
`include "apb_master_item.sv"
`include "apb_master_sequence_item.sv"
`include "apb_master_coverage_item.sv"
`include "apb_master_sequencer.sv"
`include "apb_master_driver.sv"
`include "apb_master_monitor.sv"
`include "apb_master_scoreboard.sv"
`include "apb_master_coverage.sv"
`include "apb_master_agent.sv"
`include "apb_master_env.sv"



endpackage : apb_master_pkg
`endif //`ifndef __APB_MASTER_PKG__SV__

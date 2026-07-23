`ifndef __EFUSE_PKG__SV__
`define __EFUSE_PKG__SV__
package efuse_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
import global_pkg::*;
//import reg_addr::*;   //USE YOUR REG DEFINE PKG IF YOU HAS ONE
import base_uvc_pkg::*;

`include "efuse_base_cfg.sv"
`include "efuse_cfg.sv"
`include "efuse_item.sv"
`include "efuse_sequence_item.sv"
`include "efuse_coverage_item.sv"
`include "efuse_sequencer.sv"
`include "efuse_driver.sv"
`include "efuse_monitor.sv"
`include "efuse_scoreboard.sv"
`include "efuse_coverage.sv"
`include "efuse_agent.sv"
`include "efuse_env.sv"
`include "efuse_reg2apb_adapter.sv"


endpackage : efuse_pkg
`endif //`ifndef __EFUSE_PKG__SV__

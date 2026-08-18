`ifndef __UART_PKG__SV__
`define __UART_PKG__SV__
package uart_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
import global_pkg::*;
//import reg_addr::*;   //USE YOUR REG DEFINE PKG IF YOU HAS ONE
import base_uvc_pkg::*;

`include "uart_base_cfg.sv"
`include "uart_cfg.sv"
`include "uart_item.sv"
`include "uart_sequence_item.sv"
`include "uart_coverage_item.sv"
`include "uart_sequencer.sv"
`include "uart_driver.sv"
`include "uart_monitor.sv"
`include "uart_scoreboard.sv"
`include "uart_coverage.sv"
`include "uart_agent.sv"
`include "uart_env.sv"
`include "uart_reg2uart_adapter.sv"


endpackage : uart_pkg
`endif //`ifndef __UART_PKG__SV__

`ifndef __UART_VIP_PKG__SV__
`define __UART_VIP_PKG__SV__

`include "uvm_macros.svh"
`include "uvm_pkg.sv"
`include "svt_uart.uvm.pkg"

package uart_vip_pkg;
  import uvm_pkg::*;
  import reg_addr::*;
  import global_pkg::*;
  import svt_uvm_pkg::*;
  import svt_uart_uvm_pkg::*;
  import base_uvc_pkg::*;

  `include "/project/SG/public/UART_VIP_R2021/src/sverilog/vcs/svt_uart_configuration.sv"
  `include "../src/cust_svt_uart_agent_configuration.sv"
  `include "../src/cust_svt_uart_transaction.sv"
  //`include "../vip/src/sverilog/vcs/svt_uart_reg_adapter.sv"
  `include "/project/SG/public/UART_VIP_R2021/src/sverilog/vcs/svt_uart_transaction.sv"

  `include "cust_uart_monitor.sv"
  `include "svt_uart_reg_adapter.sv"
  //`include "../../../seq/uart_seq.sv"
  `include "uart_vip_env.sv"
endpackage: uart_vip_pkg

`endif

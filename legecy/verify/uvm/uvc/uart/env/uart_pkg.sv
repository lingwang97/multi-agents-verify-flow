`ifndef __UART_PKG__SV__
`define __UART_PKG__SV__

package uart_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import global_pkg::*;
  import reg_addr::*;
  import base_uvc_pkg::*;

  `include "uart_base_config.sv"
  `include "uart_config.sv"

  `include "uart_item.sv"
  `include "uart_sequence_item.sv"

  import reg_pkg::reg_item;
  `include "uart_adapter.sv"
  `include "uart_coverage_item.sv"
  `include "uart_sequencer.sv"
  `include "uart_driver.sv"
  `include "uart_check_err_driver.sv"
  `include "uart_rx_timeout_driver.sv"
  `include "uart_monitor.sv"
  `include "uart_coverage.sv"
  `include "uart_scoreboard.sv"
  `include "uart_agent.sv"
  `include "uart_env.sv"

endpackage: uart_pkg

`endif //`ifndef __UART_PKG__SV__

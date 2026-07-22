
`ifndef __TOP_PKG__SV__
`define __TOP_PKG__SV__

`include "uvm_macros.svh"
`include "uvm_pkg.sv"
`ifdef VIP
`include "svt_uart.uvm.pkg"
`endif

package top_pkg;
  import uvm_pkg::*;
`ifdef VIP
  `include "uvm_macros.svh"
  import svt_uvm_pkg::*;
  import svt_uart_uvm_pkg::*;
  import uart_vip_pkg::*;
`endif
  import global_pkg::*;
  import reg_addr::*;
  import base_uvc_pkg::*;
  import ro_pkg::*;
  import mx2_pkg::*;
  import cpm_pkg::*;
  import pvt_pkg::*;
  import rst_pkg::*;
  import btc_pkg::*;
  import selfclk_pkg::*;
  import work_ctrl_pkg::*;
  import mc_pkg::*;
  import io_pkg::*;
  import efuse_pkg::*;
  import jamlink_pkg::*;
  import jls_pkg::*;
  import dfx_pkg::*;
  import cpft_pkg::*;
  import spd_pkg::*;
  import ft_pkg::*;
  import reg_pkg::*;
  import uart_pkg::*;

  `include "fpga_sequence_item.sv"
  `include "fpga_sequencer.sv"
  `ifdef VIP
  `include "cust_svt_uart_transaction.sv"
  `include "cust_svt_uart_agent_configuration.sv"
  `endif
  `include "top_vseqr.sv"
  //`include "top_if.sv"
  //`include "ro_if.sv"
  `include "top_env.sv"
  `include "btc_sequence_lib.sv"  

  `include "rst_vseq.sv"

  `include "base_test.sv"
  `include "cpm_test.sv"
`ifdef USE_RAL_MODEL
`ifndef VIP
  `include "fpga_test.sv"
`endif
  `include "mc_test.sv"
  `include "rst_new_test.sv"
  `include "jls_test.sv"
  `include "pvt_test.sv"
  `include "efuse_test.sv"
  `include "spd_test.sv"
  `include "spd_gbp_test.sv"
  `include "spd_lfb_test.sv"
  `include "io_test.sv"
  `include "cpft_new_test.sv"
  `include "reg_test.sv"
  `include "ro_test.sv"
  `include "mx2_test.sv"
  `include "dfx_test.sv"
  `include "work_ctrl_new_test.sv"
  `include "ft_new_test.sv"
  //`include "selfclk_test.sv"
  `include "uart_test.sv"
  `include "uart_vip_test.sv"
  `include "selftop_test.sv"

`endif

endpackage: top_pkg

`endif //`ifndef __TOP_PKG__SV__

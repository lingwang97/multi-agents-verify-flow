`ifndef __TOP_PKG__SV__
`define __TOP_PKG__SV__

`include "uvm_macros.svh"
`ifndef VERILATOR
`include "uvm_pkg.sv"
`endif

package top_pkg;
  import uvm_pkg::*;
  import global_pkg::*;
  //import reg_addr::*;         //USE YOUR REG DEFINE PKG IF YOU HAS ONE
  import base_uvc_pkg::*;

  //import all module pkg
  import reg_pkg::*;
  import apb_master_pkg::*;
  import ro_pkg::*;
  import uart_pkg::*;
  import efuse_pkg::*;

  //add VIP-relative pkg begin


  //add VIP-relative pkg end

  `include "top_vseqr.sv"
  `include "top_env.sv"
  `include "soc_sequence_lib.sv"
  

  //include all module test
  `include "base_test.sv"
  `include "reg_test.sv"
  `include "apb_master_test.sv"
  `include "ro_test.sv"
  `include "uart_test.sv"
  `include "efuse_test.sv"

  //add VIP-relative test begin

  //add VIP-relative test end

  


endpackage: top_pkg
`endif //`ifndef __TOP_PKG__SV__

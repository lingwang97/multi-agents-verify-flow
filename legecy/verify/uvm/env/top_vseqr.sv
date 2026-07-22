
`ifndef __TOP_VIRTUAL_SEQUENCER__SVH__
`define __TOP_VIRTUAL_SEQUENCER__SVH__

class top_virtual_sequencer extends uvm_sequencer;

  // references to the subsequencers on which the virtual sequences
  // will coordinate the activity
  RAL_PKG::ral_gen_main 	ral;
  ro_sequencer    ro_seqr_h;
  mx2_sequencer      mx2_seqr_h;
  spd_sequencer      spd_seqr_h;
  ft_sequencer       ft_seqr_h;
  cpm_sequencer      cpm_seqr_h; 
  pvt_sequencer      pvt_seqr_h;
  rst_sequencer      rst_seqr_h;
  mc_sequencer       mc_seqr_h;
  io_sequencer       io_seqr_h;
  dfx_sequencer      dfx_seqr_h;
  cpft_sequencer     cpft_seqr_h;
  efuse_sequencer    efuse_seqr_h;
  jamlink_sequencer  jamlink_seqr_h;
  `ifdef VIP
  svt_uart_transaction_sequencer     uart_vip_seqr_h;
  `endif

  uart_sequencer  uart_seqr_h;
  jls_sequencer      jls_seqr_h;
  reg_sequencer      reg_seqr_h;
  fpga_sequencer      fpga_seqr_h; 
  work_ctrl_sequencer    work_ctrl_seqr_h;
  selfclk_sequencer   selfclk_seqr_h;
  //----------------- Chip configuration object-------------------------

  //UVM automation macros for sequencers
  `uvm_component_utils_begin(top_virtual_sequencer)
    `uvm_field_object(ro_seqr_h, UVM_ALL_ON)
    `uvm_field_object(mx2_seqr_h, UVM_ALL_ON)
    `uvm_field_object(spd_seqr_h, UVM_ALL_ON)
    `uvm_field_object(ft_seqr_h, UVM_ALL_ON)
    `uvm_field_object(cpm_seqr_h, UVM_ALL_ON)
    `uvm_field_object(pvt_seqr_h, UVM_ALL_ON)
    `uvm_field_object(rst_seqr_h, UVM_ALL_ON)
    `uvm_field_object(mc_seqr_h, UVM_ALL_ON)
    `uvm_field_object(jls_seqr_h, UVM_ALL_ON)
    `uvm_field_object(jamlink_seqr_h, UVM_ALL_ON)

    `ifdef VIP
    `uvm_field_object(uart_vip_seqr_h, UVM_ALL_ON)
    `endif

    `uvm_field_object(uart_seqr_h, UVM_ALL_ON)

    `uvm_field_object(efuse_seqr_h, UVM_ALL_ON)
    `uvm_field_object(io_seqr_h, UVM_ALL_ON)
    `uvm_field_object(dfx_seqr_h, UVM_ALL_ON)
    `uvm_field_object(cpft_seqr_h, UVM_ALL_ON)
    `uvm_field_object(reg_seqr_h, UVM_ALL_ON)
    `uvm_field_object(fpga_seqr_h, UVM_ALL_ON)
    `uvm_field_object(work_ctrl_seqr_h, UVM_ALL_ON)
    `uvm_field_object(selfclk_seqr_h, UVM_ALL_ON)


  `uvm_component_utils_end

  // constructor
  function new(string name = "top_virtual_sequencer", uvm_component parent = null);
    super.new(name, parent);

  endfunction : new

endclass

`endif // __TOP_VIRTUAL_SEQUENCER__SVH__

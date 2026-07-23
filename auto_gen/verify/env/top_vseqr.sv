`ifndef __TOP_VIRTUAL_SEQUENCER__SVH__
`define __TOP_VIRTUAL_SEQUENCER__SVH__

class top_virtual_sequencer extends uvm_sequencer;

  //Control subsequences for convenient coordination and management

  // instance register model object
  RAL_PKG::ral_gen_main 	ral;
  // module squencer declaration
  reg_sequencer		reg_seqr_h;
  jls_sequencer		jls_seqr_h;
  cpft_sequencer		cpft_seqr_h;
  uart_sequencer		uart_seqr_h;
  efuse_sequencer		efuse_seqr_h;
  
  //UVM automation macros for sequencers
  `uvm_component_utils_begin(top_virtual_sequencer)
    `uvm_field_object(reg_seqr_h, UVM_ALL_ON)
    `uvm_field_object(jls_seqr_h, UVM_ALL_ON)
    `uvm_field_object(cpft_seqr_h, UVM_ALL_ON)
    `uvm_field_object(uart_seqr_h, UVM_ALL_ON)
    `uvm_field_object(efuse_seqr_h, UVM_ALL_ON)
  `uvm_component_utils_end


  // constructor
  function new(string name = "top_virtual_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

endclass
`endif // __TOP_VIRTUAL_SEQUENCER__SVH__

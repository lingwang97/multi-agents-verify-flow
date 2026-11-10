`ifndef __APB_MASTER_SEQUENCER__SVH__
`define __APB_MASTER_SEQUENCER__SVH__

class apb_master_sequencer extends uvm_sequencer#(apb_master_sequence_item);

  `uvm_component_utils(apb_master_sequencer)

  apb_master_sequence_item apb_master_seq_item_h;
  
  function new (string name = "apb_master_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new

endclass: apb_master_sequencer
`endif

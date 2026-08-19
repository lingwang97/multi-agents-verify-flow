`ifndef __EFUSE_SEQUENCER__SVH__
`define __EFUSE_SEQUENCER__SVH__

class efuse_sequencer extends uvm_sequencer#(efuse_sequence_item);

  `uvm_component_utils(efuse_sequencer)

  efuse_sequence_item efuse_seq_item_h;
  
  function new (string name = "efuse_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new

endclass: efuse_sequencer
`endif

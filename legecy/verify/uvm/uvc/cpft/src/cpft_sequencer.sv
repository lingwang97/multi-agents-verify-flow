`ifndef __CPFT_SEQUENCER__SVH__
`define __CPFT_SEQUENCER__SVH__

class cpft_sequencer extends uvm_sequencer#(cpft_sequence_item);

  `uvm_component_utils(cpft_sequencer)

  cpft_sequence_item   cpft_seq_item_h;
  function new (string name = "cpft_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
endclass: cpft_sequencer
`endif //`ifndef __CPFT_SEQUENCER__SVH__

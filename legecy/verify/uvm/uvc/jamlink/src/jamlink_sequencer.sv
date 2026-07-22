`ifndef __JAMLINK_SEQUENCER__SVH__
`define __JAMLINK_SEQUENCER__SVH__

class jamlink_sequencer extends uvm_sequencer#(jamlink_sequence_item);

  `uvm_component_utils(jamlink_sequencer)

  jamlink_sequence_item   jamlink_seq_item_h;
  function new (string name = "jamlink_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
endclass: jamlink_sequencer
`endif //`ifndef __JAMLINK_SEQUENCER__SVH__

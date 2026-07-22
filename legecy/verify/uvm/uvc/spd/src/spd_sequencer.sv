`ifndef __SPD_SEQUENCER__SVH__
`define __SPD_SEQUENCER__SVH__

class spd_sequencer extends uvm_sequencer#(spd_sequence_item);

  `uvm_component_utils(spd_sequencer)

  spd_sequence_item   spd_seq_item_h;
  function new (string name = "spd_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
endclass: spd_sequencer
`endif //`ifndef __SPD_SEQUENCER__SVH__

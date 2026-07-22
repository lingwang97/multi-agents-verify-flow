`ifndef __RO_SEQUENCER__SVH__
`define __RO_SEQUENCER__SVH__

class ro_sequencer extends uvm_sequencer#(ro_sequence_item);

  `uvm_component_utils(ro_sequencer)

  ro_sequence_item   ro_seq_item_h;
  function new (string name = "ro_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
endclass: ro_sequencer
`endif //`ifndef __RO_SEQUENCER__SVH__

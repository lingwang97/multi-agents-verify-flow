`ifndef __REG_SEQUENCER__SVH__
`define __REG_SEQUENCER__SVH__

class reg_sequencer extends uvm_sequencer#(reg_sequence_item);

  `uvm_component_utils(reg_sequencer)

  reg_sequence_item   reg_seq_item_h;
  function new (string name = "reg_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
endclass: reg_sequencer
`endif //`ifndef __REG_SEQUENCER__SVH__

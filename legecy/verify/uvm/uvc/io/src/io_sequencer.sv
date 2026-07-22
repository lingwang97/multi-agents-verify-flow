`ifndef __IO_SEQUENCER__SVH__
`define __IO_SEQUENCER__SVH__

class io_sequencer extends uvm_sequencer#(io_sequence_item);

  `uvm_component_utils(io_sequencer)

  io_sequence_item   io_seq_item_h;
  function new (string name = "io_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
endclass: io_sequencer
`endif //`ifndef __IO_SEQUENCER__SVH__

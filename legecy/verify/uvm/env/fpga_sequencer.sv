`ifndef __FPGA_SEQUENCER__SVH__
`define __FPGA_SEQUENCER__SVH__

class fpga_sequencer extends uvm_sequencer#(fpga_sequence_item);

  `uvm_component_utils(fpga_sequencer)

  fpga_sequence_item   fpga_seq_item_h;
  function new (string name = "fpga_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
endclass: fpga_sequencer
`endif //`ifndef __FPGA_SEQUENCER__SVH__

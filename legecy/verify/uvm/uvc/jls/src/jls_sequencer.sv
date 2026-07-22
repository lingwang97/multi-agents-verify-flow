`ifndef __JLM_SEQUENCER__SVH__
`define __JLM_SEQUENCER__SVH__

class jls_sequencer extends uvm_sequencer#(jls_sequence_item);

  `uvm_component_utils(jls_sequencer)

  jls_sequence_item   jls_seq_item_h;
`ifdef USE_RAL_MODEL
  RAL_PKG::ral_gen_main 	ral;
`endif
  function new (string name = "jls_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
endclass: jls_sequencer
`endif //`ifndef __JLM_SEQUENCER__SVH__

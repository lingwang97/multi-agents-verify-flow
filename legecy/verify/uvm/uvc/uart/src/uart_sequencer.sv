`ifndef __UART_SEQUENCER__SVH__
`define __UART_SEQUENCER__SVH__

class uart_sequencer extends uvm_sequencer#(uart_sequence_item);

  `uvm_component_utils(uart_sequencer)

  uart_sequence_item   uart_seq_item_h;
  function new (string name = "uart_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction: new
endclass: uart_sequencer
`endif //`ifndef __UART_SEQUENCER__SVH__

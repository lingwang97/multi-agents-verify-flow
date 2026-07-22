
`ifndef UART_RX_TIMEOUT_DRIVER
`define UART_RX_TIMEOUT_DRIVER
// ------------------------------------------------------------
// trigger err driver
// ------------------------------------------------------------
//class uart_rx_timeout_23_driver extends uart_driver;
class uart_rx_timeout_23_driver extends uart_custom_driver;
  `uvm_component_utils(uart_rx_timeout_23_driver);

  function new(string name="uart_rx_timeout_23_driver" , uvm_component parent=null);
    super.new(name , parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction :build_phase


   task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask:run_phase

// send 2,3 byte packet with a break
task trans_frame (input logic [39:0] wdata);
    trans_packet(wdata[7:0]);
    trans_packet(wdata[15:8]);
      insert_packet_nidles(this.packet_nidles);
    trans_packet(wdata[23:16]);
    trans_packet(wdata[31:24]);
    trans_packet(wdata[39:32]);
      // insert a break in last frame, so that next cmd will not be affected
      insert_packet_nidles(this.packet_nidles);

    `uvm_info(get_type_name(), $sformatf("[UART] trans frame done %h",wdata), UVM_MEDIUM)
  endtask:trans_frame

endclass:uart_rx_timeout_23_driver


class uart_rx_timeout_14_driver extends uart_custom_driver;
  `uvm_component_utils(uart_rx_timeout_14_driver);

  function new(string name="uart_rx_timeout_14_driver" , uvm_component parent=null);
    super.new(name , parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction :build_phase


   task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask:run_phase


// send 1,4 byte packet with a break
  task trans_frame (input logic [39:0] wdata);
    trans_packet(wdata[7:0]);
      insert_packet_nidles(this.packet_nidles);
    trans_packet(wdata[15:8]);
    trans_packet(wdata[23:16]);
    trans_packet(wdata[31:24]);
    trans_packet(wdata[39:32]);
      insert_packet_nidles(this.packet_nidles);

    `uvm_info(get_type_name(), $sformatf("[UART] trans frame done %h",wdata), UVM_MEDIUM)
  endtask

endclass:uart_rx_timeout_14_driver




`endif //`ifndef UART_RX_TIMEOUT_DRIVER

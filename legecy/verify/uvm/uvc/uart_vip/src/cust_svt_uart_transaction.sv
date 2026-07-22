
`ifndef GUARD_CUST_SVT_UART_TRANSACTION_SV
`define GUARD_CUST_SVT_UART_TRANSACTION_SV

/** 
 * Abstract:
 * This file defines a class that represents a customized transaction class 
 * which is extended from svt_uart_transaction class. This extended class
 * adds constraint reasonable_packet_count on packet_count
 */
class cust_svt_uart_transaction extends svt_uart_transaction ;

  /* Variables to control the number of packets to be transferred */
  int pkt_count_low_wt  = 80; 
  int pkt_count_med_wt  = 10; 
  int pkt_count_high_wt = 10; 
 
  rand logic[31:0] addr;
  //rand logic[31:0] data;
  rand logic[`UVM_REG_DATA_WIDTH-1:0] data;
  rand logic [1:0] mode;
  rand logic we;

  rand logic [7:0] chipaddr = 0;
  rand logic [7:0] tranlen = 0;
  rand logic [7:0] baud;

  bit [31:0] data_frame[];

  /** 
   * UVM object utility macro which implements the create() and get_type_name() methods. 
   * Field macros registeration provides default implementation of utility functions, 
   * print() & copy().
   */
  `uvm_object_utils_begin(cust_svt_uart_transaction)
    `uvm_field_int(pkt_count_low_wt ,UVM_PRINT | UVM_COPY)
    `uvm_field_int(pkt_count_med_wt ,UVM_PRINT | UVM_COPY)
    `uvm_field_int(pkt_count_high_wt,UVM_PRINT | UVM_COPY)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(we, UVM_ALL_ON)
    `uvm_field_int(mode, UVM_ALL_ON)
    `uvm_field_int(chipaddr, UVM_ALL_ON)
    `uvm_field_int(tranlen, UVM_ALL_ON)
    `uvm_field_int(baud, UVM_ALL_ON)

    `uvm_field_array_int(data_frame, UVM_ALL_ON)

  `uvm_object_utils_end

  /**
   * Declare user-defined constraints
   */
  //constraint reasonable_packet_count {
  //  packet_count dist { [1:40]  := pkt_count_low_wt,
  //                      20 := pkt_count_med_wt,
  //                      30 := pkt_count_high_wt };
  //}

  constraint reasonable_delay {
    delay_cts == 0;
    delay_rts == 0;
    buffer_flush_delay == 0;
    inter_cycle_delay  == 0;
  }

  /** Class constructor */
  function new(string name ="cust_svt_uart_transaction" );
    super.new(name);
  endfunction: new

endclass: cust_svt_uart_transaction
`endif // GUARD_CUST_SVT_UART_TRANSACTION_SV
 

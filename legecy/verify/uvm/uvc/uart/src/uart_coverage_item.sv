typedef enum {LOW, MEDIUM, HIGH} baud_kind;


class uart_coverage_item extends uvm_sequence_item;

  // used for messaging purposes
  string report_id = "uart_coverage_item";
  int i;

  int card_sel;
  

  logic[31:0] addr;
  logic[31:0] data;
  logic       we;

  logic [1:0] mode;
  //logic [7:0] chipaddr;
  logic [9:0] chipaddr;

  logic [7:0] tranlen ;
  //logic [7:0] baud;
  baud_kind baud;
  int    frame_nidles;
  int    packet_nidles;




  // registering the properties of this object
  `uvm_object_utils_begin(uart_coverage_item)
    `uvm_field_int(card_sel, UVM_ALL_ON)

    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(we, UVM_ALL_ON)
    `uvm_field_int(mode, UVM_ALL_ON)
    `uvm_field_int(chipaddr, UVM_ALL_ON)
    `uvm_field_int(tranlen, UVM_ALL_ON)
    `uvm_field_int(frame_nidles, UVM_ALL_ON)
    `uvm_field_int(packet_nidles, UVM_ALL_ON)

    `uvm_field_enum(baud_kind, baud, UVM_ALL_ON)
  `uvm_object_utils_end

  // constructor
  function new(string name="uart_coverage_item");
    begin
    super.new(name);
    card_sel = 0;
    end
  endfunction : new

  // prints this class properties,
  // used when error is encountered
  virtual function void do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_object("UART_SEQUENCE_ITEM:", this);
  endfunction

endclass : uart_coverage_item


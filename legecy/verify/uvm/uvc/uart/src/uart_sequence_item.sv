class uart_sequence_item extends uvm_sequence_item;

  // used for messaging purposes
  string report_id = "uart_sequence_item";
  int i;

//  int card_sel;

  rand logic[31:0] addr;
  rand logic[31:0] data;
  rand logic we;

  rand logic [1:0] mode;
  rand logic [9:0] chipaddr ;

//  rand logic [7:0] tranlen = 0;
  rand logic [7:0] tranlen;

  rand logic [7:0] baud;

  rand bit[9:0] chip_start_id = 0;
  rand bit    chiplast_cfg = 0;
  rand bit    chiplast_en;

  rand int    frame_nidles;
  rand int    packet_nidles;
  rand bit    err_trigger;
  int         cnt = 0;
   
  rand bit[7:0]    packet;
  rand logic[31:0] reg_fifo[254:0][379:0];

  // registering the properties of this object
  `uvm_object_utils_begin(uart_sequence_item)

    `uvm_field_int(cnt, UVM_ALL_ON)
    `uvm_field_int(mode, UVM_ALL_ON)
    `uvm_field_int(we, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(chipaddr, UVM_ALL_ON)
    `uvm_field_int(tranlen, UVM_ALL_ON)
    `uvm_field_int(baud, UVM_ALL_ON)
    `uvm_field_int(chip_start_id, UVM_ALL_ON)
    `uvm_field_int(chiplast_en, UVM_ALL_ON)
    `uvm_field_int(chiplast_cfg, UVM_ALL_ON)
    `uvm_field_int(frame_nidles, UVM_ALL_ON|UVM_NOPRINT)
    `uvm_field_int(packet_nidles, UVM_ALL_ON|UVM_NOPRINT)
    `uvm_field_int(err_trigger, UVM_ALL_ON|UVM_NOPRINT)
    `uvm_field_int(packet, UVM_ALL_ON|UVM_NOPRINT)

  `uvm_object_utils_end

  // constructor
  function new(string name="uart_sequence_item");
    begin
    super.new(name);
//    card_sel = 0;
    end
  endfunction : new

  // prints this class properties,
  // used when error is encountered
  virtual function void do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_object("UART_SEQUENCE_ITEM:", this);
  endfunction


  /////////////////////////////////////
  // Constraints
  /////////////////////////////////////

  constraint basic_cstr{
    soft  tranlen     == 'h1; 
    soft  chipaddr    == 0;
    soft  chip_start_id == 0;
    soft  chiplast_cfg  == 0;
  }
    
  constraint err_trig_cstr{
    soft err_trigger    == 'h0; 
    soft frame_nidles   == 'h0; 
    soft packet_nidles  == 'h0; 
  }


endclass : uart_sequence_item



class uart_init_packet extends uart_sequence_item;
  // registering the properties of this object
  uart_sequence_item   	tr;
  `uvm_object_utils_begin(uart_init_packet)
  `uvm_object_utils_end

  // constructor
  function new(string name="uart_init_packet");
    super.new(name);
  endfunction : new
endclass




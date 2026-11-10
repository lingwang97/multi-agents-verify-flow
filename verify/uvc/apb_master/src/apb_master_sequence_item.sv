class apb_master_sequence_item extends uvm_sequence_item;

  string report_id = "apb_master_sequence_item";
  
  int card_sel;
  logic [31:0] addr;
  logic [31:0] data;
  logic we;
  logic [31:0] prdata;
  logic pslverr;


  // registering the properties of this object
  `uvm_object_utils_begin(apb_master_sequence_item)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(we, UVM_ALL_ON)
    `uvm_field_int(card_sel, UVM_ALL_ON)
    `uvm_field_int(prdata, UVM_ALL_ON)
    `uvm_field_int(pslverr, UVM_ALL_ON)
  `uvm_object_utils_end

  // constructor
  function new(string name="apb_master_sequence_item");
    super.new(name);
    addr = 0;
    data = 0;
    we = 0;
    card_sel = 0;
    prdata = 0;
    pslverr = 0;
  endfunction : new

  // prints this class properties,used when error is encountered
  virtual function void do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_object("APB_MASTER_SEQUENCE_ITEM:", this);
  endfunction

endclass : apb_master_sequence_item

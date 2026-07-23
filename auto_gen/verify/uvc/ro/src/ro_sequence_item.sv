class ro_sequence_item extends uvm_sequence_item;

  string report_id = "ro_sequence_item";
  
  int card_sel;
  logic [31:0] addr;
  logic [31:0] data;
  logic we;
  

  // registering the properties of this object
  `uvm_object_utils_begin(ro_sequence_item)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(we, UVM_ALL_ON)
    `uvm_field_int(card_sel, UVM_ALL_ON)
  `uvm_object_utils_end

  // constructor
  function new(string name="ro_sequence_item");
    super.new(name);
    addr = 0;
    data = 0;
    we = 0;
    card_sel = 0;
  endfunction : new

  // prints this class properties,used when error is encountered
  virtual function void do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_object("RO_SEQUENCE_ITEM:", this);
  endfunction

endclass : ro_sequence_item

class jls_item extends uvm_object;

  // used for messaging purposes
  string report_id = "jls_item";
  int i;

  int card_sel;
  logic[31:0] addr;
  logic[31:0] data;  
  bit we;
  
  
  // registering the properties of this object
  `uvm_object_utils_begin(jls_item)
    //`uvm_field_int(card_sel, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(we, UVM_ALL_ON)

  `uvm_object_utils_end

  // constructor
  function new(string name="jls_item");
    begin
    super.new(name);
    card_sel = 0;
    end
  endfunction : new

  // prints this class properties,
  // used when error is encountered
  virtual function void do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_object("JLM_ITEM:", this);
  endfunction

endclass : jls_item


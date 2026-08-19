class jls_item extends uvm_object;

  // used for messaging purposes between components (MON2SCB,Etc..)
  string report_id = "jls_item";

  int card_sel;

  // registering the properties of this object
  `uvm_object_utils_begin(jls_item)
    `uvm_field_int(card_sel, UVM_ALL_ON)
  `uvm_object_utils_end

  // constructor
  function new(string name="jls_item");
    super.new(name);
    card_sel = 0;
  endfunction : new

  // prints this class properties,used when error is encountered
  virtual function void do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_object("JLS_ITEM:", this);
  endfunction

endclass : jls_item

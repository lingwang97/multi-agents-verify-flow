class jls_coverage_item extends uvm_object;

  // Used to collect coverage messages
  string report_id = "jls_coverage_item";

  int card_sel;
  bit[31:0] jls_ctrl;

  // registering the properties of this object
  `uvm_object_utils_begin(jls_coverage_item)
    `uvm_field_int(card_sel, UVM_ALL_ON)
    `uvm_field_int(jls_ctrl, UVM_ALL_ON)
  `uvm_object_utils_end

  // constructor
  function new(string name="jls_coverage_item");
    super.new(name);
    card_sel = 0;
    jls_ctrl = 0;
  endfunction : new

  // prints this class properties,used when error is encountered
  virtual function void do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_object("JLS_COVERAGE_ITEM:", this);
  endfunction

endclass : jls_coverage_item

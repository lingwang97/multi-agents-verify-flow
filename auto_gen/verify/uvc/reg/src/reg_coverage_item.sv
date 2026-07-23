class reg_coverage_item extends uvm_object;

  // Used to collect coverage messages
  string report_id = "reg_coverage_item";

  int card_sel;
  bit[31:0] reg_ctrl;

  // registering the properties of this object
  `uvm_object_utils_begin(reg_coverage_item)
    `uvm_field_int(card_sel, UVM_ALL_ON)
    `uvm_field_int(reg_ctrl, UVM_ALL_ON)
  `uvm_object_utils_end

  // constructor
  function new(string name="reg_coverage_item");
    super.new(name);
    card_sel = 0;
    reg_ctrl = 0;
  endfunction : new

  // prints this class properties,used when error is encountered
  virtual function void do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_object("REG_COVERAGE_ITEM:", this);
  endfunction

endclass : reg_coverage_item

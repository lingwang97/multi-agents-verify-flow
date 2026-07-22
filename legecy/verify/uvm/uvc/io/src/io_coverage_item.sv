class io_coverage_item extends uvm_object;

  // used for messaging purposes
  string report_id = "io_coverage_item";
  int i;

  int card_sel;
  bit [3:0] io_ctrl1;
  bit [3:0] io_ctrl2;

  // registering the properties of this object
  `uvm_object_utils_begin(io_coverage_item)

    `uvm_field_int(card_sel, UVM_ALL_ON)
    `uvm_field_int(io_ctrl1, UVM_ALL_ON)
    `uvm_field_int(io_ctrl2, UVM_ALL_ON)

  `uvm_object_utils_end

  // constructor
  function new(string name="io_coverage_item");
    begin
    super.new(name);
    card_sel = 0;
    io_ctrl1 = 0;
    io_ctrl2 = 0;
    end
  endfunction : new

  // prints this class properties,
  // used when error is encountered
  virtual function void do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_object("IO_SEQUENCE_ITEM:", this);
  endfunction

endclass : io_coverage_item


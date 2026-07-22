class spd_coverage_item extends uvm_object;

  // used for messaging purposes
  string report_id = "spd_coverage_item";
  int i;

  int card_sel;

  // registering the properties of this object
  `uvm_object_utils_begin(spd_coverage_item)

    `uvm_field_int(card_sel, UVM_ALL_ON)

  `uvm_object_utils_end

  // constructor
  function new(string name="spd_coverage_item");
    begin
    super.new(name);
    card_sel = 0;
    end
  endfunction : new

  // prints this class properties,
  // used when error is encountered
  virtual function void do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_object("SPD_SEQUENCE_ITEM:", this);
  endfunction

endclass : spd_coverage_item


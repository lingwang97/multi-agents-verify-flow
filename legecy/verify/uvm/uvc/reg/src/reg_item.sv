class reg_item extends uvm_object;

  // used for messaging purposes
  string report_id = "reg_item";
  int         cnt;
  bit         we;
  bit [31:0]  addr;
  bit [31:0]  data;

  //int card_sel;

  // registering the properties of this object
  `uvm_object_utils_begin(reg_item)
    //`uvm_field_int(card_sel, UVM_ALL_ON)
    `uvm_field_int(cnt, UVM_ALL_ON)
    `uvm_field_int(we, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)

  `uvm_object_utils_end

  // constructor
  function new(string name="reg_item");
    begin
    super.new(name);
    //card_sel = 0;
    end
  endfunction : new

  // prints this class properties,
  // used when error is encountered
  virtual function void do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_object("REG_ITEM:", this);
  endfunction

endclass : reg_item


class reg_sequence_item extends uvm_sequence_item;

  // used for messaging purposes
  string report_id = "reg_sequence_item";
  int i;
  //rand uvm_reg_data_t reg_data;
  int card_sel;

  // registering the properties of this object
  `uvm_object_utils_begin(reg_sequence_item)

    `uvm_field_int(card_sel, UVM_ALL_ON)
    //`uvm_field_int(reg_data, UVM_ALL_ON)

  `uvm_object_utils_end

  // constructor
  function new(string name="reg_sequence_item");
    begin
    super.new(name);
    card_sel = 0;
    end
  endfunction : new

  // prints this class properties,
  // used when error is encountered
  virtual function void do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_object("REG_SEQUENCE_ITEM:", this);
  endfunction



endclass : reg_sequence_item


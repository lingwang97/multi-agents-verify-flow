class ro_item extends uvm_sequence_item;

  // used for messaging purposes
  string report_id = "ro_item";
  int i;
  int        	card_sel;

  logic [1:0] 	div_num;
  int        	ro_num;
  int        	ro_inst;
  logic [5:0] 	ro_sel;
  logic [15:0] 	ro_dataout;


  // registering the properties of this object
  `uvm_object_utils_begin(ro_item)

    `uvm_field_int(div_num, UVM_ALL_ON)
    `uvm_field_int(ro_num, UVM_ALL_ON)
    `uvm_field_int(ro_inst, UVM_ALL_ON)
    `uvm_field_int(ro_sel, UVM_ALL_ON)
    `uvm_field_int(ro_dataout, UVM_ALL_ON)

  `uvm_object_utils_end

  // constructor
  function new(string name="ro_item");
    begin
    super.new(name);
    card_sel = 0;

    end
  endfunction : new

  // prints this class properties,
  // used when error is encountered
  virtual function void do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_object("RO_SEQUENCE_ITEM:", this);
  endfunction

endclass : ro_item



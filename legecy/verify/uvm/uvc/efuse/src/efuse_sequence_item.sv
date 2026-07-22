class efuse_sequence_item extends uvm_sequence_item;

  // used for messaging purposes
  string report_id = "efuse_sequence_item";
  int i;

  int card_sel;
  logic[31:0] data;
  logic[31:0] addr;
  logic we;


  // registering the properties of this object
  `uvm_object_utils_begin(efuse_sequence_item)

    `uvm_field_int(card_sel, UVM_ALL_ON)

  `uvm_object_utils_end

  // constructor
  function new(string name="efuse_sequence_item");
    begin
    super.new(name);
    card_sel = 0;
    we = 0;
    data = 0;
    addr = 0;
    end
  endfunction : new

  // prints this class properties,
  // used when error is encountered
  virtual function void do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_object("EFUSE_SEQUENCE_ITEM:", this);
  endfunction

endclass : efuse_sequence_item


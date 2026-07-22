class jamlink_sequence_item extends uvm_sequence_item;

  // used for messaging purposes
  string report_id = "jamlink_sequence_item";
  int i;

  int card_sel;

	rand logic[31:0] addr;
	rand logic[31:0] data;
	logic [5:0] mode_t;
    logic [7:0] chipaddr;
    logic       needdly;
    logic [9:0] tranlen;

	rand logic we;
	rand int delay;

  logic [31:0] len;
  logic head;


  // registering the properties of this object
  `uvm_object_utils_begin(jamlink_sequence_item)

    `uvm_field_int(card_sel, UVM_ALL_ON)

  `uvm_object_utils_end

  // constructor
  function new(string name="jamlink_sequence_item");
    begin
    super.new(name);
    card_sel = 0;
    end
  endfunction : new

  // prints this class properties,
  // used when error is encountered
  virtual function void do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_object("JAMLINK_SEQUENCE_ITEM:", this);
  endfunction

endclass : jamlink_sequence_item


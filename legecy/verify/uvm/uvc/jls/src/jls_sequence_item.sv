class jls_sequence_item extends uvm_sequence_item;
  `uvm_object_utils(jls_sequence_item)
  // used for messaging purposes
  string report_id = "jls_sequence_item";
  int i;
  
  int card_sel;

//------------------------------------------
// Data Members (Outputs rand, inputs non-rand)
//------------------------------------------
	rand logic[31:0] addr;
	rand logic[31:0] data;
	rand logic we;
	rand int delay;

//------------------------------------------
// Constraints
//------------------------------------------
	constraint addr_alignment {
  		addr[1:0] == 0;
	}


  // constructor
  function new(string name="jls_sequence_item");
    begin
    super.new(name);
    card_sel = 0;
    end
  endfunction : new

  // prints this class properties,
  // used when error is encountered
  virtual function void do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_object("JLM_SEQUENCE_ITEM:", this);
  endfunction

endclass : jls_sequence_item


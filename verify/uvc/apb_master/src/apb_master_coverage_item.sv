class apb_master_coverage_item extends uvm_object;

  // Used to collect coverage messages
  string report_id = "apb_master_coverage_item";

  int card_sel;
  bit[31:0] apb_master_ctrl;
  bit [31:0] addr;
  bit [31:0] wdata;
  bit [31:0] rdata;
  bit we;
  bit pslverr;
  int unsigned wait_cycles;

  // registering the properties of this object
  `uvm_object_utils_begin(apb_master_coverage_item)
    `uvm_field_int(card_sel, UVM_ALL_ON)
    `uvm_field_int(apb_master_ctrl, UVM_ALL_ON)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(wdata, UVM_ALL_ON)
    `uvm_field_int(rdata, UVM_ALL_ON)
    `uvm_field_int(we, UVM_ALL_ON)
    `uvm_field_int(pslverr, UVM_ALL_ON)
    `uvm_field_int(wait_cycles, UVM_ALL_ON)
  `uvm_object_utils_end

  // constructor
  function new(string name="apb_master_coverage_item");
    super.new(name);
    card_sel = 0;
    apb_master_ctrl = 0;
    addr = 0;
    wdata = 0;
    rdata = 0;
    we = 0;
    pslverr = 0;
    wait_cycles = 0;
  endfunction : new

  // prints this class properties,used when error is encountered
  virtual function void do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_object("APB_MASTER_COVERAGE_ITEM:", this);
  endfunction

endclass : apb_master_coverage_item

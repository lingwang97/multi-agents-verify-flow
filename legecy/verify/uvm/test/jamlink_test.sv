
//`ifndef __JAMLINK_TEST__
//`define __JAMLINK_TEST__
class jamlink_base_test extends base_test;

string report_id = "jamlink_base_test";
  // automation macro
  `uvm_component_utils_begin(jamlink_base_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "jamlink_base_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);

  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
   super.main_phase(phase);
  endtask



endclass : jamlink_base_test


class jamlink_ecc_inject_test extends jamlink_base_test;

string report_id = "jamlink_ecc_inject_test"; 
  // automation macro
  `uvm_component_utils_begin(jamlink_ecc_inject_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "jamlink_ecc_inject_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   jamlink_ecc_inject_seq   seq;

   phase.raise_objection(this);

   seq = jamlink_ecc_inject_seq::type_id::create("jamlink_ecc_inject_seq");
   seq.start(vseqr_h.jamlink_seqr_h);
   phase.drop_objection(this);

  endtask



endclass : jamlink_ecc_inject_test

class jamlink_ecc_test_test extends jamlink_base_test;

string report_id = "jamlink_ecc_test_test"; 
  // automation macro
  `uvm_component_utils_begin(jamlink_ecc_test_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "jamlink_ecc_test_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   jamlink_ecc_test_seq   seq;

   phase.raise_objection(this);

   seq = jamlink_ecc_test_seq::type_id::create("jamlink_ecc_test_seq");
   seq.start(vseqr_h.jamlink_seqr_h);
   phase.drop_objection(this);

  endtask



endclass : jamlink_ecc_test_test

class jamlink_fsm_inject_test extends jamlink_base_test;

string report_id = "jamlink_fsm_inject_test"; 
  // automation macro
  `uvm_component_utils_begin(jamlink_fsm_inject_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "jamlink_fsm_inject_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   jamlink_fsm_inject_seq   seq;

   phase.raise_objection(this);

   seq = jamlink_fsm_inject_seq::type_id::create("jamlink_fsm_inject_seq");
   seq.start(vseqr_h.jamlink_seqr_h);
   phase.drop_objection(this);

  endtask



endclass : jamlink_fsm_inject_test

//`endif //`ifndef __JAMLINK_TEST__

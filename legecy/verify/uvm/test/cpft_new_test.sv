class cpft_new_base_test extends base_test;

string report_id = "cpft_new_base_test";
  // automation macro
  `uvm_component_utils_begin(cpft_new_base_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "cpft_new_base_test",uvm_component parent);
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

endclass : cpft_new_base_test

class cpft_init_ral_test extends cpft_new_base_test;

string report_id = "cpft_init_ral_test"; 
  // automation macro
  `uvm_component_utils_begin(cpft_init_ral_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "cpft_init_ral_test",uvm_component parent);
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
   cpft_init_ral_seq   seq;

   phase.raise_objection(this);

   seq = cpft_init_ral_seq::type_id::create("cpft_init_ral_seq");
   seq.start(vseqr_h.cpft_seqr_h);
   phase.drop_objection(this);

  endtask

endclass : cpft_init_ral_test

///////////////////////////////////////////////////////////////////////////////
/////////////////////////////    RO test    ///////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

class cpft_lvro_ral_test extends cpft_new_base_test;

string report_id = "cpft_lvro_ral_test"; 
  // automation macro
  `uvm_component_utils_begin(cpft_lvro_ral_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "cpft_lvro_ral_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   cpft_lvro_ral_seq   seq;

   phase.raise_objection(this);

   seq = cpft_lvro_ral_seq::type_id::create("cpft_lvro_ral_seq");
   seq.start(vseqr_h.cpft_seqr_h);
   phase.drop_objection(this);

  endtask

endclass : cpft_lvro_ral_test

///////////////////////////////////////////////////////////////////////////////
///////////////////////////// VTsensor test ///////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
class cpft_ts_ral_test extends cpft_new_base_test;

string report_id = "cpft_ts_ral_test"; 
  // automation macro
  `uvm_component_utils_begin(cpft_ts_ral_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "cpft_ts_ral_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   cpft_ts_ral_seq   seq;

   phase.raise_objection(this);

   seq = cpft_ts_ral_seq::type_id::create("cpft_ts_ral_seq");
   seq.start(vseqr_h.cpft_seqr_h);
   phase.drop_objection(this);

  endtask

endclass : cpft_ts_ral_test

class cpft_vs_ral_test extends cpft_new_base_test;

string report_id = "cpft_vs_ral_test"; 
  // automation macro
  `uvm_component_utils_begin(cpft_vs_ral_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "cpft_vs_ral_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   cpft_vs_ral_seq   seq;

   phase.raise_objection(this);

   seq = cpft_vs_ral_seq::type_id::create("cpft_vs_ral_seq");
   seq.start(vseqr_h.cpft_seqr_h);
   phase.drop_objection(this);

  endtask

endclass : cpft_vs_ral_test

///////////////////////////////////////////////////////////////////////////////
//////////////////////////////// Efuse test ///////////////////////////////////
///////////////////////////////////////////////////////////////////////////////
class cpft_efuse_normal_ral_test extends cpft_new_base_test;

string report_id = "cpft_efuse_normal_ral_test"; 
  // automation macro
  `uvm_component_utils_begin(cpft_efuse_normal_ral_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "cpft_efuse_normal_ral_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   cpft_efuse_normal_ral_seq   seq;

   phase.raise_objection(this);

   seq = cpft_efuse_normal_ral_seq::type_id::create("cpft_efuse_normal_ral_seq");
   seq.start(vseqr_h.cpft_seqr_h);
   phase.drop_objection(this);

  endtask

endclass : cpft_efuse_normal_ral_test
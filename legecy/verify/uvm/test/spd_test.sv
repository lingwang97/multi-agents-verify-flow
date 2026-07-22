
//`ifndef __SPD_TEST__
//`define __SPD_TEST__
class spd_base_test extends base_test;

string report_id = "spd_base_test";
  // automation macro
  `uvm_component_utils_begin(spd_base_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_base_test",uvm_component parent);
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



endclass : spd_base_test

`ifdef USE_RAL_MODEL

class spd_bitmap_test extends spd_base_test;

    string report_id = "spd_bitmap_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_bitmap_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_bitmap_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    `ifdef LOW_MIDCLK
    set_cpm_cfg_type("cpm_low_mux2_config");
    `endif
    super.build_phase(phase);
    
  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   spd_bitmap_seq   seq;

   phase.raise_objection(this);

   seq = spd_bitmap_seq::type_id::create("spd_bitmap_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

  endtask
endclass



class spd_fake_pantern_test extends spd_base_test;

string report_id = "spd_fake_pantern_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_fake_pantern_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_fake_pantern_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    super.build_phase(phase);
    
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);
    //int rd_data;
   logic [7:0] rd_data, exp_data; 
   spd_fake_pantern_seq   seq;

   phase.raise_objection(this);

   seq = spd_fake_pantern_seq::type_id::create("spd_fake_pantern_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

endtask
endclass : spd_fake_pantern_test


class spd_plltable_pantern_test extends spd_base_test;

string report_id = "spd_plltable_pantern_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_plltable_pantern_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_plltable_pantern_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    super.build_phase(phase);
    
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);
    //int rd_data;
   logic [7:0] rd_data, exp_data; 
   spd_plltable_pantern_seq   seq;

   phase.raise_objection(this);

   seq = spd_plltable_pantern_seq::type_id::create("spd_plltable_pantern_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

endtask
endclass : spd_plltable_pantern_test


class spd_passcnt_pantern_test extends spd_base_test;

string report_id = "spd_passcnt_pantern_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_passcnt_pantern_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_passcnt_pantern_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    super.build_phase(phase);
    
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);
    //int rd_data;
   logic [7:0] rd_data, exp_data; 
   spd_passcnt_pantern_seq   seq;

   phase.raise_objection(this);

   seq = spd_passcnt_pantern_seq::type_id::create("spd_passcnt_pantern_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

endtask
endclass : spd_passcnt_pantern_test


class spd_thms_test extends spd_base_test;

string report_id = "spd_thms_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_thms_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_thms_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    super.build_phase(phase);
    
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);
    //int rd_data;
   logic [7:0] rd_data, exp_data; 
   spd_thms_seq   seq;

   phase.raise_objection(this);

   seq = spd_thms_seq::type_id::create("spd_thms_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

endtask
endclass : spd_thms_test


class spd_fakecore_pantern_test extends spd_base_test;

string report_id = "spd_fakecore_pantern_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_fakecore_pantern_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_fakecore_pantern_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    super.build_phase(phase);
    
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);
    //int rd_data;
   logic [7:0] rd_data, exp_data; 
   spd_fakecore_pantern_seq   seq;

   phase.raise_objection(this);

   seq = spd_fakecore_pantern_seq::type_id::create("spd_fakecore_pantern_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

endtask
endclass : spd_fakecore_pantern_test


class spd_passfail_test extends spd_base_test;

string report_id = "spd_passfail_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_passfail_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_passfail_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    super.build_phase(phase);
    
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);
    //int rd_data;
   logic [7:0] rd_data, exp_data; 
   spd_passfail_seq   seq;

   phase.raise_objection(this);

   seq = spd_passfail_seq::type_id::create("spd_passfail_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

endtask
endclass : spd_passfail_test

class spd_initpass_test extends spd_base_test;

string report_id = "spd_initpass_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_initpass_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_initpass_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    super.build_phase(phase);
    
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);
    //int rd_data;
   logic [7:0] rd_data, exp_data; 
   spd_initpass_seq   seq;

   phase.raise_objection(this);

   seq = spd_initpass_seq::type_id::create("spd_initpass_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

endtask
endclass : spd_initpass_test

class spd_initfail_test extends spd_base_test;

string report_id = "spd_initfail_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_initfail_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_initfail_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    super.build_phase(phase);
    
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);
    //int rd_data;
   logic [7:0] rd_data, exp_data; 
   spd_initfail_seq   seq;

   phase.raise_objection(this);

   seq = spd_initfail_seq::type_id::create("spd_initfail_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

endtask
endclass : spd_initfail_test

class spd_initfail_realcore_test extends spd_base_test;

string report_id = "spd_initfail_realcore_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_initfail_realcore_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_initfail_realcore_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    super.build_phase(phase);
    
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);
    //int rd_data;
   logic [7:0] rd_data, exp_data; 
   spd_initfail_realcore_seq   seq;

   phase.raise_objection(this);

   seq = spd_initfail_realcore_seq::type_id::create("spd_initfail_realcore_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

endtask
endclass : spd_initfail_realcore_test

class spd_pllcnt_pantern_test extends spd_base_test;

string report_id = "spd_pllcnt_pantern_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_pllcnt_pantern_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_pllcnt_pantern_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    super.build_phase(phase);
    
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);
    //int rd_data;
   logic [7:0] rd_data, exp_data; 
   spd_pllcnt_pantern_seq   seq;

   phase.raise_objection(this);

   seq = spd_pllcnt_pantern_seq::type_id::create("spd_pllcnt_pantern_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

endtask
endclass : spd_pllcnt_pantern_test


class spd_spdtimer_pantern_test extends spd_base_test;

string report_id = "spd_spdtimer_pantern_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_spdtimer_pantern_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_spdtimer_pantern_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    super.build_phase(phase);
    
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);
    //int rd_data;
   logic [7:0] rd_data, exp_data; 
   spd_spdtimer_pantern_seq   seq;

   phase.raise_objection(this);

   seq = spd_spdtimer_pantern_seq::type_id::create("spd_spdtimer_pantern_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

endtask
endclass : spd_spdtimer_pantern_test


class spd_trig_pass_timer_test extends spd_base_test;

string report_id = "spd_trig_pass_timer_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_trig_pass_timer_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_trig_pass_timer_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    super.build_phase(phase);
    
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);
    //int rd_data;
   logic [7:0] rd_data, exp_data; 
   spd_trig_pass_timer_seq   seq;

   phase.raise_objection(this);

   seq = spd_trig_pass_timer_seq::type_id::create("spd_trig_pass_timer_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

endtask
endclass : spd_trig_pass_timer_test

























//################################################## New Model ########################################












class spd_fake_pantern_ss_test extends spd_base_test;

string report_id = "spd_fake_pantern_ss_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_fake_pantern_ss_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_fake_pantern_ss_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    `ifdef LOW_MIDCLK
    set_cpm_cfg_type("cpm_low_mux2_config");
    `endif
    super.build_phase(phase);
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);
    //int rd_data;
   logic [7:0] rd_data, exp_data; 
   spd_fake_pantern_ss_seq   seq;

   phase.raise_objection(this);

   seq = spd_fake_pantern_ss_seq::type_id::create("spd_fake_pantern_ss_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

endtask
endclass : spd_fake_pantern_ss_test





class spd_tinycore_ss_test extends spd_base_test;

string report_id = "spd_tinycore_ss_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_tinycore_ss_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_tinycore_ss_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    super.build_phase(phase);
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);
    //int rd_data;
   logic [7:0] rd_data, exp_data; 
   spd_tinycore_ss_seq   seq;

   phase.raise_objection(this);

   seq = spd_tinycore_ss_seq::type_id::create("spd_tinycore_ss_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

endtask
endclass : spd_tinycore_ss_test


class spd_spdlog_test extends spd_base_test;

string report_id = "spd_spdlog_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_spdlog_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_spdlog_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    `ifdef LOW_MIDCLK
    set_cpm_cfg_type("cpm_low_mux2_config");
    `endif
    super.build_phase(phase);
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);
    //int rd_data;
   logic [7:0] rd_data, exp_data; 
   spd_spdlog_seq   seq;

   phase.raise_objection(this);

   seq = spd_spdlog_seq::type_id::create("spd_spdlog_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

endtask
endclass : spd_spdlog_test


class spd_ssdn_test extends spd_base_test;

string report_id = "spd_ssdn_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_ssdn_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_ssdn_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    `ifdef LOW_MIDCLK
    set_cpm_cfg_type("cpm_low_mux2_config");
    `endif
    super.build_phase(phase);
  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   spd_ssdn_seq   seq;

   phase.raise_objection(this);

   seq = spd_ssdn_seq::type_id::create("spd_ssdn_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

  endtask
  
endclass : spd_ssdn_test


class spd_ssdn_refmodel_test extends spd_base_test;

string report_id = "spd_ssdn_refmodel_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_ssdn_refmodel_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_ssdn_refmodel_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    `ifdef LOW_MIDCLK
    set_cpm_cfg_type("cpm_low_mux2_config");
    `endif
    super.build_phase(phase);
  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   spd_ssdn_refmodel_seq   seq;

   phase.raise_objection(this);

   seq = spd_ssdn_refmodel_seq::type_id::create("spd_ssdn_refmodel_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

  endtask
  
endclass : spd_ssdn_refmodel_test


class spd_spdsel_test extends spd_base_test;

string report_id = "spd_spdsel_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_spdsel_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_spdsel_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    `ifdef LOW_MIDCLK
    set_cpm_cfg_type("cpm_low_mux2_config");
    `endif
    super.build_phase(phase);
  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   spd_spdsel_seq   seq;

   phase.raise_objection(this);

   seq = spd_spdsel_seq::type_id::create("spd_spdsel_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

  endtask
  
endclass : spd_spdsel_test

class spd_spdpri_test extends spd_base_test;

string report_id = "spd_spdpri_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_spdpri_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_spdpri_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    `ifdef LOW_MIDCLK
    set_cpm_cfg_type("cpm_low_mux2_config");
    `endif
    super.build_phase(phase);
  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   spd_spdpri_seq   seq;

   phase.raise_objection(this);

   seq = spd_spdpri_seq::type_id::create("spd_spdpri_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

  endtask
  
endclass : spd_spdpri_test




class spd_glb_limit_test extends spd_base_test;

string report_id = "spd_glb_limit_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_glb_limit_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_glb_limit_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    `ifdef LOW_MIDCLK
    set_cpm_cfg_type("cpm_low_mux2_config");
    `endif
    super.build_phase(phase);
  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   spd_glb_limit_seq   seq;

   phase.raise_objection(this);

   seq = spd_glb_limit_seq::type_id::create("spd_glb_limit_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

  endtask
  
endclass : spd_glb_limit_test


class spd_glb_limit_refmodel_test extends spd_base_test;

string report_id = "spd_glb_limit_refmodel_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_glb_limit_refmodel_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_glb_limit_refmodel_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    `ifdef LOW_MIDCLK
    set_cpm_cfg_type("cpm_low_mux2_config");
    `endif
    super.build_phase(phase);
  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   spd_glb_limit_refmodel_seq   seq;

   phase.raise_objection(this);

   seq = spd_glb_limit_refmodel_seq::type_id::create("spd_glb_limit_refmodel_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

  endtask
  
endclass : spd_glb_limit_refmodel_test


class spd_all_core_gate_test extends spd_base_test;

string report_id = "spd_all_core_gate_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_all_core_gate_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_all_core_gate_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    `ifdef LOW_MIDCLK
    set_cpm_cfg_type("cpm_low_mux2_config");
    `endif
    super.build_phase(phase);
  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   spd_all_core_gate_seq   seq;

   phase.raise_objection(this);

   seq = spd_all_core_gate_seq::type_id::create("spd_all_core_gate_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

  endtask
  
endclass : spd_all_core_gate_test


class spd_work_spdcore_test extends spd_base_test;

string report_id = "spd_work_spdcore_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_work_spdcore_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_work_spdcore_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    `ifdef LOW_MIDCLK
    set_cpm_cfg_type("cpm_low_mux2_config");
    `endif
    super.build_phase(phase);
  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   spd_work_spdcore_seq   seq;

   phase.raise_objection(this);

   seq = spd_work_spdcore_seq::type_id::create("spd_work_spdcore_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

  endtask
  
endclass : spd_work_spdcore_test


class spd_pllcnt_check_test extends spd_base_test;

string report_id = "spd_pllcnt_check_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_pllcnt_check_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_pllcnt_check_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    `ifdef LOW_MIDCLK
    set_cpm_cfg_type("cpm_low_mux2_config");
    `endif
    super.build_phase(phase);
  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   spd_pllcnt_check_seq   seq;

   phase.raise_objection(this);

   seq = spd_pllcnt_check_seq::type_id::create("spd_pllcnt_check_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

  endtask
  
endclass : spd_pllcnt_check_test

class spd_fake_pantern_ss_low_freq_test extends spd_base_test;

string report_id = "spd_fake_pantern_ss_low_freq_test"; 
  // automation macro
  `uvm_component_utils_begin(spd_fake_pantern_ss_low_freq_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "spd_fake_pantern_ss_low_freq_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    set_cpm_cfg_type("cpm_mux2_config");
    `ifdef LOW_MIDCLK
    set_cpm_cfg_type("cpm_low_mux2_config");
    `endif
    super.build_phase(phase);
  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   spd_fake_pantern_ss_low_freq_seq   seq;

   phase.raise_objection(this);

   seq = spd_fake_pantern_ss_low_freq_seq::type_id::create("spd_fake_pantern_ss_low_freq_seq");
   seq.start(vseqr_h.spd_seqr_h);
   phase.drop_objection(this);

  endtask
  
endclass : spd_fake_pantern_ss_low_freq_test

`endif

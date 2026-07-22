
//`ifndef __EFUSE_TEST__
//`define __EFUSE_TEST__
class efuse_base_test extends base_test;

string report_id = "efuse_base_test";
  // automation macro
  `uvm_component_utils_begin(efuse_base_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "efuse_base_test",uvm_component parent);
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



endclass : efuse_base_test

class efuse_access_test extends efuse_base_test;

string report_id = "efuse_access_test"; 
  // automation macro
  `uvm_component_utils_begin(efuse_access_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "efuse_access_test",uvm_component parent);
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
   efuse_access_seq   seq;

   phase.raise_objection(this);

   seq = efuse_access_seq::type_id::create("efuse_access_seq");
   seq.start(vseqr_h.efuse_seqr_h);
   phase.drop_objection(this);

  endtask

endclass : efuse_access_test

class efuse_strobe_timer_rst_test extends efuse_base_test;

string report_id = "efuse_strobe_timer_rst_test"; 
  // automation macro
  `uvm_component_utils_begin(efuse_strobe_timer_rst_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "efuse_strobe_timer_rst_test",uvm_component parent);
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
   efuse_strobe_timer_rst_seq   seq;

   phase.raise_objection(this);

   seq = efuse_strobe_timer_rst_seq::type_id::create("efuse_strobe_timer_rst_seq");
   seq.start(vseqr_h.efuse_seqr_h);
   phase.drop_objection(this);

  endtask

endclass : efuse_strobe_timer_rst_test


class efuse_xlck_gate_test extends efuse_base_test;

string report_id = "efuse_xlck_gate_test"; 
  // automation macro
  `uvm_component_utils_begin(efuse_xlck_gate_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "efuse_xlck_gate_test",uvm_component parent);
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
   efuse_xlck_gate_seq   seq;

   phase.raise_objection(this);

   seq = efuse_xlck_gate_seq::type_id::create("efuse_xlck_gate_seq");
   seq.start(vseqr_h.efuse_seqr_h);
   phase.drop_objection(this);

  endtask

endclass : efuse_xlck_gate_test

class efuse_access_redundancy_line_test extends efuse_base_test;

string report_id = "efuse_access_redundancy_line_test"; 
  // automation macro
  `uvm_component_utils_begin(efuse_access_redundancy_line_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "efuse_access_redundancy_line_test",uvm_component parent);
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
   efuse_access_redundancy_line_seq   seq;

   phase.raise_objection(this);

   seq = efuse_access_redundancy_line_seq::type_id::create("efuse_access_redundancy_line_seq");
   seq.start(vseqr_h.efuse_seqr_h);
   phase.drop_objection(this);

  endtask

endclass : efuse_access_redundancy_line_test


class efuse_access_test_row_col_test extends efuse_base_test;

string report_id = "efuse_access_test_row_col_test"; 
  // automation macro
  `uvm_component_utils_begin(efuse_access_test_row_col_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "efuse_access_test_row_col_test",uvm_component parent);
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
   efuse_access_test_row_col_seq   seq;

   phase.raise_objection(this);

   seq = efuse_access_test_row_col_seq::type_id::create("efuse_access_test_row_col_seq");
   seq.start(vseqr_h.efuse_seqr_h);
   phase.drop_objection(this);

  endtask

endclass : efuse_access_test_row_col_test


class efuse_access_line_continuous_test extends efuse_base_test;

string report_id = "efuse_access_line_continuous_test"; 
  // automation macro
  `uvm_component_utils_begin(efuse_access_line_continuous_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "efuse_access_line_continuous_test",uvm_component parent);
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
   efuse_access_line_continuous_seq   seq;

   phase.raise_objection(this);

   seq = efuse_access_line_continuous_seq::type_id::create("efuse_access_line_continuous_seq");
   seq.start(vseqr_h.efuse_seqr_h);
   phase.drop_objection(this);

  endtask

endclass : efuse_access_line_continuous_test


class efuse_access_with_strobetimer_test extends efuse_base_test;

string report_id = "efuse_access_with_strobetimer_test"; 
  // automation macro
  `uvm_component_utils_begin(efuse_access_with_strobetimer_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "efuse_access_with_strobetimer_test",uvm_component parent);
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
   efuse_access_with_strobetimer_seq   seq;

   phase.raise_objection(this);

   seq = efuse_access_with_strobetimer_seq::type_id::create("efuse_access_with_strobetimer_seq");
   seq.start(vseqr_h.efuse_seqr_h);
   phase.drop_objection(this);

  endtask

endclass : efuse_access_with_strobetimer_test


class efuse_access_with_strobe_switch_test extends efuse_base_test;

string report_id = "efuse_access_with_strobe_switch_test"; 
  // automation macro
  `uvm_component_utils_begin(efuse_access_with_strobe_switch_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "efuse_access_with_strobe_switch_test",uvm_component parent);
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
   efuse_access_with_strobe_switch_seq   seq;

   phase.raise_objection(this);

   seq = efuse_access_with_strobe_switch_seq::type_id::create("efuse_access_with_strobe_switch_seq");
   seq.start(vseqr_h.efuse_seqr_h);
   phase.drop_objection(this);

  endtask

endclass : efuse_access_with_strobe_switch_test


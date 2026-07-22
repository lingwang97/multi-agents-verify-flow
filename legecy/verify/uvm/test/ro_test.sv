
/////////////////////////////////////////////
//
//  using uvm ral test cases
//
////////////////////////////////////////////
class ro_new_base_test extends base_test;

string report_id = "ro_new_base_test";
  // automation macro
  `uvm_component_utils_begin(ro_new_base_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "ro_new_base_test",uvm_component parent);
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

endclass : ro_new_base_test



class ro_ral_divclk_lvro_test extends ro_new_base_test;

string report_id = "ro_ral_divclk_lvro_test"; 
  // automation macro
  `uvm_component_utils_begin(ro_ral_divclk_lvro_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "ro_ral_divclk_lvro_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);
  
  endfunction: build_phase

  task run_phase(uvm_phase phase);

	if($test$plusargs("FORCE_CPM_CLK"))begin

		uvm_objection phase_over;
		phase.raise_objection(this);

		for(int i=0;i<`CHIP_NUM;i++)begin
			uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.crg.clk_ctrl",i), 1'b1);
			uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.crg.trunk_clk",i), {`PLL_NUM{1'b1}});
		end
   		`uvm_info(get_type_name(), $sformatf("[Force Signals] \n\n\t*******************************\n\tThis case force cpm.clk_comm/cpm.trunk_clk for speed-up !!! \n\t*******************************\n\n"), UVM_MEDIUM)

    	phase.drop_objection(this);
	end

  endtask


   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   ro_ral_divclk_lvro_seq   seq;

   phase.raise_objection(this);

   seq = ro_ral_divclk_lvro_seq::type_id::create("ro_ral_divclk_lvro_seq");
   seq.start(vseqr_h.ro_seqr_h);
   phase.drop_objection(this);

  endtask

endclass : ro_ral_divclk_lvro_test





class ro_ral_clock_gate_test extends ro_new_base_test;

  string report_id = "ro_ral_clock_gate_test"; 
  // automation macro
  `uvm_component_utils_begin(ro_ral_clock_gate_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "ro_ral_clock_gate_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);
  
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   ro_ral_clock_gate_seq   seq;

   phase.raise_objection(this);

   seq = ro_ral_clock_gate_seq::type_id::create("ro_ral_clock_gate_seq");
   seq.start(vseqr_h.ro_seqr_h);
   phase.drop_objection(this);

  endtask

endclass : ro_ral_clock_gate_test


class ro_ral_ro_reg_test extends ro_new_base_test;

  string report_id = "ro_ral_ro_reg_test"; 
  // automation macro
  `uvm_component_utils_begin(ro_ral_ro_reg_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "ro_ral_ro_reg_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);
  
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   ro_ral_ro_reg_seq   seq;

   phase.raise_objection(this);

   seq = ro_ral_ro_reg_seq::type_id::create("ro_ral_ro_reg_seq");
   seq.start(vseqr_h.ro_seqr_h);
   phase.drop_objection(this);

  endtask

endclass : ro_ral_ro_reg_test


class ro_ral_fastsim_lvro_test extends ro_new_base_test;

  string report_id = "ro_ral_fastsim_lvro_test"; 
  // automation macro
  `uvm_component_utils_begin(ro_ral_fastsim_lvro_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "ro_ral_fastsim_lvro_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);
  
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    uvm_objection phase_over;
    phase.raise_objection(this);

	for(int i=0;i<`CHIP_NUM;i++)begin
		uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.crg.clk_ctrl",i), 1'b1);
		uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.crg.trunk_clk",i), {`PLL_NUM{1'b1}});
	end

   `uvm_info(get_type_name(), $sformatf("[Force Signals] \n\n\t*******************************\n\tThis case force cpm.clk_comm/cpm.trunk_clk for speed-up !!! \n\t*******************************\n\n"), UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   ro_ral_divclk_lvro_seq   seq;

   phase.raise_objection(this);

   seq = ro_ral_divclk_lvro_seq::type_id::create("ro_ral_divclk_lvro_seq");
   seq.start(vseqr_h.ro_seqr_h);
   phase.drop_objection(this);

  endtask

endclass : ro_ral_fastsim_lvro_test


class ro_ral_lvro_smoke_test extends ro_new_base_test;

  string report_id = "ro_ral_lvro_smoke_test"; 
  // automation macro
  `uvm_component_utils_begin(ro_ral_lvro_smoke_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "ro_ral_lvro_smoke_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);
  
  endfunction: build_phase

	task run_phase(uvm_phase phase);

		if($test$plusargs("FORCE_CPM_CLK"))begin

			uvm_objection phase_over;
			phase.raise_objection(this);

			for(int i=0;i<`CHIP_NUM;i++)begin
				uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.crg.clk_ctrl",i), 1'b1);
				uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.crg.trunk_clk",i), {`PLL_NUM{1'b1}});
			end
			`uvm_info(get_type_name(), $sformatf("[Force Signals] \n\n\t*******************************\n\tThis case force cpm.clk_comm/cpm.trunk_clk for speed-up !!! \n\t*******************************\n\n"), UVM_MEDIUM)

			phase.drop_objection(this);
		end

	endtask

   task main_phase(uvm_phase phase);
    //int rd_data;
   logic [7:0] rd_data, exp_data;
   ro_ral_lvro_smoke_seq   seq;

   phase.raise_objection(this);

   seq = ro_ral_lvro_smoke_seq::type_id::create("ro_ral_lvro_smoke_seq");
   seq.start(vseqr_h.ro_seqr_h);
   phase.drop_objection(this);

  endtask

endclass : ro_ral_lvro_smoke_test


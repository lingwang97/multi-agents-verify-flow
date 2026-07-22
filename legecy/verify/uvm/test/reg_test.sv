
//`ifndef __REG_TEST__
//`define __REG_TEST__
class reg_base_test extends base_test;

string report_id = "reg_base_test";
  // automation macro
  `uvm_component_utils_begin(reg_base_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "reg_base_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);

  end
  endfunction: build_phase


  task configure_phase(uvm_phase phase);
    reg_configuration_seq reg_config_seq;
    super.configure_phase(phase);
    phase.raise_objection(this);

    reg_config_seq = reg_configuration_seq::type_id::create("reg_config_seq");
    reg_config_seq.start(vseqr_h.reg_seqr_h);
    phase.drop_objection(this);
  endtask:configure_phase

  task main_phase(uvm_phase phase);
   super.main_phase(phase);
  endtask: main_phase

endclass : reg_base_test

// -------------------------------------------------------------
// ral basic test
// -------------------------------------------------------------
class reg_basic_test extends reg_base_test;
  `uvm_component_utils_begin(reg_basic_test)
    //
  `uvm_component_utils_end
  string report_id = "reg_basic_test";

  function new (string name = "reg_basic_test", uvm_component parent);
    super.new(name, parent);
  endfunction :new 
  
  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
  end
  endfunction: build_phase

// SPEEDUP mid_clk
  function void cpm_cfg_randomize();
      if (cpm_cfg_h.randomize() with {cpm_cfg_h.clk_ctrl_sel_xclk == 0;cpm_cfg_h.divmode * cpm_cfg_h.mid_clk_div <= 3;cpm_cfg_h.mid_clk_mux == 1;}
         ) `uvm_info(get_type_name (),cpm_cfg_h.sprint(),UVM_MEDIUM)
      else `uvm_fatal(get_type_name (),$sformatf("cpm_cfg_h randomization failed"))
  endfunction : cpm_cfg_randomize

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
    reg_basic_seq seq;
    phase.raise_objection(this);
      seq = reg_basic_seq::type_id::create("reg_basic_seq");
      seq.start(vseqr_h.reg_seqr_h);
    phase.drop_objection(this);
  endtask: main_phase

endclass : reg_basic_test


// -------------------------------------------------------------
// ral basic test
// -------------------------------------------------------------
class reg_hw_rst_test extends reg_base_test;
  `uvm_component_utils_begin(reg_hw_rst_test)
    //
  `uvm_component_utils_end
  string report_id = "reg_hw_rst_test";

  function new (string name = "reg_hw_rst_test", uvm_component parent);
    super.new(name, parent);
  endfunction :new 
  
  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
  end
  endfunction: build_phase

  //function void end_of_elaboration_phase(uvm_phase phase);
  //  super.end_of_elaboration_phase(phase);
  //  //this.set_report_verbosity_level(UVM_LOW);
  //  this.set_report_verbosity_level_hier(UVM_LOW);
  //endfunction:end_of_elaboration_phase
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
    reg_hw_rst_seq seq;
    phase.raise_objection(this);
      seq = reg_hw_rst_seq::type_id::create("reg_hw_rst_seq");
      seq.start(vseqr_h.reg_seqr_h);
    phase.drop_objection(this);
  endtask: main_phase

endclass : reg_hw_rst_test

//
// ral 32bit test
class reg_basic_roctrl_bit_test extends reg_base_test;
  `uvm_component_utils_begin(reg_basic_roctrl_bit_test)
    //
  `uvm_component_utils_end
  string report_id = "reg_basic_roctrl_bit_test";

  function new (string name = "reg_basic_roctrl_bit_test", uvm_component parent);
    super.new(name, parent);
  endfunction :new 
  
  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
  end
  endfunction: build_phase


  task main_phase(uvm_phase phase);  
    reg_basic_roctrl_bit_seq seq;
    phase.raise_objection(this);
      seq = reg_basic_roctrl_bit_seq::type_id::create("reg_basic_roctrl_bit_seq");
      seq.start(vseqr_h.reg_seqr_h);
    phase.drop_objection(this);
  endtask: main_phase

endclass : reg_basic_roctrl_bit_test


//
// ral 32bit test
class reg_32bits_test extends reg_base_test;
  `uvm_component_utils_begin(reg_32bits_test)
    //
  `uvm_component_utils_end
  string report_id = "reg_32bits_test";

  function new (string name = "reg_32bits_test", uvm_component parent);
    super.new(name, parent);
  endfunction :new 
  
  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
  end
  endfunction: build_phase

`ifdef RO_TRIGGER
  task pre_main_phase(uvm_phase phase);
    super.pre_main_phase(phase);
    begin
      phase.raise_objection(this);
      uvm_hdl_deposit("tb_top.RO",1);
      `uvm_info(get_type_name(),"trigger pad ri",UVM_MEDIUM);
      phase.drop_objection(this);
    end
  endtask
`endif

 function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
      rst_assertion_vif.assertion_checks_enable = 1'b1;
  endfunction

  task main_phase(uvm_phase phase);  
    reg_32bits_seq seq;
    phase.raise_objection(this);
      seq = reg_32bits_seq::type_id::create("reg_32bits_seq");
      seq.start(vseqr_h.reg_seqr_h);
    phase.drop_objection(this);
  endtask: main_phase

endclass : reg_32bits_test

//
// ral spacial value test
//
// all 0/1 and 5a5a_5a5a
class reg_special_val_test extends reg_base_test;
  `uvm_component_utils_begin(reg_special_val_test)
    //
  `uvm_component_utils_end
  string report_id = "reg_special_val_test";

  function new (string name = "reg_special_val_test", uvm_component parent);
    super.new(name, parent);
  endfunction :new 
  
  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);  
    reg_special_val_seq seq;
    phase.raise_objection(this);
      seq = reg_special_val_seq::type_id::create("reg_special_val_seq");
      seq.start(vseqr_h.reg_seqr_h);
    phase.drop_objection(this);
  endtask: main_phase

endclass : reg_special_val_test

//
// roctrl sub_blk regs, 32bits test
//
class reg_32bits_roctrl_test extends reg_base_test;
  `uvm_component_utils_begin(reg_32bits_roctrl_test)
    //
  `uvm_component_utils_end
  string report_id = "reg_32bits_roctrl_test";

  function new (string name = "reg_32bits_roctrl_test", uvm_component parent);
    super.new(name, parent);
  endfunction :new 
  
  virtual function void build_phase(uvm_phase phase);
  begin
    `ifndef PL_SIM
    set_cpm_cfg_type("cpm_mux2_config");
    `else 
    // PLSIM, mid_clk 25~60 MHz
    set_cpm_cfg_type("cpm_mux2_traversal_config");
    `endif
    super.build_phase(phase);
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);  
    reg_32bits_roctrl_seq seq;
    phase.raise_objection(this);
      seq = reg_32bits_roctrl_seq::type_id::create("reg_32bits_roctrl_seq");
      seq.start(vseqr_h.reg_seqr_h);
    phase.drop_objection(this);
  endtask: main_phase

endclass : reg_32bits_roctrl_test


//
//reg excluded reg_list 32bits random tes
//
class reg_32bits_W1C_test extends reg_base_test;
  `uvm_component_utils_begin(reg_32bits_W1C_test)
    //
  `uvm_component_utils_end
  string report_id = "reg_32bits_W1C_test";

  function new (string name = "reg_32bits_W1C_test", uvm_component parent);
    super.new(name, parent);
  endfunction :new 
  
  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);  
    reg_32bits_W1C_seq seq;
    phase.raise_objection(this);
      seq = reg_32bits_W1C_seq::type_id::create("reg_32bits_W1C_seq");
      seq.start(vseqr_h.reg_seqr_h);
    phase.drop_objection(this);
  endtask: main_phase

endclass : reg_32bits_W1C_test

//
// ral 32bits test on excluded regs
//
class reg_excluded_regs_test extends reg_base_test;
  `uvm_component_utils_begin(reg_excluded_regs_test)
    //
  `uvm_component_utils_end
  string report_id = "reg_excluded_regs_test";

  function new (string name = "reg_excluded_regs_test", uvm_component parent);
    super.new(name, parent);
  endfunction :new 
  
  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);  
    reg_excluded_regs_seq seq;
    phase.raise_objection(this);
      seq = reg_excluded_regs_seq::type_id::create("reg_excluded_regs_seq");
      seq.start(vseqr_h.reg_seqr_h);
    phase.drop_objection(this);
  endtask: main_phase

endclass : reg_excluded_regs_test
//
// ral random cfg, execute core test 
//
class reg_core_test extends reg_base_test;
  `uvm_component_utils_begin(reg_core_test)
    //
  `uvm_component_utils_end
  string report_id = "reg_core_test";

  function new (string name = "reg_core_test", uvm_component parent);
    super.new(name, parent);
  endfunction :new 
  
  virtual function void build_phase(uvm_phase phase);
  begin
    // config cpm to set clk, 
    `ifndef PL_SIM
    set_cpm_cfg_type("cpm_mux2_config");
    `else 
    // PLSIM, mid_clk 25~60 MHz
    set_cpm_cfg_type("cpm_mux2_traversal_config");
    `endif
    super.build_phase(phase);
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);  
    reg_core_seq seq;
    phase.raise_objection(this);
      seq = reg_core_seq::type_id::create("reg_core_seq");
      seq.start(vseqr_h.reg_seqr_h);
    phase.drop_objection(this);
  endtask: main_phase

endclass : reg_core_test

//
// ral write all and read back check
//
class reg_write_read_test extends reg_base_test;
  `uvm_component_utils_begin(reg_write_read_test)
    //
  `uvm_component_utils_end
  string report_id = "reg_write_read_test";

  function new (string name = "reg_write_read_test", uvm_component parent);
    super.new(name, parent);
  endfunction :new 
  
  virtual function void build_phase(uvm_phase phase);
  begin
    // config cpm to set clk, 
    //set_cpm_cfg_type("cpm_mux2_config");
    super.build_phase(phase);
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);  
    reg_write_read_seq seq;
    phase.raise_objection(this);
      seq = reg_write_read_seq::type_id::create("reg_write_read_seq");
      seq.start(vseqr_h.reg_seqr_h);
    phase.drop_objection(this);
  endtask: main_phase

endclass : reg_write_read_test



//
// ral write all and read back check in reverse order
//
class reg_write_read_reverse_test extends reg_base_test;
  `uvm_component_utils_begin(reg_write_read_reverse_test)
    //
  `uvm_component_utils_end
  string report_id = "reg_write_read_reverse_test";

  function new (string name = "reg_write_read_reverse_test", uvm_component parent);
    super.new(name, parent);
  endfunction :new 
  
  virtual function void build_phase(uvm_phase phase);
  begin
    // config cpm to set clk, 
    //set_cpm_cfg_type("cpm_mux2_config");
    super.build_phase(phase);
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);  
    reg_write_read_reverse_seq seq;
    phase.raise_objection(this);
      seq = reg_write_read_reverse_seq::type_id::create("reg_write_read_reverse_seq");
      seq.start(vseqr_h.reg_seqr_h);
    phase.drop_objection(this);
  endtask: main_phase

endclass : reg_write_read_reverse_test



//
// ral 32bits val check use jamlink driver 
//
class reg_32bits_jlm_test extends reg_base_test;
  `uvm_component_utils_begin(reg_32bits_jlm_test)
    //
  `uvm_component_utils_end
  string report_id = "reg_32bits_jlm_test";

  function new (string name = "reg_32bits_jlm_test", uvm_component parent);
    super.new(name, parent);
  endfunction :new   
  
  virtual function void build_phase(uvm_phase phase);
  begin
    // config cpm to set clk, 
    //`ifdef USE_UART_DRV
    //`else 
    `ifndef PL_SIM
    set_cpm_cfg_type("cpm_mux2_config");
    `else 
    // PLSIM, mid_clk 25~60 MHz
    set_cpm_cfg_type("cpm_mux2_traversal_config");
    `endif
    //`endif
    super.build_phase(phase);
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);  
    reg_32bits_jlm_seq seq;
    phase.raise_objection(this);
    seq = reg_32bits_jlm_seq::type_id::create("reg_32bits_jlm_seq");;
      seq.start(vseqr_h.reg_seqr_h);
    phase.drop_objection(this);
  endtask: main_phase
endclass : reg_32bits_jlm_test




//
// ral write special reg and check
//
class reg_noncebuf_jlm_test extends reg_base_test;
  `uvm_component_utils_begin(reg_noncebuf_jlm_test)
    //
  `uvm_component_utils_end
  string report_id = "reg_noncebuf_jlm_test";

  function new (string name = "reg_noncebuf_jlm_test", uvm_component parent);
    super.new(name, parent);
  endfunction :new 
  
  virtual function void build_phase(uvm_phase phase);
  begin
    // config cpm to set clk, 
    `ifndef PL_SIM
    set_cpm_cfg_type("cpm_mux2_config");
    `else 
    // PLSIM, mid_clk 25~60 MHz
    set_cpm_cfg_type("cpm_mux2_traversal_config");
    `endif
    super.build_phase(phase);
  end
  endfunction: build_phase


  task main_phase(uvm_phase phase);  
    reg_noncebuf_jlm_seq seq;
    phase.raise_objection(this);
      seq = reg_noncebuf_jlm_seq::type_id::create("reg_noncebuf_jlm_seq");
      seq.start(vseqr_h.reg_seqr_h);
    phase.drop_objection(this);
  endtask: main_phase

endclass : reg_noncebuf_jlm_test


//
// ral write and check th eci_clk and mid_clk difference
//
class reg_ci_mid_clk_jlm_test extends reg_base_test;
  `uvm_component_utils_begin(reg_ci_mid_clk_jlm_test)
    //
  `uvm_component_utils_end
  string report_id = "reg_ci_mid_clk_jlm_test";

  function new (string name = "reg_ci_mid_clk_jlm_test", uvm_component parent);
    super.new(name, parent);
  endfunction :new 
  
  virtual function void build_phase(uvm_phase phase);
  begin
    
    // config cpm to set clk, 
    //set_cpm_cfg_type("cpm_mux2_config");
    super.build_phase(phase);
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);  
    reg_ci_mid_clk_jlm_seq seq;
    phase.raise_objection(this);
      seq = reg_ci_mid_clk_jlm_seq::type_id::create("reg_ci_mid_clk_jlm_seq");
      seq.start(vseqr_h.reg_seqr_h);
    phase.drop_objection(this);
  endtask: main_phase

endclass : reg_ci_mid_clk_jlm_test

//---------------------------------------
// implement uvm built_in seq: uvm_reg_single_access_bash_seq / uvm_reg_access_seq
// check the backdoor path
//---------------------------------------
class reg_access_test extends reg_base_test;
  `uvm_component_utils_begin(reg_access_test)
    //
  `uvm_component_utils_end
  string report_id = "reg_access_test";

  function new (string name = "reg_access_test", uvm_component parent);
    super.new(name, parent);
  endfunction :new 
  
  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);  
    reg_access_seq seq;
    phase.raise_objection(this);
      seq = reg_access_seq::type_id::create("reg_access_seq");
      seq.start(vseqr_h.reg_seqr_h);
    phase.drop_objection(this);
  endtask: main_phase

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

endclass : reg_access_test


//---------------------------------------
// roctrl block
// implement uvm built_in seq: uvm_reg_single_access_bash_seq / uvm_reg_access_seq
// check the backdoor path
//---------------------------------------
class reg_access_roctrl_test extends reg_base_test;
  `uvm_component_utils_begin(reg_access_roctrl_test)
    //
  `uvm_component_utils_end
  string report_id = "reg_access_roctrl_test";

  function new (string name = "reg_access_roctrl_test", uvm_component parent);
    super.new(name, parent);
  endfunction :new 
  
  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);  
    reg_access_roctrl_seq seq;
    phase.raise_objection(this);
      seq = reg_access_roctrl_seq::type_id::create("reg_access_roctrl_seq");
      seq.start(vseqr_h.reg_seqr_h);
    phase.drop_objection(this);
  endtask: main_phase

endclass : reg_access_roctrl_test

//---------------------------------------
// eco reg
//---------------------------------------
class reg_access_eco_test extends reg_base_test;
  `uvm_component_utils_begin(reg_access_eco_test)
    //
  `uvm_component_utils_end
  string report_id = "reg_access_eco_test";

  function new (string name = "reg_access_eco_test", uvm_component parent);
    super.new(name, parent);
  endfunction :new 
  
  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);  
    reg_access_eco_seq seq;
    phase.raise_objection(this);
      seq = reg_access_eco_seq::type_id::create("reg_access_eco_seq");
      seq.start(vseqr_h.reg_seqr_h);
    phase.drop_objection(this);
  endtask: main_phase

endclass : reg_access_eco_test



class reg_access_fiforeg_test extends reg_base_test;
  `uvm_component_utils_begin(reg_access_fiforeg_test)
    //
  `uvm_component_utils_end
  string report_id = "reg_access_fiforeg_test";

  function new (string name = "reg_access_fiforeg_test", uvm_component parent);
    super.new(name, parent);
  endfunction :new 
  
  virtual function void build_phase(uvm_phase phase);
  begin 
    set_cpm_cfg_type("cpm_mux2_config");
    super.build_phase(phase);
  end
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
    reg_access_fiforeg_seq seq;
    phase.raise_objection(this);
      seq = reg_access_fiforeg_seq::type_id::create("reg_access_fiforeg_seq");
      seq.start(vseqr_h.reg_seqr_h);
    phase.drop_objection(this);
  endtask: main_phase

endclass : reg_access_fiforeg_test

//---------------------------------------
// check the reset flow when pad_ri is pulled up
//---------------------------------------
class reg_pad_ri_test extends reg_base_test;
  `uvm_component_utils_begin(reg_pad_ri_test)
    //
  `uvm_component_utils_end
  string report_id = "reg_pad_ri_test";

  function new (string name = "reg_pad_ri_test", uvm_component parent);
    super.new(name, parent);
  endfunction :new 
  
  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
  end
  endfunction: build_phase

  task main_phase(uvm_phase phase);  
    reg_pad_ri_seq seq;
    phase.raise_objection(this);
      seq = reg_pad_ri_seq::type_id::create("reg_pad_ri_seq");
      seq.start(vseqr_h.reg_seqr_h);
    phase.drop_objection(this);
  endtask: main_phase

endclass : reg_pad_ri_test




//`endif //`ifndef __REG_TEST__

typedef class efuse_access_block_seq;
typedef class efuse_access_block_seq;

class efuse_block_base_test extends uvm_test;

  `uvm_component_utils(efuse_block_base_test)

  efuse_env efuse_env_h;
  RAL_PKG::ral_gen_main 		ral;
  efuse_reg2apb_adapter efuse_adapter_h;
  function new(string name = "efuse_block_base_test" , uvm_component parent = null);
    super.new(name , parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    efuse_env_h = efuse_env::type_id::create("efuse_env_h" , this);
    efuse_env_h.drv_is_active=UVM_ACTIVE;
    efuse_adapter_h = efuse_reg2apb_adapter::type_id::create("efuse_adapter_h", this);
    ral  = RAL_PKG::ral_gen_main::type_id::create("ral", this);
    ral.configure(null, "");
    ral.build();
    ral.set_coverage(UVM_CVR_ALL);	
    ral.lock_model();
    ral.reset();
    ral.set_hdl_path_root("tb_top.C[0].btnode.btc");
    
    uvm_config_db#(RAL_PKG::ral_gen_main)::set(uvm_root::get(),"*", "ral", ral);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    //$display("NNNNNNNN==> sqr==%b",(efuse_env_h.vseqr_h==null));

    ral.default_map.set_sequencer(efuse_env_h.vseqr_h, efuse_adapter_h);
    ral.default_map.set_auto_predict(1);

  endfunction

endclass


class efuse_access_block_test extends efuse_block_base_test;

  `uvm_component_utils(efuse_access_block_test)


  function new(string name = "efuse_access_block_test" , uvm_component parent = null);
    super.new(name , parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

  endfunction

  task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   efuse_access_block_seq   seq;

   phase.raise_objection(this);

   seq = efuse_access_block_seq::type_id::create("efuse_access_block_seq");
   seq.start(efuse_env_h.vseqr_h);
   phase.drop_objection(this);

  endtask

endclass
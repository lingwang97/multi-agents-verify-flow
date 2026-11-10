class apb_master_env extends base_env;

  `uvm_component_utils(apb_master_env)

  apb_master_agent      apb_master_agent_h;
  apb_master_sequencer  vseqr_h;
  apb_master_coverage   apb_master_coverage_h;

  function new(string name = "apb_master_env" , uvm_component parent = null);
    super.new(name , parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_master_agent_h = apb_master_agent::type_id::create("apb_master_agent_h" , this);
    apb_master_agent_h.is_active = drv_is_active;
    vseqr_h = apb_master_sequencer::type_id::create("vseqr_h", this);
    apb_master_coverage_h = apb_master_coverage::type_id::create("apb_master_coverage_h" , this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    apb_master_agent_h.coverage_ap.connect(apb_master_coverage_h.mon2cov);
    if(apb_master_agent_h.is_active == UVM_ACTIVE)
      vseqr_h = apb_master_agent_h.m_sequencer;
  endfunction

endclass

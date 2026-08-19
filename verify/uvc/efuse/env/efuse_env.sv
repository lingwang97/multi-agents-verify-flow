class efuse_env extends base_env;

  `uvm_component_utils(efuse_env)

  efuse_agent      efuse_agent_h;
  efuse_sequencer  vseqr_h;
  efuse_coverage   efuse_coverage_h;

  function new(string name = "efuse_env" , uvm_component parent = null);
    super.new(name , parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    efuse_agent_h = efuse_agent::type_id::create("efuse_agent_h" , this);
    efuse_agent_h.is_active = drv_is_active;
    vseqr_h = efuse_sequencer::type_id::create("vseqr_h", this);
    efuse_coverage_h = efuse_coverage::type_id::create("efuse_coverage_h" , this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    efuse_agent_h.coverage_ap.connect(efuse_coverage_h.mon2cov);
    if(efuse_agent_h.is_active == UVM_ACTIVE)
      vseqr_h = efuse_agent_h.m_sequencer;
  endfunction

endclass

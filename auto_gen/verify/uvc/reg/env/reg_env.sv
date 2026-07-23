class reg_env extends uvm_env;

  `uvm_component_utils(reg_env)

  reg_agent      reg_agent_h;
  reg_sequencer  vseqr_h;
  reg_coverage   reg_coverage_h;

  uvm_active_passive_enum drv_is_active=UVM_PASSIVE;//UVM_ACTIVE

  function new(string name = "reg_env" , uvm_component parent = null);
    super.new(name , parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    reg_agent_h = reg_agent::type_id::create("reg_agent_h" , this);
    reg_agent_h.is_active = drv_is_active;
    vseqr_h = reg_sequencer::type_id::create("vseqr_h", this);
    reg_coverage_h = reg_coverage::type_id::create("reg_coverage_h" , this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    reg_agent_h.coverage_ap.connect(reg_coverage_h.mon2cov);
    if(reg_agent_h.is_active == UVM_ACTIVE)
      vseqr_h = reg_agent_h.m_sequencer;
  endfunction

endclass

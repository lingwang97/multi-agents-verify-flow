class jls_env extends base_env;

  `uvm_component_utils(jls_env)

  jls_agent      jls_agent_h;
  jls_sequencer  vseqr_h;
  jls_coverage   jls_coverage_h;

  function new(string name = "jls_env" , uvm_component parent = null);
    super.new(name , parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    jls_agent_h = jls_agent::type_id::create("jls_agent_h" , this);
    jls_agent_h.is_active = drv_is_active;
    vseqr_h = jls_sequencer::type_id::create("vseqr_h", this);
    jls_coverage_h = jls_coverage::type_id::create("jls_coverage_h" , this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    jls_agent_h.coverage_ap.connect(jls_coverage_h.mon2cov);
    if(jls_agent_h.is_active == UVM_ACTIVE)
      vseqr_h = jls_agent_h.m_sequencer;
  endfunction

endclass

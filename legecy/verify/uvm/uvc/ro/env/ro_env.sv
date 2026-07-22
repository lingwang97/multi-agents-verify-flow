
class ro_env extends uvm_env;

  `uvm_component_utils(ro_env)

  ro_agent ro_agent_h;
  ro_sequencer vseqr_h;
  ro_coverage ro_coverage_h;

  function new(string name = "ro_env" , uvm_component parent = null);
    super.new(name , parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ro_agent_h = ro_agent::type_id::create("ro_agent_h" , this);
    vseqr_h = ro_sequencer::type_id::create("vseqr_h", this);

    ro_coverage_h = ro_coverage::type_id::create("ro_coverage_h" , this);

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    ro_agent_h.coverage_ap.connect(ro_coverage_h.mon2cov);
    if(ro_agent_h.is_active == UVM_ACTIVE)
      vseqr_h =  ro_agent_h.m_sequencer;
  endfunction

endclass


class spd_env extends uvm_env;

  `uvm_component_utils(spd_env)

  spd_agent spd_agent_h;
  spd_sequencer vseqr_h;
  spd_coverage spd_coverage_h;

  function new(string name = "spd_env" , uvm_component parent = null);
    super.new(name , parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    spd_agent_h = spd_agent::type_id::create("spd_agent_h" , this);
    vseqr_h = spd_sequencer::type_id::create("vseqr_h", this);

    spd_coverage_h = spd_coverage::type_id::create("spd_coverage_h" , this);

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    spd_agent_h.coverage_ap.connect(spd_coverage_h.mon2cov);
    if(spd_agent_h.is_active == UVM_ACTIVE)
      vseqr_h =  spd_agent_h.m_sequencer;
  endfunction

endclass


class jamlink_env extends uvm_env;

  `uvm_component_utils(jamlink_env)

  jamlink_agent jamlink_agent_h;
  jamlink_sequencer vseqr_h;
  jamlink_coverage jamlink_coverage_h;

  function new(string name = "jamlink_env" , uvm_component parent = null);
    super.new(name , parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    jamlink_agent_h = jamlink_agent::type_id::create("jamlink_agent_h" , this);
    vseqr_h = jamlink_sequencer::type_id::create("vseqr_h", this);

    jamlink_coverage_h = jamlink_coverage::type_id::create("jamlink_coverage_h" , this);

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    jamlink_agent_h.coverage_ap.connect(jamlink_coverage_h.mon2cov);
    if(jamlink_agent_h.is_active == UVM_ACTIVE)
      vseqr_h =  jamlink_agent_h.m_sequencer;
  endfunction

endclass

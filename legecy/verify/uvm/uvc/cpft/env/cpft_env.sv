
class cpft_env extends uvm_env;

  `uvm_component_utils(cpft_env)

  cpft_agent cpft_agent_h;
  cpft_sequencer vseqr_h;
  cpft_coverage cpft_coverage_h;

  function new(string name = "cpft_env" , uvm_component parent = null);
    super.new(name , parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cpft_agent_h = cpft_agent::type_id::create("cpft_agent_h" , this);
    vseqr_h = cpft_sequencer::type_id::create("vseqr_h", this);

    cpft_coverage_h = cpft_coverage::type_id::create("cpft_coverage_h" , this);

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    cpft_agent_h.coverage_ap.connect(cpft_coverage_h.mon2cov);
    if(cpft_agent_h.is_active == UVM_ACTIVE)
      vseqr_h =  cpft_agent_h.m_sequencer;
  endfunction

endclass

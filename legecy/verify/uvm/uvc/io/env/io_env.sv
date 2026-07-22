
class io_env extends uvm_env;

  `uvm_component_utils(io_env)

  io_agent io_agent_h;
  io_sequencer vseqr_h;
  io_coverage io_coverage_h;

  function new(string name = "io_env" , uvm_component parent = null);
    super.new(name , parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    io_agent_h = io_agent::type_id::create("io_agent_h" , this);
    vseqr_h = io_sequencer::type_id::create("vseqr_h", this);

    io_coverage_h = io_coverage::type_id::create("io_coverage_h" , this);

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    io_agent_h.coverage_ap.connect(io_coverage_h.mon2cov);
    if(io_agent_h.is_active == UVM_ACTIVE)
      vseqr_h =  io_agent_h.m_sequencer;
  endfunction

endclass

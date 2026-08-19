class uart_env extends base_env;

  `uvm_component_utils(uart_env)

  uart_agent      uart_agent_h;
  uart_sequencer  vseqr_h;
  uart_coverage   uart_coverage_h;

  function new(string name = "uart_env" , uvm_component parent = null);
    super.new(name , parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uart_agent_h = uart_agent::type_id::create("uart_agent_h" , this);
    uart_agent_h.is_active = drv_is_active;
    vseqr_h = uart_sequencer::type_id::create("vseqr_h", this);
    uart_coverage_h = uart_coverage::type_id::create("uart_coverage_h" , this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    uart_agent_h.coverage_ap.connect(uart_coverage_h.mon2cov);
    if(uart_agent_h.is_active == UVM_ACTIVE)
      vseqr_h = uart_agent_h.m_sequencer;
  endfunction

endclass

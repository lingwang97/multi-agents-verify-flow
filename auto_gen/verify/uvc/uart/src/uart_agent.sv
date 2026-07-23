class uart_agent extends uvm_agent;

  `uvm_component_utils(uart_agent)

  uart_monitor      m_monitor;  
  uart_sequencer    m_sequencer;
  uart_scoreboard   m_scoreboard;  
  uart_driver       m_driver;    
  uvm_analysis_port#(uart_coverage_item) coverage_ap;

  function new(string name = "uart_agent", uvm_component parent);
    super.new(name,parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_monitor = uart_monitor::type_id::create("m_monitor", this);  
    if(is_active == UVM_ACTIVE)begin
      m_sequencer = uart_sequencer::type_id::create("m_sequencer",this);
      m_driver = uart_driver::type_id::create("m_driver", this);  
    end
    m_scoreboard = uart_scoreboard::type_id::create("m_scoreboard", this);  
    coverage_ap = new("coverage_ap",this);
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_monitor.frame_collected_port.connect(coverage_ap); 
    m_monitor.uart_monitor_main_ap.connect(m_scoreboard.uart_scoreboard_main_ap);
    if(is_active == UVM_ACTIVE)begin
      m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    end
  endfunction : connect_phase

endclass : uart_agent

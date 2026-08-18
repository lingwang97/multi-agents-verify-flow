class uart_agent extends base_agent;

  `uvm_component_utils(uart_agent)

  uart_monitor      uart_monitor_h;  
  uart_sequencer    m_sequencer;
  uart_scoreboard   uart_scoreboard_h;  
  uart_driver       m_driver;    
  uvm_analysis_port#(uart_coverage_item) coverage_ap;

  function new(string name = "uart_agent", uvm_component parent);
    super.new(name,parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uart_monitor_h = uart_monitor::type_id::create("uart_monitor_h", this);  
    if(is_active == UVM_ACTIVE)begin
      m_sequencer = uart_sequencer::type_id::create("m_sequencer",this);
      m_driver = uart_driver::type_id::create("m_driver", this);  
    end
    uart_scoreboard_h = uart_scoreboard::type_id::create("uart_scoreboard_h", this);  
    coverage_ap = new("coverage_ap",this);
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    uart_monitor_h.frame_collected_port.connect(coverage_ap); 
    uart_monitor_h.uart_monitor_main_ap.connect(uart_scoreboard_h.uart_scoreboard_main_ap);
    if(is_active == UVM_ACTIVE)begin
      m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    end
  endfunction : connect_phase

endclass : uart_agent

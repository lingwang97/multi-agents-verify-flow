
class io_agent extends uvm_agent;

  `uvm_component_utils(io_agent)

  io_monitor      m_monitor;  
  io_sequencer    m_sequencer;
  io_scoreboard   m_scoreboard;  
  io_driver       m_driver;    
  uvm_analysis_port#(io_coverage_item) coverage_ap;
  bit  drv_is_active = 0;

  function new(string name = "io_agent", uvm_component parent);
    super.new(name,parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
      m_monitor = io_monitor::type_id::create("m_monitor", this);
      if(drv_is_active == 1)
      begin  
      m_sequencer = io_sequencer::type_id::create("m_sequencer",this);
      m_driver = io_driver::type_id::create("m_driver", this);  
      end
      m_scoreboard = io_scoreboard::type_id::create("m_scoreboard", this);  

      coverage_ap = new("coverage_ap",this);
      
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_monitor.frame_collected_port.connect(coverage_ap); 
    m_monitor.io_monitor_main_ap.connect(m_scoreboard.io_scoreboard_main_ap);
    if(drv_is_active == 1)
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  endfunction : connect_phase

endclass : io_agent

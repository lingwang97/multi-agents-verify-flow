
class reg_agent extends uvm_agent;

  `uvm_component_utils(reg_agent)

  reg_monitor      m_monitor;  
  reg_sequencer    m_sequencer;
  reg_scoreboard   m_scoreboard;  
  reg_driver       m_driver;    
  uvm_analysis_port#(reg_coverage_item) coverage_ap;
  bit  drv_is_active = 0;

  function new(string name = "reg_agent", uvm_component parent);
    super.new(name,parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
      m_monitor = reg_monitor::type_id::create("m_monitor", this);  
      if(drv_is_active == 1)
      begin
      m_sequencer = reg_sequencer::type_id::create("m_sequencer",this);
      m_driver = reg_driver::type_id::create("m_driver", this);  
      end
      m_scoreboard = reg_scoreboard::type_id::create("m_scoreboard", this);  

      coverage_ap = new("coverage_ap",this);
      
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_monitor.frame_collected_port.connect(coverage_ap); 
    //m_monitor.reg_monitor_main_ap.connect(m_scoreboard.reg_scoreboard_main_ap);
    //m_monitor.reg_monitor_main_ap.connect(m_scoreboard.reg_scoreboard_mon_fifo.analysis_export);
    
    if(drv_is_active == 1)begin
      m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    end
  endfunction : connect_phase

endclass : reg_agent


class efuse_agent extends uvm_agent;

  `uvm_component_utils(efuse_agent)

  efuse_monitor      m_monitor;  
  efuse_sequencer    m_sequencer;
  efuse_scoreboard   m_scoreboard;  
  efuse_driver       m_driver;    
  uvm_analysis_port#(efuse_coverage_item) coverage_ap;

  function new(string name = "efuse_agent", uvm_component parent);
    super.new(name,parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
      m_monitor = efuse_monitor::type_id::create("m_monitor", this);  
      if(is_active == UVM_ACTIVE)
      begin
        m_sequencer = efuse_sequencer::type_id::create("m_sequencer",this);
        m_driver = efuse_driver::type_id::create("m_driver", this);  
      end
      m_scoreboard = efuse_scoreboard::type_id::create("m_scoreboard", this);  

      coverage_ap = new("coverage_ap",this);
      
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_monitor.frame_collected_port.connect(coverage_ap); 
    m_monitor.efuse_monitor_main_ap.connect(m_scoreboard.efuse_scoreboard_main_ap);
    if(is_active == UVM_ACTIVE)begin
      m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
      m_driver.ap.connect(m_scoreboard.efuse_scoreboard_ap);
    end
  endfunction : connect_phase

endclass : efuse_agent

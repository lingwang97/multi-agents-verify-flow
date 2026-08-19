class efuse_agent extends base_agent;

  `uvm_component_utils(efuse_agent)

  efuse_monitor      efuse_monitor_h;  
  efuse_sequencer    m_sequencer;
  efuse_scoreboard   efuse_scoreboard_h;  
  efuse_driver       m_driver;    
  uvm_analysis_port#(efuse_coverage_item) coverage_ap;

  function new(string name = "efuse_agent", uvm_component parent);
    super.new(name,parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    efuse_monitor_h = efuse_monitor::type_id::create("efuse_monitor_h", this);  
    if(is_active == UVM_ACTIVE)begin
      m_sequencer = efuse_sequencer::type_id::create("m_sequencer",this);
      m_driver = efuse_driver::type_id::create("m_driver", this);  
    end
    efuse_scoreboard_h = efuse_scoreboard::type_id::create("efuse_scoreboard_h", this);  
    coverage_ap = new("coverage_ap",this);
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    efuse_monitor_h.frame_collected_port.connect(coverage_ap); 
    efuse_monitor_h.efuse_monitor_main_ap.connect(efuse_scoreboard_h.efuse_scoreboard_main_ap);
    if(is_active == UVM_ACTIVE)begin
      m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    end
  endfunction : connect_phase

endclass : efuse_agent

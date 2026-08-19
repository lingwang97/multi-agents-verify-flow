class ro_agent extends base_agent;

  `uvm_component_utils(ro_agent)

  ro_monitor      ro_monitor_h;  
  ro_sequencer    m_sequencer;
  ro_scoreboard   ro_scoreboard_h;  
  ro_driver       m_driver;    
  uvm_analysis_port#(ro_coverage_item) coverage_ap;

  function new(string name = "ro_agent", uvm_component parent);
    super.new(name,parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ro_monitor_h = ro_monitor::type_id::create("ro_monitor_h", this);  
    if(is_active == UVM_ACTIVE)begin
      m_sequencer = ro_sequencer::type_id::create("m_sequencer",this);
      m_driver = ro_driver::type_id::create("m_driver", this);  
    end
    ro_scoreboard_h = ro_scoreboard::type_id::create("ro_scoreboard_h", this);  
    coverage_ap = new("coverage_ap",this);
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    ro_monitor_h.frame_collected_port.connect(coverage_ap); 
    ro_monitor_h.ro_monitor_main_ap.connect(ro_scoreboard_h.ro_scoreboard_main_ap);
    if(is_active == UVM_ACTIVE)begin
      m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    end
  endfunction : connect_phase

endclass : ro_agent

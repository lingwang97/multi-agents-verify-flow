class apb_master_agent extends base_agent;

  `uvm_component_utils(apb_master_agent)

  apb_master_monitor      apb_master_monitor_h;  
  apb_master_sequencer    m_sequencer;
  apb_master_scoreboard   apb_master_scoreboard_h;  
  apb_master_driver       m_driver;    
  uvm_analysis_port#(apb_master_coverage_item) coverage_ap;

  function new(string name = "apb_master_agent", uvm_component parent);
    super.new(name,parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_master_monitor_h = apb_master_monitor::type_id::create("apb_master_monitor_h", this);  
    if(is_active == UVM_ACTIVE)begin
      m_sequencer = apb_master_sequencer::type_id::create("m_sequencer",this);
      m_driver = apb_master_driver::type_id::create("m_driver", this);  
    end
    apb_master_scoreboard_h = apb_master_scoreboard::type_id::create("apb_master_scoreboard_h", this);  
    coverage_ap = new("coverage_ap",this);
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    apb_master_monitor_h.frame_collected_port.connect(coverage_ap); 
    apb_master_monitor_h.apb_master_monitor_main_ap.connect(apb_master_scoreboard_h.apb_master_scoreboard_main_ap);
    if(is_active == UVM_ACTIVE)begin
      m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    end
  endfunction : connect_phase

endclass : apb_master_agent

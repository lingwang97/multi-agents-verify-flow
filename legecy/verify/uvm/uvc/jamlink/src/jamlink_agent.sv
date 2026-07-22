
class jamlink_agent extends uvm_agent;

  `uvm_component_utils(jamlink_agent)

  jamlink_monitor      m_monitor;  
  jamlink_sequencer    m_sequencer;
  jamlink_scoreboard   m_scoreboard;  
  jamlink_driver       m_driver;    
  jamlink_new_driver   m_new_driver;
  uvm_analysis_port#(jamlink_coverage_item) coverage_ap;
  uvm_analysis_port#(jamlink_sequence_item) adapter_ap;


  function new(string name = "jamlink_agent", uvm_component parent);
    super.new(name,parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
	  `ifdef JLM_DRV_OLD 
      `else
	  set_type_override_by_type(jamlink_driver::get_type(),jamlink_new_driver::get_type() );
      `endif
      m_monitor = jamlink_monitor::type_id::create("m_monitor", this);  
      m_sequencer = jamlink_sequencer::type_id::create("m_sequencer",this);
      m_driver = jamlink_driver::type_id::create("m_driver", this);  
      m_scoreboard = jamlink_scoreboard::type_id::create("m_scoreboard", this);  

      coverage_ap = new("coverage_ap",this);
	  adapter_ap  = new("adapter_ap", this);
      
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_monitor.frame_collected_port.connect(coverage_ap); 
    m_monitor.jamlink_monitor_adapter_ap.connect(adapter_ap);
    m_monitor.jamlink_monitor_main_ap.connect(m_scoreboard.jamlink_scoreboard_main_ap);
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  endfunction : connect_phase

endclass : jamlink_agent




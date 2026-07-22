
class jls_agent extends uvm_agent;

  `uvm_component_utils(jls_agent)

  jls_monitor      m_monitor;  
  jls_sequencer    m_sequencer;
  jls_scoreboard   m_scoreboard;  
  jls_driver       m_driver;   

  jls_btc_driver   m_btc_driver;    

 
  uvm_analysis_port#(jls_coverage_item) coverage_ap;
  uvm_analysis_port#(jls_sequence_item) adapter_ap;


  function new(string name = "jls_agent", uvm_component parent);
    super.new(name,parent);
  endfunction : new

  function void build_phase(uvm_phase phase);

      set_type_override_by_type(jls_driver::get_type(),jls_btc_driver::get_type() );

      m_monitor = jls_monitor::type_id::create("m_monitor", this);  
      m_sequencer = jls_sequencer::type_id::create("m_sequencer",this);
      m_driver = jls_driver::type_id::create("m_driver", this);  
      m_scoreboard = jls_scoreboard::type_id::create("m_scoreboard", this);  

      coverage_ap = new("coverage_ap",this);
	  adapter_ap  = new("adapter_ap", this);
      
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_monitor.frame_collected_port.connect(coverage_ap); 
    m_monitor.jls_monitor_adapter_ap.connect(adapter_ap);
    m_monitor.jls_monitor_main_ap.connect(m_scoreboard.jls_scoreboard_main_ap);
    m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
  endfunction : connect_phase

endclass : jls_agent

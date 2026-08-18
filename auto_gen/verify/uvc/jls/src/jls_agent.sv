class jls_agent extends base_agent;

  `uvm_component_utils(jls_agent)

  jls_monitor      jls_monitor_h;  
  jls_sequencer    m_sequencer;
  jls_scoreboard   jls_scoreboard_h;  
  jls_driver       m_driver;    
  uvm_analysis_port#(jls_coverage_item) coverage_ap;

  function new(string name = "jls_agent", uvm_component parent);
    super.new(name,parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    jls_monitor_h = jls_monitor::type_id::create("jls_monitor_h", this);  
    if(is_active == UVM_ACTIVE)begin
      m_sequencer = jls_sequencer::type_id::create("m_sequencer",this);
      m_driver = jls_driver::type_id::create("m_driver", this);  
    end
    jls_scoreboard_h = jls_scoreboard::type_id::create("jls_scoreboard_h", this);  
    coverage_ap = new("coverage_ap",this);
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    jls_monitor_h.frame_collected_port.connect(coverage_ap); 
    jls_monitor_h.jls_monitor_main_ap.connect(jls_scoreboard_h.jls_scoreboard_main_ap);
    if(is_active == UVM_ACTIVE)begin
      m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    end
  endfunction : connect_phase

endclass : jls_agent

class reg_agent extends base_agent;

  `uvm_component_utils(reg_agent)

  reg_monitor      reg_monitor_h;  
  reg_sequencer    m_sequencer;
  reg_scoreboard   reg_scoreboard_h;  
  reg_driver       m_driver;    
  uvm_analysis_port#(reg_coverage_item) coverage_ap;

  function new(string name = "reg_agent", uvm_component parent);
    super.new(name,parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    reg_monitor_h = reg_monitor::type_id::create("reg_monitor_h", this);  
    if(is_active == UVM_ACTIVE)begin
      m_sequencer = reg_sequencer::type_id::create("m_sequencer",this);
      m_driver = reg_driver::type_id::create("m_driver", this);  
    end
    reg_scoreboard_h = reg_scoreboard::type_id::create("reg_scoreboard_h", this);  
    coverage_ap = new("coverage_ap",this);
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    reg_monitor_h.frame_collected_port.connect(coverage_ap); 
    reg_monitor_h.reg_monitor_main_ap.connect(reg_scoreboard_h.reg_scoreboard_main_ap);
    if(is_active == UVM_ACTIVE)begin
      m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
    end
  endfunction : connect_phase

endclass : reg_agent

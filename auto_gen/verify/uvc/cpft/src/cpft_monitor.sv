class cpft_monitor extends base_monitor;

  uvm_analysis_port #(cpft_item) cpft_monitor_main_ap;
  uvm_analysis_port #(cpft_coverage_item) frame_collected_port;

  `uvm_component_utils(cpft_monitor);

  cpft_coverage_item req;
  cpft_item cpft_item_h;
  virtual cpft_if cpft_vif;

  extern task monitor_trans();
  extern task collect_coverage();

  function new(string name="cpft_monitor" , uvm_component parent=null);
    super.new(name , parent);
    cpft_monitor_main_ap = new("cpft_monitor_main_ap", this);
    frame_collected_port = new("frame_collected_port",this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    req = cpft_coverage_item::type_id::create("req",this);
    cpft_item_h = cpft_item::type_id::create("cpft_item_h",this);
    if(!uvm_config_db#(virtual cpft_if)::get(this , "" , "cpft_vif" ,cpft_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork
      monitor_trans();
      collect_coverage();
    join_none
  endtask


endclass : cpft_monitor

  // Sample vif data , trans to scoreboard or other component
  task cpft_monitor::monitor_trans();
    forever begin
      @(posedge cpft_vif.clk);
      begin
        cpft_item_h.card_sel = cpft_vif.card_sel  ;
        cpft_monitor_main_ap.write(cpft_item_h);
      end
    end
  endtask

  // Sample vif data , for coverage collection
  task cpft_monitor::collect_coverage();
    forever begin
      @(posedge cpft_vif.clk);
      req.card_sel  = cpft_vif.card_sel ;
      req.cpft_ctrl  = cpft_vif.cpft_ctrl ;
      frame_collected_port.write(req);  
    end
  endtask


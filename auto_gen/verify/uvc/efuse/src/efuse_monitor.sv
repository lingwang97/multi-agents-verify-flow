class efuse_monitor extends base_monitor;

  uvm_analysis_port #(efuse_item) efuse_monitor_main_ap;
  uvm_analysis_port #(efuse_coverage_item) frame_collected_port;

  `uvm_component_utils(efuse_monitor);

  efuse_coverage_item req;
  efuse_item efuse_item_h;
  virtual efuse_if efuse_vif;

  extern task monitor_trans();
  extern task collect_coverage();

  function new(string name="efuse_monitor" , uvm_component parent=null);
    super.new(name , parent);
    efuse_monitor_main_ap = new("efuse_monitor_main_ap", this);
    frame_collected_port = new("frame_collected_port",this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    req = efuse_coverage_item::type_id::create("req",this);
    efuse_item_h = efuse_item::type_id::create("efuse_item_h",this);
    if(!uvm_config_db#(virtual efuse_if)::get(this , "" , "efuse_vif" ,efuse_vif))
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


endclass : efuse_monitor

  // Sample vif data , trans to scoreboard or other component
  task efuse_monitor::monitor_trans();
    forever begin
      @(posedge efuse_vif.clk);
      begin
        efuse_item_h.card_sel = efuse_vif.card_sel  ;
        efuse_monitor_main_ap.write(efuse_item_h);
      end
    end
  endtask

  // Sample vif data , for coverage collection
  task efuse_monitor::collect_coverage();
    forever begin
      @(posedge efuse_vif.clk);
      req.card_sel  = efuse_vif.card_sel ;
      req.efuse_ctrl  = efuse_vif.efuse_ctrl ;
      frame_collected_port.write(req);  
    end
  endtask



class efuse_monitor extends base_monitor;

  uvm_analysis_port #(efuse_item) efuse_monitor_main_ap;
  uvm_analysis_port #(efuse_coverage_item) frame_collected_port;

  `uvm_component_utils(efuse_monitor);

  efuse_coverage_item req;
  efuse_item efuse_item_h;

  virtual efuse_if vif;
  
  extern task main_traffic();
  extern task collect_coverage();

  function new(string name="efuse_monitor" , uvm_component parent=null);
    super.new(name , parent);
    efuse_monitor_main_ap = new("efuse_monitor_main_ap",this);
    frame_collected_port = new("frame_collected_port",this);
  endfunction
 
   function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual efuse_if)::get(this , "" , "efuse_vif" ,vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")

    req = efuse_coverage_item::type_id::create("req",this);
    efuse_item_h = efuse_item::type_id::create("efuse_item_h",this);
      
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork
      main_traffic();
      collect_coverage();
    join_none
  endtask  
endclass

task efuse_monitor::main_traffic();
    begin
    forever
    begin
      wait(~vif.rst);
      @(posedge vif.mid_clk);
      begin
        efuse_item_h.card_sel = vif.card_sel  ;
        efuse_monitor_main_ap.write(efuse_item_h);
      end
    end
    end
endtask

task efuse_monitor::collect_coverage();
    begin 
    forever
    begin
    @(posedge vif.xclk);
    req.card_sel  = vif.card_sel  ;
    frame_collected_port.write(req);   
    end
    end
endtask

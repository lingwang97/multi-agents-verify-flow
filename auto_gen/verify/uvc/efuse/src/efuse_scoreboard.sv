`uvm_analysis_imp_decl(_main_efuse_monitor)
class efuse_scoreboard extends base_scoreboard;

  `uvm_component_utils(efuse_scoreboard);
  
  virtual efuse_if efuse_vif;

  efuse_item efuse_item_h;

  uvm_analysis_imp_main_efuse_monitor #(efuse_item, efuse_scoreboard) efuse_scoreboard_main_ap;
  
  function new(string name="efuse_scoreboard" , uvm_component parent=null);
    super.new(name , parent);
  endfunction
 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    efuse_scoreboard_main_ap = new("efuse_scoreboard_main_ap",this);  
    efuse_item_h = efuse_item::type_id::create("efuse_item_h",this);
    if (!uvm_config_db #(virtual interface efuse_if)::get(this, "", "efuse_vif", efuse_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  virtual task main_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("efuse_scoreboard begin check"), UVM_MEDIUM)
    #1000ns;
    if(checks_enable) `uvm_info(get_type_name(), $sformatf("begin to do scoreboard check"), UVM_MEDIUM)
    else `uvm_info(get_type_name(), $sformatf("stop to do scoreboard check"), UVM_MEDIUM)

  endtask:main_phase

  virtual function void write_main_efuse_monitor(efuse_item req);
    `uvm_info(get_type_name(), $sformatf("Received efuse_item transaction: %s", req.sprint()), UVM_FULL)
  endfunction
  
endclass

`uvm_analysis_imp_decl(_main_ro_monitor)
class ro_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(ro_scoreboard);
  
  virtual ro_if ro_vif;

  ro_item ro_item_h;

  uvm_analysis_imp_main_ro_monitor #(ro_item, ro_scoreboard) ro_scoreboard_main_ap;
  
  function new(string name="ro_scoreboard" , uvm_component parent=null);
    super.new(name , parent);
  endfunction
 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ro_scoreboard_main_ap = new("ro_scoreboard_main_ap",this);  
    ro_item_h = ro_item::type_id::create("ro_item_h",this);
    if (!uvm_config_db #(virtual interface ro_if)::get(this, "", "ro_vif", ro_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  virtual task main_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("ro_scoreboard begin check"), UVM_MEDIUM)
    #1000ns;

  endtask:main_phase

  virtual function void write_main_ro_monitor(ro_item req);
    `uvm_info(get_type_name(), $sformatf("Received ro_item transaction: %s", req.sprint()), UVM_FULL)
  endfunction
  
endclass

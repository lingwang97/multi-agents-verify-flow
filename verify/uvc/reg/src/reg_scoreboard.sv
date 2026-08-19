`uvm_analysis_imp_decl(_main_reg_monitor)
class reg_scoreboard extends base_scoreboard;

  `uvm_component_utils(reg_scoreboard);
  
  virtual reg_if reg_vif;

  reg_item reg_item_h;

  uvm_analysis_imp_main_reg_monitor #(reg_item, reg_scoreboard) reg_scoreboard_main_ap;
  
  function new(string name="reg_scoreboard" , uvm_component parent=null);
    super.new(name , parent);
  endfunction
 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    reg_scoreboard_main_ap = new("reg_scoreboard_main_ap",this);  
    reg_item_h = reg_item::type_id::create("reg_item_h",this);
    if (!uvm_config_db #(virtual interface reg_if)::get(this, "", "reg_vif", reg_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  virtual task main_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("reg_scoreboard begin check"), UVM_MEDIUM)
    #1000ns;
    if(checks_enable) `uvm_info(get_type_name(), $sformatf("begin to do scoreboard check"), UVM_MEDIUM)
    else `uvm_info(get_type_name(), $sformatf("stop to do scoreboard check"), UVM_MEDIUM)

  endtask:main_phase

  virtual function void write_main_reg_monitor(reg_item req);
    `uvm_info(get_type_name(), $sformatf("Received reg_item transaction: %s", req.sprint()), UVM_FULL)
  endfunction
  
endclass

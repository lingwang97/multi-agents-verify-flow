class efuse_coverage extends uvm_subscriber #(efuse_coverage_item);
 
  `uvm_component_utils(efuse_coverage)
  
  uvm_analysis_imp #(efuse_coverage_item, efuse_coverage) mon2cov;

  virtual efuse_if efuse_vif;
  efuse_coverage_item req_h;

  string report_id = "efuse_coverage";

  //CHOOSE METHOD_A/B to Sample coverage data
  //[METHOD_A] Sample monitor data by TLM   
  covergroup cg_efuse_ctrl;
    option.per_instance = 1;
    
    cov_ctrl : coverpoint req_h.efuse_ctrl {
      type_option.weight = 0;
      bins efuse_ctrl[] = {[0:31]};
    }
    
  endgroup

  //[METHOD_B] Sample interface data directly 
  covergroup cg_efuse_ctrl_by_if ;
    option.per_instance = 1;
    
    cov_ctrl : coverpoint efuse_vif.efuse_ctrl {
      bins efuse_ctrl[] = {[0:31]};
    }
    
  endgroup


  function new(string name, uvm_component parent);
    super.new(name, parent);
    mon2cov = new("mon2cov",this);
    cg_efuse_ctrl = new();
    cg_efuse_ctrl_by_if = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    req_h = efuse_coverage_item::type_id::create("req_h",this);
    if(!uvm_config_db#(virtual efuse_if)::get(this , "" , "efuse_vif" ,efuse_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction

  function void write(efuse_coverage_item t);
    req_h = t;
    cg_efuse_ctrl.sample();
    cg_efuse_ctrl_by_if.sample();
  endfunction

endclass

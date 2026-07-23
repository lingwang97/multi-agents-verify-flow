class ro_coverage extends uvm_subscriber #(ro_coverage_item);
 
  `uvm_component_utils(ro_coverage)
  
  uvm_analysis_imp #(ro_coverage_item, ro_coverage) mon2cov;

  virtual ro_if ro_vif;
  ro_coverage_item req_h;

  string report_id = "ro_coverage";

  //CHOOSE METHOD_A/B to Sample coverage data
  //[METHOD_A] Sample monitor data by TLM   
  covergroup cg_ro_ctrl;
    option.per_instance = 1;
    
    cov_ctrl : coverpoint req_h.ro_ctrl {
      type_option.weight = 0;
      bins ro_ctrl[] = {[0:31]};
    }
    
  endgroup

  //[METHOD_B] Sample interface data directly 
  covergroup cg_ro_ctrl_by_if ;
    option.per_instance = 1;
    
    cov_ctrl : coverpoint ro_vif.ro_ctrl {
      bins ro_ctrl[] = {[0:31]};
    }
    
  endgroup


  function new(string name, uvm_component parent);
    super.new(name, parent);
    mon2cov = new("mon2cov",this);
    cg_ro_ctrl = new();
    cg_ro_ctrl_by_if = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    req_h = ro_coverage_item::type_id::create("req_h",this);
    if(!uvm_config_db#(virtual ro_if)::get(this , "" , "ro_vif" ,ro_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction

  function void write(ro_coverage_item t);
    req_h = t;
    cg_ro_ctrl.sample();
    cg_ro_ctrl_by_if.sample();
  endfunction

endclass

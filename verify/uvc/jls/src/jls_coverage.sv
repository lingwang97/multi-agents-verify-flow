class jls_coverage extends uvm_subscriber #(jls_coverage_item);
 
  `uvm_component_utils(jls_coverage)
  
  uvm_analysis_imp #(jls_coverage_item, jls_coverage) mon2cov;

  virtual jls_if jls_vif;
  jls_coverage_item req_h;

  string report_id = "jls_coverage";

  //CHOOSE METHOD_A/B to Sample coverage data
  //[METHOD_A] Sample monitor data by TLM   
  covergroup cg_jls_ctrl;
    option.per_instance = 1;
    
    cov_ctrl : coverpoint req_h.jls_ctrl {
      type_option.weight = 0;
      bins jls_ctrl[] = {[0:31]};
    }
    
  endgroup

  //[METHOD_B] Sample interface data directly 
  covergroup cg_jls_ctrl_by_if ;
    option.per_instance = 1;
    
    cov_ctrl : coverpoint jls_vif.jls_ctrl {
      bins jls_ctrl[] = {[0:31]};
    }
    
  endgroup


  function new(string name, uvm_component parent);
    super.new(name, parent);
    mon2cov = new("mon2cov",this);
    cg_jls_ctrl = new();
    cg_jls_ctrl_by_if = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    req_h = jls_coverage_item::type_id::create("req_h",this);
    if(!uvm_config_db#(virtual jls_if)::get(this , "" , "jls_vif" ,jls_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction

  function void write(jls_coverage_item t);
    req_h = t;
    cg_jls_ctrl.sample();
    cg_jls_ctrl_by_if.sample();
  endfunction

endclass

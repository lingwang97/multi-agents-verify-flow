class cpft_coverage extends uvm_subscriber #(cpft_coverage_item);
 
  `uvm_component_utils(cpft_coverage)
  
  uvm_analysis_imp #(cpft_coverage_item, cpft_coverage) mon2cov;

  virtual cpft_if cpft_vif;
  cpft_coverage_item req_h;

  string report_id = "cpft_coverage";

  //CHOOSE METHOD_A/B to Sample coverage data
  //[METHOD_A] Sample monitor data by TLM   
  covergroup cg_cpft_ctrl;
    option.per_instance = 1;
    
    cov_ctrl : coverpoint req_h.cpft_ctrl {
      type_option.weight = 0;
      bins cpft_ctrl[] = {[0:31]};
    }
    
  endgroup

  //[METHOD_B] Sample interface data directly 
  covergroup cg_cpft_ctrl_by_if ;
    option.per_instance = 1;
    
    cov_ctrl : coverpoint cpft_vif.cpft_ctrl {
      bins cpft_ctrl[] = {[0:31]};
    }
    
  endgroup


  function new(string name, uvm_component parent);
    super.new(name, parent);
    mon2cov = new("mon2cov",this);
    cg_cpft_ctrl = new();
    cg_cpft_ctrl_by_if = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    req_h = cpft_coverage_item::type_id::create("req_h",this);
    if(!uvm_config_db#(virtual cpft_if)::get(this , "" , "cpft_vif" ,cpft_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction

  function void write(cpft_coverage_item t);
    req_h = t;
    cg_cpft_ctrl.sample();
    cg_cpft_ctrl_by_if.sample();
  endfunction

endclass

class reg_coverage extends uvm_subscriber #(reg_coverage_item);
 
  `uvm_component_utils(reg_coverage)
  
  uvm_analysis_imp #(reg_coverage_item, reg_coverage) mon2cov;

  virtual reg_if reg_vif;
  reg_coverage_item req_h;

  string report_id = "reg_coverage";

  //CHOOSE METHOD_A/B to Sample coverage data
  //[METHOD_A] Sample monitor data by TLM   
  covergroup cg_reg_ctrl;
    option.per_instance = 1;
    
    cov_ctrl : coverpoint req_h.reg_ctrl {
      type_option.weight = 0;
      bins reg_ctrl[] = {[0:31]};
    }
    
  endgroup

  //[METHOD_B] Sample interface data directly 
  covergroup cg_reg_ctrl_by_if ;
    option.per_instance = 1;
    
    cov_ctrl : coverpoint reg_vif.reg_ctrl {
      bins reg_ctrl[] = {[0:31]};
    }
    
  endgroup


  function new(string name, uvm_component parent);
    super.new(name, parent);
    mon2cov = new("mon2cov",this);
    cg_reg_ctrl = new();
    cg_reg_ctrl_by_if = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    req_h = reg_coverage_item::type_id::create("req_h",this);
    if(!uvm_config_db#(virtual reg_if)::get(this , "" , "reg_vif" ,reg_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction

  function void write(reg_coverage_item t);
    req_h = t;
    cg_reg_ctrl.sample();
    cg_reg_ctrl_by_if.sample();
  endfunction

endclass

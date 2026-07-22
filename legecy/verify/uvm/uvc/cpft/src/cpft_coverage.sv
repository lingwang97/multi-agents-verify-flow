class cpft_coverage extends uvm_subscriber #(cpft_coverage_item);
 
   `uvm_component_utils(cpft_coverage)
  
   uvm_analysis_imp #(cpft_coverage_item, cpft_coverage)  mon2cov;

   virtual cpft_if cpft_vif;
   cpft_coverage_item req_h;

   string report_id = "cpft_coverage";

   covergroup cg_card_sel;
     option.per_instance = 0;
     cov_card_sel  : coverpoint  cpft_vif.card_sel;
   endgroup

  function new(string name, uvm_component parent);
    begin
    super.new(name, parent);
    //cg_card_sel = new();
    mon2cov = new("mon2cov",this);
    end
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual cpft_if)::get(this , "" , "cpft_vif" ,cpft_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction
  
  function void write(cpft_coverage_item t); 
   req_h = t;
   //cg_card_sel.sample();
  endfunction

endclass

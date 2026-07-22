class ro_coverage extends uvm_subscriber #(ro_coverage_item);
 
   `uvm_component_utils(ro_coverage)
  
   uvm_analysis_imp #(ro_coverage_item, ro_coverage)  mon2cov;

   virtual ro_if ro_vif;
   ro_coverage_item req_h;

   string report_id = "ro_coverage";


   //////////////////////////////////////////////////////////////
   // RO fucntion coverage
   //////////////////////////////////////////////////////////////

   //RO sdf file define:   in sv/env/tb_top/tb_sdf.sv

   //////////////////////////////////////////////////////////////
   // RO fucntion coverage
   //////////////////////////////////////////////////////////////

   //RO sdf file define:   in sv/env/tb_top/tb_sdf.sv
   //RO NOTE:  there are 2 core_ro placed in slice0(A) ; 2 ro placed in PD_TOP(B) ;


   covergroup RO_CTRL0_SLICE0;
     option.per_instance = 0;

     cov_RO_div_num :  coverpoint  ro_vif.RO_div_num{
             bins  one   = {1};
             bins  two   = {2};
          }

     
     //******INST0 
     //check ro ready
     cov_RO0_rdy_inst0 :  coverpoint  ro_vif.RO0_rdy_inst0 {
             bins  zero  = {0};
             bins  one   = {1};
          }
     //check ro_sel: DL0~ DLn
     cov_RO0_sel_inst0 :  coverpoint  ro_vif.RO0_sel_inst0{
             bins  value[]   = {[0:`RO_SEL_NUM-1]};
          }

     //******INST1 
     //check ro ready
     cov_RO0_rdy_inst1 :  coverpoint  ro_vif.RO0_rdy_inst1 {
             bins  zero  = {0};
             bins  one   = {1};
          }
     //check ro_sel: DL0~ DLn
     cov_RO0_sel_inst1 :  coverpoint  ro_vif.RO0_sel_inst1 {
             bins  value[]   = {[0:`RO_SEL_NUM-1]};
          }


     cov_RO0_inst0 : cross cov_RO0_rdy_inst0, cov_RO_div_num, cov_RO0_sel_inst0;
     cov_RO0_inst1 : cross cov_RO0_rdy_inst1, cov_RO_div_num, cov_RO0_sel_inst1;

   endgroup

   //top
   covergroup RO_CTRL1_TOP;
     option.per_instance = 0;

     cov_RO_div_num :  coverpoint  ro_vif.RO_div_num{
             bins  one   = {1};
             bins  two   = {2};
          }

     
     //******INST0 
     //check ro ready
     cov_RO1_rdy_inst0 :  coverpoint  ro_vif.RO1_rdy_inst0 {
             bins  zero  = {0};
             bins  one   = {1};
          }
     //check ro_sel: DL0~ DLn
     cov_RO1_sel_inst0 :  coverpoint  ro_vif.RO1_sel_inst0{
             bins  value[]   = {[0:`RO_SEL_NUM-1]};
          }

     //******INST1 
     //check ro ready
     cov_RO1_rdy_inst1 :  coverpoint  ro_vif.RO1_rdy_inst1 {
             bins  zero  = {0};
             bins  one   = {1};
          }
     //check ro_sel: DL0~ DLn
     cov_RO1_sel_inst1 :  coverpoint  ro_vif.RO1_sel_inst1 {
             bins  value[]   = {[0:`RO_SEL_NUM-1]};
          }


     cov_RO1_inst0 : cross cov_RO1_rdy_inst0, cov_RO_div_num, cov_RO1_sel_inst0;
     cov_RO1_inst1 : cross cov_RO1_rdy_inst1, cov_RO_div_num, cov_RO1_sel_inst1;

   endgroup


 
 //////////////////////////////////////////////////////////////
 // RO top_ctrl Feature
 //////////////////////////////////////////////////////////////


 //////////////////////////////////////////////////////////////
 // RO New Feature
 //////////////////////////////////////////////////////////////
   covergroup RO_New_Feature;
     option.per_instance = 0;

     //ro clock gate:
     cov_ro_clk_gate :  coverpoint  ro_vif.reg_ro_cg_en{
             bins  zero   = {0};
             bins  one    = {1};
          }

   endgroup


  //ro rst



  function new(string name, uvm_component parent);
    begin
    super.new(name, parent);
    //cg_card_sel = new();

    RO_CTRL0_SLICE0 = new();
    RO_CTRL1_TOP = new();
    RO_New_Feature = new();

    mon2cov = new("mon2cov",this);
    end
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ro_if)::get(this , "" , "ro_vif" ,ro_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction
  
  function void write(ro_coverage_item t); 
   req_h = t;
   //cg_card_sel.sample();

   RO_CTRL0_SLICE0.sample();
   RO_CTRL1_TOP.sample();
   RO_New_Feature.sample();

  endfunction

endclass

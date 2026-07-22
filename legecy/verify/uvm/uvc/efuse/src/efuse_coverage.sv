class efuse_coverage extends uvm_subscriber #(efuse_coverage_item);
 
   `uvm_component_utils(efuse_coverage)
  
   uvm_analysis_imp #(efuse_coverage_item, efuse_coverage)  mon2cov;

   virtual efuse_if efuse_vif;
   efuse_coverage_item req_h;
  
   string report_id = "efuse_coverage";

//==========tmp quick code area==========

//=======================================

   covergroup cg_efuse_Ctrl;
     option.per_instance = 0;

      cov_efuse_csb : coverpoint efuse_vif.ip_CSB 
                       {
                        bins enable= {0};
                        bins dis_able= {1};
                      }
      cov_efuse_strobe : coverpoint efuse_vif.ip_STROBE 
                       {
                        bins enable= {1};
                        bins dis_able= {0};
                      }
      cov_efuse_load : coverpoint efuse_vif.ip_LOAD 
                       {
                        bins enable= {1};
                        bins dis_able= {0};
                      }
      cov_efuse_pgenb : coverpoint efuse_vif.ip_PGENB 
                       {
                        bins enable= {0};
                        bins dis_able= {1};
                      }
      cov_efuse_ps : coverpoint efuse_vif.ip_PS 
                       {
                        bins enable= {1};
                        bins dis_able= {0};
                      }
      cov_efuse_mr : coverpoint efuse_vif.ip_MR 
                       {
                        bins enable= {1};
                        bins dis_able= {0};
                      }
      cross_efuse_load_mr:cross cov_efuse_mr,cov_efuse_load
                      {
                         ignore_bins unvalid= binsof(cov_efuse_load.dis_able);
                      }
      cov_efuse_pd : coverpoint efuse_vif.ip_PD 
                       {
                        bins enable= {1};
                        bins dis_able= {0};
                      }
      cov_efuse_rwl : coverpoint efuse_vif.ip_RWL 
                       {
                        bins enable= {1};
                        bins dis_able= {0};
                      }
      cov_efuse_rsb : coverpoint efuse_vif.ip_RSB 
                       {
                        bins enable= {0};
                        bins dis_able= {1};
                      }
      cross_efuse_rwl_csb:cross cov_efuse_rwl,cov_efuse_rsb,cov_efuse_csb
                      {
                         ignore_bins unvalid_1= binsof(cov_efuse_rsb.dis_able);
                         ignore_bins unvalid_2= binsof(cov_efuse_csb.dis_able);
                      }
      cov_efuse_addr : coverpoint efuse_vif.ip_A 
                       {
                        bins efuse_addr[]= {[0:1023]};    
                      }
      cov_efuse_test_addr : coverpoint efuse_vif.ip_AT 
                       {
                        bins test_addr[]= {0,2,3};    
                      }
      cov_efuse_trcs : coverpoint efuse_vif.ip_TRCS 
                       {
                         bins enable= {1};
                         bins dis_able= {0};   
                      }
      cross_test_address:cross cov_efuse_test_addr,cov_efuse_trcs,cov_efuse_strobe,cov_efuse_pgenb{
                        ignore_bins unvalid_1= binsof(cov_efuse_trcs.dis_able);
                        ignore_bins unvalid_2= binsof(cov_efuse_strobe.dis_able);
                        ignore_bins unvalid_3= binsof(cov_efuse_pgenb.dis_able);
                      }
    
      cross_address_data:cross cov_efuse_addr,cov_efuse_pgenb,cov_efuse_strobe{
                        ignore_bins unvalid_1= binsof(cov_efuse_pgenb.dis_able);
                        ignore_bins unvalid_2= binsof(cov_efuse_strobe.dis_able);
                      }


    endgroup

   covergroup cg_efuse_strobe_timer;
     option.per_instance = 0;

     cov_efuse_reg_strobe_timer_we : coverpoint efuse_vif.reg_strobe_timer_we;
     cov_efuse_reg_strobe_timer : coverpoint efuse_vif.reg_strobe_timer 
                      {
                        bins rd_region = {[1:20]};
                        bins wr_region = {[112:132]};
                    }
    cross_strobe_timer_we:cross cov_efuse_reg_strobe_timer,cov_efuse_reg_strobe_timer_we{
                ignore_bins unvalid= binsof(cov_efuse_reg_strobe_timer_we)intersect{0};
               
              }
   endgroup


  function new(string name, uvm_component parent);
    begin
    super.new(name, parent);
    
    cg_efuse_Ctrl		=new();
    cg_efuse_strobe_timer		=new();
    mon2cov = new("mon2cov",this);
    end
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual efuse_if)::get(this , "" , "efuse_vif" ,efuse_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction
  
  function void write(efuse_coverage_item t); 
   req_h = t;
   cg_efuse_Ctrl.sample();
   cg_efuse_strobe_timer.sample();
  
   
  endfunction

endclass

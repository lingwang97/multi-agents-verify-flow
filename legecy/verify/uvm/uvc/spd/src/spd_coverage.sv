class spd_coverage extends uvm_subscriber #(spd_coverage_item);
 
   `uvm_component_utils(spd_coverage)
  
   uvm_analysis_imp #(spd_coverage_item, spd_coverage)  mon2cov;

   virtual spd_if spd_vif;
   spd_coverage_item req_h;
   logic [2:0] lfb_state_cur;
   logic        self_aging_en;
   string report_id = "spd_coverage";


    covergroup cg_spd_global;
      option.per_instance = 0;
      cov_ssdn_protect : coverpoint spd_vif.ssdn_protect;
      cov_global_spd_en : coverpoint spd_vif.global_spd_en;
      cov_glb_limit: coverpoint spd_vif.REG_glb_limit;
      cov_cro_spden_limit: cross cov_global_spd_en, cov_glb_limit;

      //spd limit & spd_fifo adding case

      cov_global_set_vld : coverpoint spd_vif.global_set_vld{
          bins EN= {1};
          bins NEN={0}; 
      }
      cov_global_set : coverpoint spd_vif.global_set{
          bins L1 = {3'h1};
          bins L2 = {3'h2};
          bins L3 = {3'h3};
          bins L4 = {3'h4};
      }
      cov_ssdn_en: cross cov_ssdn_protect, cov_global_spd_en{
          ignore_bins unuseful = binsof(cov_global_spd_en) intersect {0};
      }
      cov_spd_vld_set: cross cov_global_set_vld, cov_global_set{
          bins VLD_SET1 = binsof(cov_global_set.L1) && binsof(cov_global_set_vld.EN);
          bins VLD_SET2 = binsof(cov_global_set.L2) && binsof(cov_global_set_vld.EN);
          bins VLD_SET3 = binsof(cov_global_set.L3) && binsof(cov_global_set_vld.EN);
          bins VLD_SET4 = binsof(cov_global_set.L4) && binsof(cov_global_set_vld.EN);
      }
      cov_global_spd_high : coverpoint spd_vif.global_spd_high {
                  bins H1 = {1};
                  bins H2 = {2};
                  bins H3 = {3};
                  bins H4 = {4};
      }
      cov_global_spd_low : coverpoint spd_vif.global_spd_low{
                  bins L1 = {1};
                  bins L2 = {2};
                  bins L3 = {3};
                  bins L4 = {4};
                  bins Low = {[5:7]};
      }
      cov_global_spd_highlow_cross : cross cov_global_spd_high, cov_global_spd_low{
                  option.cross_auto_bin_max = 0;
                  bins H2L1 = binsof(cov_global_spd_high.H2) && binsof(cov_global_spd_low.L1);
                  bins H3L1 = binsof(cov_global_spd_high.H3) && binsof(cov_global_spd_low.L1);
                  bins H3L2 = binsof(cov_global_spd_high.H3) && binsof(cov_global_spd_low.L2);
                  bins H4L1 = binsof(cov_global_spd_high.H4) && binsof(cov_global_spd_low.L1);
                  bins H4L2 = binsof(cov_global_spd_high.H4) && binsof(cov_global_spd_low.L2);
                  bins H4L3 = binsof(cov_global_spd_high.H4) && binsof(cov_global_spd_low.L3);
                  bins H4LOW = binsof(cov_global_spd_high.H4) && binsof(cov_global_spd_low.Low);
      }

    endgroup


    covergroup cg_th0;
      
      cov_th_pass : coverpoint spd_vif.th_pass {    
              bins LOW = {[0: 16'h4fff]};
              bins MID = {[16'h7fff: 16'h8fff]};
              bins HIGH = {[16'hefff: 16'hffff]};
                                                  }
      cov_th_fail : coverpoint spd_vif.th_fail {  

              bins LOW = {[0: 16'h4fff]};
              bins MID = {[16'h7fff: 16'h8fff]};
              bins HIGH = {[16'hefff: 16'hffff]};
                                                  }
      cov_th_passfail_cross : cross cov_th_pass, cov_th_fail;

      // port from legacy
      //the num needed to spd_up
      spd_up_times: coverpoint ( {1'b1,16'h0} - spd_vif.th_init ) / spd_vif.th_pass
      {
          ignore_bins times_0 = {0};                     
          bins times_1 = {1};                     
          bins times_2_5 = {[2:5]};               
          bins times_6_10 = {[6:10]};             
          // bins times_11_50 = {[11:50]};           
          // bins times_51_100 = {[51:100]};         
          option.weight = 0;
      }
      //the num needed to spd_down
      spd_down_times_cp: coverpoint spd_vif.th_init/ spd_vif.th_fail
      {

          ignore_bins times_0 = {0};                     
          bins times_1 = {1};                     
          bins times_2_5 = {[2:5]};                 
          bins times_6_10 = {[6:10]};          
          // bins times_11_50 = {[11:50]};           
          // bins times_51_100 = {[51:100]};     
          option.weight = 0;
      }
      
      th_init_pass_cmp: coverpoint {1'b0,spd_vif.th_init}+{1'b0,spd_vif.th_pass}
      {
          wildcard bins all_upflow_gt = {17'b1_????_????_????_????};
          //bins all_upflow_eq = {17'b1_0000_0000_0000_0000};
          wildcard bins no_upflow     = {17'b0_????_????_????_????};
          option.weight = 0;
      } 

      th_init_fail_cmp: coverpoint {1'b1,spd_vif.th_init}-{1'b0,spd_vif.th_fail}
      {
          wildcard bins all_downflow_lt = {17'b1_????_????_????_????};
          //bins all_downflow_eq = {17'b1_0000_0000_0000_0000};
          wildcard bins no_downflow     = {17'b0_????_????_????_????};
          option.weight = 0;
      }

      th_pass_fail_cmp: coverpoint {1'b1,spd_vif.th_pass}-{1'b0,spd_vif.th_fail}
      {
        wildcard bins all_downflow_lt = {17'b1_????_????_????_????};
        //bins all_downflow_eq = {17'b1_0000_0000_0000_0000};
        wildcard bins no_downflow     = {17'b0_????_????_????_????};
        option.weight = 0;
      }

      th_pass_fail_times: coverpoint spd_vif.th_pass/spd_vif.th_fail {
        bins times1 = {1};
        bins times2_5 = {[2:5]};
        bins times5_10 = {[5:10]};
        // bins times10_20 = {[10:20]};
        // bins times20_50 = {[20:50]};
      }
      th_fail_pass_times: coverpoint spd_vif.th_fail/spd_vif.th_pass {
        bins times1 = {1};
        bins times2_5 = {[2:5]};
        bins times5_10 = {[5:10]};
        // bins times10_20 = {[10:20]};
        // bins times20_50 = {[20:50]};
      }

    endgroup

    covergroup cg_aging_th0;
      
      cov_th_pass : coverpoint spd_vif.th_pass {    
              bins LOW = {[0: 16'h4fff]};
              bins MID = {[16'h7fff: 16'h8fff]};
              bins HIGH = {[16'hefff: 16'hffff]};
                                                  }
      cov_th_fail : coverpoint spd_vif.th_fail {  

              bins LOW = {[0: 16'h4fff]};
              bins MID = {[16'h7fff: 16'h8fff]};
              bins HIGH = {[16'hefff: 16'hffff]};
                                                  }
      cov_th_passfail_cross : cross cov_th_pass, cov_th_fail;

   
      th_init_pass_cmp: coverpoint {1'b0,spd_vif.th_init}+{1'b0,spd_vif.th_pass}
      {
          wildcard bins all_upflow_gt = {17'b1_????_????_????_????};
          //bins all_upflow_eq = {17'b1_0000_0000_0000_0000};
          wildcard bins no_upflow     = {17'b0_????_????_????_????};
          option.weight = 0;
      } 

      th_init_fail_cmp: coverpoint {1'b1,spd_vif.th_init}-{1'b0,spd_vif.th_fail}
      {
          wildcard bins all_downflow_lt = {17'b1_????_????_????_????};
          //bins all_downflow_eq = {17'b1_0000_0000_0000_0000};
          wildcard bins no_downflow     = {17'b0_????_????_????_????};
          option.weight = 0;
      }

      th_pass_fail_cmp: coverpoint {1'b1,spd_vif.th_pass}-{1'b0,spd_vif.th_fail}
      {
        wildcard bins all_downflow_lt = {17'b1_????_????_????_????};
        //bins all_downflow_eq = {17'b1_0000_0000_0000_0000};
        wildcard bins no_downflow     = {17'b0_????_????_????_????};
        option.weight = 0;
      }

    endgroup

    covergroup cg_th1;
      cov_th_ms_sel : coverpoint spd_vif.th_ms_sel;
      


      cov_th_init : coverpoint spd_vif.th_init {
              //bins ZERO = {0};
              bins LOW = {[1: 16'h0fff]};
              bins MID = {[16'h7fff: 16'h8fff]};
              bins HIGH = {[16'hefff: 16'hffff-1]};
                                                }
    endgroup

    covergroup cg_aging_th1;
      cov_th_ms_sel : coverpoint spd_vif.th_ms_sel;
      cov_th_init : coverpoint spd_vif.th_init {
              
              bins LOW = {[1: 16'h0fff]};
              bins MID = {[16'h7fff: 16'h8fff]};
              bins HIGH = {[16'hefff: 16'hffff-1]};
                                                }
    endgroup

    //
    covergroup cg_th2;
      cov_th_to : coverpoint spd_vif.th_to {
              bins LOW = {[32'h0000_0000: 32'h2000_0000]};
              bins MID = {[32'h7000_0000: 32'h8000_0000]};
              bins HIGH = {[32'he000_0000: 32'hffff_ffff]}; 
                                            }
      
    endgroup

    covergroup cg_aging_th2;
      cov_th_to : coverpoint spd_vif.th_to {
              bins LOW = {[32'h0000_0000: 32'h2000_0000]};
              bins MID = {[32'h7000_0000: 32'h8000_0000]};
              bins HIGH = {[32'he000_0000: 32'hffff_ffff]}; 
                                            }
    endgroup

    covergroup cg_ths;
      cov_lv2_th_ms_add : coverpoint spd_vif.lv2_th_ms_add;
      lv2_th_ms : coverpoint spd_vif.lv2_th_ms {

              bins LOW = {[0: 15'h1fff]};
              bins MID = {[15'h3fff: 15'h5fff]}; 
              bins HIGH = {[15'h5fff: 15'h7fff]};
                                              }

      cov_lv2_th_cross: cross cov_lv2_th_ms_add, lv2_th_ms;
      
      cov_lv1_th_ms_add : coverpoint spd_vif.lv1_th_ms_add;
      lv1_th_ms : coverpoint spd_vif.lv1_th_ms {
              bins LOW = {[0: 15'h1fff]};
              bins MID = {[15'h3fff: 15'h5fff]}; 
              bins HIGH = {[15'h5fff: 15'h7fff]};
                                              }
      cov_lv1_th_cross: cross cov_lv1_th_ms_add, lv1_th_ms;

      cov_mssel_ms1: cross spd_vif.th_ms_sel, lv1_th_ms
      {
        bins ms1_all = cov_mssel_ms1 with (spd_vif.th_ms_sel==1);
      }

      cov_lv4_th_ms_add : coverpoint spd_vif.lv4_th_ms_add;
      lv4_th_ms : coverpoint spd_vif.lv4_th_ms {
              bins LOW = {[0: 15'h1fff]};
              bins MID = {[15'h3fff: 15'h5fff]}; 
              bins HIGH = {[15'h5fff: 15'h7fff]};
                                              }
      cov_lv4_th_cross: cross cov_lv4_th_ms_add, lv4_th_ms;
      
      cov_lv3_th_ms_add : coverpoint spd_vif.lv3_th_ms_add;
      lv3_th_ms : coverpoint spd_vif.lv3_th_ms {
              bins LOW = {[0: 15'h1fff]};
              bins MID = {[15'h3fff: 15'h5fff]}; 
              bins HIGH = {[15'h5fff: 15'h7fff]};
                                              }
      cov_lv3_th_cross: cross cov_lv3_th_ms_add, lv3_th_ms;

      // the add or sub flag combinations
      cov_th_ms_add12_cross: cross spd_vif.lv1_th_ms_add, spd_vif.lv2_th_ms_add;
      cov_th_ms_add13_cross: cross spd_vif.lv1_th_ms_add, spd_vif.lv3_th_ms_add;
      cov_th_ms_add14_cross: cross spd_vif.lv1_th_ms_add, spd_vif.lv4_th_ms_add;
      cov_th_ms_add23_cross: cross spd_vif.lv2_th_ms_add, spd_vif.lv3_th_ms_add;
      cov_th_ms_add24_cross: cross spd_vif.lv2_th_ms_add, spd_vif.lv4_th_ms_add;
      cov_th_ms_add34_cross: cross spd_vif.lv3_th_ms_add, spd_vif.lv4_th_ms_add;
      // the value combinations
      cov_th_ms12_cross: cross lv1_th_ms, lv2_th_ms;
      cov_th_ms13_cross: cross lv1_th_ms, lv3_th_ms;
      cov_th_ms14_cross: cross lv1_th_ms, lv4_th_ms;
      cov_th_ms23_cross: cross lv2_th_ms, lv3_th_ms;
      cov_th_ms24_cross: cross lv2_th_ms, lv4_th_ms;
      cov_th_ms34_cross: cross lv3_th_ms, lv4_th_ms;


      //thms th_init combinations
      cov_thinit_thms1_cross: coverpoint spd_vif.th_init/spd_vif.lv1_th_ms {
          bins times1 = {1};
          bins times2_5 = {[2:5]};
          bins times5_10 = {[6:10]};
          bins times10_20 = {[11:20]};
      }
      cov_thinit_thms2_cross: coverpoint spd_vif.th_init/spd_vif.lv2_th_ms {
          bins times1 = {1};
          bins times2_5 = {[2:5]};
          bins times5_10 = {[6:10]};
          bins times10_20 = {[11:20]};
      }
      cov_thinit_thms3_cross: coverpoint spd_vif.th_init/spd_vif.lv3_th_ms {
          bins times1 = {1};
          bins times2_5 = {[2:5]};
          bins times5_10 = {[6:10]};
          bins times10_20 = {[11:20]};
      }
      cov_thinit_thms4_cross: coverpoint spd_vif.th_init/spd_vif.lv4_th_ms {
          bins times1 = {1};
          bins times2_5 = {[2:5]};
          bins times5_10 = {[6:10]};
          bins times10_20 = {[11:20]};
      }
    
    endgroup

    covergroup cg_aging_thms;
      cov_lv1_th_ms_add : coverpoint spd_vif.lv1_th_ms_add;
      lv1_th_ms : coverpoint spd_vif.lv1_th_ms {
              bins LOW = {[0: 15'h1fff]};
              bins MID = {[15'h3fff: 15'h5fff]}; 
              bins HIGH = {[15'h5fff: 15'h7fff]};
                                              }        
      cov_lv1_th_cross: cross cov_lv1_th_ms_add, lv1_th_ms;
      
      cov_mssel_ms1: cross spd_vif.th_ms_sel, lv1_th_ms
      {
        bins ms1_all = cov_mssel_ms1 with (spd_vif.th_ms_sel==1);
      }

      cov_lv2_th_ms_add : coverpoint spd_vif.lv2_th_ms_add;
      lv2_th_ms : coverpoint spd_vif.lv2_th_ms {

              bins LOW = {[0: 15'h1fff]};
              bins MID = {[15'h3fff: 15'h5fff]}; 
              bins HIGH = {[15'h5fff: 15'h7fff]};
                                              }
      cov_lv2_th_cross: cross cov_lv2_th_ms_add, lv2_th_ms;

      cov_lv3_th_ms_add : coverpoint spd_vif.lv3_th_ms_add;
      lv3_th_ms : coverpoint spd_vif.lv3_th_ms {
              bins LOW = {[0: 15'h1fff]};
              bins MID = {[15'h3fff: 15'h5fff]}; 
              bins HIGH = {[15'h5fff: 15'h7fff]};
                                              }
      cov_lv3_th_cross: cross cov_lv3_th_ms_add, lv3_th_ms;     
      
      cov_lv4_th_ms_add : coverpoint spd_vif.lv4_th_ms_add;
      lv4_th_ms : coverpoint spd_vif.lv4_th_ms {
              bins LOW = {[0: 15'h1fff]};
              bins MID = {[15'h3fff: 15'h5fff]}; 
              bins HIGH = {[15'h5fff: 15'h7fff]};
                                              }
      cov_lv4_th_cross: cross cov_lv4_th_ms_add, lv4_th_ms;
      
    endgroup

    covergroup cg_aging_spd_trans;
        cov_aging_trans: coverpoint spd_vif.self_aging_to_spd
       {
            bins TRANS0 = {2'b01}; 
            bins TRANS1 = {2'b10};      
       }  
    endgroup

    covergroup cg_plltable;
      cov_plltable_lv0 : coverpoint spd_vif.plltable_lv0 {
                bins SPD0 = {0};
                bins SPD1 = {1};
                bins SPD2 = {2};
                bins SPD3 = {3};
                bins SPD4 = {4};
                                            }
      cov_plltable_lv1 : coverpoint spd_vif.plltable_lv1 {
                bins SPD0 = {0};
                bins SPD1 = {1};
                bins SPD2 = {2};
                bins SPD3 = {3};
                bins SPD4 = {4};
                                            }
      cov_plltable_lv2 : coverpoint spd_vif.plltable_lv2 {
                bins SPD0 = {0};
                bins SPD1 = {1};
                bins SPD2 = {2};
                bins SPD3 = {3};
                bins SPD4 = {4};
                                            }
      cov_plltable_lv3 : coverpoint spd_vif.plltable_lv3 {
                bins SPD0 = {0};
                bins SPD1 = {1};
                bins SPD2 = {2};
                bins SPD3 = {3};
                bins SPD4 = {4};
                                            }
      cov_plltable_lv4 : coverpoint spd_vif.plltable_lv4 {
                bins SPD5 = {5};
                bins SPD6 = {6};
                bins SPD7 = {7};
                                            }
      cov_plltable_lv5 : coverpoint spd_vif.plltable_lv5 {
                bins SPD5 = {5};
                bins SPD6 = {6};
                bins SPD7 = {7};
                                            }
      cov_plltable_lv6 : coverpoint spd_vif.plltable_lv6 {
                bins SPD5 = {5};
                bins SPD6 = {6};
                bins SPD7 = {7};
                                            }

      cov_spd_cross: cross cov_plltable_lv0, cov_plltable_lv1, cov_plltable_lv2, cov_plltable_lv3{
            ignore_bins pll1_0 = binsof(cov_plltable_lv0.SPD0);
            ignore_bins pll2_0 = binsof(cov_plltable_lv1.SPD0);
            ignore_bins pll3_0 = binsof(cov_plltable_lv2.SPD0);
            ignore_bins pll4_0 = binsof(cov_plltable_lv3.SPD0);          
        }
      cov_spdlow_cross: cross cov_plltable_lv4, cov_plltable_lv5, cov_plltable_lv6;
      
    endgroup

    covergroup cg_spdlog_timer; 
      cov_timer_stop : coverpoint spd_vif.timer_stop; 
      cov_spdlog_timer_on : coverpoint spd_vif.spdlog_timer_on;
      cov_spdlog_timer : coverpoint spd_vif.spdlog_timer {
                  bins LOW = {[1:16'h0fff]};
                  //understand and add case after
                  bins MID = {[16'h5fff: 16'hafff]};
                  bins HIGH = {[16'hefff:16'hffff-1]};
                                                          }

      spdlog_timer_on_cross : cross cov_spdlog_timer_on, cov_spdlog_timer{
          ignore_bins OFF = binsof(cov_spdlog_timer_on) intersect {1'b0};
      }
      spdlog_timer_stop_cross : cross cov_timer_stop, cov_spdlog_timer{
          ignore_bins OFF = binsof(cov_timer_stop) intersect {1'b0};
      }
    endgroup



    covergroup cg_spd_distribution;

      SPD_DIS_0: coverpoint spd_vif.REG_Spd[(`DESIGN_CORE_NUM/10*0)*4+:4]{
        bins S1 = {1};
        bins S2 = {2};
        bins S3 = {3};
        bins S4 = {4};
        bins S5 = {5};
        bins S6 = {6};
        bins S7 = {7};
        bins norm2low=(4'd1 => 4'd7);
        bins low2norm=(4'd7 => 4'd1);
      }
      SPD_DIS_01: coverpoint spd_vif.REG_Spd[(`DESIGN_CORE_NUM/10*0+1)*4+:4]{
        bins S1 = {1};
        bins S2 = {2};
        bins S3 = {3};
        bins S4 = {4};
        bins S5 = {5};
        bins S6 = {6};
        bins S7 = {7};
        bins norm2low=(4'd1 => 4'd7);
        bins low2norm=(4'd7 => 4'd1);
      }
      SPD_DIS_1: coverpoint spd_vif.REG_Spd[(`DESIGN_CORE_NUM/10*1)*4+:4]{
        bins S1 = {1};
        bins S2 = {2};
        bins S3 = {3};
        bins S4 = {4};
        bins S5 = {5};
        bins S6 = {6};
        bins S7 = {7};
        bins norm2low=(4'd1 => 4'd7);
        bins low2norm=(4'd7 => 4'd1);
      }
      SPD_DIS_12: coverpoint spd_vif.REG_Spd[(`DESIGN_CORE_NUM/10*1+2)*4+:4]{
        bins S1 = {1};
        bins S2 = {2};
        bins S3 = {3};
        bins S4 = {4};
        bins S5 = {5};
        bins S6 = {6};
        bins S7 = {7};
        bins norm2low=(4'd1 => 4'd7);
        bins low2norm=(4'd7 => 4'd1);
      }
      SPD_DIS_2: coverpoint spd_vif.REG_Spd[(`DESIGN_CORE_NUM/10*2)*4+:4]{
        bins S1 = {1};
        bins S2 = {2};
        bins S3 = {3};
        bins S4 = {4};
        bins S5 = {5};
        bins S6 = {6};
        bins S7 = {7};
        bins norm2low=(4'd1 => 4'd7);
        bins low2norm=(4'd7 => 4'd1);
      }
      SPD_DIS_23: coverpoint spd_vif.REG_Spd[(`DESIGN_CORE_NUM/10*2+3)*4+:4]{
        bins S1 = {1};
        bins S2 = {2};
        bins S3 = {3};
        bins S4 = {4};
        bins S5 = {5};
        bins S6 = {6};
        bins S7 = {7};
        bins norm2low=(4'd1 => 4'd7);
        bins low2norm=(4'd7 => 4'd1);
      }
      SPD_DIS_3: coverpoint spd_vif.REG_Spd[(`DESIGN_CORE_NUM/10*3)*4+:4]{
        bins S1 = {1};
        bins S2 = {2};
        bins S3 = {3};
        bins S4 = {4};
        bins S5 = {5};
        bins S6 = {6};
        bins S7 = {7};
        bins norm2low=(4'd1 => 4'd7);
        bins low2norm=(4'd7 => 4'd1);
      }
      SPD_DIS_4: coverpoint spd_vif.REG_Spd[(`DESIGN_CORE_NUM/10*4)*4+:4]{
        bins S1 = {1};
        bins S2 = {2};
        bins S3 = {3};
        bins S4 = {4};
        bins S5 = {5};
        bins S6 = {6};
        bins S7 = {7};
        bins norm2low=(4'd1 => 4'd7);
        bins low2norm=(4'd7 => 4'd1);
      }
      SPD_DIS_5: coverpoint spd_vif.REG_Spd[(`DESIGN_CORE_NUM/10*5)*4+:4]{
        bins S1 = {1};
        bins S2 = {2};
        bins S3 = {3};
        bins S4 = {4};
        bins S5 = {5};
        bins S6 = {6};
        bins S7 = {7};
        bins norm2low=(4'd1 => 4'd7);
        bins low2norm=(4'd7 => 4'd1);
      }
      SPD_DIS_6: coverpoint spd_vif.REG_Spd[(`DESIGN_CORE_NUM/10*6)*4+:4]{
        bins S1 = {1};
        bins S2 = {2};
        bins S3 = {3};
        bins S4 = {4};
        bins S5 = {5};
        bins S6 = {6};
        bins S7 = {7};
        bins norm2low=(4'd1 => 4'd7);
        bins low2norm=(4'd7 => 4'd1);
      }
      SPD_DIS_7: coverpoint spd_vif.REG_Spd[(`DESIGN_CORE_NUM/10*7)*4+:4]{
        bins S1 = {1};
        bins S2 = {2};
        bins S3 = {3};
        bins S4 = {4};
        bins S5 = {5};
        bins S6 = {6};
        bins S7 = {7};
        bins norm2low=(4'd1 => 4'd7);
        bins low2norm=(4'd7 => 4'd1);
      }
      SPD_DIS_82: coverpoint spd_vif.REG_Spd[(`DESIGN_CORE_NUM/10*8-2)*4+:4]{
        bins S1 = {1};
        bins S2 = {2};
        bins S3 = {3};
        bins S4 = {4};
        bins S5 = {5};
        bins S6 = {6};
        bins S7 = {7};
        bins norm2low=(4'd1 => 4'd7);
        bins low2norm=(4'd7 => 4'd1);
      }
      SPD_DIS_8: coverpoint spd_vif.REG_Spd[(`DESIGN_CORE_NUM/10*8)*4+:4]{
        bins S1 = {1};
        bins S2 = {2};
        bins S3 = {3};
        bins S4 = {4};
        bins S5 = {5};
        bins S6 = {6};
        bins S7 = {7};
        bins norm2low=(4'd1 => 4'd7);
        bins low2norm=(4'd7 => 4'd1);
      }
      SPD_DIS_91: coverpoint spd_vif.REG_Spd[(`DESIGN_CORE_NUM/10*9-1)*4+:4]{
        bins S1 = {1};
        bins S2 = {2};
        bins S3 = {3};
        bins S4 = {4};
        bins S5 = {5};
        bins S6 = {6};
        bins S7 = {7};
        bins norm2low=(4'd1 => 4'd7);
        bins low2norm=(4'd7 => 4'd1);
      }
      SPD_DIS_9: coverpoint spd_vif.REG_Spd[(`DESIGN_CORE_NUM/10*9)*4+:4]{
        bins S1 = {1};
        bins S2 = {2};
        bins S3 = {3};
        bins S4 = {4};
        bins S5 = {5};
        bins S6 = {6};
        bins S7 = {7};
        bins norm2low=(4'd1 => 4'd7);
        bins low2norm=(4'd7 => 4'd1);
      }
      SPD_DIS_10: coverpoint spd_vif.REG_Spd[(`DESIGN_CORE_NUM-1)*4+:4]{
        bins S1 = {1};
        bins S2 = {2};
        bins S3 = {3};
        bins S4 = {4};
        bins S5 = {5};
        bins S6 = {6};
        bins S7 = {7};
        bins norm2low=(4'd1 => 4'd7);
        bins low2norm=(4'd7 => 4'd1);
      }

    endgroup

    covergroup cg_passfail_local;
      pass_local0: coverpoint spd_vif.pass_local[`DESIGN_CORE_NUM/10*0] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      pass_local01: coverpoint spd_vif.pass_local[`DESIGN_CORE_NUM/10*0+1] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      pass_local1: coverpoint spd_vif.pass_local[`DESIGN_CORE_NUM/10*1] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      pass_local12: coverpoint spd_vif.pass_local[`DESIGN_CORE_NUM/10*1+2] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      pass_local2: coverpoint spd_vif.pass_local[`DESIGN_CORE_NUM/10*2] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      pass_local3: coverpoint spd_vif.pass_local[`DESIGN_CORE_NUM/10*3] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      pass_local4: coverpoint spd_vif.pass_local[`DESIGN_CORE_NUM/10*4] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      pass_local5: coverpoint spd_vif.pass_local[`DESIGN_CORE_NUM/10*5] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      pass_local6: coverpoint spd_vif.pass_local[`DESIGN_CORE_NUM/10*6] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      pass_local7: coverpoint spd_vif.pass_local[`DESIGN_CORE_NUM/10*7] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      pass_local82: coverpoint spd_vif.pass_local[`DESIGN_CORE_NUM/10*8-2] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      pass_local8: coverpoint spd_vif.pass_local[`DESIGN_CORE_NUM/10*8] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      pass_local91: coverpoint spd_vif.pass_local[`DESIGN_CORE_NUM-2] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      pass_local9: coverpoint spd_vif.pass_local[`DESIGN_CORE_NUM-1] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }

      fail_local0: coverpoint spd_vif.fail_local[`DESIGN_CORE_NUM/10*0] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      fail_local01: coverpoint spd_vif.fail_local[`DESIGN_CORE_NUM/10*0+1] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      fail_local1: coverpoint spd_vif.fail_local[`DESIGN_CORE_NUM/10*1] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      fail_local12: coverpoint spd_vif.fail_local[`DESIGN_CORE_NUM/10*1+2] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      fail_local2: coverpoint spd_vif.fail_local[`DESIGN_CORE_NUM/10*2] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      fail_local3: coverpoint spd_vif.fail_local[`DESIGN_CORE_NUM/10*3] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      fail_local4: coverpoint spd_vif.fail_local[`DESIGN_CORE_NUM/10*4] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      fail_local5: coverpoint spd_vif.fail_local[`DESIGN_CORE_NUM/10*5] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      fail_local6: coverpoint spd_vif.fail_local[`DESIGN_CORE_NUM/10*6] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      fail_local7: coverpoint spd_vif.fail_local[`DESIGN_CORE_NUM/10*7] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      fail_local8: coverpoint spd_vif.fail_local[`DESIGN_CORE_NUM/10*8] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      fail_local82: coverpoint spd_vif.fail_local[`DESIGN_CORE_NUM/10*8-2] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      fail_local91: coverpoint spd_vif.fail_local[`DESIGN_CORE_NUM-2] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
      fail_local9: coverpoint spd_vif.fail_local[`DESIGN_CORE_NUM-1] {
        bins LOW = {[0:16'h0fff]};
        bins HIGH = {[16'hefff:16'hffff]};
      }
    
    endgroup

    covergroup cg_pllcnt;

      cov_pll3_cnt : coverpoint spd_vif.pll3_cnt {
                option.weight = 0;
                bins LOW = {[0: `DESIGN_CORE_NUM/3]};
                bins MID = {[`DESIGN_CORE_NUM/3: (`DESIGN_CORE_NUM/3)*2]};
                bins HIGH = {[(`DESIGN_CORE_NUM/3)*2: `DESIGN_CORE_NUM]};
                                                }
      cov_pll2_cnt : coverpoint spd_vif.pll2_cnt {
                option.weight = 0;
                bins LOW = {[0: `DESIGN_CORE_NUM/3]};
                bins MID = {[`DESIGN_CORE_NUM/3: (`DESIGN_CORE_NUM/3)*2]};
                bins HIGH = {[(`DESIGN_CORE_NUM/3)*2: `DESIGN_CORE_NUM]};
                                                }
      cov_pll1_cnt : coverpoint spd_vif.pll1_cnt {
                option.weight = 0;
                bins LOW = {[0: `DESIGN_CORE_NUM/3]};
                bins MID = {[`DESIGN_CORE_NUM/3: (`DESIGN_CORE_NUM/3)*2]};
                bins HIGH = {[(`DESIGN_CORE_NUM/3)*2: `DESIGN_CORE_NUM]};
                                                }
      cov_pll0_cnt : coverpoint spd_vif.pll0_cnt {
                option.weight = 0;
                bins LOW = {[0: `DESIGN_CORE_NUM/3]};
                bins MID = {[`DESIGN_CORE_NUM/3: (`DESIGN_CORE_NUM/3)*2]};
                bins HIGH = {[(`DESIGN_CORE_NUM/3)*2: `DESIGN_CORE_NUM]};
                                                }
      cov_pll_h1_cnt : coverpoint spd_vif.halfclk1_cnt {
                option.weight = 0;
                bins LOW = {[0: `DESIGN_CORE_NUM/3]};
                bins MID = {[`DESIGN_CORE_NUM/3: (`DESIGN_CORE_NUM/3)*2]};
                bins HIGH = {[(`DESIGN_CORE_NUM/3)*2: `DESIGN_CORE_NUM]};
                                                }
      cov_pll_h2_cnt : coverpoint spd_vif.halfclk2_cnt {
                option.weight = 0;
                bins LOW = {[0: `DESIGN_CORE_NUM/3]};
                bins MID = {[`DESIGN_CORE_NUM/3: (`DESIGN_CORE_NUM/3)*2]};
                bins HIGH = {[(`DESIGN_CORE_NUM/3)*2: `DESIGN_CORE_NUM]};
                                                }
      cov_pll_h3_cnt : coverpoint spd_vif.halfclk3_cnt {
                option.weight = 0;
                bins LOW = {[0: `DESIGN_CORE_NUM/3]};
                bins MID = {[`DESIGN_CORE_NUM/3: (`DESIGN_CORE_NUM/3)*2]};
                bins HIGH = {[(`DESIGN_CORE_NUM/3)*2: `DESIGN_CORE_NUM]};
                                                }

    endgroup

    covergroup cg_passfail_cnt; 
      cov_spdlog_passcnt : coverpoint spd_vif.spdlog_passcnt {
                  bins LOW = {[0:32'h0fffffff]};
                  bins HIGH = {[32'hefffffff:32'hffffffff]};
                                                            }
      cov_spdlog_failcnt : coverpoint spd_vif.spdlog_failcnt {
                  bins LOW = {[0:32'h0fffffff]};
                  bins HIGH = {[32'hefffffff:32'hffffffff]};
                                                            }
      cov_spdlog_passfail_cnt_cross: cross cov_spdlog_passcnt, cov_spdlog_failcnt;
    endgroup






    // For New Model

    covergroup cg_ss_set;
      cov_ss_sel: coverpoint spd_vif.ss_sel{
          bins SET={2'b10};
          bins UNSET={2'b01};
          bins HALF_EN={2'b11};
          bins TRANS0 = (2'b00 => 2'b01); 
          bins TRANS1 = (2'b01 => 2'b10); 
          bins TRANS2 = (2'b00 => 2'b10); 
          bins TRANS3 = (2'b10 => 2'b01); 
          bins TRANS4 = (2'b00 => 2'b11); 
          bins TRANS5 = (2'b01 => 2'b11); 
          bins TRANS6 = (2'b10 => 2'b11); 
          bins TRANS7 = (2'b11 => 2'b01); 
          bins TRANS8 = (2'b11 => 2'b10); 
      }
      cov_ss_pri: coverpoint spd_vif.ss_pri{
          bins SET={1'b1};
          bins UNSET={1'b0};
      }
      sel_pri_cross: cross cov_ss_sel, cov_ss_pri{
            option.cross_auto_bin_max = 0;
            bins SET1 = binsof(cov_ss_sel.SET) && binsof(cov_ss_pri.SET);
            bins SET2 = binsof(cov_ss_sel.SET) && binsof(cov_ss_pri.UNSET);
            bins SET3 = binsof(cov_ss_sel.HALF_EN) && binsof(cov_ss_pri.SET);
            bins SET4 = binsof(cov_ss_sel.HALF_EN) && binsof(cov_ss_pri.UNSET);
      }
      normal_trig: coverpoint spd_vif.REG_normal_trig_acc{
            bins LOW = {[8'd0:8'd16]};
            bins MID = {[8'd32:8'd64]};
            bins HIG = {[8'd96:8'hff]};
      }
      fail_trig: coverpoint spd_vif.REG_fail_trig_acc{
            bins LOW = {[8'd0:8'd16]};
            bins MID = {[8'd32:8'd64]};
            bins HIG = {[8'd96:8'hff]};
      }
      pass_trig: coverpoint spd_vif.REG_pass_trig_acc{
            bins LOW = {[8'd0:8'd16]};
            bins MID = {[8'd32:8'd64]};
            bins HIG = {[8'd96:8'hff]};
      }
      dh_cnt_timer: coverpoint spd_vif.REG_dh_cnt_wdt_timer{
            bins LOW = {[16'h0000: 16'h4000]};
            bins MID = {[16'h5000: 16'hB000]};
            bins HIG = {[16'hC000: 16'hF000]}; 
      }
      dh_cnt_wdt_on: coverpoint spd_vif.REG_dh_cnt_wdt_on{
            bins ON = {1'b1};
            bins OFF = {1'b0};
      }
      cro_dh_cnt_timer: cross dh_cnt_timer, dh_cnt_wdt_on{
            ignore_bins invalid = binsof(dh_cnt_wdt_on) intersect {0}; 
      }

    endgroup

    covergroup cg_ss_para;

      // hp=5%  lp=10%-15% hard>50%
      cov_ss_pd: coverpoint spd_vif.ss_pd{
          bins LOW = {[16'h0000:16'h0ff]};
          bins MID = {[16'h0140:16'h01ff]};
          bins HIGH = {[16'h0e00:16'h0fff]};
      }
      cov_th_hp: coverpoint spd_vif.th_hp{
          bins LOW = {[16'h0000:16'h00f]};
          bins MID = {[16'h001f:16'h02f]};
          bins HIGH = {[16'h00e0:16'h0ff]};
      }
      cov_th_lp: coverpoint spd_vif.th_lp{
          bins LOW = {[16'h0080:16'h008f]};
          bins MID = {[16'h00e0:16'h00ff]};
          bins HIGH = {[16'h0100:16'h0200]};
      }
      cov_th_dp: coverpoint spd_vif.th_dp{
          bins LOW = {[16'h0080:16'h008f]};
          bins MID = {[16'h00e0:16'h00ff]};
          bins HIGH = {[16'h0100:16'h0200]};
      }
      cov_rechk: coverpoint spd_vif.max_rechk{
          bins LOW = {[4'h0:4'h2]};
          bins MID = {[4'h7:4'h8]};
          bins HIGH = {[4'he:4'hf]};
      }
      cov_th_same: coverpoint spd_vif.th_same{
            bins ON={1'b1};  
            bins OFF={1'b0};  
      }
      cov_th_delta1: coverpoint spd_vif.th_delta1{
            bins LOW = {[0:50]};
            bins MID = {[100:200]};
            bins HIGH = {[500:1000]};
      }
      cov_th_delta2: coverpoint spd_vif.th_delta2{
            bins LOW = {[0:50]};
            bins MID = {[100:200]};
            bins HIGH = {[500:1000]};
     }
      cov_th_delta3: coverpoint spd_vif.th_delta3{
            bins LOW = {[0:50]};
            bins MID = {[100:200]};
            bins HIGH = {[500:1000]};
      }
      cov_th_delta4: coverpoint spd_vif.th_delta4{
            bins LOW = {[0:50]};
            bins MID = {[100:200]};
            bins HIGH = {[500:1000]};
      }
     
      hp_lp_cross: coverpoint (spd_vif.th_lp/spd_vif.th_hp){
            bins times_2to4 = {[2:4]};
            bins times_4to8 = {[4:8]};
            bins times_8to16 = {[8:16]};
      }

endgroup

covergroup cg_aging_ss_para;

      cov_ss_pd: coverpoint spd_vif.ss_pd{
          bins LOW = {[16'h0000:16'h000f]};
          bins MID = {[16'h0010:16'h01ff]};
      }

endgroup

localparam SS_IDLE                = 4'b0000;
localparam SS_WORK                = 4'b0001;
localparam SS_FAULT_SHOT_1        = 4'b0011;
localparam SS_RANGE_CHG           = 4'b0010;
localparam SS_DIAG                = 4'b0110;
localparam SS_SPD_CHG             = 4'b0111;
localparam SS_MONITOR             = 4'b0101;
localparam SS_FAULT_SHOT_2        = 4'b0100;
localparam SS_RELEASE             = 4'b1100;
localparam SS_RECHK               = 4'b1101;
localparam SS_SLC                 = 4'b1111;
localparam SS_REWARD              = 4'b1110;
localparam SS_TRY_UP              = 4'b1010;
localparam SS_TRY_MONI            = 4'b1011;
localparam SS_TRY_FAIL            = 4'b1001;

covergroup cg_ss_state;
      cov_state_trans0: coverpoint spd_vif.spd_state_cur[0]{
          bins SHAKE0 = (SS_WORK => SS_REWARD);
          bins SHAKE1 = (SS_REWARD => SS_WORK);
          bins WORK2FAULT1 = (SS_WORK => SS_FAULT_SHOT_1);
          bins MON2RELEASE = (SS_MONITOR => SS_RELEASE);
          bins MON2FAULT2 = (SS_MONITOR => SS_FAULT_SHOT_2);
          bins MON2MON = (SS_MONITOR => SS_MONITOR);
        
          bins FAULT22RECHK = (SS_FAULT_SHOT_2 => SS_RECHK);
          bins FAULT22SLC = (SS_FAULT_SHOT_2 => SS_SLC);
          bins FAULT22DIAG = (SS_FAULT_SHOT_2 => SS_DIAG);
          //after rst
          bins WORK2IDLE = (SS_WORK => SS_IDLE);
          bins MON2IDLE = (SS_MONITOR => SS_IDLE);
          bins UP2MONI = (SS_TRY_UP => SS_TRY_MONI);
          bins MONI2FAIL = (SS_TRY_MONI => SS_TRY_FAIL);
          //low
          bins FAULT1_TORANGE=(SS_FAULT_SHOT_1=>SS_RANGE_CHG);
      }
      cov_state_trans0a: coverpoint spd_vif.spd_state_cur[2]{
          bins SHAKE0 = (SS_WORK => SS_REWARD);
          bins SHAKE1 = (SS_REWARD => SS_WORK);
          bins WORK2FAULT1 = (SS_WORK => SS_FAULT_SHOT_1);
          bins MON2RELEASE = (SS_MONITOR => SS_RELEASE);
          bins MON2FAULT2 = (SS_MONITOR => SS_FAULT_SHOT_2);
          bins MON2MON = (SS_MONITOR => SS_MONITOR);
          
          bins FAULT22RECHK = (SS_FAULT_SHOT_2 => SS_RECHK);
          bins FAULT22SLC = (SS_FAULT_SHOT_2 => SS_SLC);
          bins FAULT22DIAG = (SS_FAULT_SHOT_2 => SS_DIAG);
          //after rst
          bins WORK2IDLE = (SS_WORK => SS_IDLE);
          bins MON2IDLE = (SS_MONITOR => SS_IDLE);
          bins UP2MONI = (SS_TRY_UP => SS_TRY_MONI);
          bins MONI2FAIL = (SS_TRY_MONI => SS_TRY_FAIL);
          //low
          bins FAULT1_TORANGE=(SS_FAULT_SHOT_1=>SS_RANGE_CHG);
      }

      cov_state_trans1: coverpoint spd_vif.spd_state_cur[`DESIGN_CORE_NUM/6*1]{
          bins SHAKE0 = (SS_WORK => SS_REWARD);
          bins SHAKE1 = (SS_REWARD => SS_WORK);
          bins WORK2FAULT1 = (SS_WORK => SS_FAULT_SHOT_1);
          bins MON2RELEASE = (SS_MONITOR => SS_RELEASE);
          bins MON2FAULT2 = (SS_MONITOR => SS_FAULT_SHOT_2);
          bins MON2MON = (SS_MONITOR => SS_MONITOR);
          
          bins FAULT22RECHK = (SS_FAULT_SHOT_2 => SS_RECHK);
          bins FAULT22SLC = (SS_FAULT_SHOT_2 => SS_SLC);
          bins FAULT22DIAG = (SS_FAULT_SHOT_2 => SS_DIAG);
          //after rst
          bins WORK2IDLE = (SS_WORK => SS_IDLE);
          bins MON2IDLE = (SS_MONITOR => SS_IDLE);
          bins UP2MONI = (SS_TRY_UP => SS_TRY_MONI);
          bins MONI2FAIL = (SS_TRY_MONI => SS_TRY_FAIL);
          //low
          bins FAULT1_TORANGE=(SS_FAULT_SHOT_1=>SS_RANGE_CHG);
      }
    cov_state_trans2: coverpoint spd_vif.spd_state_cur[`DESIGN_CORE_NUM/6*2]{
          bins SHAKE0 = (SS_WORK => SS_REWARD);
          bins SHAKE1 = (SS_REWARD => SS_WORK);
          bins WORK2FAULT1 = (SS_WORK => SS_FAULT_SHOT_1);
          bins MON2RELEASE = (SS_MONITOR => SS_RELEASE);
          bins MON2FAULT2 = (SS_MONITOR => SS_FAULT_SHOT_2);
          bins MON2MON = (SS_MONITOR => SS_MONITOR);
          
          bins FAULT22RECHK = (SS_FAULT_SHOT_2 => SS_RECHK);
          bins FAULT22SLC = (SS_FAULT_SHOT_2 => SS_SLC);
          bins FAULT22DIAG = (SS_FAULT_SHOT_2 => SS_DIAG);
          //after rst
          bins WORK2IDLE = (SS_WORK => SS_IDLE);
          bins MON2IDLE = (SS_MONITOR => SS_IDLE);
          bins UP2MONI = (SS_TRY_UP => SS_TRY_MONI);
          bins MONI2FAIL = (SS_TRY_MONI => SS_TRY_FAIL);
          //low
          bins FAULT1_TORANGE=(SS_FAULT_SHOT_1=>SS_RANGE_CHG);
      }
    cov_state_trans3: coverpoint spd_vif.spd_state_cur[`DESIGN_CORE_NUM/6*3]{
          bins SHAKE0 = (SS_WORK => SS_REWARD);
          bins SHAKE1 = (SS_REWARD => SS_WORK);
          bins WORK2FAULT1 = (SS_WORK => SS_FAULT_SHOT_1);
          bins MON2RELEASE = (SS_MONITOR => SS_RELEASE);
          bins MON2FAULT2 = (SS_MONITOR => SS_FAULT_SHOT_2);
          bins MON2MON = (SS_MONITOR => SS_MONITOR);
          
          bins FAULT22RECHK = (SS_FAULT_SHOT_2 => SS_RECHK);
          bins FAULT22SLC = (SS_FAULT_SHOT_2 => SS_SLC);
          bins FAULT22DIAG = (SS_FAULT_SHOT_2 => SS_DIAG);
          //after rst
          bins WORK2IDLE = (SS_WORK => SS_IDLE);
          bins MON2IDLE = (SS_MONITOR => SS_IDLE);
          bins UP2MONI = (SS_TRY_UP => SS_TRY_MONI);
          bins MONI2FAIL = (SS_TRY_MONI => SS_TRY_FAIL);
          //low
          bins FAULT1_TORANGE=(SS_FAULT_SHOT_1=>SS_RANGE_CHG);
      }
      cov_state_trans4: coverpoint spd_vif.spd_state_cur[`DESIGN_CORE_NUM/6*4]{
          bins SHAKE0 = (SS_WORK => SS_REWARD);
          bins SHAKE1 = (SS_REWARD => SS_WORK);
          bins WORK2FAULT1 = (SS_WORK => SS_FAULT_SHOT_1);
          bins MON2RELEASE = (SS_MONITOR => SS_RELEASE);
          bins MON2FAULT2 = (SS_MONITOR => SS_FAULT_SHOT_2);
          bins MON2MON = (SS_MONITOR => SS_MONITOR);
          
          bins FAULT22RECHK = (SS_FAULT_SHOT_2 => SS_RECHK);
          bins FAULT22SLC = (SS_FAULT_SHOT_2 => SS_SLC);
          bins FAULT22DIAG = (SS_FAULT_SHOT_2 => SS_DIAG);
          //after rst
          bins WORK2IDLE = (SS_WORK => SS_IDLE);
          bins MON2IDLE = (SS_MONITOR => SS_IDLE);
          bins UP2MONI = (SS_TRY_UP => SS_TRY_MONI);
          bins MONI2FAIL = (SS_TRY_MONI => SS_TRY_FAIL);
          //low
          bins FAULT1_TORANGE=(SS_FAULT_SHOT_1=>SS_RANGE_CHG);
      }
      cov_state_trans5: coverpoint spd_vif.spd_state_cur[`DESIGN_CORE_NUM/6*5]{
          bins SHAKE0 = (SS_WORK => SS_REWARD);
          bins SHAKE1 = (SS_REWARD => SS_WORK);
          bins WORK2FAULT1 = (SS_WORK => SS_FAULT_SHOT_1);
          bins MON2RELEASE = (SS_MONITOR => SS_RELEASE);
          bins MON2FAULT2 = (SS_MONITOR => SS_FAULT_SHOT_2);
          bins MON2MON = (SS_MONITOR => SS_MONITOR);
          
          bins FAULT22RECHK = (SS_FAULT_SHOT_2 => SS_RECHK);
          bins FAULT22SLC = (SS_FAULT_SHOT_2 => SS_SLC);
          bins FAULT22DIAG = (SS_FAULT_SHOT_2 => SS_DIAG);
          //after rst
          bins WORK2IDLE = (SS_WORK => SS_IDLE);
          bins MON2IDLE = (SS_MONITOR => SS_IDLE);
          bins UP2MONI = (SS_TRY_UP => SS_TRY_MONI);
          bins MONI2FAIL = (SS_TRY_MONI => SS_TRY_FAIL);
          //low
          bins FAULT1_TORANGE=(SS_FAULT_SHOT_1=>SS_RANGE_CHG);
      }
      cov_state_trans6b: coverpoint spd_vif.spd_state_cur[`DESIGN_CORE_NUM-2]{
          bins SHAKE0 = (SS_WORK => SS_REWARD);
          bins SHAKE1 = (SS_REWARD => SS_WORK);
          bins WORK2FAULT1 = (SS_WORK => SS_FAULT_SHOT_1);
          bins MON2RELEASE = (SS_MONITOR => SS_RELEASE);
          bins MON2FAULT2 = (SS_MONITOR => SS_FAULT_SHOT_2);
          bins MON2MON = (SS_MONITOR => SS_MONITOR);
          
          bins FAULT22RECHK = (SS_FAULT_SHOT_2 => SS_RECHK);
          bins FAULT22SLC = (SS_FAULT_SHOT_2 => SS_SLC);
          bins FAULT22DIAG = (SS_FAULT_SHOT_2 => SS_DIAG);
          //after rst
          bins WORK2IDLE = (SS_WORK => SS_IDLE);
          bins MON2IDLE = (SS_MONITOR => SS_IDLE);
          bins UP2MONI = (SS_TRY_UP => SS_TRY_MONI);
          bins MONI2FAIL = (SS_TRY_MONI => SS_TRY_FAIL);
          //low
          bins FAULT1_TORANGE=(SS_FAULT_SHOT_1=>SS_RANGE_CHG);
      }
     cov_state_trans6: coverpoint spd_vif.spd_state_cur[`DESIGN_CORE_NUM-1]{
          bins SHAKE0 = (SS_WORK => SS_REWARD);
          bins SHAKE1 = (SS_REWARD => SS_WORK);
          bins WORK2FAULT1 = (SS_WORK => SS_FAULT_SHOT_1);
          bins MON2RELEASE = (SS_MONITOR => SS_RELEASE);
          bins MON2FAULT2 = (SS_MONITOR => SS_FAULT_SHOT_2);
          bins MON2MON = (SS_MONITOR => SS_MONITOR);
                    
          bins FAULT22RECHK = (SS_FAULT_SHOT_2 => SS_RECHK);
          bins FAULT22SLC = (SS_FAULT_SHOT_2 => SS_SLC);
          bins FAULT22DIAG = (SS_FAULT_SHOT_2 => SS_DIAG);
          //after rst
          bins WORK2IDLE = (SS_WORK => SS_IDLE);
          bins MON2IDLE = (SS_MONITOR => SS_IDLE);
          bins UP2MONI = (SS_TRY_UP => SS_TRY_MONI);
          bins MONI2FAIL = (SS_TRY_MONI => SS_TRY_FAIL);
          //low
          bins FAULT1_TORANGE=(SS_FAULT_SHOT_1=>SS_RANGE_CHG);
      }

endgroup
localparam WORK_FLAG            = 3'b000;
localparam DIAG_FLAG        = 3'b001;
localparam RECHECK_FLAG         = 3'b010;
localparam SILENCE_FLAG         = 3'b011;

localparam HALF_WORK            =3'b111;
localparam HALF_OTHER           =3'b110;

localparam PLL_UNUSED           = 3'b000;
localparam PLL_USED             = 3'b001;
localparam PLL_INVALID          = 3'b010;
localparam PLL_TIMEOUT          = 3'b011;

covergroup cg_ss_sslog;
        pll0_status0: coverpoint spd_vif.pll0_status[0]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        pll1_status0: coverpoint spd_vif.pll1_status[0]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        pll2_status0: coverpoint spd_vif.pll2_status[0]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }
        pll3_status0: coverpoint spd_vif.pll3_status[0]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        pll0_status0a: coverpoint spd_vif.pll0_status[1]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        pll1_status0a: coverpoint spd_vif.pll1_status[1]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        pll2_status0a: coverpoint spd_vif.pll2_status[1]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }
        pll3_status0a: coverpoint spd_vif.pll3_status[1]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }
        pll0_status1: coverpoint spd_vif.pll0_status[`DESIGN_CORE_NUM/6*1]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        pll1_status1: coverpoint spd_vif.pll1_status[`DESIGN_CORE_NUM/6*1]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        pll2_status1: coverpoint spd_vif.pll2_status[`DESIGN_CORE_NUM/6*1]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }
        pll3_status1: coverpoint spd_vif.pll3_status[`DESIGN_CORE_NUM/6*1]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }
        pll0_status2: coverpoint spd_vif.pll0_status[`DESIGN_CORE_NUM/6*2]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        pll1_status2: coverpoint spd_vif.pll1_status[`DESIGN_CORE_NUM/6*2]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        pll2_status2: coverpoint spd_vif.pll2_status[`DESIGN_CORE_NUM/6*2]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }
        pll3_status2: coverpoint spd_vif.pll3_status[`DESIGN_CORE_NUM/6*2]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }
        pll0_status3: coverpoint spd_vif.pll0_status[`DESIGN_CORE_NUM/6*3]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        pll1_status3: coverpoint spd_vif.pll1_status[`DESIGN_CORE_NUM/6*3]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        pll2_status3: coverpoint spd_vif.pll2_status[`DESIGN_CORE_NUM/6*3]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }
        pll3_status3: coverpoint spd_vif.pll3_status[`DESIGN_CORE_NUM/6*3]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }
        pll0_status4: coverpoint spd_vif.pll0_status[`DESIGN_CORE_NUM/6*4]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        pll1_status4: coverpoint spd_vif.pll1_status[`DESIGN_CORE_NUM/6*4]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        pll2_status4: coverpoint spd_vif.pll2_status[`DESIGN_CORE_NUM/6*4]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }
        pll3_status4: coverpoint spd_vif.pll3_status[`DESIGN_CORE_NUM/6*4]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }
        pll0_status5: coverpoint spd_vif.pll0_status[`DESIGN_CORE_NUM/6*5]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        pll1_status5: coverpoint spd_vif.pll1_status[`DESIGN_CORE_NUM/6*5]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        pll2_status5: coverpoint spd_vif.pll2_status[`DESIGN_CORE_NUM/6*5]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }
        pll3_status5: coverpoint spd_vif.pll3_status[`DESIGN_CORE_NUM/6*5]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }
        pll0_status6b: coverpoint spd_vif.pll0_status[`DESIGN_CORE_NUM-2]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        pll1_status6b: coverpoint spd_vif.pll1_status[`DESIGN_CORE_NUM-2]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        pll2_status6b: coverpoint spd_vif.pll2_status[`DESIGN_CORE_NUM-2]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }
        pll3_status6b: coverpoint spd_vif.pll3_status[`DESIGN_CORE_NUM-2]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }
        pll0_status6: coverpoint spd_vif.pll0_status[`DESIGN_CORE_NUM-1]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        pll1_status6: coverpoint spd_vif.pll1_status[`DESIGN_CORE_NUM-1]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        pll2_status6: coverpoint spd_vif.pll2_status[`DESIGN_CORE_NUM-1]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }
        pll3_status6: coverpoint spd_vif.pll3_status[`DESIGN_CORE_NUM-1]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        halfclk0_status0: coverpoint spd_vif.halfclk0_status[0]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        halfclk1_status0: coverpoint spd_vif.halfclk1_status[0]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        halfclk2_status0: coverpoint spd_vif.halfclk2_status[0]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        halfclk0_status_1: coverpoint spd_vif.halfclk0_status[`DESIGN_CORE_NUM/3]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        halfclk1_status_1: coverpoint spd_vif.halfclk1_status[`DESIGN_CORE_NUM/3]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        halfclk2_status_1: coverpoint spd_vif.halfclk2_status[`DESIGN_CORE_NUM/3]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        halfclk0_status_2: coverpoint spd_vif.halfclk0_status[`DESIGN_CORE_NUM/2]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        halfclk1_status_2: coverpoint spd_vif.halfclk1_status[`DESIGN_CORE_NUM/2]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        halfclk2_status_2: coverpoint spd_vif.halfclk2_status[`DESIGN_CORE_NUM/2]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        halfclk0_status_3: coverpoint spd_vif.halfclk0_status[`DESIGN_CORE_NUM-1]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        halfclk1_status_3: coverpoint spd_vif.halfclk1_status[`DESIGN_CORE_NUM-1]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        halfclk2_status_3: coverpoint spd_vif.halfclk2_status[`DESIGN_CORE_NUM-1]{
              bins UNUSED = {PLL_UNUSED};
              bins USED = {PLL_USED};
              bins BAD = {PLL_INVALID};
              bins TIMEOUT = {PLL_TIMEOUT};
        }

        
        //add cluster and rand select 
        diag_flag1: coverpoint spd_vif.diag_flag[`DESIGN_CORE_NUM/10*1]{
              bins WORK = {WORK_FLAG};
              bins DIAGNOSE = {DIAG_FLAG};
              bins SILENCE = {SILENCE_FLAG};
              bins RECHK = {RECHECK_FLAG};
        }
        low_diag_flag1: coverpoint spd_vif.low_diag_flag[`DESIGN_CORE_NUM/10*1]{
              bins HALF_WORK={HALF_WORK};
              bins HALF_OTHER={HALF_OTHER};
        }
        diag_flag11: coverpoint spd_vif.diag_flag[`DESIGN_CORE_NUM/10*1+1]{
              bins WORK = {WORK_FLAG};
              bins DIAGNOSE = {DIAG_FLAG};
              bins SILENCE = {SILENCE_FLAG};
              bins RECHK = {RECHECK_FLAG};
        }
        low_diag_flag11: coverpoint spd_vif.low_diag_flag[`DESIGN_CORE_NUM/10*1+1]{
              bins HALF_WORK={HALF_WORK};
              bins HALF_OTHER={HALF_OTHER};
        }
        diag_flag2: coverpoint spd_vif.diag_flag[`DESIGN_CORE_NUM/10*2]{
              bins WORK = {WORK_FLAG};
              bins DIAGNOSE = {DIAG_FLAG};
              bins SILENCE = {SILENCE_FLAG};
              bins RECHK = {RECHECK_FLAG};
        }
        low_diag_flag2: coverpoint spd_vif.low_diag_flag[`DESIGN_CORE_NUM/10*2]{
              bins HALF_WORK={HALF_WORK};
              bins HALF_OTHER={HALF_OTHER};
        }
        diag_flag22: coverpoint spd_vif.diag_flag[`DESIGN_CORE_NUM/10*2+2]{
              bins WORK = {WORK_FLAG};
              bins DIAGNOSE = {DIAG_FLAG};
              bins SILENCE = {SILENCE_FLAG};
              bins RECHK = {RECHECK_FLAG};

        }
low_diag_flag22: coverpoint spd_vif.low_diag_flag[`DESIGN_CORE_NUM/10*2+2]{
              bins HALF_WORK={HALF_WORK};
              bins HALF_OTHER={HALF_OTHER};
        }
        diag_flag3: coverpoint spd_vif.diag_flag[`DESIGN_CORE_NUM/10*3]{
              bins WORK = {WORK_FLAG};
              bins DIAGNOSE = {DIAG_FLAG};
              bins SILENCE = {SILENCE_FLAG};
              bins RECHK = {RECHECK_FLAG};
   
        }
        low_diag_flag3: coverpoint spd_vif.low_diag_flag[`DESIGN_CORE_NUM/10*3]{
              bins HALF_WORK={HALF_WORK};
              bins HALF_OTHER={HALF_OTHER};
        }
        diag_flag4: coverpoint spd_vif.diag_flag[`DESIGN_CORE_NUM/10*4]{
              bins WORK = {WORK_FLAG};
              bins DIAGNOSE = {DIAG_FLAG};
              bins SILENCE = {SILENCE_FLAG};
              bins RECHK = {RECHECK_FLAG};
        }
        low_diag_flag4: coverpoint spd_vif.low_diag_flag[`DESIGN_CORE_NUM/10*4]{
              bins HALF_WORK={HALF_WORK};
              bins HALF_OTHER={HALF_OTHER};
        }
        diag_flag5: coverpoint spd_vif.diag_flag[`DESIGN_CORE_NUM/10*5]{
              bins WORK = {WORK_FLAG};
              bins DIAGNOSE = {DIAG_FLAG};
              bins SILENCE = {SILENCE_FLAG};
              bins RECHK = {RECHECK_FLAG};
        }
        low_diag_flag5: coverpoint spd_vif.low_diag_flag[`DESIGN_CORE_NUM/10*5]{
              bins HALF_WORK={HALF_WORK};
              bins HALF_OTHER={HALF_OTHER};
        }
        diag_flag6: coverpoint spd_vif.diag_flag[`DESIGN_CORE_NUM/10*6]{
              bins WORK = {WORK_FLAG};
              bins DIAGNOSE = {DIAG_FLAG};
              bins SILENCE = {SILENCE_FLAG};
              bins RECHK = {RECHECK_FLAG};
        }
        low_diag_flag6: coverpoint spd_vif.low_diag_flag[`DESIGN_CORE_NUM/10*6]{
              bins HALF_WORK={HALF_WORK};
              bins HALF_OTHER={HALF_OTHER};
        }
        diag_flag7: coverpoint spd_vif.diag_flag[`DESIGN_CORE_NUM/10*7]{
              bins WORK = {WORK_FLAG};
              bins DIAGNOSE = {DIAG_FLAG};
              bins SILENCE = {SILENCE_FLAG};
              bins RECHK = {RECHECK_FLAG};    
        }
        low_diag_flag7: coverpoint spd_vif.low_diag_flag[`DESIGN_CORE_NUM/10*7]{
              bins HALF_WORK={HALF_WORK};
              bins HALF_OTHER={HALF_OTHER};
        }
        diag_flag82: coverpoint spd_vif.diag_flag[`DESIGN_CORE_NUM/10*8-2]{
              bins WORK = {WORK_FLAG};
              bins DIAGNOSE = {DIAG_FLAG};
              bins SILENCE = {SILENCE_FLAG};
              bins RECHK = {RECHECK_FLAG};      
        }
        low_diag_flag82: coverpoint spd_vif.low_diag_flag[`DESIGN_CORE_NUM/10*8-2]{
              bins HALF_WORK={HALF_WORK};
              bins HALF_OTHER={HALF_OTHER}; 
        }
        diag_flag8: coverpoint spd_vif.diag_flag[`DESIGN_CORE_NUM/10*8]{
              bins WORK = {WORK_FLAG};
              bins DIAGNOSE = {DIAG_FLAG};
              bins SILENCE = {SILENCE_FLAG};
              bins RECHK = {RECHECK_FLAG};            
        }
        low_diag_flag8: coverpoint spd_vif.low_diag_flag[`DESIGN_CORE_NUM/10*8]{
              bins HALF_WORK={HALF_WORK};
              bins HALF_OTHER={HALF_OTHER};
        }
        diag_flag91: coverpoint spd_vif.diag_flag[`DESIGN_CORE_NUM-2]{
              bins WORK = {WORK_FLAG};
              bins DIAGNOSE = {DIAG_FLAG};
              bins SILENCE = {SILENCE_FLAG};
              bins RECHK = {RECHECK_FLAG};
           
        }
        low_diag_flag91: coverpoint spd_vif.low_diag_flag[`DESIGN_CORE_NUM-2]{
              bins HALF_WORK={HALF_WORK};
              bins HALF_OTHER={HALF_OTHER};  
        }
        diag_flag9: coverpoint spd_vif.diag_flag[`DESIGN_CORE_NUM-1]{
              bins WORK = {WORK_FLAG};
              bins DIAGNOSE = {DIAG_FLAG};
              bins SILENCE = {SILENCE_FLAG};
              bins RECHK = {RECHECK_FLAG};
        }
        low_diag_flag9: coverpoint spd_vif.low_diag_flag[`DESIGN_CORE_NUM-1]{
              bins HALF_WORK={HALF_WORK};
              bins HALF_OTHER={HALF_OTHER}; 
        }
   endgroup

//***** gbp ****//
  covergroup cg_spd_gbp_reg;
     option.per_instance = 0;
      cov_spd_gbp_reg_gbp_en                     : coverpoint spd_vif.REG_gbp_en;
      cov_spd_gbp_reg_gbp_en_switch                     : coverpoint spd_vif.REG_gbp_en
      {
          bins TRANS0 = (1'b0 => 1'b1);
          bins TRANS1 = (1'b1 => 1'b0);
      }
      cov_spd_gbp_reg_gbp_vld                    : coverpoint spd_vif.REG_gbp_vld;
      cov_spd_gbp_en_vld: cross cov_spd_gbp_reg_gbp_en, cov_spd_gbp_reg_gbp_vld
      {
          ignore_bins unuseful = binsof(cov_spd_gbp_reg_gbp_en) intersect {0};
      }
      cov_spd_gbp_reg_gbp_gate_num               : coverpoint spd_vif.REG_gbp_gate_num[7:0]
      {
        bins SPEC16 = {8'h10};
        bins ZERO = {8'h0};
        bins LOW = {[8'h1 : `DESIGN_CORE_NUM/3]};
        bins MID = {[`DESIGN_CORE_NUM/3 : `DESIGN_CORE_NUM/3*2]};
        bins HIGH = {[`DESIGN_CORE_NUM/3*2 : `DESIGN_CORE_NUM-1]};

      }
      cov_spd_gbp_reg_gbp_gated_core_num         : coverpoint spd_vif.gbp_gated_core_num[7:0]
      {
        bins SPEC16 = {8'h10};
        bins ZERO = {8'h0};
        bins LOW = {[8'h1 : `DESIGN_CORE_NUM/3]};
        bins MID = {[`DESIGN_CORE_NUM/3 : `DESIGN_CORE_NUM/3*2]};
        bins HIGH = {[`DESIGN_CORE_NUM/3*2 : `DESIGN_CORE_NUM-1]};
      }
     cov_spd_gbp_reg_gbp_nonsort_gated_core_num : coverpoint spd_vif.gbp_nonsort_gated_core_num[7:0]
     {
        bins ZERO = {8'h0};
        bins LOW  = {[8'h1  : 8'h5]};
        bins MID  = {[8'h6  : 8'd11]};
        bins HIGH = {[8'd12 : 8'd16]};
     }
      cov_spd_gbp_reg_gbp_open_core_error_num    : coverpoint spd_vif.gbp_open_core_error_num[7:0]
      {
        bins ZERO = {8'h0};
        bins LOW  = {[8'h1  : 8'h5]};
        bins MID  = {[8'h6  : 8'd11]};
        bins HIGH = {[8'd12 : 8'd16]};
      }
      cov_spd_gbp_reg_gbp_st                     : coverpoint spd_vif.gbp_st;

  endgroup

  covergroup cg_spd_gbp_worst_id;
    option.per_instance = 0;
      
      cov_spd_gbp_worst_id: coverpoint spd_vif.worst_core_id_mark
      {
          bins valid0 = {{(`SORT_DEEP){1'h0}}};
          bins valid1 = {{(`SORT_DEEP-4){1'h1}}, {4{1'h0}}};
          bins valid2 = {{(`SORT_DEEP-8){1'h1}}, {8{1'h0}}};
          bins valid3 = {{(`SORT_DEEP-12){1'h1}}, {12{1'h0}}};
          bins valid4 = {{(`SORT_DEEP){1'h1}}};
      }
  endgroup

  covergroup cg_spd_gbp_gated_core;
    option.per_instance = 0;
      
      cov_spd_gbp_gated_core0 : coverpoint spd_vif.TB_check_gate_pass[0];
      cov_spd_gbp_gated_core1 : coverpoint spd_vif.TB_check_gate_pass[`DESIGN_CORE_NUM/10*1];//17
      cov_spd_gbp_gated_core2 : coverpoint spd_vif.TB_check_gate_pass[`DESIGN_CORE_NUM/10*2];//34
      cov_spd_gbp_gated_core3 : coverpoint spd_vif.TB_check_gate_pass[`DESIGN_CORE_NUM/10*3];//51
      cov_spd_gbp_gated_core4 : coverpoint spd_vif.TB_check_gate_pass[`DESIGN_CORE_NUM/10*4];//68
      cov_spd_gbp_gated_core5 : coverpoint spd_vif.TB_check_gate_pass[`DESIGN_CORE_NUM/10*5];//85
      cov_spd_gbp_gated_core6 : coverpoint spd_vif.TB_check_gate_pass[`DESIGN_CORE_NUM/10*6];//102
      cov_spd_gbp_gated_core7 : coverpoint spd_vif.TB_check_gate_pass[`DESIGN_CORE_NUM/10*7];//119
      cov_spd_gbp_gated_core8 : coverpoint spd_vif.TB_check_gate_pass[`DESIGN_CORE_NUM/10*8];//136
      cov_spd_gbp_gated_core9 : coverpoint spd_vif.TB_check_gate_pass[`DESIGN_CORE_NUM/10*9];//153
      cov_spd_gbp_gated_core10: coverpoint spd_vif.TB_check_gate_pass[`DESIGN_CORE_NUM-1];//176
  endgroup

  covergroup cg_spd_gbp_open_core;
    option.per_instance = 0;

      cov_spd_gbp_open_core0 : coverpoint spd_vif.TB_check_open_pass[0];
      cov_spd_gbp_open_core1 : coverpoint spd_vif.TB_check_open_pass[`DESIGN_CORE_NUM/10*1];
      cov_spd_gbp_open_core2 : coverpoint spd_vif.TB_check_open_pass[`DESIGN_CORE_NUM/10*2];
      cov_spd_gbp_open_core3 : coverpoint spd_vif.TB_check_open_pass[`DESIGN_CORE_NUM/10*3];
      cov_spd_gbp_open_core4 : coverpoint spd_vif.TB_check_open_pass[`DESIGN_CORE_NUM/10*4];
      cov_spd_gbp_open_core5 : coverpoint spd_vif.TB_check_open_pass[`DESIGN_CORE_NUM/10*5];
      cov_spd_gbp_open_core6 : coverpoint spd_vif.TB_check_open_pass[`DESIGN_CORE_NUM/10*6];
      cov_spd_gbp_open_core7 : coverpoint spd_vif.TB_check_open_pass[`DESIGN_CORE_NUM/10*7];
      cov_spd_gbp_open_core8 : coverpoint spd_vif.TB_check_open_pass[`DESIGN_CORE_NUM/10*8];
      cov_spd_gbp_open_core9 : coverpoint spd_vif.TB_check_open_pass[`DESIGN_CORE_NUM/10*9];
      cov_spd_gbp_open_core10: coverpoint spd_vif.TB_check_open_pass[`DESIGN_CORE_NUM-1];
  endgroup

  covergroup cg_spd_gbp_spdlog_timer_gbp;
    option.per_instance = 0;

      cov_spd_gbp_spdlog_timer_gbp: coverpoint spd_vif.Spdlog_Timer_gbp
      {
          bins LOW = {[36'h1 : 36'h4_ffffffff]};
          bins MID = {[36'h5_00000000 : 36'hb_ffffffff]};
          bins HIGH = {[36'hc_00000000 : 36'hf_ffffffff]};
      }
endgroup

covergroup cg_spd_gbp_gbp_with_spd;
    option.per_instance = 0;
      cov_spd_gbp_gbp_spd: coverpoint {spd_vif.REG_gbp_en, spd_vif.ss_sel}
      {
          bins valid0 = {1'b1, 2'b01};
          bins valid1 = {1'b1, 2'b10};
      }
endgroup

covergroup cg_spd_gbp_work_nonce;
    option.per_instance = 0;
      cov_spd_gbp_work_nonce: coverpoint {spd_vif.vld_Work, spd_vif.send_work_round_start, spd_vif.send_work_check_pass}
      {
        bins valid ={1'b1, 1'b1 ,1'b1};
      }
endgroup


//***** lfb ****//
  covergroup cg_spd_lfb_reg;
        cov_spd_lfb_en: coverpoint spd_vif.REG_lfb_en;
        cov_spd_lfb_clear: coverpoint spd_vif.REG_lfb_clear;
        cov_spd_lfb_times: coverpoint spd_vif.REG_lfb_times
        {
          ignore_bins times0 = {0};
        }
        
        cov_spd_lfb_en_times_cro: cross cov_spd_lfb_en, cov_spd_lfb_times
        {
          ignore_bins invalid = binsof(cov_spd_lfb_en) intersect {0};
        }
        
        cov_spd_lfb_start: coverpoint spd_vif.lfb_start;
        cov_spd_lfb_recover_close: coverpoint spd_vif.lfb_recover_close;
        cov_spd_lfb_current_mem_reduce: coverpoint spd_vif.current_mem_reduce;
        cov_spd_lfb_current_mem_increase: coverpoint spd_vif.current_mem_increase;
        cov_spd_lfb_current_mem_insert_en: coverpoint spd_vif.current_mem_insert_en;

        cov_spd_lfb_bro_th: coverpoint spd_vif.REG_lfb_broken_threshold
        {
          bins lfb_bro_th1 = {[1:2730]};  
          bins lfb_bro_th2 = {[2730:5460]}; 
          bins lfb_bro_th3 = {[5461:8190]}; 
          bins lfb_bro_th4 = {[8191:20000]}; 
          bins lfb_bro_th5 = {[20001:30000]}; 
          bins lfb_bro_th6 = {[30001:40000]}; 
          bins lfb_bro_th7 = {[40001:50000]}; 
          bins lfb_bro_th8 = {[50001:65535]}; 
        }

        cov_spd_lfb_rec_th: coverpoint spd_vif.REG_lfb_recover_threshold
        {
          bins cov_lfb_rec_th1 = {[1:2730]};  
          bins cov_lfb_rec_th2 = {[2730:5460]}; 
          bins cov_lfb_rec_th3 = {[5461:8190]}; 
          bins cov_lfb_rec_th4 = {[8191:20000]}; 
          bins cov_lfb_rec_th5 = {[20001:30000]}; 
          bins cov_lfb_rec_th6 = {[30001:40000]}; 
          bins cov_lfb_rec_th7 = {[40001:50000]}; 
          bins cov_lfb_rec_th8 = {[50001:65535]}; 
        }

        cov_spd_lfb_bro_rec_times: coverpoint spd_vif.REG_lfb_recover_threshold/spd_vif.REG_lfb_broken_threshold
        {
          bins times1 = {1};
          bins times2 = {2};
          bins times35 = {[3:5]};
          bins times610 = {[6:10]};
          bins times_11_max = {[11:$]};
        }
       
        cov_spd_lfb_memory_full: coverpoint spd_vif.REG_lfb_memory_full;

        cov_spd_lfb_memory_lost_num: coverpoint spd_vif.REG_lfb_memory_lost_num
        {
          bins ZERO = {0};
          bins LOW  = {[   1       : `SORT_DEEP]};
          bins MID  = {[`SORT_DEEP : 50]};
          bins HIGH = {[   50      : `DESIGN_CORE_NUM - `SORT_DEEP - 1]};
          bins FULL = {`DESIGN_CORE_NUM - `SORT_DEEP};
        }
        
        cov_spd_lfb_broken_core_reg_full: coverpoint spd_vif.REG_lfb_broken_core_reg_full;

        cov_spd_lfb_reg_lost_core_num: coverpoint spd_vif.REG_lfb_reg_lost_core_num
        {
          bins ZERO = {0};
          bins LOW  = {[   1       : `SORT_DEEP]};
          bins MID  = {[`SORT_DEEP : 50]};
          bins HIGH = {[   50      : `DESIGN_CORE_NUM - `SORT_DEEP - 1]};
          bins FULL = {`DESIGN_CORE_NUM - `SORT_DEEP};
        }

  endgroup

  covergroup cg_spd_lfb_core_id;

        cov_spd_lfb_broken_id: coverpoint spd_vif.REG_lfb_broken_core_id_mark
        {
          bins valid0 = {{`SORT_DEEP{1'b0}}};
          bins valid1 = {{{(`SORT_DEEP-4){1'b0}}, {4{1'b1}}}};
          bins valid2 = {{{(`SORT_DEEP-8){1'b0}}, {8{1'b1}}}};
          bins valid3 = {{{(`SORT_DEEP-12){1'b0}}, {12{1'b1}}}};
          bins valid4 = {{`SORT_DEEP{1'b1}}};
        }
  endgroup

  covergroup cg_lfb_state_machine @(lfb_state_cur);
  	    cov_ft_state_machine : coverpoint  spd_vif.lfb_state_cur 
				{
						bins s1 = (spd_vif.LFB_STATE_IDLE => spd_vif.LFB_MEM_REDUCE_INCEA => spd_vif.LFB_MEM_INSEART => spd_vif.LFB_MEM_CHECKOUT => spd_vif.LFB_STATE_DONE => spd_vif.LFB_STATE_IDLE);
						bins s2 = (spd_vif.LFB_STATE_IDLE => spd_vif.LFB_MEM_REDUCE_INCEA => spd_vif.LFB_MEM_INSEART => spd_vif.LFB_REG_RELEASE => spd_vif.LFB_MEM_CHECKOUT => spd_vif.LFB_STATE_DONE => spd_vif.LFB_STATE_IDLE);
				}
  endgroup
//**************//


  function new(string name, uvm_component parent);
    begin
    super.new(name, parent);
    cg_spd_global = new();
    cg_th0 = new();
    cg_th1 = new();
    cg_th2 = new();
    cg_ths = new();
    cg_plltable = new();
    cg_pllcnt = new();
    cg_passfail_cnt = new();
    cg_spdlog_timer = new();
    cg_spd_distribution = new();
    cg_passfail_local = new();
    cg_ss_set = new();
    cg_ss_para = new();
    cg_ss_state = new();
    cg_ss_sslog = new();
//**** gbp ****//
    cg_spd_gbp_reg=new();
    cg_spd_gbp_worst_id=new();
    cg_spd_gbp_gated_core=new();
    cg_spd_gbp_open_core=new();
    cg_spd_gbp_spdlog_timer_gbp=new();
    cg_spd_gbp_gbp_with_spd=new();
    cg_spd_gbp_work_nonce=new();
//*************//

//**** lfb ****//
    cg_spd_lfb_reg=new();
    cg_spd_lfb_core_id=new();
    cg_lfb_state_machine=new();
//*************//

//*****self_aging*****//
    cg_aging_th0=new();
    cg_aging_th1=new();
    cg_aging_th2=new();
    cg_aging_thms=new();
    cg_aging_ss_para=new();
    cg_aging_spd_trans=new();

//*********************//
    mon2cov = new("mon2cov",this);
    end
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual spd_if)::get(this , "" , "spd_vif" ,spd_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction
  
  function void write(spd_coverage_item t); 
    req_h = t;
    cg_spd_global.sample();
    cg_th0.sample();
    cg_th1.sample();
    cg_th2.sample();
    cg_ths.sample();
    cg_plltable.sample();
    cg_pllcnt.sample();
    cg_passfail_cnt.sample();
    cg_spdlog_timer.sample();
    cg_spd_distribution.sample();
    cg_passfail_local.sample();
    cg_ss_set.sample();
    cg_ss_para.sample();
    cg_ss_state.sample();
    cg_ss_sslog.sample();
//**** gbp ****//
    cg_spd_gbp_reg.sample();
    cg_spd_gbp_worst_id.sample();
    cg_spd_gbp_gated_core.sample();
    cg_spd_gbp_open_core.sample();
    cg_spd_gbp_spdlog_timer_gbp.sample();
    cg_spd_gbp_gbp_with_spd.sample();
    cg_spd_gbp_work_nonce.sample();
//*************//

//**** lfb ****//
    lfb_state_cur = spd_vif.lfb_state_cur;
    cg_spd_lfb_reg.sample();
    cg_spd_lfb_core_id.sample();
    //cg_lfb_state_machine.sample();
    
//*************//

//*****self_aging*****//
//     cg_aging_spd_trans.sample();
    
//     if(spd_vif.REG_self_aging_en==1'b1) begin
//         cg_aging_th0.sample();
//         cg_aging_th1.sample();
//         cg_aging_th2.sample();
//         cg_aging_thms.sample();
//         cg_aging_ss_para.sample();
//     end

//*********************//

  endfunction

endclass

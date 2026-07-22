
`define LFB_NULL    3'b000
`define LFB_BROKEN  3'b001
`define LFB_RECOVER 3'b010
`define LFB_SPEED_GATE 3'b011


class spd_base_cfg extends uvm_object; 

  // spd global
  rand bit        glb_set_vld   ; //[8]
  rand bit [2:0]  glb_set       ; //[2:0]

  rand bit        spd_en        ; //[9]
  rand bit [2:0]  spd_high      ; //[15:13]
  rand bit [2:0]  spd_low       ; //[12:10]
  rand bit        ssdn_pro      ; //[20]

  rand bit [7:0]  orders[`DESIGN_CORE_NUM];
  randc bit [7:0] rand_coreid;
  rand bit  [7:0] lost_rand_coreid;
  randc bit [16:0] work_hit_rate;

  rand bit dh_cnt_wdt_on;
  rand bit [15:0] dh_cnt_wdt_timer;

  rand int         repeat_num;

  rand bit [3:0]  lfb_times;
  rand bit [3:0]  lfb_gate_times;
  rand bit [3:0]  lfb_reduce_incre_times;
  rand bit [3:0]  lfb_times_tmp;
  rand bit [3:0]  lfb_round;
  rand bit [4:0]  lfb_round_lost;
  rand bit [7:0]  lfb_round_id[9];
  rand bit [7:0]  lfb_round_lost_id[21];
  rand bit [7:0]  lfb_gate_id_array[`SORT_DEEP];
 
  rand bit [15:0] lfb_broken_th;
  rand bit [15:0] lfb_broken_th_out;
  rand bit [15:0] lfb_broken_cnt_ex;
  rand bit [15:0] lfb_broken_cnt_ex_lost;
  rand bit [15:0] lfb_broken_cnt[`SORT_DEEP]; 
  rand bit [15:0] lfb_broken_cnt_lost[`DESIGN_CORE_NUM]; 
  rand bit [15:0] lfb_recover_th;
  rand bit [15:0] lfb_recover_cnt_ex;
  rand bit [15:0] lfb_recover_cnt[`SORT_DEEP];
  rand bit [15:0] lfb_pre_recover_cnt[`SORT_DEEP];
  rand bit [15:0] lfb_pass_cnt;
  rand bit [15:0] lfb_init_recover_cnt;
    
  rand bit [7:0]  lfb_last_gate_corenum;
  rand bit [7:0]  lfb_gate_cnt;

  rand bit [7:0]      lfb_bro_or_rec[16][`SORT_DEEP];
  rand bit [7:0]      lfb_cores[16];
  rand bit [2:0]      lfb_bro_or_rec_map[16][`SORT_DEEP];
    
  rand bit [7:0]      rand_gbp_num;
  rand bit [7:0]      rand_gbp_gate_num;
  rand bit [7:0]      gbp_run_times;
  rand bit            spd_glb_limit;
  rand bit            gbp_open_core_error_flag;
  rand bit            gbp_nonsort_gated_core_flag;
  rand bit [2:0]      spd_glb_set;
  rand bit [15:0]     gbp_pass_cnt;
  randc bit [4:0]   reg_full_lost_num;

  // the following is randomized in cpm_config 
//   rand bit [1:0]  pll_sel       ; //[29:28]
//   rand bit        mid_clk_mux   ; //[27]
//   rand bit [3:0]  pll_clk_mux1  ; //[26:23]
//   rand bit [1:0]  pll_clk_mux2  ; //[22:21]
//   rand bit        core_clk_sel0 ; //[16]

  
  //PLLCNT0 PLLCNT1 ReadOnly

  //speed_th0
  rand bit [15:0]  th_pass ;
  rand bit [15:0]  th_fail ;

  //speed th1
  rand bit         th_mssel; 
  rand bit [15:0]  th_init ;

  //speed th2
  rand bit [31:0]  th_to;

  //speed th3
  rand bit         lv2_thms_add;
  rand bit [14:0]  lv2_thms ;
  rand bit         lv1_thms_add;
  rand bit [14:0]  lv1_thms ;

  //speed th4
  rand bit         lv4_thms_add;
  rand bit [14:0]  lv4_thms ;
  rand bit         lv3_thms_add;
  rand bit [14:0]  lv3_thms ;

  //speed_spdlog_timer
  rand bit         timer_on;
  rand bit [15:0]  timer ;

  //pll_table
  rand bit [2:0] plltable_lv7     ;
  rand bit [2:0] plltable_lv6     ;
  rand bit [2:0] plltable_lv5     ;
  rand bit [2:0] plltable_lv4     ;
  rand bit [2:0] plltable_lv3     ;
  rand bit [2:0] plltable_lv2     ;
  rand bit [2:0] plltable_lv1     ;
  rand bit [2:0] plltable_lv0     ;

  rand bit       th_same;
  rand bit [15:0] th_delta1;
  rand bit [15:0] th_delta2;
  rand bit [15:0] th_delta3;
  rand bit [15:0] th_delta4;
  rand bit [15:0] dh_worse_th;
  rand bit [7:0]  fail_percent;
  rand bit [7:0]  norm_percent;
  rand bit [7:0]  pass_percent;

  //spd_dfx
  rand bit [4:0] spdcore_ovf_sel;
  rand bit       spd_bitmap_clr;

  //ss_spd
  rand bit [1:0]  ss_sel;
  rand bit        ss_pri;

  rand bit [15:0]    ss_pd;
  rand bit [15:0]    th_hp;
  rand bit [15:0]    th_lp;
  rand bit [15:0]    th_dp;
  rand bit [3:0]     max_rechk;
  rand bit [15:0]    ss_rand_gap;
  rand bit [1:0]     ss_rand_mod;
  rand bit [2:0]     ss_rand_mod_sel;
    
  rand bit [7:0]    rand_normal_trig_acc;
  rand bit [7:0]    rand_fail_trig_acc;
  rand bit [7:0]    rand_pass_trig_acc;

  rand bit [7:0]     coreid;
  rand bit [7:0]     times_cnt;
  rand bit [7:0]     core_times;

   rand bit [31:0]   passcnt_global_start;
   rand bit [31:0]   failcnt_global_start;

   rand bit [15:0]   passcnt_local_start;
   rand bit [15:0]   failcnt_local_start;

   rand bit [3:0] spds_r[`DESIGN_CORE_NUM];
   rand bit [`DESIGN_CORE_NUM*4-1:0] spds;
    
   rand bit [7:0]   broad_nonce_coreid;
   
   //`ifdef LFB_REFMDL
       `ifdef LFB_RAND
           //rand bit [7:0]  lfb_rand_core; 
           randc bit [7:0]  lfb_rand_core; 
       `else
           randc bit [7:0]  lfb_rand_core; 
       `endif
       rand bit [7:0]  lfb_broken_core_times;// 
       rand bit [7:0]  lfb_run_times; 
       rand bit        lfb_reg_lost_flag; 
       rand bit        lfb_recover_close_flag;
       rand bit [7:0]  rand_gbp_lfb_gate_num;
   //`endif
   // Registration
   /////////////////////////////////////////////////////////
   `uvm_object_utils_begin(spd_base_cfg)
     //`uvm_field_int(members,)
      `uvm_field_int(glb_set_vld       , UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(glb_set   , UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(spd_glb_set   , UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(spd_en  , UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(spd_high  , UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(spd_low      , UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(ssdn_pro , UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(th_pass      , UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(th_fail       , UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(th_mssel        , UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(th_init   , UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(th_to       , UVM_ALL_ON+UVM_HEX);

      `uvm_field_int(lv2_thms_add, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(lv2_thms , UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(lv1_thms_add, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(lv1_thms , UVM_ALL_ON+UVM_HEX);

      `uvm_field_int(lv4_thms_add, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(lv4_thms , UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(lv3_thms_add, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(lv3_thms , UVM_ALL_ON+UVM_HEX);

      `uvm_field_int(timer_on, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(timer , UVM_ALL_ON+UVM_HEX);

      `uvm_field_int(plltable_lv7     , UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(plltable_lv6     , UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(plltable_lv5     , UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(plltable_lv4     , UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(plltable_lv3     , UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(plltable_lv2     , UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(plltable_lv1     , UVM_ALL_ON+UVM_HEX);

      `uvm_field_int(rand_normal_trig_acc     , UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(rand_fail_trig_acc     , UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(rand_pass_trig_acc     , UVM_ALL_ON+UVM_HEX);
      
      `uvm_field_int(dh_cnt_wdt_on     , UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(dh_cnt_wdt_timer     , UVM_ALL_ON+UVM_HEX);

      `uvm_field_int(spdcore_ovf_sel, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(spd_bitmap_clr, UVM_ALL_ON+UVM_HEX);

      `uvm_field_int(ss_sel, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(ss_pri, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(ss_pd, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(th_hp, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(th_lp, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(dh_worse_th,UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(th_dp, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(max_rechk, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(coreid, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(times_cnt, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(core_times, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(passcnt_global_start, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(failcnt_global_start, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(passcnt_local_start, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(failcnt_local_start, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(rand_coreid, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(lost_rand_coreid, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(lfb_times, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(lfb_round, UVM_ALL_ON+UVM_HEX);
     `uvm_field_int(lfb_round_lost, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(lfb_broken_th, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(lfb_broken_th_out, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(lfb_recover_th, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(lfb_pass_cnt, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(gbp_pass_cnt, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(lfb_init_recover_cnt, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(lfb_last_gate_corenum, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(rand_gbp_num, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(rand_gbp_gate_num, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(rand_gbp_lfb_gate_num, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(gbp_run_times, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(spd_glb_limit, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(gbp_open_core_error_flag, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(gbp_nonsort_gated_core_flag, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(repeat_num       , UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(repeat_num       , UVM_ALL_ON+UVM_HEX);

     
      //`ifdef LFB_REFMDL
      `uvm_field_int(lfb_rand_core, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(lfb_broken_core_times, UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(lfb_run_times,         UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(lfb_reg_lost_flag,     UVM_ALL_ON+UVM_HEX);
      `uvm_field_int(lfb_recover_close_flag,UVM_ALL_ON+UVM_HEX);
      //`endif
   `uvm_object_utils_end

   ///////////////////////////////////////////////////////
   // Function To "new" The Class
   ///////////////////////////////////////////////////////
   function new(string name="spd_base_cfg");

      super.new(name);

      ///////////////////////////////////////////////////////
      // Assign to actual real variables in post_randomize()
      ///////////////////////////////////////////////////////
       post_randomize();

      this.constr_spd_glbset.constraint_mode(1);
      this.constr_spd_highlow.constraint_mode(1);

      this.constr_spd_to.constraint_mode(1);
      this.constr_spd_passfail.constraint_mode(1);
      this.constr_spd_plltable.constraint_mode(1);
      this.constr_spd_plltable_zero.constraint_mode(0);
      this.constr_spdlog_timer.constraint_mode(1);
      this.constr_spd_dfx.constraint_mode(1);
      this.constr_ss_low.constraint_mode(1);
      this.constr_ss_mid.constraint_mode(0);
      this.constr_ss_high.constraint_mode(0);
      this.constr_ss_rand.constraint_mode(0);
      this.constr_ss_limit_rand.constraint_mode(0);
      this.constr_coreid.constraint_mode(1);
      this.constr_dh_wdt.constraint_mode(1);
      this.constr_dh_worse_th_low.constraint_mode(0);
      this.constr_dh_worse_th_mid.constraint_mode(0);
      this.constr_dh_worse_th_high.constraint_mode(0);
      this.constr_trig_acc.constraint_mode(1);


      this.constr_spd_pass_gt_fail.constraint_mode(0);
      this.constr_spd_pass_eq_fail.constraint_mode(0);
      this.constr_spd_pass_lt_fail.constraint_mode(0);
      this.constr_spd_pass_1to2_fail.constraint_mode(0);
      this.constr_spd_pass_2to5_fail.constraint_mode(0);
      this.constr_spd_pass_5to8_fail.constraint_mode(0);
      this.constr_spd_pass_8to15_fail.constraint_mode(0);
      this.constr_spd_fail_1to2_pass.constraint_mode(0);
      this.constr_spd_fail_2to5_pass.constraint_mode(0);
      this.constr_spd_fail_5to8_pass.constraint_mode(0);
      this.constr_spd_fail_8to15_pass.constraint_mode(0);
      this.constr_spd_init_gt_pass.constraint_mode(0);
      this.constr_spd_init_eq_pass.constraint_mode(0);
      this.constr_spd_init_lt_pass.constraint_mode(0);
      this.constr_spd_init_1to2_pass.constraint_mode(0);
      this.constr_spd_init_2to5_pass.constraint_mode(0);
      this.constr_spd_init_5to8_pass.constraint_mode(0);
      this.constr_spd_init_8to15_pass.constraint_mode(0);
      this.constr_spd_pass_1to2_init.constraint_mode(0);
      this.constr_spd_pass_2to5_init.constraint_mode(0);
      this.constr_spd_pass_5to8_init.constraint_mode(0);
      this.constr_spd_pass_8to15_init.constraint_mode(0);
      this.constr_spd_init_gt_fail.constraint_mode(0);
      this.constr_spd_init_eq_fail.constraint_mode(0);
      this.constr_spd_init_lt_fail.constraint_mode(0);
      this.constr_spd_init_1to2_fail.constraint_mode(0);
      this.constr_spd_init_2to5_fail.constraint_mode(0);
      this.constr_spd_init_5to8_fail.constraint_mode(0);
      this.constr_spd_init_8to15_fail.constraint_mode(0);
      this.constr_spd_fail_1to2_init.constraint_mode(0);
      this.constr_spd_fail_2to5_init.constraint_mode(0);
      this.constr_spd_fail_5to8_init.constraint_mode(0);
      this.constr_spd_fail_8to15_init.constraint_mode(0);
      this.constr_spd_pass_fail_init_common.constraint_mode(0);
      this.constr_spd_pass_high_fail_init_common.constraint_mode(0);
      this.constr_spd_fail_high_pass_init_common.constraint_mode(0);
      this.constr_spd_fail_pass_high_init_common.constraint_mode(0);
      this.constr_spd_init_pass_fail.constraint_mode(0);
      
      this.constr_spd_global_passfail_lowlow.constraint_mode(0);
      this.constr_spd_global_passfail_lowhigh.constraint_mode(0);
      this.constr_spd_global_passfail_lowmax.constraint_mode(0);
      this.constr_spd_global_passfail_highlow.constraint_mode(0);
      this.constr_spd_global_passfail_highhigh.constraint_mode(0);
      this.constr_spd_global_passfail_highmax.constraint_mode(0);
      this.constr_spd_global_passfail_maxlow.constraint_mode(0);
      this.constr_spd_global_passfail_maxhigh.constraint_mode(0);
      this.constr_spd_global_passfail_maxmax.constraint_mode(0);

      this.constr_spd_local_passfail.constraint_mode(0);
      this.constr_spd_local_passfail_lowlow.constraint_mode(0);
      this.constr_spd_local_passfail_lowhigh.constraint_mode(0);
      this.constr_spd_local_passfail_lowmax.constraint_mode(0);
      this.constr_spd_local_passfail_highlow.constraint_mode(0);
      this.constr_spd_local_passfail_highhigh.constraint_mode(0);
      this.constr_spd_local_passfail_highmax.constraint_mode(0);
      this.constr_spd_local_passfail_maxlow.constraint_mode(0);
      this.constr_spd_local_passfail_maxhigh.constraint_mode(0);
      this.constr_spd_local_passfail_maxmax.constraint_mode(0);


      this.constr_spds.constraint_mode(1);
      this.constr_spds_normal.constraint_mode(0);
      this.constr_spds_12_equal.constraint_mode(0);
      this.constr_spds_23_equal.constraint_mode(0);
      this.constr_spds_34_equal.constraint_mode(0);

      this.constr_spd_thms.constraint_mode(1);
      this.constr_spd_thms_equal_low.constraint_mode(0);
      this.constr_spd_thms_equal_mid.constraint_mode(0);
      this.constr_spd_thms_equal_high.constraint_mode(0);
      this.constr_spd_thms_low.constraint_mode(0);
      this.constr_spd_thms_mid.constraint_mode(0);
      this.constr_spd_thms_high.constraint_mode(0);
      this.constr_spd_thms_rand.constraint_mode(0);

      this.constr_spdlog_timer_rand.constraint_mode(0);

      this.constr_fakecore_order.constraint_mode(0);
      this.constr_fakecore_order_repeat.constraint_mode(0);
      this.constr_fakecore_order_slice_boundary.constraint_mode(0);
      this.constr_lfb_rounds.constraint_mode(1);
      this.constr_lfb_bro_or_rec.constraint_mode(1);
      this.constr_rand_gbp_num.constraint_mode(1);
      this.constr_rand_gbp_gate_num.constraint_mode(1);
      
      this.constr_lfb_refmdl.constraint_mode(0);
      this.constr_gbp_refmdl.constraint_mode(1);
   endfunction : new

  function void pre_randomize();
      super.pre_randomize();
   endfunction : pre_randomize


   /////////////////////////////////////////////////////
   // Function To Run After Randomization
   // Get Real Numbers From Randomized Values
   /////////////////////////////////////////////////////
   function void post_randomize();
      super.post_randomize();
      if(gbp_open_core_error_flag == 1)begin
         gbp_nonsort_gated_core_flag = 0;
      end
      //`uvm_info(get_type_name(),this.sprint(),UVM_MEDIUM);
   endfunction : post_randomize

  /////////////////////////////////////
   // Constraints
   /////////////////////////////////////

  constraint constr_spd_glbset;
  constraint constr_spd_highlow;

  constraint constr_spd_to;
  constraint constr_spd_passfail;
  constraint constr_spd_plltable;
  constraint constr_spd_plltable_zero;
  constraint constr_spdlog_timer;
  constraint constr_spd_dfx;
  constraint constr_ss_low;
  constraint constr_ss_mid;
  constraint constr_ss_high;
  constraint constr_ss_rand;
  constraint constr_ss_limit_rand;
  constraint constr_coreid;
  constraint constr_dh_wdt;

  constraint constr_dh_worse_th_low;
  constraint constr_dh_worse_th_mid;   
  constraint constr_dh_worse_th_high; 
  constraint constr_trig_acc;

   constraint constr_spd_pass_gt_fail;

   constraint constr_spd_pass_eq_fail;
   constraint constr_spd_pass_lt_fail;
   constraint constr_spd_pass_1to2_fail;
   constraint constr_spd_pass_2to5_fail;
   constraint constr_spd_pass_5to8_fail;
   constraint constr_spd_pass_8to15_fail;
   constraint constr_spd_fail_1to2_pass;
   constraint constr_spd_fail_2to5_pass;
   constraint constr_spd_fail_5to8_pass;
   constraint constr_spd_fail_8to15_pass;

   constraint constr_spd_init_gt_pass;
   constraint constr_spd_init_eq_pass;
   constraint constr_spd_init_lt_pass;
   constraint constr_spd_init_1to2_pass;
   constraint constr_spd_init_2to5_pass;
   constraint constr_spd_init_5to8_pass;
   constraint constr_spd_init_8to15_pass;
   constraint constr_spd_pass_1to2_init;
   constraint constr_spd_pass_2to5_init;
   constraint constr_spd_pass_5to8_init;
   constraint constr_spd_pass_8to15_init;

   constraint constr_spd_init_gt_fail;
   constraint constr_spd_init_eq_fail;
   constraint constr_spd_init_lt_fail;
   constraint constr_spd_init_1to2_fail;
   constraint constr_spd_init_2to5_fail;
   constraint constr_spd_init_5to8_fail;
   constraint constr_spd_init_8to15_fail;
   constraint constr_spd_fail_1to2_init;
   constraint constr_spd_fail_2to5_init;
   constraint constr_spd_fail_5to8_init;
   constraint constr_spd_fail_8to15_init;
   constraint constr_spd_pass_fail_init_common;
   constraint constr_spd_pass_high_fail_init_common;
   constraint constr_spd_fail_high_pass_init_common;
   constraint constr_spd_fail_pass_high_init_common;
   constraint constr_spd_init_pass_fail;

   constraint constr_spd_global_passfail;
   constraint constr_spd_global_passfail_lowlow;
   constraint constr_spd_global_passfail_lowhigh;
   constraint constr_spd_global_passfail_lowmax;
   constraint constr_spd_global_passfail_highlow;
   constraint constr_spd_global_passfail_highhigh;
   constraint constr_spd_global_passfail_highmax;
   constraint constr_spd_global_passfail_maxlow;
   constraint constr_spd_global_passfail_maxhigh;
   constraint constr_spd_global_passfail_maxmax;

   constraint constr_spd_local_passfail;
   constraint constr_spd_local_passfail_lowlow;
   constraint constr_spd_local_passfail_lowhigh;
   constraint constr_spd_local_passfail_lowmax;
   constraint constr_spd_local_passfail_highlow;
   constraint constr_spd_local_passfail_highhigh;
   constraint constr_spd_local_passfail_highmax;
   constraint constr_spd_local_passfail_maxlow;
   constraint constr_spd_local_passfail_maxhigh;
   constraint constr_spd_local_passfail_maxmax;

   constraint constr_spds;
   constraint constr_spds_normal;
   constraint constr_spds_12_equal;
   constraint constr_spds_23_equal;
   constraint constr_spds_34_equal;

   constraint constr_spd_thms;
   constraint constr_spd_thms_equal_low;
   constraint constr_spd_thms_equal_mid;
   constraint constr_spd_thms_equal_high;
   constraint constr_spd_thms_low;
   constraint constr_spd_thms_mid;
   constraint constr_spd_thms_high;
   constraint constr_spd_thms_rand;

   constraint constr_spdlog_timer_rand;


   constraint constr_fakecore_order;
   constraint constr_fakecore_order_repeat;
   constraint constr_fakecore_order_slice_boundary;

   constraint constr_lfb_rounds;
   constraint constr_lfb_bro_or_rec;

   constraint constr_rand_gbp_num;
   constraint constr_rand_gbp_gate_num;

   constraint constr_lfb_refmdl;
   constraint constr_gbp_refmdl;
   constraint con_reg_full_lost_num{
     //reg_full_lost_num inside {['d0:`DESIGN_CORE_NUM-'d16-'d1]};
     reg_full_lost_num inside {5'd26};
   }
endclass: spd_base_cfg

constraint spd_base_cfg::constr_spd_glbset
{   
   glb_set_vld inside {1'b1, 1'b0};
   glb_set inside {[3'h1:3'h4]};
   repeat_num inside {[4'h1 : 4'h9]};
   broad_nonce_coreid inside {[0:`DESIGN_CORE_NUM-2]};
}

constraint spd_base_cfg::constr_trig_acc
{
    rand_normal_trig_acc dist {[0:10]:/100, [16:32]:/10,[64:128]:/5};
    rand_fail_trig_acc dist {[0:10]:/100, [16:32]:/10,[64:128]:/5};
    rand_pass_trig_acc dist {[0:10]:/100, [16:32]:/10,[64:128]:/5};
}

constraint spd_base_cfg::constr_spd_highlow
{   
   spd_en   inside {1'b1};
   spd_high inside {[3'h1:3'h4]};
   spd_low  inside {[3'h1:3'h4]};
   ssdn_pro inside {1'b0};
   spd_high >= spd_low;
   glb_set_vld inside {1'b1};
   glb_set inside {[3'h1:3'h4]};
   glb_set >= spd_low;
   glb_set <= spd_high;
}

constraint spd_base_cfg::constr_spd_to
{
   //th_to inside {[32'h1000:32'h2000], [32'h7000:32'h8000], [32'he000:32'hf000]};
}


constraint spd_base_cfg::constr_spd_passfail
{
   th_pass inside {'h8FFF};
   th_fail inside {'h8FFF};
   th_mssel inside {[1'b0:1'b1]};
   th_init inside {'h7FFF};
}

//
constraint spd_base_cfg::constr_spd_plltable
{
   plltable_lv0 inside {0};
   plltable_lv4 inside {[1:4]};
   plltable_lv3 inside {[1:4]};
   plltable_lv2 inside {[1:4]};
   plltable_lv1 inside {[1:4]};

   // plltable_lv4 >= plltable_lv3;
   // plltable_lv3 >= plltable_lv2;
   // plltable_lv2 >= plltable_lv1;

   //man2
   plltable_lv5 inside {[5:7]};
   plltable_lv6 inside {[5:7]};
   plltable_lv7 inside {[5:7]};

}
constraint spd_base_cfg::constr_spd_plltable_zero
{
   plltable_lv0 inside {0};
   plltable_lv4 inside {[0:4]};
   plltable_lv3 inside {[0:4]};
   plltable_lv2 inside {[0:4]};
   plltable_lv1 inside {[0:4]};
   
   // plltable_lv4 >= plltable_lv3;
   // plltable_lv3 >= plltable_lv2;
   // plltable_lv2 >= plltable_lv1;
   //man2
   plltable_lv5 inside {[5:7]};
   plltable_lv6 inside {[5:7]};
   plltable_lv7 inside {[5:7]};

}


constraint spd_base_cfg::constr_spdlog_timer
{
   timer_on inside {1'b0};
   timer inside {'h0};
}


constraint spd_base_cfg::constr_spd_dfx
{
   spdcore_ovf_sel inside {1'b0};
   spd_bitmap_clr inside  {1'b0};
}

constraint spd_base_cfg::constr_ss_low
{
   ss_sel inside     {2'b01,2'b10};
   ss_pri inside     {1'b0,1'b1};
   ss_pd  inside     {[16'h0000:16'h00ff]};
   th_hp  inside     {[16'h0000:16'h000f]};
   th_lp  inside     {[16'h0080:16'h008f]};
   th_dp inside    {[16'h00e0:16'h00ff]};
   max_rechk inside  {[4'h0:4'h2]};
   th_hp > 8;
   th_hp < th_lp;
   th_lp < th_dp;
   th_dp < ss_pd;
   th_same inside {[1'b0:1'b1]};
   th_delta1 inside {[0:16'hf]};
   th_delta2 inside {[0:16'hf]};
   th_delta3 inside {[0:16'hf]};
   th_delta4 inside {[0:16'hf]};

}

constraint spd_base_cfg::constr_ss_mid
{
   ss_sel inside     {2'b01,2'b10};
   ss_pri inside   {1'b0,1'b1};
   ss_pd  inside   {[16'h0140:16'h01ff]};
   th_hp  inside   {[16'h001f:16'h02f]};
   th_lp  inside   {[16'h00e0:16'h00ff]};
   th_dp inside  {[16'h0100:16'h01ff]};
   max_rechk inside {[4'h7:4'h8]};
   th_hp > 15;
   th_hp < th_lp;
   th_lp < th_dp;
   th_dp < ss_pd;
   th_same inside {[1'b0:1'b1]};
   th_delta1 inside {[0:16'h1f]};
   th_delta2 inside {[0:16'h1f]};
   th_delta3 inside {[0:16'h1f]};
   th_delta4 inside {[0:16'h1f]};
}

constraint spd_base_cfg::constr_ss_high
{
   ss_sel inside   {2'b01,2'b10};
   ss_pri inside   {1'b0,1'b1};
   ss_pd  inside   {[16'h0e00:16'h0fff]};
   th_hp  inside   {[16'h00e0:16'h00ff]};
   th_lp  inside   {[16'h0100:16'h0800]};
   th_dp inside    {[16'h0d00:16'h0fff]};
   max_rechk inside {[4'he:4'hf]};
   th_hp > 16'h80;
   th_hp < th_lp;
   th_lp < th_dp;
   th_dp < ss_pd; 
   th_same inside {[1'b0:1'b1]};
   th_delta1 inside {[0:16'hff]};
   th_delta2 inside {[0:16'hff]};
   th_delta3 inside {[0:16'hff]};
   th_delta4 inside {[0:16'hff]};
}
constraint spd_base_cfg::constr_ss_rand
{
   ss_pri inside   {1'b0,1'b1};
   ss_sel dist     {3:=80,2:=20};
   ss_pd  inside   {[16'h01ff:16'hfe00]};
   th_hp  inside   {[16'h01ff:16'hfe00]};
   th_lp  inside   {[16'h01ff:16'hfe00]};
   th_dp  inside   {[16'h01ff:16'hfe00]};
   max_rechk inside {[4'h2:4'hf]};
   th_hp > 16'h1ff;
   th_hp+16'h1ff < th_lp;
   th_lp+16'h6f  == th_dp;
   th_dp+16'h1ff < ss_pd;
   ss_rand_gap inside {[16'h2f:16'hff]};
   th_same inside {[1'b0:1'b1]};
   th_delta1 inside {[0:16'h1f0]};
   th_delta2 inside {[0:16'h1f0]};
   th_delta3 inside {[0:16'h1f0]};
   th_delta4 inside {[0:16'h1f0]};
   dh_worse_th inside{[0:16'h1f0]};

   fail_percent inside{[1:8'd100]};
   norm_percent inside{[1:8'd100]};
   pass_percent inside{[1:8'd100]};
   fail_percent+norm_percent+pass_percent == 8'd100;

}

constraint spd_base_cfg::constr_ss_limit_rand
{
   // ss_pri inside   {1'b0,1'b1};
   // ss_pd  ==16'd1000;
   // th_hp  ==16'd100;
   // th_lp  ==16'd400;
   // max_rechk inside {[4'h2:4'hf]};
   `ifdef FPGA_SYN

      th_same inside {[1'b0:1'b1]};
      th_delta1 inside {[0:16'd100]};
      th_delta2 inside {[0:16'd100]};
      th_delta3 inside {[0:16'd100]};
      th_delta4 inside {[0:16'd100]};

      th_delta2>=th_delta1;
      th_delta3>=th_delta2;
      th_delta4>=th_delta3;
      dh_worse_th inside{[0:10'd300]};

   `else
   
      th_hp  inside   {[16'h01ff:16'hfe00]};
      th_lp  inside   {[16'h01ff:16'hfe00]};
      max_rechk inside {[4'h2:4'hf]};
      th_hp > 16'h1ff;
      th_hp+16'h1ff < th_lp;
      th_lp+16'h1ff < ss_pd;
      ss_pd  inside   {[16'd1000:16'd10000]};
      th_same   inside {[1'b0:1'b1]};
      th_delta1 inside {[0:16'd100]};
      th_delta2 inside {[0:16'd100]};
      th_delta3 inside {[0:16'd100]};
      th_delta4 inside {[0:16'd100]};

      th_delta2-th_delta1<=90;
      th_delta3-th_delta2<=90;
      th_delta4-th_delta3<=90;
      dh_worse_th inside{[90:10'd900]};

   `endif

}

constraint spd_base_cfg::constr_dh_worse_th_low
{
   `ifdef FPGA_SYN
      dh_worse_th inside {[0:16'd99]};
   `else
      dh_worse_th inside {[1:16'd9]};
   `endif
}
constraint spd_base_cfg::constr_dh_worse_th_mid
{
   `ifdef FPGA_SYN
      dh_worse_th inside {[16'd100:16'd299]};
   `else
      dh_worse_th inside {[16'd100:16'd279]};
   `endif  
}
constraint spd_base_cfg::constr_dh_worse_th_high
{

   `ifdef FPGA_SYN
      dh_worse_th inside {[16'd300:16'd299]};
   `else
      dh_worse_th inside {[1000:16'd2799]};
   `endif

}
constraint spd_base_cfg::constr_coreid
{
   coreid inside {[0:`DESIGN_CORE_NUM-11]};
}

constraint spd_base_cfg::constr_dh_wdt
{
    dh_cnt_wdt_on inside {1'b1, 1'b0};
    `ifndef PL_SIM
    dh_cnt_wdt_timer inside {[16'h1000 : 16'hffff]};
    `else
    dh_cnt_wdt_timer inside {16'b0001, 16'b0100, 16'b0101, 16'b1000, 16'b1001, 16'b1100, 16'b1101};
    `endif
}

constraint spd_base_cfg::constr_spd_pass_fail_init_common
{
   th_init >= 'h000F;
   th_fail >= 'h000F;
   th_pass >= 'h000F;
   th_init <= 'hFF00;
   th_fail <= 'hFF00;
   th_pass <= 'hFF00;
}

constraint spd_base_cfg::constr_spd_pass_high_fail_init_common
{
   th_init >= 'h2F00;
   th_fail >= 'h2F00;
   th_pass >= 'hF000;
   th_init <= 'hFF00;
   th_fail <= 'hFF00;
   th_pass <= 'hFFF0;
}
constraint spd_base_cfg::constr_spd_fail_high_pass_init_common
{
   th_init >= 'h2F00;
   th_fail >= 'hF000;
   th_pass >= 'h2F00;
   th_init <= 'hFF00;
   th_fail <= 'hFFF0;
   th_pass <= 'hFF00;
}

constraint spd_base_cfg::constr_spd_fail_pass_high_init_common
{
   th_init >= 'h2F00;
   th_fail >= 'hF000;
   th_pass >= 'hF000;
   th_init <= 'hFF00;
   th_fail <= 'hFFF0;
   th_pass <= 'hFFF0;
}

constraint spd_base_cfg::constr_spd_pass_gt_fail
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_pass > th_fail;
   times_cnt == 8'd6;
   core_times == 8'd5;
}

constraint spd_base_cfg::constr_spd_pass_eq_fail
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_pass == th_fail;
   times_cnt == 8'd6;
   core_times == 8'd5;
}

constraint spd_base_cfg::constr_spd_pass_lt_fail
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_pass < th_fail;
   times_cnt == 8'd6;
   core_times == 8'd5;
}

constraint spd_base_cfg::constr_spd_pass_1to2_fail
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_pass >= 1*th_fail;
   th_pass <= 2*th_fail;
   times_cnt == 8'd6;
   core_times == 8'd5;
}
constraint spd_base_cfg::constr_spd_pass_2to5_fail
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_pass >= 2*th_fail;
   th_pass <= 5*th_fail;
   times_cnt == 8'd6;
   core_times == 8'd5;
}

constraint spd_base_cfg::constr_spd_pass_5to8_fail
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_pass >= 5*th_fail;
   th_pass <= 8*th_fail;
   times_cnt == 8'd3;
   core_times == 8'd10;
}
constraint spd_base_cfg::constr_spd_pass_8to15_fail
{
   th_init >= 'h1000;
   th_fail >= 'h1000;
   th_pass >= 'h1000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_pass >= 8*th_fail;
   th_pass <= 15*th_fail;
   times_cnt == 8'd2;
   core_times == 8'd20;
}

constraint spd_base_cfg::constr_spd_fail_1to2_pass
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_fail >= 1*th_pass;
   th_fail <= 2*th_pass;
   times_cnt == 8'd6;
   core_times == 8'd5;
}

constraint spd_base_cfg::constr_spd_fail_2to5_pass
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_fail >= 2*th_pass;
   th_fail <= 5*th_pass;
   times_cnt == 8'd6;
   core_times == 8'd5;
}

constraint spd_base_cfg::constr_spd_fail_5to8_pass
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_fail >= 5*th_pass;
   th_fail <= 8*th_pass;
   times_cnt == 8'd3;
   core_times == 8'd10;
}
constraint spd_base_cfg::constr_spd_fail_8to15_pass
{
   th_init >= 'h1000;
   th_fail >= 'h1000;
   th_pass >= 'h1000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_fail >= 8*th_pass;
   th_fail <= 15*th_pass;
   times_cnt == 8'd2;
   core_times == 8'd20;
}

constraint spd_base_cfg::constr_spd_init_gt_pass
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_init >= th_pass;
   times_cnt == 8'd6;
   core_times == 8'd5;
}

constraint spd_base_cfg::constr_spd_init_lt_pass
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_init <= th_pass;
   times_cnt == 8'd6;
   core_times == 8'd5;
}

constraint spd_base_cfg::constr_spd_init_eq_pass
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_init == th_pass;
   times_cnt == 8'd6;
   core_times == 8'd5;
}

constraint spd_base_cfg::constr_spd_init_1to2_pass
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_init >= 1*th_pass;
   th_init <= 2*th_pass;
   times_cnt == 8'd6;
   core_times == 8'd5;
}

constraint spd_base_cfg::constr_spd_init_2to5_pass
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_init >= 2*th_pass;
   th_init <= 5*th_pass;
   times_cnt == 8'd6;
   core_times == 8'd5;
}

constraint spd_base_cfg::constr_spd_init_5to8_pass
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_init >= 5*th_pass;
   th_init <= 8*th_pass;
   times_cnt == 8'd3;
   core_times == 8'd10;
}
constraint spd_base_cfg::constr_spd_init_8to15_pass
{
   th_init >= 'h1000;
   th_fail >= 'h1000;
   th_pass >= 'h1000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_init >= 8*th_pass;
   th_init <= 15*th_pass;
   times_cnt == 8'd2;
   core_times == 8'd20;
}

constraint spd_base_cfg::constr_spd_pass_1to2_init
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_pass >= 1*th_init;
   th_pass <= 2*th_init;
   times_cnt == 8'd6;
   core_times == 8'd5;
}

constraint spd_base_cfg::constr_spd_pass_2to5_init
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_pass >= 2*th_init;
   th_pass <= 5*th_init;
   times_cnt == 8'd6;
   core_times == 8'd5;
}

constraint spd_base_cfg::constr_spd_pass_5to8_init
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_pass >= 5*th_init;
   th_pass <= 8*th_init;
   times_cnt == 8'd3;
   core_times == 8'd10;
}
constraint spd_base_cfg::constr_spd_pass_8to15_init
{
   th_init >= 'h1000;
   th_fail >= 'h1000;
   th_pass >= 'h1000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_pass >= 8*th_init;
   th_pass <= 15*th_init;
   times_cnt == 8'd2;
   core_times == 8'd20;
}

constraint spd_base_cfg::constr_spd_init_gt_fail
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_init >= th_fail;
   times_cnt == 8'd6;
   core_times == 8'd5;
}

constraint spd_base_cfg::constr_spd_init_eq_fail
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_init == th_fail;
   times_cnt == 8'd6;
   core_times == 8'd5;
}

constraint spd_base_cfg::constr_spd_init_lt_fail
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_init <= th_fail;
   times_cnt == 8'd6;
   core_times == 8'd5;
}

constraint spd_base_cfg::constr_spd_init_1to2_fail
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_init >= 1*th_fail;
   th_init <= 2*th_fail;
   times_cnt == 8'd6;
   core_times == 8'd5;
}

constraint spd_base_cfg::constr_spd_init_2to5_fail
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_init >= 2*th_fail;
   th_init <= 5*th_fail;
   times_cnt == 8'd6;
   core_times == 8'd5;
}

constraint spd_base_cfg::constr_spd_init_5to8_fail
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_init >= 5*th_fail;
   th_init <= 8*th_fail;
   times_cnt == 8'd3;
   core_times == 8'd10;
}
constraint spd_base_cfg::constr_spd_init_8to15_fail
{
   th_init >= 'h1000;
   th_fail >= 'h1000;
   th_pass >= 'h1000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_init >= 8*th_fail;
   th_init <= 15*th_fail;
   times_cnt == 8'd2;
   core_times == 8'd20;
}
constraint spd_base_cfg::constr_spd_fail_1to2_init
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_fail >= 1*th_init;
   th_fail <= 2*th_init;
   times_cnt == 8'd6;
   core_times == 8'd5;
}

constraint spd_base_cfg::constr_spd_fail_2to5_init
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_fail >= 2*th_init;
   th_fail <= 5*th_init;
   times_cnt == 8'd6;
   core_times == 8'd5;
}

constraint spd_base_cfg::constr_spd_fail_5to8_init
{
   th_init >= 'h2000;
   th_fail >= 'h2000;
   th_pass >= 'h2000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_fail >= 5*th_init;
   th_fail <= 8*th_init;
   times_cnt == 8'd3;
   core_times == 8'd10;
}
constraint spd_base_cfg::constr_spd_fail_8to15_init
{
   th_init >= 'h1000;
   th_fail >= 'h1000;
   th_pass >= 'h1000;

   th_mssel inside {'h0};
   th_to inside {1'b0};

   th_fail >= 8*th_init;
   th_fail <= 15*th_init;
   times_cnt == 8'd2;
   core_times == 8'd20;
}

constraint spd_base_cfg::constr_spd_global_passfail
{
   passcnt_global_start inside {32'h0};
   failcnt_global_start inside {32'h0};
}
constraint spd_base_cfg::constr_spd_global_passfail_lowlow
{
   passcnt_global_start inside {[1:32'h0fffffff]};
   failcnt_global_start inside {[1:32'h0fffffff]};
}

constraint spd_base_cfg::constr_spd_global_passfail_lowhigh
{
   passcnt_global_start inside {[1:32'h0fffffff]};
   failcnt_global_start inside {[32'hefffffff:32'hffffffff-1]};
}

constraint spd_base_cfg::constr_spd_global_passfail_lowmax
{
   passcnt_global_start inside {[1:32'h0fffffff]};
   failcnt_global_start inside {[32'hffffffff-10:32'hffffffff]};
}

constraint spd_base_cfg::constr_spd_global_passfail_highlow
{
   passcnt_global_start inside {[32'hefffffff:32'hffffffff-1]};
   failcnt_global_start inside {[1:32'h0fffffff]};
}
constraint spd_base_cfg::constr_spd_global_passfail_highhigh
{
   passcnt_global_start inside {[32'hefffffff:32'hffffffff-1]};
   failcnt_global_start inside {[32'hefffffff:32'hffffffff-1]};
}
constraint spd_base_cfg::constr_spd_global_passfail_highmax
{
   passcnt_global_start inside {[32'hefffffff:32'hffffffff-1]};
   failcnt_global_start inside {[32'hffffffff-10:32'hffffffff]};
}

constraint spd_base_cfg::constr_spd_global_passfail_maxlow
{
   passcnt_global_start inside {[32'hffffffff-10:32'hffffffff]};
   failcnt_global_start inside {[1:32'h0fffffff]};
}
constraint spd_base_cfg::constr_spd_global_passfail_maxhigh
{
   passcnt_global_start inside {[32'hffffffff-10:32'hffffffff]};
   failcnt_global_start inside {[32'hefffffff:32'hffffffff-1]};
}
constraint spd_base_cfg::constr_spd_global_passfail_maxmax
{
   passcnt_global_start inside {[32'hffffffff-10:32'hffffffff]};
   failcnt_global_start inside {[32'hffffffff-10:32'hffffffff]};
}




constraint spd_base_cfg::constr_spd_local_passfail
{
   passcnt_local_start inside {32'h0};
   failcnt_local_start inside {32'h0};
}
constraint spd_base_cfg::constr_spd_local_passfail_lowlow
{
   passcnt_local_start inside {[0:16'h0fff]};
   failcnt_local_start inside {[0:16'h0fff]};
}

constraint spd_base_cfg::constr_spd_local_passfail_lowhigh
{
   passcnt_local_start inside {[0:16'h0fff]};
   failcnt_local_start inside {[16'hefff:16'hffff]};
}

constraint spd_base_cfg::constr_spd_local_passfail_lowmax
{
   passcnt_local_start inside {[0:16'h0fff]};
   failcnt_local_start inside {[16'hffff-3:16'hffff]};
}

constraint spd_base_cfg::constr_spd_local_passfail_highlow
{
   passcnt_local_start inside {[16'hefff:16'hffff]};
   failcnt_local_start inside {[0:16'h0fff]};
}
constraint spd_base_cfg::constr_spd_local_passfail_highhigh
{
   passcnt_local_start inside {[16'hefff:16'hffff]};
   failcnt_local_start inside {[16'hefff:16'hffff]};
}
constraint spd_base_cfg::constr_spd_local_passfail_highmax
{
   passcnt_local_start inside {[16'hefff:16'hffff]};
   failcnt_local_start inside {[16'hffff-3:16'hffff]};
}

constraint spd_base_cfg::constr_spd_local_passfail_maxlow
{
   passcnt_local_start inside {[16'hffff-3:16'hffff]};
   failcnt_local_start inside {[0:16'h0fff]};
}
constraint spd_base_cfg::constr_spd_local_passfail_maxhigh
{
   passcnt_local_start inside {[16'hffff-3:16'hffff]};
   failcnt_local_start inside {[16'hefff:16'hffff]};
}
constraint spd_base_cfg::constr_spd_local_passfail_maxmax
{
   passcnt_local_start inside {[16'hffff-3:16'hffff]};
   failcnt_local_start inside {[16'hffff-3:16'hffff]};
}



constraint spd_base_cfg::constr_spds
{
   foreach(spds_r[i]) 
      spds_r[i] dist {1:=25, 2:=25, 3:=25, 4:=25};
   foreach(spds_r[i])
      spds[i*4+:4] == spds_r[i];
}
constraint spd_base_cfg::constr_spds_normal
{
   foreach(spds_r[i]) 
      spds_r[i] dist {1:=15, 2:=35, 3:=35, 4:=15};
   foreach(spds_r[i])
      spds[i*4+:4] == spds_r[i];
}
constraint spd_base_cfg::constr_spds_12_equal
{
   foreach(spds_r[i]) 
      spds_r[i] dist {1:=25, 2:=25};
   foreach(spds_r[i])
      spds[i*4+:4] == spds_r[i];
}
constraint spd_base_cfg::constr_spds_23_equal
{
   foreach(spds_r[i]) 
      spds_r[i] dist {2:=25, 3:=25};
   foreach(spds_r[i])
      spds[i*4+:4] == spds_r[i];
}
constraint spd_base_cfg::constr_spds_34_equal
{
   foreach(spds_r[i]) 
      spds_r[i] dist {3:=25, 4:=25};
   foreach(spds_r[i])
      spds[i*4+:4] == spds_r[i];
}


// bins LOW = {[32'h0000_0000: 32'h2000_0000]};
// bins MID = {[32'h7000_0000: 32'h8000_0000]};
// bins HIGH = {[32'he000_0000: 32'hffff_ffff]}; 


// bins LOW = {[0: 15'h1fff]};
// bins MID = {[15'h3fff: 15'h5fff]}; 
// bins HIGH = {[15'h5fff: 15'h7fff]};

constraint spd_base_cfg::constr_spd_thms
{
   th_mssel == 1'b0;
   th_to == 32'h0;
   lv1_thms_add == 1'b0;
   lv1_thms   == 15'h0;
   lv2_thms_add == 1'b0;
   lv2_thms   == 15'h0;
   lv3_thms_add == 1'b0;
   lv3_thms   == 15'h0;
   lv4_thms_add == 1'b0;
   lv4_thms   == 15'h0;
}
constraint spd_base_cfg::constr_spd_thms_equal_low
{
   th_mssel == 1'b0;
   th_to dist  {[32'h0000_0100: 32'h0000_2000]:/3000, [32'h7000_0000: 32'h8000_0000]:/3000, [32'he000_0000: 32'hffff_ffff]:/3000};

   lv1_thms_add inside {[1'b0:1'b1]};
   lv1_thms     inside {[0: 15'h1fff]};
}

constraint spd_base_cfg::constr_spd_thms_equal_mid
{
   th_mssel == 1'b0;
   th_to dist  {[32'h0000_0100: 32'h0000_2000]:/3000, [32'h7000_0000: 32'h8000_0000]:/3000, [32'he000_0000: 32'hffff_ffff]:/3000};

   lv1_thms_add inside {[1'b0:1'b1]};
   lv1_thms     inside {[15'h3fff: 15'h5fff]}; 
}

constraint spd_base_cfg::constr_spd_thms_equal_high
{
   th_mssel == 1'b0;
   th_to dist  {[32'h0000_0100: 32'h0000_2000]:/3000, [32'h7000_0000: 32'h8000_0000]:/3000, [32'he000_0000: 32'hffff_ffff]:/3000};

   lv1_thms_add inside {[1'b0:1'b1]};
   lv1_thms     inside {[15'h5fff: 15'h7fff]};
}


constraint spd_base_cfg::constr_spd_thms_low
{
   th_mssel == 1'b1;
   th_to dist  {[32'h0000_0100: 32'h0000_2000]:/3000, [32'h7000_0000: 32'h8000_0000]:/3000, [32'he000_0000: 32'hffff_ffff]:/3000};

   lv1_thms_add inside {[1'b0:1'b1]};
   lv1_thms     inside {[0: 15'h1fff]};
   lv2_thms_add dist {[1'b0:1'b1]};
   lv2_thms     inside {[0: 15'h1fff]};
   lv3_thms_add dist {[1'b0:1'b1]};
   lv3_thms     inside {[0: 15'h1fff]};
   lv4_thms_add dist {[1'b0:1'b1]};
   lv4_thms     inside {[0: 15'h1fff]};
}

constraint spd_base_cfg::constr_spd_thms_mid
{
   th_mssel == 1'b1;
   th_to dist  {[32'h0000_0100: 32'h0000_2000]:/3000, [32'h7000_0000: 32'h8000_0000]:/3000, [32'he000_0000: 32'hffff_ffff]:/3000};

   lv1_thms_add inside {[1'b0:1'b1]};
   lv1_thms     inside {[15'h3fff: 15'h5fff]}; 
   lv2_thms_add inside {[1'b0:1'b1]};
   lv2_thms     inside {[15'h3fff: 15'h5fff]};
   lv3_thms_add inside {[1'b0:1'b1]};
   lv3_thms     inside {[15'h3fff: 15'h5fff]};
   lv4_thms_add inside {[1'b0:1'b1]};
   lv4_thms     inside {[15'h3fff: 15'h5fff]};
}

constraint spd_base_cfg::constr_spd_thms_high
{
   th_mssel == 1'b0;
   th_to dist  {[32'h0000_0100: 32'h0000_2000]:/3000, [32'h7000_0000: 32'h8000_0000]:/3000, [32'he000_0000: 32'hffff_ffff]:/3000};

   lv1_thms_add inside {[1'b0:1'b1]};
   lv1_thms     inside {[15'h5fff: 15'h7fff]};
   lv2_thms_add inside {[1'b0:1'b1]};
   lv2_thms     inside {[15'h5fff: 15'h7fff]};
   lv3_thms_add inside {[1'b0:1'b1]};
   lv3_thms     inside {[15'h5fff: 15'h7fff]};
   lv4_thms_add inside {[1'b0:1'b1]};
   lv4_thms     inside {[15'h5fff: 15'h7fff]};
   
}

constraint spd_base_cfg::constr_spd_thms_rand
{
   th_mssel == 1'b0;
   th_to dist  {[32'h0000_0100: 32'h0000_2000]:/3000, [32'h7000_0000: 32'h8000_0000]:/3000, [32'he000_0000: 32'hffff_ffff]:/3000};

   lv1_thms_add inside {[1'b0:1'b1]};
   lv1_thms     dist {[15'h5fff: 15'h7fff]:/30, [15'h3fff: 15'h5fff]:/30, [0: 15'h1fff]:/30};
   lv2_thms_add inside {[1'b0:1'b1]};
   lv2_thms     dist {[15'h5fff: 15'h7fff]:/30, [15'h3fff: 15'h5fff]:/30, [0: 15'h1fff]:/30};
   lv3_thms_add inside {[1'b0:1'b1]};
   lv3_thms     dist {[15'h5fff: 15'h7fff]:/30, [15'h3fff: 15'h5fff]:/30, [0: 15'h1fff]:/30};
   lv4_thms_add inside {[1'b0:1'b1]};
   lv4_thms     dist {[15'h5fff: 15'h7fff]:/30, [15'h3fff: 15'h5fff]:/30, [0: 15'h1fff]:/30};
   
}

constraint spd_base_cfg::constr_spdlog_timer_rand
{
   timer_on == 1'b1;
   timer inside {[0:16'hffff]};
}


constraint spd_base_cfg::constr_fakecore_order
{
   foreach(orders[i])
      orders[i] dist {[0:`DESIGN_CORE_NUM-1]:=1};
}

constraint spd_base_cfg::constr_fakecore_order_repeat
{
   foreach(orders[i])
      orders[i] dist {[0:`DESIGN_CORE_NUM-1]:=1};

   orders[0] == orders[1];
   orders[2] == orders[3];
   orders[4] == orders[5];
   orders[6] == orders[7];
   orders[8] == orders[9];
}

constraint spd_base_cfg::constr_fakecore_order_slice_boundary
{
   foreach(orders[i])
      orders[i] dist {[0:`DESIGN_CORE_NUM-1]:=1};
`ifdef SLICE0_START
   orders[0] == `SLICE0_START;
   orders[1] == `SLICE0_START+`SLICE0_CORE_NUM;
`endif
`ifdef SLICE1_START
   orders[2] == `SLICE1_START;
   orders[3] == `SLICE1_START+`SLICE1_CORE_NUM;
`endif
`ifdef SLICE2_START
   orders[4] == `SLICE2_START;
   orders[5] == `SLICE2_START+`SLICE2_CORE_NUM;
`endif
`ifdef SLICE3_START
   orders[6] == `SLICE3_START;
   orders[7] == `SLICE3_START+`SLICE3_CORE_NUM;
`endif
`ifdef SLICE4_START
   orders[8] == `SLICE4_START;
   orders[9] == `SLICE4_START+`SLICE4_CORE_NUM;
`endif
`ifdef SLICE5_START
   orders[10] == `SLICE5_START;
   orders[11] == `SLICE5_START+`SLICE5_CORE_NUM;
`endif
`ifdef SLICE6_START
   orders[12] == `SLICE6_START;
   orders[13] == `SLICE6_START+`SLICE6_CORE_NUM;
`endif
}

constraint spd_base_cfg::constr_lfb_rounds
{
  //lfb_times >= 1;
  `ifdef PL_SIM
    lfb_times inside {[1:4]};
  `else
    lfb_times dist {1:/20 ,[2:14]:/60, 15:/20};
  `endif
  lfb_gate_times+1 < lfb_times;
  lfb_reduce_incre_times < lfb_times;
  lfb_reduce_incre_times > 0;
  lfb_times_tmp >0;
  lfb_times_tmp <= lfb_times-lfb_reduce_incre_times;
  `ifdef PL_SIM
    lfb_round == 2;
  `else
    lfb_round inside {[1:8]};
  `endif
  lfb_last_gate_corenum inside {[1:15]};
  foreach(lfb_round_id[i])
    lfb_round_id[i] inside {[5'h0: `SORT_DEEP*2]};
  
  lfb_round_id[0] == 0;
  lfb_round_id[0] <= lfb_round_id[1];
  lfb_round_id[1] <= lfb_round_id[2];
  lfb_round_id[2] <= lfb_round_id[3];
  lfb_round_id[3] <= lfb_round_id[4];
  lfb_round_id[4] <= lfb_round_id[5];
  lfb_round_id[5] <= lfb_round_id[6];
  lfb_round_id[6] <= lfb_round_id[7];
  lfb_round_id[7] <= lfb_round_id[8];

  if(lfb_round == 4'h1){
    lfb_round_id[1] == `SORT_DEEP;
  }
  else if(lfb_round == 4'h2){
    lfb_round_id[2] == `SORT_DEEP;
  }
  else if(lfb_round == 4'h3){
    lfb_round_id[3] == `SORT_DEEP;
  }
  else if(lfb_round == 4'h4){
    lfb_round_id[4] == `SORT_DEEP;
  }
  else if(lfb_round == 4'h5){
    lfb_round_id[5] == `SORT_DEEP;
  }
  else if(lfb_round == 4'h6){
    lfb_round_id[6] == `SORT_DEEP;
  }
  else if(lfb_round == 4'h7){
    lfb_round_id[7] == `SORT_DEEP;
  }
  else if(lfb_round == 4'h8){
    lfb_round_id[8] == `SORT_DEEP;
  }
  lfb_broken_th dist {[1:2730],[2730:5460],[5461:8190],[8191:20000],[20001:30000],[30001:40000],[40001:65535]};
  lfb_recover_th dist {[1:2730],[2730:5460],[5461:8190],[8191:20000],[20001:30000],[30001:40000],[40001:65535]};
  lfb_recover_th>lfb_broken_th;
  lfb_recover_th/lfb_broken_th dist {1:/20, 2:/20,[3:5]:/20,[6:10]:/20, [11:8191]:/20}; 
  //lfb_broken_th+10 < lfb_recover_th;
  lfb_recover_th+10 < lfb_pass_cnt; 
  lfb_init_recover_cnt+10 <  lfb_broken_th;

  foreach(lfb_broken_cnt[i]){
    lfb_broken_cnt[i] > 0;
    lfb_broken_cnt[i] < lfb_broken_th;
    `ifdef PL_SIM
        lfb_pass_cnt inside{[200:400]};
    `endif
  }
  foreach(lfb_broken_cnt_lost[i]){
    lfb_broken_cnt_lost[i] > 0;
    lfb_broken_cnt_lost[i] < lfb_broken_th;
//    lfb_broken_cnt_ex_lost <lfb_broken_cnt_lost[i];
    if(i != `DESIGN_CORE_NUM -1){
    lfb_broken_cnt_lost[i] >lfb_broken_cnt_lost[i+1];
    }
  lfb_broken_cnt_lost[i] < lfb_broken_cnt_ex_lost;
  }

  lfb_broken_cnt_ex < lfb_broken_th;
  lfb_broken_cnt_ex_lost < lfb_broken_th;
  lfb_broken_th_out >= lfb_broken_th;

  foreach(lfb_recover_cnt[i]){
    lfb_recover_cnt[i] > 0;
    lfb_recover_cnt[i] >= lfb_recover_th;
  }

  foreach(lfb_pre_recover_cnt[i]){
    lfb_pre_recover_cnt[i]>0;
    lfb_pre_recover_cnt[i] < lfb_init_recover_cnt;
  }

  lfb_recover_cnt_ex > lfb_recover_th;

lfb_round_lost inside {[1:20]};
lfb_round_lost dist {[1:10]:/25, [11:15]:/25, [16:20]:/50};
lfb_round_lost < lfb_times-1;
foreach(lfb_round_lost_id[i])
  lfb_round_lost_id[i] inside {[8'd0: 8'd255]};

  lfb_round_lost_id[0] == 0;
  lfb_round_lost_id[0]  <= lfb_round_lost_id[1];
  lfb_round_lost_id[1]  <= lfb_round_lost_id[2];
  lfb_round_lost_id[2]  <= lfb_round_lost_id[3];
  lfb_round_lost_id[3]  <= lfb_round_lost_id[4];
  lfb_round_lost_id[4]  <= lfb_round_lost_id[5];
  lfb_round_lost_id[5]  <= lfb_round_lost_id[6];
  lfb_round_lost_id[6]  <= lfb_round_lost_id[7];
  lfb_round_lost_id[7]  <= lfb_round_lost_id[8];
  lfb_round_lost_id[8]  <= lfb_round_lost_id[9];
  lfb_round_lost_id[9]  <= lfb_round_lost_id[10];
  lfb_round_lost_id[10] <= lfb_round_lost_id[11];
  lfb_round_lost_id[11] <= lfb_round_lost_id[12];
  lfb_round_lost_id[12] <= lfb_round_lost_id[13];
  lfb_round_lost_id[13] <= lfb_round_lost_id[14];
  lfb_round_lost_id[14] <= lfb_round_lost_id[15];
  lfb_round_lost_id[15] <= lfb_round_lost_id[16];
  lfb_round_lost_id[16] <= lfb_round_lost_id[17];
  lfb_round_lost_id[17] <= lfb_round_lost_id[18];
  lfb_round_lost_id[18] <= lfb_round_lost_id[19];
  lfb_round_lost_id[19] <= lfb_round_lost_id[20];

  lfb_round_lost_id[1]  - lfb_round_lost_id[0]  <= `SORT_DEEP;
  lfb_round_lost_id[2]  - lfb_round_lost_id[1]  <= `SORT_DEEP;
  lfb_round_lost_id[3]  - lfb_round_lost_id[2]  <= `SORT_DEEP;
  lfb_round_lost_id[4]  - lfb_round_lost_id[3]  <= `SORT_DEEP;
  lfb_round_lost_id[5]  - lfb_round_lost_id[4]  <= `SORT_DEEP;
  lfb_round_lost_id[6]  - lfb_round_lost_id[5]  <= `SORT_DEEP;
  lfb_round_lost_id[7]  - lfb_round_lost_id[6]  <= `SORT_DEEP;
  lfb_round_lost_id[8]  - lfb_round_lost_id[7]  <= `SORT_DEEP;
  lfb_round_lost_id[9]  - lfb_round_lost_id[8]  <= `SORT_DEEP;
  lfb_round_lost_id[10] - lfb_round_lost_id[9]  <= `SORT_DEEP;
  lfb_round_lost_id[11] - lfb_round_lost_id[10] <= `SORT_DEEP;
  lfb_round_lost_id[12] - lfb_round_lost_id[11] <= `SORT_DEEP;
  lfb_round_lost_id[13] - lfb_round_lost_id[12] <= `SORT_DEEP;
  lfb_round_lost_id[14] - lfb_round_lost_id[13] <= `SORT_DEEP;
  lfb_round_lost_id[15] - lfb_round_lost_id[14] <= `SORT_DEEP;
  lfb_round_lost_id[16] - lfb_round_lost_id[15] <= `SORT_DEEP;
  lfb_round_lost_id[17] - lfb_round_lost_id[16] <= `SORT_DEEP;
  lfb_round_lost_id[18] - lfb_round_lost_id[17] <= `SORT_DEEP;
  lfb_round_lost_id[19] - lfb_round_lost_id[18] <= `SORT_DEEP;
  lfb_round_lost_id[20] - lfb_round_lost_id[19] <= `SORT_DEEP;

  if(lfb_round_lost == 8'd1){
    lfb_round_lost_id[1]  <= `SORT_DEEP;
  }
  else if(lfb_round_lost == 8'd2){
    lfb_round_lost_id[2]  <= 2*`SORT_DEEP;
  }
  else if(lfb_round_lost == 8'd3){
    lfb_round_lost_id[3]  <= 3*`SORT_DEEP;
  }
  else if(lfb_round_lost == 8'd4){
    lfb_round_lost_id[4]  <= 4*`SORT_DEEP;
  }
  else if(lfb_round_lost == 8'd5){
    lfb_round_lost_id[5]  <= 5*`SORT_DEEP;
  }
  else if(lfb_round_lost == 8'd6){
    lfb_round_lost_id[6]  <= 6*`SORT_DEEP;
  }
  else if(lfb_round_lost == 8'd7){
    lfb_round_lost_id[7]  <= 7*`SORT_DEEP;
  }
  else if(lfb_round_lost == 8'd8){
    lfb_round_lost_id[8]  <= 8*`SORT_DEEP;
  }
  else if(lfb_round_lost == 8'd9){
    lfb_round_lost_id[9]  <= 9*`SORT_DEEP;
  }
  else if(lfb_round_lost == 8'd10){
    lfb_round_lost_id[10] <= 10*`SORT_DEEP;
  }
  else if(lfb_round_lost == 8'd11){
    lfb_round_lost_id[11] <= 11*`SORT_DEEP;
  }
  else if(lfb_round_lost == 8'd12){
    lfb_round_lost_id[12] <= 12*`SORT_DEEP;
  }
  else if(lfb_round_lost == 8'd13){
    lfb_round_lost_id[13] <= 13*`SORT_DEEP;
  }
  else if(lfb_round_lost == 8'd14){
    lfb_round_lost_id[14] <= 14*`SORT_DEEP;
  }
  else if(lfb_round_lost == 8'd15){
    lfb_round_lost_id[15] <= 15*`SORT_DEEP;
  }
  else if(lfb_round_lost == 8'd16){
    lfb_round_lost_id[16] <= 16*`SORT_DEEP;
  }
  else if(lfb_round_lost == 8'd17){
    lfb_round_lost_id[17] <= 17*`SORT_DEEP;
  }
  else if(lfb_round_lost == 8'd18){
    lfb_round_lost_id[18] <= 18*`SORT_DEEP;
  }
  else if(lfb_round_lost == 8'd19){
    lfb_round_lost_id[19] <= 19*`SORT_DEEP;
  }
  else if(lfb_round_lost == 8'd20){
    lfb_round_lost_id[20] <= 20*`SORT_DEEP;
  }
}


constraint spd_base_cfg::constr_lfb_bro_or_rec{
  
}

constraint spd_base_cfg::constr_rand_gbp_num{
    soft rand_gbp_num inside {[1:15]};
}

constraint spd_base_cfg::constr_lfb_refmdl{
    //lfb_broken_core_times dist {0:/20, [1:`SORT_DEEP-1]:/60, `SORT_DEEP:/20};
    lfb_broken_core_times dist {0:/40, [1:`SORT_DEEP-1]:/60};
    `ifdef LFB_GBP_CROSS
       // lfb_run_times dist {[1:lfb_times]:/10, [lfb_times+1:2*lfb_times]:/25, [2*lfb_times:5*lfb_times]:/25,[5*lfb_times:10*lfb_times]:/20,[10*lfb_times:15*lfb_times]:/20};
        lfb_run_times inside {[1:16]};
    `else
        //lfb_run_times dist {[1:lfb_times]:/10, [lfb_times+1:3*lfb_times]:/25, [3*lfb_times:10*lfb_times]:/25,[10*lfb_times:20*lfb_times]:/20,[20*lfb_times:50*lfb_times]:/20};
        lfb_run_times inside {[1:16]};
    `endif
    lfb_reg_lost_flag dist {0:/50, 1:/50};
    lfb_recover_close_flag dist {0:/50, 1:/50};
    rand_gbp_lfb_gate_num dist {0:/15, [1:`SORT_DEEP-1]:/55, `SORT_DEEP:/15, [`SORT_DEEP+1:`DESIGN_CORE_NUM]:/15};
    //rand_gbp_lfb_gate_num dist {0:/30, [1:`SORT_DEEP-1]:/55, `SORT_DEEP:/15};
    lfb_broken_th dist {[1:2730],[2730:5460],[5461:8190],[8191:20000],[20001:30000],[30001:40000],[40001:65535]};
    lfb_recover_th dist {[1:2730],[2730:5460],[5461:8190],[8191:20000],[20001:30000],[30001:40000],[40001:65535]};
    lfb_times dist {1:/20 ,[2:14]:/60, 15:/20};
    lfb_recover_th>lfb_broken_th;
    lfb_recover_th/lfb_broken_th dist {1:/20, 2:/20,[3:5]:/20,[6:10]:/20, [11:8191]:/20}; 
    lfb_recover_th+10 < lfb_pass_cnt; 
    lfb_init_recover_cnt+10 <  lfb_broken_th;
    lfb_broken_cnt_ex < lfb_broken_th;
}
constraint spd_base_cfg::constr_gbp_refmdl{
    rand_gbp_gate_num dist {0:/15, [1:`SORT_DEEP-1]:/55, `SORT_DEEP:/15, [`SORT_DEEP+1:`DESIGN_CORE_NUM]:/15};
    //rand_gbp_gate_num dist {0:/15, [1:`SORT_DEEP-1]:/55, `SORT_DEEP:/30};
    //gbp_run_times dist {[1:5]:/30, [6:10]:/30, [11:20]:/30, [21:50]:/10};
    gbp_run_times inside {[16:16]};
    gbp_open_core_error_flag dist {0:/50, 1:/50};
    gbp_nonsort_gated_core_flag dist {0:/50, 1:/50};
    spd_glb_set dist {1:/1, 2:/1, 3:/1, 4:/1};
    spd_glb_limit dist {0:/50, 1:/50};
}

constraint spd_base_cfg::constr_spd_init_pass_fail
{
   th_pass dist {[1: 16'h0fff]:/30, [16'h1000: 16'h8fff]:/30, [16'h9000: 16'hffff]:/30};
   th_fail dist {[1: 16'h0fff]:/30, [16'h1000: 16'h8fff]:/30, [16'h9000: 16'hffff]:/30};
   th_init dist {[1: 16'h0fff]:/30, [16'h1000: 16'h8fff]:/30, [16'h9000: 16'hffff]:/30};
}

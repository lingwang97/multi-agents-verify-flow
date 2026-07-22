
interface spd_if ();

   timeunit 1ns;
   timeprecision 10ps;
   import uvm_pkg::*;
   import global_pkg::*;
   import reg_addr::*;
   import spd_pkg::*;
   string       report_id = "cal_adc_if";
   spd_pkg::spd_lfb_refmdl lfb_refmdl_h;
   spd_pkg::spd_gbp_refmdl gbp_refmdl_h;
   logic checks_enable; //always@(*) checks_enable = IF_CHECKS_ENABLE["spd_if"];
   logic coverage_enable; //always@(*) coverage_enable = IF_COVERAGE_ENABLE["spd_if"];

   initial begin
      IF_CHECKS_ENABLE["spd_if"] = 1'b1;     //initially on
      IF_COVERAGE_ENABLE["spd_if"] = 1'b1;   //initially on

   end
   logic pready_in;
   logic pready_out;
   logic psel;
   logic penable;
   logic pwrite_1r;
   logic paddr_sel_0;
   logic [9:0] paddr_1r;
   logic xclk;
   logic clk;
   logic mid_clk;
   logic gbp_sort_mid_clk;
	 logic [71:0][31:0] mid_clk_clone;  // for post sim 
	 logic [35:0]mid_clk_clone_cnt_spdlog_t;
   logic rst;
   logic card_sel;
   logic mid_rst_f_n;
   logic wait_flag;
   logic clk_pin_ri;
   logic pll0_lock;
   logic    [2:0] spd_sel_r;
   logic   syc0;
   logic rst_wait_flag;
   logic [`DESIGN_CORE_NUM-1:0] mx2_hash_clk;
   //SPD
   logic    [`SPD_LEN-1:0]    REG_Spd;
   logic    [16*`DESIGN_CORE_NUM-1:0]   REG_sslog;
   logic    [2:0]             spd_sel[`DESIGN_CORE_NUM+`TINY_CORE_NUM];
   logic    [2:0]             spd_sel_in_core[`DESIGN_CORE_NUM];
   logic    [1:0]         top_rx_mx2_tx[`DESIGN_CORE_NUM+`TINY_CORE_NUM];
   //SPD_Global
   logic    [1:0]             mid_clk_pll_sel;
   logic                      ssdn_protect;
   logic                      REG_glb_limit;
   logic    [2:0]             global_spd_high;
   logic    [2:0]             global_spd_low;
   logic                      global_spd_en;
   logic                      global_set_vld;
   logic    [2:0]             global_set;
   logic                      f_is_REG_Spd;
   // new add for ss_ctrl
   logic    [1:0]             ss_sel;
   logic                      ss_pri;
   logic    [15:0]            ss_pd;
   logic                      spdlog_reset;

   logic                      timeout_signal;
   logic    [31:0]            cnt_timeout;
   logic    [31:0]            REG_timeout;
   //Th0
   logic    [15:0]            th_pass;
   logic    [15:0]            th_fail;

   //Th1
   logic                      th_ms_sel;
   logic    [15:0]            th_init;

   //Th2
   logic    [31:0]            th_to;

   //Th3
   logic                      lv2_th_ms_add;
   logic    [14:0]            lv2_th_ms;
   logic                      lv1_th_ms_add;
   logic    [14:0]            lv1_th_ms;

   //Th4
   logic                      lv4_th_ms_add;
   logic    [14:0]            lv4_th_ms;
   logic                      lv3_th_ms_add;
   logic    [14:0]            lv3_th_ms;

   //RegPllTable
   logic    [2:0]             gate;
   logic    [2:0]             plltable_lv0;
   logic    [2:0]             plltable_lv1;
   logic    [2:0]             plltable_lv2;
   logic    [2:0]             plltable_lv3;

   logic    [2:0]             plltable_lv4;
   logic    [2:0]             plltable_lv5;
   logic    [2:0]             plltable_lv6;
   //PLLCNT


   logic    [7:0]             halfclk1_cnt;
   logic    [7:0]             halfclk2_cnt;
   logic    [7:0]             halfclk3_cnt;


   logic    [7:0]             gate_cnt;
   logic    [7:0]             pll3_cnt;
   logic    [7:0]             pll2_cnt;
   logic    [7:0]             pll1_cnt;
   logic    [7:0]             pll0_cnt;
   logic    [7:0]             pll_id;

   //Spdlog_Timer
   logic                      spdlog_timer_on;
   logic    [15:0]            spdlog_timer;

   logic    [31:0]            spdlog_passcnt;
   logic    [31:0]            spdlog_failcnt;
   logic    [`DESIGN_CORE_NUM-1:0] vld_reg_spd_sel;
   logic    [`DESIGN_CORE_NUM-1:0] vld_reg_spd_sel_glb;

   logic    [2:0] reg_spd_sel [`DESIGN_CORE_NUM];
   logic    [15:0]            dh_cnt_fail[`DESIGN_CORE_NUM];
   logic    [15:0]            dh_cnt_fail_onebeat[`DESIGN_CORE_NUM];

   logic    [4:0]             spdcore_ovf_dbg_sel;
   logic                      spdcore_ovf_bitmap_clr;


   //SS TH
   logic    [15:0]            th_lp;
   logic    [15:0]            th_hp;
   logic    [15:0]            th_dp;

   logic    [7:0]            REG_normal_trig_acc;
   logic    [7:0]            REG_fail_trig_acc;
   logic    [7:0]            REG_pass_trig_acc;
   logic                     REG_dh_cnt_wdt_on;
   logic    [15:0]           REG_dh_cnt_wdt_timer;
   //SS_Rechk
   logic    [3:0]             max_rechk;
   logic                      th_same;
   logic    [15:0]          th_delta1;
   logic    [15:0]          th_delta2;
   logic    [15:0]          th_delta3;
   logic    [15:0]          th_delta4;

   logic                    rst_stable;

   // logic                   tinycore_clk167;
   // logic                   tinycore_clk168;

   //logic                   tinycore_clk[`TINY_CORE_NUM];

   logic [15:0] pass_local[`DESIGN_CORE_NUM];
   logic [15:0] fail_local[`DESIGN_CORE_NUM];

 
   logic [3:0] bestpll[`DESIGN_CORE_NUM];

    real clk_prod[`DESIGN_CORE_NUM];

   logic [7:0]    check_id;
   logic          check_done;
   logic          check_pass;
   logic          selfwork_aging_update;

   logic          last_spd_done;

   logic          check_enable = 1'b0;
   logic          spd_fresh_done;
   logic          spd_fresh_start;

   logic          mid_clk_gated_ss1;
   logic          mid_clk_gated_ss2;
   logic          mid_clk_gated_ss3;

   logic          ss1_clr;
   logic          ss2_clr;
   logic          ss_simple_en;
   logic          ss_adaptive_en;

   bit            my_pass[`DESIGN_CORE_NUM];
   bit            my_fail[`DESIGN_CORE_NUM];
   bit            spd_up[`DESIGN_CORE_NUM];
   bit            spd_down[`DESIGN_CORE_NUM];

   logic [3:0]    state;
   logic [3:0]    spd_state_cur[`DESIGN_CORE_NUM-1:0];
   logic          dh_worse[`DESIGN_CORE_NUM-1:0];
   logic          all_pll_used[`DESIGN_CORE_NUM-1:0];

   logic [15:0]   set_cnt_timer = 0;

   logic [1:0]    pll0_status[`DESIGN_CORE_NUM-1:0];
   logic [1:0]    pll1_status[`DESIGN_CORE_NUM-1:0];
   logic [1:0]    pll2_status[`DESIGN_CORE_NUM-1:0];
   logic [1:0]    pll3_status[`DESIGN_CORE_NUM-1:0];

   logic [1:0]    halfclk0_status[`DESIGN_CORE_NUM-1:0];
   logic [1:0]    halfclk1_status[`DESIGN_CORE_NUM-1:0];
   logic [1:0]    halfclk2_status[`DESIGN_CORE_NUM-1:0];

   logic [2:0]    diag_flag[`DESIGN_CORE_NUM-1:0];
   logic [2:0]    low_diag_flag[`DESIGN_CORE_NUM-1:0];
   logic [3:0]    spd2_up[`DESIGN_CORE_NUM-1:0];
   logic [3:0]    spd2_down[`DESIGN_CORE_NUM-1:0];
   logic [3:0]    pass_trigger[`DESIGN_CORE_NUM-1:0];
   logic [3:0]    normal_trigger[`DESIGN_CORE_NUM-1:0];
   logic [3:0]    fail_trigger[`DESIGN_CORE_NUM-1:0];
   logic [3:0]    timeout_trigger[`DESIGN_CORE_NUM-1:0];
   logic [3:0]    reg_spdhigh_tmp[`DESIGN_CORE_NUM-1:0];
   logic [3:0]    reg_spdlow_tmp[`DESIGN_CORE_NUM-1:0];
   logic          ss_state_clr;
   logic          dh_wdt_timeout;

   bit   [`DESIGN_CORE_NUM-1:0] clk_spd;
   bit   [`DESIGN_CORE_NUM-1:0] tclk_spd_gated;
   byte  tclk_spd_cnt[`DESIGN_CORE_NUM];
   logic          REG_gbp_en;
   //self_aging
   logic    REG_self_aging_en;

   logic    selfwork_aging_done;
   logic    selfwork_aging_pass;
   logic[7:0]  selfwork_aging_coreid;
   logic    thsr_spd_go;
   logic[1:0]   self_aging_to_spd;
   logic    dh_check_done;
   logic    dh_check_pass;
   logic[7:0]  dh_check_id;

   initial begin
        rst_stable=1'b0;
        #10ns;
        @(negedge rst)
        rst_stable=1'b1;
   end

  	//for idle check
	generate
		for(genvar i=0;i<`DESIGN_CORE_NUM;i=i+1) begin
			assign vld_reg_spd_sel_glb[i]= (vld_reg_spd_sel[i] | global_set_vld);
		end
	endgenerate

	always_ff @(posedge mid_clk) begin
		dh_cnt_fail_onebeat<=dh_cnt_fail;
	end

   initial   begin
		wait_flag = 0;
		repeat(50) @(posedge clk);
		wait_flag = 1;

   end

   generate
     for(genvar i=0;i<`DESIGN_CORE_NUM;i=i+1) begin
       always@(posedge clk iff (clk===1'b1 && REG_gbp_en)) begin
         tclk_spd_cnt[i]=0;
         fork
           forever@(posedge clk_spd[i] iff clk_spd[i]===1'b1) tclk_spd_cnt[i]=tclk_spd_cnt[i]+1;
           @(negedge clk iff clk===1'b0);
         begin
            wait(rst == 1'b0);
         end
         join_any
         disable fork;
         if(tclk_spd_cnt[i]==0) tclk_spd_gated[i]=1'b1; else tclk_spd_gated[i]=1'b0;
         if(rst == 1'b0)begin
            repeat(15) @(posedge clk);
         end

       end
     end
   endgenerate

    real clk_f0[`DESIGN_CORE_NUM];
    byte  clk_prod_cnt[`DESIGN_CORE_NUM];
   generate
     for(genvar i=0;i<`DESIGN_CORE_NUM;i=i+1) begin
       always@(posedge clk ) begin
         clk_prod_cnt[i]=0;
         fork
           forever@(posedge clk_spd[i] iff clk_spd[i]===1'b1)begin
              clk_f0[i]=$realtime;
              //@(negedge clk_spd[i]);
              @(posedge clk_spd[i]);
              //clk_prod[i] = ($realtime - clk_f0[i])*2.0;
              clk_prod[i] = ($realtime - clk_f0[i]);
              clk_prod_cnt[i] = 1;
              break;
           end
           @(negedge clk iff clk===1'b0);
         join_any
         disable fork;
         if(clk_prod_cnt[i]==0) clk_prod[i] = 0.0;
       end
     end
   endgenerate


//======================================//
//=========== spd gbp signal ===========//
//======================================//
   logic          timer_stop_gbp;
   logic          timer_stop;
   logic          spdlog_clear;
   logic          gbp_closing;
   logic          sort_done;
   logic          sort_en;
   //logic          REG_gbp_en;
   logic          REG_gbp_vld;
   logic [7:0]    REG_gbp_gate_num;
   logic          gbp_done;
   logic [7:0]    gbp_gated_core_num;
   logic [7:0]    gbp_nonsort_gated_core_num;
   logic [7:0]    gbp_open_core_error_num;
   logic [(`SORT_DEEP*`CORE_ID_WIDTH)-1:0] worst_core_id;
   logic [`SORT_DEEP-1:0] worst_core_id_mark;
   logic [7:0]    gbp_id;
   logic [35:0]   Spdlog_Timer_gbp;
   logic          gbp_mode;
   logic          gbp_st;
   logic          spd_busy;
   logic          is_REG_Spdlog_Timer;
   byte unsigned  TB_worst_core_id[`SORT_DEEP];
   byte unsigned     TB_op_core_id[`SORT_DEEP];
   byte unsigned    RTL_op_core_id[`SORT_DEEP];
   int   TB_delta_gate_num,TB_vld_num_in_spdlogtime,TB_gbp_gated_core_num;
   bit  [`DESIGN_CORE_NUM-1:0] TB_halfway ;
   bit  [`DESIGN_CORE_NUM-1:0] TB_check_gate_pass;
   bit  [`DESIGN_CORE_NUM-1:0] TB_check_open_pass;
   logic          vld_Work;
   logic          send_work_round_start;
   logic          send_work_check_pass;



   logic [15:0]   worst_spdlog_array[`SORT_DEEP-1:0];
   logic [15:0]   worst_core_id_array[`SORT_DEEP-1:0];

   logic [35:0]   cnt_spdlog_timer;
   logic [383:0]  spd_raw;

   logic spd_gbp_assertion_checks_disable = 1'b0;


   logic disable_check_en = 1'b0;

   always@(negedge REG_gbp_vld ) begin
     automatic int idx=0;
     #1ns;
     if (TB_delta_gate_num[30:0]!=0) begin
       foreach(RTL_op_core_id[i]) RTL_op_core_id[i]='hff;
       fork
         forever @(gbp_id iff (gbp_id!='hff && gbp_st))  RTL_op_core_id[idx++]=gbp_id;
         @(negedge gbp_done);
         @(negedge gbp_st);
         @(posedge REG_gbp_vld);
       join_any
       disable fork;
     end
   end

   generate
   for(genvar i=0; i<`SORT_DEEP; i++)begin
      always@(worst_core_id[i*`CORE_ID_WIDTH+:8])begin
          if(worst_core_id[i*`CORE_ID_WIDTH+:8] == 8'hff)
              worst_core_id_mark[i] = 1'b0;
          else
              worst_core_id_mark[i] = 1'b1;
      end
   end
   endgenerate;


//##################LFB Signal###################
//  logic                                 lfb_timer_stop;
  logic                                 lfb_sort_done;
  logic   [(`DESIGN_CORE_NUM*16)-1:0]   lfb_REG_SpdLog;
  logic   [(`SORT_DEEP*8)-1:0]          lfb_worst_core_id;
  logic   [(`SORT_DEEP*16)-1:0]         lfb_worst_core_spdlog;
  logic [(`SORT_DEEP*`CORE_ID_WIDTH)-1:0] REG_lfb_broken_core_id;
  logic [(`DESIGN_CORE_NUM * 16) -1 :0] REG_SpdLog;
  bit   [`SORT_DEEP-1:0]                REG_lfb_broken_core_id_mark;
  logic                                 REG_lfb_clear;
  logic                                 REG_lfb_en;
  logic                                 lfb_reg_en;
  logic  [3:0]                          REG_lfb_times;
  logic  [15:0]                         REG_lfb_broken_threshold;
  logic  [15:0]                         REG_lfb_recover_threshold;
  logic [7:0]                           lfb_memory_core_id [`SORT_DEEP-1 :0];
  logic [3:0]                           lfb_memory_times   [`SORT_DEEP-1 :0];


  logic                                 REG_lfb_memory_full;
  logic [`CORE_ID_WIDTH-1:0]            REG_lfb_memory_lost_num;
  logic                                 REG_lfb_broken_core_reg_full;
  logic [`CORE_ID_WIDTH-1:0]            REG_lfb_reg_lost_core_num;

  logic [2:0] lfb_state_cur;
  logic ReduceIncrease_en;
  logic Release_en;
  logic Checkout_en;
  logic Insert_en;
  logic lfb_start;
  logic ReaduceIncrease_done;
  logic lfb_recover_close;
  logic release_done;
  logic insert_done;
  logic current_mem_broken;
  logic current_worst_core_need_insert;
  logic current_mem_reduce;
  logic current_mem_increase;
  logic current_mem_insert_en;
  logic [$clog2(`SORT_DEEP) -1 :0] CycleAddr;
  logic [$clog2(`SORT_DEEP) -1 :0] AdvanceAddr;
  logic lfb_clear;
  logic checkout_done;
  logic current_reg_need_insert;
  logic broken_reg_full;
  logic current_worst_core_marked;
  logic lfb_memory_full;

  logic [7:0] FixedValue;
  logic mem_ReaduceIncrease_en;
  logic mem_insert_en;
  logic [7:0] current_mem;
  logic [7:0] current_worst_core;
  logic CycleAddrEn;
  logic CycleAddrFull;
  logic AdvanceAddrSum;
  logic current_worst_core_vld;



//logic [`SORT_DEEP-1 :0] core_broken               [`SORT_DEEP-1 :0];
//logic [`SORT_DEEP-1 :0] insert_en                 [`SORT_DEEP-1 :0];
//logic [`SORT_DEEP-1 :0] insert_en_transpose       [`SORT_DEEP-1 :0];
//logic [`SORT_DEEP-1 :0] insert_flag               [`SORT_DEEP-1 :0];
//logic [`SORT_DEEP-1 :0] reg_insert_en             [`SORT_DEEP-1 :0];
//logic [`SORT_DEEP-1 :0] reg_insert_en_transpose   [`SORT_DEEP-1 :0];
//logic [`SORT_DEEP-1 :0] reg_insert_flag           [`SORT_DEEP-1 :0];
//logic                   lfb_en;
logic [`SORT_DEEP-1:0] brokenid_vs_memid_mark[`SORT_DEEP-1:0];


generate
for(genvar i=0; i<`SORT_DEEP; i++)begin
    always@(REG_lfb_broken_core_id[i *`CORE_ID_WIDTH+:8])begin
      if(REG_lfb_broken_core_id[i *`CORE_ID_WIDTH+:8] == 8'hff)
        REG_lfb_broken_core_id_mark[i] = 1'b0;
      else
        REG_lfb_broken_core_id_mark[i] = 1'b1;
    end
end
endgenerate;

generate
   for(genvar i=0; i<`SORT_DEEP; i++)begin
      always@(posedge clk)begin
          if(REG_lfb_en == 1)begin
              for(int j=0; j<`SORT_DEEP; j++)begin
                  if(lfb_memory_core_id[i]==8'hff && REG_lfb_broken_core_id[j*8+:8])
                      brokenid_vs_memid_mark[i][j]=1'b0;
                  else if(lfb_memory_core_id[i] == REG_lfb_broken_core_id[j*8+:8])
                      brokenid_vs_memid_mark[i][j]=1'b1;
                  else
                      brokenid_vs_memid_mark[i][j]=1'b0;
              end
          end
      end
   end
endgenerate;

localparam LFB_STATE_IDLE = 3'b000;
localparam LFB_MEM_REDUCE_INCEA = 3'b001;
localparam LFB_REG_RELEASE = 3'b010;
localparam LFB_MEM_CHECKOUT = 3'b011;
localparam LFB_MEM_INSEART = 3'b100;
localparam LFB_STATE_DONE = 3'b101;

parameter logic [2:0] REAL_SPD[8] = '{
    0          : 3'd0,
    3'd5       : 3'd1,
    3'd6       : 3'd2,
    3'd7       : 3'd3,
    3'd1       : 3'd4,
    3'd2       : 3'd5,
    3'd3       : 3'd6,
    3'd4       : 3'd7
};

//Open ada assertion
//bind smart_speed_adaptive spd_ada_assert_extension #(.REAL_SPD(REAL_SPD)) assert_ada (.*);

//better use ifndef PL_SIM
 `include "../../../verify/uvm/uvc/spd/src/spd_if_pc.sv"
 `include "../../../verify/uvm/uvc/spd/src/spd_gbp_if_pc.sv"
 `include "../../../verify/uvm/uvc/spd/src/spd_lfb_if_pc.sv"
 `include "../../../verify/uvm/uvc/spd/src/spd_ada_if_pc.sv"
endinterface : spd_if


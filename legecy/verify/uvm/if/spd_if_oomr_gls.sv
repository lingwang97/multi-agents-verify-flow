`define CPM         `BTC0.sys_ctrl.crg.crg_regfile
`define SPD_REGFILE_PATH  `BTC0.sys_ctrl.u_top_reg_cfg.speed_regfile
assign spd_pif.xclk = `BTC0.sys_ctrl.crg.xclk;
initial begin
   spd_pif.clk=0;
   repeat(3) @(posedge spd_pif.xclk);
   assign spd_pif.clk = `BTC0.sys_ctrl.speed.mid_clk;
end

//assign spd_pif.clk = `BTC0.sys_ctrl.speed.mid_clk;
assign spd_pif.pready_in=`SPD_REGFILE_PATH.pready_in;
assign spd_pif.pready_out=`SPD_REGFILE_PATH.pready_out;
assign spd_pif.psel=`SPD_REGFILE_PATH.psel;
assign spd_pif.penable=`SPD_REGFILE_PATH.penable;
assign spd_pif.pwrite_1r=`SPD_REGFILE_PATH.pwrite_1r;
assign spd_pif.paddr_1r=`SPD_REGFILE_PATH.paddr_1r;

assign spd_pif.mid_clk = `BTC0.sys_ctrl.speed.mid_clk;
assign spd_pif.spd_fresh_done = `BTC0.sys_ctrl.speed.spd_fresh_done;
assign spd_pif.spd_fresh_start =`BTC0.sys_ctrl.work_ctrl.spd2core.spd_fresh_start;
assign spd_pif.card_sel = 1;
assign spd_pif.rst = `BTC0.sys_ctrl.mid_rst_n;
assign spd_pif.mid_rst_f_n = `BTC0.sys_ctrl.mid_rst_f_n;
assign spd_pif.clk_pin_ri = `BTC0.slice0.i_rst_n[0];  
assign spd_pif.REG_Spd = `BTC0.sys_ctrl.speed.REG_Spd;  // wire REG_Spd removed from netlist

assign spd_pif.pll0_lock = `BTC0.sys_ctrl.crg.REG_PLL0_LOCK;
assign spd_pif.spd_sel_r = `BTC0.sys_ctrl.speed.speed_cnt.spd_sel_r[2:0];
assign spd_pif.syc0      = `BTC0.slice0.syc;          
//bit [3:0] spd_sel4b[`DESIGN_CORE_NUM];
//`HDLREF_AllSpeedCore_port_assign(spd_sel4b,spd_sel,2,0)

assign spd_pif.ssdn_protect = `BTC0.sys_ctrl.speed.REG_ssdn_protect;
assign spd_pif.REG_glb_limit = `BTC0.sys_ctrl.speed.REG_glb_limit;

assign spd_pif.global_spd_high = `BTC0.sys_ctrl.speed.REG_SpdHigh;
assign spd_pif.global_spd_low = `BTC0.sys_ctrl.speed.REG_SpdLow;
assign spd_pif.global_spd_en = `BTC0.sys_ctrl.speed.REG_SpdEn;

assign spd_pif.global_set_vld = `BTC0.sys_ctrl.speed.REG_GlbSetVld;
assign spd_pif.global_set = `BTC0.sys_ctrl.speed.REG_GlbSet;

assign spd_pif.last_spd_done = `BTC0.sys_ctrl.speed.G_SPEED_CORE[`DESIGN_CORE_NUM-1].speed_core.vld_reg_spd_sel;

assign spd_pif.th_pass = `BTC0.sys_ctrl.speed.REG_ThPass;
assign spd_pif.th_fail = `BTC0.sys_ctrl.speed.REG_ThFail;

assign spd_pif.th_ms_sel = `BTC0.sys_ctrl.speed.REG_ThMs[0];
assign spd_pif.th_init = `BTC0.sys_ctrl.speed.REG_ThInit;

assign spd_pif.th_to = `BTC0.sys_ctrl.speed.REG_ThTo;

assign spd_pif.lv2_th_ms_add = `BTC0.sys_ctrl.speed.REG_LV2ThMsAdd;
assign spd_pif.lv2_th_ms = `BTC0.sys_ctrl.speed.REG_LV2ThMs;
assign spd_pif.lv1_th_ms_add = `BTC0.sys_ctrl.speed.REG_LV1ThMsAdd;
assign spd_pif.lv1_th_ms = `BTC0.sys_ctrl.speed.REG_LV1ThMs;

assign spd_pif.lv4_th_ms_add = `BTC0.sys_ctrl.speed.REG_LV4ThMsAdd;
assign spd_pif.lv4_th_ms = `BTC0.sys_ctrl.speed.REG_LV4ThMs;
assign spd_pif.lv3_th_ms_add = `BTC0.sys_ctrl.speed.REG_LV3ThMsAdd;
assign spd_pif.lv3_th_ms = `BTC0.sys_ctrl.speed.REG_LV3ThMs;

assign spd_pif.gate =    `BTC0.sys_ctrl.speed.REG_PLLTable_LV0;
assign spd_pif.plltable_lv0 = `BTC0.sys_ctrl.speed.REG_PLLTable_LV1;
assign spd_pif.plltable_lv1 = `BTC0.sys_ctrl.speed.REG_PLLTable_LV2;
assign spd_pif.plltable_lv2 = `BTC0.sys_ctrl.speed.REG_PLLTable_LV3;
assign spd_pif.plltable_lv3 = `BTC0.sys_ctrl.speed.REG_PLLTable_LV4;
assign spd_pif.plltable_lv4 = `BTC0.sys_ctrl.speed.REG_PLLTable_LV5;
assign spd_pif.plltable_lv5 = `BTC0.sys_ctrl.speed.REG_PLLTable_LV6;
assign spd_pif.plltable_lv6 = `BTC0.sys_ctrl.speed.REG_PLLTable_LV7;


assign spd_pif.pll_id  = `BTC0.sys_ctrl.speed.speed_cnt.pll_id;
assign spd_pif.gate_cnt = `BTC0.sys_ctrl.speed.REG_gated_cnt;


assign spd_pif.halfclk3_cnt = `BTC0.sys_ctrl.speed.REG_half_pll3_cnt;
assign spd_pif.halfclk2_cnt = `BTC0.sys_ctrl.speed.REG_half_pll2_cnt;
assign spd_pif.halfclk1_cnt = `BTC0.sys_ctrl.speed.REG_half_pll1_cnt;

assign spd_pif.pll3_cnt = `BTC0.sys_ctrl.speed.REG_pll3_cnt;
assign spd_pif.pll2_cnt = `BTC0.sys_ctrl.speed.REG_pll2_cnt;
assign spd_pif.pll1_cnt = `BTC0.sys_ctrl.speed.REG_pll1_cnt;
assign spd_pif.pll0_cnt = `BTC0.sys_ctrl.speed.REG_pll0_cnt;
assign spd_pif.spdlog_timer_on = `BTC0.sys_ctrl.speed.REG_spdlog_timer_on;
assign spd_pif.spdlog_timer = `BTC0.sys_ctrl.speed.REG_spdlog_timer;
assign spd_pif.spdlog_passcnt = `BTC0.sys_ctrl.speed.REG_Spdlog_Passcnt;
assign spd_pif.spdlog_failcnt = `BTC0.sys_ctrl.speed.REG_Spdlog_Failcnt;
assign spd_pif.spdlog_reset = `BTC0.sys_ctrl.u_top_reg_cfg.REG_SpdLog_reset;

assign spd_pif.spdcore_ovf_dbg_sel = `BTC0.sys_ctrl.speed.REG_spdcore_ovf_dbg_sel;
assign spd_pif.spdcore_ovf_bitmap_clr = `BTC0.sys_ctrl.speed.REG_spdcore_ovf_bitmap_clr;

assign spd_pif.f_is_REG_Spd = `BTC0.sys_ctrl.speed.f_is_REG_Spd;

assign spd_pif.check_id = `BTC0.sys_ctrl.speed.z_check_id;
assign spd_pif.check_done = `BTC0.sys_ctrl.speed.z_check_done;
assign spd_pif.check_pass = `BTC0.sys_ctrl.speed.z_check_mask_pass;
assign spd_pif.selfwork_aging_update = `BTC0.sys_ctrl.speed.selfwork_aging_update;

assign spd_pif.REG_self_aging_en = `BTC0.sys_ctrl.speed.REG_self_aging_en;
assign spd_pif.selfwork_aging_done = `BTC0.sys_ctrl.speed.selfwork_aging_update;
assign spd_pif.selfwork_aging_pass = `BTC0.sys_ctrl.speed.selfwork_aging_pass;
assign spd_pif.selfwork_aging_coreid = `BTC0.sys_ctrl.speed.selfwork_aging_coreid;
assign spd_pif.thsr_spd_go    =`BTC0.sys_ctrl.speed.thsr_spd_go;

assign spd_pif.dh_check_done  = `BTC0.sys_ctrl.speed.dh_check_done;
assign spd_pif.dh_check_pass  = `BTC0.sys_ctrl.speed.dh_check_pass;
assign spd_pif.dh_check_id    = `BTC0.sys_ctrl.speed.dh_check_id;
// for New Model
assign spd_pif.ss_sel = `BTC0.sys_ctrl.speed.REG_ss_sel;
assign spd_pif.ss_pri = `BTC0.sys_ctrl.speed.REG_ss_pri;
assign spd_pif.ss_pd = `BTC0.sys_ctrl.speed.REG_ss_pd;

assign spd_pif.th_lp = `BTC0.sys_ctrl.speed.REG_thlp;
assign spd_pif.th_hp = `BTC0.sys_ctrl.speed.REG_thhp;
assign spd_pif.th_dp = `BTC0.sys_ctrl.speed.REG_thdp;
assign spd_pif.max_rechk = `BTC0.sys_ctrl.speed.REG_ss_max_rechk;

assign spd_pif.th_same = `BTC0.sys_ctrl.speed.REG_th_same;
assign spd_pif.th_delta1 = {`BTC0.sys_ctrl.speed.REG_LV1ThMsAdd,`BTC0.sys_ctrl.speed.REG_LV1ThMs};
assign spd_pif.th_delta2 = {`BTC0.sys_ctrl.speed.REG_LV2ThMsAdd,`BTC0.sys_ctrl.speed.REG_LV2ThMs};
assign spd_pif.th_delta3 = {`BTC0.sys_ctrl.speed.REG_LV3ThMsAdd,`BTC0.sys_ctrl.speed.REG_LV3ThMs};
assign spd_pif.th_delta4 = {`BTC0.sys_ctrl.speed.REG_LV4ThMsAdd,`BTC0.sys_ctrl.speed.REG_LV4ThMs};

`HDLREF_wire_assign(spd_pif.REG_sslog , `BTC0.sys_ctrl.speed.REG_sslog,`DESIGN_CORE_NUM*16,0)

assign spd_pif.mid_clk_gated_ss1 = `BTC0.sys_ctrl.speed.mid_clk_gated_ss1;
assign spd_pif.mid_clk_gated_ss2 = `BTC0.sys_ctrl.speed.mid_clk_gated_ss2;
//assign spd_pif.mid_clk_gated_ss3 = `BTC0.sys_ctrl.speed.mid_clk_gated_ss3;

reg spd_pif_ss_simple_en_ff1;
reg spd_pif_ss_adaptive_en_ff1;
`HDLREF_reg_assign(spd_pif_ss_simple_en_ff1  ,`BTC0.sys_ctrl.speed.ss_simple_en_ff1,0,0)
`HDLREF_reg_assign(spd_pif_ss_adaptive_en_ff1,`BTC0.sys_ctrl.speed.ss_adaptive_en_ff1,0,0)
assign spd_pif.ss1_clr = (spd_pif.ss_sel==2'b10)^~spd_pif_ss_simple_en_ff1;   // copy RTL logic to here
assign spd_pif.ss2_clr = (spd_pif.ss_sel==2'b01)^~spd_pif_ss_adaptive_en_ff1; // copy RTL logic to here
assign spd_pif.ss_state_clr = spd_pif.ss2_clr || spd_pif.global_set_vld || spd_pif.last_spd_done;


assign spd_pif.ss_simple_en   = (spd_pif.ss_sel==2'b01) && spd_pif.global_spd_en;  // copy RTL logic
assign spd_pif.ss_adaptive_en = (spd_pif.ss_sel==2'b10) && spd_pif.global_spd_en;  // copy RTL logic

`ifndef FPGA_SYN
`ifndef NO_TINYCORE
//assign spd_pif.tinycore_clk[0]         =   `BTC0.G_MX2_TINY_SLICE2[`DESIGN_CORE_NUM].mx2_tiny.mx2_tail.mx2_clk_ctrl.clk_spd;
//assign spd_pif.tinycore_clk[1]         =   `BTC0.G_MX2_TINY_SLICE3[`DESIGN_CORE_NUM+1].mx2_tiny.mx2_tail.mx2_clk_ctrl.clk_spd;
//assign spd_pif.tinycore_clk[2]         =   `BTC0.G_MX2_TINY_SLICE6[`DESIGN_CORE_NUM+2].mx2_tiny.mx2_tail.mx2_clk_ctrl.clk_spd;
`endif
`endif



assign spd_pif.dh_wdt_timeout = `BTC0.sys_ctrl.speed.dh_cnt_wdt_timeout;

assign spd_pif.timeout_signal       = `BTC0.sys_ctrl.speed.REG_th_timeout_of;
assign spd_pif.cnt_timeout          = `BTC0.sys_ctrl.speed.cnt_timeout;
assign spd_pif.REG_timeout          = `BTC0.sys_ctrl.speed.REG_ThTo;
assign spd_pif.REG_normal_trig_acc  = `BTC0.sys_ctrl.speed.REG_normal_trig_acc;
assign spd_pif.REG_fail_trig_acc     = `BTC0.sys_ctrl.speed.REG_fail_trig_acc;
assign spd_pif.REG_pass_trig_acc     = `BTC0.sys_ctrl.speed.REG_pass_trig_acc;
assign spd_pif.REG_dh_cnt_wdt_on      = `BTC0.sys_ctrl.speed.REG_dh_cnt_wdt_on;
assign spd_pif.REG_dh_cnt_wdt_timer  = `BTC0.sys_ctrl.speed.REG_dh_cnt_wdt_timer;


generate;
  for(genvar i=0; i<`DESIGN_CORE_NUM; i++)begin
     assign spd_pif.spd_state_cur[i]          = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.smart_speed_adaptive.ss_cur_state[3:0];
     assign spd_pif.diag_flag[i]              = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.smart_speed_adaptive.diag_flag; 
     assign spd_pif.low_diag_flag[i]              = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.smart_speed_adaptive.c_real_diag_flag; 
     assign spd_pif.pll0_status[i]            = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.smart_speed_adaptive.pll0_status; 
     assign spd_pif.pll1_status[i]            = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.smart_speed_adaptive.pll1_status; 
     assign spd_pif.pll2_status[i]            = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.smart_speed_adaptive.pll2_status; 
     assign spd_pif.pll3_status[i]            = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.smart_speed_adaptive.pll3_status; 

     assign spd_pif.halfclk0_status[i]            = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.smart_speed_adaptive.half_clk_0_status; 
     assign spd_pif.halfclk1_status[i]            = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.smart_speed_adaptive.half_clk_1_status; 
     assign spd_pif.halfclk2_status[i]            = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.smart_speed_adaptive.half_clk_2_status; 

     assign spd_pif.spd2_up[i]                = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.smart_speed_adaptive.spd2_up; 
     assign spd_pif.spd2_down[i]              = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.smart_speed_adaptive.spd2_down; 
     assign spd_pif.pass_trigger[i]           = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.smart_speed_adaptive.pass_trigger; 
     assign spd_pif.normal_trigger[i]         = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.smart_speed_adaptive.normal_trigger; 
     assign spd_pif.fail_trigger[i]           = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.smart_speed_adaptive.fail_trigger; 
     assign spd_pif.reg_spdhigh_tmp[i]        = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.smart_speed_adaptive.REG_SpdHigh; 
     assign spd_pif.reg_spdlow_tmp[i]         = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.smart_speed_adaptive.REG_SpdLow; 
     assign spd_pif.pass_local[i]            = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.REG_SpdLog[15:0];
     assign spd_pif.fail_local[i]            = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.REG_SpdLog[31:16];
     assign spd_pif.spd_up[i]                = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.ss_speed_up;
     assign spd_pif.spd_down[i]              = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.ss_speed_down;
     assign spd_pif.my_pass[i]               = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.my_pass;
     assign spd_pif.my_fail[i]               = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.my_fail;
     assign spd_pif.dh_cnt_fail[i]               = `BTC0.sys_ctrl.speed.G_SPEED_DH_CNT[i].speed_dh_cnt.cnt;
     assign spd_pif.dh_worse[i]               = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.smart_speed_adaptive.dh_worse;
     assign spd_pif.all_pll_used[i]               = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.smart_speed_adaptive.all_pll_used;
     assign spd_pif.vld_reg_spd_sel[i]       = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.vld_reg_spd_sel;
     assign spd_pif.reg_spd_sel[i]       = `BTC0.sys_ctrl.speed.G_SPEED_CORE[i].speed_core.reg_spd_sel;
end
endgenerate



`ifndef FPGA_SYN
//`HDLREF_AllSliceAllMx2CoreBus2Bus(0,assign spd_pif.clk_spd[,]=,clk_spd;,clk_spd;,,0,0)

 generate;
 for(genvar i=`SLICE0_START; i < `SLICE0_START + `SLICE0_CORE_NUM; i++)begin
      assign spd_pif.clk_spd[i] =          tb_top.C[0].btnode.btc.slice0.G_MX2[i].mx2.ctrl.tail_clkgen.clk_spd;
 end
 endgenerate

 generate;
 for(genvar i=`SLICE1_START; i < `SLICE1_START + `SLICE1_CORE_NUM; i++)begin
      assign spd_pif.clk_spd[i] =          tb_top.C[0].btnode.btc.slice1.G_MX2[i].mx2.ctrl.tail_clkgen.clk_spd;
 end
 endgenerate

 generate;
 for(genvar i=`SLICE2_START; i < `SLICE2_START + `SLICE2_CORE_NUM; i++)begin
      assign spd_pif.clk_spd[i] =          tb_top.C[0].btnode.btc.slice2.G_MX2[i].mx2.ctrl.tail_clkgen.clk_spd;
 end
 endgenerate

 generate;
 for(genvar i=`SLICE3_START; i < `SLICE3_START + `SLICE3_CORE_NUM; i++)begin
      assign spd_pif.clk_spd[i] =          tb_top.C[0].btnode.btc.slice3.G_MX2[i].mx2.ctrl.tail_clkgen.clk_spd;
 end
 endgenerate

 generate;
 for(genvar i=`SLICE4_START; i < `SLICE4_START + `SLICE4_CORE_NUM; i++)begin
      assign spd_pif.clk_spd[i] =          tb_top.C[0].btnode.btc.slice4.G_MX2[i].mx2.ctrl.tail_clkgen.clk_spd;
 end
 endgenerate

 generate;
 for(genvar i=`SLICE5_START; i < `SLICE5_START + `SLICE5_CORE_NUM; i++)begin
      assign spd_pif.clk_spd[i] =          tb_top.C[0].btnode.btc.slice5.G_MX2[i].mx2.ctrl.tail_clkgen.clk_spd;
 end
 endgenerate
 generate;
 for(genvar i=`SLICE6_START; i < `SLICE6_START + `SLICE6_CORE_NUM; i++)begin
      assign spd_pif.clk_spd[i] =          tb_top.C[0].btnode.btc.slice6.G_MX2[i].mx2.ctrl.tail_clkgen.clk_spd;
 end
 endgenerate

 generate;
 for(genvar i=`SLICE7_START; i < `SLICE7_START + `SLICE7_CORE_NUM; i++)begin
      assign spd_pif.clk_spd[i] =          tb_top.C[0].btnode.btc.slice7.G_MX2[i].mx2.ctrl.tail_clkgen.clk_spd;
 end
 endgenerate

 //generate;
 //for(genvar i=`SLICE8_START; i < `SLICE8_START + `SLICE8_CORE_NUM; i++)begin
 //     assign spd_pif.clk_spd[i] =          tb_top.C[0].btnode.btc.slice8.G_MX2[i].mx2.mx2_tail.mx2_clkgen.clk_spd;
 //end
 //endgenerate

 //generate;
 //for(genvar i=`SLICE9_START; i < `SLICE9_START + `SLICE9_CORE_NUM; i++)begin
 //     assign spd_pif.clk_spd[i] =          tb_top.C[0].btnode.btc.slice9.G_MX2[i].mx2.mx2_tail.mx2_clkgen.clk_spd;
 //end
 //endgenerate

 //generate;
 //for(genvar i=`SLICE10_START; i < `SLICE10_START + `SLICE10_CORE_NUM; i++)begin
 //     assign spd_pif.clk_spd[i] =          tb_top.C[0].btnode.btc.slice10.G_MX2[i].mx2.mx2_tail.mx2_clkgen.clk_spd;
 //end
 //endgenerate
 //generate;
 //for(genvar i=`SLICE11_START; i < `SLICE11_START + `SLICE11_CORE_NUM; i++)begin
 //     assign spd_pif.clk_spd[i] =          tb_top.C[0].btnode.btc.slice11.G_MX2[i].mx2.mx2_tail.mx2_clkgen.clk_spd;
 //end
 //endgenerate



`endif
`ifdef FPGA_SPD_CLK_ENABLE
`define MX2_PATH(slice_index, core_index) `BTC0.slice``slice_index``.G_MX2[core_index]
`define MX2_PATH_ASSIGN(slice_index, core_index) \
   assign spd_pif.clk_spd[core_index]     = `MX2_PATH(slice_index, core_index).G.mx2.ctrl.tail_clkgen.clk_spd;\

generate for(genvar i = 0; i < `SLICE_NUM+1; i = i + 1)begin
   case(i)
      0:begin
           for(genvar j = slice_start[i]; j <= slice_end[i]; j++)begin
            `MX2_PATH_ASSIGN(0,j)
           end
      end
      1:begin
           for(genvar j = slice_start[i]; j <= slice_end[i]; j++)begin
            `MX2_PATH_ASSIGN(1,j)
           end
      end
      2:begin
           for(genvar j = slice_start[i]; j <= slice_end[i]; j++)begin
            `MX2_PATH_ASSIGN(2,j)
           end
      end
      3:begin
           for(genvar j = slice_start[i]; j <=slice_end[i]; j++)begin
            `MX2_PATH_ASSIGN(3,j)
           end
      end
      4:begin
           for(genvar j = slice_start[i]; j <=slice_end[i]; j++)begin
            `MX2_PATH_ASSIGN(4,j)
           end
      end
      5:begin
           for(genvar j = slice_start[i]; j <=slice_end[i]; j++)begin
            `MX2_PATH_ASSIGN(5,j)
           end
      end
      6:begin
           for(genvar j = slice_start[i]; j <=slice_end[i]; j++)begin
            `MX2_PATH_ASSIGN(6,j)
           end
      end
   7:begin
           for(genvar j = slice_start[i]; j <=slice_end[i]; j++)begin
            `MX2_PATH_ASSIGN(7,j)
           end
      end

      default: begin
      end
   endcase
end
endgenerate
`endif


//======================================//
//=========== spd gbp signal ===========//
//======================================//
assign spd_pif.timer_stop_gbp             = `BTC0.sys_ctrl.speed.gbp_top.gbp_sort.timer_stop_gbp;
assign spd_pif.timer_stop                 = `BTC0.sys_ctrl.speed.REG_timer_stop;
assign spd_pif.spdlog_clear               = `BTC0.sys_ctrl.speed.gbp_top.gbp_sort.spdlog_clear;
assign spd_pif.gbp_closing                = `BTC0.sys_ctrl.speed.gbp_top.gbp_sort.gbp_closing;
assign spd_pif.sort_done                  = `BTC0.sys_ctrl.speed.gbp_top.gbp_sort.sort_done;
assign spd_pif.sort_en                    = `BTC0.sys_ctrl.speed.gbp_top.gbp_sort.sort_en;
assign spd_pif.REG_gbp_en                 = `BTC0.sys_ctrl.speed.gbp_top.REG_gbp_en;
assign spd_pif.REG_gbp_vld                = `BTC0.sys_ctrl.speed.gbp_top.REG_gbp_vld;
assign spd_pif.REG_gbp_gate_num           = `BTC0.sys_ctrl.speed.gbp_top.REG_gbp_gate_num;
assign spd_pif.gbp_done                   = `BTC0.sys_ctrl.speed.gbp_top.gbp_done;
assign spd_pif.gbp_gated_core_num         = `BTC0.sys_ctrl.speed.gbp_top.gbp_gated_core_num;        
assign spd_pif.gbp_nonsort_gated_core_num = `BTC0.sys_ctrl.speed.gbp_top.gbp_nonsort_gated_core_num;
assign spd_pif.gbp_open_core_error_num    = `BTC0.sys_ctrl.speed.gbp_top.gbp_open_core_error_num;
assign spd_pif.worst_core_id              = `BTC0.sys_ctrl.speed.gbp_top.gbp_sort.worst_core_id;
assign spd_pif.gbp_id                     = `BTC0.sys_ctrl.speed.gbp_top.gbp_ctrl.gbp_id;
assign spd_pif.Spdlog_Timer_gbp           = `BTC0.sys_ctrl.speed.spdlog_timer_gbp;
assign spd_pif.gbp_st                     = `BTC0.sys_ctrl.speed.gbp_top.gbp_ctrl.gbp_st;
assign spd_pif.gbp_mode                   = `BTC0.sys_ctrl.speed.gbp_top.gbp_ctrl.gbp_mode;
assign spd_pif.worst_spdlog_array         = `BTC0.sys_ctrl.speed.gbp_top.gbp_sort.worst_spdlog_array;
assign spd_pif.worst_core_id_array        = `BTC0.sys_ctrl.speed.gbp_top.gbp_sort.worst_core_id_array;
assign spd_pif.cnt_spdlog_timer           = `BTC0.sys_ctrl.speed.cnt_spdlog_timer[35:0];




//======================================//
//=========== spd lfb signal ===========//
//======================================//
//assign spd_pif.lfb_timer_stop          = `BTC0.sys_ctrl.speed.lfb_top.timer_stop;
assign spd_pif.lfb_sort_done           = `BTC0.sys_ctrl.speed.lfb_top.sort_done;
assign spd_pif.lfb_REG_SpdLog          = `BTC0.sys_ctrl.speed.lfb_top.REG_SpdLog;
assign spd_pif.lfb_worst_core_id       = `BTC0.sys_ctrl.speed.lfb_top.worst_core_id;
assign spd_pif.REG_lfb_broken_core_id       = `BTC0.sys_ctrl.speed.lfb_top.REG_lfb_broken_core_id;
//assign spd_pif.spd_busy                   = `BTC0.sys_ctrl.speed.gbp_top.gbp_ctrl.spd_busy;
assign spd_pif.is_REG_Spdlog_Timer        = `BTC0.sys_ctrl.speed.is_REG_Spdlog_Timer;
assign spd_pif.REG_lfb_clear           = `BTC0.sys_ctrl.speed.REG_lfb_clear;
assign spd_pif.REG_lfb_en             = `BTC0.sys_ctrl.speed.lfb_top.REG_lfb_en;
//assign spd_pif.lfb_memory_core_id     = `BTC0.sys_ctrl.speed.lfb_top.lfb_memory.core_id[15:0];
//assign spd_pif.lfb_memory_times       = `BTC0.sys_ctrl.speed.lfb_top.lfb_memory.times[15:0];
//
assign spd_pif.lfb_state_cur             = `BTC0.sys_ctrl.speed.lfb_top.lfb_state_cur;
assign spd_pif.ReduceIncrease_en         = `BTC0.sys_ctrl.speed.lfb_top.mem_ReaduceIncrease_en;
assign spd_pif.Release_en                = `BTC0.sys_ctrl.speed.lfb_top.reg_release_en;
assign spd_pif.Checkout_en               = `BTC0.sys_ctrl.speed.lfb_top.mem_checkout_en;
assign spd_pif.Insert_en                 = `BTC0.sys_ctrl.speed.lfb_top.mem_insert_en;
assign spd_pif.lfb_start                 = `BTC0.sys_ctrl.speed.lfb_top.lfb_start;
assign spd_pif.ReaduceIncrease_done      = `BTC0.sys_ctrl.speed.lfb_top.mem_ReaduceIncrease_done;
assign spd_pif.lfb_recover_close         = `BTC0.sys_ctrl.speed.lfb_top.lfb_recover_close;
assign spd_pif.release_done              = `BTC0.sys_ctrl.speed.lfb_top.reg_release_done;
assign spd_pif.insert_done               = `BTC0.sys_ctrl.speed.lfb_top.mem_insert_done;
assign spd_pif.current_mem_reduce        = `BTC0.sys_ctrl.speed.lfb_top.current_mem_reduce;
assign spd_pif.current_mem_increase      = `BTC0.sys_ctrl.speed.lfb_top.current_mem_increase;
assign spd_pif.current_mem_broken     = `BTC0.sys_ctrl.speed.lfb_top.current_mem_broken;
assign spd_pif.current_worst_core_need_insert     = `BTC0.sys_ctrl.speed.lfb_top.current_worst_core_need_insert;
assign spd_pif.current_mem_insert_en     = `BTC0.sys_ctrl.speed.lfb_top.current_mem_insert_en;
assign spd_pif.CycleAddr                 = `BTC0.sys_ctrl.speed.lfb_top.CycleAddr;
assign spd_pif.AdvanceAddr               = `BTC0.sys_ctrl.speed.lfb_top.AdvanceAddr;
assign spd_pif.lfb_clear                 = `BTC0.sys_ctrl.speed.lfb_top.lfb_clear;
assign spd_pif.checkout_done            = `BTC0.sys_ctrl.speed.lfb_top.mem_checkout_done;
assign spd_pif.FixedValue                       = `BTC0.sys_ctrl.speed.lfb_top.FixedValue;
assign spd_pif.current_mem                      = `BTC0.sys_ctrl.speed.lfb_top.current_mem;
assign spd_pif.current_worst_core               = `BTC0.sys_ctrl.speed.lfb_top.current_worst_core;
assign spd_pif.CycleAddrEn                      = `BTC0.sys_ctrl.speed.lfb_top.CycleAddrEn;
assign spd_pif.CycleAddrFull                    = `BTC0.sys_ctrl.speed.lfb_top.CycleAddrFull;
assign spd_pif.current_reg_need_insert          = `BTC0.sys_ctrl.speed.lfb_top.current_reg_need_insert;
assign spd_pif.current_worst_core_marked        = `BTC0.sys_ctrl.speed.lfb_top.current_worst_core_marked;
assign spd_pif.broken_reg_full                  = `BTC0.sys_ctrl.speed.lfb_top.broken_reg_full;
assign spd_pif.lfb_memory_full                  = `BTC0.sys_ctrl.speed.lfb_top.lfb_memory_full;
assign spd_pif.AdvanceAddrSum                   = `BTC0.sys_ctrl.speed.lfb_top.AdvanceAddrSum;
assign spd_pif.current_worst_core_vld           = `BTC0.sys_ctrl.speed.lfb_top.current_worst_core_vld;
//######################LFB Signal##############################
assign spd_pif.REG_lfb_times = `BTC0.sys_ctrl.speed.REG_lfb_times; 
assign spd_pif.REG_lfb_broken_threshold =`BTC0.sys_ctrl.speed.REG_lfb_broken_threshold; 
assign spd_pif.REG_lfb_recover_threshold =`BTC0.sys_ctrl.speed.REG_lfb_recover_threshold; 

//assign spd_pif.lfb_en = `BTC0.sys_ctrl.speed.lfb_top.lfb_en;
//assign spd_pif.lfb_reg_en = `BTC0.sys_ctrl.speed.lfb_top.lfb_reg_en;

generate;
  for(genvar i=0; i<`SORT_DEEP; i++)begin
    assign spd_pif.lfb_memory_core_id[i]      = `BTC0.sys_ctrl.speed.lfb_top.lfb_memory.core_id[i];
    assign spd_pif.lfb_memory_times[i]        = `BTC0.sys_ctrl.speed.lfb_top.lfb_memory.times[i];
//    assign spd_pif.core_broken[i]             = `BTC0.sys_ctrl.speed.lfb_top.core_broken[i];
//    assign spd_pif.insert_en[i]               = `BTC0.sys_ctrl.speed.lfb_top.insert_en[i];
//    assign spd_pif.insert_en_transpose[i]     = `BTC0.sys_ctrl.speed.lfb_top.insert_en_transpose[i];
//    assign spd_pif.insert_flag[i]             = `BTC0.sys_ctrl.speed.lfb_top.insert_flag[i];
//    assign spd_pif.reg_insert_en[i]           = `BTC0.sys_ctrl.speed.lfb_top.reg_insert_en[i];
//    assign spd_pif.reg_insert_en_transpose[i] = `BTC0.sys_ctrl.speed.lfb_top.reg_insert_en_transpose[i];
//    assign spd_pif.reg_insert_flag[i]         = `BTC0.sys_ctrl.speed.lfb_top.reg_insert_flag[i];
  end
endgenerate



assign spd_pif.REG_lfb_memory_full            = `BTC0.sys_ctrl.speed.REG_lfb_memory_full;
assign spd_pif.REG_lfb_memory_lost_num        = `BTC0.sys_ctrl.speed.REG_lfb_memory_lost_num;
assign spd_pif.REG_lfb_broken_core_reg_full   = `BTC0.sys_ctrl.speed.REG_lfb_broken_core_reg_full;
assign spd_pif.REG_lfb_reg_lost_core_num      = `BTC0.sys_ctrl.speed.REG_lfb_reg_lost_core_num;

assign spd_pif.vld_Work                   = `BTC0.sys_ctrl.work_ctrl.gen_mid.vld_Work;
assign spd_pif.send_work_round_start      = `BTC0.sys_ctrl.work_ctrl.send_work.round_start;
assign spd_pif.send_work_check_pass       = `BTC0.sys_ctrl.work_ctrl.send_work.check.check_pass;
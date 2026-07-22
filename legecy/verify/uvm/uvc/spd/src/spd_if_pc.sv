`ifndef PL_SIM
`ifndef SPD_ASSERTION_NO_CHK
property global_set_valid;
    @(posedge clk) disable iff(!rst)
        $rose(global_set_vld) |-> global_set >= 0 && global_set <= 4;
endproperty
chk_global_set_valid: 
    assert property(global_set_valid) 
        else `uvm_error("[ASSERT ERR]",$psprintf("global_set_valid fail glbset=%d",global_set));
cov_global_set_valid: 
    cover property(global_set_valid);
/*
property spd_low_high_cpm;
    @(posedge clk) disable iff(!rst)
        ($rose(global_set_vld) && (ss_sel<2'b11)) |-> global_spd_high >= global_spd_low;
endproperty
chk_spd_low_high_cpm: 
    assert property(spd_low_high_cpm) 
        else `uvm_error("[ASSERT ERR]",$psprintf("spd_low_high_cpm fail low=%d high=%x",global_spd_low, global_spd_high));
cov_spd_low_high_cpm: 
    cover property(spd_low_high_cpm);
*/

property plltable_lv0_valid;
    @(posedge clk) disable iff(!rst)
        $rose(global_spd_en) |-> plltable_lv0 >= 0 && plltable_lv0 <= 4;
endproperty
chk_plltable_lv0_valid: 
    assert property(plltable_lv0_valid) 
        else `uvm_error("[ASSERT ERR]",$psprintf("plltable_lv0_valid fail plltable_lv0=%d ",plltable_lv0));
cov_plltable_lv0_valid: 
    cover property(plltable_lv0_valid);

property plltable_lv1_valid;
    @(posedge clk) disable iff(!rst)
        $rose(global_spd_en) |-> plltable_lv1 >= 0 && plltable_lv1 <= 4;
endproperty
chk_plltable_lv1_valid: 
    assert property(plltable_lv1_valid) 
        else `uvm_error("[ASSERT ERR]",$psprintf("plltable_lv1_valid fail plltable_lv1=%d ",plltable_lv1));
cov_plltable_lv1_valid: 
    cover property(plltable_lv1_valid);

property plltable_lv2_valid;
    @(posedge clk) disable iff(!rst)
        $rose(global_spd_en) |-> plltable_lv2 >= 0 && plltable_lv2 <= 4;
endproperty
chk_plltable_lv2_valid: 
    assert property(plltable_lv2_valid) 
        else `uvm_error("[ASSERT ERR]",$psprintf("plltable_lv2_valid fail plltable_lv2=%d ",plltable_lv2));
cov_plltable_lv2_valid: 
    cover property(plltable_lv2_valid);

property plltable_lv3_valid;
    @(posedge clk) disable iff(!rst)
        $rose(global_spd_en) |-> plltable_lv3 >= 0 && plltable_lv3 <= 4;
endproperty
chk_plltable_lv3_valid: 
    assert property(plltable_lv3_valid) 
        else `uvm_error("[ASSERT ERR]",$psprintf("plltable_lv3_valid fail plltable_lv3=%d ",plltable_lv3));
cov_plltable_lv3_valid: 
    cover property(plltable_lv3_valid);

property plltable_lv4_valid;
    @(posedge clk) disable iff(!rst)
        $rose(global_spd_en) |-> plltable_lv4 >= 5 && plltable_lv4 <= 7;
endproperty
chk_plltable_lv4_valid: 
    assert property(plltable_lv4_valid) 
        else `uvm_error("[ASSERT ERR]",$psprintf("plltable_lv4_valid fail plltable_lv4=%d ",plltable_lv4));
cov_plltable_lv4_valid: 
    cover property(plltable_lv4_valid);

property plltable_lv5_valid;
    @(posedge clk) disable iff(!rst)
        $rose(global_spd_en) |-> plltable_lv5 >= 5 && plltable_lv5 <= 7;
endproperty
chk_plltable_lv5_valid: 
    assert property(plltable_lv5_valid) 
        else `uvm_error("[ASSERT ERR]",$psprintf("plltable_lv5_valid fail plltable_lv5=%d ",plltable_lv5));
cov_plltable_lv5_valid: 
    cover property(plltable_lv5_valid);

property plltable_lv6_valid;
    @(posedge clk) disable iff(!rst)
        $rose(global_spd_en) |-> plltable_lv6 >= 5 && plltable_lv6 <= 7;
endproperty
chk_plltable_lv6_valid: 
    assert property(plltable_lv6_valid) 
        else `uvm_error("[ASSERT ERR]",$psprintf("plltable_lv6_valid fail plltable_lv6=%d ",plltable_lv6));
cov_plltable_lv6_valid: 
    cover property(plltable_lv6_valid);

property spd_valid_clk_choose;
    @(posedge clk) disable iff(!rst)
        $changed(ss_sel) |-> ((!mid_clk_gated_ss1)&(!mid_clk_gated_ss2))||((!mid_clk_gated_ss1)&(!mid_clk_gated_ss3))||((!mid_clk_gated_ss3)&(!mid_clk_gated_ss2));
endproperty

chk_spd_valid_clk_choose:
    assert property(spd_valid_clk_choose)
        else `uvm_error("[ASSERT ERR]",$psprintf("Multiple clock is turned on simultaneously, mid_clk_gated_ss1=%d ,mid_clk_gated_ss2=%d, mid_clk_gated_ss3=%d",mid_clk_gated_ss1,mid_clk_gated_ss2,mid_clk_gated_ss3));
cov_spd_valid_clk_choose:
    cover property(spd_valid_clk_choose);

// property spd_pllcnt;
//     @(posedge clk)disable iff(!rst)
//         (global_spd_en== 1'b1 && 1'b0<=spd_sel_r && spd_sel_r<=4&& pll_id == `DESIGN_CORE_NUM && ss_sel<2'b11) |=> ((gate_cnt+pll0_cnt+pll1_cnt+pll2_cnt+pll3_cnt)==`DESIGN_CORE_NUM);
// endproperty
// chk_spd_pllcnt:
//     assert property(spd_pllcnt)
//         else `uvm_error("[ASSERT ERR]",$psprintf("all pll_cnt are not equal to tatal nums,gate_cnt=%d ,pll0_cnt=%d,pll1_cnt=%d,pll2_cnt=%d,pll3_cnt=%d",gate_cnt,pll0_cnt,pll1_cnt,pll2_cnt,pll3_cnt))
// cov_spd_pllcnt:
//     cover property(spd_pllcnt);

property spd_pllcnt_low_freq;
    @(posedge clk)disable iff(!rst)
        (global_spd_en== 1'b1 && 1'b0<=spd_sel_r && spd_sel_r<=7 && pll_id == `DESIGN_CORE_NUM) |=> ((gate_cnt+pll0_cnt+pll1_cnt+pll2_cnt+pll3_cnt+halfclk1_cnt+halfclk2_cnt+halfclk3_cnt)==`DESIGN_CORE_NUM);
endproperty


chk_spd_pllcnt_low_freq:
    assert property(spd_pllcnt_low_freq)
        else `uvm_error("[ASSERT ERR]",$psprintf("LOW Freq enabled,all pll_cnt are not equal to tatal nums,gate_cnt=%d ,pll0_cnt=%d,pll1_cnt=%d,pll2_cnt=%d,pll3_cnt=%d,halfclk1_cnt=%d,halfclk2_cnt=%d,halfclk3_cnt=%d",gate_cnt,pll0_cnt,pll1_cnt,pll2_cnt,pll3_cnt,halfclk1_cnt,halfclk2_cnt,halfclk3_cnt))

cov_spd_pllcnt_low_freq:
    cover property(spd_pllcnt_low_freq);


property thsr_spdgo_finish(i);
    @(posedge clk)disable iff(!rst)
        (REG_self_aging_en== 1'b1 && global_spd_en== 1'b1 && $rose(thsr_spd_go) ) |-> (($past((spd_down[i] | spd_up[i]),5)==0)||$past(timeout_signal,5)==1||$past(timeout_signal,4)==1||$past(timeout_signal,3)==1||$past(timeout_signal,2)==1||$past(timeout_signal,1)==1||$past(timeout_signal,6)==1);
endproperty

generate;
  for(genvar i=0; i<`DESIGN_CORE_NUM; i++)begin
    chk_thsr_spdgo_finish:
        assert property(thsr_spdgo_finish(i))
            else `uvm_error("[ASSERT ERR]",$psprintf("G[%d]:spd_down or spd_up is still triggered before thsr_spdgo",i));
    cov_thsr_spdgo_finish:
        cover property(thsr_spdgo_finish(i));
end
endgenerate


property low_freq_region_idle(i);
    @(posedge clk)  disable iff(!rst)
            ((ss_sel[1]==1'b1) && $rose(vld_reg_spd_sel[i]) && (reg_spd_sel[i]>4 || reg_spd_sel[i]==0)) |=> (spd_state_cur[i]==4'b0) throughout (##1 (!vld_reg_spd_sel[i])##1 (vld_reg_spd_sel_glb[i][=1]));
endproperty

generate;
  for(genvar i=0; i<`DESIGN_CORE_NUM; i++)begin
    chk_low_freq_region_idle:
        assert property(low_freq_region_idle(i))
            else `uvm_error("[ASSERT ERR]",$psprintf("G[%d]:low freq or gate vld_reg_spd_sel enabled,FSM changed",i));
    cov_low_freq_region_idle:
        cover property(low_freq_region_idle(i));
end
endgenerate

property spd_up_down(i);
    @(posedge clk)  disable iff(!rst)
            (!(spd_down[i] & spd_up[i]));
endproperty

generate;
  for(genvar i=0; i<`DESIGN_CORE_NUM; i++)begin
    chk_spd_up_down:
        assert property(spd_up_down(i))
            else `uvm_error("[ASSERT ERR]",$psprintf("G[%d]:spd_down and spd_up are high simultaneously",i));
    cov_spd_up_down:
        cover property(spd_up_down(i));
end
endgenerate

property my_pass_fail(m);
    @(posedge clk)  disable iff(!rst)
        (!(my_pass[m] & my_fail[m]));
endproperty

generate;
  for(genvar n=0; n<`DESIGN_CORE_NUM; n++)begin
    chk_my_pass_fail:
        assert property(my_pass_fail(n))
            else `uvm_error("[ASSERT ERR]",$psprintf("G[%d]:my_pass and my_fail are high simultaneously",n));
    cov_my_pass_fail:
        cover property(my_pass_fail(n));
end
endgenerate

`ifndef AGING_SPD_SIG_MUTEX_OFF
property aging_update_mutex();
    @(posedge clk) disable iff(!rst)
        (global_spd_en==1'b1 || REG_self_aging_en==1'b1) |=> (!(check_done==1'b1 && selfwork_aging_update==1'b1));
endproperty

chk_aging_update_mutex:
    assert property(aging_update_mutex) else `uvm_error("[ASSERT ERR]", "z_check_done and selfwork_aging_update can not be 1 sametime");
cov_aging_update_muxte: cover property(aging_update_mutex);
`endif


initial   begin
  rst_wait_flag = 0;
  repeat(3) @(posedge xclk);
  rst_wait_flag = 1;
end

property plltable_rst_value();
    @(negedge clk) disable iff(!rst_wait_flag)
        (rst==1'b0) |-> ((plltable_lv0==3'b1)&&(plltable_lv1==3'd2)&&(plltable_lv2==3'd3)&&(plltable_lv3==3'd4));
endproperty

chk_plltable_rst_value:
    assert property(plltable_rst_value) else `uvm_error("[ASSERT ERR]", "plltable rst value check failed");
cov_plltable_rst_value: 
    cover property(plltable_rst_value);
 

property ss_th_lp_valid;
    @(posedge clk) disable iff(!rst)
        $rose(global_spd_en) |-> ss_sel == 2'b11 |-> th_lp >= th_hp && th_lp <= th_dp;
endproperty
chk_ss_th_lp_valid: 
    assert property(ss_th_lp_valid) 
        else `uvm_error("[ASSERT ERR]",$psprintf("ss_th_lp_valid fail ss_th_lp=%d ",th_lp));
cov_ss_th_lp_valid: 
    cover property(ss_th_lp_valid);


property ss_th_hp_valid;
    @(posedge clk) disable iff(!rst)
        $rose(global_spd_en) |-> ss_sel == 2'b11 |-> th_hp <= th_dp;
endproperty
chk_ss_th_hp_valid: 
    assert property(ss_th_hp_valid) 
        else `uvm_error("[ASSERT ERR]",$psprintf("ss_th_hp_valid fail ss_th_hp=%d ",th_hp));
cov_ss_th_hp_valid: 
    cover property(ss_th_hp_valid);

`endif
`endif




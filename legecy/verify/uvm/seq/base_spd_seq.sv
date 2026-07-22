localparam WORK_FLAG            = 3'b000;
localparam DIAG_FLAG        = 3'b001;
localparam RECHECK_FLAG         = 3'b010;
localparam SILENCE_FLAG         = 3'b011;
localparam TRY_UP_FLAG         = 3'b100;

localparam PLL_UNUSED           = 3'b000;
localparam PLL_USED             = 3'b001;
localparam PLL_INVALID          = 3'b010;
localparam PLL_TIMEOUT          = 3'b011;


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

function string getStateStr(input bit [3:0] state);
    string strState="UNKNOW";
    case(state)
        SS_IDLE:
            strState = "SS_IDLE";
        SS_WORK:
            strState = "SS_WORK";
        SS_FAULT_SHOT_1:
            strState = "SS_FAULT_SHOT_1";
        SS_RANGE_CHG:
            strState = "SS_RANGE_CHG";
        SS_DIAG:
            strState = "SS_DIAG";
        SS_SPD_CHG:
            strState = "SS_SPD_CHG";
        SS_MONITOR:
            strState = "SS_MONITOR";
        SS_FAULT_SHOT_2:
            strState = "SS_FAULT_SHOT_2";
        SS_RELEASE:
            strState = "SS_RELEASE";
        SS_RECHK:
            strState = "SS_RECHK";
        SS_SLC:
            strState = "SS_SLC";
        SS_REWARD:
            strState = "SS_REWARD";
        SS_TRY_UP:
            strState = "SS_TRY_UP";
        SS_TRY_MONI:
            strState = "SS_TRY_MONI";
        SS_TRY_FAIL:
            strState = "SS_TRY_FAIL";
    endcase 
    return strState;
endfunction




/*  ============================================================  */
/*  ==========================     spd     =====================  */
/*  ============================================================  */
/**
 *  task name: initSpd
 *  Description: 
 *    This task initialized the speed registers that requires after chip power on.
 *  Procedure:
 *    1. config the speed.REG_spdth0.thpass & thfail
 *    2. config the speed.REG_spdth1.thinit & thms
 *    3. config the speed.REG_spdth2
 *    4. config the speed.REG_spdth3
 *    5. config the speed.REG_spdth4
 *    6. config the speed.REG_plltable, to set spd and pll table
 *    7. randomized the spdcore
 *    8. set spdgo to trigger spd write
 *  parameter: none
 */
task initSpd;
    logic [`SPD_LEN-1:0] spd;
    logic [31:0] reg_data;
    assert(spd_cfg_h.randomize());
    //pass:0x6ff1, fail:0x6ff0
    `SET_REG_FIELD(speed, spdth0, thpass, spd_cfg_h.th_pass);
    `SET_REG_FIELD(speed, spdth0, thfail, spd_cfg_h.th_fail);
    `PRINT_REG_SETTING(speed,spdth0);
    reg_data = `GET_REG(speed, spdth0);
    `WR_REG(speed, spdth0,reg_data);

    //th_init: 0x7FFF, th_mssel:0
    `SET_REG_FIELD(speed, spdth1, thinit,   spd_cfg_h.th_init);
    `SET_REG_FIELD(speed, spdth1, thms,     spd_cfg_h.th_mssel);
    `PRINT_REG_SETTING(speed,spdth1);
    reg_data = `GET_REG(speed, spdth1);
    `WR_REG(speed, spdth1, reg_data);

    `WR_REG(speed, spdth2, 32'h0);
    `PRINT_REG_SETTING(speed,spdth2);
    `WR_REG(speed, spdth3, 32'h0);
    `PRINT_REG_SETTING(speed,spdth3);
    `WR_REG(speed, spdth4, 32'h0);
    `PRINT_REG_SETTING(speed,spdth4);

    `SET_REG_FIELD(speed, plltable, plltable_lv0, 0);
    `SET_REG_FIELD(speed, plltable, plltable_lv1, 1);
    `SET_REG_FIELD(speed, plltable, plltable_lv2, 2);
    `SET_REG_FIELD(speed, plltable, plltable_lv3, 3);
    `SET_REG_FIELD(speed, plltable, plltable_lv4, 4);
    `SET_REG_FIELD(speed, plltable, plltable_lv5, 5);
    `SET_REG_FIELD(speed, plltable, plltable_lv6, 6);
    `SET_REG_FIELD(speed, plltable, plltable_lv7, 7);

    `PRINT_REG_SETTING(speed,plltable);
    reg_data = `GET_REG(speed,plltable);
    `WR_REG(speed,plltable,reg_data);

    for(int i=0;i<`SPD_CORE_NUM;i++)begin
        spd[i*4 +: 4] = (i >= `DESIGN_CORE_NUM) ? 4'h0 : (($random % `TB_PLL_NUM) + 1);
    end
    `uvm_info("initSpd",$psprintf(" set spd to 0x%0x",spd),UVM_MEDIUM);
    `WR_REG(speed,spd,spd);
    `PRINT_REG_SETTING(speed,spd);

    //trigger spdgo to apply the REG_Spd
    `SET_REG_FIELD(work, spdsyc_cfg, cfg_spdgo, `ON);
    `PRINT_REG_SETTING(work,spdsyc_cfg);
    `UPDATE_REG(work, spdsyc_cfg);

`ifndef USE_JAMLINK_DRV
    wait(spd_vif.spd_fresh_done);
`endif
endtask : initSpd

/**
 *  task name: initSpdZero
 *  Description: 
 *    This task initialized the speed registers that requires after chip power on.
 *  Procedure:
 *    1. config the speed.REG_spdth0.thpass & thfail
 *    2. config the speed.REG_spdth1.thinit & thms
 *    3. config the speed.REG_spdth2
 *    4. config the speed.REG_spdth3
 *    5. config the speed.REG_spdth4
 *    6. config the speed.REG_plltable, to set spd and pll table
 *    7. set all spd core to one, which means all core pll use pll0
 *    8. set spdgo to trigger spd write
 *  parameter: none
 */
task initSpdZero;
    logic [`SPD_LEN-1:0] spd;
    logic [31:0] reg_data;
    assert(spd_cfg_h.randomize());
    //pass:0x6ff1, fail:0x6ff0
    `SET_REG_FIELD(speed, spdth0, thpass, spd_cfg_h.th_pass);
    `SET_REG_FIELD(speed, spdth0, thfail, spd_cfg_h.th_fail);
    `PRINT_REG_SETTING(speed,spdth0);
    reg_data = `GET_REG(speed, spdth0);
    `WR_REG(speed, spdth0,reg_data);

    //th_init: 0x7FFF, th_mssel:0
    `SET_REG_FIELD(speed, spdth1, thinit,   spd_cfg_h.th_init);
    `SET_REG_FIELD(speed, spdth1, thms,     spd_cfg_h.th_mssel);
    `PRINT_REG_SETTING(speed,spdth1);
    reg_data = `GET_REG(speed, spdth1);
    `WR_REG(speed, spdth1,reg_data);

    `WR_REG(speed, spdth2, 32'h0);
    `PRINT_REG_SETTING(speed,spdth2);
    `WR_REG(speed, spdth3, 32'h0);
    `PRINT_REG_SETTING(speed,spdth3);
    `WR_REG(speed, spdth4, 32'h0);
    `PRINT_REG_SETTING(speed,spdth4);

 
    `SET_REG_FIELD(speed, plltable, plltable_lv0, 0 );
    `SET_REG_FIELD(speed, plltable, plltable_lv1, 1);
    `SET_REG_FIELD(speed, plltable, plltable_lv2, 2);
    `SET_REG_FIELD(speed, plltable, plltable_lv3, 3);
    `SET_REG_FIELD(speed, plltable, plltable_lv4, 4);

    `PRINT_REG_SETTING(speed,plltable);
    reg_data = `GET_REG(speed,plltable);
    `WR_REG(speed,plltable,reg_data);

    for(int i=0;i<`SPD_CORE_NUM;i++)begin
        spd[i*4 +: 4] = (i >= `DESIGN_CORE_NUM) ? 4'h0 : 4'h0;
    end
    `uvm_info("initSpd",$psprintf(" set spd to 0x%0x",spd),UVM_MEDIUM);
    `WR_REG(speed,spd,spd);
    `PRINT_REG_SETTING(speed,spd);

    //trigger spdgo to apply the REG_Spd
    `SET_REG_FIELD(work, spdsyc_cfg, cfg_spdgo, `ON);
    `PRINT_REG_SETTING(work,spdsyc_cfg);
    `UPDATE_REG(work, spdsyc_cfg);

`ifndef USE_JAMLINK_DRV
    wait(spd_vif.spd_fresh_done);
`endif
endtask : initSpdZero

/**
 *  task name: set_spd_init
 *  Description: 
 *    set spdHigh spdLow spdEn spdvld spdglbset and ssdn_protect, 
 *  Procedure:
 *    1. config the spd parameter
 *    2. set spdgo to trigger spd write
 */
task set_spd_init(input [2:0] spdhigh=`TB_PLL_NUM, input [2:0] spdlow=1, input spden=1, input glbsetvld, input [2:0] glbset, input ssdn_pro=0, input [1:0]ss_sel=2'b01, input ss_pri=1'b0, input [15:0] ss_pd=16'h00, input spd_glb_limit=1'b0);

    `SET_REG_FIELD(speed, ss_ctrl, spdhigh, spdhigh); 
    `SET_REG_FIELD(speed, ss_ctrl, spdlow, spdlow);
    `SET_REG_FIELD(speed, ss_ctrl, spden, spden);
    `SET_REG_FIELD(speed, ss_ctrl, glbsetvld, glbsetvld);
    `SET_REG_FIELD(speed, ss_ctrl, glbset, glbset);
    `SET_REG_FIELD(speed, ss_ctrl, ssdn_protect, ssdn_pro);
    `SET_REG_FIELD(speed, ss_ctrl, ss_sel, ss_sel);
    `SET_REG_FIELD(speed, ss_ctrl, ss_pri, ss_pri);
    `SET_REG_FIELD(speed, ss_ctrl, ss_pd, ss_pd);
    `SET_REG_FIELD(speed, ss_ctrl, glb_limit, spd_glb_limit);
    `PRINT_REG_SETTING(speed,ss_ctrl);
    `UPDATE_REG(speed, ss_ctrl);

    `SET_REG_FIELD(work, spdsyc_cfg, cfg_spdgo, `ON);
    `PRINT_REG_SETTING(work,spdsyc_cfg);
    fork
    begin //1.1
        `UPDATE_REG(work, spdsyc_cfg);
    end

    begin //1.2
    fork:wait_freshdone_spdinit
        begin //1.2.1
            $display($time,"wait spd_fresh done");
            wait(spd_vif.spd_fresh_done);
        end
        begin //1.2.2
            #20000000;
            `uvm_error(get_type_name(), "After 2000_0000ns, not get spd_fresh_done"); 
        end
    join_any
    disable wait_freshdone_spdinit;
    end //end 1.2

    join
endtask
task set_spd_init_nosync(input [2:0] spdhigh=`TB_PLL_NUM, input [2:0] spdlow=1, input spden=1, input glbsetvld, input [2:0] glbset, input ssdn_pro=0, input [1:0]ss_sel=2'b01, input ss_pri=1'b0, input [15:0] ss_pd=16'h00, input spd_glb_limit=1'b0);

    `SET_REG_FIELD(speed, ss_ctrl, spdhigh, spdhigh); 
    `SET_REG_FIELD(speed, ss_ctrl, spdlow, spdlow);
    `SET_REG_FIELD(speed, ss_ctrl, spden, spden);
    `SET_REG_FIELD(speed, ss_ctrl, glbsetvld, glbsetvld);
    `SET_REG_FIELD(speed, ss_ctrl, glbset, glbset);
    `SET_REG_FIELD(speed, ss_ctrl, ssdn_protect, ssdn_pro);
    `SET_REG_FIELD(speed, ss_ctrl, ss_sel, ss_sel);
    `SET_REG_FIELD(speed, ss_ctrl, ss_pri, ss_pri);
    `SET_REG_FIELD(speed, ss_ctrl, ss_pd, ss_pd);
    `SET_REG_FIELD(speed, ss_ctrl, glb_limit, spd_glb_limit);
    `PRINT_REG_SETTING(speed,ss_ctrl);
    `UPDATE_REG(speed, ss_ctrl);

endtask
task set_spdlog_reset();
        `SET_REG_FIELD(speed, spdlog_reset, spdlog_reset, `ON);
        `PRINT_REG_SETTING(speed,spdlog_reset);
        `UPDATE_REG(speed, spdlog_reset);
endtask

//
task set_ssth_init(input [15:0] th_lp, input [15:0] th_hp,input [3:0] max_rechk, input [15:0] pass_trig_acc=0, input [7:0] fail_trig_acc=8, input [7:0]normal_trig_acc=8, input bit th_same=1'b1);
    `SET_REG_FIELD(speed, ss_th, thlp, th_lp);
    `SET_REG_FIELD(speed, ss_th, thhp, th_hp);
    `PRINT_REG_SETTING(speed,ss_th);
    `UPDATE_REG(speed, ss_th);

    `SET_REG_FIELD(speed, ss_rechk, th_same, th_same);
    `SET_REG_FIELD(speed, ss_rechk, fail_trig_acc, fail_trig_acc);
    `SET_REG_FIELD(speed, ss_rechk, normal_trig_acc, normal_trig_acc);
    `SET_REG_FIELD(speed, ss_rechk, pass_trig_acc, pass_trig_acc);
    `SET_REG_FIELD(speed, ss_rechk, ss_max_rechk, max_rechk);
    `PRINT_REG_SETTING(speed,ss_rechk);
    `UPDATE_REG(speed, ss_rechk);
endtask

task set_ssdh_th(input[15:0] th_dp);

    `SET_REG_FIELD(speed, ss_dh_th, thdp, th_dp);
    `PRINT_REG_SETTING(speed,ss_dh_th);
    `UPDATE_REG(speed, ss_dh_th);

endtask
task set_th_init(input [15:0] th_pass, input [15:0] th_fail, input [15:0] th_init, input [15:0] th_mssel);
    // `SET_REG_FIELD(speed, spdth0, thpass, thpass);
    // `SET_REG_FIELD(speed, spdth0, thfail, th_fail);
    // `PRINT_REG_SETTING(speed,spdth0);
    // `UPDATE_REG(speed, spdth0);
    //th_init: 0x7FFF, th_mssel:0
    // `SET_REG_FIELD(speed, spdth1, thinit,   th_init);
    // `SET_REG_FIELD(speed, spdth1, thms,     th_mssel);
    // `PRINT_REG_SETTING(speed,spdth1);
    // `UPDATE_REG(speed, spdth1);

    //change set==>wr by wl
    `WR_REG(speed, spdth0, {th_pass,th_fail});
    `PRINT_REG_SETTING(speed,spdth0);
    `WR_REG(speed, spdth1, {th_mssel,th_init});
    `PRINT_REG_SETTING(speed,spdth1);

endtask

task set_spd_thms(input [31:0] th_to, input lv1thmsadd, input [14:0] lv1thms, input lv2thmsadd=0, input [14:0] lv2thms=0, input lv3thmsadd=0, input [14:0] lv3thms=0, input lv4thmsadd=0, input [14:0] lv4thms=0);
    `WR_REG(speed, spdth2, th_to);
    `PRINT_REG_SETTING(speed,spdth2);
    `WR_REG(speed, spdth3, {lv2thmsadd, lv2thms, lv1thmsadd, lv1thms});
    `PRINT_REG_SETTING(speed,spdth3);
    `WR_REG(speed, spdth4, {lv4thmsadd, lv4thms, lv3thmsadd, lv3thms});
    `PRINT_REG_SETTING(speed,spdth4);

endtask

task set_ss_delta(input [15:0] delta1=0, input [15:0] delta2=0, input [15:0] delta3=0,  input [15:0] delta4=0);
    `WR_REG(speed, spdth3, {delta2, delta1});
    `PRINT_REG_SETTING(speed,spdth3);
    `WR_REG(speed, spdth4, {delta4, delta3});
    `PRINT_REG_SETTING(speed,spdth4);
endtask


//
task set_spd_plltable(input int plltable[$]);
    if(plltable.size==4)begin
        $display("PLL4 MODE SETTING");
        `SET_REG_FIELD(speed, plltable, plltable_lv0, 0 );
        `SET_REG_FIELD(speed, plltable, plltable_lv1, plltable[0]);
        `SET_REG_FIELD(speed, plltable, plltable_lv2, plltable[1]);
        `SET_REG_FIELD(speed, plltable, plltable_lv3, plltable[2]);
        `SET_REG_FIELD(speed, plltable, plltable_lv4, plltable[3]);
    end
    else begin
        $display("PLL7 MODE SETTING");
        `SET_REG_FIELD(speed, plltable, plltable_lv0, 0 );
        `SET_REG_FIELD(speed, plltable, plltable_lv1, plltable[0]);
        `SET_REG_FIELD(speed, plltable, plltable_lv2, plltable[1]);
        `SET_REG_FIELD(speed, plltable, plltable_lv3, plltable[2]);
        `SET_REG_FIELD(speed, plltable, plltable_lv4, plltable[3]);
        `SET_REG_FIELD(speed, plltable, plltable_lv5, plltable[4]);
        `SET_REG_FIELD(speed, plltable, plltable_lv6, plltable[5]);
        `SET_REG_FIELD(speed, plltable, plltable_lv7, plltable[6]);
    end

    `PRINT_REG_SETTING(speed,plltable);
    `UPDATE_REG(speed, plltable);

    #2000ns;
endtask

task set_dh_wdt(input dh_wdt_on, input [15:0] dh_wdt_timer);
   `SET_REG_FIELD(speed, dh_cnt_wdt_ctrl, dh_cnt_wdt_on, dh_wdt_on);
   `ifndef PL_SIM
   `SET_REG_FIELD(speed, dh_cnt_wdt_ctrl, dh_cnt_wdt_timer, dh_wdt_timer);
   `else
   `SET_REG_FIELD(speed, dh_cnt_wdt_ctrl, dh_cnt_wdt_timer, 16'h1);
    `endif
   `PRINT_REG_SETTING(speed, dh_cnt_wdt_ctrl);
   `UPDATE_REG(speed, dh_cnt_wdt_ctrl);
endtask

task set_dh_worse_th(input [15:0] dh_worse_th);

// speed.reg_dh_worse_th.dh_worese_th.set(value)
// `define SET_REG_FIELD(module,reg,field,value) ral.``module``.reg_``reg``.``field``.set(value)

   `SET_REG_FIELD(speed, dh_worse_th, dh_worse_th, dh_worse_th);
   `PRINT_REG_SETTING(speed, dh_worse_th);
   `UPDATE_REG(speed, dh_worse_th);

endtask

task dh_wdt_acc_sync(input [15:0] dh_wdt_timer);
    bit [15:0] acc_rand_val = $urandom_range(0, 50) + 20;
    bit [35:0] acc_val = {dh_wdt_timer-1, 20'hfffff} - acc_rand_val;
    $display("dh_wdt timeout = %x, accelerate to %x", {dh_wdt_timer, 20'h00000}, acc_val);
    
    @(negedge spd_vif.clk);
    `ifndef PL_SIM
        uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_lo", acc_val[19:0]);
        uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_hi", acc_val[35:20]);
    `else
        //uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_lo", acc_val[19:0]);
        uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_lo_reg_3___dh_cnt_wdt_timer_lo_reg_2___dh_cnt_wdt_timer_lo_reg_1___dh_cnt_wdt_timer_lo_reg_0_.D3", acc_val[0]);
        uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_lo_reg_3___dh_cnt_wdt_timer_lo_reg_2___dh_cnt_wdt_timer_lo_reg_1___dh_cnt_wdt_timer_lo_reg_0_.D2", acc_val[1]);
        uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_lo_reg_3___dh_cnt_wdt_timer_lo_reg_2___dh_cnt_wdt_timer_lo_reg_1___dh_cnt_wdt_timer_lo_reg_0_.D1", acc_val[2]);
        uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_lo_reg_3___dh_cnt_wdt_timer_lo_reg_2___dh_cnt_wdt_timer_lo_reg_1___dh_cnt_wdt_timer_lo_reg_0_.D0", acc_val[3]);

        uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_lo_reg_7___dh_cnt_wdt_timer_lo_reg_6___dh_cnt_wdt_timer_lo_reg_5___dh_cnt_wdt_timer_lo_reg_4_.D3", acc_val[4]);
        uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_lo_reg_7___dh_cnt_wdt_timer_lo_reg_6___dh_cnt_wdt_timer_lo_reg_5___dh_cnt_wdt_timer_lo_reg_4_.D2", acc_val[5]);
        uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_lo_reg_7___dh_cnt_wdt_timer_lo_reg_6___dh_cnt_wdt_timer_lo_reg_5___dh_cnt_wdt_timer_lo_reg_4_.D1", acc_val[6]);
        uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_lo_reg_7___dh_cnt_wdt_timer_lo_reg_6___dh_cnt_wdt_timer_lo_reg_5___dh_cnt_wdt_timer_lo_reg_4_.D0", acc_val[7]);

        uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_lo_reg_11___dh_cnt_wdt_timer_lo_reg_10___dh_cnt_wdt_timer_lo_reg_9___dh_cnt_wdt_timer_lo_reg_8_.D3", acc_val[8]);
        uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_lo_reg_11___dh_cnt_wdt_timer_lo_reg_10___dh_cnt_wdt_timer_lo_reg_9___dh_cnt_wdt_timer_lo_reg_8_.D2", acc_val[9]);
        uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_lo_reg_11___dh_cnt_wdt_timer_lo_reg_10___dh_cnt_wdt_timer_lo_reg_9___dh_cnt_wdt_timer_lo_reg_8_.D1", acc_val[10]);
        uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_lo_reg_11___dh_cnt_wdt_timer_lo_reg_10___dh_cnt_wdt_timer_lo_reg_9___dh_cnt_wdt_timer_lo_reg_8_.D0", acc_val[11]);

        uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_lo_reg_15___dh_cnt_wdt_timer_lo_reg_14___dh_cnt_wdt_timer_lo_reg_13___dh_cnt_wdt_timer_lo_reg_12_.D3", acc_val[12]);
        uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_lo_reg_15___dh_cnt_wdt_timer_lo_reg_14___dh_cnt_wdt_timer_lo_reg_13___dh_cnt_wdt_timer_lo_reg_12_.D2", acc_val[13]);
        uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_lo_reg_15___dh_cnt_wdt_timer_lo_reg_14___dh_cnt_wdt_timer_lo_reg_13___dh_cnt_wdt_timer_lo_reg_12_.D1", acc_val[14]);
        uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_lo_reg_15___dh_cnt_wdt_timer_lo_reg_14___dh_cnt_wdt_timer_lo_reg_13___dh_cnt_wdt_timer_lo_reg_12_.D0", acc_val[15]);
        uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_lo_reg_19___dh_cnt_wdt_timer_lo_reg_18___dh_cnt_wdt_timer_lo_reg_17___dh_cnt_wdt_timer_lo_reg_16_.D3", acc_val[16]);
        uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_lo_reg_19___dh_cnt_wdt_timer_lo_reg_18___dh_cnt_wdt_timer_lo_reg_17___dh_cnt_wdt_timer_lo_reg_16_.D2", acc_val[17]);
        uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_lo_reg_19___dh_cnt_wdt_timer_lo_reg_18___dh_cnt_wdt_timer_lo_reg_17___dh_cnt_wdt_timer_lo_reg_16_.D1", acc_val[18]);
        uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_lo_reg_19___dh_cnt_wdt_timer_lo_reg_18___dh_cnt_wdt_timer_lo_reg_17___dh_cnt_wdt_timer_lo_reg_16_.D0", acc_val[19]);

        //uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_hi_reg_0__dh_cnt_wdt_timer_hi_reg_14_.D0", acc_val[20]);
        //uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_hi_reg_4__dh_cnt_wdt_timer_hi_reg_1__dh_cnt_wdt_timer_hi_reg_12_.D0", acc_val[21]);

        //uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_hi_reg_2__dh_cnt_wdt_timer_hi_reg_3__dh_cnt_wdt_timer_hi_reg_8__dh_cnt_wdt_timer_hi_reg_11_.D0", acc_val[22]);
        //uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.speed.dh_cnt_wdt_timer_hi_reg_2__dh_cnt_wdt_timer_hi_reg_3__dh_cnt_wdt_timer_hi_reg_8__dh_cnt_wdt_timer_hi_reg_11_.D1", acc_val[23]);
        
    `endif
    $display($realtime, "==> Begin Wait dh_wdt_timeout");
    fork: dh_wdt_fork
        begin
            wait(spd_vif.dh_wdt_timeout == 1'b1); 
        end
        begin
            `ifdef PL_SIM
             repeat(30000) @(posedge spd_vif.clk);
            `else
             repeat(acc_rand_val*2) @(posedge spd_vif.clk);
            `endif
            `uvm_fatal("WDT_TIMEOUT","wdt_timeout,please check"); 
        end
    join_any
    disable dh_wdt_fork;
    $display($realtime, "==> GET dh_wdt_timeout");
endtask


task set_spd_fifo(output [`SPD_LEN-1:0] r_spd, input zero = 1'b0);
    logic [`SPD_LEN-1:0] spd;
    int unsigned CORE_NUM=`DESIGN_CORE_NUM+`TINY_CORE_NUM;
    `ifdef FPGA_LFB_DX
        for(int i = 0; i < `SPD_CORE_NUM; i++)begin
            if(i == 10)begin
                spd[i*4 +: 4] = 2;
            end
            else if(i == 81)begin
                spd[i*4 +: 4] = 3;
            end
            else if(i == 134)begin
                spd[i*4 +: 4] = 4;
            end 
            else begin
                spd[i*4 +: 4] = 0;
            end
        end
    `elsif FPGA_GBP_NONSORT
        for(int i = 0; i < `SPD_CORE_NUM; i++)begin
            if(i == 134)begin
                spd[i*4 +: 4] = 4;
            end 
            else begin
                spd[i*4 +: 4] = 0;
            end
        end
    `else
        if(zero == 1'b0)begin
            for(int i=0;i<`SPD_CORE_NUM;i++)begin
                spd[i*4 +: 4] = (i >= CORE_NUM) ? 4'h0 : (($random % `TB_PLL_NUM) + 1);
            end
        end
        else begin
            for(int i=0;i<`SPD_CORE_NUM;i++)begin
                spd[i*4 +: 4] = (i >= CORE_NUM) ? 4'h0 : (($random % (`TB_PLL_NUM+1)));
            end
        end
    `endif

    `uvm_info("initSpd",$psprintf(" set spd tp 0x%0x",spd),UVM_MEDIUM);
    `WR_REG(speed,spd,spd);
    `PRINT_REG_SETTING(speed,spd);

    `SET_REG_FIELD(work, spdsyc_cfg, cfg_spdgo, `ON);
    `PRINT_REG_SETTING(work,spdsyc_cfg);
    `UPDATE_REG(work, spdsyc_cfg);
    
    fork
        begin //1.1
            `UPDATE_REG(work, spdsyc_cfg);
        end

        begin //1.2
        fork:wait_freshdone_spdfifo
            begin //1.2.1
                $display($time,"wait spd_fresh done");
                wait(spd_vif.spd_fresh_done);
            end
            begin //1.2.2
                #20000000;
                `uvm_error(get_type_name(), "After 2000_0000ns, not get spd_fresh_done"); 
            end
        join_any
        disable wait_freshdone_spdfifo;
        end //end 1.2

    join

    r_spd = spd;
endtask

/**
 *  task name: set_spd_fifo_low_freq
 *  Description: 
 *    set_spd_fifo_low_freq is similiar to set_spd_fifo ,and include half clk spd
 *  
 */

task set_spd_fifo_low_freq(output [`SPD_LEN-1:0] r_spd, input zero = 1'b0);
    logic [`SPD_LEN-1:0] spd;
    if(zero == 1'b0)begin
        for(int i=0;i<`SPD_CORE_NUM;i++)begin
            spd[i*4 +: 4] = (i >= `DESIGN_CORE_NUM) ? 4'h0 : (($random % 7) + 1);
        end
    end
    else begin
        for(int i=0;i<`SPD_CORE_NUM;i++)begin
            spd[i*4 +: 4] = (i >= `DESIGN_CORE_NUM) ? 4'h0 : (($random % 8));
        end
    end

    `uvm_info("initSpd",$psprintf(" set spd fifo 0x%0x",spd),UVM_MEDIUM);
    `WR_REG(speed,spd,spd);
    `PRINT_REG_SETTING(speed,spd);

    `SET_REG_FIELD(work, spdsyc_cfg, cfg_spdgo, `ON);
    `PRINT_REG_SETTING(work,spdsyc_cfg);
    `UPDATE_REG(work, spdsyc_cfg);
    
    fork
        begin //1.1
            `UPDATE_REG(work, spdsyc_cfg);
        end

        begin //1.2
        fork:wait_freshdone_spdfifo
            begin //1.2.1
                $display($time,"wait spd_fresh done");
                wait(spd_vif.spd_fresh_done);
            end
            begin //1.2.2
                #20000000;
                `uvm_error(get_type_name(), "After 2000_0000ns, not get spd_fresh_done"); 
            end
        join_any
        disable wait_freshdone_spdfifo;
        end //end 1.2

    join

    r_spd = spd;
endtask

/**
 *  task name: check_spdcore_equal
 *  Description: 
 *    check coreSpd is equal, when coreid==`DESIGN_CORE_NUM or default, check all coreSpd, otherwise check specificed coreid
 *  Procedure:
 *    1. read all coreSpd 
 *    2. check all or check specificed coreid
 */
task check_spdcore_equal(input [`SPD_LEN-1:0] exp, input int coreid=`DESIGN_CORE_NUM, input bit mapped=0);
    logic [`SPD_LEN-1:0] actual_with_tiny; 
    logic [`SPD_LEN-1:0] exp_i; 
    logic [(`DESIGN_CORE_NUM+`TINY_CORE_NUM)*4:0] actual;
    int offset = 0;
    `RD_REG(speed, spd, actual_with_tiny);
    actual = actual_with_tiny[`DESIGN_CORE_NUM*4-1:0];
    exp_i = exp[`DESIGN_CORE_NUM*4-1:0];
    if(mapped == 0) begin
        if(coreid == `DESIGN_CORE_NUM) begin
            `uvm_info("check_spdcore_equal", $psprintf("exp=%x spd_in_core=%x", exp_i, actual), UVM_MEDIUM);
            if(actual != exp_i) begin
                `uvm_error("check_spdcore_equal", "spd mismatch!")
            end
            for(int i=0; i<`DESIGN_CORE_NUM; i++) begin
                `ifndef PL_SIM
                    if(work_ctrl_vif.spd_sel[i] != exp_i[i*4+:4]) begin
                        `uvm_error("check_spdcore_equal", $psprintf("coreid=%d, spd ch_spd_sel mismatch!", i))
                    end
                `else
                    if(spd_vif.spd_sel_in_core[i] != exp_i[i*4+:4]) begin
                        `uvm_error("check_spdcore_equal", $psprintf("coreid=%d, spd ch_spd_sel mismatch!", i))
                    end
                `endif
            end
        end 
        else begin
            offset = coreid;
            `uvm_info("check_spdcore_equal", $psprintf("coreid=%d exp=%x spd_in_core=%x", coreid, exp_i[0+:4], actual[offset*4+:4]), UVM_MEDIUM);
            if(actual[offset*4+:4] != exp_i[0+:4]) begin
                `uvm_error("check_spdcore_equal", "spd mismatch!")
            end

            `ifndef PL_SIM
                if(work_ctrl_vif.spd_sel[offset] != exp_i[0+:4]) begin
                    `uvm_error("check_spdcore_equal", "spd ch_spd_sel mismatch!")
                end
            `else
                if(spd_vif.spd_sel_in_core[offset] != exp_i[0+:4]) begin
                    `uvm_error("check_spdcore_equal", "spd ch_spd_sel mismatch!")
                end
            `endif
        end
    end
    else begin
        for(int i=0; i<`DESIGN_CORE_NUM; i++) begin
            exp_i[i*4+:4] = get_map_spd(exp_i[i*4+:4]);
        end
        if(coreid == `DESIGN_CORE_NUM) begin
            `uvm_info("check_spdcore_equal", $psprintf("exp=%x spd_in_core=%x", exp_i, actual), UVM_MEDIUM);
            if(actual != exp_i) begin
                `uvm_error("check_spdcore_equal", "spd mismatch!")
            end
            for(int i=0; i<`DESIGN_CORE_NUM; i++) begin
                `ifndef PL_SIM
                    if(work_ctrl_vif.spd_sel[i] != exp_i[i*4+:4]) begin
                        `uvm_error("check_spdcore_equal", $psprintf("coreid=%d, spd ch_spd_sel mismatch!", i))
                    end
                `else
                    if(spd_vif.spd_sel_in_core[i] != exp_i[i*4+:4]) begin
                        `uvm_error("check_spdcore_equal", $psprintf("coreid=%d, spd ch_spd_sel mismatch!", i))
                    end
                `endif
            end
        end 
        else begin
            offset = coreid;
            `uvm_info("check_spdcore_equal", $psprintf("coreid=%d exp=%x spd_in_core=%x", coreid, exp_i[0+:4], actual[offset*4+:4]), UVM_MEDIUM);
            if(actual[offset*4+:4] != exp_i[0+:4]) begin
                `uvm_error("check_spdcore_equal", "spd mismatch!")
            end

            `ifndef PL_SIM
                if(work_ctrl_vif.spd_sel[offset] != exp_i[0+:4]) begin
                    `uvm_error("check_spdcore_equal", "spd ch_spd_sel mismatch!")
                end
            `else
                if(spd_vif.spd_sel_in_core[offset] != exp_i[0+:4]) begin
                    `uvm_error("check_spdcore_equal", "spd ch_spd_sel mismatch!")
                end
            `endif
        
        end
    end
endtask



function automatic logic[3:0] get_map_spd(logic [3:0] spd);
    if(spd == 0)
        return spd_cfg_h.plltable_lv0;
    if(spd == 1)
        return spd_cfg_h.plltable_lv1;
    if(spd == 2)
        return spd_cfg_h.plltable_lv2;
    if(spd == 3)
        return spd_cfg_h.plltable_lv3;
    if(spd == 4)
        return spd_cfg_h.plltable_lv4;
    if(spd == 5)
        return spd_cfg_h.plltable_lv5;
    if(spd == 6)
        return spd_cfg_h.plltable_lv6;
    if(spd == 7)
        return spd_cfg_h.plltable_lv7;
    `uvm_error("SPD_REF_MDL", $psprintf("get_map_spd spd=%d invalid", spd));
endfunction

/**
 *  task name: check_spdlog_equal
 *  Description: 
 *    check spdlog is equal, when coreid==`DESIGN_CORE_NUM or default, check all spdlog, otherwise check specificed coreid
 *  Procedure:
 *    1. read all spdlog 
 *    2. check all or check specificed coreid
 */
task check_spdlog_equal(input [`DESIGN_CORE_NUM*32-1:0] exp, input int coreid=`DESIGN_CORE_NUM);
    logic [`DESIGN_CORE_NUM*32-1:0] actual;
    `RD_REG(speed, spdlog, actual);
    
    if(coreid == `DESIGN_CORE_NUM) begin
        `uvm_info("check_spdlog_equal", $psprintf("exp=%x  spdlog=%x", exp, actual), UVM_MEDIUM);
        if(actual != exp) begin
            `uvm_error("check_spdlog_equal", "spdlog mismatch!")
        end
    end
    else begin
        //????????????????????????????????????????????????????????
        `uvm_info("check_spdlog_equal", $psprintf("exp=%x  spdlog=%x", exp[0+:32], actual[coreid*32+:32]), UVM_MEDIUM);
        if(actual[coreid*32+:32] != exp[0+:32]) begin
            `uvm_error("check_spdlog_equal", "spdlog mismatch!")
        end
    end
endtask


/**
 *  task name: trigc_work_fake_spd
 *  Description: 
 *    force the z_check_done z_check_id z_check_mask_pass, force fake work result to speed
 *  Procedure:
 *    1. force z_check_done=0, z_check_id=coreid z_check_mask_pass=pass
 *    2. force z_check_done=1
 *    3. force z_check_done=0
 *    function store(logic pass, logic [7:0] coreid, int passcnt, int failcnt);
 */
 `ifdef BROADCAST_NONCE
task trigc_work_fake_spd(input pass, input [31:0] coreid, input [31:0] cnt);
    bit [31:0] local_passcnt=0;
    bit [31:0] local_failcnt=0;
    uvm_event tx_data_force_req,tx_data_force_done;
    fake_core_tx_data_trans tmp;
 
    if(pass == 1'b1)
        local_passcnt = cnt;
    else
        local_failcnt = cnt;

    tx_data_force_req = uvm_event_pool::get_global("tx_data_force_req");
    tx_data_force_done = uvm_event_pool::get_global("tx_data_force_done");
    

    `uvm_info(get_type_name(), "start to force", UVM_MEDIUM);
    
    tmp.store(.pass(pass), .coreid(coreid), .passcnt(local_passcnt), .failcnt(local_failcnt));
    tx_data_force_req.trigger(tmp);
    tx_data_force_req.wait_off();
    tx_data_force_done.wait_trigger();
    tx_data_force_done.reset();
    `SET_REG_FIELD(work, spdsyc_cfg, cfg_spdgo, `ON);
    `PRINT_REG_SETTING(work,spdsyc_cfg);
    
    fork
        begin //1.1
            `UPDATE_REG(work, spdsyc_cfg);
        end

        begin //1.2
        fork:wait_freshdone_trig
            begin //1.2.1
                $display($time,"wait spd_fresh done");
                wait(spd_vif.spd_fresh_done);
            end
            begin //1.2.2
            #20000000;
            `uvm_error(get_type_name(), "After 2000_0000ns, not get spd_fresh_done"); 
            end
        join_any
        disable wait_freshdone_trig;
        end //end 1.2
    join
 
endtask
`else
task trigc_work_fake_spd(input pass, input [31:0] coreid, input [31:0] cnt);
    int num=1;
    for(int i = 0; i < cnt; i = i + 1) begin
        `uvm_info("trigc_work_fake_spd", $psprintf("%dth: coreid=%d pass=%d", i, coreid, pass), UVM_MEDIUM);
        #200
        @(negedge spd_vif.mid_clk);
        uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_done",0);
        uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_id",coreid);
        uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_mask_pass",pass);
        @(negedge spd_vif.mid_clk); 
        uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_done",1);
        @(negedge spd_vif.mid_clk);
        uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_done",0);

        #200;
        `SET_REG_FIELD(work, spdsyc_cfg, cfg_spdgo, `ON);
        `PRINT_REG_SETTING(work,spdsyc_cfg);
    
        fork
            begin //1.1
                `UPDATE_REG(work, spdsyc_cfg);
            end

            begin //1.2
            fork:wait_freshdone_trig
                begin //1.2.1
                    $display($time,"wait spd_fresh done");
                    wait(spd_vif.spd_fresh_done);
                end
                begin //1.2.2
                #20000000;
                `uvm_error(get_type_name(), "After 2000_0000ns, not get spd_fresh_done"); 
                end
            join_any
            disable wait_freshdone_trig;
            end //end 1.2

        join

    
    end
endtask
`endif


`ifdef BROADCAST_NONCE
task trigc_work_fake_spd_ss(input [31:0] coreid, input [31:0] passcnt, input [31:0] failcnt, input spdgo=1'b0);
    bit [31:0] local_passcnt=0;
    bit [31:0] local_failcnt=0;
    uvm_event tx_data_force_req,tx_data_force_done;
    fake_core_tx_data_trans tmp;
    $display($time, "coreid=%d passcnt=%d failcnt=%d spdgo=%x", coreid, passcnt, failcnt, spdgo); 
    `ifdef AGING_ACCELERATE
        trigc_work_fake_spd_ss_gbp(.coreid(coreid), .passcnt(passcnt),.failcnt(failcnt), .spdgo(spdgo));
        return ;
    `endif
    tmp = new();
    tx_data_force_req = uvm_event_pool::get_global("tx_data_force_req");
    tx_data_force_done = uvm_event_pool::get_global("tx_data_force_done");
    

    `uvm_info(get_type_name(), "start to force", UVM_MEDIUM);
    if(passcnt+failcnt == 0)begin
        return;
    end
    fork:wait_trig_done
        begin//1.1
        tmp.store(.coreid(coreid), .passcnt(passcnt), .failcnt(failcnt));
        tx_data_force_req.trigger(tmp);
        tx_data_force_req.wait_off();
        tx_data_force_done.wait_trigger();
        tx_data_force_done.reset();
        end//1.1
        begin//1.2
        fork:wait_cnt_check_done
            begin
                repeat(passcnt+failcnt)begin
                    @(posedge spd_vif.check_done);
                    $display("Get one z_check_done");
                end
            end
            begin
                #20000000ns;
                `uvm_error(get_type_name(), "Wait enough z_check_done Timeout");
            end
        join_any
        disable wait_cnt_check_done;
        end//1.2
    join
    disable wait_trig_done;

    // fork: wait_check_fifo_empty
    //     begin
    //         `uvm_info(get_type_name(), "start wait pp_empty", UVM_MEDIUM);
    //         wait(work_ctrl_vif.pp_empty == 1'b1);
    //         `uvm_info(get_type_name(), "wait pp_empty done", UVM_MEDIUM);
    //     end
    //     begin
    //         #20000000ns;
    //         `uvm_error(get_type_name(), "Wait pp_empty Timeout");
    //     end
    // join_any
    

    if(spdgo==1'b1)begin
    fork
        begin //1.1
            repeat(20) @(posedge spd_vif.clk);
            `SET_REG_FIELD(work, spdsyc_cfg, cfg_spdgo, `ON);
            `PRINT_REG_SETTING(work,spdsyc_cfg);
            `UPDATE_REG(work, spdsyc_cfg);
        end

        begin //1.2
        fork:wait_freshdone_trig_ss
            begin //1.2.1
                $display($time,"wait spd_fresh done");
                wait(spd_vif.spd_fresh_done);
                $display($time, "Get spd_fresh_done !");
            end
            begin //1.2.2
            #20000000;
            `uvm_error(get_type_name(), "After 2000_0000ns, not get spd_fresh_done"); 
            end
        join_any
        disable wait_freshdone_trig_ss;
        end //end 1.2
    join
    end
endtask
`else

localparam HIGH_MODE = 2'b11;
localparam NORM_MODE = 2'b10;
localparam LOW_MODE = 2'b01;
localparam RAND_MODE = 2'b00;
task trigc_work_fake_spd_ss_mod(input bit [7:0] coreid, input bit [1:0] mod);
    assert(spd_cfg_h.randomize(ss_rand_gap)) else $finish;
    
    if(mod == HIGH_MODE)begin
        assert(spd_cfg_h.randomize(ss_rand_mod) with { ss_rand_mod dist {HIGH_MODE:=8, NORM_MODE:=1, LOW_MODE:=1};}) else $finish;
    end
    if(mod == NORM_MODE)begin
        assert(spd_cfg_h.randomize(ss_rand_mod) with { ss_rand_mod dist {HIGH_MODE:=1, NORM_MODE:=8, LOW_MODE:=1};}) else $finish;
    end
    if(mod == LOW_MODE)begin
        assert(spd_cfg_h.randomize(ss_rand_mod) with { ss_rand_mod dist {HIGH_MODE:=3, NORM_MODE:=1, LOW_MODE:=6};}) else $finish;
    end
    if(mod == RAND_MODE)begin

        `ifdef  SS_FULL_RAND_PERCENT
            
            assert(spd_cfg_h.randomize(ss_rand_mod) with { ss_rand_mod dist {HIGH_MODE:=spd_cfg_h.pass_percent,NORM_MODE:=spd_cfg_h.norm_percent,LOW_MODE:= spd_cfg_h.fail_percent};}) else $finish;
        
        `else
            if(spd_cfg_h.ss_rand_mod_sel == 1)begin
                assert(spd_cfg_h.randomize(ss_rand_mod) with { ss_rand_mod dist {HIGH_MODE:=1, NORM_MODE:=3, LOW_MODE:=1};}) else $finish;
            end
            else if(spd_cfg_h.ss_rand_mod_sel == 2)begin
                assert(spd_cfg_h.randomize(ss_rand_mod) with { ss_rand_mod dist {HIGH_MODE:=1, NORM_MODE:=1, LOW_MODE:=1};}) else $finish;
            end
            else if(spd_cfg_h.ss_rand_mod_sel == 3)begin
                assert(spd_cfg_h.randomize(ss_rand_mod) with { ss_rand_mod dist {HIGH_MODE:=1, NORM_MODE:=2, LOW_MODE:=1};}) else $finish;
            end
            else if(spd_cfg_h.ss_rand_mod_sel == 4)begin
                assert(spd_cfg_h.randomize(ss_rand_mod) with { ss_rand_mod dist {HIGH_MODE:=2, NORM_MODE:=3, LOW_MODE:=2};}) else $finish;
            end
            else if(spd_cfg_h.ss_rand_mod_sel == 5)begin
                assert(spd_cfg_h.randomize(ss_rand_mod) with { ss_rand_mod dist {HIGH_MODE:=1, NORM_MODE:=2, LOW_MODE:=3};}) else $finish;
            end
            else if(spd_cfg_h.ss_rand_mod_sel == 6)begin
                assert(spd_cfg_h.randomize(ss_rand_mod) with { ss_rand_mod dist {HIGH_MODE:=3, NORM_MODE:=2, LOW_MODE:=1};}) else $finish;
            end
            else if(spd_cfg_h.ss_rand_mod_sel == 7)begin
                assert(spd_cfg_h.randomize(ss_rand_mod) with { ss_rand_mod dist {HIGH_MODE:=3, NORM_MODE:=1, LOW_MODE:=1};}) else $finish;
            end
            else begin
                assert(spd_cfg_h.randomize(ss_rand_mod) with { ss_rand_mod dist {HIGH_MODE:=2, NORM_MODE:=3, LOW_MODE:=1};}) else $finish;
            end
        `endif


    end
    

    if(spd_cfg_h.ss_rand_mod == HIGH_MODE)begin
        trigc_work_fake_spd_ss(.coreid(coreid), .passcnt(spd_cfg_h.ss_pd-(spd_cfg_h.th_hp-spd_cfg_h.ss_rand_gap)), .failcnt(spd_cfg_h.th_hp - spd_cfg_h.ss_rand_gap));
    end
    if(spd_cfg_h.ss_rand_mod == NORM_MODE)begin
        trigc_work_fake_spd_ss(.coreid(coreid), .passcnt(spd_cfg_h.ss_pd-(spd_cfg_h.th_lp-spd_cfg_h.ss_rand_gap)), .failcnt(spd_cfg_h.th_lp - spd_cfg_h.ss_rand_gap));
    end
    if(spd_cfg_h.ss_rand_mod== LOW_MODE)begin
        trigc_work_fake_spd_ss(.coreid(coreid), .passcnt(spd_cfg_h.ss_pd-(spd_cfg_h.th_lp+spd_cfg_h.ss_rand_gap)), .failcnt(spd_cfg_h.th_lp+spd_cfg_h.ss_rand_gap));
    end

endtask

task deposit_spdlog(input [7:0] coreid, input [15:0] passcnt=0, input [15:0] failcnt=0);
    bit [31:0] spdlog;
    @(negedge spd_vif.clk);
   uvm_hdl_deposit($psprintf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_DH_CNT[%0d].speed_dh_cnt.cnt_timer[15:0]", coreid),  passcnt+failcnt);
   uvm_hdl_deposit($psprintf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_DH_CNT[%0d].speed_dh_cnt.cnt[15:0]", coreid),  failcnt);
   
   uvm_hdl_read($psprintf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.REG_SpdLog[31:0]",coreid), spdlog);
   spdlog[31:16] = spdlog[31:16] + failcnt;
   spdlog[15:0] = spdlog[15:0] + passcnt;
   uvm_hdl_deposit($psprintf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.REG_SpdLog[31:0]", coreid), spdlog);
endtask


task trigc_work_fake_spd_ss(input [31:0] coreid, input [31:0] passcnt, input [31:0] failcnt, input spdgo=1'b0);
    static int trig_times = 0;
    logic [31:0] allcnt = 0; // = passcnt + failcnt;
    int id1 = 0;
    int id2 = 0;
    bit result[$];
    bit tmp = 0;
    bit [15:0] passforce = 0;
    bit [15:0] failforce = 0;
    
    bit [31:0] coreid_pl = coreid;
    coreid_pl = coreid;
  
    if(passcnt > 10)begin
        passforce = passcnt -10;
        passcnt=10;
    end
    
    if(failcnt > 10)begin
        failforce = failcnt - 10;
        failcnt=10;
    end
    if(passforce != 0 || failforce != 0)begin
        deposit_spdlog(.coreid(coreid), .passcnt(passforce), .failcnt(failforce));
    end

    allcnt = passcnt + failcnt;
    for(int i=0; i<passcnt; i++)begin
        result[i] = 1'b1;
    end
    for(int i=0; i<failcnt; i++)begin
        result[passcnt+i] = 1'b0;
    end
    
    result.shuffle();
    
    $display("%dth Trig", trig_times);
    trig_times++;
    for(int i=0; i<allcnt; i++) begin
        $display("fake_ss %dth = %x ", i, result[i]);
    end

    for(int i = 0; i < allcnt; i = i + 1) begin
        `uvm_info("trigc_work_fake_spd", $psprintf("%dth: coreid=%d pass=%d", i, coreid, result[i]), UVM_MEDIUM);
        @(negedge spd_vif.mid_clk);
        uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_done",0);
        `ifndef PL_SIM
        uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_id",coreid);
        `else
        uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_id",coreid_pl);
        `endif
        uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_mask_pass",result[i]);
        @(negedge spd_vif.mid_clk); 
        uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_done",1);
        @(negedge spd_vif.mid_clk);
        uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_done",0);

        repeat(5) begin
            @(posedge spd_vif.clk);
        end
    end
    
    uvm_hdl_release("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_done");
    uvm_hdl_release("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_id");
    uvm_hdl_release("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_mask_pass");


    if(spdgo==1'b1)begin
        #2000;
        `SET_REG_FIELD(work, spdsyc_cfg, cfg_spdgo, `ON);
        `PRINT_REG_SETTING(work,spdsyc_cfg);
        `UPDATE_REG(work, spdsyc_cfg);
        #50;
        wait(spd_vif.spd_fresh_done);
        `uvm_info("trigc_work_fake_spd", "Spd_fresh_done=1", UVM_MEDIUM);
    end
endtask
`endif

task trigc_work_fake_spd_ss_gbp(input [31:0] coreid, input [31:0] passcnt, input [31:0] failcnt, input spdgo=1'b1);
    static int trig_times = 0;
    logic [31:0] allcnt = passcnt + failcnt;
    int id1 = 0;
    int id2 = 0;
    bit result[];
    bit tmp = 0;
    // `ifdef PL_SIM
    bit [31:0] coreid_pl = coreid;
    // coreid_pl[0] = ~coreid[0];
    // coreid_pl[3] = ~coreid[3];
    // coreid_pl[4] = ~coreid[4];
    // coreid_pl[5] = ~coreid[5];
    // `endif
    coreid_pl = coreid;
    result = new[allcnt];
    
    for(int i=0; i<passcnt; i++)begin
        result[i] = 1'b1;
    end
    for(int i=0; i<failcnt; i++)begin
        result[passcnt+i] = 1'b0;
    end

    for(int i=0; i<allcnt; i++) begin
        id1 = $random()%allcnt;
        id2 = $random()%allcnt;
        tmp = result[id1];
        result[id1] = result[id2];
        result[id2] = tmp;
    end
    $display("%dth Trig", trig_times);
    trig_times++;
    for(int i=0; i<allcnt; i++) begin
        $display("fake_ss %dth = %x ", i, result[i]);
    end

    for(int i = 0; i < allcnt; i = i + 1) begin
        `uvm_info("trigc_work_fake_spd", $psprintf("%dth: coreid=%d pass=%d", i, coreid, result[i]), UVM_MEDIUM);
        #10
        @(negedge spd_vif.mid_clk);
        uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_done",0);
        `ifndef PL_SIM
        uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_id",coreid);
        `else
        uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_id",coreid_pl);
        `endif
        uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_mask_pass",result[i]);
        @(negedge spd_vif.mid_clk); 
        uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_done",1);
        @(negedge spd_vif.mid_clk);
        uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_done",0);

        repeat(10) begin
            @(posedge spd_vif.clk);
        end
    end

    if(spdgo==1'b1)begin
    fork
        begin //1.1
            `UPDATE_REG(work, spdsyc_cfg);
        end

        begin //1.2
        fork:wait_freshdone_trig_gbp
            begin //1.2.1
                $display($time,"wait spd_fresh done");
                wait(spd_vif.spd_fresh_done);
            end
            begin //1.2.2
            #20000000;
            `uvm_error(get_type_name(), "After 2000_0000ns, not get spd_fresh_done"); 
            end
        join_any
        disable wait_freshdone_trig_gbp;
        end //end 1.2
    join

    end

    uvm_hdl_release("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_done");
    uvm_hdl_release("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_id");
    uvm_hdl_release("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_mask_pass");

endtask


//trigc_deposit
task trigc_deposit_work_fake_spd_ss(input [31:0] coreid, input [31:0] passcnt, input [31:0] failcnt, input spdgo=1'b1,input int trigc_num);
    //int trigc_num = 5;
    static int trig_times = 0;
    logic [31:0] allcnt;
    int id1 = 0;
    int id2 = 0;
    bit result[];
    bit tmp = 0;
    bit [31:0] coreid_pl;
    //$value$plusargs("GBP_TRIGC_NUM=%0d",trigc_num);
    `uvm_info("GBP_TRIGC_NUM",$sformatf("GBP_trigc_num=%0d",trigc_num),UVM_LOW);
    if(passcnt > trigc_num)begin
        //force
        @(negedge spd_vif.mid_clk) 
        uvm_hdl_deposit($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.REG_SpdLog[31:0]", coreid), (passcnt-trigc_num));
        
        //trigc
        //static int trig_times = 0;
        allcnt = trigc_num + failcnt;
        coreid_pl = coreid;
        result = new[allcnt];
        
        for(int i=0; i<trigc_num; i++)begin
            result[i] = 1'b1;
        end
        for(int i=0; i<failcnt; i++)begin
            result[trigc_num+i] = 1'b0;
        end

        for(int i=0; i<allcnt; i++) begin
            id1 = $random()%allcnt;
            id2 = $random()%allcnt;
            tmp = result[id1];
            result[id1] = result[id2];
            result[id2] = tmp;
        end
        $display("%dth Trig", trig_times);
        trig_times++;
        for(int i=0; i<allcnt; i++) begin
            $display("fake_ss %dth = %x ", i, result[i]);
        end

        for(int i = 0; i < allcnt; i = i + 1) begin
            `uvm_info("trigc_work_fake_spd", $psprintf("%dth: coreid=%d pass=%d", i, coreid, result[i]), UVM_MEDIUM);
            #20;
            @(negedge spd_vif.mid_clk);
            uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_done",0);
            `ifndef PL_SIM
            uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_id",coreid);
            `else
            uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_id",coreid_pl);
            `endif
           uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_mask_pass",result[i]);
            @(negedge spd_vif.mid_clk); 
            uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_done",1);
            @(negedge spd_vif.mid_clk);
            uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_done",0);

            repeat(10) begin
                @(posedge spd_vif.clk);
            end
        end

        if(spdgo==1'b1)begin
            #2000;
            `SET_REG_FIELD(work, spdsyc_cfg, cfg_spdgo, `ON);
            `PRINT_REG_SETTING(work,spdsyc_cfg);
            `UPDATE_REG(work, spdsyc_cfg);
            #50;
            wait(spd_vif.spd_fresh_done);
            `uvm_info("trigc_work_fake_spd", "Spd_fresh_done=1", UVM_MEDIUM);
        end

        end
        else begin
            //static int trig_times = 0;
            allcnt = passcnt + failcnt;
            coreid_pl = coreid;
            result = new[allcnt];
            
            for(int i=0; i<passcnt; i++)begin
                result[i] = 1'b1;
            end
            for(int i=0; i<failcnt; i++)begin
                result[passcnt+i] = 1'b0;
            end

            for(int i=0; i<allcnt; i++) begin
                id1 = $random()%allcnt;
                id2 = $random()%allcnt;
                tmp = result[id1];
                result[id1] = result[id2];
                result[id2] = tmp;
            end
            $display("%dth Trig", trig_times);
            trig_times++;
            for(int i=0; i<allcnt; i++) begin
                $display("fake_ss %dth = %x ", i, result[i]);
            end

            for(int i = 0; i < allcnt; i = i + 1) begin
                `uvm_info("trigc_work_fake_spd", $psprintf("%dth: coreid=%d pass=%d", i, coreid, result[i]), UVM_MEDIUM);
                #20;
                @(negedge spd_vif.mid_clk);
                uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_done",0);
                `ifndef PL_SIM
                uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_id",coreid);
                `else
                uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_id",coreid_pl);
                `endif
                uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_mask_pass",result[i]);
                @(negedge spd_vif.mid_clk); 
                uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_done",1);
                @(negedge spd_vif.mid_clk);
                uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_done",0);

                repeat(10) begin
                    @(posedge spd_vif.clk);
                end
            end

            if(spdgo==1'b1)begin
                #2500;
                `SET_REG_FIELD(work, spdsyc_cfg, cfg_spdgo, `ON);
                `PRINT_REG_SETTING(work,spdsyc_cfg);
                `UPDATE_REG(work, spdsyc_cfg);
                #250;
                wait(spd_vif.spd_fresh_done);
                `uvm_info("trigc_work_fake_spd", "Spd_fresh_done=1", UVM_MEDIUM);
            end
        end
endtask:trigc_deposit_work_fake_spd_ss

task check_spd_low_freq_equal(input [`SPD_LEN-1:0] spds, input int plltable[7], input real plls[7], input int coreid=`DESIGN_CORE_NUM, input bit mapped=0);
    real prods[8];
    real prod_in_core[`DESIGN_CORE_NUM];
    real prod_spd;
    int  pllTable[8];
    int offset = 0;

    pllTable[0] = 0;
    pllTable[1] = plltable[0];
    pllTable[2] = plltable[1];
    pllTable[3] = plltable[2];
    pllTable[4] = plltable[3];
    pllTable[5] = plltable[4];
    pllTable[6] = plltable[5];
    pllTable[7] = plltable[6];

    //deal with STUB_PLL prod
    prods[0] = 1000.0/`XCLK_FREQ;
    for(int i=0; i<7; i++)begin
        prods[i+1] = 1000.0/plls[i];
    end

    `uvm_info("check_spd_low_freq_equal", $psprintf("pllTable=[%d,%d,%d,%d,%d,%d,%d]", plltable[0],plltable[1],plltable[2],plltable[3],plltable[4],plltable[5],plltable[6]), UVM_MEDIUM);
    `uvm_info("check_spd_low_freq_equal", $psprintf("Prods=[%f,%f,%f,%f,%f,%f,%f]", prods[1], prods[2], prods[3], prods[4], prods[5], prods[6], prods[7]), UVM_MEDIUM);

    //check all spd or specificed coreid spd equal
    check_spdcore_equal(spds, coreid, mapped);

    cal_all_core_clk_prod(prod_in_core);

    if(coreid == `DESIGN_CORE_NUM) begin
        for(int i=0; i<`DESIGN_CORE_NUM; i++) begin
            offset = i;
            if(pllTable[spds[offset*4+:4]] != 4'h0) begin
                prod_spd = prods[pllTable[spds[offset*4+:4]]];
                `uvm_info("check_spd_low_freq_equal", $psprintf("coreid=%d spd=%d spd_map=%d prod_in_core=%f prod_spd=%f", i, spds[offset*4+:4], pllTable[spds[offset*4+:4]], prod_in_core[i], prod_spd), UVM_MEDIUM);
                if(chkc_real_equal(prod_in_core[i], prod_spd) !== 1) begin
                    `uvm_error("check_spd_low_freq_equal", "prod_in_core !== prod_spd");
                end
            end
            else begin
                fork: chk_clk_fork
                begin
                    wait(mx2_vif.mx2_hash_clk[offset] == 1'b1);
                    $display($time);
                    wait(mx2_vif.mx2_hash_clk[offset] == 1'b0);
                    $display($time);
                    `uvm_error("check_spd_low_freq_equal", "gated core has clk");
                end
                begin
                    #200ns;
                end
                join_any
                disable chk_clk_fork;
            end
        end
    end
    else begin
        offset = coreid;
        if(pllTable[spds[offset*4+:4]] != 4'h0) begin
            prod_spd = prods[pllTable[spds[offset*4+:4]]];
            `uvm_info("check_spd_low_freq_equal", $psprintf("coreid=%d spd=%d spd_map=%d prod_in_core=%f prod_spd=%f", coreid, spds[offset*4+:4],pllTable[spds[offset*4+:4]], prod_in_core[coreid], prod_spd), UVM_MEDIUM);
            if(chkc_real_equal(prod_in_core[coreid], prod_spd) !== 1) begin
                `uvm_error("check_spd_low_freq_equal", "prod_in_core !== prod_spd");
            end
        end
        else begin
                fork: chk_clk_fork;
                begin
                    wait(mx2_vif.mx2_hash_clk[offset] == 1'b1);
                    $display($realtime);
                    wait(mx2_vif.mx2_hash_clk[offset] == 1'b0);
                    $display($realtime);
                    `uvm_error("check_spd_low_freq_equal", "gated core has clk");
                end
                begin
                    #200ns;
                end
                join_any
                disable chk_clk_fork;
            end
    end
endtask
task check_spd_freq_equal(input [`SPD_LEN-1:0] spds, input int plltable[4], input real plls[4], input int coreid=`DESIGN_CORE_NUM, input bit mapped=0);
    real prods[5];
    real prod_in_core[`DESIGN_CORE_NUM];
    real prod_spd;
    int  pllTable[5];
    int offset = 0;

    pllTable[0] = 0;
    pllTable[1] = plltable[0];
    pllTable[2] = plltable[1];
    pllTable[3] = plltable[2];
    pllTable[4] = plltable[3];

    //deal with STUB_PLL prod
    prods[0] = 1000.0/`XCLK_FREQ;
    //`ifndef STUB_PLL
        for(int i=0; i<`TB_PLL_NUM; i++)begin
            prods[i+1] = 1000.0/plls[i];
        end
    /*`else
        `ifdef WORK_PLL_FPGA_120_120_150_170
            prods[1] = 1000.0/120.0;
            prods[2] = 1000.0/120.0;
            prods[3] = 1000.0/150.0;
            prods[4] = 1000.0/170.0;
        `else
            for(int i=0; i<`TB_PLL_NUM; i++)begin
                prods[i+1] = 1000.0/`STUB_FAKE_PLL_FREQ;
            end
        `endif
    `endif*/

    `uvm_info("check_spd_freq_equal", $psprintf("pllTable=[%d,%d,%d,%d], Prods=[%f,%f,%f,%f]", plltable[0],plltable[1],plltable[2],plltable[3], prods[1], prods[2], prods[3], prods[4]), UVM_MEDIUM);

    //check all spd or specificed coreid spd equal
    check_spdcore_equal(spds, coreid, mapped);

    cal_all_core_clk_prod(prod_in_core);

    if(coreid == `DESIGN_CORE_NUM) begin
        for(int i=0; i<`DESIGN_CORE_NUM; i++) begin
            offset = i;
            if(pllTable[spds[offset*4+:4]] != 4'h0) begin
                prod_spd = prods[pllTable[spds[offset*4+:4]]];
                `uvm_info("check_spd_freq_equal", $psprintf("coreid=%d spd=%d spd_map=%d prod_in_core=%f prod_spd=%f", i, spds[offset*4+:4], pllTable[spds[offset*4+:4]], prod_in_core[i], prod_spd), UVM_MEDIUM);
                if(chkc_real_equal(prod_in_core[i], prod_spd) !== 1) begin
                    `uvm_error("check_spd_freq_equal", "prod_in_core !== prod_spd");
                end
            end
            else begin
                fork: chk_clk_fork
                begin
                    wait(mx2_vif.mx2_hash_clk[offset] == 1'b1);
                    $display($time);
                    wait(mx2_vif.mx2_hash_clk[offset] == 1'b0);
                    $display($time);
                    `uvm_error("check_spd_freq_equal", "gated core has clk");
                end
                begin
                    #200ns;
                end
                join_any
                disable chk_clk_fork;
            end
        end
    end
    else begin
        offset = coreid;
        if(pllTable[spds[offset*4+:4]] != 4'h0) begin
            prod_spd = prods[pllTable[spds[offset*4+:4]]];
            `uvm_info("check_spd_freq_equal", $psprintf("coreid=%d spd=%d spd_map=%d prod_in_core=%f prod_spd=%f", coreid, spds[offset*4+:4],pllTable[spds[offset*4+:4]], prod_in_core[coreid], prod_spd), UVM_MEDIUM);
            if(chkc_real_equal(prod_in_core[coreid], prod_spd) !== 1) begin
                `uvm_error("check_spd_freq_equal", "prod_in_core !== prod_spd");
            end
        end
        else begin
                fork: chk_clk_fork;
                begin
                    wait(mx2_vif.mx2_hash_clk[offset] == 1'b1);
                    $display($realtime);
                    wait(mx2_vif.mx2_hash_clk[offset] == 1'b0);
                    $display($realtime);
                    `uvm_error("check_spd_freq_equal", "gated core has clk");
                end
                begin
                    #200ns;
                end
                join_any
                disable chk_clk_fork;
            end
    end
endtask


task set_spdgo();
    `SET_REG_FIELD(work, spdsyc_cfg, cfg_spdgo, `ON);
    `PRINT_REG_SETTING(work,spdsyc_cfg);
    `UPDATE_REG(work, spdsyc_cfg);
    wait(spd_vif.spd_fresh_done);
endtask

task check_padri_clk_equal(input real exp ,input int coreid=`DESIGN_CORE_NUM);

    real prod_in_core[`DESIGN_CORE_NUM];
    real exp_prod=0.0;
    cal_all_core_clk_prod(prod_in_core);

    if(chkc_real_equal(0, exp) == 1)begin
        
        `uvm_info("check_padri_clk_equal", $psprintf("expect clk is gated"), UVM_MEDIUM);
        if(coreid == `DESIGN_CORE_NUM) begin
            for(int i=0; i<`DESIGN_CORE_NUM; i++) begin               
                if(chkc_real_equal(prod_in_core[i], exp_prod) !== 1) begin
                    `uvm_error("check_padri_clk_equal", $psprintf(" coreid=%0d  expect clk is not gated",i));
                end
                else begin
                    `uvm_info("check_padri_clk_equal", $psprintf(" coreid=%0d  expect clk is gated",i), UVM_MEDIUM);
                end
            end
        end
        else begin
            
            if(chkc_real_equal(prod_in_core[coreid], exp_prod) !== 1) begin
                `uvm_error("check_padri_clk_equal", $psprintf(" coreid=%0d  expect clk is not gated",coreid));
            end
            else begin
                `uvm_info("check_padri_clk_equal", $psprintf(" coreid=%0d  expect clk is gated",coreid), UVM_MEDIUM);
            end
        end 

    end
    else begin

        exp_prod=1000.0/exp;
        `uvm_info("check_padri_clk_equal", $psprintf("exp_prod=%f", exp_prod), UVM_MEDIUM);

        if(coreid == `DESIGN_CORE_NUM) begin
            for(int i=0; i<`DESIGN_CORE_NUM; i++) begin
                `uvm_info("check_padri_clk_equal", $psprintf("%t coreid=%d exp_prod=%f , act_prod=%f", $time, i, exp_prod,prod_in_core[i]), UVM_MEDIUM);
                if(chkc_real_equal(prod_in_core[i], exp_prod) !== 1) begin
                    `uvm_error("check_padri_clk_equal", "prod_in_core !== expect padri_clk");
                end
            end
        end
        else begin
            `uvm_info("check_padri_clk_equal", $psprintf("exp_prod=%f , act_prod=%f", exp_prod,prod_in_core[coreid]), UVM_MEDIUM);
            if(chkc_real_equal(prod_in_core[coreid], exp_prod) !== 1) begin
                    `uvm_error("check_padri_clk_equal", "prod_in_core !== expect padri_clk");
            end
        end 

    end
    


 
endtask


task chk_state(input [7:0] coreid, input [3:0] exp_state);
    bit [3:0] actual_state;
    bit tmp;
    
    `ifndef PL_SIM
        uvm_hdl_read($psprintf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_adaptive.ss_cur_state[3:0]", coreid), actual_state);
        if(exp_state != actual_state)
            `uvm_error("ERROR", $psprintf("check spd state failed, exp=%s actual=%s", getStateStr(exp_state), getStateStr(actual_state)));
    `else
        
        uvm_hdl_read($psprintf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE_%0d__speed_core.smart_speed_adaptive.ss_cur_state[3:0]", coreid), actual_state);
        if(exp_state != actual_state)
            `uvm_error("ERROR", $psprintf("check spd state failed, exp=%s actual=%s", getStateStr(exp_state), getStateStr(actual_state)));

    `endif
endtask


function bit [3:0] iterSPD(input [3:0] spd, input bit[7:0] times, input bit spd_dir);
    bit dir = spd_dir;
    bit [3:0] iterspd = spd;
    for(int i=0; i<times; i++)begin
        if(dir == 0)begin
            dir = iterspd == 4'h1 ? 1'b1 : 1'b0;
            iterspd = iterspd == 4'h1 ? 4'h2 : iterspd-1'b1;
        end
        else begin
            dir = iterspd == 4'h4 ? 1'b0 : 1'b1;
            iterspd = iterspd == 4'h4 ? 4'h3 : iterspd + 1'b1;
        end
        $display("%dth iterSPD=%d dir=%b", i, iterSPD, dir);
   end
   return iterspd;
endfunction


task chk_sslog(input [7:0] coreid, input [1:0] timeout_trigger=2'b10, input [1:0] pass_trigger=2'b10, input [1:0] fail_trigger=2'b10, input [1:0] normal_trigger=2'b10, input [1:0] dh_worse=2'b10, input [2:0] diag_flag=3'b111, input [2:0] pll0_status=3'b100, input [2:0] pll1_status=3'b100, input [2:0] pll2_status=3'b100, input [2:0] pll3_status=3'b100);
    logic [32*((`DESIGN_CORE_NUM+1)/2)-1: 0] adaptive_log;
    logic [15:0] ss_log;
    `RD_REG(speed, sslog, adaptive_log);
    ss_log = adaptive_log[coreid*16+:16];
    
    if(pll0_status != 3'b100)begin
        if(pll0_status[1:0] != ss_log[1:0])begin
    if(pll0_status != 3'b100)begin
        if(pll0_status[1:0] != ss_log[1:0])begin
           `uvm_error("Check Failed", $psprintf("Checking Coreid=%d pll0_status, exp=%b actual=%b", coreid, pll0_status, ss_log[1:0])); 
        end
    end
    if(pll1_status != 3'b100)begin
        if(pll1_status[1:0] != ss_log[3:2])begin
           `uvm_error("Check Failed", $psprintf("Checking Coreid=%d pll1_status, exp=%b actual=%b", coreid, pll1_status, ss_log[3:2])); 
        end
    end
    if(pll2_status != 3'b100)begin
        if(pll2_status[1:0] != ss_log[5:4])begin
           `uvm_error("Check Failed", $psprintf("Checking Coreid=%d pll2_status, exp=%b actual=%b", coreid, pll2_status, ss_log[5:4])); 
        end
    end
    if(pll3_status != 3'b100)begin
        if(pll3_status[1:0] != ss_log[7:6])begin
           `uvm_error("Check Failed", $psprintf("Checking Coreid=%d pll3_status, exp=%b actual=%b", coreid, pll3_status, ss_log[7:6])); 
        end
    end
    if(diag_flag != 3'b111)begin
        if(diag_flag[2:0] != ss_log[10:8])begin
           `uvm_error("Check Failed", $psprintf("Checking Coreid=%d diag_flag, exp=%b actual=%b", coreid, diag_flag, ss_log[10:8])); 
        end
    end
    if(timeout_trigger != 2'b10)begin
       if(timeout_trigger[0] != ss_log[11])begin
           `uvm_error("Check Failed", $psprintf("Checking Coreid=%d timeout_trigger, exp=%b actual=%b", coreid, timeout_trigger[0], ss_log[11])); 
        end 
    end
    if(dh_worse != 2'b10)begin
       if(dh_worse[0] != ss_log[12])begin
           `uvm_error("Check Failed", $psprintf("Checking Coreid=%d dh_worse, exp=%b actual=%b", coreid, dh_worse[0], ss_log[12])); 
        end 
    end
    if(fail_trigger != 2'b10)begin
       if(fail_trigger[0] != ss_log[13])begin
           `uvm_error("Check Failed", $psprintf("Checking Coreid=%d fail_trigger, exp=%b actual=%b", coreid, fail_trigger[0], ss_log[13])); 
        end 
    end
    if(normal_trigger != 2'b10)begin
       if(normal_trigger[0] != ss_log[14])begin
           `uvm_error("Check Failed", $psprintf("Checking Coreid=%d normal_trigger, exp=%b actual=%b", coreid, normal_trigger[0], ss_log[14])); 
        end 
    end
    if(pass_trigger != 2'b10)begin
       if(pass_trigger[0] != ss_log[15])begin
           `uvm_error("Check Failed", $psprintf("Checking Coreid=%d pass_trigger, exp=%b actual=%b", coreid, pass_trigger[0], ss_log[15])); 
        end 
    end


endtask

task moni_state_trans(input [7:0] coreid, ref bit [4:0] trans[$]);
    foreach(trans[i])begin
        $display("%d ---%t--->Begin Wait ", i, $realtime, getStateStr(trans[i][3:0]));
        `ifndef PL_SIM
            wait(spd_vif.spd_state_cur[coreid] == trans[i][3:0]);
        `else
            if(coreid==0)begin
                //only core 0 has full connection
                wait(spd_vif.spd_state_cur[coreid] == trans[i][3:0]);
            end
            else begin
                wait(spd_vif.spd_state_cur[coreid][3:1] == trans[i][3:1]);
            end   
        `endif
        $display("%d <---%t---Get ", i, $realtime, getStateStr(trans[i][3:0]));
        trans[i] = trans[i] | 5'b10000;
    end
endtask

task chk_state_trans(input [7:0] coreid, input bit [4:0] trans[$]);
    foreach(trans[i])begin
        $display("<---%t---> coreid=%0d ,%dth Checking State %s", $realtime(), coreid,i, getStateStr(trans[i][3:0]));
        if((trans[i]&5'b10000) != 5'b10000)begin
            `uvm_error("State Check Failed", $psprintf("Coreid=%d %dth State=%s Not Gotten", coreid, i, getStateStr(trans[i][3:0])));
        end
    end
    `uvm_info(get_type_name, "chk_state_trans done!", UVM_MEDIUM);
endtask

`define MON_STATE_TRANS(coreid, trans) fork:moni_fork begin moni_state_trans(coreid, trans); end join_none
`define CHK_STATE_TRANS(coreid, trans)  repeat(20) @(posedge spd_vif.clk); chk_state_trans(coreid, trans); disable moni_fork;
`define MON_STATE_TRANS_EX(coreid, trans) fork:moni_fork_ex begin moni_state_trans(coreid, trans); end join_none
`define CHK_STATE_TRANS_EX(coreid, trans)  repeat(20) @(posedge spd_vif.clk); chk_state_trans(coreid, trans); disable moni_fork_ex;

`ifndef BROADCAST_NONCE
`ifdef REAL_CORE
function bit[7:0] GET_START();
    return spd_cfg_h.broad_nonce_coreid;
endfunction
`else
function bit[7:0] GET_START();
    `ifdef PARTS
        `ifdef ORDER
            bit [7:0] per = `DESIGN_CORE_NUM/`PARTS;
            bit [7:0] start = (`ORDER-1) * per;
            return start;
        `else
            return 0;
        `endif
    `else
        return 0;
    `endif
endfunction
`endif
`else
function bit[7:0] GET_START();
    return spd_cfg_h.broad_nonce_coreid;
endfunction
`endif


`ifndef BROADCAST_NONCE
`ifdef REAL_CORE
function bit[7:0] GET_END();
    return spd_cfg_h.broad_nonce_coreid + 2;
endfunction
`else
function bit[7:0] GET_END();
    `ifdef PARTS
        `ifdef ORDER
            bit [7:0] per = `DESIGN_CORE_NUM/`PARTS;
            bit [7:0] endn = `ORDER * per;
            if(`ORDER == `PARTS) return `DESIGN_CORE_NUM;
            return endn;
        `else
            return 0;
        `endif
    `else
        return `DESIGN_CORE_NUM;
    `endif
endfunction
`endif
`else
function bit[7:0] GET_END();
    return spd_cfg_h.broad_nonce_coreid + 2;
endfunction
`endif




task set_ss_fpga(input bit [6:0] rate_pll0=7'b0, input bit [6:0] rate_pll1=7'b0,input bit [6:0] rate_pll2=7'b0,input bit [6:0] rate_pll3=7'b0,input bit pll3_to=1'b0,input bit pll2_to=1'b0,input bit pll1_to=1'b0,input bit pll0_to=1'b0 );
    `ifdef SPD_INJECT_ERR
        `WR_REG(speed, ss_fpga, {pll3_to,pll2_to,pll1_to,pll0_to,rate_pll3, rate_pll2, rate_pll1, rate_pll0});
        $display("Set pll timeout: pll0_to=%d pll1_to=%d pll2_to=%d pll3_to=%d", pll0_to, pll1_to, pll2_to, pll3_to);
        $display("Set Error Rate: pll0=%d pll1=%d pll2=%d pll3=%d", rate_pll0, rate_pll1, rate_pll2, rate_pll3);
    `endif
endtask


task trigc_pass_for_inject_err(input [7:0] coreid, input [31:0] cnt);
    `ifdef SPD_INJECT_ERR
        for(int i = 0; i < cnt; i = i + 1) begin
            @(negedge spd_vif.mid_clk);
            uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_done",0);
            uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_id",coreid);
            uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_mask_pass", 1);
            @(negedge spd_vif.mid_clk); 
            uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_done",1);
            @(negedge spd_vif.mid_clk);
            uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.z_check_done",0);
        
        end
    `endif
endtask
          
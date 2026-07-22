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

localparam  NONE_TRIG = 3'b000;
localparam  PASS_TRIG = 3'b001;
localparam  FAIL_TRIG = 3'b010;
localparam  NORM_TRIG = 3'b011;
localparam  TOUT_TRIG = 3'b100;

localparam  DIR_UP = 1'b1;
localparam  DIR_DW = 1'b0;

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




class spd_new_refmdl extends spd_base_refmdl;
    `uvm_component_utils(spd_new_refmdl);
    bit [15:0]      PassCnt[`DESIGN_CORE_NUM-1:0]; 
    bit [15:0]      FailCnt[`DESIGN_CORE_NUM-1:0]; 
    bit [16:0]      AllCnt[`DESIGN_CORE_NUM-1:0]; 
    


    function new(string name="spd_new_refmdl",uvm_component parent);
      super.new(name,parent);
      for(int unsigned i=0; i<`DESIGN_CORE_NUM; i++)begin
            this.spd_high_tmp[i] = 4;
            this.spd_low_tmp[i] = 1;
      end
    endfunction
    
    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        //$display("Begin Run Phase");
            for(int unsigned i=0; i<`DESIGN_CORE_NUM; i++)begin
                fork
                begin
                    automatic bit [7:0] coreid = i;
                   // $display("Begin Moni coreid=%d", coreid);
                    forever begin
                        wait(this.vif.rst);
                        @(posedge vif.pass_trigger[coreid])begin
                            if(this.vif.ss_sel==2'b10) begin
                                $display("-------------------->[SPD ADA REFMDL], GET PASS_TRIG");
                                this.do_Trig(coreid, PASS_TRIG);
                            end
                        end
                    end
                end
                begin
                    automatic bit [7:0] coreid = i;
                    forever begin
                        wait(this.vif.rst);
                        @(posedge vif.fail_trigger[coreid])begin
                            if(this.vif.ss_sel==2'b10) begin
                                $display("-------------------->[SPD ADA REFMDL], GET FAIL_TRIG");
                                this.do_Trig(coreid, FAIL_TRIG);
                            end 
                        end
                    end
                end
                begin
                    automatic bit [7:0] coreid = i;
                    forever begin
                        wait(this.vif.rst);
                        @(posedge vif.normal_trigger[coreid])begin         
                            if(this.vif.ss_sel==2'b10) begin
                                $display("-------------------->[SPD ADA REFMDL], GET NORM_TRIG");
                                this.do_Trig(coreid, NORM_TRIG);
                            end 
                        end
                    end
                end
                begin
                    automatic bit [7:0] coreid = i;
                    forever begin
                        wait(this.vif.rst);
                        @(posedge vif.timeout_trigger[coreid])begin
                            if(this.vif.ss_sel==2'b10) begin
                                $display("-------------------->[SPD ADA REFMDL], GET TOUT_TRIG");
                                this.do_Trig(coreid, TOUT_TRIG);
                            end 
                        end
                    end
                end
                join_none
            #1ns;
            end

    endtask:run_phase

    task automatic incSPD(input bit [7:0] coreid);
        $display("-----> incSPD coreid=%d spd=%d", coreid, this.getSPD(coreid));
        if(this.spds[coreid*4+:4] < this.spdhigh)begin
            this.spds[coreid*4+:4] = this.spds[coreid*4+:4] + 1'b1;
            `uvm_info("SPD ADA REFMDL", $psprintf("Coreid=%d increase spd to %d", coreid, this.spds[coreid*4+:4]), UVM_MEDIUM);
        end
        this.chkSPD(coreid);
    endtask
    task automatic decSPD(input bit [7:0] coreid);
        $display("-----> decSPD coreid=%d spd=%d", coreid, this.getSPD(coreid));
        if(this.spds[coreid*4+:4] > this.spdlow)begin
            this.spds[coreid*4+:4] = this.spds[coreid*4+:4] - 1'b1;
            `uvm_info("SPD ADA REFMDL", $psprintf("Coreid=%d decrease spd to %d", coreid, this.spds[coreid*4+:4]), UVM_MEDIUM);
        end
        this.chkSPD(coreid);
    endtask

    task automatic chkSPD(input bit[7:0] coreid);
       fork
        begin
            automatic bit [7:0] coreid_exp = coreid;
            automatic bit [3:0] spd_exp = this.spds[coreid*4+:4]; 
            automatic bit [3:0] spd_rtl = 0;
            $display("*************ADA MODEL Check SPD Coreid=%d EXP_SPD=%d**************", coreid_exp, spd_exp);
            repeat(10) @(posedge vif.mid_clk);
            uvm_hdl_read($psprintf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.spd_sel_tmp[2:0]", coreid_exp), spd_rtl);
            if(spd_exp != spd_rtl)begin
                `uvm_error("[SPD ADA REFMDL]", $psprintf("Checking Coreid=%d exp_spd=%d rtl_spd=%d, Unequal", coreid_exp,spd_exp, spd_rtl));
            end
        end
        join_none 
    endtask

    task initMdl();
        super.initMdl();
        $display("########################### For New Model###########################");
        this.ss_sel = vif.ss_sel;
        this.ss_pri = vif.ss_pri;
        this.ss_pd = vif.ss_pd;
        this.sslogs = vif.REG_sslog;
        this.th_hp = vif.th_hp;
        this.th_lp = vif.th_lp;
        this.max_rechk = vif.max_rechk;
        this.REG_fail_trig_acc = vif.REG_fail_trig_acc;
        this.REG_normal_trig_acc = vif.REG_normal_trig_acc;
        this.REG_dh_cnt_wdt_on = vif.REG_dh_cnt_wdt_on;
        this.REG_dh_cnt_wdt_timer = REG_dh_cnt_wdt_timer;

        $display("ss_sel = %x", this.ss_sel);
        $display("ss_pri = %x", this.ss_pri);
        $display("ss_pd = %d", this.ss_pd);
        $display("th_hp = %x", this.th_hp);   
        $display("th_lp = %x", this.th_lp);
        $display("sslogs = %x", this.sslogs);
        $display("max_rechk = %x", this.max_rechk);
        $display("fail_trig_acc = %x", this.REG_fail_trig_acc);
        $display("normal_trig_acc = %x", this.REG_normal_trig_acc);
        $display("dh_cnt_wdt_on = %x", this.REG_dh_cnt_wdt_on);
        $display("dh_cnt_wdt_timer = %x", this.REG_dh_cnt_wdt_timer);
       
        for(integer i=0; i<`DESIGN_CORE_NUM; i++)begin
            uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_adaptive.ss_cur_state[3:0]",i), this.states[i]);
            uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_adaptive.pll0_status[1:0]",i), this.pll0_status[i]);
            uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_adaptive.pll1_status[1:0]",i), this.pll1_status[i]);
            uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_adaptive.pll2_status[1:0]",i), this.pll2_status[i]);
            uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_adaptive.pll3_status[1:0]",i), this.pll3_status[i]);
            uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_adaptive.diag_flag[1:0]",i), this.diag_flag[i]);
            uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_adaptive.rechk_cnt[3:0]",i), this.rechk_cnt[i]);
            $display("Coreid=%d Cur_State=%s", i, getStateStr(this.states[i]));
        end

    endtask
    
    task reset_states();
        for(int unsigned i=0; i<`DESIGN_CORE_NUM; i++)begin
            this.do_IDLE(i);
        end
    endtask
    task set_work_states();
        for(int unsigned i=0; i<`DESIGN_CORE_NUM; i++)begin
            this.do_WORK(i);
        end
    endtask
    task do_Common_Clr();
        do_Normaltrig_acc_clr();
        do_Failtrig_acc_clr();
    endtask


    task automatic do_Trig(input bit [7:0] coreid, input bit [2:0] TRIG_TYPE);
        automatic bit [3:0] cur_state = this.states[coreid];

        case(cur_state)
            SS_WORK:begin
                $display("------------->New Trig Enter SS_WORK<------------");
                
                if(this.getSPD(coreid) < this.spdhigh && this.diag_flag[coreid]==WORK_FLAG)begin
                    this.normaltrig_acc_cnt[coreid] = this.normaltrig_acc_cnt[coreid] + 1'b1; 
                end
                
                if(TRIG_TYPE == FAIL_TRIG || TRIG_TYPE == TOUT_TRIG)begin
                    if(TRIG_TYPE == FAIL_TRIG)
                        this.setPLLStatus(coreid, PLL_USED);
                    else
                        this.setPLLStatus(coreid, PLL_TIMEOUT);
                    
                    if (this.getSPD(coreid) > this.spd_low_tmp[coreid]) begin
                        this.spd_dir[coreid] = DIR_DW;
                        `uvm_info(get_full_name(),$psprintf("coreid=%0d,Performance Drop,changed spd_dir to DIR_DW",coreid),UVM_MEDIUM);                   
                    end

                    this.do_FAULT_SHOT_1(coreid);
                end
                else if(TRIG_TYPE == PASS_TRIG)begin
                    this.setPLLStatus(coreid, PLL_USED);
                    this.do_REWORD(coreid);
                end
                else if(this.getSPD(coreid) < this.spdhigh && this.diag_flag[coreid]==WORK_FLAG)begin
                    this.setPLLStatus(coreid, PLL_USED);
                    if(this.REG_normal_trig_acc != 0 && this.normaltrig_acc_cnt[coreid] == this.REG_normal_trig_acc)begin
                        do_TRY_UP(coreid);
                        this.normaltrig_acc_cnt[coreid]=0;
                    end
                end
                else
                    this.setPLLStatus(coreid, PLL_USED);

                
            end
            SS_MONITOR:begin
                $display("------------->New Trig Enter SS_MONITOR<------------");
                
                if(this.diag_flag[coreid] == SILENCE_FLAG && TRIG_TYPE==FAIL_TRIG)begin
                    this.failtrig_acc_cnt[coreid]++;
                end
                $display("IN SS_MONITOR failtrig_acc_cnt=%d, REG_fail_trig_acc=%d", this.failtrig_acc_cnt[coreid], this.REG_fail_trig_acc); 
                if( (TRIG_TYPE==TOUT_TRIG) || 
                   ((TRIG_TYPE==FAIL_TRIG||vif.dh_worse[coreid]==1'b1) && this.diag_flag[coreid]!=SILENCE_FLAG) ||
                    (TRIG_TYPE==FAIL_TRIG && this.failtrig_acc_cnt[coreid]==(this.REG_fail_trig_acc+1) && this.diag_flag[coreid]==SILENCE_FLAG)) 
                begin
                    if(TRIG_TYPE == FAIL_TRIG)
                        this.setPLLStatus(coreid, PLL_USED);
                    else
                        this.setPLLStatus(coreid, PLL_TIMEOUT);
                    do_FAULT_SHOT_2(coreid);
                    this.failtrig_acc_cnt[coreid]=0;
                end
                else if((TRIG_TYPE==PASS_TRIG || (TRIG_TYPE==NORM_TRIG&&this.diag_flag[coreid]==SILENCE_FLAG)) && vif.dh_worse[coreid] == 1'b0 )begin
                    this.setPLLStatus(coreid, PLL_USED);
                    do_RELEASE(coreid); 
                end
            end
            SS_TRY_MONI:begin
                $display("------------->New Trig Enter SS_TRY_MONI<------------");
                if(TRIG_TYPE == FAIL_TRIG || TRIG_TYPE == TOUT_TRIG)begin
                    if(TRIG_TYPE == FAIL_TRIG)
                        this.setPLLStatus(coreid, PLL_USED);
                    else
                        this.setPLLStatus(coreid, PLL_TIMEOUT);

                    this.do_TRY_FAIL(coreid); 
                end
                else if((TRIG_TYPE == PASS_TRIG || TRIG_TYPE == NORM_TRIG) && vif.dh_worse[coreid] == 1'b0)begin 
                    this.setState(coreid, SS_WORK);
                    this.diag_flag[coreid]=WORK_FLAG;
                    this.setPLLStatus(coreid, PLL_USED);
                end
                else begin
                        this.setPLLStatus(coreid, PLL_USED);
                end
            end
            default:begin
            
            end
        endcase

    endtask




    task automatic do_IDLE(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_IDLE----------------------------", $realtime, coreid);
        this.states[coreid] = SS_IDLE;
        this.pll0_status[coreid] = PLL_UNUSED;
        this.pll1_status[coreid] = PLL_UNUSED;
        this.pll2_status[coreid] = PLL_UNUSED;
        this.pll3_status[coreid] = PLL_UNUSED;
        this.diag_flag[coreid] = WORK_FLAG;
        this.rechk_cnt[coreid] = 4'b0;
        this.spd_high_tmp[coreid] = this.spdhigh;
        this.spd_low_tmp[coreid] = this.spdlow;
        this.spd_dir[coreid] =  DIR_DW;
        this.do_Acc_clr(coreid);
    endtask

    task automatic do_WORK(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_WORK----------------------------", $realtime, coreid);
        this.setState(coreid, SS_WORK);
        this.diag_flag[coreid] = WORK_FLAG;

    endtask
 
    task automatic do_REWORD(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_REWARD----------------------------", $realtime, coreid);
        this.spd_dir[coreid] = DIR_UP;
        this.incSPD(coreid); //independent increase 
        this.setState(coreid, SS_WORK);
        this.do_Acc_clr(coreid);

    endtask

    task automatic do_FAULT_SHOT_1(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_FAULT_SHOT_1----------------------------", $realtime, coreid);
        this.diag_flag[coreid] = DIAG_FLAG;
        this.do_DIAG(coreid);
        this.do_SPD_CHG(coreid);
        this.setState(coreid, SS_MONITOR);
        this.do_Acc_clr(coreid);
    endtask
    
    //chang spd dir
    function do_DIAG(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_DIAG----------------------------", $realtime, coreid);
        $display("coreid=%d spd=%d spd_low_tmp=%d spd_high_tmp=%d", coreid, getSPD(coreid), this.spd_low_tmp[coreid], this.spd_high_tmp[coreid]);
        if(this.diag_flag[coreid] == SILENCE_FLAG && this.ss_pri == 1'b0)begin
            $display("0->DIR_DW");
            this.spd_dir[coreid] = DIR_DW;
        end
        else if(this.getSPD(coreid) <= this.spd_low_tmp[coreid])begin
            $display("1->DIR_UP");
            this.spd_dir[coreid] = DIR_UP;
        end
        else if(this.getSPD(coreid) >= this.spd_high_tmp[coreid])begin
            $display("2->DIR_DW");
            this.spd_dir[coreid] = DIR_DW;
        end
        $display("----------------------------%20t %4d DIAG-END, spd_dir=%b----------------------------", $realtime, coreid, this.spd_dir[coreid]);
        this.do_Acc_clr(coreid);

    endfunction

    task automatic do_SPD_CHG(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_SPD_CHG----------------------------", $realtime, coreid);
        if(this.spd_dir[coreid] == DIR_UP)begin
            this.incSPD(coreid);
        end
        else begin
            this.decSPD(coreid);
        end
        this.setState(coreid, SS_MONITOR);
        this.do_Acc_clr(coreid);
    endtask


    task automatic do_RELEASE(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_RELEASE----------------------------", $realtime, coreid);
        this.setState(coreid, SS_WORK);
        this.diag_flag[coreid] = WORK_FLAG;
        //range_clr
        this.spd_high_tmp[coreid] = this.spdhigh;
        this.spd_low_tmp[coreid] = this.spdlow;
        //pll status clr
        this.pll0_status[coreid] = PLL_UNUSED;
        this.pll1_status[coreid] = PLL_UNUSED;
        this.pll2_status[coreid] = PLL_UNUSED;
        this.pll3_status[coreid] = PLL_UNUSED;
        this.do_Acc_clr(coreid);
        this.rechk_cnt[coreid] = 0;
        
    endtask

    task automatic do_FAULT_SHOT_2(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_FAULT_SHOT_2----------------------------", $realtime, coreid);
        $display("----------------------------%20t all_pll_used=%b dh_worse=%b diag_flag=%x rechk_cnt=%d max_rechk=%d----------------------------", $realtime, this.all_pll_used(coreid), vif.dh_worse[coreid], this.diag_flag[coreid], this.rechk_cnt[coreid], this.max_rechk);
        
        if(this.all_pll_used(coreid)==1'b0 && vif.dh_worse[coreid]==1'b1 && this.diag_flag[coreid] != SILENCE_FLAG)begin
            $display("Branch 0 do_RANGE_CHG");
            do_RANGE_CHG(coreid);
        end
        else if(this.all_pll_used(coreid)==1'b0 && (vif.dh_worse[coreid]==1'b0 || this.diag_flag[coreid]==SILENCE_FLAG))begin
            $display("Branch 1 do_DIAG");
            do_DIAG(coreid);
            do_SPD_CHG(coreid);
        end
        else if(this.all_pll_used(coreid)==1'b1 && this.rechk_cnt[coreid]!=this.max_rechk && this.diag_flag[coreid]!=SILENCE_FLAG)begin
            $display("Branch 2 do_RECHK");
            do_RECHK(coreid);
        end
        else if((this.all_pll_used(coreid)==1'b1 && this.rechk_cnt[coreid]==this.max_rechk) || this.diag_flag[coreid]==SILENCE_FLAG)begin
            $display("Branch 3 do_SLC");
            do_SLC(coreid);
        end
        else begin
            this.setState(coreid, SS_MONITOR);
        end
        this.do_Acc_clr(coreid);
    endtask
    
    task automatic do_RECHK(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_RECHK----------------------------", $realtime, coreid);
        this.spd_high_tmp[coreid]=this.spdhigh;
        this.spd_low_tmp[coreid]=this.spdlow;
        this.pll0_status[coreid]=PLL_UNUSED;
        this.pll1_status[coreid]=PLL_UNUSED;
        this.pll2_status[coreid]=PLL_UNUSED;
        this.pll3_status[coreid]=PLL_UNUSED;

        this.rechk_cnt[coreid]++;
        this.diag_flag[coreid]=RECHECK_FLAG;
        this.setState(coreid, SS_MONITOR);
        this.do_Acc_clr(coreid);
    endtask

    task automatic do_SLC(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_SLC----------------------------", $realtime, coreid);
        this.setState(coreid, SS_MONITOR);
        this.diag_flag[coreid]=SILENCE_FLAG;
        this.rechk_cnt[coreid]=0;
        this.spd_dir[coreid]=DIR_DW;
        this.pll0_status[coreid]=PLL_UNUSED;
        this.pll1_status[coreid]=PLL_UNUSED;
        this.pll2_status[coreid]=PLL_UNUSED;
        this.pll3_status[coreid]=PLL_UNUSED;
        this.spd_high_tmp[coreid]=this.spdhigh;
        this.spd_low_tmp[coreid]=this.spdlow;

    endtask

    task automatic do_TRY_UP(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_TRY_UP----------------------------", $realtime, coreid);
        this.diag_flag[coreid] = TRY_UP_FLAG;
        this.spd_dir[coreid] = DIR_UP;
        this.incSPD(coreid); //TRY_UP independent up
        this.setState(coreid, SS_TRY_MONI);
        this.do_Acc_clr(coreid);
    endtask

    task automatic do_TRY_FAIL(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_TRY_FAIL----------------------------", $realtime, coreid);
        this.diag_flag[coreid] = WORK_FLAG;
        this.setState(coreid, SS_WORK);
        this.spd_dir[coreid] = DIR_DW;
        this.decSPD(coreid);
        this.do_Acc_clr(coreid);
    endtask

    task automatic do_RANGE_CHG(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_RANGE_CHG----------------------------", $realtime, coreid);
        $display("In do_RANGE_CHG SPD=%d Coreid=%d spd_low_tmp=%d spd_high_tmp=%d pll_status=[%x %x %x %x]", coreid, getSPD(coreid), this.spd_low_tmp[coreid], this.spd_high_tmp[coreid], this.pll0_status[coreid], this.pll1_status[coreid], this.pll2_status[coreid], this.pll3_status[coreid]); 
        if(this.getSPD(coreid) < this.spd_high_tmp[coreid] && this.getSPD(coreid) > this.spd_low_tmp[coreid])begin
            if(this.spd_dir[coreid] == DIR_UP)begin
                this.spd_high_tmp[coreid] = this.getSPD(coreid);
            end
            else if(this.spd_dir[coreid] == DIR_DW)begin
                this.spd_low_tmp[coreid] = this.getSPD(coreid);
            end
        end
        if(this.all_pll_used(coreid) && this.rechk_cnt[coreid] < this.max_rechk && this.diag_flag[coreid]!=SILENCE_FLAG)begin//rechk_en
            do_RECHK(coreid);
            $display("After SPD_RANGE_CHG then RECHK, Coreid=%d spd_dir reverse to %b", coreid, ~this.spd_dir[coreid]);
            this.spd_dir[coreid] = ~this.spd_dir[coreid];
        end
        else begin
            do_DIAG(coreid);
            do_SPD_CHG(coreid);
        end
        this.do_Acc_clr(coreid);
    endtask

    function automatic bit all_pll_used(input bit [7:0] coreid);
        bit used_flag = 1'b1;
        $display("In All_pll_used Coreid=%d spd_low_tmp=%d spd_high_tmp=%d pll_status=[%x %x %x %x]", coreid,this.spd_low_tmp[coreid], this.spd_high_tmp[coreid], this.pll0_status[coreid], this.pll1_status[coreid], this.pll2_status[coreid], this.pll3_status[coreid]); 
        for(int unsigned i=this.spd_low_tmp[coreid]; i<=this.spd_high_tmp[coreid]; i++)begin
            if(i == 1)
                if(this.pll0_status[coreid] == PLL_UNUSED)
                    used_flag = 1'b0;
            if(i == 2)
                if(this.pll1_status[coreid] == PLL_UNUSED)
                    used_flag = 1'b0;
            if(i == 3)
                if(this.pll2_status[coreid] == PLL_UNUSED)
                    used_flag = 1'b0;
            if(i == 4)
                if(this.pll3_status[coreid] == PLL_UNUSED)
                    used_flag = 1'b0;
        end
        return used_flag;
    endfunction


    task automatic clr_cnt(int coreid);
    endtask

    function bit is_all_used(int coreid);
    
    endfunction


    task do_Failtrig_acc_add();
    endtask
    
    task do_Failtrig_acc_clr();
    endtask
    task do_Normaltrig_acc_add(input bit [7:0] coreid);
    endtask
    
    task do_Normaltrig_acc_clr();
    endtask

    function automatic do_Acc_clr(input bit [7:0] coreid);
        this.failtrig_acc_cnt[coreid]=0;
        this.normaltrig_acc_cnt[coreid]=0;
    endfunction

    function automatic setPLLStatus(input bit [7:0] coreid, input bit [1:0] PLL_STA);
        bit [3:0] spd = getSPD(coreid);
        if(spd == 4'h1)
            this.pll0_status[coreid] = PLL_STA;
        else if(spd == 4'h2)
            this.pll1_status[coreid] = PLL_STA;
        else if(spd == 4'h3)
            this.pll2_status[coreid] = PLL_STA;
        else if(spd == 4'h4)
            this.pll3_status[coreid] = PLL_STA;
        else
            `uvm_error("SPD ADA REFMDL", "SPD=0 SET PLL_STATUS");
    endfunction
    
    task automatic setState(input bit [7:0] coreid_i, input bit [3:0] state_i);
        this.states[coreid_i] = state_i;
        if(vif.check_enable == 1'b1)begin
            fork begin
                automatic bit [7:0] coreid = coreid_i;
                automatic bit [3:0] state = state_i;
                bit [3:0] cur_state;
                repeat(10) @(posedge vif.mid_clk);
                $display("####################Checking Coreid=%d Exp State=%s ###################", coreid, getStateStr(state)); 
                if(state == SS_WORK)begin
                    if(vif.spd_state_cur[coreid] != SS_WORK)
                        `uvm_error("SPD ADA REFMDL", $psprintf("%10t Coreid=%d State is Not %s, but %s", $realtime, coreid, getStateStr(SS_WORK), getStateStr(vif.spd_state_cur[coreid])));
                    end
                else if(state == SS_MONITOR)begin
                    if(vif.spd_state_cur[coreid] != SS_MONITOR)
                        `uvm_error("SPD ADA REFMDL", $psprintf("%10t Coreid=%d State is Not %s, but %s", $realtime, coreid, getStateStr(SS_MONITOR), getStateStr(vif.spd_state_cur[coreid])));
                    end
                else if(state == SS_TRY_MONI)begin
                    if(vif.spd_state_cur[coreid] != SS_TRY_MONI)
                        `uvm_error("SPD ADA REFMDL", $psprintf("%10t Coreid=%d State is Not %s, but %s", $realtime, coreid, getStateStr(SS_TRY_MONI), getStateStr(vif.spd_state_cur[coreid])));
                    end
                /*else if(state == SS_SLC)begin
                    if(vif.spd_state_cur[coreid] != SS_SLC)
                        `uvm_error("SPD ADA REFMDL", $psprintf("%10t Coreid=%d State is Not %s, but %s", $realtime, coreid, getStateStr(SS_SLC), getStateStr(vif.spd_state_cur[coreid])));
                    end*/
                end
            join_none
        end
    endtask
endclass


















/*=================================================================
///
/// FOR NEW LOW FREQ MODEL
==================================================================*/


class spd_low_freq_refmdl extends spd_base_refmdl;
    `uvm_component_utils(spd_low_freq_refmdl);

    bit [15:0]      PassCnt[`DESIGN_CORE_NUM-1:0]; 
    bit [15:0]      FailCnt[`DESIGN_CORE_NUM-1:0]; 
    bit [16:0]      AllCnt[`DESIGN_CORE_NUM-1:0]; 
    
    bit [1:0]      half_clk0_status[`DESIGN_CORE_NUM];
    bit [1:0]      half_clk1_status[`DESIGN_CORE_NUM];
    bit [1:0]      half_clk2_status[`DESIGN_CORE_NUM];

    bit [7:0]      passtrig_acc_cnt[`DESIGN_CORE_NUM]; 

    function new(string name="spd_low_freq_refmdl",uvm_component parent);
      super.new(name,parent);
      for(int unsigned i=0; i<`DESIGN_CORE_NUM; i++)begin
            this.spd_high_tmp[i] = 4;
            this.spd_low_tmp[i] = 1;
      end
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        //$display("Begin Run Phase");
            for(int unsigned i=0; i<`DESIGN_CORE_NUM; i++)begin
            fork

                `ifdef LOW_FREQ_FIFO_CHECK
                    begin
                        automatic bit [7:0] coreid = i;
                        forever begin                       
                            wait(this.vif.rst);
                            @(posedge vif.vld_reg_spd_sel[coreid])begin
                                if(this.vif.ss_sel==2'b11) begin
                                    ClrPLLStatus(coreid);
                                    if(vif.reg_spd_sel[coreid]>4)begin
                                        @(posedge vif.mid_clk);
                                        $display("-------------------->[SPD ADA LOW REFMDL], GET VLD FIFO IN LOW FREQ");
                                        this.do_IDLE(coreid);
                                        this.spd_low_tmp[coreid]=5;
                                        this.spd_high_tmp[coreid]=7;
                                    end
                                    else if(vif.reg_spd_sel[coreid]==0)begin
                                        @(posedge vif.mid_clk);
                                        $display("-------------------->[SPD ADA LOW REFMDL], GET VLD FIFO IN GATE");
                                        this.do_IDLE(coreid);
                                        this.spd_low_tmp[coreid]=5;
                                        this.spd_high_tmp[coreid]=4;
                                    end
                                    else begin
                                        @(posedge vif.mid_clk);
                                        $display("-------------------->[SPD ADA LOW REFMDL], GET VLD FIFO IN NORM");
                                        this.do_WORK(coreid);
                                        this.spd_low_tmp[coreid]=1;
                                        this.spd_high_tmp[coreid]=4;
                                    end
                                end
                            end
                        end
                    end

                `endif

                begin
                    automatic bit [7:0] coreid = i;
                   // $display("Begin Moni coreid=%d", coreid);
                    forever begin
                        wait(this.vif.rst);
                        @(posedge vif.pass_trigger[coreid])begin
                            if(this.vif.ss_sel==2'b11) begin
                                $display("-------------------->[SPD ADA LOW REFMDL], GET PASS_TRIG");
                                this.do_Trig(coreid, PASS_TRIG);
                            end    
                        end
                    end
                end
                begin
                    automatic bit [7:0] coreid = i;
                    forever begin                       
                        wait(this.vif.rst);
                        @(negedge vif.fail_trigger[coreid])begin
                            if(this.vif.ss_sel==2'b11) begin
                                $display("-------------------->[SPD ADA LOW REFMDL], GET FAIL_TRIG");
                                this.do_Trig(coreid, FAIL_TRIG);
                            end   
                        end
                    end
                end
                begin
                    automatic bit [7:0] coreid = i;
                    forever begin
                        wait(this.vif.rst);
                        @(posedge vif.normal_trigger[coreid])begin
                            if(this.vif.ss_sel==2'b11) begin
                                $display("-------------------->[SPD ADA LOW REFMDL], GET NORM_TRIG");
                                this.do_Trig(coreid, NORM_TRIG);
                            end                             
                        end
                    end
                end
                begin
                    automatic bit [7:0] coreid = i;
                    forever begin
                        wait(this.vif.rst);
                        @(posedge vif.timeout_trigger[coreid])begin
                            if(this.vif.ss_sel==2'b11) begin
                                $display("-------------------->[SPD ADA LOW REFMDL], GET TOUT_TRIG");
                                this.do_Trig(coreid, TOUT_TRIG);
                            end     
                        end
                    end
                end
            join_none
            #1ns;
            end
             
    endtask:run_phase

    function logic[2:0] get_spd_tmp_mapped(logic[2:0] spd_tmp);
        logic[2:0] mapped_spd=0;
        if(spd_tmp>4)
            mapped_spd=spd_tmp-4;
        else if(spd_tmp>0)
            mapped_spd=spd_tmp+3;
        else 
            mapped_spd=0;

        return mapped_spd;
    endfunction

    task automatic incSPD(input bit [7:0] coreid);
        $display("----->sub_incSPD coreid=%d spd=%d", coreid, this.getSPD(coreid));
        if(get_spd_tmp_mapped(this.spds[coreid*4+:4]) < get_spd_tmp_mapped(this.spdhigh))begin
            if(this.spds[coreid*4+:4]==3'd0)
                this.spds[coreid*4+:4] = 3'b0;
            else if(this.spds[coreid*4+:4]!=3'd7)
                this.spds[coreid*4+:4] = this.spds[coreid*4+:4] + 1'b1;
            else
                this.spds[coreid*4+:4] =3'd1;
            `uvm_info("SPD ADA LOW REFMDL", $psprintf("Coreid=%d increase spd to %d", coreid, this.spds[coreid*4+:4]), UVM_MEDIUM);
        end
        this.chkSPD(coreid);
        this.setPLLStatus(coreid, PLL_USED);
    endtask
    
    task automatic decSPD(input bit [7:0] coreid);
        $display("----->sub_decSPD coreid=%d spd=%d", coreid, this.getSPD(coreid));
        if(get_spd_tmp_mapped(this.spds[coreid*4+:4] )> get_spd_tmp_mapped(this.spdlow))begin
            if(this.spds[coreid*4+:4]!=3'd1)
                this.spds[coreid*4+:4] = this.spds[coreid*4+:4] - 1'b1;
            else
                this.spds[coreid*4+:4] =3'd7;
            `uvm_info("SPD ADA LOW REFMDL", $psprintf("Coreid=%d decrease spd to %d", coreid, this.spds[coreid*4+:4]), UVM_MEDIUM);
        end
        this.chkSPD(coreid);
        this.setPLLStatus(coreid, PLL_USED);
    endtask

    task automatic chkSPD(input bit[7:0] coreid);
       fork
        begin
            automatic bit [7:0] coreid_exp = coreid;
            automatic bit [3:0] spd_exp = this.spds[coreid*4+:4]; 
            automatic bit [3:0] spd_rtl = 0;
            $display("*************LOW MODEL Check SPD Coreid=%d EXP_SPD=%d**************", coreid_exp, spd_exp);
            repeat(10) @(posedge vif.mid_clk);
            uvm_hdl_read($psprintf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.spd_sel_tmp[2:0]", coreid_exp), spd_rtl);
            if(spd_exp != spd_rtl)begin
                `uvm_error("[SPD ADA LOW REFMDL]", $psprintf("Checking Coreid=%d exp_spd=%d rtl_spd=%d, Unequal", coreid_exp,spd_exp, spd_rtl));
            end
        end
        join_none 
    endtask

    task initMdl();
        super.initMdl();
        $display("########################### For LOW FREQ Model###########################");
        this.ss_sel = vif.ss_sel;
        this.ss_pri = vif.ss_pri;
        this.ss_pd = vif.ss_pd;
        this.sslogs = vif.REG_sslog;
        this.th_hp = vif.th_hp;
        this.th_lp = vif.th_lp;
        this.th_dp = vif.th_dp;
        this.max_rechk = vif.max_rechk;
        this.REG_fail_trig_acc = vif.REG_fail_trig_acc;
        this.REG_normal_trig_acc = vif.REG_normal_trig_acc;
        this.REG_pass_trig_acc = vif.REG_pass_trig_acc;
        this.REG_dh_cnt_wdt_on = vif.REG_dh_cnt_wdt_on;
        this.REG_dh_cnt_wdt_timer = vif.REG_dh_cnt_wdt_timer;

        $display("ss_sel = %x", this.ss_sel);
        $display("ss_pri = %x", this.ss_pri);
        $display("ss_pd = %d", this.ss_pd);
        $display("th_hp = %x", this.th_hp);   
        $display("th_lp = %x", this.th_lp);
        $display("th_dp = %x", this.th_dp);
        $display("sslogs = %x", this.sslogs);
        $display("max_rechk = %x", this.max_rechk);
        $display("fail_trig_acc = %x", this.REG_fail_trig_acc);
        $display("normal_trig_acc = %x", this.REG_normal_trig_acc);
        $display("pass_trig_acc = %x", this.REG_pass_trig_acc);
        $display("dh_cnt_wdt_on = %x", this.REG_dh_cnt_wdt_on);
        $display("dh_cnt_wdt_timer = %x", this.REG_dh_cnt_wdt_timer);
       
        for(integer i=0; i<`DESIGN_CORE_NUM; i++)begin
            uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_adaptive.ss_cur_state[3:0]",i), this.states[i]);
            uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_adaptive.pll0_status[1:0]",i), this.pll0_status[i]);
            uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_adaptive.pll1_status[1:0]",i), this.pll1_status[i]);
            uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_adaptive.pll2_status[1:0]",i), this.pll2_status[i]);
            uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_adaptive.pll3_status[1:0]",i), this.pll3_status[i]);
            uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_adaptive.half_clk_0_status[1:0]",i), this.half_clk0_status[i]);
            uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_adaptive.half_clk_1_status[1:0]",i), this.half_clk1_status[i]);
            uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_adaptive.half_clk_2_status[1:0]",i), this.half_clk2_status[i]);
            uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_adaptive.diag_flag[1:0]",i), this.diag_flag[i]);
            uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_adaptive.rechk_cnt[3:0]",i), this.rechk_cnt[i]);
            $display("Coreid=%d Cur_State=%s", i, getStateStr(this.states[i]));
        end

    endtask
    
    task reset_states();
        for(int unsigned i=0; i<`DESIGN_CORE_NUM; i++)begin
            this.do_IDLE(i);
        end
    endtask
    task set_work_states();
        for(int unsigned i=0; i<`DESIGN_CORE_NUM; i++)begin
            this.do_WORK(i);
        end
    endtask

    task automatic do_Trig(input bit [7:0] coreid, input bit [2:0] TRIG_TYPE);
        automatic bit [3:0] cur_state = this.states[coreid];

        case(cur_state)
            SS_WORK:begin
                $display("------------->New Trig Enter SS_WORK<------------");
                
                if(get_spd_tmp_mapped(this.getSPD(coreid)) < get_spd_tmp_mapped(this.spdhigh) && this.diag_flag[coreid]==WORK_FLAG)begin
                    if(TRIG_TYPE == NORM_TRIG)begin
                        this.normaltrig_acc_cnt[coreid] = this.normaltrig_acc_cnt[coreid] + 1'b1; 
                        this.passtrig_acc_cnt[coreid] ='d0; 
                    end
                    else if(TRIG_TYPE == PASS_TRIG) begin
                        this.normaltrig_acc_cnt[coreid] = 'd0;
                        this.passtrig_acc_cnt[coreid] =this.passtrig_acc_cnt[coreid]+1'd1;  
                    end
                    else begin
                        this.normaltrig_acc_cnt[coreid] = 'd0;
                        this.passtrig_acc_cnt[coreid] = 'd0; 
                    end
                end
                
                if(TRIG_TYPE == TOUT_TRIG)begin

                    this.setPLLStatus(coreid, PLL_TIMEOUT);           
                    if (get_spd_tmp_mapped(this.getSPD(coreid)) > get_spd_tmp_mapped(this.spd_low_tmp[coreid])) begin
                        this.spd_dir[coreid] = DIR_DW;
                        `uvm_info(get_full_name(),$psprintf("coreid=%0d,Performance Drop,changed spd_dir to DIR_DW",coreid),UVM_MEDIUM);                   
                    end

                    this.do_FAULT_SHOT_1(coreid);
                end
                else if(TRIG_TYPE == FAIL_TRIG)begin          
                    this.setPLLStatus(coreid, PLL_USED);                    
                    if (get_spd_tmp_mapped(this.getSPD(coreid)) > get_spd_tmp_mapped(this.spd_low_tmp[coreid])) begin
                        this.spd_dir[coreid] = DIR_DW;
                        `uvm_info(get_full_name(),$psprintf("coreid=%0d,Performance Drop,changed spd_dir to DIR_DW",coreid),UVM_MEDIUM);                   
                    end

                    this.do_FAULT_SHOT_1(coreid);
                end
                else if(TRIG_TYPE == PASS_TRIG && this.getSPD(coreid)!=3'd7)begin
                    this.setPLLStatus(coreid, PLL_USED);
                    this.do_REWORD(coreid);
                end
                else if(get_spd_tmp_mapped(this.getSPD(coreid)) < get_spd_tmp_mapped(this.spdhigh) && this.diag_flag[coreid]==WORK_FLAG)begin
                    this.setPLLStatus(coreid, PLL_USED);
                    if(this.REG_normal_trig_acc != 0 && this.normaltrig_acc_cnt[coreid] == this.REG_normal_trig_acc && this.getSPD(coreid)!=3'd7)begin
                        do_TRY_UP(coreid);
                        this.normaltrig_acc_cnt[coreid]=0;
                    end
                    else if(this.REG_pass_trig_acc != 0 && this.passtrig_acc_cnt[coreid] == this.REG_pass_trig_acc && this.ss_sel==2'b11 && this.getSPD(coreid)==3'd7 && this.ss_pri==1'b1) begin
                        do_TRY_UP(coreid);
                        this.passtrig_acc_cnt[coreid]=0;
                        // this.spd_high_tmp[coreid] = this.spdhigh;
                        // this.spd_low_tmp[coreid] =1;
                    end
                end
                else
                    this.setPLLStatus(coreid, PLL_USED);

                
            end
            SS_MONITOR:begin
                $display("------------->New Trig Enter SS_MONITOR<------------");
                
                if(this.diag_flag[coreid] == SILENCE_FLAG && TRIG_TYPE==FAIL_TRIG)begin
                    this.failtrig_acc_cnt[coreid]++;
                end
                else begin
                    this.failtrig_acc_cnt[coreid]=0;
                end
                $display("IN SS_MONITOR failtrig_acc_cnt=%d, REG_fail_trig_acc=%d, REG_Pass_trig_acc=%d", this.failtrig_acc_cnt[coreid], this.REG_fail_trig_acc,this.REG_pass_trig_acc); 

                if((TRIG_TYPE==TOUT_TRIG) || 
                   ((TRIG_TYPE==FAIL_TRIG||vif.dh_worse[coreid]==1'b1) && this.diag_flag[coreid]!=SILENCE_FLAG) ||
                    (TRIG_TYPE==FAIL_TRIG && this.failtrig_acc_cnt[coreid]==(this.REG_fail_trig_acc+1) && this.diag_flag[coreid]==SILENCE_FLAG)||
                    ((TRIG_TYPE==FAIL_TRIG && this.dh_cnt_fail[coreid]>=this.th_dp))) 
                begin
                    if(TRIG_TYPE == FAIL_TRIG)
                        this.setPLLStatus(coreid, PLL_USED);
                    else
                        this.setPLLStatus(coreid, PLL_TIMEOUT);
                    do_FAULT_SHOT_2(coreid);
                    this.failtrig_acc_cnt[coreid]=0;
                end
                else if((TRIG_TYPE==PASS_TRIG || (TRIG_TYPE==NORM_TRIG&&this.diag_flag[coreid]==SILENCE_FLAG)) && vif.dh_worse[coreid] == 1'b0 )begin
                    this.setPLLStatus(coreid, PLL_USED);
                    do_RELEASE(coreid); 
                end
            end
            SS_TRY_MONI:begin
                $display("------------->New Trig Enter SS_TRY_MONI<------------");
                if(TRIG_TYPE == FAIL_TRIG || TRIG_TYPE == TOUT_TRIG)begin
                    if(TRIG_TYPE == FAIL_TRIG)
                        this.setPLLStatus(coreid, PLL_USED);
                    else
                        this.setPLLStatus(coreid, PLL_TIMEOUT);

                    this.do_TRY_FAIL(coreid); 
                    
                end
                else if((TRIG_TYPE == PASS_TRIG || TRIG_TYPE == NORM_TRIG) && vif.dh_worse[coreid] == 1'b0)begin 
                    this.setState(coreid, SS_WORK);
                    this.diag_flag[coreid]=WORK_FLAG;
                    this.setPLLStatus(coreid, PLL_USED);
                end
                else begin
                        this.setPLLStatus(coreid, PLL_USED);
                end
            end
            SS_IDLE:begin
                $display("------------->New Trig Enter SS_IDLE[LOW FREQ REGION]<------------");
                this.do_IDLE(coreid);
            end
            default:begin
                `uvm_error(get_full_name(),"DO TRIG BASE STATE ERROR!!!");
            end
        endcase

    endtask




    task automatic do_IDLE(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_IDLE----------------------------", $realtime, coreid);
        this.states[coreid] = SS_IDLE;

        this.ClrPLLStatus(coreid);
        this.diag_flag[coreid] = WORK_FLAG;
        this.rechk_cnt[coreid] = 4'b0;
        this.spd_high_tmp[coreid] = this.spdhigh;
        this.spd_low_tmp[coreid] = this.spdlow;
        this.spd_dir[coreid] =  DIR_DW;
        this.do_Acc_clr(coreid);
        this.do_PassAcc_clr(coreid);
    endtask

    task automatic do_WORK(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_WORK----------------------------", $realtime, coreid);
        this.setState(coreid, SS_WORK);
        this.diag_flag[coreid] = WORK_FLAG;

        this.rechk_cnt[coreid] = 0;
    endtask
 
    task automatic do_REWORD(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_REWARD----------------------------", $realtime, coreid);
        this.spd_dir[coreid] = DIR_UP;
        this.incSPD(coreid); //independent increase 
        this.setState(coreid, SS_WORK);
        this.do_Acc_clr(coreid);
        this.do_PassAcc_clr(coreid);

    endtask

    task automatic do_FAULT_SHOT_1(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_FAULT_SHOT_1----------------------------", $realtime, coreid);
        this.diag_flag[coreid] = DIAG_FLAG;
        if(this.ss_sel==2'b11 && this.getSPD(coreid)==3'd1 && this.dh_cnt_fail[coreid]>=this.th_dp)begin
            $display("low freq branch do_RANGE_CHG");
            this.do_RANGE_CHG(coreid);
        end else begin
            $display("branch do_diag");
            this.do_DIAG(coreid);
            this.do_SPD_CHG(coreid);
            //this.setState(coreid, SS_MONITOR);
        end
        this.do_Acc_clr(coreid);
        this.do_PassAcc_clr(coreid);
    endtask
    
    //chang spd dir
    function do_DIAG(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_DIAG----------------------------", $realtime, coreid);
        $display("coreid=%d spd=%d spd_low_tmp=%d spd_high_tmp=%d", coreid, getSPD(coreid), this.spd_low_tmp[coreid], this.spd_high_tmp[coreid]);
        
        if(this.dh_cnt_fail[coreid]>=this.th_dp && this.ss_sel==2'b11)begin
            $display("5->DIR_DW");
            this.spd_dir[coreid] = DIR_DW;
        end
        else if(this.diag_flag[coreid] == SILENCE_FLAG && this.ss_pri == 1'b0)begin
            $display("0->DIR_DW");
            this.spd_dir[coreid] = DIR_DW;
        end
        else if(this.getSPD(coreid)==1 && (this.ss_sel!=2'b11 || this.dh_cnt_fail[coreid]<this.th_dp))begin
            $display("3->DIR_UP");
            this.spd_dir[coreid] = DIR_UP;
        end
        else if(get_spd_tmp_mapped(this.getSPD(coreid)) <= get_spd_tmp_mapped(this.spd_low_tmp[coreid]))begin
            $display("1->DIR_UP");
            this.spd_dir[coreid] = DIR_UP;
        end
        else if(get_spd_tmp_mapped(this.getSPD(coreid)) >= get_spd_tmp_mapped(this.spd_high_tmp[coreid]))begin
            $display("2->DIR_DW");
            this.spd_dir[coreid] = DIR_DW;
        end
        $display("----------------------------%20t %4d DIAG-END, spd_dir=%b----------------------------", $realtime, coreid, this.spd_dir[coreid]);
        this.do_Acc_clr(coreid);
        this.do_PassAcc_clr(coreid);

    endfunction

    task automatic do_SPD_CHG(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_SPD_CHG----------------------------", $realtime, coreid);
        if(this.spd_dir[coreid] == DIR_UP)begin
            this.incSPD(coreid);
        end
        else begin
            this.decSPD(coreid);
        end
        this.setState(coreid, SS_MONITOR);
        this.do_Acc_clr(coreid);
        this.do_PassAcc_clr(coreid);
    endtask


    task automatic do_RELEASE(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_RELEASE----------------------------", $realtime, coreid);
        this.setState(coreid, SS_WORK);
        this.diag_flag[coreid] = WORK_FLAG;
        //range_clr
        if(getSPD(coreid)>4 && this.ss_pri==1'b0)begin
            this.spd_low_tmp[coreid] = this.spdlow;
            this.spd_high_tmp[coreid] = 'd7;
        end
        else if(getSPD(coreid)<5) begin    
            this.spd_high_tmp[coreid] = this.spdhigh;
            
            if(get_spd_tmp_mapped(this.spdlow)>get_spd_tmp_mapped(1))
                this.spd_low_tmp[coreid] = this.spdlow;
            else begin
                this.spd_low_tmp[coreid] = 'd1;
            end
        end
        else begin
            this.spd_low_tmp[coreid] = this.spdlow;
            this.spd_high_tmp[coreid] = this.spdhigh;
        end

        //pll status clr
     
        this.ClrPLLStatus(coreid);
        this.do_Acc_clr(coreid);
        this.do_PassAcc_clr(coreid);
        this.rechk_cnt[coreid] = 0;
        
    endtask

    task automatic do_FAULT_SHOT_2(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_FAULT_SHOT_2----------------------------", $realtime, coreid);
        $display("----------------------------%20t all_pll_used=%b dh_worse=%b th_dp=%d  dh_cnt_fail=%d diag_flag=%x rechk_cnt=%d max_rechk=%d----------------------------",
        $realtime, this.all_pll_used(coreid), vif.dh_worse[coreid], this.th_dp,this.dh_cnt_fail[coreid],this.diag_flag[coreid], this.rechk_cnt[coreid], this.max_rechk);
        
        if(this.ss_sel==2'b11 && this.getSPD(coreid)==3'd1 && this.dh_cnt_fail[coreid]>=this.th_dp)begin
            $display("LOW FREQ Branch do_RANGE_CHG");
            do_RANGE_CHG(coreid);
        end 
        else if(this.ss_sel==2'b11 && this.getSPD(coreid)!=3'd1 && this.dh_cnt_fail[coreid]>=this.th_dp)begin
            $display("worst dh Branch do_DIAG");
            do_DIAG(coreid);
            do_SPD_CHG(coreid);
        end
        else if(this.all_pll_used(coreid)==1'b0 && vif.dh_worse[coreid]==1'b1 && this.diag_flag[coreid] != SILENCE_FLAG)begin
            $display("Branch 0 do_RANGE_CHG");
            do_RANGE_CHG(coreid);
        end
        else if(this.all_pll_used(coreid)==1'b0 && (vif.dh_worse[coreid]==1'b0 || this.diag_flag[coreid]==SILENCE_FLAG))begin
            $display("Branch 1 do_DIAG");
            do_DIAG(coreid);
            do_SPD_CHG(coreid);
        end
        else if(this.all_pll_used(coreid)==1'b1 && this.rechk_cnt[coreid]!=this.max_rechk && this.diag_flag[coreid]!=SILENCE_FLAG)begin
            $display("Branch 2 do_RECHK");
            do_RECHK(coreid);
        end
        else if((this.all_pll_used(coreid)==1'b1 && this.rechk_cnt[coreid]==this.max_rechk) || this.diag_flag[coreid]==SILENCE_FLAG)begin
            $display("Branch 3 do_SLC");
            do_SLC(coreid);
        end
        else begin
            this.setState(coreid, SS_MONITOR);
        end
        this.do_Acc_clr(coreid);
        this.do_PassAcc_clr(coreid);
    endtask
    
    task automatic do_RECHK(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_RECHK----------------------------", $realtime, coreid);
        
        if(getSPD(coreid)>4)begin
            this.spd_low_tmp[coreid] = this.spdlow;
            this.spd_high_tmp[coreid] = 'd7;
        end
        else if(getSPD(coreid)<5) begin    
            this.spd_high_tmp[coreid] = this.spdhigh;
            
            if(get_spd_tmp_mapped(this.spdlow)>get_spd_tmp_mapped(1))
                this.spd_low_tmp[coreid] = this.spdlow;
            else begin
                this.spd_low_tmp[coreid] = 'd1;
            end
        end
        else begin
            this.spd_low_tmp[coreid] = this.spdlow;
            this.spd_high_tmp[coreid] = this.spdhigh;
        end

        
        this.ClrPLLStatus(coreid);
        this.rechk_cnt[coreid]++;
        this.diag_flag[coreid]=RECHECK_FLAG;
        this.setState(coreid, SS_MONITOR);
        this.do_Acc_clr(coreid);
        this.do_PassAcc_clr(coreid);
    endtask

    task automatic do_SLC(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_SLC----------------------------", $realtime, coreid);
        this.setState(coreid, SS_MONITOR);
        this.diag_flag[coreid]=SILENCE_FLAG;
        this.rechk_cnt[coreid]=0;
        this.spd_dir[coreid]=DIR_DW;

        this.ClrPLLStatus(coreid);
        this.spd_high_tmp[coreid]=this.spdhigh;
        this.spd_low_tmp[coreid]=this.spdlow;

    endtask

    task automatic do_TRY_UP(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_TRY_UP----------------------------", $realtime, coreid);
        this.diag_flag[coreid] = TRY_UP_FLAG;
        this.spd_dir[coreid] = DIR_UP;
        this.incSPD(coreid); //TRY_UP independent up
        this.setState(coreid, SS_TRY_MONI);

        if(this.ss_sel==2'b11 && this.getSPD(coreid)==3'd1)begin
            this.half_clk0_status[coreid] = PLL_UNUSED;
            this.half_clk1_status[coreid] = PLL_UNUSED;
            this.half_clk2_status[coreid] = PLL_UNUSED;
        end

        this.do_Acc_clr(coreid);
        this.do_PassAcc_clr(coreid);

    endtask

    task automatic do_TRY_FAIL(input bit [7:0] coreid);
        $display("----------------------------%20t %4d SS_TRY_FAIL----------------------------", $realtime, coreid);
        this.diag_flag[coreid] = WORK_FLAG;
        this.setState(coreid, SS_WORK);
        this.spd_dir[coreid] = DIR_DW;
        this.decSPD(coreid);
        this.do_Acc_clr(coreid);
        this.do_PassAcc_clr(coreid);
    endtask

    task automatic do_RANGE_CHG(input bit [7:0] coreid);
       	//automatic logic all_used_flag=0;
        $display("----------------------------%20t %4d SS_RANGE_CHG----------------------------", $realtime, coreid);
        $display("In do_RANGE_CHG Coreid=%d SPD=%d spd_low_tmp=%d spd_high_tmp=%d pll_status=[%x %x %x %x],half_clk status=[%x %x %x]",
         		coreid, getSPD(coreid), this.spd_low_tmp[coreid], this.spd_high_tmp[coreid], this.pll0_status[coreid], this.pll1_status[coreid], 
         		this.pll2_status[coreid], this.pll3_status[coreid],this.half_clk0_status[coreid],this.half_clk1_status[coreid],this.half_clk2_status[coreid]); 
		
        if(this.ss_sel==2'b11 && getSPD(coreid)=='d1 && this.dh_cnt_fail[coreid]>=this.th_dp)begin
            this.spd_high_tmp[coreid] = 'd7;
            this.spd_low_tmp[coreid] =this.spdlow;
        end
        else if(get_spd_tmp_mapped(this.getSPD(coreid)) <= get_spd_tmp_mapped(this.spd_high_tmp[coreid]) && get_spd_tmp_mapped(this.getSPD(coreid)) >= get_spd_tmp_mapped(this.spd_low_tmp[coreid]))begin
            if(this.spd_dir[coreid] == DIR_UP)begin
                this.spd_high_tmp[coreid] = this.getSPD(coreid);
            end
            else if(this.spd_dir[coreid] == DIR_DW)begin
                this.spd_low_tmp[coreid] = this.getSPD(coreid);
            end
        end


        if(this.ss_sel==2'b11 && getSPD(coreid)=='d1 && this.dh_cnt_fail[coreid]>=this.th_dp)begin
            do_DIAG(coreid);
            do_SPD_CHG(coreid);
        end
        else if(this.all_pll_used(coreid) && this.rechk_cnt[coreid] < this.max_rechk && this.diag_flag[coreid]!=SILENCE_FLAG)begin//rechk_en
            do_RECHK(coreid);
            $display("After SPD_RANGE_CHG then RECHK, Coreid=%d spd_dir reverse to %b", coreid, ~this.spd_dir[coreid]);
            this.spd_dir[coreid] = ~this.spd_dir[coreid];
        end
        else begin
            do_DIAG(coreid);
            do_SPD_CHG(coreid);
        end

        this.do_Acc_clr(coreid);
        this.do_PassAcc_clr(coreid);
    endtask

    function automatic bit all_pll_used(input bit [7:0] coreid);
        bit used_flag = 1'b1;
        $display("In All_pll_used Coreid=%d spd_low_tmp=%d spd_high_tmp=%d pll_status=[%x %x %x %x],half clk_use_status=[%x %x %x]",
         coreid,this.spd_low_tmp[coreid], this.spd_high_tmp[coreid], this.pll0_status[coreid], this.pll1_status[coreid], this.pll2_status[coreid],
          this.pll3_status[coreid],this.half_clk0_status[coreid], this.half_clk1_status[coreid], this.half_clk2_status[coreid]); 
        for(int unsigned i=get_spd_tmp_mapped(this.spd_low_tmp[coreid]); i<=get_spd_tmp_mapped(this.spd_high_tmp[coreid]); i++)begin
            if(getSPD(coreid)<5)begin
                if((i-3) == 1)
                    if(this.pll0_status[coreid] == PLL_UNUSED)
                        used_flag = 1'b0;
                if((i-3) == 2)
                    if(this.pll1_status[coreid] == PLL_UNUSED)
                        used_flag = 1'b0;
                if((i-3) == 3)
                    if(this.pll2_status[coreid] == PLL_UNUSED)
                        used_flag = 1'b0;
                if((i-3) == 4)
                    if(this.pll3_status[coreid] == PLL_UNUSED)
                        used_flag = 1'b0;
            end
            else begin
                if((i+4) == 5)
                    if(this.half_clk0_status[coreid] == PLL_UNUSED)
                        used_flag = 1'b0;
                if((i+4) == 6)
                    if(this.half_clk1_status[coreid] == PLL_UNUSED)
                        used_flag = 1'b0;
                if((i+4) == 7)
                    if(this.half_clk2_status[coreid] == PLL_UNUSED)
                        used_flag = 1'b0;     
            end
        end
        return used_flag;
    endfunction


    function automatic do_Acc_clr(input bit [7:0] coreid);
        this.failtrig_acc_cnt[coreid]=0;
        this.normaltrig_acc_cnt[coreid]=0;
    endfunction

    function automatic do_PassAcc_clr(input bit [7:0] coreid);
        this.passtrig_acc_cnt[coreid]=0;
    endfunction

    function automatic setPLLStatus(input bit [7:0] coreid, input bit [1:0] PLL_STA);
        bit [3:0] spd = getSPD(coreid);
        if(spd == 4'h1)
            this.pll0_status[coreid] = PLL_STA;
        else if(spd == 4'h2)
            this.pll1_status[coreid] = PLL_STA;
        else if(spd == 4'h3)
            this.pll2_status[coreid] = PLL_STA;
        else if(spd == 4'h4)
            this.pll3_status[coreid] = PLL_STA;
        else if(spd == 4'h5)
            this.half_clk0_status[coreid] = PLL_STA;
        else if(spd == 4'h6)
            this.half_clk1_status[coreid] = PLL_STA;
        else if(spd == 4'h7)
            this.half_clk2_status[coreid] = PLL_STA;
        else
            `uvm_error("SPD ADA LOW REFMDL", "SPD=0 SET PLL_STATUS");
    endfunction

    function automatic ClrPLLStatus(input bit [7:0] coreid);

        this.pll0_status[coreid] = PLL_UNUSED ;
        this.pll1_status[coreid] = PLL_UNUSED ;
        this.pll2_status[coreid] = PLL_UNUSED ;
        this.pll3_status[coreid] = PLL_UNUSED ;
        this.half_clk0_status[coreid] = PLL_UNUSED ;
        this.half_clk1_status[coreid] = PLL_UNUSED ;
        this.half_clk2_status[coreid] = PLL_UNUSED ;

    endfunction
    
    task automatic setState(input bit [7:0] coreid_i, input bit [3:0] state_i);
        this.states[coreid_i] = state_i;
        if(vif.check_enable == 1'b1)begin
            fork begin
                automatic bit [7:0] coreid = coreid_i;
                automatic bit [3:0] state = state_i;
                repeat(10) @(posedge vif.mid_clk);
                $display("####################Checking Coreid=%d Exp State=%s ###################", coreid, getStateStr(state)); 
                if(state == SS_WORK)begin
                    if(vif.spd_state_cur[coreid] != SS_WORK)
                        `uvm_error("SPD ADA lOW REFMDL", $psprintf("%10t Coreid=%d State is Not %s, but %s", $realtime, coreid, getStateStr(SS_WORK), getStateStr(vif.spd_state_cur[coreid])));
                    end
                else if(state == SS_MONITOR)begin
                    if(vif.spd_state_cur[coreid] != SS_MONITOR)
                        `uvm_error("SPD ADA LOW REFMDL", $psprintf("%10t Coreid=%d State is Not %s, but %s", $realtime, coreid, getStateStr(SS_MONITOR), getStateStr(vif.spd_state_cur[coreid])));
                    end
                else if(state == SS_TRY_MONI)begin
                    if(vif.spd_state_cur[coreid] != SS_TRY_MONI)
                        `uvm_error("SPD ADA LOW REFMDL", $psprintf("%10t Coreid=%d State is Not %s, but %s", $realtime, coreid, getStateStr(SS_TRY_MONI), getStateStr(vif.spd_state_cur[coreid])));
                end
                else begin
                    `uvm_error("SPD ADA LOW REFMDL", $psprintf("get setStatus input error"));     
                end
            end
            join_none
        end
    endtask
endclass


           
      
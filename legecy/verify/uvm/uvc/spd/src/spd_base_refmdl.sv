import reg_mdl_pkg::*;
import uvm_pkg::*;

class spd_base_refmdl extends uvm_component;
    `uvm_component_utils(spd_base_refmdl);

    string name;
    virtual spd_if vif;
    virtual work_ctrl_if wc_vif;
    virtual mx2_if mx2_vif;
    virtual cpm_if cpm_vif;
    cpm_pkg::cpm_base_cfg cpm_cfg_h;
    //SPD variable\
    logic [15:0]                        marks[`DESIGN_CORE_NUM];
    logic [3:0]                         states[`DESIGN_CORE_NUM];
    bit [1:0]                         pll0_status[`DESIGN_CORE_NUM];
    bit [1:0]                         pll1_status[`DESIGN_CORE_NUM];
    bit [1:0]                         pll2_status[`DESIGN_CORE_NUM];
    bit [1:0]                         pll3_status[`DESIGN_CORE_NUM];
    bit [2:0]                         diag_flag[`DESIGN_CORE_NUM];
    bit [3:0]                         rechk_cnt[`DESIGN_CORE_NUM];
    logic [15:0]                        cnts[`DESIGN_CORE_NUM];
    logic [16*`DESIGN_CORE_NUM-1:0]     sslogs;
    bit                                 spd_chged[`DESIGN_CORE_NUM];   
    bit                                 spd_dir[`DESIGN_CORE_NUM];   
    logic [`SPD_LEN-1:0]      spds;
    logic [`SPD_LEN-1:0]      spds_sync;
    logic                     ssdn_protect;        
    logic [2:0]               spdhigh;        
    logic [2:0]               spdlow;        
    bit [2:0]                 spd_high_tmp[`DESIGN_CORE_NUM-1:0];        
    bit [2:0]                 spd_low_tmp[`DESIGN_CORE_NUM-1:0];        
    bit [7:0]                 normaltrig_acc_cnt[`DESIGN_CORE_NUM-1:0];        
    bit [7:0]                 failtrig_acc_cnt[`DESIGN_CORE_NUM-1:0];   

    bit [15:0]                dh_cnt_fail[`DESIGN_CORE_NUM];      
    logic                     spden;          
    logic                     glbsetvld;      
    logic [2:0]               glbset = 3'b111;  
    logic                     glblimit;    
    //logic [31:0]              SpdTh0;
    logic [15:0]              th_pass;
    logic [15:0]              th_fail;
    //logic [31:0]              SpdTh1;
    logic [15:0]              th_init;
    logic                     th_ms_sel;
    //logic [31:0]              SpdTh2;  
    logic [31:0]              th_to;
    //logic [31:0]              SpdTh3;
    logic [14:0]              lv1thms;
    logic                     lv1thmsadd;
    logic [14:0]              lv2thms;
    logic                     lv2thmsadd;             
    //logic [31:0]              SpdTh4;
    logic [14:0]              lv3thms;
    logic                     lv3thmsadd;
    logic [14:0]              lv4thms;
    logic                     lv4thmsadd;
    

    //logic [31:0]              PllTable;         
    logic [2:0]               plltable_lv0;
    logic [2:0]               plltable_lv1;
    logic [2:0]               plltable_lv2;
    logic [2:0]               plltable_lv3;
    logic [2:0]               plltable_lv4;     
    logic [2:0]               plltable_lv5;
    logic [2:0]               plltable_lv6;
    logic [2:0]               plltable_lv7;  
       
    logic [15:0]              spdlog_timer;          
    logic                     spdlog_timer_on;       
    logic                     spdLog_reset;          
    logic [4:0]               spdcore_ovf_dbg_sel;   
    logic                     spdcore_ovf_bitmap_clr;
 
    //SS TH
    logic    [15:0]             th_lp;
    logic    [15:0]             th_hp;

    logic    [15:0]             th_dp;

    //SS_Rechk
    logic    [3:0]              max_rechk;

    logic    [1:0]             ss_sel;
    logic                      ss_pri;
    logic    [15:0]            ss_pd;
    logic                       gbp_en;
    //ssdn_protect
    bit                         spd_can_down[`DESIGN_CORE_NUM];

    bit [7:0]       REG_fail_trig_acc;
    bit [7:0]       REG_normal_trig_acc;
    bit [7:0]       REG_pass_trig_acc;
    bit             REG_dh_cnt_wdt_on;
    bit [15:0]      REG_dh_cnt_wdt_timer;
 


    function new(string name="spd_base_refmdl",uvm_component parent);
      super.new(name,parent);
    endfunction

    virtual function new_vif(string name="spd_base_refmdl", virtual spd_if vif, virtual work_ctrl_if wc_vif, virtual cpm_if cpm_vif, virtual mx2_if mx2_vif,  cpm_pkg::cpm_base_cfg cpm_cfg_h);
        this.name = name;
        this.vif = vif;
        this.wc_vif = wc_vif;
        this.cpm_vif = cpm_vif;
        this.mx2_vif = mx2_vif;
        this.cpm_cfg_h = cpm_cfg_h;
        this.clr_spd_chg();
    endfunction
    
    


    virtual task initMdl();
        //assign all the RTL signal to local variable
        //this.spds = vif.REG_Spd;
      for(integer i=0; i<`DESIGN_CORE_NUM; i++)begin
            uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.spd_sel_tmp[2:0]",i), this.spds[i*4+:4]);
        end
        this.ssdn_protect = vif.ssdn_protect;
        this.spdhigh = vif.global_spd_high;
        this.spdlow = vif.global_spd_low;
        this.spden = vif.global_spd_en;
        this.glbsetvld = vif.global_set_vld;
        this.glbset = vif.global_set;
        this.glblimit=vif.REG_glb_limit;
        //PllTable     
        this.plltable_lv0 = vif.gate;
        this.plltable_lv1 = vif.plltable_lv0;
        this.plltable_lv2 = vif.plltable_lv1;
        this.plltable_lv3 = vif.plltable_lv2;
        this.plltable_lv4 = vif.plltable_lv3;
        this.plltable_lv5 = vif.plltable_lv4;
        this.plltable_lv6 = vif.plltable_lv5;
        this.plltable_lv7 = vif.plltable_lv6;

        this.spdlog_timer = vif.spdlog_timer;
        this.spdlog_timer_on = vif.spdlog_timer_on;
        this.spdLog_reset = vif.spdlog_reset;       
        this.spdcore_ovf_dbg_sel = vif.spdcore_ovf_dbg_sel;
        this.spdcore_ovf_bitmap_clr = vif.spdcore_ovf_bitmap_clr;

        

        $display("spdhigh = %d", this.spdhigh);
        $display("spdlow = %d", this.spdlow);
        $display("spden = %d", this.spden);
        $display("spd_ssdn_pro = %d", this.ssdn_protect);
        $display("glbsetvld = %d", this.glbsetvld);
        $display("glbset = %d", this.glbset);
        $display("glblimit = %d", this.glblimit);
        $display("-----------------------------------------");
        $display("plltable_lv0 = %x", this.plltable_lv0);
        $display("plltable_lv1 = %x", this.plltable_lv1);
        $display("plltable_lv2 = %x", this.plltable_lv2);
        $display("plltable_lv3 = %x", this.plltable_lv3);
        $display("plltable_lv4 = %x", this.plltable_lv4);
        $display("plltable_lv5 = %x", this.plltable_lv5);
        $display("plltable_lv6 = %x", this.plltable_lv6);
        $display("plltable_lv7 = %x", this.plltable_lv7);
        $display("-----------------------------------------");
        $display("spdlog_timer = %d", this.spdlog_timer);
        $display("spdlog_timer_on = %d", this.spdlog_timer_on);
        $display("spdcore_ovf_dbg_sel = %d", this.spdcore_ovf_dbg_sel);
        $display("spdcore_ovf_bitmap_clr = %d", this.spdcore_ovf_bitmap_clr);

        //get the marks
        for(integer i=0; i<`DESIGN_CORE_NUM; i++)begin
            uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_simple.mark[15:0]",i), this.marks[i]);
        end
        
        this.gbp_en = vif.REG_gbp_en;
        for(integer i=0; i<`DESIGN_CORE_NUM; i++)begin
            this.spd_can_down[i]=1'b1;           
        end 
    endtask

    task automatic set_glbset(logic [2:0] spd, logic [15:0] thinit,logic glblimit);
        this.glbset = spd;
        this.glblimit = glblimit;
        for(int i=0; i<`DESIGN_CORE_NUM; i++) begin

            if (this.glblimit==1) begin

                if (this.spds[i*4+:4]!==0) begin
                    this.spds[i*4+:4] = spd;
                    this.marks[i] = thinit;
                end
                else begin
                    this.spds[i*4+:4] = 0;
                    this.marks[i] = thinit;
                end
            
            end
            else begin
                this.spds[i*4+:4] = spd;
                this.marks[i] = thinit;
            end

        end 
        if(this.ss_sel != 2'b01)
            return;

        //wait RTL data Ready
        repeat(10) begin
            @(posedge vif.clk);
        end 

        for(int id=0;id<`DESIGN_CORE_NUM;id++)fork 

            automatic logic [7:0]       cur_coreid = id;
            automatic logic [15:0]      rtl_mark;
            automatic logic [3:0]       rtl_spd;
            automatic logic [3:0]       spd_exp = get_map_spd(this.spds[cur_coreid*4+:4]);
            automatic logic [15:0]      mark_exp = this.marks[cur_coreid];
               
            begin
                uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_simple.mark[15:0]",cur_coreid), rtl_mark);
                uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.spd_sel[2:0]",cur_coreid), rtl_spd);

                if(spd_exp != rtl_spd) begin
                    `uvm_error("SPD_REF_MDL CHECK FAILED", $psprintf("coreid=%d  mdl_spd=%d rtl_spd=%d",cur_coreid,spd_exp,rtl_spd));
                end
                else begin
                    `uvm_info("set_glbset", $psprintf("coreid=%d  mdl_spd=%d  rtl_spd=%d",cur_coreid, spd_exp, rtl_spd),UVM_MEDIUM);
                end
                if(mark_exp != rtl_mark) begin
                    `uvm_error("SPD_REF_MDL CHECK FAILED", $psprintf("coreid=%d  mdl_mark=%x rtl_mark=%x",cur_coreid,mark_exp, rtl_mark));
                end
                else begin
                    `uvm_info("set_glbset", $psprintf("coreid=%d  mdl_mark=%x  rtl_mark=%x",cur_coreid, mark_exp, rtl_mark), UVM_MEDIUM);
                end
            end
        join_none
        wait fork;
        $display("set_glbset and spd  check finished ");
    endtask

    task automatic set_spds(logic [15:0] thinit);
        //this.spds = REG_Spd;
        for(integer i=0; i<`DESIGN_CORE_NUM; i++)begin
            uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.spd_sel_tmp[2:0]",i), this.spds[i*4+:4]);
            this.marks[i] = thinit;
        end
    endtask

    task automatic set_spden(logic spden, logic [15:0] thinit);
        this.spden = spden;
        for(int i=0; i<`DESIGN_CORE_NUM; i++) begin
            this.marks[i] = thinit;
        end
    endtask

    task automatic set_gbp_state(logic [7:0] gbp_id, logic gbp_mode, logic gbp_st);
        if(gbp_id>=0 && gbp_id < `DESIGN_CORE_NUM)begin
            if(gbp_st == 1'b1)begin
                if(gbp_mode == 1'b1)begin
                    this.spds[gbp_id*4+:4] = 4'b0;
                end
                else if(gbp_mode == 1'b0)begin
                    this.spds[gbp_id*4+:4] = this.glbset;
                end
            end
        end
    endtask

    function automatic logic[2:0] get_map_spd(logic [2:0] spd);
        if(spd == 0)
            return this.plltable_lv0;
        if(spd == 1)
            return this.plltable_lv1;
        if(spd == 2)
            return this.plltable_lv2;
        if(spd == 3)
            return this.plltable_lv3;
        if(spd == 4)
            return this.plltable_lv4;
        if(spd == 5)
            return this.plltable_lv5;
        if(spd == 6)
            return this.plltable_lv6;
        if(spd == 7)
            return this.plltable_lv7;    
        `uvm_error("SPD_REF_MDL", $psprintf("get_map_spd spd=%d invalid", spd));
    endfunction

    function automatic real get_freq_exp(logic [2:0] map_spd);
        real prods[8];
        prods[0] = 0.0;

        `ifdef STUB_PLL
            `ifdef WORK_PLL_MC_100M
                prods[1] = 1000.0/100.0;
                prods[2] = 1000.0/100.0;
                prods[3] = 1000.0/100.0;
                prods[4] = 1000.0/100.0;
            `else
                `ifdef WORK_PLL_FPGA_120_120_150_170
                    prods[1] = 1000.0/120.0;
                    prods[2] = 1000.0/120.0;
                    prods[3] = 1000.0/150.0;
                    prods[4] = 1000.0/170.0;
                `else
                    prods[1] = 1000.0/(cpm_cfg_h.pll0_freq*1.0);
                    prods[2] = 1000.0/(cpm_cfg_h.pll1_freq*1.0);
                    prods[3] = 1000.0/(cpm_cfg_h.pll2_freq*1.0);
                    prods[4] = 1000.0/(cpm_cfg_h.pll3_freq*1.0);
                `endif
            `endif
        `else
            prods[1] = 1000.0/`XCLK_FREQ; prods[2] = 1000.0/`XCLK_FREQ; prods[3] = 1000.0/`XCLK_FREQ; prods[4] = 1000.0/`XCLK_FREQ;
            if(cpm_cfg_h.pll0_bypass == 0)begin
                prods[1] = 1000.0/cpm_cfg_h.pll0_freq;
            end 
            if(cpm_cfg_h.pll1_bypass == 0)begin
                prods[2] = 1000.0/cpm_cfg_h.pll1_freq;
            end
            if(cpm_cfg_h.pll2_bypass == 0)begin
                prods[3] = 1000.0/cpm_cfg_h.pll2_freq;
            end
            if(cpm_cfg_h.pll3_bypass == 0)begin
                prods[4] = 1000.0/cpm_cfg_h.pll3_freq;
            end
        `endif

        prods[5]=prods[2]*2;
        prods[6]=prods[3]*2;
        prods[7]=prods[4]*2;

        if(map_spd >=0 && map_spd <=7) begin
            return prods[map_spd];
        end
        `uvm_error("SPD_REF_MDL", $psprintf("get_freq_exp spd=%d invalid", map_spd));
    endfunction

    function bit chkc_real_diffequal(input real p_realdata_act, input real p_realdata_exp, input real p_max_diffrate=0.01);
        bit  v_result;
        real v_diff;
        real v_diffrate;
        v_diff = p_realdata_act - p_realdata_exp;
        if(v_diff < 0) begin
            v_diff = p_realdata_exp - p_realdata_act;
        end
        v_diffrate = v_diff / p_realdata_exp;
        if( v_diffrate > p_max_diffrate ) begin
            v_result = 0;
        end
        else begin
            v_result = 1;
        end
        return v_result;
    endfunction

    function bit chkc_real_equal(input real act, input real exp, input bit p_abs=0, input real p_max_diffrate=0.01);
        bit  v_result;    
        real v_realdata_act_real;
        real v_realdata_exp_real;
        real v_diff;
        real v_diffrate;
        if(act === 0 && exp == 0) begin
            return 1;
        end
        if(p_abs === 1) begin
            v_result = (act === exp);
        end
        else begin
            v_result = chkc_real_diffequal(act, exp, p_max_diffrate);
        end
        return v_result;
    endfunction


    task mark_spd_chg(bit [7:0] coreid);
        //$display("Mark Coreid=%d", coreid);
        this.spd_chged[coreid] = 1'b1;
    endtask
    
    function clr_spd_chg();
        for(int i=0; i<`DESIGN_CORE_NUM; i++)begin
            this.spd_chged[i] = 1'b0;
        end
    endfunction
    task sync_spds();
       `uvm_info("SPD_REF_MDL", $psprintf("Sync Backup Spds=%x", this.spds), UVM_MEDIUM); 
       this.spds_sync = this.spds; 
    endtask


    task chk_clk_proc_instant(bit [7:0] coreid, bit [2:0] spd);
        automatic bit [2:0] spd_exp;
        automatic bit [7:0] cur_coreid=coreid;
        automatic real freq_exp = 0,f0=0,f1=0;
        automatic real freq_act = 0;
        $display("In chk_clk_proc corid=%d", cur_coreid);
        spd_exp = get_map_spd(spd);
        freq_act = this.vif.clk_prod[cur_coreid];
        freq_exp = this.get_freq_exp(spd_exp);
        `uvm_info("SPD_REF_MDL", $psprintf("Start checking Coreid=%d freq_exp=%f spd=%d map_spd=%d", cur_coreid, freq_exp, spd, spd_exp), UVM_MEDIUM);
        if(chkc_real_equal(freq_exp,freq_act) !== 1) begin
            `uvm_error("SPD_MDL_CHECK FAILED", $psprintf("Coreid=%d freq_exp=%f freq_act=%f mismatch", cur_coreid, freq_exp, freq_act));
        end
    endtask



    task chk_hash_clk();
       if(vif.check_enable == 0) begin
            return;
        end 
        for(int i=0; i<`DESIGN_CORE_NUM; i++)begin
            automatic int coreid = i;
            automatic bit [3:0] spd_exp =  this.spds_sync[i*4+:4];
            chk_clk_proc_instant(coreid, spd_exp); 
        end
    endtask


   virtual task automatic  trig_pass(input done, input pass, input [7:0] coreid);endtask
    virtual task automatic  check_spd_marks(input [7:0] coreid);endtask
    virtual task automatic  trig_timeout();endtask
    virtual task automatic  state_change();endtask
    virtual task automatic reset_states();endtask
    virtual task automatic set_work_states();endtask
    virtual task automatic set_cnt_timer(bit [15:0] cnt);endtask
    virtual task automatic pass_trigger(bit [7:0] coreid);endtask
    virtual task automatic fail_trigger(bit [7:0] coreid);endtask
    virtual task automatic normal_trigger(bit [7:0] coreid);endtask
    virtual task automatic timeout_trigger(bit [7:0] coreid);endtask

    virtual task automatic do_IDLE(bit [7:0] coreid);endtask
    virtual task automatic do_WORK(bit [7:0] coreid);endtask
    virtual function automatic ClrPLLStatus(bit [7:0] coreid);endfunction

    virtual function bit [3:0] getSPD(input bit [7:0] coreid);
        return this.spds[coreid*4+:4];
    endfunction
    
    virtual function automatic setSPD(input bit [7:0] coreid, input bit [3:0] spd);
        this.spds[coreid*4+:4] = spd;
    endfunction

    virtual task automatic incSPD(input bit [7:0] coreid);endtask
    virtual task automatic decSPD(input bit [7:0] coreid);endtask
    virtual task automatic chkSPD(input bit[7:0] coreid);endtask

endclass

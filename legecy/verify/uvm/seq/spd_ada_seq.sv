class spd_fake_pantern_ss_seq extends spd_new_base_seq;
   `uvm_object_utils(spd_fake_pantern_ss_seq)
    work_ctrl_mine_work m_work;

   function new(string name="spd_fake_pantern_ss_seq");
      super.new(name);
      for(int i=0;i<`DESIGN_CORE_NUM;i++)begin
            m_work_list[i]=new();
      end
   endfunction : new

   task pre_body();
     super.pre_body();

   endtask 

   task body();
    logic [31:0] glb_sel;
    logic [31:0] step;
    logic [31:0] targetid;
    logic [3:0]  targetsel;
    logic pass;
    bit [3:0]   cur_state;
    int coreid = 0;
    int times_cnt = 1;
    int spdgo_interval=0;
    bit [3:0] exp_spd;
    bit [16*`DESIGN_CORE_NUM+32-1 : 0] sslogs;
    bit [4:0] state_trans[$];
    bit [7:0] normal_trig_acc_rand;
    bit [7:0] fail_trig_acc_rand;
    int fail_tmp=0;
    int pass_tmp=0;
    int dh_cnt_timer=0;
    bit [31:0] act_spdlog_passcnt = 0;
    bit [31:0] act_spdlog_failcnt = 0;
    bit [31:0] exp_spdlog_passcnt = 0;
    bit [31:0] exp_spdlog_failcnt = 0;
    super.body();
    
    `ifdef NO_INIT
     initRst();
     wrc_cpm_plls();
     work_reg_init_seq();
    `endif
    `uvm_info(get_type_name(), "spd_fake_pantern_ss_seq start", UVM_MEDIUM);
    assert(spd_cfg_h.randomize(plltable_lv1, plltable_lv2, plltable_lv3, plltable_lv4) with {plltable_lv1 == 1; plltable_lv2==2; plltable_lv3==3; plltable_lv4==4;}) else $finish;
    $display("START=%d END=%d", GET_START(), GET_END());
    set_spd_plltable({spd_cfg_h.plltable_lv1, spd_cfg_h.plltable_lv2, spd_cfg_h.plltable_lv3, spd_cfg_h.plltable_lv4});
    set_ssth_init(.th_hp(2), .th_lp(5), .max_rechk(3));
    set_spd_init(.spdlow(1), .spdhigh(`TB_PLL_NUM), .spden(1), .glbsetvld(1), .glbset(1), .ss_sel(2'b10), .ss_pri(1), .ss_pd(10));
    #200ns;
    $display("####################################  START SPD REF MODEL ######################################");
    spd_vif.check_enable = 1'b1;

    `ifdef PANTERN_1TO4
        
        set_ssth_init(.th_hp(2), .th_lp(5), .max_rechk(3));
        set_spd_init(.spdlow(1), .spdhigh(`TB_PLL_NUM), .spden(1), .glbsetvld(1), .glbset(1), .ss_sel(2'b10), .ss_pri(1), .ss_pd(10));
        set_spdlog_reset();
        `ifdef SELFCLK 
                assert(spd_cfg_h.randomize(rand_coreid) with {rand_coreid inside {[0:`DESIGN_CORE_NUM-1]};});   
                coreid = spd_cfg_h.rand_coreid;
                trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(10), .failcnt(0));
                trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(10), .failcnt(0));
                trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(10), .failcnt(0));
                #2000
                check_spdcore_equal(.exp({`DESIGN_CORE_NUM{4'h4}}), .coreid(coreid),.mapped(1'b1));
                check_spdlog_equal(.exp({`DESIGN_CORE_NUM{32'd30}}), .coreid(coreid));
        `else
            //Reward 1 to 4, Random insert a Nonce Pass, FakeCoreE&RealCore
            state_trans = {SS_WORK, SS_REWARD, SS_WORK, SS_REWARD, SS_WORK, SS_REWARD, SS_WORK, SS_REWARD}; 
            `MON_STATE_TRANS(GET_START(), state_trans)

            for(int i = GET_START(); i < GET_END(); i = i + 1) begin    
                coreid = i;
                trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(10), .failcnt(0), .spdgo(1'b0));
                trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(9), .failcnt(1), .spdgo(1'b0));
                trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(8), .failcnt(2), .spdgo(1'b0));
                `ifdef USE_FAKECORE
                    m_work = m_work_list[coreid];
                    $display("Coretest for %d", coreid);
                    //Generate work
                    m_work.setGoldWork(m_work_pool.getGoldWork());
                    m_work.setRegTBase(work_ctrl_cfg_h.tbase);
                    //select core id to return the nonce with fakecore
                    m_work.nonceMask(coreid);
                    //randomize the ntime.
                    m_work.reCalcTime(work_ctrl_cfg_h.ntime);
                    // m_work.reCalcTime(0);
                    //ft_en to be zero.
                    m_work.workRegenerate(`FT_DIS);
                    m_work.print();

                    `SET_REG_FIELD(work, cfg, cfg_rollen, `ON);
                    `UPDATE_REG(work, cfg);
                    workAssign(m_work);

                    checkRollNonceReturnTimeout(m_work.ntime);
                    checkNonceCorrect(m_work);

                    trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(7), .failcnt(2), .spdgo(1'b0));
                `else
                    trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(8), .failcnt(2), .spdgo(1'b0));
                `endif

            end
            `CHK_STATE_TRANS(GET_START(), state_trans)
            set_spdgo();
            for(int i = GET_START(); i < GET_END(); i = i + 1) begin    
                check_spdcore_equal(.exp({`DESIGN_CORE_NUM{4'h4}}), .coreid(i), .mapped(1'b1));
                check_spdlog_equal(.exp({`DESIGN_CORE_NUM{16'd5,16'd35}}), .coreid(i));
                chk_sslog(.coreid(i), .diag_flag(WORK_FLAG), .pll0_status(PLL_USED), .pll1_status(PLL_USED), .pll2_status(PLL_USED), .pll3_status(PLL_USED));
            end

            //Same with SSLOG
            set_ssth_init(.th_hp(2), .th_lp(5), .max_rechk(3));
            set_spd_init(.spdlow(1), .spdhigh(`TB_PLL_NUM), .spden(1), .glbsetvld(1), .glbset(4), .ss_sel(2'b10), .ss_pri(1), .ss_pd(10));
            set_spdlog_reset();
            for(int i = GET_START(); i < GET_END(); i = i + 1) begin    
                coreid = i;
                trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(10), .failcnt(0), .spdgo(1'b0));
                chk_sslog(.coreid(coreid), .pass_trigger(1), .normal_trigger(0), .fail_trigger(0), .dh_worse(0) );
            
                trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(7), .failcnt(3), .spdgo(1'b0));
                chk_sslog(.coreid(coreid), .pass_trigger(0), .normal_trigger(1), .fail_trigger(0), .dh_worse(0) );
        
                trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(5), .failcnt(5), .spdgo(1'b0));
                chk_sslog(.coreid(coreid), .pass_trigger(0), .normal_trigger(0), .fail_trigger(1), .dh_worse(0) );
            
                trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(4), .failcnt(6), .spdgo(1'b0));
                chk_sslog(.coreid(coreid), .pass_trigger(0), .normal_trigger(0), .fail_trigger(1), .dh_worse(1) );

                trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(3), .failcnt(7), .spdgo(1'b0));
                chk_sslog(.coreid(coreid), .pass_trigger(0), .normal_trigger(0), .fail_trigger(1), .dh_worse(0) );

            end
        `endif
    
    `endif //PANTERN_1TO4
    
    `ifdef PANTERN_SSLOG

        set_ssth_init(.th_hp(2), .th_lp(5), .max_rechk(3));
        set_spd_init(.spdlow(1), .spdhigh(`TB_PLL_NUM), .spden(1), .glbsetvld(1), .glbset(4), .ss_sel(2'b10), .ss_pri(1), .ss_pd(10));
        set_spdlog_reset();
        for(int i = GET_START(); i < GET_END(); i = i + 1) begin    
            coreid = i;
            trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(10), .failcnt(0), .spdgo(1'b0));
            chk_sslog(.coreid(coreid), .pass_trigger(1), .normal_trigger(0), .fail_trigger(0), .dh_worse(0) );
            
            trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(7), .failcnt(3), .spdgo(1'b0));
            chk_sslog(.coreid(coreid), .pass_trigger(0), .normal_trigger(1), .fail_trigger(0), .dh_worse(0) );
        
            trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(5), .failcnt(5), .spdgo(1'b0));
            chk_sslog(.coreid(coreid), .pass_trigger(0), .normal_trigger(0), .fail_trigger(1), .dh_worse(0) );
            
            trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(4), .failcnt(6), .spdgo(1'b0));
            chk_sslog(.coreid(coreid), .pass_trigger(0), .normal_trigger(0), .fail_trigger(1), .dh_worse(1) );

            trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(3), .failcnt(7), .spdgo(1'b0));
            chk_sslog(.coreid(coreid), .pass_trigger(0), .normal_trigger(0), .fail_trigger(1), .dh_worse(0) );

        end

    `endif 

    `ifdef PANTERN_SS_RAND
        spd_cfg_h.constr_ss_low.constraint_mode(0);
        spd_cfg_h.constr_ss_mid.constraint_mode(0);
        spd_cfg_h.constr_ss_high.constraint_mode(0);
        spd_cfg_h.constr_ss_rand.constraint_mode(1);
        assert(spd_cfg_h.randomize()) else $finish();
        //assert(spd_cfg_h.randomize(plltable_lv1, plltable_lv2, plltable_lv3, plltable_lv4) with {plltable_lv1 == 1; plltable_lv2==2; plltable_lv3==3; plltable_lv4==4;}) else $finish;
        set_spd_plltable({spd_cfg_h.plltable_lv1, spd_cfg_h.plltable_lv2, spd_cfg_h.plltable_lv3, spd_cfg_h.plltable_lv4});
        set_ssth_init(.th_hp(spd_cfg_h.th_hp), .th_lp(spd_cfg_h.th_lp), .max_rechk(spd_cfg_h.max_rechk), .normal_trig_acc(spd_cfg_h.rand_normal_trig_acc), .fail_trig_acc(spd_cfg_h.rand_fail_trig_acc), .th_same(spd_cfg_h.th_same));
        set_spd_init(.spdlow(1), .spdhigh(`TB_PLL_NUM), .spden(1), .glbsetvld(1), .glbset(spd_cfg_h.glb_set), .ss_sel(2'b10), .ss_pri(spd_cfg_h.ss_pri), .ss_pd(spd_cfg_h.ss_pd));
        set_ss_delta(.delta1(spd_cfg_h.th_delta1), .delta2(spd_cfg_h.th_delta2), .delta3(spd_cfg_h.th_delta3), .delta4(spd_cfg_h.th_delta4));
        set_spdlog_reset();
        //Refmdl Check Rand Case
        `ifndef SS_RAND_COREID        
            `ifndef SS_FULL_RAND_PERCENT
                for(int i = GET_START(); i < GET_END(); i = i + 1) begin    
                    coreid = i;
                    for(int unsigned k=0; k<20; k++)begin
                        trigc_work_fake_spd_ss_mod(.coreid(coreid), .mod(`SS_RAND_MODE));
                        if($urandom_range(0,3) == 2)begin
                            if(spdgo_interval==2)begin
                                set_spdgo();
                                spdgo_interval=0;
                            end
                            else begin
                                spdgo_interval=spdgo_interval+1;
                            end
                        end
    
                    end
                end
            `else
                for(int i = GET_START(); i < GET_END(); i = i + 1) begin    
                    coreid = i;
                    for(int unsigned k=0; k<40; k++)begin
                        trigc_work_fake_spd_ss_mod(.coreid(coreid), .mod(`SS_RAND_MODE));
                        if($urandom_range(0,3) == 2)begin
                            if(spdgo_interval==2)begin
                                set_spdgo();
                                spdgo_interval=0;
                            end
                            else begin
                                spdgo_interval=spdgo_interval+1;
                            end
                        end
                    end
                end
            `endif
        `else
            for(int unsigned k=0; k<500; k++)begin
                assert(spd_cfg_h.randomize(rand_coreid) with {rand_coreid inside {[0:`DESIGN_CORE_NUM-1]};} ) else $finish;
                coreid = spd_cfg_h.rand_coreid;
                trigc_work_fake_spd_ss_mod(.coreid(coreid), .mod(`SS_RAND_MODE));
                // if($urandom_range(0,10) == 5)
                //     set_spdgo();
                if($urandom_range(0,3) == 2)begin
                    if(spdgo_interval==2)begin
                        set_spdgo();
                        spdgo_interval=0;
                    end
                    else begin
                        spdgo_interval=spdgo_interval+1;
                    end
                end
            end
        `endif

    `endif


    `uvm_info(get_type_name(), "spd_fake_pantern_ss_seq end", UVM_MEDIUM);

   endtask
endclass
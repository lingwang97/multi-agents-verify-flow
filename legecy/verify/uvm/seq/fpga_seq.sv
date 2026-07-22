class fpga_base_seq extends base_seq;
   virtual top_if   top_vif;
   virtual work_ctrl_if work_ctrl_vif; 
   `uvm_object_utils(fpga_base_seq)

   //////////////////////////////////////////////////////////////
   // Function Used To "New" The Class
   //////////////////////////////////////////////////////////////
   function new(string name="fpga_base_seq");
      super.new(name);
   endfunction : new

   task pre_body();
     super.pre_body();

     if (!uvm_config_db #(virtual interface top_if)::get(m_sequencer, "", "top_vif", top_vif))
      `uvm_error("RO_VIP:ERROR", "VIF top_vif is missing from config_db")
    if (!uvm_config_db #(virtual interface work_ctrl_if)::get(m_sequencer, "", "work_ctrl_vif", work_ctrl_vif))
      `uvm_error("RO_VIP:ERROR", "VIF work_ctrl_vif is missing from config_db")

   endtask

   task body();
     super.body();
   endtask



  task fpga_work_calc(input int core_id);
        work_ctrl_mine_work m_work;
        m_work = new();
        m_work.setGoldWork(m_work_pool.getGoldWork());
        m_work.setRegTBase(work_ctrl_cfg_h.tbase);
        //select core id to return the nonce with fakecore
        m_work.nonceMask(core_id);
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

  endtask


   
endclass


class fpga_spd_fake_pantern_ss_seq extends fpga_base_seq;
   `uvm_object_utils(fpga_spd_fake_pantern_ss_seq)

   function new(string name="fpga_spd_fake_pantern_ss_seq");
      super.new(name);
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
    bit [16*`DESIGN_CORE_NUM+32-1 : 0] sslogs;
    super.body();
    initRst();
    wrc_cpm_plls();
    work_reg_init_seq();
    initSpd();
    //Add by wangjianli 20230301
    selfclk_conf();
    `uvm_info(get_type_name(), "fpga_spd_fake_pantern_ss_seq start", UVM_MEDIUM);
 
    //initWorkCoreReg();

    set_spd_plltable({1,2,3,4});

    $display("####################################  START SPD REF MODEL ######################################");
    spd_vif.check_enable = 1'b1;
    spd_vif.spd_gbp_assertion_checks_disable = 1'b1;

    set_ssth_init(.th_hp(2), .th_lp(5), .max_rechk(3));
    set_spd_init(.spdlow(1), .spdhigh(`TB_PLL_NUM), .spden(1), .glbsetvld(1), .glbset(4), .ss_sel(2'b10), .ss_pri(1), .ss_pd(10));
    `SET_REG_FIELD(speed, spdlog_reset, spdlog_reset, `ON);
    `PRINT_REG_SETTING(speed,spdlog_reset);
    `UPDATE_REG(speed, spdlog_reset);      

    for(int i = 0; i < `DESIGN_CORE_NUM; i = i + 1) begin
        if(isc_core_fpga(i) == 0) continue;
        $display("Test FPGA Core %d", i);
        coreid = i;
        //spd=4
        trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(4), .failcnt(6));
        #2000
        check_spdcore_equal({`DESIGN_CORE_NUM{4'h3}}, coreid, 1'b0);
        //spd=3
        trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(4), .failcnt(6));
        #2000
        check_spdcore_equal({`DESIGN_CORE_NUM{4'h2}}, coreid, 1'b0);
        //spd=2
        trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(4), .failcnt(6));
        #2000
        check_spdcore_equal({`DESIGN_CORE_NUM{4'h1}}, coreid, 1'b0);
        //spd=1 RECHK
        trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(4), .failcnt(6));
        #2000
        check_spdcore_equal({`DESIGN_CORE_NUM{4'h1}}, coreid, 1'b0);

        //spd=1 
        trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(4), .failcnt(6));
        #2000
        check_spdcore_equal({`DESIGN_CORE_NUM{4'h2}}, coreid, 1'b0);

        //spd=2 
        trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(4), .failcnt(6));
        #2000
        check_spdcore_equal({`DESIGN_CORE_NUM{4'h3}}, coreid, 1'b0);

        //spd=3
        trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(4), .failcnt(6));
        #2000
        check_spdcore_equal({`DESIGN_CORE_NUM{4'h4}}, coreid, 1'b0);

        //spd=4 RECHK
        trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(4), .failcnt(6));
        #2000
        check_spdcore_equal({`DESIGN_CORE_NUM{4'h4}}, coreid, 1'b0);
        

        //spd=4 cnt>lp
        trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(4), .failcnt(6));
        #2000
        check_spdcore_equal({`DESIGN_CORE_NUM{4'h3}}, coreid, 1'b0);
        
        //spd=3
        trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(6), .failcnt(4));
        #2000
        check_spdcore_equal({`DESIGN_CORE_NUM{4'h2}}, coreid, 1'b0);
        
        //spd=2 
        trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(6), .failcnt(4));
        #2000
        check_spdcore_equal({`DESIGN_CORE_NUM{4'h1}}, coreid, 1'b0);
        
        //spd=1 
        trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(7), .failcnt(3));
        #2000
        check_spdcore_equal({`DESIGN_CORE_NUM{4'h1}}, coreid, 1'b0);
        
        //spd=1
        trigc_work_fake_spd_ss(.coreid(coreid),.passcnt(7), .failcnt(3));
        #2000;
        check_spdcore_equal({`DESIGN_CORE_NUM{4'h1}}, coreid, 1'b0);

        //check_spdlog_equal({`DESIGN_CORE_NUM{32'h0044003e}}, coreid);
    end

  endtask
endclass
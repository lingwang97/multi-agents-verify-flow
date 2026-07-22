class spd_new_base_seq extends base_seq;
    `uvm_object_utils(spd_new_base_seq)

    //////////////////////////////////////////////////////////////
    // Function Used To "New" The Class
    //////////////////////////////////////////////////////////////
    function new(string name="spd_new_base_seq");
        super.new(name);

    endfunction : new

    task pre_body();
        super.pre_body();

        //clear nouce fifo
        
        for(int i=0;i<`DESIGN_CORE_NUM;i++)begin
            automatic int j=i;
            fork
                begin
                    `ifndef PL_SIM
                        wait(&work_ctrl_vif.top_rx_mx2_tx_set[j]);
                    `else
                        wait(&spd_vif.top_rx_mx2_tx[j]);
                    `endif
                end
            join
        end
        repeat(`DESIGN_CORE_NUM *2)@(posedge spd_vif.clk);
        
        //wait(work_ctrl_vif.pp_empty);
        `SET_REG_FIELD(work,cfg,cfg_rstfifo,`ON);
        `UPDATE_REG(work,cfg);
        repeat(200)@(posedge spd_vif.clk);

    endtask

    task body();
        super.body();
        `SET_REG_FIELD(speed,spdlog_timer, spdlog_timer, 16'hffff);
        `SET_REG_FIELD(speed,spdlog_timer, spdlog_timer_on, `OFF);
        `PRINT_REG_SETTING(speed,spdlog_timer);
        `UPDATE_REG(speed,spdlog_timer);
        `ifdef BROADCAST_NONCE
            `ifndef AGING_BROADCAST_NONCE_OFF
                workAssignForSpd();
            `endif
        `endif

        `ifdef KEEP_CK_DONE_LOW
            uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.work_ctrl.aft_ck_done",1'd0);
        `endif

         /*uvm_hdl_force("tb_top.RO",1'b1);
        `uvm_info(get_full_name(), $psprintf("Force hard reset situation = %h", 1), UVM_LOW);
        repeat(20) @(posedge spd_vif.clk);
        uvm_hdl_force("tb_top.RO",1'b0);
        `uvm_info(get_full_name(), $psprintf("Release hard reset situation = %h, close aging mode.", 0), UVM_LOW);
        */
    endtask

endclass : spd_new_base_seq


class spd_fake_pantern_seq extends spd_new_base_seq;
   `uvm_object_utils(spd_fake_pantern_seq)

   function new(string name="spd_fake_pantern_seq");
      super.new(name);
   endfunction : new

   task pre_body();
     super.pre_body();

   endtask

   task body();
    logic [31:0] glb_sel;
    logic [31:0] step;
    logic [31:0] targetid;
    logic [3:0] targetsel;
    logic pass;

    logic [`SPD_LEN-1:0] out_spd_core= 'b0;
    logic [3:0]   maped_spd='b0;
    logic [`SPD_LEN-1:0] actual_with_tiny;
    int   plltable[4];

   bit [31:0] act_spdlog_passcnt = 0;
   bit [31:0] act_spdlog_failcnt = 0;
   bit [31:0] exp_spdlog_passcnt = 0;
   bit [31:0] exp_spdlog_failcnt = 0;
    super.body();

    `uvm_info(get_type_name(), "spd_fake_pantern_seq start", UVM_MEDIUM);
    


    $display("####################################  START SPD REF MODEL ######################################");
    spd_vif.check_enable = 1'b1;

    `ifdef FAKE_PANTERN_RAND
        for(int i = 0; i < 3; i = i + 1) begin
            targetid = $urandom % `DESIGN_CORE_NUM;
            pass = $urandom%2;
            fork: rand_glbsel
            while(1)begin
                glb_sel = $urandom % 32'd4 + 1;
                if(glb_sel >= spd_cfg_h.spd_low && glb_sel <= spd_cfg_h.spd_high) break;
            end
            #200;
            join_any
            disable rand_glbsel;

            step = $urandom % 32'd4 + 1;
            set_spd_init(.spdlow(spd_cfg_h.spd_low), .spdhigh(spd_cfg_h.spd_high), .spden(1), .glbsetvld(1), .glbset(glb_sel));
            `SET_REG_FIELD(speed, spdlog_reset, spdlog_reset, `ON);
            `PRINT_REG_SETTING(speed,spdlog_reset);
            `UPDATE_REG(speed, spdlog_reset);
            $display("Pass=%x targetId=%x glbset=%x step=%x", pass, targetid, glb_sel, step);
            if(pass)begin
                trigc_work_fake_spd_ss(.coreid(targetid),.passcnt(step), .failcnt(0),.spdgo(0));
            end
            else begin
                trigc_work_fake_spd_ss(.coreid(targetid),.passcnt(0), .failcnt(step),.spdgo(0));
            end
            if(pass)begin
                if(glb_sel+step >= spd_cfg_h.spd_high)
                    targetsel = spd_cfg_h.spd_high;
                else
                targetsel = glb_sel + step;
            end
	        else begin
                if(glb_sel < step)
                    targetsel = spd_cfg_h.spd_low;
                else
                    targetsel = glb_sel - step >= spd_cfg_h.spd_low? glb_sel - step : spd_cfg_h.spd_low;
            end            
            #2000
            set_spdgo();
            check_spdcore_equal(targetsel, targetid);
            if(pass)begin
                check_spdlog_equal(step, targetid);
            end
            else begin
                check_spdlog_equal(step<<16, targetid);
            end
        end

    `endif //FAKE_PANTERN_RAND

    `uvm_info(get_type_name(), "spd_fake_pantern_seq end", UVM_MEDIUM);

   endtask
endclass



class spd_plltable_pantern_seq extends spd_new_base_seq;
   `uvm_object_utils(spd_plltable_pantern_seq)

   function new(string name="spd_plltable_pantern_seq");
      super.new(name);
   endfunction : new

   task pre_body();
     super.pre_body();

   endtask

   task body();
    int plltable[4];
    real plls[4];
    logic [`SPD_LEN-1:0] spds;
    bit[31:0] actual_plltable;
    super.body();

    `uvm_info(get_type_name(), "spd_plltable_pantern_seq start", UVM_MEDIUM);

    spd_cfg_h.constr_spd_plltable.constraint_mode(0);
    spd_cfg_h.constr_spd_plltable_zero.constraint_mode(1);
    assert(spd_cfg_h.randomize());
    //write plls
    //`ifndef STUB_PLL
        assert(cpm_cfg_h.randomize()); 
        wrc_cpm_plls();
        plls[0] = cpm_cfg_h.pll0_freq;
        plls[1] = cpm_cfg_h.pll1_freq;
        plls[2] = cpm_cfg_h.pll2_freq;
        plls[3] = cpm_cfg_h.pll3_freq;
    // `else
    //     `ifdef WORK_PLL_FPGA_120_120_150_170
    //         plls[0] = 120;
    //         plls[1] = 120;
    //         plls[2] = 150;
    //         plls[3] = 170;
    //     `endif
    // `endif

    uvm_hdl_force("tb_top.RO",1'b1);
    `uvm_info(get_full_name(), $psprintf("Force hard reset situation = %h", 1), UVM_LOW);            
    //wait
    repeat(100)@(posedge spd_vif.clk);
    `RD_REG(speed,plltable,actual_plltable);

    if(actual_plltable[14:0]!==15'd0)begin
        `uvm_info(get_full_name(),$psprintf("speed plltabel rst failed!,actual_plltable=%x",actual_plltable),UVM_MEDIUM);
    end
    uvm_hdl_force("tb_top.RO",1'b0);
    `uvm_info(get_full_name(), $psprintf("Force hard reset situation = %h", 0), UVM_LOW); 
    uvm_hdl_release("tb_top.RO");

    repeat(10)@(posedge spd_vif.clk);
    initRst();

    //write plltable
    assert(spd_cfg_h.randomize()) else $finish;
    plltable = '{spd_cfg_h.plltable_lv1, spd_cfg_h.plltable_lv2, spd_cfg_h.plltable_lv3, spd_cfg_h.plltable_lv4};
    set_spd_plltable(plltable);
    //write spd fifo
    set_th_init(.th_pass(spd_cfg_h.th_pass), .th_fail(spd_cfg_h.th_fail), .th_init(spd_cfg_h.th_init), .th_mssel(spd_cfg_h.th_mssel));
    set_spd_init(.spdlow(1), .spdhigh(`TB_PLL_NUM), .spden(1), .glbsetvld(0), .glbset(1), .ss_sel(2'b01), .ss_pri(1), .ss_pd(10));
    set_spd_fifo(.r_spd(spds), .zero(1'b1));
    //check spd& freq
    check_spd_freq_equal(spds, plltable, plls, `DESIGN_CORE_NUM, 1'b1);

    uvm_hdl_force("tb_top.RO",1'b1);
    `uvm_info(get_full_name(), $psprintf("Force hard reset situation = %h", 1), UVM_LOW);            
    //wait
    repeat(100)@(posedge spd_vif.clk);
    `RD_REG(speed,plltable,actual_plltable);
    
    if(actual_plltable[14:0]!==15'd0)begin
        `uvm_info(get_full_name(),$psprintf("speed plltabel rst failed!,actual_plltable=%x",actual_plltable),UVM_MEDIUM);
    end
    uvm_hdl_force("tb_top.RO",1'b0);
    `uvm_info(get_full_name(), $psprintf("Force hard reset situation = %h", 0), UVM_LOW); 
    uvm_hdl_release("tb_top.RO");

    `uvm_info(get_type_name(), "spd_plltable_pantern_seq end", UVM_MEDIUM);

   endtask
endclass



class spd_passcnt_pantern_seq extends spd_new_base_seq;
   `uvm_object_utils(spd_passcnt_pantern_seq)

   function new(string name="spd_passcnt_pantern_seq");
      super.new(name);
   endfunction : new

   task pre_body();
     super.pre_body();

   endtask

   task body();
        logic [`SPD_LEN-1:0] spds;
        bit [32:0] passcnt = 0;
        bit [32:0] failcnt = 0; 
        bit [32:0] passcnt_exp = 0;
        bit [32:0] failcnt_exp = 0;
        bit [32:0] passcnt_start = 0;
        bit [32:0] failcnt_start = 0; 
        super.body();
        `uvm_info(get_type_name(), "spd_passcnt_pantern_seq start", UVM_MEDIUM);
        spd_cfg_h.constr_spd_global_passfail.constraint_mode(0);
        `ifdef PASSCNT_LOWLOW
            spd_cfg_h.constr_spd_global_passfail_lowlow.constraint_mode(1);
        `endif
        `ifdef PASSCNT_LOWHIGH
            spd_cfg_h.constr_spd_global_passfail_lowhigh.constraint_mode(1);
        `endif
        `ifdef PASSCNT_LOWMAX
            spd_cfg_h.constr_spd_global_passfail_lowmax.constraint_mode(1);
        `endif
        `ifdef PASSCNT_HIGHLOW
            spd_cfg_h.constr_spd_global_passfail_highlow.constraint_mode(1);
        `endif
        `ifdef PASSCNT_HIGHHIGH
            spd_cfg_h.constr_spd_global_passfail_highhigh.constraint_mode(1);
        `endif
        `ifdef PASSCNT_HIGHMAX
            spd_cfg_h.constr_spd_global_passfail_highmax.constraint_mode(1);
        `endif
        `ifdef PASSCNT_MAXLOW
            spd_cfg_h.constr_spd_global_passfail_maxlow.constraint_mode(1);
        `endif
        `ifdef PASSCNT_MAXHIGH
            spd_cfg_h.constr_spd_global_passfail_maxhigh.constraint_mode(1);
        `endif
        `ifdef PASSCNT_MAXMAX
            spd_cfg_h.constr_spd_global_passfail_maxmax.constraint_mode(1);
        `endif
        

        $display("####################################  START SPD REF MODEL ######################################");
        spd_vif.check_enable = 1'b1;

        assert(spd_cfg_h.randomize()) else $finish;
        spd_cfg_h.print();
        
        passcnt_start = spd_cfg_h.passcnt_global_start;
        failcnt_start = spd_cfg_h.failcnt_global_start;


        set_th_init(.th_pass(spd_cfg_h.th_pass), .th_fail(spd_cfg_h.th_fail), .th_init(spd_cfg_h.th_init), .th_mssel(spd_cfg_h.th_mssel));
        set_spd_init(.spdlow(1), .spdhigh(`TB_PLL_NUM), .spden(1), .glbsetvld(0), .glbset(1), .ss_sel(2'b01), .ss_pri(1), .ss_pd(10));
        set_spd_fifo(spds);
        `SET_REG_FIELD(speed, spdlog_reset, spdlog_reset, `ON);
        `PRINT_REG_SETTING(speed,spdlog_reset);
        `UPDATE_REG(speed, spdlog_reset);
        
        #20000
        //initWorkCoreReg();
        @(negedge spd_vif.clk) begin
            uvm_hdl_deposit($psprintf("tb_top.C[%0d].btnode.btc.sys_ctrl.speed.REG_Spdlog_Passcnt[31:0]",0),passcnt_start);
            uvm_hdl_deposit($psprintf("tb_top.C[%0d].btnode.btc.sys_ctrl.speed.REG_Spdlog_Failcnt[31:0]",0),failcnt_start);
        end
 
        if(passcnt_start > failcnt_start)begin
            for(int i = 0; i < `DESIGN_CORE_NUM; i = i + 1) begin
                trigc_work_fake_spd_ss(.coreid(i),.passcnt(1), .failcnt(0));
            end
            for(int i = 0; i < `DESIGN_CORE_NUM; i = i + 1) begin
                trigc_work_fake_spd_ss(.coreid(i),.passcnt(0), .failcnt(1));
            end
            #2000
            `RD_REG(speed, spdlog_passcnt, passcnt);
            `RD_REG(speed, spdlog_failcnt, failcnt);
            `uvm_info("spd_passcnt_pantern_seq", $psprintf("RD Passcnt=%x Failcnt=%x",passcnt,failcnt), UVM_MEDIUM);
            passcnt_exp = (passcnt_start+`DESIGN_CORE_NUM) >= 33'h0FFFF_FFFF ? 32'hFFFF_FFFF : (passcnt_start+`DESIGN_CORE_NUM);
            if(passcnt_exp !== 32'hFFFF_FFFF) begin
                failcnt_exp = (failcnt_start+`DESIGN_CORE_NUM) >= 33'h0FFFF_FFFF ? 32'hFFFF_FFFF : (failcnt_start+`DESIGN_CORE_NUM);
            end
            else begin
                failcnt_exp = failcnt_start;
            end
        end
        else begin
            for(int i = 0; i < `DESIGN_CORE_NUM; i = i + 1) begin
                trigc_work_fake_spd_ss(.coreid(i),.passcnt(0), .failcnt(1));
            end
            for(int i = 0; i < `DESIGN_CORE_NUM; i = i + 1) begin
                trigc_work_fake_spd_ss(.coreid(i),.passcnt(1), .failcnt(0));
            end
            #2000
            `RD_REG(speed, spdlog_passcnt, passcnt);
            `RD_REG(speed, spdlog_failcnt, failcnt);
            `uvm_info("spd_passcnt_pantern_seq", $psprintf("RD Passcnt=%x Failcnt=%x",passcnt,failcnt), UVM_MEDIUM);
            failcnt_exp = (failcnt_start+`DESIGN_CORE_NUM) >= 33'h0FFFF_FFFF ? 32'hFFFF_FFFF : (failcnt_start+`DESIGN_CORE_NUM);
            if(failcnt_exp !== 32'hFFFF_FFFF) begin
                passcnt_exp = (passcnt_start+`DESIGN_CORE_NUM) >= 33'h0FFFF_FFFF ? 32'hFFFF_FFFF : (passcnt_start+`DESIGN_CORE_NUM);
            end
            else begin
                passcnt_exp = passcnt_start;
            end

        end

        `uvm_info("spd_passcnt_pantern_seq", $psprintf("Passcnt_exp=%x Failcnt_exp=%x",passcnt_exp,failcnt_exp), UVM_MEDIUM);
       if(passcnt !== passcnt_exp) begin
            `uvm_error("spd_passcnt_pantern_seq", "Check passcnt failed");
        end
        if(failcnt !== failcnt_exp) begin
            `uvm_error("spd_passcnt_pantern_seq", "Check failcnt failed");
        end
        //trig reset 
        `SET_REG_FIELD(speed, spdlog_reset, spdlog_reset, `ON);
        `PRINT_REG_SETTING(speed,spdlog_reset);
        `UPDATE_REG(speed, spdlog_reset);
        `RD_REG(speed, spdlog_passcnt, passcnt);
        `RD_REG(speed, spdlog_failcnt, failcnt);
        `uvm_info("spd_passcnt_pantern_seq", $psprintf("Passcnt=%x Failcnt=%x",passcnt,failcnt), UVM_MEDIUM);
        if(passcnt !== 32'h0000_0000) begin
            `uvm_error("spd_passcnt_pantern_seq", "Check passcnt failed");
        end
        if(failcnt !== 32'h0000_0000) begin
            `uvm_error("spd_passcnt_pantern_seq", "Check failcnt failed");
        end

        `uvm_info(get_type_name(), "spd_passcnt_pantern_seq end", UVM_MEDIUM);

   endtask
   
endclass
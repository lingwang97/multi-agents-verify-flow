
class spd_monitor extends base_monitor;

  uvm_analysis_port #(spd_item) spd_monitor_main_ap;
  uvm_analysis_port #(spd_coverage_item) frame_collected_port;

  `uvm_component_utils(spd_monitor);

  spd_coverage_item req;
  spd_item spd_item_h;  

  spd_base_refmdl   	refmdl;
  spd_legacy_refmdl 	refmdl_legacy;
  spd_new_refmdl    	refmdl_new;
  spd_low_freq_refmdl   refmdl_low_freq;
  spd_gbp_checker   gbp_checker;
  spd_lfb_refmdl    lfb_refmdl;
  spd_gbp_refmdl    gbp_refmdl;

  virtual spd_if vif;
  virtual work_ctrl_if wc_vif;
  virtual mx2_if mx2_vif;
  virtual cpm_if cpm_vif;
  cpm_pkg::cpm_base_cfg cpm_cfg_h;

  extern task main_traffic();
  extern task collect_coverage();

  function new(string name="spd_monitor" , uvm_component parent=null);
    super.new(name , parent);
    spd_monitor_main_ap = new("spd_monitor_main_ap",this);
    frame_collected_port = new("frame_collected_port",this);

  endfunction
 
   function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual spd_if)::get(this , "" , "spd_vif" ,vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")

    if(!uvm_config_db#(virtual work_ctrl_if)::get(this , "" , "work_ctrl_vif" ,wc_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
    
    if(!uvm_config_db#(virtual mx2_if)::get(this , "" , "mx2_vif" ,mx2_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
    
    if(!uvm_config_db#(virtual cpm_if)::get(this , "" , "cpm_vif" ,cpm_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")

    if (!uvm_config_db #(cpm_pkg::cpm_base_cfg)::get(this, "", "cpm_cfg", cpm_cfg_h))
      `uvm_error("TOP_ENV:ERROR", "Env top_env is missing from config_db")
	`ifndef SPD_REFMDL_OFF 
		`ifdef USE_SPD_REFMDL
			refmdl_legacy = new("spd_legacy_refmdl", this);
			refmdl_new    = new("spd_new_refmdl"   , this);
			refmdl_low_freq =new("spd_low_freq_refmdl",this);

			refmdl_legacy.new_vif("spd_legacy_refmdl", vif, wc_vif, cpm_vif, mx2_vif, cpm_cfg_h);
			refmdl_new.new_vif("spd_new_refmdl", vif, wc_vif, cpm_vif, mx2_vif, cpm_cfg_h);
			refmdl_low_freq.new_vif("spd_low_freq_refmdl", vif, wc_vif, cpm_vif, mx2_vif, cpm_cfg_h);

			refmdl = refmdl_legacy;
		`endif
	`endif
    req = spd_coverage_item::type_id::create("req",this);
    spd_item_h = spd_item::type_id::create("spd_item_h",this);

    gbp_checker=spd_gbp_checker::type_id::create("gbp_checker",this);
    gbp_checker.set_vif(vif);
   
    `ifdef LFB_REFMDL
    lfb_refmdl=spd_lfb_refmdl::type_id::create("lfb_refmdl",this);
    lfb_refmdl.set_vif(vif);
    `endif
    
    `ifdef GBP_REFMDL
    gbp_refmdl=spd_gbp_refmdl::type_id::create("gbp_refmdl",this);
    gbp_refmdl.set_vif(vif,wc_vif);
    `endif

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork
      main_traffic();
      collect_coverage();
    join_none
  endtask  

endclass

task spd_monitor::collect_coverage();
    begin 
    forever
    begin
    @(posedge vif.clk);
    req.card_sel  = vif.card_sel  ;
    frame_collected_port.write(req);   
    end
    end
endtask

task spd_monitor::main_traffic();
    fork
    begin
    forever
      begin
        wait(vif.rst);
        @(posedge vif.clk);
        begin
          spd_item_h.card_sel = vif.card_sel  ;
          spd_monitor_main_ap.write(spd_item_h);
        end
      end
    end

//For Aging_spd trans
    begin
      forever begin
      wait(vif.rst);
        @(posedge vif.clk);
        begin
            vif.self_aging_to_spd=2'b00;
            wait({vif.REG_self_aging_en, vif.global_spd_en, vif.ss_sel}==4'b1101);  
            `uvm_info(get_full_name,"get self_aging wth Spd smp",UVM_MEDIUM);       
            wait({vif.REG_self_aging_en, vif.global_spd_en, vif.ss_sel}==4'b0101);
            `uvm_info(get_full_name,"get self_aging to Spd smp",UVM_MEDIUM);
            vif.self_aging_to_spd=2'b01;
        end
      end
    end

    begin
      forever begin
      wait(vif.rst);
        @(posedge vif.clk);
        begin
            vif.self_aging_to_spd=2'b00;
            wait({vif.REG_self_aging_en, vif.global_spd_en, vif.ss_sel}==4'b1110);  
            `uvm_info(get_full_name,"get self_aging wth Spd ada",UVM_MEDIUM);        
            wait({vif.REG_self_aging_en, vif.global_spd_en, vif.ss_sel}==4'b0110);
            `uvm_info(get_full_name,"get self_aging to Spd ada",UVM_MEDIUM);
            vif.self_aging_to_spd=2'b10;
        end
      end
    end

`ifndef SPD_REFMDL_OFF
  `ifdef USE_SPD_REFMDL
    begin
        wait(vif.check_enable);
        if(vif.ss_sel == 2'b10) begin
            refmdl = refmdl_new;
            refmdl.initMdl();
            `uvm_info("SPD_REF_MDL", "Switch to New Model", UVM_MEDIUM);
        end
        else if(vif.ss_sel == 2'b01) begin
            refmdl = refmdl_legacy;
            refmdl.initMdl();
            `uvm_info("SPD_REF_MDL", "Switch to Legacy Model", UVM_MEDIUM);
        end
		else if(vif.ss_sel == 2'b11) begin
            refmdl = refmdl_low_freq;
            refmdl.initMdl();
            `uvm_info("SPD_REF_MDL", "Switch to low_freq Model", UVM_MEDIUM);
        end
    end


    begin
      forever
      begin
        wait(vif.rst);

        @(posedge vif.mid_clk) begin
          if (vif.selfwork_aging_done==1'b1&&vif.REG_self_aging_en==1'b1) begin
              `uvm_info("SPD_REF_MDL", $psprintf("Get self_aging Pass=%d Id=%d", vif.selfwork_aging_pass, vif.selfwork_aging_coreid), UVM_MEDIUM);
              refmdl.trig_pass(vif.selfwork_aging_done, vif.selfwork_aging_pass, vif.selfwork_aging_coreid);
              refmdl.mark_spd_chg(vif.selfwork_aging_coreid);
          end
        end 

      end
    end

    begin
      forever
      begin
        wait(vif.rst);

        @(posedge vif.check_done) begin
            if(vif.REG_self_aging_en==1'b0)begin
              `uvm_info("SPD_REF_MDL", $psprintf("Get Pass=%d Id=%d", vif.check_pass, vif.check_id), UVM_MEDIUM);
              refmdl.trig_pass(vif.check_done, vif.check_pass, vif.check_id);
              refmdl.mark_spd_chg(vif.check_id);
            end
        end

      end
    end


    begin
      forever begin
        wait(vif.rst);

          @(posedge vif.thsr_spd_go) begin

              `uvm_info(get_full_name(),"SPD_REF_MDL SPD AND MARK CHECK", UVM_MEDIUM);

                for(int i=0; i<`DESIGN_CORE_NUM; i++)fork
                    automatic int coreid = i;
                    refmdl.check_spd_marks(coreid); 
                join_none
                wait fork;
          end    
             

      end
    end

    begin
      forever begin
        wait(vif.rst);
        @(posedge vif.global_set_vld) begin
          @(posedge vif.clk);
          refmdl.set_glbset(vif.global_set, vif.th_init,vif.REG_glb_limit);
          `uvm_info("SPD_REF_MDL", $psprintf("glbset=%d", refmdl.glbset), UVM_MEDIUM);
          `uvm_info("SPD_REF_MDL", $psprintf("Spds=%x", refmdl.spds), UVM_MEDIUM);
        end
      end
    end

    begin
      forever begin
        wait(vif.rst);
        @(posedge vif.global_set_vld) begin	
			for(int i=0;i<`DESIGN_CORE_NUM;i++)begin
				refmdl.ClrPLLStatus(i);
				refmdl.spd_low_tmp[i]=1;
				refmdl.spd_high_tmp[i]=4;
			end
			
			if(vif.global_set<5)begin
				@(posedge vif.clk);
				`uvm_info("SPD_REF_MDL", $psprintf("glbset=%d,jump into work", refmdl.glbset), UVM_MEDIUM);
				for(int i=0;i<`DESIGN_CORE_NUM;i++)begin
					refmdl.do_WORK(i);
				end
				
			end
			else begin
				@(posedge vif.clk);
				`uvm_info("SPD_REF_MDL", $psprintf("glbset=%d,jump into idle", refmdl.glbset), UVM_MEDIUM);
				for(int i=0;i<`DESIGN_CORE_NUM;i++)begin
					refmdl.do_IDLE(i);
				end
			end
        end
      end
    end

    begin
      forever begin
      wait(vif.rst);
      @(vif.last_spd_done) begin
          refmdl.set_spds(vif.th_init);
          `uvm_info("SPD_REF_MDL", $psprintf("Spds_Fifo=%x", refmdl.spds), UVM_MEDIUM);
      end
      end
    end

    begin
      forever begin
      wait(vif.rst);
      @(vif.ssdn_protect, vif.global_spd_high, vif.global_spd_low, vif.global_spd_en,vif.REG_glb_limit) begin
          refmdl.ssdn_protect = vif.ssdn_protect;
          refmdl.spdhigh = vif.global_spd_high;
          refmdl.spdlow = vif.global_spd_low;
          refmdl.glblimit = vif.REG_glb_limit;
          `uvm_info("SPD_REF_MDL", $psprintf("ssdn_protect=%b", refmdl.ssdn_protect), UVM_MEDIUM);
          `uvm_info("SPD_REF_MDL", $psprintf("spdhigh=%d", refmdl.spdhigh), UVM_MEDIUM);
          `uvm_info("SPD_REF_MDL", $psprintf("spdlow=%d", refmdl.spdlow), UVM_MEDIUM);
          `uvm_info("SPD_REF_MDL", $psprintf("glblimit=%d", refmdl.glblimit), UVM_MEDIUM);          
      end
      end
    end

    begin
      forever begin
      wait(vif.rst);
      @(vif.ss_pd,vif.th_dp, vif.th_hp, vif.th_lp,vif.ss_sel,vif.ss_pri,vif.max_rechk) begin
          refmdl.ss_pd = vif.ss_pd;
          refmdl.th_dp = vif.th_dp;
          refmdl.th_hp = vif.th_hp;
          refmdl.th_lp = vif.th_lp;
		  refmdl.ss_sel = vif.ss_sel;
          refmdl.ss_pri = vif.ss_pri;
		  refmdl.max_rechk = vif.max_rechk;
          
          `uvm_info("SPD_REF_MDL", $psprintf("ss_sel=%x", refmdl.ss_sel), UVM_MEDIUM);
          `uvm_info("SPD_REF_MDL", $psprintf("ss_pri=%x", refmdl.ss_pri), UVM_MEDIUM);
          `uvm_info("SPD_REF_MDL", $psprintf("ss_pd=%b", refmdl.ss_pd), UVM_MEDIUM);
          `uvm_info("SPD_REF_MDL", $psprintf("th_hp=%d", refmdl.th_hp), UVM_MEDIUM);
          `uvm_info("SPD_REF_MDL", $psprintf("th_lp=%d", refmdl.th_lp), UVM_MEDIUM);    
		  `uvm_info("SPD_REF_MDL", $psprintf("th_dp=%d", refmdl.th_dp), UVM_MEDIUM);  
		  `uvm_info("SPD_REF_MDL", $psprintf("max_rechk=%x", refmdl.max_rechk), UVM_MEDIUM);    
      end
      end
    end

    begin
      forever begin
      wait(vif.rst);
      @(vif.global_spd_en) begin
          refmdl.set_spden(vif.global_spd_en, vif.th_init);
          `uvm_info("SPD_REF_MDL", $psprintf("spden=%b", refmdl.spden), UVM_MEDIUM);
      end
      end
    end



    begin
      forever begin
      wait(vif.rst);
      @(vif.th_pass, vif.th_fail) begin
          refmdl.th_pass = vif.th_pass;
          refmdl.th_fail = vif.th_fail;
          `uvm_info("SPD_REF_MDL", $psprintf("th_pass=%x", refmdl.th_pass), UVM_MEDIUM);
          `uvm_info("SPD_REF_MDL", $psprintf("th_fail=%x", refmdl.th_fail), UVM_MEDIUM);
      end
      end
    end

    begin
      forever begin
      wait(vif.rst);
      @(vif.th_init, vif.th_ms_sel) begin
          refmdl.th_init = vif.th_init;
          refmdl.th_ms_sel = vif.th_ms_sel;
          `uvm_info("SPD_REF_MDL", $psprintf("th_init=%x", refmdl.th_init), UVM_MEDIUM);
          `uvm_info("SPD_REF_MDL", $psprintf("th_ms_sel=%b", refmdl.th_ms_sel), UVM_MEDIUM);
      end
      end
    end

    begin
      forever begin
      wait(vif.rst);
      @(vif.th_to) begin
          refmdl.th_to = vif.th_to;
          `uvm_info("SPD_REF_MDL", $psprintf("th_to=%x", refmdl.th_to), UVM_MEDIUM);
      end
      end
    end

    begin
      forever begin
      wait(vif.rst);
      @(vif.lv1_th_ms, vif.lv1_th_ms_add, vif.lv2_th_ms, vif.lv2_th_ms_add) begin
        refmdl.lv1thms =      vif.lv1_th_ms;
        refmdl.lv1thmsadd =   vif.lv1_th_ms_add;
        refmdl.lv2thms =      vif.lv2_th_ms;
        refmdl.lv2thmsadd =   vif.lv2_th_ms_add; 
        `uvm_info("SPD_REF_MDL", $psprintf("lv1thms=%x", refmdl.lv1thms), UVM_MEDIUM);
        `uvm_info("SPD_REF_MDL", $psprintf("lv1thmsadd=%b", refmdl.lv1thmsadd), UVM_MEDIUM);
        `uvm_info("SPD_REF_MDL", $psprintf("lv2thms=%x", refmdl.lv2thms), UVM_MEDIUM);
        `uvm_info("SPD_REF_MDL", $psprintf("lv2thmsadd=%b", refmdl.lv2thmsadd), UVM_MEDIUM);
      end
      end
    end

    begin
      forever begin
      wait(vif.rst);
      @(vif.lv3_th_ms, vif.lv3_th_ms_add, vif.lv4_th_ms, vif.lv4_th_ms_add) begin
        refmdl.lv3thms =      vif.lv3_th_ms;
        refmdl.lv3thmsadd =   vif.lv3_th_ms_add;
        refmdl.lv4thms =      vif.lv4_th_ms;
        refmdl.lv4thmsadd =   vif.lv4_th_ms_add; 
        `uvm_info("SPD_REF_MDL", $psprintf("lv3thms=%x", refmdl.lv3thms), UVM_MEDIUM);
        `uvm_info("SPD_REF_MDL", $psprintf("lv3thmsadd=%b", refmdl.lv3thmsadd), UVM_MEDIUM);
        `uvm_info("SPD_REF_MDL", $psprintf("lv4thms=%x", refmdl.lv4thms), UVM_MEDIUM);
        `uvm_info("SPD_REF_MDL", $psprintf("lv4thmsadd=%b", refmdl.lv4thmsadd), UVM_MEDIUM);
      end
      end
    end

    begin
      forever begin
      wait(vif.rst);
      @(vif.gate, vif.plltable_lv0, vif.plltable_lv1, vif.plltable_lv2, vif.plltable_lv3, vif.plltable_lv4, vif.plltable_lv5, vif.plltable_lv6) begin
        refmdl.plltable_lv0 = vif.gate;
        refmdl.plltable_lv1 = vif.plltable_lv0;
        refmdl.plltable_lv2 = vif.plltable_lv1;
        refmdl.plltable_lv3 = vif.plltable_lv2;
        refmdl.plltable_lv4 = vif.plltable_lv3;
        refmdl.plltable_lv5 = vif.plltable_lv4;
        refmdl.plltable_lv6 = vif.plltable_lv5;
        refmdl.plltable_lv7 = vif.plltable_lv6;
        `uvm_info("SPD_REF_MDL", $psprintf("plltable_lv0=%x", refmdl.plltable_lv0), UVM_MEDIUM);
        `uvm_info("SPD_REF_MDL", $psprintf("plltable_lv1=%x", refmdl.plltable_lv1), UVM_MEDIUM);
        `uvm_info("SPD_REF_MDL", $psprintf("plltable_lv2=%x", refmdl.plltable_lv2), UVM_MEDIUM);
        `uvm_info("SPD_REF_MDL", $psprintf("plltable_lv3=%x", refmdl.plltable_lv3), UVM_MEDIUM);
        `uvm_info("SPD_REF_MDL", $psprintf("plltable_lv4=%x", refmdl.plltable_lv4), UVM_MEDIUM);
        `uvm_info("SPD_REF_MDL", $psprintf("plltable_lv2=%x", refmdl.plltable_lv5), UVM_MEDIUM);
        `uvm_info("SPD_REF_MDL", $psprintf("plltable_lv3=%x", refmdl.plltable_lv6), UVM_MEDIUM);
        `uvm_info("SPD_REF_MDL", $psprintf("plltable_lv4=%x", refmdl.plltable_lv7), UVM_MEDIUM);
      end
      end
    end

    begin
      forever begin
      wait(vif.rst);
      @(vif.spdlog_timer, vif.spdlog_timer_on) begin
        refmdl.spdlog_timer = vif.spdlog_timer;
        refmdl.spdlog_timer_on = vif.spdlog_timer_on;
        `uvm_info("SPD_REF_MDL", $psprintf("spdlog_timer=%x", refmdl.spdlog_timer), UVM_MEDIUM);
        `uvm_info("SPD_REF_MDL", $psprintf("spdlog_timer_on=%x", refmdl.spdlog_timer_on), UVM_MEDIUM);
      end
      end
    end

    begin
      forever begin
      wait(vif.rst);
      @(vif.spdlog_reset) begin
        refmdl.spdLog_reset = vif.spdlog_reset;
        `uvm_info("SPD_REF_MDL", $psprintf("spdlog_timer=%x", refmdl.spdlog_timer), UVM_MEDIUM);
      end
      end
    end

     begin
      forever begin
      wait(vif.rst);
      @(posedge vif.timeout_signal) begin
          refmdl.trig_timeout();
      end
      end
    end

    begin
      forever begin
      wait(vif.rst);
      @(vif.spdcore_ovf_dbg_sel, vif.spdcore_ovf_bitmap_clr) begin
        refmdl.spdcore_ovf_dbg_sel = vif.spdcore_ovf_dbg_sel;
        refmdl.spdcore_ovf_bitmap_clr = vif.spdcore_ovf_bitmap_clr;
        `uvm_info("SPD_REF_MDL", $psprintf("mspdcore_ovf_dbg_sel=%x", refmdl.spdcore_ovf_dbg_sel), UVM_MEDIUM);
        `uvm_info("SPD_REF_MDL", $psprintf("spdcore_ovf_bitmap_clr=%x", refmdl.spdcore_ovf_bitmap_clr), UVM_MEDIUM);
      end
      end
    end

    begin
      forever begin
      wait(vif.rst);
      @(posedge vif.spd_fresh_start) begin
        refmdl.sync_spds();
        `uvm_info("SPD_REF_MDL", $psprintf("Get Spd_fresh_start, sync_spds"), UVM_MEDIUM);
      end
      end
    end
    
    begin
      forever begin
      wait(vif.rst);
      @(posedge vif.spd_fresh_done) begin
        if(vif.check_enable == 1'b1)begin
			repeat(2)@(posedge vif.clk);
			refmdl.chk_hash_clk();
        end
        `uvm_info("SPD_REF_MDL", $psprintf("Get Spd_fresh_done, chk_hash_clk"), UVM_MEDIUM);
      end
      end
    end

    `ifndef LOW_FREQ_FIFO_CHECK
    begin
      forever begin
      wait(vif.rst);
      @(posedge vif.ss_state_clr) begin
        refmdl.reset_states();
        `uvm_info("SPD_REF_MDL", "Get ss_state_clr posedge , all state to SS_IDLE", UVM_MEDIUM);
      end
      end
    end
    begin
      forever begin
      wait(vif.rst);
      @(negedge vif.ss_state_clr) begin
        refmdl.set_work_states();
        `uvm_info("SPD_REF_MDL", "Get ss_state_clr negedge, all state to SS_WORK", UVM_MEDIUM);
      end
      end
    end
	`endif


   begin
      forever begin
      wait(vif.rst);
      @(posedge vif.ss2_clr) begin
        refmdl.reset_states();
        `uvm_info("SPD_REF_MDL", "Get ss2_clr posedge , all state to SS_IDLE", UVM_MEDIUM);
      end
      end
    end

    begin
      forever begin
      wait(vif.rst);
      @(negedge vif.ss2_clr) begin
        refmdl.set_work_states();
        `uvm_info("SPD_REF_MDL", "Get ss2_clr negedge, all state to SS_WORK", UVM_MEDIUM);
      end
      end
    end

    begin
      forever begin
      wait(vif.rst);
      @(posedge vif.spd_fresh_done) begin
        for(integer i=0; i<`DESIGN_CORE_NUM; i++)begin
            refmdl.spd_can_down[i]=1'b1;           
        end
        
      end
      end
    end


    begin
		for( int id= 0;id<`DESIGN_CORE_NUM ;id++ )fork
			
			automatic logic[7:0] coreid=id;		
			forever begin
				wait(vif.rst);

				@(posedge vif.fail_trigger[coreid])begin
					refmdl.dh_cnt_fail[coreid]=vif.dh_cnt_fail_onebeat[coreid];
					//`uvm_info("SPD_REF_MDL", $psprintf("====>%20t  coreid=%d,fail trig with fail_cnt=",$realtime(),coreid,refmdl.dh_cnt_fail[coreid]), UVM_MEDIUM);				
				end
			end
		join_none
      
    end



 
      begin
        forever begin
        wait(vif.rst);
        @(posedge vif.mid_clk_gated_ss2) begin
          refmdl.state_change();
        end
        end
      end
    
      begin
        forever begin
        wait(vif.rst);
        @(vif.REG_normal_trig_acc,vif.REG_pass_trig_acc,vif.REG_fail_trig_acc) begin
          refmdl.REG_normal_trig_acc = vif.REG_normal_trig_acc;
          refmdl.REG_pass_trig_acc = vif.REG_pass_trig_acc;
		  refmdl.REG_fail_trig_acc = vif.REG_fail_trig_acc;
          `uvm_info("SPD_REF_MDL", $psprintf("Set Fail_trig_acc=%x", vif.REG_fail_trig_acc), UVM_MEDIUM);
          `uvm_info("SPD_REF_MDL", $psprintf("Set Normal_trig_acc=%x", vif.REG_normal_trig_acc), UVM_MEDIUM);
          `uvm_info("SPD_REF_MDL", $psprintf("Set REG_pass_trig_acc=%x", vif.REG_pass_trig_acc), UVM_MEDIUM);
        end
        end
      end

      begin
        forever begin
        wait(vif.rst);
        @(vif.set_cnt_timer) begin
          refmdl.set_cnt_timer(vif.set_cnt_timer);
          `uvm_info("SPD_REF_MDL", $psprintf("Set cnt_timer[0]=%x", vif.set_cnt_timer), UVM_MEDIUM);
        end
        end
      end

      begin
        forever begin
        wait(vif.rst);
		wait(vif.check_enable);
        @(vif.ss_sel) begin
            if(vif.ss_sel == 2'b10) begin
              refmdl = refmdl_new;
              refmdl.initMdl();
              `uvm_info("SPD_REF_MDL", "Switch to New Model", UVM_MEDIUM);
            end
            else if(vif.ss_sel == 2'b01) begin
               refmdl = refmdl_legacy;
               refmdl.initMdl();
               `uvm_info("SPD_REF_MDL", "Switch to Legacy Model", UVM_MEDIUM);
            end
			else if(vif.ss_sel == 2'b11) begin
				refmdl = refmdl_low_freq;
				refmdl.initMdl();
				`uvm_info("SPD_REF_MDL", "Switch to low_freq Model", UVM_MEDIUM);
        	end
        end
        end
      end

    begin
        forever begin
        wait(vif.rst);
        @(vif.gbp_id) begin
          refmdl.set_gbp_state(vif.gbp_id, vif.gbp_mode, vif.gbp_st);
          `uvm_info("SPD_REF_MDL", $psprintf("Set gbp_state id=%d mode=%d st=%d", vif.gbp_id, vif.gbp_mode, vif.gbp_st), UVM_MEDIUM);
      end
      end
    end

    begin
        forever begin
        wait(vif.rst);
        @(vif.REG_gbp_en) begin
          refmdl.gbp_en = vif.REG_gbp_en;
          `uvm_info("SPD_REF_MDL", $psprintf("REG_gbp_en=%b", vif.REG_gbp_en), UVM_MEDIUM);
      end
      end
    end

    
  `endif
  `endif
//******* lfb *******//
    begin
        forever begin
            repeat(10) @(posedge vif.clk)

            @(negedge vif.REG_lfb_en);
            @(negedge vif.clk)
            @(negedge vif.clk)
            //deal with lfb_memory
                for(int i=0; i<`SORT_DEEP; i++)begin
                    if((vif.lfb_memory_core_id[i] != 8'hff)&&(vif.lfb_memory_times[i] != 0)&&(vif.REG_lfb_broken_core_id != {(`SORT_DEEP){8'hff}})) begin
                        `uvm_error(get_type_name(),"REG_lfb_en to lfb_memeory fail!!!");
                    end
                end
        end
    end

    begin
        forever begin
            repeat(10) @(posedge vif.clk)

            @(negedge vif.REG_lfb_clear);
            @(negedge vif.clk)begin
                //deal with REG_lfb_broken_core_id
                if(vif.REG_lfb_broken_core_id != {(`SORT_DEEP){8'hff}}) begin
                    `uvm_error(get_type_name(),"REG_lfb_clear to RER_lfb_broken_core_id fail!!!");
                end
            end
        end
    end

   join

endtask



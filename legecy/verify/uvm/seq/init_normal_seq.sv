class init_normal_seq extends base_seq;
   virtual top_if   top_vif;
   `uvm_object_utils(init_normal_seq)
    bit[9:0] startchipid = 0;

   //////////////////////////////////////////////////////////////
   // Function Used To "New" The Class
   //////////////////////////////////////////////////////////////
   function new(string name="init_normal_seq");
      super.new(name);
   endfunction : new

   task pre_body();
     super.pre_body();
     if (!uvm_config_db #(virtual interface top_if)::get(m_sequencer, "", "top_vif", top_vif))
      `uvm_error("RO_VIP:ERROR", "VIF top_vif is missing from config_db")

   endtask

   task body();
    super.body();
`ifdef USE_RAL_MODEL
  `ifdef USE_JAMLINK_DRV
    top_vif.chipaddr = `BRD_ADDR;

    this.initRst;
    wrc_cpm_plls;
    //move work_reg_init before initSpd, due to syccnt shall be configure before spd setting
    this.work_reg_init_seq;
    `ifndef SELFCLK
    this.initSpd;
    `else
    this.initSpdZero;
    `endif
    //configure selfclk 
    top_vif.chipaddr = 10'h0;
    this.selfclk_conf;
    top_vif.chipaddr = `BRD_ADDR;
    //wait jlm do fifo empty
    wait(jamlink_vif.do_fifo_empty);
    `uvm_info(get_type_name(), "init over.",UVM_MEDIUM);
  
  `elsif USE_UART_DRV

    `uvm_info(get_type_name(), "enter init_seq with uart_drv.",UVM_MEDIUM);

    if ($value$plusargs("UART_VIP_START_ID=%d", startchipid))
      top_vif.chipaddr = startchipid;
    else
      top_vif.chipaddr = `BRD_ADDR;

    this.initRst;

    if ($test$plusargs("UART_PLL_MODE"))  begin
           cpm_cfg_h.pll0_bypass = 0;
           cpm_cfg_h.pll1_bypass = 0;
           cpm_cfg_h.pll2_bypass = 0;
           cpm_cfg_h.pll3_bypass = 0;
    end


    if (!$test$plusargs("TIMED_AUTOREPORT")) begin //to speed up sim
    `ifndef STUB_PLL
        wrc_cpm_plls;
    `endif
    if ($test$plusargs("UART_PLL_MODE"))  begin
    	uart_pll_mode(.plldiv_int(uart_cfg_h.plldiv_int)); //default is = pll0_freq
    end
    //move work_reg_init before initSpd, due to syccnt shall be configure before spd setting
    this.work_reg_init_seq;
    `ifndef SELFCLK
    this.initSpd;
    `else
    this.initSpdZero;
    `endif
    //configure selfclk 
    this.selfclk_conf;
    end//end of if ($test$plusargs("UART_PLL_MODE")


    `uvm_info(get_type_name(), "init ove rwith uart_drv.",UVM_MEDIUM);

  `else
    this.initRst;
    `ifdef LOCK_TIME_CHECK
    #200000;
    `endif
    wrc_cpm_plls;
    //move work_reg_init before initSpd, due to syccnt shall be configure before spd setting
    this.work_reg_init_seq;
    `ifndef SELFCLK
    this.initSpd;
    `else
    this.initSpdZero;
    `endif
    //configure selfclk 
    this.selfclk_conf;
  `endif
`endif

   endtask
endclass


// ------------------------------------------------------------------
// jamlink init flow
// ------------------------------------------------------------------
class jamlink_init_seq extends base_seq;
   virtual top_if   top_vif;
   `uvm_object_utils(jamlink_init_seq)
    top_env env_h;


   //////////////////////////////////////////////////////////////
   // Function Used To "New" The Class
   //////////////////////////////////////////////////////////////
   function new(string name="jamlink_init_seq");
      super.new(name);
   endfunction : new

   task pre_body();
     super.pre_body();
     if (!uvm_config_db #(virtual interface top_if)::get(m_sequencer, "", "top_vif", top_vif))
      `uvm_error("TOP_VIP:ERROR", "VIF top_vif is missing from config_db")

   endtask

   task body();

	 `ifdef USE_JAMLINK_DRV
     top_vif.chipaddr = `BRD_ADDR;
     initm_jlm();
     initc_chipaddr_jlm();

	 `endif

   endtask


endclass: jamlink_init_seq

class random_core_no_por_seq extends base_seq;
  int core_num;
  int core_pool[`DESIGN_CORE_NUM];
  `uvm_object_utils(random_core_no_por_seq)

  //////////////////////////////////////////////////////////////
  // Function Used To "New" The Class
  //////////////////////////////////////////////////////////////
  function new(string name="random_core_no_por_seq");
    super.new(name);
    core_num=`DESIGN_CORE_NUM;
    for(int i=0;i<`DESIGN_CORE_NUM;i++)begin
      core_pool[i]=i;
    end
  endfunction : new

  task pre_body();
    int id;
    string path;
    string path2 [4];
    string path3 [4];
    bit [122:0] taskstrt_d;
    bit        taskstrt_out;
    bit [3:0]  match_clr_syncq;
    //bit [3:0][7:0]  noncematch_toggle_syncq;
    bit [`ABS_NUM-1:0][3:0]  noncematch_toggle_syncq;
    super.pre_body();

    if($test$plusargs("RANDOM_CORE_POR"))begin
      core_num=$urandom_range(1,`DESIGN_CORE_NUM);
    end
    `uvm_info(get_type_name(),$psprintf("%0d core force to no por",core_num),UVM_MEDIUM);

    core_pool.shuffle();
    
    for(int i=0;i<core_num;i++)begin
      for(int sid=0;sid<`SLICE_NUM;sid++)begin
        if(core_pool[i]>=slice_start[sid] && core_pool[i]<=slice_end[sid])begin
          path=$sformatf("tb_top.C[0].btnode.btc.slice%0d.G_MX2[%0d].mx2.i_rst_n",sid,core_pool[i]);
          uvm_hdl_force(path,1);
          `uvm_info(get_type_name(),$psprintf("core %0d force to no por",core_pool[i]),UVM_MEDIUM);
          break;
        end
      end
    end

    for(int slice_index=0;slice_index<`SLICE_NUM;slice_index++) begin
      for(int coreid=slice_start[slice_index];coreid<=slice_end[slice_index];coreid++) begin
        std::randomize(taskstrt_d,taskstrt_out,match_clr_syncq,noncematch_toggle_syncq) with {
                                                      taskstrt_d              inside {[123'h0:123'h7ffffffffffffffffffffffffffffff]};
                                                      taskstrt_out            inside {[1'b0:1'b1]};
                                                      match_clr_syncq         inside {[4'h0:4'hf]};
                                                      noncematch_toggle_syncq inside {[64'h0:64'hffffff]};
                                                      };
        path2[0] = $sformatf("tb_top.C[0].btnode.btc.slice%0d.G_MX2[%0d].mx2.ctrl.taskstrt_pul_d",slice_index,coreid);
        uvm_hdl_force(path2[0],taskstrt_d);
       // path2[1] = $sformatf("tb_top.C[0].btnode.btc.slice%0d.G_MX2[%0d].mx2.",slice_index,coreid);
       // uvm_hdl_force(path2[1],taskstrt_out);
        path2[2] = $sformatf("tb_top.C[0].btnode.btc.slice%0d.G_MX2[%0d].mx2.ctrl.tail_tx.u_sync_match_clr.SYNCQ",slice_index,coreid);
        uvm_hdl_force(path2[2],match_clr_syncq);
        for(int boostid=0;boostid<`ABS_NUM;boostid++) begin
            //path2[3] = $sformatf("tb_top.C[0].btnode.btc.slice%0d.G_MX2[%0d].mx2.mx2_tail.sha256_stage2.sha256_s2_hash61.gen_sync_noncematch_toggle_pul_vv[%0d].u_sync_noncematch_toggle_pul_0.SYNCQ",slice_index,coreid,boostid);
            path2[3] = $sformatf("tb_top.C[0].btnode.btc.slice%0d.G_MX2[%0d].mx2.ctrl.tail_tx.gen_sync_pul[%0d].u_golden_ticket_sync.SYNCQ",slice_index,coreid,boostid);
            uvm_hdl_force(path2[3],noncematch_toggle_syncq[boostid]);
        end
      end
    end

    begin
      repeat(5) @(posedge work_ctrl_vif.cpm_clk_ctrl);
      for(int slice_index=0;slice_index<`SLICE_NUM;slice_index++) begin
        for(int coreid=slice_start[slice_index];coreid<=slice_end[slice_index];coreid++) begin
          //path3[0] = $sformatf("tb_top.C[0].btnode.btc.slice%0d.G_MX2[%0d].mx2.mx2_head.sha256_stage1.sha256_s1_hash2.taskstrt_d",slice_index,coreid);
          path3[0] = $sformatf("tb_top.C[0].btnode.btc.slice%0d.G_MX2[%0d].mx2.ctrl.taskstrt_pul_d",slice_index,coreid);
          uvm_hdl_release(path3[0]);
         // path3[1] = $sformatf("tb_top.C[0].btnode.btc.slice%0d.G_MX2[%0d].mx2.mx2_head.sha256_stage1.sha256_s1_hash2.taskstrt_out",slice_index,coreid);
         // uvm_hdl_release(path3[1]);
          path3[2] = $sformatf("tb_top.C[0].btnode.btc.slice%0d.G_MX2[%0d].mx2.ctrl.tail_tx.u_sync_match_clr.SYNCQ",slice_index,coreid);
          uvm_hdl_release(path3[2]);
          for(int boostid=0;boostid<`ABS_NUM;boostid++) begin
              path3[3] = $sformatf("tb_top.C[0].btnode.btc.slice%0d.G_MX2[%0d].mx2.ctrl.tail_tx.gen_sync_pul[%0d].u_golden_ticket_sync.SYNCQ",slice_index,coreid,boostid);
              uvm_hdl_release(path3[3]);
          end
        end
      end
    end

    wait(top_vif.mid_rst_n);
    for(int i=0;i<core_num;i++)begin
      for(int sid=0;sid<`SLICE_NUM;sid++)begin
        if(core_pool[i]>=slice_start[sid] && core_pool[i]<=slice_end[sid])begin
          path=$sformatf("tb_top.C[0].btnode.btc.slice%0d.G_MX2[%0d].mx2.i_rst_n",sid,core_pool[i]);
          uvm_hdl_release(path);
          `uvm_info(get_type_name(),$psprintf("core %0d rst_c_n release",core_pool[i]),UVM_MEDIUM);
          break;
        end
      end
    end

  endtask

  task body();
    super.body();
  endtask
endclass : random_core_no_por_seq

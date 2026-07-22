class jamlink_base_seq extends base_seq;
   virtual jamlink_if jamlink_vif;
   virtual top_if   top_vif;
   cgs_spaces   g_spaces;
   `uvm_object_utils(jamlink_base_seq)

   //////////////////////////////////////////////////////////////
   // Function Used To "New" The Class
   //////////////////////////////////////////////////////////////
   function new(string name="jamlink_base_seq");
      super.new(name);
      g_spaces = new();
   endfunction : new

   task pre_body();
     super.pre_body();
     if (!uvm_config_db #(virtual interface jamlink_if)::get(m_sequencer, "", "jamlink_vif", jamlink_vif))
      `uvm_error("RO_VIP:ERROR", "VIF jamlink_vif is missing from config_db")

     if (!uvm_config_db #(virtual interface top_if)::get(m_sequencer, "", "top_vif", top_vif))
      `uvm_error("RO_VIP:ERROR", "VIF top_vif is missing from config_db")

   endtask

   task body();
     super.body();
   endtask

endclass

class jamlink_ecc_inject_seq extends jamlink_base_seq;
   `uvm_object_utils(jamlink_ecc_inject_seq)
   integer step;
   integer i;
   reg [31:0] tmpok;
   reg [31:0] v_targetl_fifo[];
   //////////////////////////////////////////////////////////////
   // Function Used To "New" The Class
   //////////////////////////////////////////////////////////////
   function new(string name="jamlink_ecc_inject_seq");
      super.new(name);
   endfunction : new

   task pre_body();
     super.pre_body();

   endtask

   task body();
     super.body();

     `uvm_info(get_type_name(), "jamlink_ecc_inject_seq start", UVM_MEDIUM);
     fork
     begin
     `ifdef DEF_VELA13
     `uvm_info(get_type_name(), "test part 0", UVM_MEDIUM);
     #2091420;
     uvm_hdl_deposit("tb_top.g_jlm_ecc_enc", 43'hc0_0000_0000);//0ack|7:1ecc|9:8|41:10data
     #7000;
     uvm_hdl_deposit("tb_top.g_jlm_ecc_enc", 43'h40_0000_0000);//0ack|7:1ecc|9:8|41:10data
     `endif
     end 
     begin
     `uvm_info(get_type_name(), "test part 1", UVM_MEDIUM);	 
     uvm_hdl_deposit("tb_top.chipnum",`CHIP_NUM);
     uvm_hdl_deposit("tb_top.g_reg_check_finish", 0);
     #10000;
     uvm_hdl_deposit("tb_top.g_chipaddr", 8'hff);
     top_vif.initm;
     #100000;
     top_vif.initc_chipaddr;
     uvm_hdl_deposit("tb_top.g_chipaddr", 8'h00);
     #100000;
     `uvm_info(get_type_name(), "test part 2", UVM_MEDIUM);
     top_vif.inithc_rst_ri();
     #10000;
     uvm_hdl_deposit("tb_top.g_chipaddr", 8'hff);
     top_vif.initm;
     #100000;
     top_vif.initc_chipaddr;
     `uvm_info(get_type_name(), "test part 3", UVM_MEDIUM);     
     top_vif.inithc_rst_ri();
     #10000;
     uvm_hdl_deposit("tb_top.g_chipaddr", 8'hff);
     top_vif.initm;
     #1000;
     top_vif.initc_chipaddr;
     top_vif.waitm_wb_do_empty;
     top_vif.initm_wr;
     top_vif.initc_chipaddr;
     top_vif.getm_fifo_chipaddr;
     top_vif.initm;
     `uvm_info(get_type_name(), "test part 4", UVM_MEDIUM);    
     for(i = 0; i < top_vif.chipnum; i = i + 1) begin
        uvm_hdl_deposit("tb_top.g_chipaddr", i);
     	top_vif.drvc_reg(1, 1, REG_TSENW_ADDR, 32'h0, top_vif.ld_reg);
     	top_vif.drvc_reg(1, 1, VSENW_ADDR, 32'h0, top_vif.ld_reg);
     end
     `uvm_info(get_type_name(), "test part 6", UVM_MEDIUM);     
     top_vif.flushm_fifo();
     #7000;
     uvm_hdl_deposit("tb_top.g_jlm_ecc_enc", 43'h40_0000_0000);//0ack|7:1ecc|9:8|41:10data
     uvm_hdl_deposit("tb_top.g_jls_ecc_enc", 43'h1000);//0ack|7:1ecc|9:8|41:10data

     step = 0;
     uvm_hdl_deposit("tb_top.g_chipaddr", step);
     top_vif.drvc_reg(1, 1, REG_TARGETL_ADDR, top_vif.tmp, top_vif.ld_reg);
     `uvm_info(get_type_name(), "test part 7", UVM_MEDIUM);     
     for(step = 0; step < top_vif.chipnum; step = step + 1) begin
     `uvm_info(get_type_name(), "test part 8", UVM_MEDIUM);
        uvm_hdl_deposit("tb_top.g_chipaddr", step);
     	uvm_hdl_deposit("tb_top.tmp",(32'habcdef00 | step));
     	top_vif.drvc_reg(1, 1, REG_TARGETL_ADDR, top_vif.tmp, top_vif.ld_reg);
     	top_vif.drvc_reg(0, 0, REG_TARGETL_ADDR, top_vif.tmp, top_vif.ld_reg);
     end
     `uvm_info(get_type_name(), "test part 9", UVM_MEDIUM);
     top_vif.flushm_fifo();
     uvm_hdl_deposit("tb_top.g_jlm_ecc_enc", 43'hc0_0000_0000);//0ack|7:1ecc|9:8|41:10data
     step = step + 1;
     uvm_hdl_deposit("tb_top.g_chipaddr", 0);
     uvm_hdl_deposit("tb_top.tmp",(32'habcdef00 | step));
     top_vif.drvc_reg(1, 1, REG_TARGETL_ADDR, top_vif.tmp, top_vif.ld_reg);
     
     #100000;
     `uvm_info(get_type_name(), "test part 10", UVM_MEDIUM);	 
     uvm_hdl_deposit("tb_top.g_jlm_ecc_enc", 43'h40_0000_0000);//0ack|7:1ecc|9:8|41:10data
     v_targetl_fifo = new[48];
     top_vif.drvc_fifo(0, REG_TARGETL_ADDR, 0, v_targetl_fifo);
     top_vif.drvc_fifo(0, REG_TARGETL_ADDR, 48,v_targetl_fifo);
     top_vif.drvc_reg(1, 1, REG_TARGETL_ADDR, top_vif.tmp, top_vif.ld_reg);
     uvm_hdl_deposit("tb_top.tmp",(32'h12345678));
     `uvm_info(get_type_name(), "test part 11", UVM_MEDIUM);
     top_vif.drvc_reg(1, 1, REG_TARGETL_ADDR, top_vif.tmp, top_vif.ld_reg);
     top_vif.drvc_reg(0, 1, REG_TARGETL_ADDR, top_vif.tmp, top_vif.ld_reg);
     top_vif.flushm_fifo();

     uvm_hdl_deposit("tb_top.g_jlm_ecc_enc", 43'h600);//
     `uvm_info(get_type_name(), "test part 12", UVM_MEDIUM);
     top_vif.drvc_reg(1, 1, REG_TARGETL_ADDR, top_vif.tmp, top_vif.ld_reg);
     #100000;
     uvm_hdl_deposit("tb_top.g_jlm_ecc_enc", 43'h0);

     uvm_hdl_deposit("tb_top.g_jlm_ecc_enc", 43'h40_0000_0600);//0ack|7:1ecc|9:8|41:10data
 
     top_vif.drvc_reg(1, 1, REG_TARGETL_ADDR, top_vif.tmp, top_vif.ld_reg);
     #100000;
      uvm_hdl_deposit("tb_top.g_jlm_ecc_enc", 43'h0);
     `uvm_info(get_type_name(), "test part 13", UVM_MEDIUM);
     #100000;
     top_vif.flushm_fifo();
     tmpok = 32'h12345678;
     top_vif.drvc_reg(1, 1, REG_TARGETL_ADDR, tmpok, top_vif.ld_reg);
     top_vif.drvc_reg(0, 1, REG_TARGETL_ADDR, tmpok, top_vif.ld_reg);
     top_vif.flushm_fifo();
     end
     join
     `uvm_info(get_type_name(), "jamlink_ecc_inject_seq end", UVM_MEDIUM);

   endtask
endclass

class jamlink_ecc_test_seq extends jamlink_base_seq;
   `uvm_object_utils(jamlink_ecc_test_seq)
   reg [31:0] qqport;
   integer i ,j;
   reg [31:0] tmp;
   //////////////////////////////////////////////////////////////
   // Function Used To "New" The Class
   //////////////////////////////////////////////////////////////
   function new(string name="jamlink_ecc_test_seq");
      super.new(name);
   endfunction : new

   task pre_body();
     super.pre_body();

   endtask

   task body();
     super.body();

     `uvm_info(get_type_name(), "jamlink_ecc_test_seq start", UVM_MEDIUM);
     top_vif.initc_glb();
     
     top_vif.testc_jls_ecc(.chipid(0));
     top_vif.testc_jls_ecc(.chipid(1));
     top_vif.testc_jls_ecc(.chipid(2));
     `uvm_info(get_type_name(), "jamlink_ecc_test_seq end", UVM_MEDIUM);

   endtask
endclass

class jamlink_fsm_inject_seq extends jamlink_base_seq;
   `uvm_object_utils(jamlink_fsm_inject_seq)
   integer i;
   //////////////////////////////////////////////////////////////
   // Function Used To "New" The Class
   //////////////////////////////////////////////////////////////
   function new(string name="jamlink_fsm_inject_seq");
      super.new(name);
   endfunction : new

   task pre_body();
     super.pre_body();

   endtask

   task body();
     super.body();

     `uvm_info(get_type_name(), "jamlink_fsm_inject_seq start", UVM_MEDIUM);
     top_vif.inithc_rst_ri();
     uvm_hdl_deposit("tb_top.g_rsp_inject_err", 0);
     top_vif.setc_spd_fifo(`TB_PLL_NUM+1);
     top_vif.initc_cpm_mux();
     g_spaces.m_speed_ths.open_default();
     g_spaces.m_speed_ths.th0.data.th_pass = 'hf000;
     g_spaces.m_speed_ths.th0.data.th_fail = 'he000;
     g_spaces.m_speed_ths.close_th_to();
     g_spaces.m_speed_ths.close_mssel();
     top_vif.wrc_speed_ths(g_spaces.m_speed_ths);
     
     top_vif.dpr_wrc_work_h2ltime(.l2h_nosame(0), .spd_setup(1), .l2h_flip(3), .syc_cnt(`DESIGN_CORE_NUM));
     //wd_Pll(.Pll0(50),.Pll1(75),.Pll2(100),.Pll3(125),.Pll4(150),.Pll5(200),.Pll6(250));
     top_vif.wrc_cpm_plls();
     top_vif.setc_work_rolltime(10000);//1000
     top_vif.setc_work_targets_all1();
     
     top_vif.dpr_wrc_work_cfg(.note_mode(2'b00),.ft_need(0),.ft_en(0),.cover_en(0),.rst_fifo(1),.syn_rsp(1),.roll_en(0),.ft_st(0),.chk_en(1),.mask(8'hff));
     top_vif.dpr_setc_speed_ssctrl(.ssdn_pro(0), .trunk_clk_en(0),.spd_high(`TB_PLL_NUM-1),.spd_low(0),.spd_en(1),.glb_set_vld(1),.glb_set(2));
     
     top_vif.testc_core(.i_from(0),.i_to(0),.ntime_mod(3),.mode(0),.tbase(0),.check(1));
     top_vif.initlc_rst_ri();
     #10000;
     
     `ifndef PL_SIM 
     top_vif.loadv_tbtop_blockheader();
     for(i = 0; i < 4; i = i + 1) begin
     	@(posedge top_vif.cps_jls_pin_ci);
        uvm_hdl_deposit($psprintf("tb_top.C[%0d].btnode.btc.sys_ctrl.jls.cur_state",0),i);
     	@(posedge top_vif.cps_jls_pin_ci);
        uvm_hdl_deposit($psprintf("tb_top.C[%0d].btnode.btc.sys_ctrl.jls.cur_state",0),i);
     	@(posedge top_vif.cps_jls_pin_ci);
        uvm_hdl_deposit($psprintf("tb_top.C[%0d].btnode.btc.sys_ctrl.jls.cur_state",0),i);
     	top_vif.drvc_reg(1, 1, REG_TARGETL_ADDR, 32'hffffffff | i, top_vif.ld_reg);
     	top_vif.drvc_reg(0, 1, REG_TARGETL_ADDR, 32'hffffffff | i, top_vif.ld_reg);
     	top_vif.testc_core(.i_from(0),.i_to(`DESIGN_CORE_NUM),.ntime_mod(0),.mode(0),.tbase(0),.check(1));
     end
     `endif

     `uvm_info(get_type_name(), "jamlink_fsm_inject_seq end", UVM_MEDIUM);

   endtask
endclass

`include "jamlink_new_seq.sv"

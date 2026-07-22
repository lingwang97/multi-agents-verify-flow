
typedef global_pkg::UART_CMD UART_CMD;
// uart vip broadcast read data pattern;
typedef uvm_reg_data_t uart_brd_data_packet [`CHIP_NUM];

import reg_mdl_pkg::*;

class base_seq extends uvm_sequence;
    top_env env_h;
    virtual top_if top_vif;
    virtual cpm_if cpm_vif;
    virtual work_ctrl_if work_ctrl_vif;
    virtual mx2_if mx2_vif;
    virtual rst_if rst_vif;
    virtual jls_if jls_vif;
    virtual efuse_if efuse_vif;
    virtual jamlink_if jamlink_vif;
`ifdef VIP
    virtual svt_uart_if dte_vif;
`endif

    virtual uart_if uart_vif;
    virtual spd_if spd_vif;
    virtual io_if io_vif;
    virtual selfclk_if selfclk_vif;
    cpm_pkg::cpm_base_cfg   cpm_cfg_h;
    selfclk_pkg::selfclk_base_cfg selfclk_cfg_h;
    uart_pkg::uart_base_cfg   uart_cfg_h;

    work_ctrl_pkg::work_ctrl_base_cfg work_ctrl_cfg_h;
    spd_pkg::spd_base_cfg spd_cfg_h;

    work_ctrl_pkg::work_ctrl_gold_work_pool m_work_pool;
    //declare a list of works that will send to chip
    work_ctrl_pkg::work_ctrl_mine_work m_work_list[*];
    //ral model
	  RAL_PKG::ral_gen_main 		ral;
	  // Register model variables:
	  uvm_status_e status;
	  rand uvm_reg_data_t data;
    uvm_table_printer _printer;

`ifndef VIP
   uart_sequence_item 	uart_tr;
   uart_init_packet 	uart_init_tr;
`endif



   `uvm_object_utils(base_seq)
   //////////////////////////////////////////////////////////////
   // Function Used To "New" The Class
   //////////////////////////////////////////////////////////////
   function new(string name="base_seq");
      super.new(name);
      m_work_pool = new();
      m_work_pool.setDatFile();
      _printer = new();
      // usage:
      // ral.reg_uart_cfg1.print(_printer);
      // s = reg.sprint(_printer);
   endfunction : new

   task pre_body();

    `ifdef FPGA_SYN
      //uvm_hdl_deposit("tb_top.C[0].btnode.btc.sys_ctrl.crg.pll_clk_div_i", 1'b0);
    `endif
     if (!uvm_config_db #(virtual interface top_if)::get(m_sequencer, "", "top_vif", top_vif))
      `uvm_error("TOP_VIF:ERROR", "VIF top_vif is missing from config_db")

     if (!uvm_config_db #(top_env)::get(m_sequencer, "", "top_env", env_h))
      `uvm_error("TOP_ENV:ERROR", "Env top_env is missing from config_db")

     if (!uvm_config_db #(cpm_pkg::cpm_base_cfg)::get(m_sequencer, "", "cpm_cfg", cpm_cfg_h))
      `uvm_error("CPM_CFG:ERROR", "CFG cpm_cfg is missing from config_db")

     if (!uvm_config_db #(virtual interface cpm_if)::get(m_sequencer, "", "cpm_vif", cpm_vif))
      `uvm_error("CPM_VIF:ERROR", "VIF cpm_vif is missing from config_db")

     if (!uvm_config_db #(virtual interface mx2_if)::get(m_sequencer, "", "mx2_vif", mx2_vif))
      `uvm_error("MX2_VIF:ERROR", "VIF mx2_vif is missing from config_db")

     if (!uvm_config_db #(virtual interface rst_if)::get(m_sequencer, "", "rst_vif", rst_vif))
      `uvm_error("TOP_VIF:ERROR", "VIF rst_vif is missing from config_db")

     if (!uvm_config_db #(virtual interface jamlink_if)::get(m_sequencer, "", "jamlink_vif", jamlink_vif))
      `uvm_error("TOP_VIF:ERROR", "VIF jamlink_vif is missing from config_db")

    if (!uvm_config_db #(virtual interface jls_if)::get(m_sequencer, "", "jls_vif", jls_vif))
      `uvm_error("TOP_VIF:ERROR", "VIF jls_vif is missing from config_db")

`ifdef VIP
     if (!uvm_config_db #(virtual interface svt_uart_if)::get(m_sequencer, "", "dte_vif", dte_vif))
      `uvm_error("UART_VIF:ERROR", "VIF uart_vif is missing from config_db")
`endif
     if (!uvm_config_db #(virtual interface uart_if)::get(m_sequencer, "", "uart_vif", uart_vif))
      `uvm_error("UART_VIF:ERROR", "VIF uart_vif is missing from config_db")
     if (!uvm_config_db #(uart_pkg::uart_base_cfg)::get(m_sequencer, "", "uart_cfg", uart_cfg_h))
      `uvm_error("UART_CFG:ERROR", "CFG uart_cfg is missing from config_db")

     if (!uvm_config_db #(virtual interface work_ctrl_if)::get(m_sequencer, "", "work_ctrl_vif", work_ctrl_vif))
      `uvm_error("TOP_VIF:ERROR", "VIF work_ctrl_vif is missing from config_db")

     if (!uvm_config_db #(work_ctrl_pkg::work_ctrl_base_cfg)::get(m_sequencer, "", "work_ctrl_cfg", work_ctrl_cfg_h))
      `uvm_error("TOP_ENV:ERROR", "Env top_env is missing from config_db")

     if (!uvm_config_db #(virtual interface spd_if)::get(m_sequencer, "", "spd_vif", spd_vif))
      `uvm_error("TOP_VIF:ERROR", "VIF spd_vif is missing from config_db")

     if (!uvm_config_db #(virtual interface io_if)::get(m_sequencer, "", "io_vif", io_vif))
      `uvm_error("TOP_VIF:ERROR", "VIF io_vif is missing from config_db")

     if (!uvm_config_db #(spd_pkg::spd_base_cfg)::get(m_sequencer, "", "spd_cfg", spd_cfg_h)) begin
      `uvm_info("TOP_ENV:INFO", "Env spd_base_cfg is missing from config_db, using default", UVM_MEDIUM)
       spd_cfg_h = new();
     end

     if (!uvm_config_db #(virtual interface selfclk_if)::get(m_sequencer, "", "selfclk_vif", selfclk_vif))
      `uvm_error("TOP_VIF:ERROR", "VIF selfclk_vif is missing from config_db")

     if (!uvm_config_db #(selfclk_pkg::selfclk_base_cfg)::get(m_sequencer, "", "selfclk_cfg", selfclk_cfg_h)) begin
      `uvm_info("TOP_ENV:INFO", "Env selfclk_base_cfg is missing from config_db, using default", UVM_MEDIUM)
       selfclk_cfg_h = new();
     end

     if (!uvm_config_db #(virtual interface efuse_if)::get(m_sequencer, "", "efuse_vif", efuse_vif))
      `uvm_error("RO_VIF:ERROR", "VIF efuse_vif is missing from config_db")

     ral = env_h.ral;
     super.pre_body();

   endtask

   task body();
    //  super.body();

   endtask

    task getc_cpm_pll_freq(input int index, output real p_cpm_pll_freq);
        real v_time;
        real v_prod;

        @(posedge cpm_vif.cpm_pll_clk[index]);
        v_time = $realtime;
        @(posedge cpm_vif.cpm_pll_clk[index]);
        v_prod = $realtime - v_time;

        p_cpm_pll_freq = 1000.000 / v_prod;
    endtask

    task getc_cpm_vco_freq(input int index, output real p_cpm_pll_freq);
        real v_time;
        real v_prod;

        @(posedge cpm_vif.cpm_vco_clk[index]);
        v_time = $realtime;
        @(posedge cpm_vif.cpm_vco_clk[index]);
        v_prod = $realtime - v_time;

        p_cpm_pll_freq = 1000.000 / v_prod;
    endtask

function bit chkc_realdata_diffequal(input real p_realdata_act, input real p_realdata_exp, input real p_max_diffrate=0.01);
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

function bit chkc_cpm_pll_freq_equal(input real p_act_freq, input real p_exp_freq, input real p_diff_rate=0.01);
    return chkc_realdata_diffequal(p_act_freq, p_exp_freq, p_diff_rate);
endfunction

function bit chkc_cpm_pll_freqs_equal(input real p_actual_freqs[`PLL_NUM-1:0], input real p_expect_freqs[`PLL_NUM-1:0], input real p_diff_rate=0.01);
    bit v_result;

    v_result = 1'b1;
    for(int i = 0 ; i < `TB_PLL_NUM ; i++) begin
        if( ~chkc_cpm_pll_freq_equal(p_actual_freqs[i], p_expect_freqs[i], p_diff_rate) ) begin
            $display("pll frequency check failed! expect_freq = %fMhz, actual_freq = %fMhz", p_expect_freqs[i], p_actual_freqs[i]);
            v_result = 1'b0;
        end
    end

    return v_result;
endfunction

task chkc_cpm_pll_freq(input int p_pll_index, input logic [31:0] p_freq);
    real v_act_freq;
    real v_exp_freq;

`ifdef STUB_PLL_FREQ_CHKER
    return;
`endif

`ifdef STUB_PLL
    return;
`endif

    $display($time, "uvm pll%1d freq checking...", p_pll_index);

`ifndef STUB_PLL
    v_exp_freq = p_freq * 1.000;
`else
        `ifndef FPGA_SYN
    v_exp_freq = 24 * 1.000;
        `else
    v_exp_freq = `FPGA_XCLK_FREQ * 1.000;
        `endif
`endif
    getc_cpm_pll_freq(p_pll_index, v_act_freq);

    if( ~chkc_cpm_pll_freq_equal(v_act_freq, v_exp_freq,0.02) ) begin
        $display("uvm pll[%1d] frequency check failed! expect_freq = %fMhz, actual_freq = %fMhz", p_pll_index, v_exp_freq, v_act_freq);
        $finish;
    end
    else begin
        $display("uvm pll[%1d] frequency check pass! expect_freq = %fMhz, actual_freq = %fMhz", p_pll_index, v_exp_freq, v_act_freq);
    end
endtask

task chkc_cpm_vco_freq(input int p_pll_index, input logic [31:0] p_freq);
    real v_act_freq;
    real v_exp_freq;

`ifdef STUB_PLL_FREQ_CHKER
    return;
`endif

`ifdef STUB_PLL
    return;
`endif

    $display($time, " pll%1d freq checking...", p_pll_index);

`ifndef STUB_PLL
    v_exp_freq = p_freq * 1.000;
`else
        `ifndef FPGA_SYN
    v_exp_freq = 24 * 1.000;
        `else
    v_exp_freq = `FPGA_XCLK_FREQ * 1.000;
        `endif
`endif
    getc_cpm_vco_freq(p_pll_index, v_act_freq);

    if( ~chkc_cpm_pll_freq_equal(v_act_freq, v_exp_freq,0.02) ) begin
        $display("pll[%1d] frequency check failed! expect_freq = %fMhz, actual_freq = %fMhz", p_pll_index, v_exp_freq, v_act_freq);
        $finish;
    end
    else begin
        $display("pll[%1d] frequency check pass! expect_freq = %fMhz, actual_freq = %fMhz", p_pll_index, v_exp_freq, v_act_freq);
    end
endtask

task cal_core_clk_prod(input int coreid, output real prod);
begin
  fork: fork_cal_core_clk_prod
    begin
      automatic real f0,f1;
      @(posedge mx2_vif.mx2_clk[coreid]);
      f0=$realtime;
      @(posedge mx2_vif.mx2_clk[coreid]);
      f1=$realtime;
      prod=f1-f0;
    end
    begin
      #200ns;
      prod = 0.0;
    end
  join_any
  disable fork_cal_core_clk_prod;

end
endtask: cal_core_clk_prod

task cal_core_self_clk_prod(input int coreid, output real prod);
//fork
//begin //1.1
  fork
    begin
      real f0,f1;
      @(posedge selfclk_vif.mx2_clk_self[coreid]);
      f0=$realtime;
      @(posedge selfclk_vif.mx2_clk_self[coreid]);
      f1=$realtime;
      prod=f1-f0;
      //#200ns;
    end
    begin
      #200ns;
      prod = 0.0;
    end
  join_any
  //disable fork;
  //$display("Cal hash clk done coreid=%d prod=%f", coreid, prod);

//end//1.1
//join_none

endtask: cal_core_self_clk_prod

task cal_core_hash_clk_prod(input int coreid, output real prod);
//fork
//begin //1.1
  fork
    begin
        real f0,f1;
        `ifndef PL_SIM
            @(posedge mx2_vif.mx2_hash_clk[coreid]);
            f0=$realtime;
            @(posedge mx2_vif.mx2_hash_clk[coreid]);
            f1=$realtime;
        `else
            @(posedge spd_vif.mx2_hash_clk[coreid]);
            f0=$realtime;
            @(posedge spd_vif.mx2_hash_clk[coreid]);
            f1=$realtime;       
        `endif
        prod=f1-f0;
    end
    begin
      #200ns;
      prod = 0.0;
    end
  join_any
  //disable fork;
  //$display("Cal hash clk done coreid=%d prod=%f", coreid, prod);
  `uvm_info(get_type_name(), $psprintf("The clk hash prod = %0d",prod), UVM_NONE);

//end//1.1
//join_none

endtask: cal_core_hash_clk_prod

task cal_all_core_clk_prod(output real prod[`DESIGN_CORE_NUM]);
  //bit [`DESIGN_CORE_NUM-1:0] prod_check=0;
  $display( $time, "Begin cal all core hash clk");
  fork begin
    for(int i=0;i<`DESIGN_CORE_NUM;i++)begin//for
        fork
            automatic int index=i;
            cal_core_hash_clk_prod(index, prod[index]);
        join_none
    end//for
    wait fork;
  end
  join
    $display($time, "All core hash clk cal done");

endtask


task  work_ctrl_generate(int coreid, ref work_ctrl_mine_work m_work);

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

       //workAssignPreConfig;
        `SET_REG_FIELD(work, cfg, cfg_rollen, `ON);
        `UPDATE_REG(work, cfg);

        workAssign(m_work);

        checkRollNonceReturnTimeout(m_work.ntime);
        checkNonceCorrect(m_work);

endtask

`include "base_jamlink_seq.sv"
`include "base_uart_seq.sv"
`ifdef USE_RAL_MODEL
`include "base_new_seq.sv"
`include "base_rst_seq.sv"
`include "base_cpm_seq.sv"
`include "base_selfclk_seq.sv"
`include "base_pvt_seq.sv"
`include "base_fpga_seq.sv"
`include "base_spd_gbp_seq.sv"
`include "base_spd_lfb_seq.sv"
`include "base_spd_seq.sv"
`endif
`include "base_efuse_seq.sv"
`include "base_io_seq.sv"
`include "base_reg_seq.sv"
`ifdef VIP
`include "base_uart_seq.sv"
`endif

endclass


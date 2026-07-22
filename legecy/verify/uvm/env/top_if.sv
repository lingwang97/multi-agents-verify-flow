
interface top_if ();

   import uvm_pkg::*;
   
 //  string       report_id = "top_if";
//add chipaddr for jamlink driver
//chipaddr is also for uart driver
logic [9:0] chipaddr;

logic [39:0] HEADER       ;

logic cpft_print_flag;

logic jls_mid_clk;
logic jls_pin_ci;
logic clk;
logic rst;
logic RO;
logic clk_spd;
logic ri_rst_f_n;
//add by haiyang
logic mid_rst_f_n;
logic mid_rst_n;
logic mid_pin_ri;
logic xclk;

logic [1:0] apb_state_cur;
logic [2:0] jls_cur_state;
logic ri_rst_pin_ri;
logic ri_rst_n;
logic [7:0] spdcnt_st_num;
logic cps_sysc_to_io_s_xclk_chips[`CHIP_NUM];
logic cps_sysc_to_io_n_xclk_chips[`CHIP_NUM];
logic work_z_NonceFlip;
logic lat_mid;
logic lat_head;

//array prepared
logic [7:0] s_selfclk[`SLICE_NUM];
logic s_core_clk_sel[`SLICE_NUM];

logic [31:0] core_config0[`DESIGN_CORE_NUM];
logic [31:0] core_config1[`DESIGN_CORE_NUM];

logic [`DESIGN_CORE_NUM-1:0] core_clk_en1;
logic is_REG_Spdlog_Timer;
logic speed_midclk;
logic spd_fresh_done;
logic [1440-1:0] data_tp[`DATA_TP_LEN-1:0];
logic [1:0] spd_cur_state;
logic [7:0] spdcore_cnt;
logic cps_slice_syc_in[`SLICE_NUM];
logic [`CHIP_NUM-1:0] btn_to;
logic cpm_rclk[`TB_PLL_NUM];
logic btc_to;
logic cpm_trunk_clk[`TB_PLL_NUM];
logic [31:0] cpm_change_cnt[`TB_PLL_NUM];
logic xclk_clksel [`TB_PLL_NUM];
logic [15:0] marks[`DESIGN_CORE_NUM];
logic [31:0] g_rsp_inject_err;

logic timer_stop;
logic send_work_busy;
logic core_cfg_busy;
logic [`CHIP_NUM*`CHIPID_LEN-1:0] gaddr;


reg [15:0] ro_golden_data[1023:0];
reg [15:0] ro_max_golden_data[1023:0];
reg [15:0] ro_min_golden_data[1023:0];

reg [19:0] ro_period_golden_data[`RO_SEL_NUM-1:0];
reg [19:0] ro_period_min_golden_data[`RO_SEL_NUM-1:0];
reg [19:0] ro_period_max_golden_data[`RO_SEL_NUM-1:0];

   `include "top_if_pc.sv"

   logic REG_UART_CHECK_MODE_SEL;
   logic[3:0] uart_state;
   logic[3:0] uart_dirx_state[`CHIP_NUM];
   logic [31:0] noncebuf_data_o [(`CHIP_NUM-1):0][379:0];
   logic [31:0] reg_data_o [`CHIP_NUM-1:0][400:0];
   bit uart_init_16rx;
   bit uart_vip_cts_n;
   
endinterface : top_if

interface gls_dff_yx_check_if(input Y,input out_temp,input rst_n);
  import uvm_pkg::*;

  wire out_temp_d;

  assign #1ps out_temp_d = out_temp;

  always@(Y iff rst_n===1'b1) begin
    if(Y==='x && (out_temp_d===1'b1 || out_temp_d===1'b0)) begin
      `uvm_error("gls_dff_yx_check_if",$sformatf("DFF_YX_CHECK_ERROR,(%m), Y=%0b,out_temp=%0b",Y,out_temp));
    end
  end

endinterface

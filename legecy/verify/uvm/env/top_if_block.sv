
interface top_if ();

   import uvm_pkg::*;
   
 //  string       report_id = "top_if";

logic clk;
logic rst;
logic RO;
logic [7:0] g_chipaddr;
logic [31:0] ld_reg;
logic [31:0] g_rsp_inject_err;
logic [3:0] tb_spd_i [`DESIGN_CORE_NUM-1:0];
logic cps_rst_ri_trunk_ri;
logic cps_xclk;

logic cps_midclk;
logic clk_spd;
logic ri_rst_f_n;
logic [1:0] apb_state_cur;
logic [2:0] jls_cur_state;
logic ri_rst_pin_ri;
logic ri_rst_n;
logic [7:0] spdcnt_st_num;
logic [`CHIPID_LEN*`CHIP_NUM-1:0] gaddr;
logic [7:0] chipnum;
logic [31:0] dif [1023:0];
logic [127:0] g_chip0_note;
logic [127:0] g_chip1_note;
logic [127:0] g_chip2_note;
logic [127:0] g_chip3_note;
logic cps_sysc_to_io_s_xclk_chips[`CHIP_NUM];
logic cps_sysc_to_io_n_xclk_chips[`CHIP_NUM];
logic cps_mx2_pll_clk_div2_en;
logic cps_jls_pin_ci;
logic [31:0] tmp;
logic [1:0] cps_jlm_cur_state;
logic z_NonceFlip;
logic work_z_NonceFlip;
logic z_dbg_spdbusy;
logic z_dbg_w_req;
logic z_dbg_r_req;
logic raw_core_vld;
logic cps_io_to;
logic lat_mid;
logic lat_head;
logic my_round_start;
logic xclk_div;
logic to_io_s_xclk;
logic xclk;
logic [`CHIP_NUM:0]   real_cki;
logic sysctrl_xclk_delay;
logic reg_cko_inv;
logic pad_to_ie;
logic pad_to_oen;
logic pad_sel_ie;
logic pad_sel_oen;
logic pad_dsel_ie;
logic pad_dsel_oen;
logic pad_fb_ie;
logic pad_fb_oen;
logic [`CHIP_NUM:0]   fb_btc;

//array prepared
logic [7:0] s_selfclk[`SLICE_NUM];
logic s_core_clk_sel[`SLICE_NUM];

logic [31:0] core_config0[`DESIGN_CORE_NUM];
logic [31:0] core_config1[`DESIGN_CORE_NUM];

logic [`DESIGN_CORE_NUM-1:0] core_clk_en1;
logic [15:0] cps_speed_marks[`DESIGN_CORE_NUM];
logic [15:0] cps_speedlog_pass[`DESIGN_CORE_NUM];
logic [15:0] cps_speedlog_fail[`DESIGN_CORE_NUM];
logic is_REG_Spdlog_Timer;
logic speed_midclk;
logic spd_fresh_done;
logic g_note_pending;
logic mx2_sh0_clk;
logic mx2_sh1_clk;
logic mx2_sh2_clk;
logic mx2_sh15_clk;
logic mx2_sh30_clk;
logic mx2_sh45_clk;
logic mx2_sh100_clk;
logic mx2_sh130_clk;
logic [1440-1:0] data_tp[`DATA_TP_LEN-1:0];
logic [1:0] spd_cur_state;
logic [7:0] spdcore_cnt;
logic cps_slice_syc_in[`CH_NUM];
logic [`CHIP_NUM-1:0] btn_to;
logic [6:0] cps_nonce_cnt;
logic cpm_rclk[`TB_PLL_NUM];
logic btc_to;
logic cpm_trunk_clk[`TB_PLL_NUM];
logic [31:0] cpm_change_cnt[`TB_PLL_NUM];
logic xclk_clksel [`TB_PLL_NUM];
logic [15:0] marks[`DESIGN_CORE_NUM];

logic timer_stop;
logic send_work_busy;
logic core_cfg_busy;
logic [31:0] load [1023:0];


reg [15:0] ro_golden_data[1023:0];
reg [15:0] ro_max_golden_data[1023:0];
reg [15:0] ro_min_golden_data[1023:0];

reg [19:0] ro_period_golden_data[`RO_SEL_NUM-1:0];
reg [19:0] ro_period_min_golden_data[`RO_SEL_NUM-1:0];
reg [19:0] ro_period_max_golden_data[`RO_SEL_NUM-1:0];

`include "top_if_pc.sv"
   
endinterface : top_if

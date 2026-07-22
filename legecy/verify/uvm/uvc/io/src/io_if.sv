interface io_if ();

   import uvm_pkg::*;
   import global_pkg::*;
import reg_addr::*;   
   string       report_id = "cal_adc_if";

   logic checks_enable; //always@(*) checks_enable = IF_CHECKS_ENABLE["io_if"];
   logic coverage_enable; //always@(*) coverage_enable = IF_COVERAGE_ENABLE["io_if"];

   initial begin
      IF_CHECKS_ENABLE["io_if"] = 1'b1;     //initially on
      IF_COVERAGE_ENABLE["io_if"] = 1'b1;   //initially on
   end


   logic clk;
   logic rst;
   logic card_sel;
   logic vld_work;

   logic xclk_n;
   logic pin_ci_n;
   logic pad_ri_n;
   logic pin_to_n;
   logic z_DataOut_n;
   logic pin_sel_n;
   logic pin_dsel_n;
   logic pin_di_fback_n;
   logic pin_di_n;
   logic io_cfg_t_n;
   logic io_cfg_n;
   logic SEL_n;
   logic TO_n;
   logic CKI_CO_n;
   logic CKI_CO_n_dly;
   logic CI_CKO_n;
   logic CI_CKO_n_dly;
   logic RI_DO_n;
   logic DI_RO_n;
   logic FBDO_FBDI_n;
   logic DSEL_n;
   logic [`CHIP_NUM-1:0] TPSEL_n;
   logic CKI_CO_C_n;
   logic CI_CKO_C_n;
   logic DI_RO_C_n;
   logic RI_DO_C_n;
   logic FBDO_FBDI_C_n;

   logic REG_fb_sel;
   logic REG_cko_inv;
   logic [29:0]  REG_io_n_cfg;
   logic [24:0]  REG_io_s_cfg;

   logic xclk_s;
   logic pin_ci_s;
   logic pad_ri_s;
   logic z_DataOut_s;
   logic pin_sel_s;
   logic pin_fb_sel_s;
   logic pin_dsel_s;
   logic pin_di_fback_s;
   logic pin_di_s;
   logic io_cfg_t_s;
   logic io_cfg_s;
   logic CO_CKI_C_s;
   logic CKO_CI_C_s;
   logic RO_DI_C_s;
   logic DO_RI_C_s;
   logic FBDI_FBDO_C_s;
   logic CKO_CI_s;
   logic CKO_CI_s_dly;
   logic CO_CKI_s;
   logic CO_CKI_s_dly;
   logic RO_DI_s;
   logic DO_RI_s;
   logic FBDI_FBDO_s;

   logic from_io_n_pin_tpsel;

   logic io_assert_gate;

   logic cps_io_to;
   logic [1:0] mx2_tx_testo;
   logic my_round_start;
   logic xclk_div;
   logic z_NonceFlip;
   logic z_dbg_spdbusy;
   logic z_dbg_w_req;
   logic z_dbg_r_req;
   logic raw_core_vld;

   logic pin_tpsel;
   logic DO_f_jlm;
   logic uart_do;
   logic [`SLICE_NUM-1:0] slice_gnt;
   logic [1:0] mx2_rx;
   logic [1:0] mx2_ry;
   logic [1:0] mx2_ru;
   logic [1:0] mx2_rv;
   logic data_ready;
   logic header_pass;
   logic header_fail;
   logic chk_pass;
   logic chk_fail;
   logic selfcal_itrp_update;

   logic self_aging_wr_done;
   logic to_cpm_uart_pll_baudclk;
   logic REG_FT_Ftdone;
   logic burn_off_tmp;
   logic sort_done;
   logic current_reg_need_insert;
   logic to_cpm_efuse_cs;


   logic to_io_s_xclk;
   logic xclk;
   logic [`CHIP_NUM:0]   real_cki;
   logic sysctrl_xclk_delay;
   logic reg_cko_inv;
   logic cps_sysc_to_io_n_xclk_chips[`CHIP_NUM];

   logic pad_to_ie;
   logic pad_to_oen;
   logic pad_sel_ie;
   logic pad_sel_oen;
   logic pad_tpsel_ie;
   logic pad_tpsel_oen;
   logic pad_dsel_ie;
   logic pad_dsel_oen;
   logic pad_fb_ie;
   logic pad_fb_oen;
   logic [`CHIP_NUM:0]   fb_btc;


   logic [`CHIP_NUM-1 : 0]  SEL;
   logic [`CHIP_NUM-1 : 0]  DSEL;
   logic [`CHIP_NUM-1 : 0]  FBDI_FBDO;
   logic [`CHIP_NUM-1 : 0]  FBDO_FBDI;
   logic [`CHIP_NUM-1 : 0]  CKI_CO;
   logic [`CHIP_NUM-1 : 0]  CKO_CI;
   logic [`CHIP_NUM-1 : 0]  CI_CKO;
   logic [`CHIP_NUM-1 : 0]  CO_CKI;
   logic [`CHIP_NUM-1 : 0]  RI_DO;
   logic [`CHIP_NUM-1 : 0]  RO_DI;
   logic [`CHIP_NUM-1 : 0]  DI_RO;
   logic [`CHIP_NUM-1 : 0]  DO_RI;
   logic     uart_wr_cmd_valid;
   logic     uart_rd_cmd_valid;
   logic     uart_wr_rsp_valid;
   logic     uart_rd_rsp_valid;



`ifdef FUNC_IO_FB_SEL
   logic [`CHIP_NUM-1:0] chips_io_fb_sel;
`endif

  `include "../../../verify/uvm/uvc/io/src/io_if_pc.sv"

endinterface : io_if

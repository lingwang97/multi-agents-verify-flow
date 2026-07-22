class uart_coverage extends uvm_subscriber #(uart_coverage_item);
 
   `uvm_component_utils(uart_coverage)
  
   uvm_analysis_imp #(uart_coverage_item, uart_coverage)  mon2cov;

   virtual uart_if uart_vif;
   uart_coverage_item req_h;

   string report_id = "uart_coverage";

  // -----------------------------------------
  // coverage:  cmd
  // -----------------------------------------
  covergroup cg_uart_cmd;
    option.per_instance = 0;
    cov_mode: coverpoint req_h.mode {
      type_option.weight = 0;
      bins  INIT  = {2'b11};
      bins  BAUD  = {2'b10};
      bins  WRITE  = {2'b01};
      bins  READ  = {2'b00};
    }
    cov_we: coverpoint req_h.we{
      type_option.weight = 0;
      bins wr = {'b1};
      bins rd = {'b0};
    }
    cov_chipaddr: coverpoint req_h.chipaddr{
      type_option.weight = 0;
      bins chip_0 = {'h0}         ;
      bins chip_x = {['h1:'h3fe]}  ;
      bins broad  = {'h3ff}        ;
    }

    cov_single_broad_chip: coverpoint req_h.chipaddr{
      type_option.weight = 0;
      bins single = {['h0:'h3fe]}  ;
      bins broad  = {'h3ff}        ;
    }

    cov_baud: coverpoint req_h.baud{
      type_option.weight = 0;
      bins low    = {LOW   }   ;
      bins med    = {MEDIUM}   ;
      bins high   = {HIGH  }   ;
    }
    cov_tranlen: coverpoint req_h.tranlen{
      //type_option.weight = 0;
      bins short  = {'h0, 'h1} ;
      bins long[] = {REG_VERSION_WIDTH, REG_WORK_WIDTH, REG_SPDCORE_WIDTH, REG_SPD_WIDTH,         
                    //REG_NONCEBUF_WIDTH    
                    REG_SPDLOG_WIDTH, REG_SSLOG_WIDTH, REG_TCLKPD_WIDTH};    
      bins misc  = default ;
    }

    // cross coverpoint
    cov_modeXchipaddr: cross  cov_mode, cov_chipaddr iff(uart_vif.uart_pll_mode==0){
      bins wr_0   = binsof(cov_mode.WRITE)&& binsof(cov_chipaddr.chip_0);
      bins rd_0   = binsof(cov_mode.READ) && binsof(cov_chipaddr.chip_0);
      bins init_broad = binsof(cov_mode.INIT) && binsof(cov_chipaddr.broad);
      bins baud_broad = binsof(cov_mode.BAUD) && binsof(cov_chipaddr.broad);
      bins wr_broad   = binsof(cov_mode.WRITE) && binsof(cov_chipaddr.broad);
      bins rd_broad   = binsof(cov_mode.READ) && binsof(cov_chipaddr.broad);
      ignore_bins init_0 = binsof(cov_mode.INIT) && binsof(cov_chipaddr.chip_0);
      ignore_bins baud_0 = binsof(cov_mode.BAUD) && binsof(cov_chipaddr.chip_0);
      ignore_bins chip_x = binsof(cov_chipaddr.chip_x);
    }

    cov_baudXchipaddr: cross  cov_baud, cov_chipaddr iff(uart_vif.uart_pll_mode==0){
      bins high_0   = binsof(cov_baud.high)&& binsof(cov_chipaddr.chip_0);
      bins low_broad    = binsof(cov_baud.low)  && binsof(cov_chipaddr.broad);
      bins med_broad    = binsof(cov_baud.med)  && binsof(cov_chipaddr.broad);
      bins high_broad   = binsof(cov_baud.high) && binsof(cov_chipaddr.broad);
      ignore_bins chip_x = binsof(cov_chipaddr.chip_x);
      ignore_bins low_0    = binsof(cov_baud.low) && binsof(cov_chipaddr.chip_0);
      ignore_bins med_0    = binsof(cov_baud.med) && binsof(cov_chipaddr.chip_0);
    }

    cov_weXtranlen: cross cov_we,  cov_tranlen iff(uart_vif.uart_pll_mode==0) {
      bins wr_short = binsof(cov_we.wr) && binsof(cov_tranlen.short);
      bins rd_short = binsof(cov_we.rd) && binsof(cov_tranlen.short) ;
      bins wr_long  = binsof(cov_we.wr) && binsof(cov_tranlen.long);
      bins rd_long  = binsof(cov_we.rd) && binsof(cov_tranlen.long) ;
      ignore_bins misc  = binsof(cov_we.wr) && binsof(cov_tranlen.misc);
    }

    cov_uart_do_shaping: coverpoint uart_vif.REG_UART_XCLK_DO_SHAPING_EN{
      bins shaping_on   = {1};
      bins shaping_off  = {0};
    }

    cov_uart_fb_shaping: coverpoint uart_vif.REG_UART_XCLK_FB_SHAPING_EN{
      bins shaping_on   = {1};
      bins shaping_off  = {0};
    }

    cov_uart_do_shaping_mode: coverpoint uart_vif.REG_UART_XCLK_DO_SHAPING_MODE{
      bins dff_syn   = {0, 2};
      bins extend_neg_width  = {1};
      bins extend_pos_width  = {3};
    }
    cov_uart_fb_shaping_mode: coverpoint uart_vif.REG_UART_XCLK_FB_SHAPING_MODE{
      bins dff_syn   = {0, 2};
      bins extend_neg_width  = {1};
      bins extend_pos_width  = {3};
    }

    cov_uart_shaping_trans: coverpoint {uart_vif.REG_UART_XCLK_DO_SHAPING_EN,uart_vif.REG_UART_XCLK_FB_SHAPING_EN} iff(uart_vif.uart_pll_mode==0){
      bins shaping_off2on   = (2'b00 => 2'b11);
      bins shaping_on2off   = (2'b11 => 2'b00);
    }

    cov_uart_fc_disable: coverpoint uart_vif.uart_fc_disable{
      bins fc_enable    = {0};
      bins fc_disable   = {1};
    }

    cov_uart_fc_trans: coverpoint uart_vif.uart_fc_disable{
      bins fc_dis2enable    = (1 => 0);
      bins fc_en2disable   = (0 => 1);
    }

    //cov_uart_shaping_rw: cross cov_we, cov_uart_do_shaping, cov_uart_fb_shaping iff(uart_vif.uart_pll_mode==0);
    // no crossing
    cov_uart_shaping_rw: coverpoint {uart_vif.REG_UART_XCLK_DO_SHAPING_EN, uart_vif.REG_UART_XCLK_FB_SHAPING_EN, req_h.we} iff(uart_vif.uart_pll_mode==0){
      bins shaping_w = {3'b111};
      bins shaping_r = {3'b110};
    }    

    cov_uart_shaping_oneside: cross cov_uart_do_shaping,cov_uart_fb_shaping,cov_uart_do_shaping_mode,cov_uart_fb_shaping_mode iff(uart_vif.uart_pll_mode==0) {
      //stub undefined bin by set cross_auto_bin_max = 0
      option.cross_auto_bin_max = 0;
      bins do_posXfb_neg  =  binsof(cov_uart_do_shaping.shaping_on)
                          && binsof(cov_uart_do_shaping_mode.extend_pos_width)
                          && binsof(cov_uart_fb_shaping.shaping_on)   
                          && binsof(cov_uart_fb_shaping_mode.extend_neg_width); 
      //bins do_negXfb_pos  =  binsof(cov_uart_do_shaping.shaping_on) 
      //                    && binsof(cov_uart_do_shaping_mode.extend_neg_width)
      //                    && binsof(cov_uart_fb_shaping.shaping_on) 
      //                    && binsof(cov_uart_fb_shaping_mode.extend_pos_width);  //to be continue
    }
    cov_weXbaud: cross cov_we,  cov_baud iff(uart_vif.uart_pll_mode==0);
    cov_fcXchipaddrXwe: cross cov_uart_fc_disable , cov_we, cov_single_broad_chip iff(uart_vif.uart_pll_mode==0);
  endgroup: cg_uart_cmd

  // -----------------------------------------
  // coverage: reg_noncebuf
  // -----------------------------------------
  covergroup cg_uart_nonce;
    option.per_instance = 0;
    cov_we: coverpoint req_h.we{
      type_option.weight = 0;
      //bins wr = {'b1};
      bins rd = {'b0};
    }
    cov_addr: coverpoint req_h.addr{
      type_option.weight = 0;
      bins noncebuf_addr = {'ha0};
    }
    cov_noncecnt: coverpoint uart_vif.nonce_cnt{
      bins low    = {'h0}     ;
      //bins med    = {'h4}   ;
      bins high   = {['h7:$]} ;
    }

    // cross coverpoint
    cov_weXaddr: cross cov_we, cov_addr{
      bins rd_nonce = binsof(cov_we.rd);
    }
  endgroup: cg_uart_nonce


  // -----------------------------------------
  // coverage: config 
  // -----------------------------------------
  covergroup cg_uart_cfg;
    option.per_instance = 0;
    cov_chk_mode: coverpoint uart_vif.REG_UART_CHECK_MODE_SEL{
      bins ecc_mode = {1};
      bins crc_mode = {0};
    }    
    cov_header: coverpoint uart_vif.HEADER{
      bins header_0  = {'h5a_5a5a_5a5a};
      bins header_x  = default;
    }
  endgroup

  // -----------------------------------------
  // coverage: err_detect
  // 1, check & header fail 
  // 2, fsm & rx timeout  
  // 3, start err, start glitch
  // -----------------------------------------
  covergroup cg_uart_err_detect;
    option.per_instance = 0;
    
    cov_uart_pll_mode: coverpoint uart_vif.uart_pll_mode {
      type_option.weight = 0;
      bins xclkmode = {0};
      bins pllmode = {1};
    }
    cov_chk_fail: coverpoint uart_vif.chk_fail{
      type_option.weight = 0;
      bins chk_fail = {1};
    }
    cov_header_fail: coverpoint uart_vif.header_fail{
      type_option.weight = 0;
      bins header_fail = {1};
    }
    cov_DI_fsm_timeout: coverpoint uart_vif.DI_fsm_timeout_flag{
      type_option.weight = 0;
      bins fsm_timeout = {1};
    }
    cov_DI_rx_timeout: coverpoint uart_vif.DI_rx_timeout_flag{
      type_option.weight = 0;
      bins di_rx_timeout = {1};
    }
    cov_DI_rx_start_err: coverpoint uart_vif.DI_rx_start_err{
      type_option.weight = 0;
      bins DI_rx_start_err = {1};
    }    
    cov_DI_rx_start_glitch: coverpoint uart_vif.DI_rx_start_glitch{
      type_option.weight = 0;
      bins DI_rx_start_err = {1};
    }    

    cov_chk_failXclkmode: cross cov_uart_pll_mode, cov_chk_fail     ;
    cov_hdr_failXclkmode: cross cov_uart_pll_mode, cov_header_fail  ;
    cov_fsm_timeoutXclkmode: cross cov_uart_pll_mode, cov_DI_fsm_timeout  ;
    cov_rx_timeoutXclkmode: cross cov_uart_pll_mode, cov_DI_rx_timeout  ;
    cov_rx_start_errXclkmode: cross cov_uart_pll_mode, cov_DI_rx_start_err  ;
    cov_rx_start_glitchXclkmode: cross cov_uart_pll_mode, cov_DI_rx_start_glitch  ;
    
  endgroup: cg_uart_err_detect



  // -----------------------------------------
  // coverage: autoreport  
  // -----------------------------------------
  covergroup cg_uart_autoreport;
    option.per_instance = 0;
    cov_nonce_return_en: coverpoint uart_vif.REG_UART_NONCE_RETURN_EN{
      bins NONCE_RETURN_EN = {1};
    }
    cov_nonce_update: coverpoint uart_vif.reg_nonce_update{
      bins COV_NONCE_UPDATE = {1};
    }
    cov_work_nonce_update: coverpoint uart_vif.work_nonce_update{
      bins COV_WORK_NONCE_UPDATE = {1};
    }

    cov_FBDO_fifo_wdata: coverpoint uart_vif.FBDO_fifo_wdata{
                                                                                     //nonce_empty
      wildcard bins nonce_report = (40'h5a5a5a5a5a  => 40'b????????_????????_00000010_1000?_0_00_????????);
                                                                             //addr          //mode_rd
    }

    cov_uart_pll_mode: coverpoint uart_vif.uart_pll_mode {
      bins xclkmode = {0};
      bins pllmode = {1};
    }

    cov_NonceReturn_X_nonce_updateXmode:      cross cov_uart_pll_mode,cov_nonce_return_en, cov_nonce_update;    
    cov_NonceReturn_X_work_nonce_updateXmode: cross cov_uart_pll_mode,cov_nonce_return_en, cov_work_nonce_update;
    cov_NonceReturn_X_FBDO_fifoXmode:         cross cov_uart_pll_mode,cov_nonce_return_en, cov_FBDO_fifo_wdata;
 
  endgroup: cg_uart_autoreport

  // -----------------------------------------
  // coverage: softrst  
  // -----------------------------------------
  covergroup cg_uart_softrst;
    option.per_instance = 0;
    cov_soft_rst: coverpoint uart_vif.uart_softrst  {
      bins soft_rst = (1'b0 => 1'b1); 
    }

    cov_uart_pll_mode: coverpoint uart_vif.uart_pll_mode {
      bins xclkmode = {0};
      bins pllmode = {1};
    }

    cov_softrstXmode:      cross cov_uart_pll_mode, cov_soft_rst;

  endgroup: cg_uart_softrst

  // -----------------------------------------
  // coverage: duplex wr/rd
  // -----------------------------------------
  covergroup cg_uart_duplex;
    option.per_instance = 0;

    cov_chip_id: coverpoint req_h.chipaddr{
      type_option.weight = 0;
      bins chip_0 = {0};
      bins chip_x = {['h1:'h3fe]};
    }

    cov_rx_busy_chip0: coverpoint uart_vif.di_rx_busy_a[0] {
      bins rx_busy = {1};
      bins rx_not_busy = {0};
    }

    cov_tx_busy_chip0: coverpoint uart_vif.fbdo_tx_busy_a[0] {
      bins tx_busy = {1};
      bins tx_not_busy = {0};
    }

    cov_duplex_chip0: cross cov_rx_busy_chip0, cov_tx_busy_chip0 {
      bins duplex_0 = binsof(cov_rx_busy_chip0.rx_busy) && binsof(cov_tx_busy_chip0.tx_busy);
      bins duplex_1 = binsof(cov_rx_busy_chip0.rx_busy) && binsof(cov_tx_busy_chip0.tx_not_busy);
      bins duplex_2 = binsof(cov_rx_busy_chip0.rx_not_busy) && binsof(cov_tx_busy_chip0.tx_busy);
      bins duplex_3 = binsof(cov_rx_busy_chip0.rx_not_busy) && binsof(cov_tx_busy_chip0.tx_not_busy);
    }

    cov_rx_busy_chipx: coverpoint uart_vif.di_rx_busy_a[1] {
      bins rx_busy = {1};
      bins rx_not_busy = {0};
    }

    cov_tx_busy_chipx: coverpoint uart_vif.fbdo_tx_busy_a[1] {
      bins tx_busy = {1};
      bins tx_not_busy = {0};
    }

    cov_duplex_chipx: cross cov_rx_busy_chipx, cov_tx_busy_chipx {
      bins duplex_0 = binsof(cov_rx_busy_chipx.rx_busy) && binsof(cov_tx_busy_chipx.tx_busy);
      bins duplex_1 = binsof(cov_rx_busy_chipx.rx_busy) && binsof(cov_tx_busy_chipx.tx_not_busy);
      bins duplex_2 = binsof(cov_rx_busy_chipx.rx_not_busy) && binsof(cov_tx_busy_chipx.tx_busy);
      bins duplex_3 = binsof(cov_rx_busy_chipx.rx_not_busy) && binsof(cov_tx_busy_chipx.tx_not_busy);
    }


    cov_uart_pll_mode: coverpoint uart_vif.uart_pll_mode {
      bins xclkmode = {0};
      bins pllmode = {1};
    }


    cov_duplex0Xclkmode: cross cov_uart_pll_mode, cov_duplex_chip0;
    cov_duplexxXclkmode: cross cov_uart_pll_mode, cov_duplex_chipx;

  endgroup: cg_uart_duplex

  // -----------------------------------------
  // coverage: uart pll mode, freq 
  // -----------------------------------------
  covergroup cg_uart_pll_mode;
    option.per_instance = 0;

    cov_uart_pll_mode: coverpoint uart_vif.uart_pll_mode {
      type_option.weight = 0;
      bins pllmode = {1};
    }
    cov_uart_plldiv_mode: coverpoint uart_vif.uart_plldiv_mode {
      type_option.weight = 0;
      bins frc_div = {1};
      bins int_div = {0};
    }
    cov_uart_plldiv_int: coverpoint uart_vif.uart_plldiv_int {
      type_option.weight = 0;
      bins bypass = {0,1}; 
      bins mid = {[2:100]};
      bins high = {[101:$]};
    }
    cov_uart_plldiv_frc: coverpoint uart_vif.uart_plldiv_frc {
      type_option.weight = 0;
      bins M_4 = {'d10486}; 
      bins M_1_5 = default; //
    }

    cov_uart_pllmodeXdivmode: cross cov_uart_pll_mode, cov_uart_plldiv_mode;
    cov_uart_pllmodeXdiv_int: cross cov_uart_pll_mode, cov_uart_plldiv_mode, cov_uart_plldiv_int{
      ignore_bins Frc= binsof(cov_uart_plldiv_mode.frc_div);
    }
    cov_uart_pllmodeXdiv_frc: cross cov_uart_pll_mode, cov_uart_plldiv_mode, cov_uart_plldiv_frc{
      ignore_bins Int= binsof(cov_uart_plldiv_mode.int_div);
    }


    cov_mode: coverpoint uart_vif.cmd_mode_fsm_pll {
      type_option.weight = 0;
      bins  INIT  = {2'b11};
      //bins  BAUD  = {2'b10};
      bins  WRITE  = {2'b01};
      bins  READ  = {2'b00};
    }
    cov_uart_pll_do_shaping: coverpoint uart_vif.REG_UART_PLL_DO_SHAPING_EN{
      bins shaping_on   = {1};
      bins shaping_off   = {0};
    }

    cov_uart_pll_fb_shaping: coverpoint uart_vif.REG_UART_PLL_FB_SHAPING_EN{
      bins shaping_on   = {1};
      bins shaping_off   = {0};
    }

    cov_uart_pll_shaping_trans: coverpoint {uart_vif.REG_UART_PLL_DO_SHAPING_EN,uart_vif.REG_UART_PLL_FB_SHAPING_EN}{
      type_option.weight = 0;
      bins shaping_off2on  = (2'b00   => 2'b11 );
      bins shaping_on2off  = (2'b11   => 2'b00);
    }

    cov_uart_pll_do_shaping_mode: coverpoint uart_vif.REG_UART_PLL_DO_SHAPING_MODE{
      type_option.weight = 0;
      bins dff_syn   = {0, 2};
      bins extend_neg_width  = {1};
      bins extend_pos_width  = {3};
    }

    cov_uart_pll_fb_shaping_mode: coverpoint uart_vif.REG_UART_PLL_FB_SHAPING_MODE{
      type_option.weight = 0;
      bins dff_syn   = {0, 2};
      bins extend_neg_width  = {1};
      bins extend_pos_width  = {3};
    }

    cov_uart_fc_disable: coverpoint uart_vif.uart_fc_disable{
      bins fc_enable    = {0};
      bins fc_disable   = {1};
    }


    cov_uart_pllmodeXcmd: cross cov_uart_pll_mode,cov_mode;

    cov_uart_pll_shaping_oneside: cross cov_uart_pll_mode,cov_uart_pll_do_shaping,cov_uart_pll_fb_shaping,cov_uart_pll_do_shaping_mode,cov_uart_pll_fb_shaping_mode {
      //stub undefined bin by set cross_auto_bin_max = 0
      option.cross_auto_bin_max = 0;
      //bins do_posXfb_neg  =  binsof(cov_uart_pll_mode.pllmode) 
      //                    && binsof(cov_uart_pll_do_shaping.shaping_on)
      //                    && binsof(cov_uart_pll_do_shaping_mode.extend_pos_width)
      //                    && binsof(cov_uart_pll_fb_shaping.shaping_on)   
      //                    && binsof(cov_uart_pll_fb_shaping_mode.extend_neg_width);  //to be continue
      bins do_negXfb_pos  =  binsof(cov_uart_pll_mode.pllmode) 
                          && binsof(cov_uart_pll_do_shaping.shaping_on) 
                          && binsof(cov_uart_pll_do_shaping_mode.extend_neg_width)
                          && binsof(cov_uart_pll_fb_shaping.shaping_on) 
                          && binsof(cov_uart_pll_fb_shaping_mode.extend_pos_width);

    }
    cov_uart_pllmodeXshaping_trans: cross cov_uart_pll_mode,cov_uart_pll_shaping_trans;
    cov_uart_pllmodeXfc: cross cov_uart_pll_mode,cov_uart_fc_disable;


  endgroup: cg_uart_pll_mode

  // -----------------------------------------
  // coverage: duplex wr/rd
  // -----------------------------------------
  covergroup cg_uart_chipid_extension;
    option.per_instance = 0;


    cov_chipid_bit_check: coverpoint req_h.chipaddr{
      type_option.weight = 0;
      wildcard bins bit_0_as_0 = {10'b?????????0};
      wildcard bins bit_0_as_1 = {10'b?????????1};
      wildcard bins bit_1_as_0 = {10'b????????0?};
      wildcard bins bit_1_as_1 = {10'b????????1?};
      wildcard bins bit_2_as_0 = {10'b???????0??};
      wildcard bins bit_2_as_1 = {10'b???????1??};
      wildcard bins bit_3_as_0 = {10'b??????0???};
      wildcard bins bit_3_as_1 = {10'b??????1???};
      wildcard bins bit_4_as_0 = {10'b?????0????};
      wildcard bins bit_4_as_1 = {10'b?????1????};
      wildcard bins bit_5_as_0 = {10'b????0?????};
      wildcard bins bit_5_as_1 = {10'b????1?????};
      wildcard bins bit_6_as_0 = {10'b???0??????};
      wildcard bins bit_6_as_1 = {10'b???1??????};
      wildcard bins bit_7_as_0 = {10'b??0???????};
      wildcard bins bit_7_as_1 = {10'b??1???????};
      wildcard bins bit_8_as_0 = {10'b?0????????};
      wildcard bins bit_8_as_1 = {10'b?1????????};
      wildcard bins bit_9_as_0 = {10'b0?????????};
      wildcard bins bit_9_as_1 = {10'b1?????????};
    }


    cov_chipid: coverpoint req_h.chipaddr{
      type_option.weight = 0;
      bins chipid_0 = {['h000:'h0fe]};
      bins chipid_ff = {'hff};
      bins chipid_1 = {['h100:'h1ff]};
      bins chipid_2 = {['h200:'h2ff]};
      bins chipid_3 = {['h300:'h3fe]};
      bins chipid_brd = {'h3ff};
    }

    cov_mode: coverpoint req_h.mode {
      type_option.weight = 0;
      //bins  INIT  = {2'b11};
      //bins  BAUD  = {2'b10};
      bins  WRITE  = {2'b01};
      bins  READ  = {2'b00};
    }

    cov_uart_chipidXmode: cross cov_chipid,cov_mode;



    cov_chip_start_id: coverpoint uart_vif.uart_chipid{
      type_option.weight = 0;
      bins startid_0 = {['h000:'h0fe]};
      bins startid_ff = {'hff};
      bins startid_1 = {['h100:'h1ff]};
      bins startid_2 = {['h200:'h2ff]};
      bins startid_3 = {['h300:'h3fe]};
      //bins chipid_brd = {'h3ff};
    }

    cov_init_mode: coverpoint req_h.mode {
      type_option.weight = 0;
      bins  INIT  = {2'b11};
      //bins  BAUD  = {2'b10};
      //bins  WRITE  = {2'b01};
      //bins  READ  = {2'b00};
    }

    cov_uart_chip_start_idXinit_mode: cross cov_chip_start_id,cov_init_mode;


  endgroup: cg_uart_chipid_extension



  function new(string name, uvm_component parent);
    begin
    super.new(name, parent);
    mon2cov = new("mon2cov",this);
    cg_uart_cmd = new();
    cg_uart_nonce = new();
    cg_uart_err_detect = new();
    cg_uart_cfg = new();
    cg_uart_autoreport = new();
    cg_uart_softrst = new();
    cg_uart_duplex = new();
    cg_uart_pll_mode = new();
    cg_uart_chipid_extension = new();


    end
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual uart_if)::get(this , "" , "uart_vif" ,uart_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction
  
  function void write(uart_coverage_item t); 
    req_h = t;
    cg_uart_cmd.sample();
    cg_uart_nonce.sample();
    cg_uart_err_detect.sample();
    cg_uart_cfg.sample();
    cg_uart_autoreport.sample();
    cg_uart_softrst.sample();
    cg_uart_duplex.sample();
    cg_uart_pll_mode.sample();
    cg_uart_chipid_extension.sample();

  endfunction

endclass


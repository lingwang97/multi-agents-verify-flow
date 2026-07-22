//timeunit 100ps;
//timeprecision 1ps;

class uart_monitor extends base_monitor;

  uvm_analysis_port #(uart_item) uart_monitor_main_ap;
  uvm_analysis_port #(uart_coverage_item) frame_collected_port;
  uvm_analysis_port #(uart_sequence_item) uart_monitor_adapter_ap;

  `uvm_component_utils(uart_monitor);

  uart_coverage_item cov_item;
  uart_item uart_item_h;
  uart_sequence_item uart_item_adapter;


  virtual uart_if vif;
  virtual top_if top_vif;

  extern task wait_reset();
  extern task main_traffic();
  extern task tran_adapter();
  extern task collect_coverage();

  extern task chk_pll_div();
  extern task cmp_freq_div(input bit divmode);

  extern task chk_rdfsm_wait_cnt_max();
  //extern task rdfsm_wait_cnt(input int id = 0);
  //extern task cmp_rdfsm_wait_cnt_max(input int id, input bit [5:0] reg_uart_rdfsm_wait_cnt_max);

  extern task chk_rx_busy_cnt_max();

  function new(string name="uart_monitor" , uvm_component parent=null);
    super.new(name , parent);
    uart_monitor_main_ap = new("uart_monitor_main_ap",this);
    uart_monitor_adapter_ap = new("uart_monitor_adapter_ap",this);
    frame_collected_port = new("frame_collected_port",this);

  endfunction

   function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual uart_if)::get(this , "" , "uart_vif" ,vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")

    if(!uvm_config_db#(virtual top_if)::get(this , "" , "top_vif" ,top_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")


    uart_item_h = uart_item::type_id::create("uart_item_h",this);
    uart_item_adapter = uart_sequence_item::type_id::create("uart_item_adapter",this);

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task chk_uart_tpsel_clk_gate(ref logic signal,input string name);

    `uvm_info(get_full_name(), $sformatf("now check signal %s",name), UVM_LOW)

    wait (vif.tpsel == 0);
    repeat(100000)
    begin
	  #0.01ns;
	  if(signal==1)begin
        `uvm_error(get_type_name(), $sformatf("clk_uart_gate_check wrong"))
        break;
	  end
    end
  endtask : chk_uart_tpsel_clk_gate


  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    //wait( top_vif.mid_rst_f_n== 1);
    //$printtimescale();

    wait_reset();
    fork
      //main_traffic();
	  `ifdef USE_UART_DRV
      collect_coverage();
      chk_pll_div();

      `ifdef UART_FC_REG_CHK
        chk_rdfsm_wait_cnt_max();
        chk_rx_busy_cnt_max();
      `endif  //`ifndef UART_FC_REG_CHK
	  `ifdef USE_RAL_MODEL
	  	tran_adapter();
	  `endif
	  `endif
      `ifndef UART_CLK_GATE_CHK_CLOSE
      //clk gate if tpsel=0(JAMLINK_DRIVER)
      chk_uart_tpsel_clk_gate(vif.uart_xclk_for_gate,"vif.uart_xclk_for_gate");
      chk_uart_tpsel_clk_gate(vif.uart_mid_clk_for_gate,"vif.uart_mid_clk_for_gate");
      chk_uart_tpsel_clk_gate(vif.uart_pll_clk_for_gate,"vif.uart_pll_clk_for_gate");
      `endif

    join_none
  endtask
endclass: uart_monitor



// ---------------------------------
// extern task
// ---------------------------------
task uart_monitor::main_traffic();
    forever
    begin
      wait(~vif.rst);
      @(posedge vif.clk);
      begin
        uart_item_h.card_sel = vif.card_sel  ;
        uart_monitor_main_ap.write(uart_item_h);
        `uvm_info(get_type_name(), $sformatf(""), UVM_MEDIUM)
      end
    end
endtask: main_traffic

task uart_monitor::wait_reset();
    `uvm_info(get_type_name(), $sformatf("[Wait_RESET] Wait for reset"), UVM_MEDIUM)
    //wait(top_vif.ri_rst_f_n === 1'b1);
    //@vif.uart_rst_done;
    wait( vif.uart_rst_done.triggered);
    repeat (32) @(posedge vif.uart_clk);
   `uvm_info(get_type_name(), $sformatf("[WAIT_RESET] Reset end"), UVM_MEDIUM)
endtask


task uart_monitor::collect_coverage();
  forever begin
    @(posedge vif.clk_for_cov )begin
      cov_item = uart_coverage_item::type_id::create("cov_item",this);
      cov_item.card_sel   = vif.card_sel  ;

      if ($test$plusargs("SEQ_WR"))
        cov_item.chipaddr   = top_vif.chipaddr  ;
      else
        cov_item.chipaddr   = vif.chipaddr  ;

      cov_item.mode       = vif.mode  ;
      cov_item.tranlen    = vif.tranlen  ;
      cov_item.addr       = vif.cmd_addr  ;

      case(vif.REG_UART_FREQ_RATIO)
        'd209 :  cov_item.baud = LOW  ;
        'd16  :  cov_item.baud = MEDIUM  ;
        'd4 , 'd6,'d8  :  cov_item.baud = HIGH  ;    //6Mhz
        //default : `uvm_warning(get_type_name(), $sformatf("Unknow REG_UART_FREQ_RATIO: 'd%0d", vif.REG_UART_FREQ_RATIO))
      endcase

      if(cov_item.mode == 'b1)   cov_item.we = 1;
      else if(cov_item.mode == 'b0)   cov_item.we = 0;


    frame_collected_port.write(cov_item);
    end
  end

endtask:collect_coverage


  /**
  * It check the uart pll freq div every time switching to plll_mode,
  * changing the pll_divmode or div value
  */
task uart_monitor::chk_pll_div();
  forever begin
    @ (vif.REG_UART_PLL_MODE_p or vif.REG_UART_PLLDIV_MODE_pll or vif.REG_UART_PLLDIV_INT_pll or vif.REG_UART_PLLDIV_FRC_pll);
    repeat(10) @(posedge vif.xclk) ;

    if (vif.REG_UART_PLL_MODE_p  )begin
      cmp_freq_div(vif.REG_UART_PLLDIV_MODE_pll);
    end
  end

endtask:chk_pll_div


  /**
  * It compares the pll_clk after int or fract div to the uart_pclk
  */
task uart_monitor::cmp_freq_div(input bit divmode);
  realtime uart_pll_time1, uart_pll_time2, uart_pll_period, uart_pll_freq;
  realtime uart_pclk_time1, uart_pclk_time2, uart_pclk_period, uart_pclk_freq;
  realtime exp_uart_pclk_freq;
  string info;
  string mode;
logic [15:0] cycle_cnt = '1;
  int high_cnt;
  int low_cnt;

  if (divmode == 0)   mode = "int"  ;
  else                mode = "frc"  ;

  `uvm_info(get_type_name(), $sformatf("\n  **********  UART_PLL %sdiv mode, freq check begin  **********  ", mode), UVM_MEDIUM)
fork
        begin
            forever begin
                @(negedge vif.pll_clk);
                if (divmode && vif.REG_UART_PLL_MODE_p) begin
                    cycle_cnt--;
                    if (vif.pclk_gated) begin
                        high_cnt++;
                    end
                    else begin
                        low_cnt++;
                    end
                    if (&cycle_cnt) begin
                        if (high_cnt == low_cnt )
                            `uvm_info(get_type_name(), $sformatf("UART PCLK high/low duty balanced"), UVM_MEDIUM)
                        else
                            `uvm_error(get_type_name(), $sformatf("UART PCLK high/low duty is not balanced, high_cnt = %0d, low_cnt = %0d", high_cnt,low_cnt))
                    end
                end
            end
        end
    join_none


    fork
      // 3). pll_clk
      begin
        @(posedge vif.pll_clk);
        uart_pll_time1 = $realtime();
        repeat(16)@(posedge vif.pll_clk);
        uart_pll_time2 = $realtime();

        uart_pll_period = uart_pll_time2 - uart_pll_time1;
        uart_pll_freq = (1000.0/uart_pll_period)*16.0;
      end

      // 4). pll_clk int div
      begin
        @(posedge vif.pclk_gated);
        uart_pclk_time1 = $realtime();
        repeat(16)@(posedge vif.pclk_gated);
        uart_pclk_time2 = $realtime();

        uart_pclk_period = uart_pclk_time2 - uart_pclk_time1;
        uart_pclk_freq = (1000.0/uart_pclk_period)*16.0;
      end
    join

    if (divmode == 0) begin
        if(vif.REG_UART_PLLDIV_INT_pll == 0)
            exp_uart_pclk_freq = uart_pll_freq/1.0 ;    //bypass
        else exp_uart_pclk_freq = uart_pll_freq/vif.REG_UART_PLLDIV_INT_pll ;
    end
    else
        exp_uart_pclk_freq = uart_pll_freq*vif.REG_UART_PLLDIV_FRC_pll/2**16 ;

    info = {info, "\n"};
    info = {info, $sformatf("-| divmode: %0d [0-intdiv; 1-frcdiv]\n", vif.REG_UART_PLLDIV_MODE_pll) };
    info = {info, $sformatf("-| plldiv_int: 'd%0d\n", vif.REG_UART_PLLDIV_INT_pll) };
    info = {info, $sformatf("-| plldiv_frc: 'd%0d\n", vif.REG_UART_PLLDIV_FRC_pll) };
    info = {info, $sformatf("-| uart_pll_freq: %8.3f MHz\n", uart_pll_freq) };
    info = {info, $sformatf("-| uart_pclk_freq:  %8.3f MHz\n", uart_pclk_freq) };
    info = {info, $sformatf("-| exp_uart_pclk_freq:  %8.3f MHz\n", exp_uart_pclk_freq) };

    `uvm_info(get_type_name(), $sformatf("%s", info), UVM_MEDIUM)

    if ( (exp_uart_pclk_freq > uart_pclk_freq*1.01)|| (exp_uart_pclk_freq < uart_pclk_freq*0.99)  ) begin
      `uvm_error(get_type_name(), $sformatf("[INTDIV_MODE] Uart pll mode %s div chk FAIL!", mode))
    end
    else begin
      `uvm_info(get_type_name(), $sformatf("[INTDIV_MODE] Uart pll mode %s div chk SUCC!", mode), UVM_MEDIUM)
    end

  `uvm_info(get_type_name(), $sformatf("\n  **********  UART_PLL %sdiv mode, freq check end  **********  ", mode), UVM_MEDIUM)
endtask: cmp_freq_div




`ifdef UART_FC_REG_CHK

  /**
  * It checks function of uart_rdfsm_wait_cnt_max.
  * when the uart_rd_fsm (state == RDFC), the max waiting uart_clk16 cnt
  * UART_FC: RDFSM, state == RDFC('d3) ##(rdfsm_wait_cnt_max)clk, state == RDWT('d4)
  */
`define RDFSM_INFO(RDFSM_SIG, CHIP_ID)  \
  //info = "\n";  \
  info = {info, $sformatf(" -rdfsm_wait_cnt: %0d. \t", rdfsm_wait_cnt)} ;  \
  info = {info, $sformatf(" -exp_rdfsm_wait_cnt: %0d. \t", exp_rdfsm_wait_cnt_max)} ;  \
  info = {info, $sformatf(" -REG_UART_RDFSM_WAIT_CNT_MAX: %0d. \t", vif.REG_UART_RDFSM_WAIT_CNT_MAX[CHIP_ID])} ;  \
    \
  if(vif.REG_UART_RDFSM_WAIT_CNT_MAX[CHIP_ID] == exp_rdfsm_wait_cnt_max)  \
    `uvm_info(get_type_name(), $sformatf(`"[RDFSM_SIG SUCC]: %s`", info), UVM_MEDIUM) \
  else  \
    `uvm_error(get_type_name(), $sformatf(`"[RDFSM_SIG FAIL]: %s`", info))


`define RDFSM_WAIT_CNT(CHIP_ID, X_PLL, RDFSM_SIG, STATE)  \
  forever begin \
    int  rdfsm_wait_cnt  = 0; \
    int  exp_rdfsm_wait_cnt_max  = 0; \
    string info =""; \
                  \
    wait(vif.uart_rd_fsm_state_a[CHIP_ID] == 'd3) ; \
      \
    forever begin \
      @(negedge vif.uart_clk);  \
      if( vif.uart_rd_fsm_``STATE``_a[CHIP_ID] == 'd3) rdfsm_wait_cnt ++; \
      else         break;  \
    end \
        \
    if(X_PLL)    exp_rdfsm_wait_cnt_max  = (rdfsm_wait_cnt - 2*vif.REG_UART_FREQ_RATIO)/16.0;  \
      //plus 2xclk delay due to 2  DFF  \
    else    \
      exp_rdfsm_wait_cnt_max  = (rdfsm_wait_cnt - 2)/16.0; \
      //plus 2 uart_clk due to 2  DFF \
      \
    `RDFSM_INFO(RDFSM_SIG, CHIP_ID)  \
  end


task uart_monitor::chk_rdfsm_wait_cnt_max();
  fork
    `RDFSM_WAIT_CNT(0, 1, ,state_x);
    `RDFSM_WAIT_CNT(0, 0, ,state_p);
    `RDFSM_WAIT_CNT(1, 1, ,state_x);
    `RDFSM_WAIT_CNT(1, 0, ,state_p);
  join_none
  //rdfsm_wait_cnt(1);
endtask: chk_rdfsm_wait_cnt_max



 /**
  * It checks function of uart_rx_busy_cnt_max.
  *  when the rx_busy, the max waiting uart_clk16 cnt
  */
`define BUSY_INFO(X_PLL, BUSY_SIG) \
  if(busy_flag) begin \
    if(X_PLL)  exp_rx_busy_cnt_max = rx_busy_cnt*vif.REG_UART_FREQ_RATIO; \
    else       exp_rx_busy_cnt_max = rx_busy_cnt       ; \
    info = {info, $sformatf(" -rx_busy_cnt: %0d.\t", rx_busy_cnt)} ; \
    info = {info, $sformatf(" -exp_rx_busy_cnt_max: %0d.\t", exp_rx_busy_cnt_max)} ; \
    info = {info, $sformatf(" -REG_UART_RX_BUSY_CNT_MAX: %0d \t", vif.REG_UART_RX_BUSY_CNT_MAX[0])} ; \
        \
    if(exp_rx_busy_cnt_max == (vif.REG_UART_RX_BUSY_CNT_MAX[0] * 16))\
      `uvm_info(get_type_name(), $sformatf(`"[BUSY_SIG``_BUSY SUCC]: %s`", info), UVM_MEDIUM) \
    else \
      `uvm_error(get_type_name(), $sformatf(`"[BUSY_SIG``_BUSY ERR]: %s`", info)) \
      \
  end

`define RX_CNT(CLK, BUSY_SIG, STATE, RX_DIN) \
  forever begin \
    @(negedge vif.``CLK) ; \
    //`uvm_info(get_type_name(), $sformatf(`"$t=%.2f @(negedge vif.``CLK)`", $realtime), UVM_MEDIUM)\
    if ( (!vif.``BUSY_SIG``_rx_busy_n) &&  (vif.``STATE``_state == 0) && (vif.``RX_DIN``_rx_din) )begin \
        rx_busy_cnt ++; \
        //`uvm_info(get_type_name(), $sformatf("[1]$t=%p rx_busy_cnt  = %0d",$realtime, rx_busy_cnt), UVM_MEDIUM)\
    end \
    else if ((vif.``BUSY_SIG``_rx_busy_n) &&  (vif.``STATE``_state == 0) && (vif.``RX_DIN``_rx_din) && (rx_busy_cnt>0) ) begin \
        busy_flag = 1; \
        //`uvm_info(get_type_name(), $sformatf("[2]$t=%p busy_flag = 1", $realtime), UVM_MEDIUM)\
        break ; \
    end \
    else begin \
      break; \
    end \
  end

`define CHK_RX_BUSY_CNT_MAX(X_PLL, CLK, RST, BUSY_SIG, STATE, RX_DIN) \
  begin \
    forever begin \
      string info = "";\
      int rx_busy_cnt = 0; \
      real exp_rx_busy_cnt_max = 0; \
      bit busy_flag = 0;   \
          \
      if( (X_PLL && !vif.REG_UART_PLL_MODE) || (!X_PLL && vif.REG_UART_PLL_MODE_p)  ) begin  \
        wait( (!vif.``BUSY_SIG``_rx_busy_n) &&  (vif.``STATE``_state == 0) && (vif.``RX_DIN``_rx_din) ); \
        fork \
          begin \
            `RX_CNT(CLK, BUSY_SIG, STATE, RX_DIN)  \
            `BUSY_INFO(X_PLL, BUSY_SIG) \
          end \
          begin\
            @(posedge vif.uart_``RST) ;\
            `uvm_info(get_type_name(), $sformatf(`"[SOFTRST WTD], BUSY_SIG``_BUSY break`"), UVM_MEDIUM) \
            @(negedge vif.``CLK) ; \
            \
          end\
        join_any  \
                  \
        disable fork;\
        \
      end // (X_PLL && !vif.REG_UART_PLL_MODE) || (!X_PLL && vif.REG_UART_PLL_MODE_p)\
      else begin\
        @(negedge vif.``CLK) ; \
      end\
    end \
  end\

task uart_monitor::chk_rx_busy_cnt_max();
  @(posedge vif.FBDI_RX_X_rx_busy_n);  //wait POR and the first cnt
    `uvm_info(get_type_name(), $sformatf("chk_rx_busy_cnt_max start"), UVM_MEDIUM)
  fork
   `CHK_RX_BUSY_CNT_MAX(1, xclk_gated, softrst, DI_RX_X,     DI_RX_X,      DI_X     )
   `CHK_RX_BUSY_CNT_MAX(1, xclk_gated, softrst, FBDI_RX_X,   FBDI_RX_X,    FBDI_X   )
   `CHK_RX_BUSY_CNT_MAX(0, pclk_gated, softrst_p, DI_RX_PLL,   DI_RX_PLL,    DI_P     )
   `CHK_RX_BUSY_CNT_MAX(0, pclk_gated, softrst_p, FBDI_RX_PLL, FBDI_RX_PLL,  FBDI_P   )
  join_none
endtask:chk_rx_busy_cnt_max


`endif      //`ifdef UART_FC_REG_CHK

`ifdef USE_RAL_MODEL
`ifdef USE_UART_DRV

task uart_monitor::tran_adapter();
  string s;
  forever begin
	  @(posedge vif.xclk);
    uart_monitor_adapter_ap.write(uart_item_adapter);
  end
endtask



`endif
`endif

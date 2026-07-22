
// declare uvm_analysis_imp  
//`uvm_analysis_imp_decl(_main_uart_monitor)
`uvm_analysis_imp_decl(_reg_monitor)
`uvm_analysis_imp_decl(_uart_driver)

class uart_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(uart_scoreboard);

  //uvm_analysis_imp_main_uart_monitor #(uart_item, uart_scoreboard)  uart_scoreboard_main_ap;
  // reg_item, imprt from reg_pkg
  uvm_analysis_imp_reg_monitor #(reg_item, uart_scoreboard)  regmon_2_uartsbd_imp;
  uvm_analysis_imp_uart_driver #(uart_sequence_item, uart_scoreboard)  uartdrv_2_uartsbd_imp;
  virtual uart_if vif;

  // enable uart_driver to reg_monitor check
  bit enable = 1;
  int reg_mon_cnt = 0;
  int uart_mon_cnt = 0;


  uart_sequence_item  uart_trans_expected[$];
  reg_item   reg_trans_observed[$];

  function new(string name="uart_scoreboard" , uvm_component parent=null);
    super.new(name , parent);
    

  endfunction
 
   function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      //uart_scoreboard_main_ap = new("uart_scoreboard_main_ap",this);
        
      regmon_2_uartsbd_imp = new("regmon_2_uartsbd_imp",this);
      uartdrv_2_uartsbd_imp = new("uartdrv_2_uartsbd_imp",this);

       if(!uvm_config_db#(virtual uart_if)::get(this , "" , "uart_vif", vif))
       	  `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  // -----------------------------------------
  // autocheck  
  // -----------------------------------------
  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $psprintf("uart_scoreboard begin to do autocheck"), UVM_LOW)
    wait_reset();
    fork 
      `ifdef USE_UART_DRV
        crc_ecc_check();
        begin
          if(compare_uart2apb_flag() == 1) compare_uart2apb();
        end
      `endif
    join_none
  endtask: run_phase


  //------------------------------------------------------------------
  // crc & ecc compare
  //------------------------------------------------------------------
    `include "./uart_err_detect.sv"
  extern task crc_ecc_check();

  extern virtual function void write_reg_monitor(reg_item tr);
  extern virtual function void write_uart_driver(uart_sequence_item  tr);
  extern task compare_uart2apb();
  extern virtual function void do_comp(uart_sequence_item exp, reg_item obs);
  extern virtual function bit compare_uart2apb_flag();
  extern task wait_reset();

endclass :  uart_scoreboard

// -------------------------------------------------------------------------------
// reg -> uart trans
// -------------------------------------------------------------------------------
function void uart_scoreboard::write_reg_monitor(reg_item tr);
  // uart cmd -> xclk & mid, adandon fake item when state == IDLE
  if((vif.uart2apb_parser_state != 0) || (vif.uart2std_apb_cur_stat != 0)) begin
    if( (tr.addr >= REG_NONCEBUF_ADDR) && (tr.addr <= REG_NONCEBUF_ADDR + (REG_NONCEBUF_WIDTH - 1)*4) ) 
      `uvm_info(get_type_name(),$sformatf("Reg_noncebuf, skip uart2apb check"),UVM_LOW)
    else begin
      reg_mon_cnt++;
      tr.cnt = reg_mon_cnt;
      reg_trans_observed.push_back(tr);
    //`uvm_info(get_type_name(),$sformatf("reg_mon to uart_sbd item: %s", tr.sprint()), UVM_MEDIUM)
    end
  end // if(enable ==1)
endfunction : write_reg_monitor


// -------------------------------------------------------------------------------
// uart drv -> uart scoreboard
// mx2 reg, also transfer from uart utem to reg by apb bus
// -------------------------------------------------------------------------------
function void uart_scoreboard::write_uart_driver(uart_sequence_item  tr);
  if((tr.mode ==  'b01) || (tr.mode ==  'b00))begin
    if( (tr.addr >= REG_NONCEBUF_ADDR) && (tr.addr <= REG_NONCEBUF_ADDR + (REG_NONCEBUF_WIDTH - 1)*4) ) 
      `uvm_info(get_type_name(),$sformatf("Reg_noncebuf, skip uart2apb check"),UVM_LOW)
    else begin
      uart_mon_cnt++;
      tr.cnt = uart_mon_cnt;
      uart_trans_expected.push_back(tr);
    end
  end
endfunction:write_uart_driver

task uart_scoreboard::compare_uart2apb();
  uart_sequence_item exp;
  reg_item obs;

  `uvm_info(get_type_name(),$sformatf("compare_uart2apb is enabled"), UVM_MEDIUM)
  forever begin
    fork 
      begin
        wait(uart_trans_expected.size() > 0) 
        // NOTE: DEBUG INFO
        //`uvm_info(get_type_name(),$sformatf("uart_trans_expected size: %0d", uart_trans_expected.size()), UVM_MEDIUM)
        //foreach(uart_trans_expected[i])begin
        //  `uvm_info(get_type_name(),$sformatf("uart_trans_expected[%0d].addr: 'h%0h", i, uart_trans_expected[i].addr), UVM_MEDIUM)
        //end
        exp = uart_trans_expected.pop_front();
        //`uvm_info(get_type_name(),$sformatf("exp: \n%s",  exp.sprint()), UVM_MEDIUM)
      end
      begin
        wait(reg_trans_observed.size() > 0) 
        //`uvm_info(get_type_name(),$sformatf("reg_trans_observed size: %0d", reg_trans_observed.size()), UVM_MEDIUM)
        //foreach(reg_trans_observed[i])begin
        //  `uvm_info(get_type_name(),$sformatf("reg_trans_observed[%0d].addr: 'h%0h", i, reg_trans_observed[i].addr), UVM_MEDIUM)
        //end
        obs = reg_trans_observed.pop_front();
        //`uvm_info(get_type_name(),$sformatf("obs: \n%s",  obs.sprint()), UVM_MEDIUM)
      end
    join
    do_comp(exp, obs);
  end
endtask:compare_uart2apb


function void uart_scoreboard::do_comp(uart_sequence_item exp, reg_item obs);
  string info;

  info = {info, $sformatf("\n|----------------------------------------------------|")};
  info = {info, $sformatf("\n| UART SCOREBOARD REPORT                             |")};
  info = {info, $sformatf("\n|----------------------------------------------------|")};
  info = {info, $sformatf("\n|                | cnt  | we | addr      | data      |")};
  info = {info, $sformatf("\n|uart_tr expected|'d%3d |'b%b |'h%8h |'h%8h |",  exp.cnt,exp.we, exp.addr, exp.data  )};
  info = {info, $sformatf("\n|reg_tr  observed|'d%3d |'b%b |'h%8h |'h%8h |",  obs.cnt,obs.we, obs.addr, obs.data  )};

  if((exp.we == obs.we) && (exp.data == obs.data) && (exp.addr == obs.addr))
      `uvm_info(get_type_name(),$sformatf("%s", info),UVM_MEDIUM)
  else 
      `uvm_error(get_type_name(),$sformatf("%s", info))
endfunction:do_comp


// -------------------------------------------------------------------------------
// ecc & crc check
// -------------------------------------------------------------------------------
task uart_scoreboard::crc_ecc_check();
  forever begin
    bit [7:0] chkout_exp;
    string mode;
    
    @(vif.uart_clk);  //output is lower than input a delta cycle period
    @(vif.check_chkout);  

    wait( (vif.uart_fsm_x_state != 'd13) && (vif.uart_fsm_p_state != 'd13));  //STATE == TXID

    if(!vif.REG_UART_CHECK_MODE_SEL) begin
      chkout_exp = get_crc(vif.check_datain);
      mode = "CRC";
    end
    else  begin
      chkout_exp = get_ecc(vif.check_datain);
      mode = "ECC";
    end

    if(chkout_exp == vif.check_chkout)
      `uvm_info(get_type_name(), $sformatf("[%sSUCC] Uart transmit chkout_exp: 'h%0h == vif.check_chkout: 'h%0h", mode,chkout_exp, vif.check_chkout), UVM_HIGH)
    else 
      `uvm_error(get_type_name(), $sformatf("[%sERR] Uart transmit chkout_exp: 'h%0h != vif.check_chkout: 'h%0h", mode,chkout_exp, vif.check_chkout))
  end
endtask:crc_ecc_check
  

// -------------------------------------------------------------------------------
// POR reset
// -------------------------------------------------------------------------------
task uart_scoreboard::wait_reset();
  `uvm_info(get_type_name(), $sformatf("[Wait_RESET] Wait for reset"), UVM_MEDIUM)
  //#200;
  //force not on reset state
  //wait(top_vif.ri_rst_f_n === 1'b1);
  @ vif.uart_rst_done;
  repeat (32) @(posedge vif.uart_clk);

 `uvm_info(get_type_name(), $sformatf("[WAIT_RESET] Reset end"), UVM_MEDIUM)
endtask:wait_reset


// -----------------------------------------
// Method: compare_uart2apb_flag
//    Compare uart item to apb: we, addr, data
// NOTE: 
//    This task will not execute in multichip cases or cases with macro 'NO_COMPARE_UART2APB'
// -----------------------------------------
function bit uart_scoreboard::compare_uart2apb_flag();
   //bit compare_uart2apb_flag = 0 ;

    if(`CHIP_NUM == 1) compare_uart2apb_flag = 1;
    else compare_uart2apb_flag = 0;
    
    `ifdef NO_COMPARE_UART2APB
      compare_uart2apb_flag = 0;
    `endif

    `ifdef UART_ERRDETECT_ASSERT_OFF
      compare_uart2apb_flag = 0;
    `endif
  return compare_uart2apb_flag;
endfunction:compare_uart2apb_flag


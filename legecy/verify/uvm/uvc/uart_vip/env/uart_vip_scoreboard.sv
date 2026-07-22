
`ifndef GUARD_UART_SCOREBOARD_SV
`define GUARD_UART_SCOREBOARD_SV

/** Use uvm_analysis_imp_decl macros to declare analysis imp for scoreboard */
`uvm_analysis_imp_decl(_dte_tx)
`uvm_analysis_imp_decl(_dte_rx)
`uvm_analysis_imp_decl(_dce_tx)
`uvm_analysis_imp_decl(_dce_rx)

/**
 * Abstract: 
 * class 'uart_vip_scoreboard' is extended from uvm_scoreboard base class. 
 * It implements the comparison of uart transmiting and receiving transactions 
 * through DTE and DCE agent's monitors. 
 * 
 * uart_vip_scoreboard is the testbench environment component, which implements  
 * 
 * - Built in comparison transaction information between dte tx and dce rx agent monitor
 * - Built in comparison transaction information between dte rx and dce tx agent monitor
 * . 
 */
class uart_vip_scoreboard extends uvm_scoreboard;

  /** Analysis imp connected to the UART DTE Transmitter */
  uvm_analysis_imp_dte_tx #(svt_uart_transaction, uart_vip_scoreboard) item_collected_dte_tx;
  /** Analysis imp connected to the UART DTE Reciever */
  uvm_analysis_imp_dte_rx #(svt_uart_transaction, uart_vip_scoreboard) item_collected_dte_rx;
  /** Analysis imp connected to the UART DCE Transmitter */
  uvm_analysis_imp_dce_tx #(svt_uart_transaction, uart_vip_scoreboard) item_collected_dce_tx;
  /** Analysis imp connected to the UART DCE Reciever */
  uvm_analysis_imp_dce_rx #(svt_uart_transaction, uart_vip_scoreboard) item_collected_dce_rx;
  
  /** Queue used to compare DTE TX transaction and DCE RX transaction */
  svt_uart_transaction dte_trans_tx_for_dce_rx[$];
  /** Queue used to compare DTE RX transaction and DCE TX transaction */
  svt_uart_transaction dte_trans_rx_for_dce_tx[$];
  /** Queue used to compare DCE TX transaction and DTE RX transaction */
  svt_uart_transaction dce_trans_tx_for_dte_rx[$];
  /** Queue used to compare DCE RX transaction and DTE TX transaction */
  svt_uart_transaction dce_trans_rx_for_dte_tx[$];
  
  /** Instance of configuration class */
  svt_uart_configuration cfg; 

  /** Event to capture DTE TX transaction */
  event dte_tx_xact_observed; 
  /** Event to capture DTE RX transaction */
  event dte_rx_xact_observed; 
  /** Event to capture DCE TX transaction */
  event dce_tx_xact_observed; 
  /** Event to capture DCE RX transaction */
  event dce_rx_xact_observed; 
  
  /** variable to enable or disable scoreboard */
  bit enable = 1;
  
  /** variable to count number of transaction sent by DTE */
  int dte_tx_xact_count = 0;
  /** variable to count number of transaction recieved by DTE */
  int dte_rx_xact_count = 0;
  /** variable to count number of transaction sent by DCE */
  int dce_tx_xact_count = 0;
  /** variable to count number of transaction recieved by DCE */
  int dce_rx_xact_count = 0;
  
  /** variable to count number of mismatch in DTE and DCE transaction */
  int mismatch_count = 0; 

  logic [767:0]  noncebuf_act;
  int            idx = 0;
  int            tmp_idx = 7;
  int            skiped_cnt = 2;
  int            nonce_cnt_act = 3;
  int            autoreport;
  int            init_done;
  int            rd_count_done;
  int            rd_before_autoreport;
  int            if_compare = 0;
  int            work_round = 0;
  int            compare_cnt = 0;
  int            send_work_start = 0;


  work_ctrl_pkg::work_ctrl_mine_work m_work;
  work_ctrl_pkg::work_ctrl_mine_work m_work_pre;

  uvm_event one_work_done_ev;
  uvm_event compare_done_ev;
  uvm_event send_work_ev;

  virtual top_if top_vif;

  /** UVM Utility Macros*/
  `uvm_component_utils_begin(uart_vip_scoreboard)
    `uvm_field_int(enable, UVM_ALL_ON | UVM_NOPRINT)
    `uvm_field_int(dte_tx_xact_count, UVM_ALL_ON | UVM_NOPRINT)
    `uvm_field_int(dte_rx_xact_count, UVM_ALL_ON | UVM_NOPRINT)
    `uvm_field_int(dce_tx_xact_count, UVM_ALL_ON | UVM_NOPRINT)
    `uvm_field_int(dce_rx_xact_count, UVM_ALL_ON | UVM_NOPRINT)
    `uvm_field_int(mismatch_count, UVM_ALL_ON | UVM_NOPRINT)
    `uvm_field_object(cfg, UVM_ALL_ON | UVM_NOPRINT)
  `uvm_component_utils_end

  /** new - constructor */
  extern function new (string name = "uart_vip_scoreboard", uvm_component parent = null);
    
  /** build to create analysis ports and make a copy of the configuration after retriveing */
  extern virtual function void build_phase(uvm_phase phase);
 
  /** run phase to comapare transaction between DTE and DCE*/
  extern virtual task run_phase(uvm_phase phase);
  
  /** task to compare the transaction information between dte tx and dce rx agent monitor */
  extern task dte_tx_dce_rx_comparator();
    
  /** task to compare the transaction information between dte rx and dce tx agent monitor */
  extern task dce_rx_dte_tx_comparator();
 
  /** report phase to print the summery of transactions on bus*/
  extern virtual function void report_phase(uvm_phase phase);
 
  /** write_dte_tx */
  extern virtual function void write_dte_tx(svt_uart_transaction tr);
  
  /** write_dte_rx */
  extern virtual function void write_dte_rx(svt_uart_transaction tr);
  
  /** write_dce_tx */
  extern virtual function void write_dce_tx(svt_uart_transaction tr);
    
  /** write_dce_rx */
  extern virtual function void write_dce_rx(svt_uart_transaction tr);

  /** cfg_pattern */
  extern function bit cfg_pattern(svt_uart_transaction tr);
    
  /** compare transaction*/
  extern function void compare_transaction(int byte_no,
                                           svt_uart_transaction trans_1,
                                           string fst_obj_name="DTE",
                                           svt_uart_transaction trans_2,
                                           string sec_obj_name="DCE",
                                           string prefix= "BFM_MON_CMP",
                                           bit post_comp);

  extern function void compare_work_nonce(svt_uart_transaction trans_rx,work_ctrl_pkg::work_ctrl_mine_work exp_work);

endclass: uart_vip_scoreboard

//---------------------------------------------------------------------------------------------
// new()
//---------------------------------------------------------------------------------------------
function uart_vip_scoreboard::new (string name = "uart_vip_scoreboard", uvm_component parent = null);
  super.new(name, parent);
  m_work=new();
  m_work_pre=new();
endfunction: new

//---------------------------------------------------------------------------------------------
// build_phase()
//---------------------------------------------------------------------------------------------
function void uart_vip_scoreboard::build_phase(uvm_phase phase);
  
  super.build_phase(phase);

  one_work_done_ev = uvm_event_pool::get_global("one_work_done_ev");
  compare_done_ev = uvm_event_pool::get_global("compare_done_ev");
  send_work_ev = uvm_event_pool::get_global("send_work_ev");
  
  item_collected_dte_tx = new("item_collected_dte_tx", this);
  item_collected_dte_rx = new("item_collected_dte_rx", this);
  item_collected_dce_tx = new("item_collected_dce_tx", this);
  item_collected_dce_rx = new("item_collected_dce_rx", this);

  /** Retrieve the configuration from the config_db */
  if (cfg == null && !uvm_config_db#(svt_uart_configuration)::get(this,  "",  "cfg",  cfg))
    `uvm_fatal("uart_vip_scoreboard",$sformatf("'cfg' is null. An svt_uart_configuration object or derivitive object must be set using the configuration infrastructure."))

  if (!uvm_config_db#(work_ctrl_pkg::work_ctrl_mine_work)::get(null,  "uvm_test_top.top_env_h.uart_vip_env_h",  "m_work_pre",  m_work_pre))
    `uvm_fatal("uart_vip_scoreboard",$sformatf("'m_work_pre' is null"))
  else
    `uvm_info("uart_vip_scoreboard",$sformatf("got 'm_work_pre'"),UVM_MEDIUM)

  if(!uvm_config_db#(virtual top_if)::get(this , "" , "top_vif" ,top_vif))
    `uvm_error("TOP_VIF:ERROR", "VIF top_vif is missing from config_db")

endfunction: build_phase

//---------------------------------------------------------------------------------------------
// run_phase()
//---------------------------------------------------------------------------------------------
task uart_vip_scoreboard::run_phase(uvm_phase phase);
  begin
    fork
      begin :DTE_TX_DCE_RX_COMPARATOR
        dte_tx_dce_rx_comparator();
      end
      begin :DTE_RX_DCE_TX_COMPARATOR
        dce_rx_dte_tx_comparator();
      end
    join
  end
endtask: run_phase

//---------------------------------------------------------------------------------------------
// dte_tx_dce_rx_comparator()
//---------------------------------------------------------------------------------------------
task uart_vip_scoreboard::dte_tx_dce_rx_comparator();
  svt_uart_transaction dte_tx;
  svt_uart_transaction dce_rx;
  forever begin
    fork
      begin
        @(dte_tx_xact_observed);
        dte_tx = dte_trans_tx_for_dce_rx.pop_front();
      end
      begin
        @(dce_rx_xact_observed);
        dce_rx = dce_trans_rx_for_dte_tx.pop_front();
      end
    join
    
    compare_transaction(0,dte_tx, "dte_tx" ,dce_rx , "dce_rx" , "DTE_TX_DCE_RX_COMP",1); 
  end
endtask: dte_tx_dce_rx_comparator

//---------------------------------------------------------------------------------------------
// dce_rx_dte_tx_comparator()
//---------------------------------------------------------------------------------------------
task uart_vip_scoreboard::dce_rx_dte_tx_comparator();
  svt_uart_transaction dte_rx;
  svt_uart_transaction dce_tx;
  send_work_ev = uvm_event_pool::get_global("send_work_ev");

  forever begin
    fork
      begin
        @(dte_rx_xact_observed);
        dte_rx = dte_trans_rx_for_dce_tx.pop_front();
      end
      begin
        send_work_ev.wait_trigger();
        dte_rx_xact_count = 0;
        send_work_start = 1;
      end
    join_any
    disable fork;
    
    if ($test$plusargs("AUTOREPORT")) begin
      if(send_work_start == 1) begin
        compare_work_nonce(dte_rx,m_work_pre);
      end
    end
  end
endtask: dce_rx_dte_tx_comparator

function void uart_vip_scoreboard::compare_work_nonce(svt_uart_transaction trans_rx,work_ctrl_pkg::work_ctrl_mine_work exp_work);
  logic [79:0]   nonce_list[8];
  logic [127:0]  note;
  logic [31:0]   version[8];
  logic [31:0]   nonce[8];
  logic [7:0]    ntime[8];

  if ($test$plusargs("INSERT_REG")) begin
    if(dte_rx_xact_count == 8) begin
      if(trans_rx.payload[0] != 'h2) begin //2 is reading noncebuf
        dte_rx_xact_count = dte_rx_xact_count-15;//minus 15 is for reading the inserted register
      end
    end
  end

  idx = dte_rx_xact_count-10;
  `uvm_info("uart_vip_scoreboard",$sformatf("debug, idx = %0d",idx),UVM_MEDIUM)
  if ($test$plusargs("NONCE_CNT_MAX")) begin
    if( dte_rx_xact_count > 0 )
        `uvm_error("uart_vip_scoreboard",$psprintf("NONCE_CNT_MAX, expect no nonce auto report, actual received cnt: %0d",idx));
  end

//[767:0]  noncebuf, 768/32=24, if z_NonceBufCnt > 24, then set nonce_cnt_act=7;
  if( idx > 0 ) begin
    if (idx == 2) begin
      uvm_hdl_read("tb_top.C[0].btnode.btc.sys_ctrl.work_ctrl.z_NonceBufCnt",nonce_cnt_act);
    end
    if (idx%5 != 0) begin //pkt 5 is crc_pkt
      noncebuf_act[tmp_idx-:8] = trans_rx.payload[0];
      tmp_idx = tmp_idx+8;
      `uvm_info("uart_vip_scoreboard",$sformatf("debug, idx = %0d, dte_rx_xact_count= %0d, skiped_cnt=%0d,tmp_idx=%0d,nonce_cnt_act=%0d",idx,dte_rx_xact_count,skiped_cnt,tmp_idx,nonce_cnt_act),UVM_MEDIUM)
      `uvm_info("uart_vip_scoreboard",$sformatf("debug, noncebuf_act=%0h,trans_rx.payload[0]=%0h",noncebuf_act,trans_rx.payload[0]),UVM_MEDIUM)
    end
  end

  if(idx == nonce_cnt_act*5) begin

    note = noncebuf_act[127:0];

    //parse the nonce format in the noncebuf
    for(int i=0;i<8;i++)begin
        nonce_list[i]=noncebuf_act[128+i*80 +: 80];
        version[i]=nonce_list[i][63:32];
        nonce[i]=nonce_list[i][31:0];
        ntime[i]=nonce_list[i][71:64];
    end

    //check the note to be as expected
    if(exp_work.note === note) begin
        `uvm_info("checkNonceCorrect",$psprintf("work_round %0h, match note in the noncebuf, note:0x%0x",work_round, exp_work.note),UVM_MEDIUM);
    end
    else begin
        `uvm_error("checkNonceCorrect",$psprintf("work_round %0h, Please check the return note is as expected, expected: 0x%0x, actual: 0x%0x",work_round,exp_work.note, note));
    end
    //check the target nonce in the noncebuf
    for(int i=0;i<8;i++)begin
        if(exp_work.nonce0 === nonce[i])begin
            `uvm_info("checkNonceCorrect",$psprintf("work_round %0h, match %0d nonce in the noncebuf, nonce:0x%0x",work_round,i,nonce[i]),UVM_MEDIUM);
            break;
        end
        if(i==7)begin
            `uvm_error("checkNonceCorrect",$psprintf("work_round %0h, Please check the return nonce is as expected, expected: 0x%0x,  actual: 0x%0x",work_round,exp_work.nonce0,nonce[i]));
        end
    end
    //check the target version in the noncebuf
    for(int i=0;i<8;i++)begin
        if(exp_work.version === version[i])begin
            `uvm_info("checkNonceCorrect",$psprintf("work_round %0h, match %0d version in the noncebuf, version:0x%0x",work_round,i,version[i]),UVM_MEDIUM);
            break;
        end
        if(i==7)begin
            `uvm_error("checkNonceCorrect",$psprintf("work_round %0h, Please check the return version is as expected, expected: 0x%0x",work_round,exp_work.version));
        end
    end

    compare_cnt = compare_cnt+1;

    if_compare = 1;

    compare_done_ev = uvm_event_pool::get_global("compare_done_ev");
    if(compare_cnt == `CHIP_NUM) begin
      compare_done_ev.trigger();
      $display("time=%t,scoreboard, compare done",$time);
      compare_cnt = 0;
    end

    if (($test$plusargs("MULTI_WORK")) || (`CHIP_NUM == 4)) begin
        dte_rx_xact_count = 0;
        init_done = 1;
        noncebuf_act = 0;
        tmp_idx = 7;
        if ($test$plusargs("MULTI_WORK")) work_round = work_round+1;
    end

    if ($test$plusargs("TIMED_AUTOREPORT")) begin
      idx = 0;
      dte_rx_xact_count = 0;
      init_done = 0;
      noncebuf_act = 0;
      tmp_idx = 7;
    end

  end

endfunction

//---------------------------------------------------------------------------------------------
// report_phase()
//---------------------------------------------------------------------------------------------
function void uart_vip_scoreboard::report_phase(uvm_phase phase);
  if(enable) begin
    if(dte_trans_tx_for_dce_rx.size() != 0 || dce_trans_rx_for_dte_tx.size() != 0 || dte_trans_rx_for_dce_tx.size() != 0 || dce_trans_tx_for_dte_rx.size() != 0)     
      begin
        `uvm_info("uart_vip_scoreboard",$sformatf("Scoreboard Error/Warning : Some/Any of the queues still have pending objects :-"),UVM_MEDIUM)
        `uvm_info("uart_vip_scoreboard",$sformatf("dte_trans_tx_for_dce_rx.size()=%d, dce_trans_rx_for_dte_tx.size()=%d, dce_trans_rx_for_dte_tx.size()=%d, dce_trans_rx_for_dte_tx.size()=%d",
                                                  dte_trans_tx_for_dce_rx.size(), dce_trans_rx_for_dte_tx.size(), dce_trans_rx_for_dte_tx.size(), dce_trans_rx_for_dte_tx.size()),UVM_LOW)
      end
    else
      begin
        `uvm_info("uart_vip_scoreboard",$sformatf("Scoreboard Info : At the end of simulation all the queues are empty"),UVM_LOW)
      end

    `uvm_info("uart_vip_scoreboard",
                    $sformatf("\n\
                     --------------------------------------------------- \n\
                    | ScoreBoard Report                                 |\n\
                     --------------------------------------------------- \n\
                    | Transactions recieved by DTE    Tx Side       %5d |\n\
                    | Transactions recieved by DTE    Rx Side       %5d |\n\
                    | Transactions recieved by DCE    Tx Side       %5d |\n\
                    | Transactions recieved by DCE    Rx Side       %5d |\n\
                    | Mismatch in transactions                      %5d |\n\
                     --------------------------------------------------- ",
                    dte_tx_xact_count, dte_rx_xact_count,dce_tx_xact_count, dce_rx_xact_count, mismatch_count),UVM_LOW)
    
    //if((dte_tx_xact_count+ dte_rx_xact_count+dce_tx_xact_count+ dce_rx_xact_count) == 0)
    //  `uvm_error("uart_vip_scoreboard",$sformatf("Scoreboard Error : NO transaction observed on the bus"))
                         
    //if(dte_tx_xact_count != dce_rx_xact_count) 
    //  `uvm_error("uart_vip_scoreboard",$sformatf("Scoreboard Error : Mismatch detected in number of transaction of DTE Transmitter and DCE Reciever"))

    //if(dce_tx_xact_count != dte_rx_xact_count) 
    //  `uvm_error("uart_vip_scoreboard",$sformatf("Scoreboard Error : Mismatch detected in number of transaction of DCE Transmitter and DTE Reciever"))

    if(dte_tx_xact_count > dte_rx_xact_count) 
      `uvm_info("uart_vip_scoreboard",$sformatf("Scoreboard info : Mismatch detected in number of transaction of DTE Transmitter and DTE Reciever"),UVM_MEDIUM)

    if ((if_compare==0) && ($test$plusargs("AUTOREPORT")) && (!$test$plusargs("NONCE_CNT_MAX"))) //when set reg_uart_nonce_cnt_max to a large value, will not autoreport
      `uvm_error("uart_vip_scoreboard",$sformatf("Simulation finish, but not received nonce"))

  end
endfunction: report_phase

//---------------------------------------------------------------------------------------------
// write_dte_tx()
//---------------------------------------------------------------------------------------------
function void uart_vip_scoreboard::write_dte_tx(svt_uart_transaction tr);
  if(enable) begin
    dte_trans_tx_for_dce_rx.push_back(tr);
    dte_tx_xact_count ++;
    -> dte_tx_xact_observed;
  end
endfunction: write_dte_tx

//---------------------------------------------------------------------------------------------
// write_dte_rx()
//---------------------------------------------------------------------------------------------
function void uart_vip_scoreboard::write_dte_rx(svt_uart_transaction tr);
  bit pattern_detected = 0;
  if(enable) begin
     dte_rx_xact_count ++;
     if(send_work_start == 1) begin
       dte_trans_rx_for_dce_tx.push_back(tr);
       -> dte_rx_xact_observed;
     end
     //`uvm_info("uart_vip_scoreboard",$sformatf("sb_rx_got_trans = %0h",tr.payload[0]),UVM_MEDIUM) //DO
  end
endfunction: write_dte_rx

//---------------------------------------------------------------------------------------------
// write_dce_tx()
//---------------------------------------------------------------------------------------------
function void uart_vip_scoreboard::write_dce_tx(svt_uart_transaction tr);
  bit pattern_detected = 0;
  if(enable) begin   
      dce_trans_tx_for_dte_rx.push_back(tr);
      dce_tx_xact_count ++;
      -> dce_tx_xact_observed; 
  end
endfunction: write_dce_tx

//---------------------------------------------------------------------------------------------
// write_dce_rx()
//---------------------------------------------------------------------------------------------
function void uart_vip_scoreboard::write_dce_rx(svt_uart_transaction tr);
  if(enable) begin
    dce_trans_rx_for_dte_tx.push_back(tr);
    dce_rx_xact_count ++;
    -> dce_rx_xact_observed;
  end
endfunction: write_dce_rx

//---------------------------------------------------------------------------------------------
// cfg_pattern()
//---------------------------------------------------------------------------------------------
function bit uart_vip_scoreboard::cfg_pattern(svt_uart_transaction tr);
  case (cfg.data_width)
    
    5: 
      begin 
        if(tr.payload[0][4:0] == cfg.data_pattern_xon[4:0] || tr.payload[0][4:0] == cfg.data_pattern_xoff[4:0])
          cfg_pattern = 1;
      end
    6:  
      begin 
        if(tr.payload[0][5:0] == cfg.data_pattern_xon[5:0] || tr.payload[0][5:0] == cfg.data_pattern_xoff[5:0])
          cfg_pattern = 1;
      end
    7:
      begin 
        if(tr.payload[0][6:0] == cfg.data_pattern_xon[6:0] || tr.payload[0][6:0] == cfg.data_pattern_xoff[6:0])
          cfg_pattern = 1;
      end
    8: 
      begin 
        if(tr.payload[0][7:0] == cfg.data_pattern_xon[7:0] || tr.payload[0][7:0] == cfg.data_pattern_xoff[7:0])
          cfg_pattern = 1;
      end
    9:
      begin 
        if(tr.payload[0][8:0] == cfg.data_pattern_xon[8:0] || tr.payload[0][8:0] == cfg.data_pattern_xoff[8:0])
          cfg_pattern = 1;
      end
    10:
      begin 
        if(tr.payload[0][9:0] == cfg.data_pattern_xon[9:0] || tr.payload[0][9:0] == cfg.data_pattern_xoff[9:0])
          cfg_pattern = 1;
      end
    11:
      begin 
        if(tr.payload[0][10:0] == cfg.data_pattern_xon[10:0] || tr.payload[0][10:0] == cfg.data_pattern_xoff[10:0])
          cfg_pattern = 1;
      end
    12:
      begin 
        if(tr.payload[0][11:0] == cfg.data_pattern_xon[11:0] || tr.payload[0][11:0] == cfg.data_pattern_xoff[11:0])
          cfg_pattern = 1;
      end
  endcase
endfunction: cfg_pattern

//---------------------------------------------------------------------------------------------
// compare_transaction()
//---------------------------------------------------------------------------------------------
function void uart_vip_scoreboard::compare_transaction(int byte_no,
                                                   svt_uart_transaction trans_1,
                                                   string fst_obj_name = "DTE",
                                                   svt_uart_transaction trans_2,
                                                   string sec_obj_name = "DCE",
                                                   string prefix = "BFM_MON_CMP",
                                                   bit post_comp);
  
  svt_uart_transaction pre_bfm_trans;
  string mismatch_str,match_str;
  bit    mismatch_detected = 0;
  bit    mismatch_parity_detected = 0;
  bit    break_on_pre = 0;
  bit    break_on_post = 1;
  logic  [8:0] payload_lhs = 0,payload_rhs = 0;
  bit  temp_parity = 0;
  int    length = 0;
  
  /** store the payload values into two temporary varaible to do manipulation on them according to different condition like break, parity calculation */    
 case(cfg.data_width)
    
    5:
      begin
        payload_lhs = trans_1.payload[byte_no][4:0];
        payload_rhs = trans_2.payload[0][4:0];
      end
    6:
      begin
        payload_lhs = trans_1.payload[byte_no][5:0];
        payload_rhs = trans_2.payload[0][5:0];
      end
    7:
      begin
        payload_lhs = trans_1.payload[byte_no][6:0];
        payload_rhs = trans_2.payload[0][6:0];
      end
    8:
      begin
        payload_lhs = trans_1.payload[byte_no][7:0];
        payload_rhs = trans_2.payload[0][7:0];
      end
    9:
      begin
        payload_lhs = trans_1.payload[byte_no][8:0];
        payload_rhs = trans_2.payload[0][8:0];
      end
    10:
      begin
        payload_lhs = trans_1.payload[byte_no][9:0];
        payload_rhs = trans_2.payload[0][9:0];
      end
    11:
      begin
        payload_lhs = trans_1.payload[byte_no][10:0];
        payload_rhs = trans_2.payload[0][10:0];
      end
    12:
      begin
        payload_lhs = trans_1.payload[byte_no][11:0];
        payload_rhs = trans_2.payload[0][11:0];
      end
  endcase // case(cfg.data_width)

  
  /** for pre comparision manipulate the pre data, make it zero, if break condition is inserted */     
  if(!post_comp)
    begin
      if($cast(pre_bfm_trans,trans_1))
        begin
          if(pre_bfm_trans.break_cond == 1'b1)
            payload_lhs = 0;
        end
    end // if (!post_comp)
  
  /** after manipulation on data(for pre case), compare the data of both the objects to be compared */      
  if(payload_lhs !== payload_rhs)
    begin
      $sformat(mismatch_str,"%s : Trans Data Mismatch between %s value is %0b and %s value is %0b ",prefix,fst_obj_name,payload_lhs,sec_obj_name,payload_rhs);
      `uvm_error("uart_vip_scoreboard",mismatch_str)
      mismatch_detected = 1;
    end
  else
    begin
      $sformat(match_str,"%s : Trans Data match between %s value is %h and %s value is %h ",prefix,fst_obj_name,payload_lhs,sec_obj_name,payload_rhs);
      `uvm_info("uart_vip_scoreboard",match_str,UVM_LOW)
    end       
  
  /** for pre comparision calculate the parity value according to the type of parity set and the payload value driven also invert calculated correct parity if the invalid parity is inserted */
  if(!post_comp)
    begin
      for(int i = 0; i<cfg.data_width; i=i+1)
        temp_parity = payload_lhs[i]^temp_parity;
      if(cfg.parity_type == svt_uart_configuration::ODD_PARITY)
        temp_parity = ~temp_parity;
      else if(cfg.parity_type == svt_uart_configuration::STICK_LOW_PARITY)
        temp_parity = 1'b0;
      else if(cfg.parity_type == svt_uart_configuration::STICK_HIGH_PARITY)
        temp_parity = 1'b1;
      
      if(pre_bfm_trans.break_cond == 1'b1)
        begin
          break_on_pre = 1;
        end
      trans_1.received_parity[0] = temp_parity;
    end
  
  /** if the break is detected on post object indicated by  break_on_post=1 value */
  if(post_comp)
    begin
      if(cfg.parity_type == svt_uart_configuration::NO_PARITY)
        length = 1 + cfg.data_width + cfg.stop_bit;
      else
        length = 1+ cfg.data_width+1 + cfg.stop_bit;
      if(trans_1.received_packet[0] !== 0)
        break_on_post = 1'b0;
    end
  else
    break_on_post = 1'b0;                  //for pre comparison set break_on_post to zero
  
  /** compare the parity value if parity set is not NO_PARITY and no break is detected on the line */   
  if(!((cfg.parity_type == svt_uart_configuration::NO_PARITY) || (break_on_pre == 1) ||(break_on_post == 1)))
    begin
      if(trans_1.received_parity[0] !== trans_2.received_parity[0])
        begin
          $sformat(mismatch_str,"%s : Parity Mismatch between %s value is %h and %s value is %h ",prefix,fst_obj_name,trans_1.received_parity[0],sec_obj_name,trans_2.received_parity[0]);
          `uvm_error("uart_vip_scoreboard",mismatch_str)
          mismatch_parity_detected = 1;
        end
      else
        begin
          $sformat(match_str,"%s : Parity Matches between %s value is %h and %s value is %h ",prefix,fst_obj_name,trans_1.received_parity[0],sec_obj_name,trans_2.received_parity[0]);
          `uvm_info("uart_vip_scoreboard",match_str,UVM_LOW)
        end
    end
  
  /** if any mismatch in data or parity increment the mismatch_count */     
  if(mismatch_detected || mismatch_parity_detected)
    mismatch_count ++;
endfunction: compare_transaction

`endif // `ifndef GUARD_UART_SCOREBOARD_SV

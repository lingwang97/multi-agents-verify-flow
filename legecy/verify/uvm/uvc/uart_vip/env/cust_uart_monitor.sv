`uvm_analysis_imp_decl(_mon_dte_rx)
`uvm_analysis_imp_decl(_mon_dte_tx)

class cust_uart_monitor extends base_monitor;

  uvm_analysis_port #(cust_svt_uart_transaction) rx_xact_ap;
  uvm_analysis_imp_mon_dte_rx #(svt_uart_transaction, cust_uart_monitor) item_collected_dte_rx;
  uvm_analysis_imp_mon_dte_tx #(svt_uart_transaction, cust_uart_monitor) item_collected_dte_tx;
  svt_uart_transaction dte_trans_rx[$];
  svt_uart_transaction dte_trans_tx[$];

  event dte_rx_xact_observed;
  event dte_tx_xact_observed;
  int dte_rx_xact_count = 0;
  int dte_tx_xact_count = 0;
  int tmp_for_init      = 0;
  int len_tmp           = 0;
  int chip_tmp          = 0;
  int chip_tmp1         = 0;

  bit [31:0] data_frame[];
  bit [`UVM_REG_DATA_WIDTH-1:0] data;
  bit [31:0] addr_tmp;
  bit [31:0] addr_tmp_wr;
  bit [31:0] addr_tmp1;

  int len = 1;
  int wr_len = 1;
  int len_noncereg[`CHIP_NUM];
  int noncereg_total_len = 0;
  int nonce_empty = 1;
  bit[39:0] init_done_value = 0;
  bit[31:0] received_chipid = 0;
  int chip_id_return    ;
  int chip_id_tmp = 0;
  int chip_id_tmp_pre = 0;
  int payload_total_size = 0;
  int header_err;
  bit[39:0] dte_trans_rx_header = 0;
  bit[39:0] dte_trans_tx_header = 0;

  int insertreg_nonce = 0;
  int delete_cnt = 0;

  bit[9:0] startchipid=0;

  uvm_event rd_done_ev;
  uvm_event wr_done_ev;
  uvm_event init_done_ev;

  bit[31:0] reg_addr[$];
  bit[31:0] exp_reg_addr[$];

  `uvm_component_utils(cust_uart_monitor);

  cust_svt_uart_transaction rx_xact;
  cust_svt_uart_transaction tx_xact;

  svt_uart_vif      dte_vif;
  virtual uart_if   uart_vif;
  virtual top_if    top_vif;
  
  extern task compare_addr();
  extern task compare_fbdo_status();
  extern virtual task write_adapter();
  extern virtual task read_adapter();
  extern virtual task softrst_watchdog();
  extern virtual function void write_mon_dte_rx(svt_uart_transaction tr);
  extern virtual function void write_mon_dte_tx(svt_uart_transaction tr);
  extern virtual function void rd_ap_write();
  extern virtual function void wr_ap_write();


  function new(string name="cust_uart_monitor" , uvm_component parent=null);
    super.new(name , parent);
    rx_xact_ap = new("rx_xact_ap",this);
    rx_xact = cust_svt_uart_transaction::type_id::create("rx_xact");
    tx_xact = cust_svt_uart_transaction::type_id::create("tx_xact");
  endfunction
 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    item_collected_dte_rx = new("item_collected_dte_rx", this);
    item_collected_dte_tx = new("item_collected_dte_tx", this);

    if (!uvm_config_db#(svt_uart_vif)::get(null, "uvm_test_top.top_env_h.uart_vip_env_h", "dte_vif", dte_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
    if(!uvm_config_db#(virtual top_if)::get(this , "" , "top_vif" ,top_vif))
      `uvm_error("TOP_VIF:ERROR", "VIF top_vif is missing from config_db")
    if (!uvm_config_db#(virtual uart_if)::get(null, "uvm_test_top.top_env_h.uart_env_h", "uart_vif", uart_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    foreach (len_noncereg[i]) len_noncereg[i] = 1;

    rd_done_ev = uvm_event_pool::get_global("rd_done_ev"); 

    fork
      begin
        forever begin
          @dte_tx_xact_observed;
          write_adapter();
        end
      end

      begin
        forever begin
          @dte_rx_xact_observed;
          read_adapter();
        end
      end

      `ifndef UART_VIP_GLS
      begin
      `ifdef PL_SIM
        #800; //soft rst is X at beginning of simulation
      `endif
        forever begin
          softrst_watchdog();
        end
      end
      `endif

      if (($test$plusargs("ADDR_CHECK")) && (`CHIP_NUM == 1)) begin
        compare_addr();
      end

      if (($test$plusargs("FC_CHECK")) && (`CHIP_NUM > 1)) begin
        compare_fbdo_status();
      end

    join
  endtask

endclass


function void cust_uart_monitor::write_mon_dte_rx(svt_uart_transaction tr);

  dte_trans_rx.push_back(tr);
  dte_rx_xact_count ++;
  -> dte_rx_xact_observed;

  $display("[write_mon_dte_rx] %t debug, dte_rx_xact_count = %0d, size = %0d, tr= %0h",$time,dte_rx_xact_count,dte_trans_rx.size(),tr.payload[0]);
endfunction: write_mon_dte_rx

function void cust_uart_monitor::write_mon_dte_tx(svt_uart_transaction tr);

  dte_trans_tx.push_back(tr);
  dte_tx_xact_count ++;
  -> dte_tx_xact_observed;

  //$display("[write_mon_dte_tx] %t debug, dte_tx_xact_count = %0d, size = %0d, tr= %0h",$time,dte_tx_xact_count,dte_trans_tx.size(),tr.payload[0]);
endfunction: write_mon_dte_tx

task cust_uart_monitor::write_adapter();
  if (!$test$plusargs("SEQ_WR")) begin
      if (`CHIP_NUM == 1) begin
        if (dte_trans_tx.size() == 10) begin
          dte_trans_tx_header = { dte_trans_tx[4].payload[0][7:0],
                                  dte_trans_tx[3].payload[0][7:0],
                                  dte_trans_tx[2].payload[0][7:0],
                                  dte_trans_tx[1].payload[0][7:0],
                                  dte_trans_tx[0].payload[0][7:0]};
          if ( dte_trans_tx_header == top_vif.HEADER) begin
            if(dte_trans_tx[6].payload[0][3:2] == 'b01)begin //write
              wr_len = dte_trans_tx[8].payload[0];
              //$display("wr_len=%0d",wr_len);
            end
          end
        end

        if (((dte_trans_tx.size() == 15) && (dte_trans_tx[6].payload[0][3:2] == 'b11)) ||  //init
            ((dte_trans_tx.size() == 10) && (dte_trans_tx[6].payload[0][3:2] == 'b10)) ||  //baud
            ((dte_trans_tx.size() == 10) && (dte_trans_tx[6].payload[0][3:2] == 'b11) && (dte_trans_tx[6].payload[0][7:4] == 'b0000)) ||  //chipid clear
            ((dte_trans_tx.size() == 10) && (dte_trans_tx[6].payload[0][3:2] == 'b00)))begin //read
            dte_trans_tx.delete();
            dte_tx_xact_count = 0;
        end

        // write ap for svt_uart_reg_adapter to predict
        wr_ap_write();

      end
  end
endtask:write_adapter

task cust_uart_monitor::read_adapter();
     if ($value$plusargs("UART_VIP_START_ID=%d", startchipid))
       received_chipid = startchipid+1;
     else
       received_chipid = `CHIP_NUM;

      init_done_value = {get_crc(received_chipid),received_chipid};


      // check header
      if (dte_trans_rx.size()==10) begin
        dte_trans_rx_header = { dte_trans_rx[4].payload[0][7:0],
                                dte_trans_rx[3].payload[0][7:0],
                                dte_trans_rx[2].payload[0][7:0],
                                dte_trans_rx[1].payload[0][7:0],
                                dte_trans_rx[0].payload[0][7:0]};
      `uvm_info(get_type_name(),$sformatf("[UART RECEIVE PACKET] received_chipid=%0h,init_done_value=%0h",received_chipid,init_done_value),UVM_MEDIUM)

        if (dte_trans_rx_header != top_vif.HEADER) begin
          if(!$value$plusargs("header_err=%0d",header_err))
            `uvm_error(get_type_name(),$sformatf("[UART RECEIVE PACKET] head frame failed, %0h!",dte_trans_rx_header) )
        end else begin
          `uvm_info(get_type_name(),$sformatf("[UART RECEIVE PACKET] head frame check pass"),UVM_MEDIUM)
        end
      end

      if (dte_trans_rx.size()>=11) begin //init may have one more ff in 11th rx
        if ({dte_trans_rx[$-6].payload[0][7:0],
             dte_trans_rx[$-7].payload[0][7:0],
             dte_trans_rx[$-8].payload[0][7:0],
             dte_trans_rx[$-9].payload[0][7:0],
             dte_trans_rx[$-10].payload[0][7:0]} == top_vif.HEADER) begin // in case of brd read
          if (dte_trans_rx[$-4].payload[0][3:2] == 'h3) begin //init
              len = 1;
              if  (dte_trans_rx[$].payload[0][7:0] == 'hff) top_vif.uart_init_16rx = 1;
              else top_vif.uart_init_16rx = 0;
          end
        end
      end

      // got brd/single rd's len, chipid, nonce_reg info, etc from rx
      if (top_vif.chipaddr != `BRD_ADDR) begin //single rd
        if (dte_trans_rx.size() == 10) begin //to deal with nonce_empty
          if ({dte_trans_rx[4].payload[0][7:0],
               dte_trans_rx[3].payload[0][7:0],
               dte_trans_rx[2].payload[0][7:0],
               dte_trans_rx[1].payload[0][7:0],
               dte_trans_rx[0].payload[0][7:0]} == top_vif.HEADER) begin // in case of brd read
            if (dte_trans_rx[6].payload[0][3:2] == 'h0) begin //read
                len = dte_trans_rx[8].payload[0];
                chip_id_tmp = {dte_trans_rx[6].payload[0][1:0],dte_trans_rx[5].payload[0][7:0]};
                len_noncereg[chip_id_tmp-startchipid] = dte_trans_rx[8].payload[0][7:0];
                if ({dte_trans_rx[7].payload[0][7:0],dte_trans_rx[6].payload[0][7:4],2'b00} == 'ha0 ) begin
                  noncereg_total_len = `NONCE_WORD_NUM-1;
                  //nonce_empty = dte_trans_rx[6].payload[0][2];
                  nonce_empty = dte_trans_rx[8].payload[0][7:0];
                end
            end
          end
        end
      end else begin //brd read, has many header
        if (dte_trans_rx.size() > 10) begin
          if ({dte_trans_rx[$-6].payload[0][7:0],
               dte_trans_rx[$-7].payload[0][7:0],
               dte_trans_rx[$-8].payload[0][7:0],
               dte_trans_rx[$-9].payload[0][7:0],
               dte_trans_rx[$-10].payload[0][7:0]} == top_vif.HEADER) begin // in case of brd read
            if (dte_trans_rx[$-4].payload[0][3:2] == 'h0) begin //read
                len = dte_trans_rx[$-2].payload[0][7:0];
                chip_id_tmp = {dte_trans_rx[$-4].payload[0][1:0],dte_trans_rx[$-5].payload[0][7:0]};
                len_noncereg[chip_id_tmp] = dte_trans_rx[$-2].payload[0][7:0];
                noncereg_total_len = `NONCE_WORD_NUM-1;
                nonce_empty = dte_trans_rx[$-2].payload[0][7:0];
                //$display("len=%0d,chip_id_tmp=%0d,len_noncereg=%0d,noncereg_total_len=%0d",len,chip_id_tmp,len_noncereg[chip_id_tmp],noncereg_total_len);
                if($test$plusargs("INSERT_REG")) begin
                  if( {dte_trans_rx[$-4].payload[0][7:0],dte_trans_rx[$-5].payload[0][7:4],2'b00} == 'ha0 ) begin
                    insertreg_nonce = 1;
                    //$display("insertreg_nonce=1");
                  end
                end
            end
          end
        end
        if ((dte_trans_rx.size() == 10) && (!$test$plusargs("INSERT_REG")))begin //do with noncebuf empty, only have 10 frames
          if ({dte_trans_rx[$-5].payload[0][7:0],
               dte_trans_rx[$-6].payload[0][7:0],
               dte_trans_rx[$-7].payload[0][7:0],
               dte_trans_rx[$-8].payload[0][7:0],
               dte_trans_rx[$-9].payload[0][7:0]} == top_vif.HEADER) begin // in case of brd read
            if (dte_trans_rx[$-3].payload[0][3:2] == 'h0) begin //read
                len = dte_trans_rx[$-1].payload[0][7:0];
                chip_id_tmp = {dte_trans_rx[$-3].payload[0][1:0],dte_trans_rx[$-4].payload[0][7:0]};
                len_noncereg[chip_id_tmp] = dte_trans_rx[$-1].payload[0][7:0];
                noncereg_total_len = `NONCE_WORD_NUM-1;
                nonce_empty = dte_trans_rx[$-1].payload[0][7:0];
            end
          end
        end

        if (insertreg_nonce == 1) begin
          if (delete_cnt < len*5) begin
            dte_trans_rx.pop_back();
            delete_cnt = delete_cnt+1;
          end
          if (delete_cnt == len*5) begin
            //$display("insertreg_nonce=3");
            insertreg_nonce = 0;
            delete_cnt = 0;
            repeat(10) dte_trans_rx.pop_back();//delete nonce_return cmd's header/cmd
          end
        end

      end

      // init_done ev, check returned chipid
      if (dte_trans_rx.size()>10) begin
        if (dte_trans_rx[6].payload[0][3:2] == 'h3) begin //init
            if( {dte_trans_rx[$-0].payload[0][7:0],
                 dte_trans_rx[$-1].payload[0][7:0],
                 dte_trans_rx[$-2].payload[0][7:0],
                 dte_trans_rx[$-3].payload[0][7:0],
                 dte_trans_rx[$-4].payload[0][7:0]} == init_done_value ) begin

                chip_id_return = {dte_trans_rx[$-3].payload[0][1:0],dte_trans_rx[$-4].payload[0][7:0]};
                dte_trans_rx.delete(); // init_done
                len = 1;
                dte_rx_xact_count = 0;
                init_done_ev = uvm_event_pool::get_global("init_done_ev"); 
                init_done_ev.trigger();

      		if (chip_id_return == received_chipid )  //0 should be chip_start number
                  `uvm_info(get_type_name(), $sformatf("[cust_uart_monitor] \n\n\t******UART CHIP INIT RX READBACK\n\t******Retune Value(ChipId+1):<   %0d   >\n\t******SENDING TRIGGER******\n\n ",chip_id_return), UVM_MEDIUM)
      		else
                  `uvm_error(get_type_name(),$sformatf("[cust_uart_monitor]  RECEIVE PACKET: chip_id returned:%0d, should be:%0d",chip_id_return,received_chipid) )
            end
        end
      end

      if (dte_trans_rx.size() == 10) begin
        if ((dte_trans_rx[6].payload[0][3:2] == 'h3) && (dte_trans_rx[6].payload[0][7:4] == 'h0) ) begin //init
                dte_trans_rx.delete(); // init_done
                dte_rx_xact_count = 0;
        end
      end


      // calculate the needed return RX cnt for a read trans
      if ( (dte_trans_rx.size() > 14)  && (dte_trans_rx[6].payload[0][3:2] == 'b00))begin
        $display("RX_debug0,1=%0d,2=%0d,3=%0d,4=%0h,,,,,uart_vif.targetchipid=%0h",chip_id_tmp,uart_vif.targetchipid,tmp_for_init,top_vif.chipaddr,uart_vif.targetchipid);
        if (!$test$plusargs("SEQ_WR")) begin
          $display("chip_id_tmp=%0d, uart_vif.targetchipid=%0d,tmp_for_init=%0d, top_vif.chipaddr=%0d ",chip_id_tmp,uart_vif.targetchipid,tmp_for_init,top_vif.chipaddr);
          if ( (chip_id_tmp == uart_vif.targetchipid) && (tmp_for_init == 0) && (top_vif.chipaddr == `BRD_ADDR) ) begin // broad_rd
            foreach(len_noncereg[i]) begin
              if(i<=uart_vif.targetchipid)
                payload_total_size = payload_total_size+len_noncereg[i];
            end
            payload_total_size = payload_total_size*5+10*(uart_vif.targetchipid+1);
            tmp_for_init = 1;
          end
          if ((top_vif.chipaddr != `BRD_ADDR) && (tmp_for_init == 0))begin // single_rd
$display("aaa1");
            payload_total_size = len_noncereg[chip_id_tmp-startchipid]*5+10;
            tmp_for_init = 1;
          end
          //$display("payload_total_size=%0d",payload_total_size);
          //foreach(len_noncereg[i])
        end else begin
          if (tmp_for_init == 0) begin
            payload_total_size = payload_total_size+len_noncereg[chip_id_tmp];
            payload_total_size = payload_total_size*5+10;
            tmp_for_init = 1;
          end

          if (`CHIP_NUM == 1) begin
            payload_total_size = 10+len_noncereg[chip_id_tmp]*5;
            chip_id_tmp = 0;
          end
        end

        if (($test$plusargs("INSERT_REG")) && (`CHIP_NUM == 4)) begin//case multi_chip_single_work_reg, 4chip, reg rx cnt
            payload_total_size = 60;
        end
        
      end

      // write ap for svt_uart_reg_adapter to predict
      rd_ap_write();

endtask:read_adapter

task cust_uart_monitor::softrst_watchdog();
   @(negedge uart_vif.uart_softrst_mc_flag);
   $display("softrst_watchdog detect,%t",$time);
   #8600; //wait the wrong RX of rd spdlog
   `uvm_info(get_type_name(), $sformatf("[cust_uart_monitor] detect softrst, reset dte_trans cnt"), UVM_MEDIUM)
   dte_trans_rx.delete();
   dte_trans_tx.delete();
   len = 1;
   foreach (len_noncereg[i]) len_noncereg[i] = 0;
   dte_rx_xact_count = 0;
   dte_tx_xact_count = 0;
   tmp_for_init = 0;
   payload_total_size = 0;
endtask:softrst_watchdog


task cust_uart_monitor::compare_addr();
  $display("got rd_done begin");
  repeat(13)rd_done_ev.wait_trigger();
  $display("got rd_done end");

  foreach (reg_addr[i])
    `uvm_info(get_type_name(), $sformatf("[cust_uart_monitor] seq_read, addr[%0d]= %0h",i,reg_addr[i]), UVM_MEDIUM)

  //exp_reg_addr = {'h208,'h3ca0,'h20c,'h210,'h3c90,'h214,'h218,'h224,'h230,'h404,'h408,'h40c,'h410};
  exp_reg_addr = {'h208,'h3ca0,'h20c,'h210,'h3c90,'h214,'h218,'h228,'h234,'h404,'h408,'h40c,'h410};

  for(int ii=0;ii<reg_addr.size;ii++) begin
    if(reg_addr[ii] != exp_reg_addr[ii]) begin
      `uvm_error(get_type_name(),$sformatf("[compare_addr_seq] mismatch, i=%0d, act_reg_addr[i] %0h != exp_reg_addr[i] %0h",ii,reg_addr[ii],exp_reg_addr[ii]) )
    end else begin
      `uvm_info(get_type_name(),$sformatf("[compare_addr_seq] match, i=%0d, act_reg_addr[i] %0h == exp_reg_addr[i] %0h",ii,reg_addr[ii],exp_reg_addr[ii]),UVM_LOW)
    end
  end
endtask:compare_addr

task cust_uart_monitor::compare_fbdo_status();
  forever begin
    @(posedge uart_vif.pll_clk);
    if(uart_vif.fbdo_tx_pll_busy.sum>1) begin
      `uvm_error(get_type_name(),$sformatf("[check_fc] CHIP0&CHIP1 fbdo_tx_busy simultaneously") )
      #20000;
      $finish;
    end
  end
endtask:compare_fbdo_status

function void cust_uart_monitor::rd_ap_write();
    if (  ((dte_trans_rx.size() == payload_total_size) && (dte_trans_rx.size() > 14))||
          (  ((nonce_empty == 0) && (dte_trans_rx.size() == 10)) &&
             ({dte_trans_rx[7].payload[0][7:0],dte_trans_rx[6].payload[0][7:4],2'b00} == 'ha0 ) &&
             (dte_trans_rx[6].payload[0][3:2] == 'b00) 
          )
       ) begin
      //$display("debug00,%t,8 =%0h, len=%0d",$time,dte_trans_rx[8].payload[0][7:0],len);
      //if (((dte_trans_rx[6].payload[0][1:0] == 'h0) && (dte_trans_rx[8].payload[0][7:0] == len )) ||
      if ((dte_trans_rx[6].payload[0][3:2] == 'h0 ) ||
           ((nonce_empty == 0) && (((dte_trans_rx.size() == 11) && (top_vif.uart_init_16rx)) || (((dte_trans_rx.size() == 10) && (~top_vif.uart_init_16rx))))) 
         ) begin
        rx_xact.direction    = cust_svt_uart_transaction::RX;
        if(nonce_empty == 0) begin
          rx_xact.payload      = new[`NONCE_WORD_NUM+10];
          rx_xact.packet_count = `NONCE_WORD_NUM+10;
        end else begin
          rx_xact.payload      = new[payload_total_size];
          rx_xact.packet_count = payload_total_size;

          for (int tmp=0;tmp<payload_total_size;tmp=tmp+1) begin
            rx_xact.payload[tmp] = dte_trans_rx[tmp].payload[0];
          end
        end

        addr_tmp = {dte_trans_rx[7].payload[0][7:0],dte_trans_rx[6].payload[0][7:4],2'b00};
        addr_tmp1 = addr_tmp;

        if (!(nonce_empty == 0)) begin
        //{{{
          if (!$test$plusargs("SEQ_WR")) begin
//{{{
            if (top_vif.chipaddr != `BRD_ADDR)begin
                 data_frame = new[len_noncereg[chip_id_tmp-startchipid]];
                 for (int len_i = 0; len_i <= (len_noncereg[chip_id_tmp-startchipid]-1); len_i++) begin
                   data_frame[len_i] = {dte_trans_rx[13+chip_tmp1].payload[0][7:0],
                                        dte_trans_rx[12+chip_tmp1].payload[0][7:0],
                                        dte_trans_rx[11+chip_tmp1].payload[0][7:0],
                                        dte_trans_rx[10+chip_tmp1].payload[0][7:0]};
                   chip_tmp1 = chip_tmp1+5;

                   rx_xact.data = data_frame[len_i];
                   rx_xact.addr = addr_tmp;
                   addr_tmp = addr_tmp+4;
                   rx_xact_ap.write(rx_xact);
                   `uvm_info(get_type_name(), $sformatf("data=%0h,addr = %0h,len_i=%0h,chip_id_tmp=%0h,data_frame[len_i]=%0h",rx_xact.data,rx_xact.addr,len_i,chip_id_tmp,data_frame[len_i]), UVM_MEDIUM)
                   reg_addr.push_back(rx_xact.addr);
                   top_vif.noncebuf_data_o[chip_id_tmp][len_i] = rx_xact.data;
                 end
                 chip_tmp1 = 0;
            end else begin
               for(int chip_i=0;chip_i<=uart_vif.targetchipid;chip_i++) begin

                 data_frame = new[len_noncereg[chip_i]];
                 `uvm_info(get_type_name(), $sformatf("chip_i=%0h, targetchipid = %0h,",chip_i,uart_vif.targetchipid), UVM_MEDIUM)

                 if (chip_i!=0) begin
                   for(int chip_ii = 1;chip_ii<=chip_i;chip_ii++) begin
                     chip_tmp = 10+(len_noncereg[chip_i-chip_ii])*5;
                     chip_tmp1 = chip_tmp1+chip_tmp;
                   end
                 end

                 for (int len_i = 0; len_i <= (len_noncereg[chip_i]-1); len_i++) begin
                   data_frame[len_i] = {       dte_trans_rx[13+chip_tmp1].payload[0][7:0],
                                               dte_trans_rx[12+chip_tmp1].payload[0][7:0],
                                               dte_trans_rx[11+chip_tmp1].payload[0][7:0],
                                               dte_trans_rx[10+chip_tmp1].payload[0][7:0]};
                   chip_tmp1 = chip_tmp1+5;

                   rx_xact.data = data_frame[len_i];
                   rx_xact.addr = addr_tmp;
                   addr_tmp = addr_tmp+4;
                   if ((len_i < len_noncereg[0]) && (chip_i == 0)) begin
                   // only predict chip0; len>0, ap write more times for predictor will collect the multiple bus transactions
                      rx_xact_ap.write(rx_xact);
                      reg_addr.push_back(rx_xact.addr);
                   end
                   top_vif.noncebuf_data_o[chip_i][len_i] = rx_xact.data;
                 end

                 chip_tmp          = 0;
                 chip_tmp1         = 0;

               end
            end
          end else begin
            data_frame = new[len_noncereg[chip_id_tmp]];
            for (int len_i = 0; len_i < len_noncereg[chip_id_tmp]; len_i++) begin
              data_frame[len_i] = {dte_trans_rx[13+len_i*5].payload[0][7:0],
                                   dte_trans_rx[12+len_i*5].payload[0][7:0],
                                   dte_trans_rx[11+len_i*5].payload[0][7:0],
                                   dte_trans_rx[10+len_i*5].payload[0][7:0]};
              rx_xact.data = data_frame[len_i];
              rx_xact.addr = addr_tmp;
              addr_tmp = addr_tmp+4;
              rx_xact_ap.write(rx_xact);
              if (!((dte_trans_rx[7].payload[0][7:0] == 'hc0) && ($test$plusargs("UART_PLL_MODE"))))
                reg_addr.push_back(rx_xact.addr);
                //`uvm_info(get_type_name(), $sformatf("data=%0h,addr = %0h,len_i=%0h,chip_id_tmp=%0h,data_frame[len_i]=%0h",rx_xact.data,rx_xact.addr,len_i,chip_id_tmp,data_frame[len_i]), UVM_MEDIUM)
            end
//}}}
          end
           if ({dte_trans_rx[7].payload[0][7:0],dte_trans_rx[6].payload[0][7:4],2'b00} == 'ha0)begin
             if(`CHIP_NUM > 1) len_tmp = len_noncereg[0];
             else len_tmp = len;

             addr_tmp1 = addr_tmp1+4*len_tmp;

             for (int len_i = (len_tmp); len_i <= noncereg_total_len; len_i++) begin
               rx_xact.data = 32'h0;
               rx_xact.addr = addr_tmp1;
               addr_tmp1 = addr_tmp1+4;
               rx_xact_ap.write(rx_xact);
             end
           end
        end else begin //if (!nonce_empty) begin
           for (int len_i = 0; len_i <= (`NONCE_WORD_NUM-1); len_i++) begin
             rx_xact.data = 32'h0;
             rx_xact.addr = addr_tmp;
             addr_tmp = addr_tmp+4;
             rx_xact_ap.write(rx_xact);
           end
        //}}}
        end

        rd_done_ev.trigger();

        `uvm_info(get_type_name(), $sformatf("[cust_uart_monitor] rd_adapter done"), UVM_MEDIUM)

        dte_trans_rx.delete(); // a read_done
        len = 1;
        foreach (len_noncereg[i]) len_noncereg[i] = 1;
        dte_rx_xact_count = -1;
        tmp_for_init = 0;
        payload_total_size = 0;

      end
    end
endfunction:rd_ap_write

function void cust_uart_monitor::wr_ap_write();
    if ((dte_trans_tx.size() == (10+wr_len*5)) && (dte_trans_tx[6].payload[0][3:2] == 'b01)) begin //write

        tx_xact.payload      = new[dte_trans_tx.size()+1];
        tx_xact.packet_count = dte_trans_tx.size()+1;

        for (int tmp=0;tmp<dte_trans_tx.size();tmp=tmp+1) begin
          tx_xact.payload[tmp] = dte_trans_tx[tmp].payload[0];
        end

        data_frame = new[wr_len];

        addr_tmp_wr = {dte_trans_tx[7].payload[0][7:0],dte_trans_tx[6].payload[0][7:4],2'b00};

        for (int wr_len_i = 0; wr_len_i <= (wr_len-1); wr_len_i++) begin
            data_frame[wr_len_i] = {dte_trans_tx[13+wr_len_i*5].payload[0][7:0],
                                    dte_trans_tx[12+wr_len_i*5].payload[0][7:0],
                                    dte_trans_tx[11+wr_len_i*5].payload[0][7:0],
                                    dte_trans_tx[10+wr_len_i*5].payload[0][7:0]};

            tx_xact.data = data_frame[wr_len_i];
            tx_xact.addr = addr_tmp_wr;
            rx_xact_ap.write(tx_xact);
            addr_tmp_wr = addr_tmp_wr+4;
        end

        wr_done_ev = uvm_event_pool::get_global("wr_done_ev"); 
        wr_done_ev.trigger();

        dte_trans_tx.delete();
        dte_tx_xact_count = 0;
    end
endfunction:wr_ap_write


 
 // `ifndef UART_DRIVER
 // `define UART_DRIVER
typedef  global_pkg::UART_CMD UART_CMD;        // prototype in global_enum.svh

class uart_driver extends uvm_driver#(uart_sequence_item);

  uvm_analysis_port #(uart_sequence_item) ap;
  uvm_analysis_port #(uart_sequence_item) uartdrv_2_uartsbd_ap;

  uart_sequence_item req;
  uart_sequence_item rsp;


  `uvm_component_utils(uart_driver);

  virtual uart_if vif;
  virtual top_if top_vif;  
  uart_base_cfg m_cfg; 


  //parameter UART_HEADER = 40'h5a5a5a5a5a;
  bit [31:0] cmd_value;


  logic [9:0] chipaddr;
  logic [1:0] mode;

  logic 	we;
  logic [31:0]  addr;
  logic [31:0]  data_t;
  logic [31:0]  data_o [0:200];
  logic [31:0]  reg_fifo[379:0];

  logic [31:0]  noncebuf_data_o [`CHIP_NUM-1:0][25:0];


  logic [7:0]   tranlen;
  logic [7:0]   baud;
  
  //logic [7:0]  chipid_read;
  //bit   [7:0] chip_start_id = 0;  ********2023.10 chipadd update to 10bits
 
  logic [9:0]  chipid_read;
  bit   [9:0] chip_start_id = 0;
 
  //int len_cnt = 0;
  int len_cnt = 1;
  int noncebuf_cnt = 0;
  bit nonce_empty  =0;
  int frame_nidles = 0;
  int packet_nidles = 0;
  bit err_trigger = 0;

  bit chiplast_cfg  =0;
  bit chiplast_en;
  int _trans_cnt;

  function new(string name="uart_driver" , uvm_component parent=null);
    super.new(name , parent);
    ap = new("ap", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uartdrv_2_uartsbd_ap = new("uartdrv_2_uartsbd_ap", this);
    
    if(!uvm_config_db#(virtual uart_if)::get(this , "" , "uart_vif" ,vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")

    if (!uvm_config_db #(virtual interface top_if)::get(this, "", "top_vif", top_vif))
      `uvm_error("TOP_VIP:ERROR", "VIF top_vif is missing from config_db")

    if (!uvm_config_db #(uart_base_cfg)::get(this, "", "uart_config", m_cfg) )
      `uvm_info("CONFIG_LOAD", "Cannot get configuration uart_config from uvm_config_db. Have you set it?", UVM_MEDIUM)
  endfunction


   task run_phase(uvm_phase phase);
       
   wait_reset();

   forever
   begin
      seq_item_port.get_next_item(req);

        req.chipaddr	= top_vif.chipaddr;
	      we 		        = req.we;
	      addr 	 	      = req.addr;
        data_t 	    	= req.data;
        tranlen	    	= req.tranlen;
        chipaddr    	= req.chipaddr;
        mode	        = req.mode;
        baud	        = req.baud;
        frame_nidles  = req.frame_nidles;
        packet_nidles = req.packet_nidles;
        err_trigger 	= req.err_trigger;
	      chiplast_cfg 	= req.chiplast_cfg;
 	      chiplast_en	  = req.chiplast_en;
        chip_start_id  = req.chip_start_id; 
      
      if(req.mode == 'b00) begin
        req.we = 0;  _trans_cnt++;
      end
      else if(req.mode == 'b01) begin   
        req.we = 1;   _trans_cnt++;
      end

      req.cnt = _trans_cnt;
      `uvm_info(get_type_name(),$sformatf("UART trans, \n %s", req.sprint()),UVM_LOW)
      case (mode)
        2'b11 :  begin 
                 if(chiplast_cfg) begin uart_chiplast_set(); end
                 else begin uart_chip_init();uart_receive_init(); end
                 end  //chip init
        2'b10 :  uart_baud_upd();    //baud rate
        2'b01 :  uart_reg_wr(addr,data_t);   //
        2'b00 :  begin 
                 if( (chipaddr== 10'h3ff)&&(`CHIP_NUM>1) )   begin
                      if(   (addr >= REG_NONCEBUF_ADDR) && (addr <= REG_NONCEBUF_ADDR + (REG_NONCEBUF_WIDTH - 1)*4)  ) uart_noncebuf_brd_rd(addr);                        
                      else uart_brd_rd(addr ,data_o);
                 end
                 else begin 
                      if(   (addr >= REG_NONCEBUF_ADDR) && (addr <= REG_NONCEBUF_ADDR + (REG_NONCEBUF_WIDTH - 1)*4)  ) uart_noncebuf_rd(addr ,req.data);  
                      else uart_reg_rd(addr ,req.data);
                 end
                 end
      endcase
    
      //  void'($cast(rsp, req.clone()));
      //  rsp.set_sequence_id(req.get_sequence_id());
      //  rsp.set_transaction_id(req.get_transaction_id());
      //  seq_item_port.item_done(rsp);

      uartdrv_2_uartsbd_ap.write(req);

      seq_item_port.item_done();
   end
  endtask


// ***************sub- task
  virtual task uart_rxtimeout_trigger ();
        if(mode==3) 	begin #(200000*`CHIP_NUM);	repeat (100*`CHIP_NUM) @(posedge vif.uart_clk16); end
        else 		begin #200000 ;          	repeat (100) @(posedge vif.uart_clk16);	 	  end
        -> vif.uart_rx_timeout;    
        
    `ifndef UART_RX_WATCHDOG
        `uvm_warning(get_type_name(), $sformatf("[RX TIMEOUT---------------------]"))
    `else
        `uvm_error(get_type_name(), $sformatf("[RX TIMEOUT---------------------]"))
        #1000;
        $finish;
    `endif
  endtask
  

  task wait_reset();

    `uvm_info(get_type_name(), $sformatf("[Wait_RESET] Wait for reset"), UVM_MEDIUM)
    //#200;
    //force not on reset state
    //wait(top_vif.ri_rst_f_n === 1'b1);
    @ vif.uart_rst_done;
    repeat (32) @(posedge vif.uart_clk);

   `uvm_info(get_type_name(), $sformatf("[WAIT_RESET] Reset end"), UVM_MEDIUM)
  endtask


  // ------------------------------------
  // Function: choose parity mode crc or ecc
  // ------------------------------------
`include "uart_err_detect.sv"
extern virtual protected function bit [7:0] err_detect(input bit [31:0] data_in);
extern task insert_frame_nidles(input int nidles);
extern task insert_packet_nidles(input int nidles);



  // ------------------------------------
  // Function: 
  // ------------------------------------
  virtual task bit_arbiter (output logic rdata);
    int counter=0;
    for(int i = 0; i<16;i++) begin
          @(posedge vif.uart_clk);
          if ((i>3)&&(i<12))begin
		        if(vif.RX) counter++;
          end          
    end  
    if (counter>4) rdata=1; else rdata=0;
    counter=0;
  endtask


  virtual task bit_arbiter_stopbit (output logic rdata);
    int counter=0;
    for(int i = 0; i<12;i++) begin
          @(posedge vif.uart_clk);
          if ((i>3)&&(i<12))begin
		        if(vif.RX) counter++;
          end          
    end  
    if (counter>4) rdata=1; else rdata=0;
    counter=0;
  endtask

  
  virtual task receive_packet (output logic [7:0] rdata);
    logic start_bit, stop_bit;

        @(negedge vif.RX);
        bit_arbiter(start_bit);

        if( start_bit!==0 )  `uvm_error(get_type_name(),$sformatf("[UART RECEIVE PACKET] start_bit check failed !") )
 
        for(int i = 0; i<8;i++) begin
	          bit_arbiter(rdata[i]);
        end

        //repeat (14) @(posedge vif.uart_clk);
        //stop_bit = vif.RX;
        bit_arbiter_stopbit(stop_bit); 
        if( stop_bit!==1 )  `uvm_error(get_type_name(),$sformatf("[UART RECEIVE PACKET] stop_bit check failed !") )
  endtask:receive_packet


  virtual task receive_frame (output logic [39:0] rdata);
    fork
    begin
    receive_packet(rdata[7:0]);
    receive_packet(rdata[15:8]);
    receive_packet(rdata[23:16]);
    receive_packet(rdata[31:24]);
    receive_packet(rdata[39:32]);
    `uvm_info(get_type_name(), $sformatf("[UART] receive frame done %h",rdata), UVM_MEDIUM)
    end
    uart_rxtimeout_trigger();
    join_any
    disable fork; 

  endtask




  virtual task trans_packet (input logic [7:0] wdata);

    repeat (16) @(posedge vif.uart_clk);
    vif.DI = 0;  //start
    for(int i = 0; i<8;i++) begin
          repeat (16) @(posedge vif.uart_clk);
          vif.DI = wdata[i];
    end
    repeat (16) @(posedge vif.uart_clk);
    vif.DI = 1;  //stop

  endtask




  virtual task trans_frame (input logic [39:0] wdata);
    trans_packet(wdata[7:0]);
    trans_packet(wdata[15:8]);
    trans_packet(wdata[23:16]);
    trans_packet(wdata[31:24]);
    trans_packet(wdata[39:32]);
      insert_frame_nidles(this.frame_nidles);

    `uvm_info(get_type_name(), $sformatf("[UART] trans frame done %h",wdata), UVM_MEDIUM)
  endtask


  virtual task uart_reg_wr (input [31:0] addr ,data);
    UART_CMD cmd_value;
    cmd_value.chipaddr = chipaddr ;
    cmd_value.mode = 2'b01        ;  //WR
    cmd_value.addr = (addr>>2)    ;  
    cmd_value.tranlen = tranlen   ;  

    //cmd_value   = {tranlen,addr[13:2],4'b0000,mode,chipaddr  };
  
    if(tranlen>0) len_cnt=tranlen+1;
    

    if( tranlen>0 || len_cnt==0 ) begin 
      `uvm_info(get_type_name(), $sformatf("[UART] trans HEADER = %h", vif.HEADER), UVM_MEDIUM)
      trans_frame(vif.HEADER);  //head
      

    trans_frame( {err_detect(cmd_value),cmd_value} );  //cmd      
    
    `uvm_info(get_type_name(), $sformatf("[UART_REG_WR] reg wr done %h",cmd_value), UVM_MEDIUM)
    
    end

    trans_frame( {err_detect(data),data} );    
    
    if(len_cnt>0) len_cnt--;

    `uvm_info(get_type_name(), $sformatf("[UART_REG_WR] reg wr done %h",data), UVM_MEDIUM)
  endtask:uart_reg_wr



  virtual task uart_reg_rd (input [31:0] addr ,output reg[31:0] data);
    bit [39:0] tmp_value;
    UART_CMD cmd_value;
    cmd_value.chipaddr = chipaddr ;
    cmd_value.mode = 2'b00        ;  //RD
    cmd_value.addr = (addr>>2)    ;  
    cmd_value.tranlen = tranlen   ;  


    //cmd_value   = {tranlen,addr[11:2],4'b0000,mode,chipaddr  };

    if(tranlen>0) len_cnt=tranlen+1;   //internal counter for long reg access
    
    // tran frame 1 time when read reg
    if( tranlen>0 || len_cnt==0 ) begin 
    `uvm_info(get_type_name(), $sformatf("[UART] trans HEADER = %h", vif.HEADER), UVM_MEDIUM)
    	trans_frame(vif.HEADER);  //head
    	trans_frame( {err_detect(cmd_value),cmd_value} );  //cmd

    	receive_frame (tmp_value);
    	if( tmp_value !== vif.HEADER )  `uvm_warning(get_type_name(),$sformatf("[UART RECEIVE PACKET] read head frame failed !") )
    	receive_frame (tmp_value);
    end
    //if (addr == 'ha0 ) noncebuf_cnt = tranlen + 1;


    receive_frame (tmp_value);   //real data
    data = tmp_value[31:0];
    `uvm_info(get_type_name(), $sformatf("[UART_REG_RD] reg rd done %h",tmp_value), UVM_MEDIUM)

    if(len_cnt>0) len_cnt--;


  endtask: uart_reg_rd     







  virtual task uart_noncebuf_rd (input [31:0] addr ,output reg[31:0] data);
    bit [39:0] tmp_value;
    UART_CMD cmd_value;

    cmd_value.chipaddr = chipaddr ;
    cmd_value.mode = 2'b00        ;  //RD
    cmd_value.addr = (addr>>2)    ;  
    cmd_value.tranlen = tranlen   ;  

    //cmd_value   = {tranlen,addr[11:2],4'b0000,mode,chipaddr  };

    if(tranlen>0) len_cnt=tranlen+1;   //internal counter for long reg access
    
    // tran frame 1 time when read reg
    if( tranlen>0 || len_cnt==0 ) begin 
    `uvm_info(get_type_name(), $sformatf("[UART] trans HEADER = %h", vif.HEADER), UVM_MEDIUM)
    	trans_frame(vif.HEADER);  //head
    	trans_frame( {err_detect(cmd_value),cmd_value} );  //cmd

    	receive_frame (tmp_value);
    	if( tmp_value !== vif.HEADER )  `uvm_warning(get_type_name(),$sformatf("[UART RECEIVE PACKET] read head frame failed !") )
    	receive_frame (tmp_value);
        nonce_empty  = tmp_value[10];
        noncebuf_cnt = tmp_value[31:24]+1;
    end
    
    if(nonce_empty) `uvm_info(get_type_name(), $sformatf("[UART_NONCEBUF_RD] nonce_empty:  High "), UVM_MEDIUM)
    else begin

    if(noncebuf_cnt>0)  
      begin
      receive_frame (tmp_value);   //real data
      data = tmp_value[31:0];
      noncebuf_cnt --;
      `uvm_info(get_type_name(), $sformatf("[UART_NONCEBUF_RD] noncebuf_cnt: %h,  value: %h",noncebuf_cnt,tmp_value), UVM_MEDIUM)
      end
    else      `uvm_info(get_type_name(), $sformatf("[UART_NONCEBUF_RD] noncebuf_cnt:  SKIP "), UVM_MEDIUM)   
 
    end

    if(len_cnt>0) len_cnt--;

  endtask:uart_noncebuf_rd


  virtual task uart_noncebuf_brd_rd (input [31:0] addr);
    bit [39:0] tmp_value;
    int i,j,k,l;
    UART_CMD cmd_value;

    cmd_value.chipaddr = chipaddr ;
    cmd_value.mode = 2'b00        ;  //RD
    cmd_value.addr = (addr>>2)    ;  
    cmd_value.tranlen = tranlen   ;  

if(addr==REG_NONCEBUF_ADDR)  begin
    //cmd_value   = {tranlen,addr[11:2],4'b0000,mode,chipaddr  };

    foreach (noncebuf_data_o[k])  foreach (noncebuf_data_o[k][l]) noncebuf_data_o[k][l]= 32'h0;
    // tran frame 1 time when read reg
    `uvm_info(get_type_name(), $sformatf("[UART] trans HEADER = %h", vif.HEADER), UVM_MEDIUM)
    trans_frame(vif.HEADER);  //head
    trans_frame( {err_detect(cmd_value),cmd_value} );  //cmd

    for(int i = 0; i<`CHIP_NUM;i++) begin
    	receive_frame (tmp_value);
    	if( tmp_value !== vif.HEADER )  `uvm_warning(get_type_name(),$sformatf("[UART RECEIVE PACKET] read head frame failed !") )
        noncebuf_data_o[i][0] = tmp_value[31:0];
    	receive_frame (tmp_value);
        noncebuf_data_o[i][1] = tmp_value[31:0];
        nonce_empty  = tmp_value[10];
        noncebuf_cnt = tmp_value[31:24]+1;
        if(nonce_empty) begin
 		`uvm_info(get_type_name(), $sformatf("[UART_NONCEBUF_RD] nonce_empty:  High "), UVM_MEDIUM)
        end
        else begin
        	for(int j = 0; j<noncebuf_cnt;j++) begin
    	     		receive_frame (tmp_value);   //real data
    	     		noncebuf_data_o[i][2+j] = tmp_value[31:0];
        	end    
        end
       
    end
    `uvm_info(get_type_name(), $sformatf("[UART_NONCEBUF_RD] BRD rd done %p",noncebuf_data_o), UVM_MEDIUM)

    foreach (noncebuf_data_o[k]) foreach (noncebuf_data_o[k][l])  vif.noncebuf_data_o[k][l] = noncebuf_data_o[k][l];
end
  endtask:uart_noncebuf_brd_rd


  virtual task uart_brd_rd (input [31:0] addr ,output reg[31:0] data_o [0:200]);
    bit [39:0] tmp_value;
    UART_CMD cmd_value;

    cmd_value.chipaddr = chipaddr ;
    cmd_value.mode = 2'b00        ;  //RD
    cmd_value.addr = (addr>>2)    ;  
    cmd_value.tranlen = tranlen   ;  

    //cmd_value   = {tranlen,addr[11:2],4'b0000,mode,chipaddr  };

    
    // tran frame 1 time when read reg
    `uvm_info(get_type_name(), $sformatf("[UART] trans HEADER = %h", vif.HEADER), UVM_MEDIUM)
    trans_frame(vif.HEADER);  //head
    trans_frame( {err_detect(cmd_value),cmd_value} );  //cmd


    for(int j = 0; j<`CHIP_NUM;j++)  begin:repeat_chip_num
         receive_frame (tmp_value);
         	if( tmp_value !== vif.HEADER )  `uvm_warning(get_type_name(),$sformatf("[UART RECEIVE PACKET] read head frame failed !") )
         reg_fifo[0] = tmp_value[31:0];
         
         receive_frame (tmp_value);
         reg_fifo[1] = tmp_value[31:0];
         
         for(int i = 0; i<tranlen+1;i++) begin
         	receive_frame (tmp_value);   //real data
         	reg_fifo[2+i] = tmp_value[31:0];
         end    

         `uvm_info(get_type_name(), $sformatf("[UART_REG_RD] BRD rd done %p",reg_fifo), UVM_MEDIUM)
         req.reg_fifo[j] = reg_fifo;    

    end:repeat_chip_num

//    repeat (`CHIP_NUM) begin:  repeat_chip
//    receive_frame (tmp_value);
//    	if( tmp_value !== vif.HEADER )  `uvm_warning(get_type_name(),$sformatf("[UART RECEIVE PACKET] read head frame failed !") )
//    data_o[0] = tmp_value[31:0];
//
//    receive_frame (tmp_value);
//    data_o[1] = tmp_value[31:0];
//    
//    for(int i = 0; i<tranlen+1;i++) begin
//    	receive_frame (tmp_value);   //real data
//    	data_o[2+i] = tmp_value[31:0];
//    end    
//
//    `uvm_info(get_type_name(), $sformatf("[UART_REG_RD] BRD rd done %p",data_o), UVM_MEDIUM)
//    end    :repeat_chip

    

  endtask


// ------------------------------------------------------------
//  UART CHIPLAST CFG
// ------------------------------------------------------------
  virtual task uart_chiplast_set();
      bit [31:0] ignore_data = $random;
      bit [31:0] cmd_value;

      `uvm_info(get_type_name(), $sformatf("[UART] trans HEADER = %h", vif.HEADER), UVM_MEDIUM)
      trans_frame(vif.HEADER);

      cmd_value   = {  8'b0, chiplast_en, 7'b0,6'b0,2'b11,chipaddr}; 
      trans_frame({ err_detect(cmd_value), cmd_value });
      // wait for disconnect of DI_RX AND DO_TX
      // reopen delay between send cmd and chip id, otherwise the fbdo will toggle unexpected err
      repeat(20) @(posedge vif.uart_clk16);  

      //trans_packet(chip_start_id[7:0]);
      `uvm_info(get_type_name(), $sformatf("[UART] CHIPLAST CFG = %d val=%d", chipaddr, chiplast_en), UVM_MEDIUM)
  endtask

// ------------------------------------------------------------
//  UART CHIPLAST BOARDCAST CLR
// ------------------------------------------------------------
  virtual task uart_chiplast_brd_clr();
      bit [31:0] ignore_data = $random;
      bit [31:0] cmd_value;
      if(ignore_data[23:16] == 8'hff)
          ignore_data[23:16] = ignore_data[23:16] - 1'b1;
      `uvm_info(get_type_name(), $sformatf("[UART] trans HEADER = %h", vif.HEADER), UVM_MEDIUM)
      trans_frame(vif.HEADER);

      cmd_value   = {  8'b0, chiplast_en, 7'b0,6'b0,2'b11,8'hff}; 
      trans_frame({ err_detect(cmd_value), cmd_value });
      `uvm_info(get_type_name(), $sformatf("[UART] CHIPLAST BRD CLR"), UVM_MEDIUM)
  endtask


// ------------------------------------------------------------
//  UART CHIP INIT 
// ------------------------------------------------------------
  virtual task uart_chip_init ();
      bit [31:0] ignore_data = $random;
      bit [31:0] cmd_value;

      uart_chiplast_brd_clr();

      //wait for disconnect of FBDI & FBDO reopen when clearing chiplast
      repeat(2) @(posedge vif.uart_clk16);  

      `uvm_info(get_type_name(), $sformatf("[UART] trans HEADER = %h", vif.HEADER), UVM_MEDIUM)
      trans_frame(vif.HEADER);

      cmd_value   = {32'hffff_ffff}; 
      trans_frame({ err_detect(cmd_value), cmd_value });
      // wait for disconnect of DI_RX AND DO_TX
      // reopen delay between send cmd and chip id, otherwise the fbdo will toggle unexpected err
      repeat(2) @(posedge vif.uart_clk16);  

//rollback
      cmd_value   = {  ignore_data[23:16], ignore_data[15:8],ignore_data[7:0],chip_start_id[7:0]};
      trans_frame({ err_detect(cmd_value), cmd_value });
      //trans_packet(chip_start_id[7:0]);
      `uvm_info(get_type_name(), $sformatf("[UART] trans chip_start_id = 'd%d", chip_start_id), UVM_MEDIUM)
  endtask

  virtual task uart_receive_init ();
      receive_frame(chipid_read);
      //receive_packet(chipid_read);
       
      if (chipid_read == (chip_start_id+`CHIP_NUM) )
      `uvm_info(get_type_name(), $sformatf("[UART_CHIP_INIT] \n\n ******UART CHIP INIT Done******\n\n"), UVM_MEDIUM)
      else
      `uvm_error(get_type_name(),$sformatf("[UART_CHIP_INIT]  RECEIVE PACKET: chip id read back error!") )
      
      // wait for chipid_mode = 0
      repeat(2) @(posedge vif.uart_clk16); 
  endtask

// ------------------------------------------------------------
//  Update uart baud 
// ------------------------------------------------------------
  virtual task uart_baud_upd ();
      bit [31:0] ignore_data = $random;
      bit [31:0] cmd_value;

    `uvm_info(get_type_name(), $sformatf("[UART] trans HEADER = %h", vif.HEADER), UVM_MEDIUM)
      trans_frame(vif.HEADER);

      cmd_value   = {  ignore_data[23:16], baud ,ignore_data[5:0],2'b10,8'hff}; 
      trans_frame({ err_detect(cmd_value), cmd_value });
      `uvm_info(get_type_name(), $sformatf("[UART_BAUD_UPD] UART Baud update Done, baud= %h",baud), UVM_MEDIUM)
  endtask



endclass:uart_driver



// ------------------------------------------------------------
// extern methods
// ------------------------------------------------------------
function bit [7:0] uart_driver::err_detect(input bit [31:0] data_in);
  if(vif.REG_UART_CHECK_MODE_SEL)      
    err_detect = get_ecc(data_in);
  else err_detect = get_crc(data_in);
    
  return err_detect;
endfunction: err_detect

task uart_driver::insert_frame_nidles(input int nidles);
    `uvm_info(get_type_name(), $sformatf("[FRAME START] frame_nidles = 'd%0d", frame_nidles), UVM_HIGH)
    repeat(nidles) @(posedge vif.uart_clk16);
    `uvm_info(get_type_name(), $sformatf("[FRAME END] frame_nidles = 'd%0d", frame_nidles), UVM_HIGH)
endtask: insert_frame_nidles

task uart_driver::insert_packet_nidles(input int nidles);
    `uvm_info(get_type_name(), $sformatf("[packet_nidles] = 'd%0d", packet_nidles), UVM_HIGH)
    repeat(packet_nidles) @(posedge vif.uart_clk16);
endtask: insert_packet_nidles


//move to uart_pkg
// ------------------------------------------------------------
// check err injection driver
// ------------------------------------------------------------
//`include "uart_check_err_driver.sv"
// ------------------------------------------------------------
// rx timeout driver, trigger 1,2,3&4 byte
// ------------------------------------------------------------
//`include "uart_rx_timeout_driver.sv"


// class uart_custom_driver extends uart_driver#(uart_sequence_item);
// #(uart_sequence_item) will be ignored
class uart_custom_driver extends uart_driver;

  `uvm_component_utils(uart_custom_driver);

  function new(string name="uart_custom_driver" , uvm_component parent=null);
    super.new(name , parent);
  endfunction


  virtual task uart_reg_wr (input [31:0] addr ,data);
    UART_CMD cmd_value;
    cmd_value.chipaddr = chipaddr ;
    cmd_value.mode = 2'b01        ;  //WR
    cmd_value.addr = (addr>>2)    ;  
    cmd_value.tranlen = tranlen   ;  

    //cmd_value   = {tranlen,addr[13:2],4'b0000,mode,chipaddr  };

      `uvm_info(get_type_name(), "Starting Driver:   uart_custom_driver........", UVM_MEDIUM)
  

    if(tranlen>1) len_cnt=tranlen+1;
    
    if( tranlen>1 || len_cnt==1 ) begin 
      `uvm_info(get_type_name(), $sformatf("[UART] trans HEADER = %h", vif.HEADER), UVM_MEDIUM)
      trans_frame(vif.HEADER);  //head
      

    trans_frame( {err_detect(cmd_value),cmd_value} );  //cmd      
    
    `uvm_info(get_type_name(), $sformatf("[UART_REG_WR] reg wr done %h",cmd_value), UVM_MEDIUM)
    
    end

    trans_frame( {err_detect(data),data} );    
    
    if(len_cnt>1) len_cnt--;

    `uvm_info(get_type_name(), $sformatf("[UART_REG_WR] reg wr done %h",data), UVM_MEDIUM)
  endtask:uart_reg_wr



  virtual task uart_reg_rd (input [31:0] addr ,output reg[31:0] data);
    bit [39:0] tmp_value;
    UART_CMD cmd_value;
    cmd_value.chipaddr = chipaddr ;
    cmd_value.mode = 2'b00        ;  //RD
    cmd_value.addr = (addr>>2)    ;  
    cmd_value.tranlen = tranlen   ;  


    //cmd_value   = {tranlen,addr[11:2],4'b0000,mode,chipaddr  };

      `uvm_info(get_type_name(), "Starting Driver:   uart_custom_driver........", UVM_MEDIUM)


    if(tranlen>1) len_cnt=tranlen+1;   //internal counter for long reg access
    
    // tran frame 1 time when read reg
    if( tranlen>1 || len_cnt==1 ) begin 
    `uvm_info(get_type_name(), $sformatf("[UART] trans HEADER = %h", vif.HEADER), UVM_MEDIUM)
    	trans_frame(vif.HEADER);  //head
    	trans_frame( {err_detect(cmd_value),cmd_value} );  //cmd

    	receive_frame (tmp_value);
    	if( tmp_value !== vif.HEADER )  `uvm_warning(get_type_name(),$sformatf("[UART RECEIVE PACKET] read head frame failed !") )
    	receive_frame (tmp_value);
    end
    //if (addr == 'ha0 ) noncebuf_cnt = tranlen + 1;


    receive_frame (tmp_value);   //real data
    data = tmp_value[31:0];
    `uvm_info(get_type_name(), $sformatf("[UART_REG_RD] reg rd done %h",tmp_value), UVM_MEDIUM)

    if(len_cnt>1) len_cnt--;


  endtask: uart_reg_rd     







  virtual task uart_noncebuf_rd (input [31:0] addr ,output reg[31:0] data);
    bit [39:0] tmp_value;
    UART_CMD cmd_value;

    cmd_value.chipaddr = chipaddr ;
    cmd_value.mode = 2'b00        ;  //RD
    cmd_value.addr = (addr>>2)    ;  
    cmd_value.tranlen = tranlen   ;  

    //cmd_value   = {tranlen,addr[11:2],4'b0000,mode,chipaddr  };
      `uvm_info(get_type_name(), "Starting Driver:   uart_custom_driver........", UVM_MEDIUM)


    if(tranlen>1) len_cnt=tranlen+1;   //internal counter for long reg access
    
    // tran frame 1 time when read reg
    if( tranlen>1 || len_cnt==1 ) begin 
    `uvm_info(get_type_name(), $sformatf("[UART] trans HEADER = %h", vif.HEADER), UVM_MEDIUM)
    	trans_frame(vif.HEADER);  //head
    	trans_frame( {err_detect(cmd_value),cmd_value} );  //cmd

    	receive_frame (tmp_value);
    	if( tmp_value !== vif.HEADER )  `uvm_warning(get_type_name(),$sformatf("[UART RECEIVE PACKET] read head frame failed !") )
    	receive_frame (tmp_value);
        //nonce_empty  = tmp_value[10];
        //noncebuf_cnt = tmp_value[31:24]+1;
        noncebuf_cnt = tmp_value[31:24];

    end
    
    if(noncebuf_cnt==0) `uvm_info(get_type_name(), $sformatf("[UART_NONCEBUF_RD] nonce_empty:  High "), UVM_MEDIUM)
    else begin

    if(noncebuf_cnt>0)  
      begin
      receive_frame (tmp_value);   //real data
      data = tmp_value[31:0];
      noncebuf_cnt --;
      `uvm_info(get_type_name(), $sformatf("[UART_NONCEBUF_RD] noncebuf_cnt: %h,  value: %h",noncebuf_cnt,tmp_value), UVM_MEDIUM)
      end
    else      `uvm_info(get_type_name(), $sformatf("[UART_NONCEBUF_RD] noncebuf_cnt:  SKIP "), UVM_MEDIUM)   
 
    end

    if(len_cnt>1) len_cnt--;

  endtask:uart_noncebuf_rd


  virtual task uart_noncebuf_brd_rd (input [31:0] addr);
    bit [39:0] tmp_value;
    int i,j,k,l;
    UART_CMD cmd_value;

    cmd_value.chipaddr = chipaddr ;
    cmd_value.mode = 2'b00        ;  //RD
    cmd_value.addr = (addr>>2)    ;  
    cmd_value.tranlen = tranlen   ;  

      `uvm_info(get_type_name(), "Starting Driver:   uart_custom_driver........", UVM_MEDIUM)


if(addr==REG_NONCEBUF_ADDR)  begin
    //cmd_value   = {tranlen,addr[11:2],4'b0000,mode,chipaddr  };

    foreach (noncebuf_data_o[k])  foreach (noncebuf_data_o[k][l]) noncebuf_data_o[k][l]= 32'h0;
    // tran frame 1 time when read reg
    `uvm_info(get_type_name(), $sformatf("[UART] trans HEADER = %h", vif.HEADER), UVM_MEDIUM)
    trans_frame(vif.HEADER);  //head
    trans_frame( {err_detect(cmd_value),cmd_value} );  //cmd

    for(int i = 0; i<`CHIP_NUM;i++) begin
    	receive_frame (tmp_value);
    	if( tmp_value !== vif.HEADER )  `uvm_warning(get_type_name(),$sformatf("[UART RECEIVE PACKET] read head frame failed !") )
        noncebuf_data_o[i][0] = tmp_value[31:0];
    	receive_frame (tmp_value);
        noncebuf_data_o[i][1] = tmp_value[31:0];
        //nonce_empty  = tmp_value[10];
        noncebuf_cnt = tmp_value[31:24];
        if(noncebuf_cnt==0) begin
 		`uvm_info(get_type_name(), $sformatf("[UART_NONCEBUF_RD] nonce_empty:  High "), UVM_MEDIUM)
        end
        else begin
        	for(int j = 0; j<noncebuf_cnt;j++) begin
    	     		receive_frame (tmp_value);   //real data
    	     		noncebuf_data_o[i][2+j] = tmp_value[31:0];
        	end    
        end
       
    end
    `uvm_info(get_type_name(), $sformatf("[UART_NONCEBUF_RD] BRD rd done %p",noncebuf_data_o), UVM_MEDIUM)

    foreach (noncebuf_data_o[k]) foreach (noncebuf_data_o[k][l])  vif.noncebuf_data_o[k][l] = noncebuf_data_o[k][l];
end
  endtask:uart_noncebuf_brd_rd


  virtual task uart_brd_rd (input [31:0] addr ,output reg[31:0] data_o [0:200]);
    bit [39:0] tmp_value;
    UART_CMD cmd_value;
    string info;

    cmd_value.chipaddr = chipaddr ;
    cmd_value.mode = 2'b00        ;  //RD
    cmd_value.addr = (addr>>2)    ;  
    cmd_value.tranlen = tranlen   ;  


      `uvm_info(get_type_name(), "Starting Driver:   uart_custom_driver........", UVM_MEDIUM)
    
    // tran frame 1 time when read reg
    `uvm_info(get_type_name(), $sformatf("[UART] trans HEADER = %h", vif.HEADER), UVM_MEDIUM)
    trans_frame(vif.HEADER);  //head
    trans_frame( {err_detect(cmd_value),cmd_value} );  //cmd


    for(int j = 0; j<`CHIP_NUM;j++)  begin:repeat_chip_num
         receive_frame (tmp_value);
         	if( tmp_value !== vif.HEADER )  `uvm_warning(get_type_name(),$sformatf("[UART RECEIVE PACKET] read head frame failed !") )
         reg_fifo[0] = tmp_value[31:0];
         
         receive_frame (tmp_value);
         reg_fifo[1] = tmp_value[31:0];
         
         //for(int i = 0; i<tranlen+1;i++) begin
         for(int i = 0; i<tranlen;i++) begin
         	receive_frame (tmp_value);   //real data
         	reg_fifo[2+i] = tmp_value[31:0];
         end    
        
        info = $sformatf("\nC[%0d]: UART_REG_RD BRD rd done \n", j);
        for(int m = 0; m < tranlen+2; m++)begin
          info = {info, $sformatf("|%6d: 'h%h ",m, reg_fifo[m])};
          if ((m+1)%5== 0) info = {info, $sformatf("\n")};
        end
        `uvm_info(get_type_name(), $sformatf("%s",info), UVM_MEDIUM)

         req.reg_fifo[j] = reg_fifo;    

    end:repeat_chip_num


  endtask


// ------------------------------------------------------------
//  UART CHIPLAST CFG
// ------------------------------------------------------------
  virtual task uart_chiplast_set();
      bit [31:0] ignore_data = $random;
      bit [31:0] cmd_value;

      `uvm_info(get_type_name(), $sformatf("[UART] trans HEADER = %h", vif.HEADER), UVM_MEDIUM)
      trans_frame(vif.HEADER);

      cmd_value   = {  8'b0, chiplast_en, 7'b0,4'b0,2'b11,chipaddr}; //***********
      trans_frame({ err_detect(cmd_value), cmd_value });
      // wait for disconnect of DI_RX AND DO_TX
      // reopen delay between send cmd and chip id, otherwise the fbdo will toggle unexpected err
      repeat(20) @(posedge vif.uart_clk16);  

      //trans_packet(chip_start_id[7:0]);
      `uvm_info(get_type_name(), $sformatf("[UART] CHIPLAST CFG = %d val=%d", chipaddr, chiplast_en), UVM_MEDIUM)
  endtask

// ------------------------------------------------------------
//  UART CHIPLAST BOARDCAST CLR
// ------------------------------------------------------------
  virtual task uart_chiplast_brd_clr();
      bit [31:0] ignore_data = $random;
      bit [31:0] cmd_value;
      `uvm_info(get_type_name(), "Starting Driver:   uart_custom_driver........", UVM_MEDIUM)


      if(ignore_data[23:16] == 8'hff)
          ignore_data[23:16] = ignore_data[23:16] - 1'b1;
      `uvm_info(get_type_name(), $sformatf("[UART] trans HEADER = %h", vif.HEADER), UVM_MEDIUM)
      trans_frame(vif.HEADER);

      cmd_value   = {  8'b0, chiplast_en, 7'b0,4'b0,2'b11,10'h3ff}; //***********
      trans_frame({ err_detect(cmd_value), cmd_value });
      `uvm_info(get_type_name(), $sformatf("[UART] CHIPLAST BRD CLR"), UVM_MEDIUM)
  endtask


// ------------------------------------------------------------
//  UART CHIP INIT 
// ------------------------------------------------------------
  virtual task uart_chip_init ();
      bit [31:0] ignore_data = $random;
      bit [31:0] cmd_value;

      uart_chiplast_brd_clr();

      //wait for disconnect of FBDI & FBDO reopen when clearing chiplast
      repeat(2) @(posedge vif.uart_clk16);  

      `uvm_info(get_type_name(), $sformatf("[UART] trans HEADER = %h", vif.HEADER), UVM_MEDIUM)
      trans_frame(vif.HEADER);

      cmd_value   = {32'hffff_ffff}; 
      trans_frame({ err_detect(cmd_value), cmd_value });
      // wait for disconnect of DI_RX AND DO_TX
      // reopen delay between send cmd and chip id, otherwise the fbdo will toggle unexpected err
      repeat(4) @(posedge vif.uart_clk16);  

//rollback
      cmd_value   = {  ignore_data[23:16], ignore_data[15:8],ignore_data[5:0],chip_start_id[9:0]};//***********
      trans_frame({ err_detect(cmd_value), cmd_value });
      //trans_packet(chip_start_id[7:0]);
      `uvm_info(get_type_name(), $sformatf("[UART] trans chip_start_id = 'd%d", chip_start_id), UVM_MEDIUM)
  endtask


// ------------------------------------------------------------
//  Update uart baud 
// ------------------------------------------------------------
  virtual task uart_baud_upd ();
      bit [31:0] ignore_data = $random;
      bit [31:0] cmd_value;
      `uvm_info(get_type_name(), "Starting Driver:   uart_custom_driver........", UVM_MEDIUM)

    `uvm_info(get_type_name(), $sformatf("[UART] trans HEADER = %h", vif.HEADER), UVM_MEDIUM)
      trans_frame(vif.HEADER);

      cmd_value   = {  ignore_data[23:16], baud ,ignore_data[3:0],2'b10,10'h3ff}; //***********
      trans_frame({ err_detect(cmd_value), cmd_value });
      `uvm_info(get_type_name(), $sformatf("[UART_BAUD_UPD] UART Baud update Done, baud= %h",baud), UVM_MEDIUM)
  endtask



endclass

//`endif     //`ifndef UART_DRIVER

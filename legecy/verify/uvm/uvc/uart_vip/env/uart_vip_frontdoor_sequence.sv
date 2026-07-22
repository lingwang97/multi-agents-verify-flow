`include "uart_err_detect.sv"

class uart_vip_frontdoor_sequence extends uvm_reg_frontdoor;


  `uvm_object_utils(uart_vip_frontdoor_sequence)

  virtual top_if         top_vif;
  svt_uart_vif           dte_vif;


  int cnt;
  uvm_event rd_done_ev;
  uvm_event wr_done_ev;
  bit [9:0] chip_id = 10'h0;

  function new(string name = "uart_vip_frontdoor_sequence");
    super.new(name);
  endfunction

  task pre_body();

    if (uvm_config_db#(svt_uart_vif)::get(null, "uvm_test_top.top_env_h.uart_vip_env_h", "dte_vif", dte_vif)) begin
      if(dte_vif == null) begin
      `uvm_fatal("build_phase", "uart_vip_base_seq 'dte_vif' is null. A svt_uart_if interface must be set using the UVM configuration infrastructure.");
      end else begin
        //`uvm_info("build_phase", "Applying the DTE virtual interface received through the config db to the configuration.", UVM_LOW);
      end
    end else begin 
      `uvm_fatal("build_phase", "A DTE virtual interface was not received either through the config db, or through the configuration object for the master.");
    end

    if (!uvm_config_db #(virtual interface top_if)::get(m_sequencer, "", "top_vif", top_vif))
      `uvm_fatal("TOP_VIF:ERROR", "VIF top_vif is missing from config_db")

  endtask


  virtual task body();

    uvm_reg the_reg;
    uvm_reg_addr_t reg_addr;
    uvm_reg_data_t data;

    bit 	cmd;
    bit [7:0]   len            = 1;

    if ($test$plusargs("VIP_BRD"))
      chip_id = `BRD_ADDR;
    else
      chip_id = top_vif.chipaddr;

    `uvm_info(get_type_name(), $sformatf("uart_vip_frontdoor_sequence start........."),UVM_MEDIUM);

    $cast(the_reg, rw_info.element); // Find the original uvm_reg object
    reg_addr = the_reg.get_address(); // Find the address of the register
    cmd = (rw_info.kind == UVM_WRITE);

    len = the_reg.get_n_bits()/32;

    data = rw_info.value[0];
    if (cmd == 1) begin // Write command
      wr_transaction( .cmd(cmd), .addr(reg_addr), .data(data) ,.len(len) );  //write reg transaction

      if (!$test$plusargs("SEQ_WR")) begin
        if (`CHIP_NUM == 1) begin
        wr_done_ev = uvm_event_pool::get_global("wr_done_ev");
        wr_done_ev.wait_trigger();
        end
      end

      //`uvm_info("got_trigger", $sformatf("debug, data = %0h" , data),UVM_LOW);
    end

    if (cmd == 0) // Read command
    //rw_info.value[0][3:0] = data;
    //data = rw_info.value[0][7:4]; // Top nibble
        rd_transaction( .cmd(cmd), .addr(reg_addr), .data(data),.len(len) );
    if (cmd == 0) begin// Read command
      if (!$test$plusargs("SEQ_WR")) begin
        rd_done_ev = uvm_event_pool::get_global("rd_done_ev");
        rd_done_ev.wait_trigger();
        //`uvm_info("got_trigger", $sformatf("debug, data = %0h" , data),UVM_LOW);
        data = the_reg.get_mirrored_value();
      end
    end
    
    rw_info.value[0] = data;
    rw_info.status = UVM_IS_OK;

    `uvm_info(get_type_name(), $sformatf("uart_vip_frontdoor_sequence end........."),UVM_MEDIUM);

    //if (cmd == 1) begin
    //    `uvm_info("fd_seq", $sformatf("debug, data = %0h len=%0h, addr=%0h, DATA = %0h" , rw_info.value[0],len,reg_addr,data),UVM_LOW);
    //    the_reg.predict(data);
    //end

  endtask



  task rd_transaction(bit cmd, uvm_reg_addr_t addr, ref uvm_reg_data_t data ,bit [7:0] len);
    svt_uart_transaction req;
    svt_uart_transaction rsp;
    uvm_sequence_item item;

    bit [1:0]	mode;
    bit [31:0] cmd_value;

    bit [39:0] head_frame;
    bit [39:0] cmd_frame;
    bit [39:0] data_frame[];

    mode	= (cmd)? 2'b01 : 2'b00;
    cmd_value   = {len,addr[13:2],mode,chip_id};

    head_frame = top_vif.HEADER;
    if (top_vif.REG_UART_CHECK_MODE_SEL) cmd_frame = {get_ecc(cmd_value),cmd_value};
    else cmd_frame  = {get_crc(cmd_value),cmd_value};
    
    req = svt_uart_transaction::type_id::create("req");

       //`uvm_info("fd_rd", $sformatf("debug, addr = %0h, data = %0h, len = %0h", addr,data,len),UVM_LOW);
    if (!$test$plusargs("SEQ_WR_COVERAGE")) begin
        req.inter_cycle_delay = 0;
        
        req.enable_packet_generation 	= 1'b1;
        req.packet_count 		= 10;
        req.payload      		= new[10];
    
        foreach (req.payload[i]) begin
            req.payload[i] 	= {cmd_frame,head_frame}[(i*8)+:8];
             //`uvm_info("fd_rd", $sformatf("debug, i = %0d, data = %0h", i,req.payload[i]),UVM_LOW);
        end
    end else begin
        req.inter_cycle_delay           = 0;
        req.enable_packet_generation 	= 1'b1;
        req.packet_count 		= 5;
        req.payload      		= new[5];
    
        foreach (req.payload[i]) begin
            req.payload[i] 	= {head_frame}[(i*8)+:8];
        end
    
        start_item(req);
        finish_item(req);
    
        get_response(item);
        $cast(rsp, item);
        assert(rsp != null);
    
        foreach (req.payload[i]) begin
            req.payload[i] 	= {cmd_frame}[(i*8)+:8];
        end
    end

    start_item(req);
    finish_item(req);

    get_response(item);
    $cast(rsp, item);
    assert(rsp != null);
    //if (cmd == 0)
    //data = rsp.data;
  endtask

  task wr_transaction(bit cmd, uvm_reg_addr_t addr, ref uvm_reg_data_t data ,bit [7:0] len);
    svt_uart_transaction req;
    svt_uart_transaction rsp;
    uvm_sequence_item item;

    bit [1:0]	mode;
    bit [31:0]  cmd_value;

    bit [39:0]  head_frame = 40'h5a5a5a5a5a;
    bit [39:0]  cmd_frame;
    bit [39:0]  data_frame[];

    bit [ `UVM_REG_DATA_WIDTH+(`UVM_REG_DATA_WIDTH/32*8)-1 :0] all_data_frame;

    mode	= (cmd)? 2'b01 : 2'b00;
    cmd_value   = {len,addr[13:2],mode,chip_id};
$display("addr=======%0h,chip_id==%0h",addr,chip_id);
    head_frame = top_vif.HEADER;
    if (top_vif.REG_UART_CHECK_MODE_SEL) cmd_frame = {get_ecc(cmd_value),cmd_value};
    else cmd_frame  = {get_crc(cmd_value),cmd_value};

    data_frame  = new[len];
    foreach (data_frame[i]) begin
     if (top_vif.REG_UART_CHECK_MODE_SEL) data_frame[i] = {get_ecc(data[(i*32)+:32]),data[(i*32)+:32]};  //uvm_reg_data_t data is a `UVM_REG_DATA_WIDTH
     else data_frame[i] = {get_crc(data[(i*32)+:32]),data[(i*32)+:32]};
     all_data_frame[i*40+:40] = data_frame[i];
    end

    req = svt_uart_transaction::type_id::create("req");

    req.inter_cycle_delay = 0;
    
    req.enable_packet_generation 	= 1'b1;
    req.packet_count 		        = 5+5+5*len;
    req.payload      		        = new[5+5+5*len];

    foreach (req.payload[i]) begin
        req.payload[i] 	= {all_data_frame,cmd_frame,head_frame}[(i*8)+:8];
        //`uvm_info("fd_wr", $sformatf("debug, i = %0d, data = %0h", i,req.payload[i]),UVM_LOW);
    end

    start_item(req);
    finish_item(req);

    get_response(item);
    $cast(rsp, item);
    assert(rsp != null);
    //if (cmd == 0)
    //data = rsp.data;
  endtask

endclass


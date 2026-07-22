
`ifndef GUARD_SVT_UART_REG_ADAPTER_SV
`define GUARD_SVT_UART_REG_ADAPTER_SV

class svt_uart_reg_adapter extends uvm_reg_adapter;
  
  cust_svt_uart_transaction uart_reg_trans;

  svt_uart_vif dte_vif;
  virtual top_if         top_vif;

  bit [1:0]    mode           = 2'h1;
  bit [7:0]    len            = 8'h1;
  bit [9:0]    chip_id        = 10'h0;
  bit [13:0]   addr           = 14'h0;
  bit [7:0]    tmp_pkt_value  = 8'h0;
  bit [31:0]   cmd_value      = 32'h0;

  bit [ `UVM_REG_DATA_WIDTH+(`UVM_REG_DATA_WIDTH/32*8)-1 :0]   rw_data=0;
  bit [11:0]   rw_addr        = 12'h0;

  bit [7:0]    payload_loop[0:19];
  bit [31:0]   rw_data_tmp;

  integer tmp1;

  // ****************************************************************************
  `uvm_object_utils_begin(svt_uart_reg_adapter)
    `uvm_field_object(uart_reg_trans, UVM_ALL_ON);
  `uvm_object_utils_end
  //-----------------------------------------------------------------------------
  
  /**
   * CONSTUCTOR: Create a new transaction instance, passing the appropriate argument
   * values to the parent class.
   *
   * @param name Instance name of the transaction
   */
  extern function new(string name= "svt_uart_reg_adapter");

  /** Convert a UVM RAL transaction into an AHB transaction */
  extern virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
  
  /** Convert AHB transaction back to into a UVM RAL transaction */
  extern virtual function void bus2reg(uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);
endclass

   function svt_uart_reg_adapter::new(string name = "svt_uart_reg_adapter");
      super.new(name);
      
      /**
       * If the bus protocol supports byte lane enables 
       * (i.e., it is possible to read or write individual bytes in a multibyte bus), 
       * the supports_byte_enable class property should be set to TRUE in the constructor.
       */
      supports_byte_enable = 1;
      
      /**
       * The provides_responses class property should be set to TRUE if the bus driver returns responses,
       * e.g., the result of a read operation, in a separate response descriptor:
       */
      provides_responses = 1;
     `uvm_info("svt_uart_reg_adapter", "Constructed", UVM_LOW);

     if(!uvm_config_db#(svt_uart_vif)::get(null, "uvm_test_top.top_env_h.uart_vip_env_h", "dte_vif",dte_vif))
       `uvm_fatal(get_full_name(), "Virtual interface handle missing")

     if(!uvm_config_db#(virtual top_if)::get(null, "uvm_test_top.top_env_h" , "top_vif" ,top_vif))
       `uvm_error("TOP_VIF:ERROR", "VIF top_vif is missing from config_db")

   endfunction
  
   // -----------------------------------------------------------------------------
   // abandon, (ral rd/wr is in uart_vip_frontdoor_sequence.sv), (will no execute when set_frontdoor)
   // -----------------------------------------------------------------------------
   function uvm_sequence_item svt_uart_reg_adapter::reg2bus(const ref uvm_reg_bus_op rw);
     chip_id              = 10'h00;
     mode                 = (rw.kind == UVM_READ)? 2'b00 : 2'b01;
     addr                 = rw.addr;

     case (addr)
         `BASE_WORK            :  len = `ABS_NUM;   
         REG_WORK_ADDR         :  len = `WORK_WORD_NUM;   
         REG_NONCEBUF_ADDR     :  len = `NONCE_WORD_NUM;  
         REG_SPD_ADDR          :  len = `SPD_CORE_NUM/8;   
         REG_SPDLOG_ADDR       :  len = `DESIGN_CORE_NUM;   
         REG_SSLOG_ADDR        :  len = (`DESIGN_CORE_NUM+1)/2;   
         default               :  len = 1; 
     endcase

     tmp_pkt_value        = {addr[5:2],mode};
     cmd_value            = {len,addr[13:6],tmp_pkt_value,chip_id};

     uart_reg_trans = cust_svt_uart_transaction::type_id::create("uart_reg_trans");
     uart_reg_trans.direction = cust_svt_uart_transaction::TX;
     uart_reg_trans.packet_count = (rw.kind == UVM_READ)? 10 : (len*5+10);
     uart_reg_trans.enable_packet_generation = 1'b1;
     uart_reg_trans.payload      = new[uart_reg_trans.packet_count];
     //uart_reg_trans.payload[0]   = top_vif.HEADER[0*8+:8];
     //uart_reg_trans.payload[1]   = top_vif.HEADER[1*8+:8];
     //uart_reg_trans.payload[2]   = top_vif.HEADER[2*8+:8];
     //uart_reg_trans.payload[3]   = top_vif.HEADER[3*8+:8];
     //uart_reg_trans.payload[4]   = top_vif.HEADER[4*8+:8];
     uart_reg_trans.payload[0]   = 'h5a;
     uart_reg_trans.payload[1]   = 'h5a;
     uart_reg_trans.payload[2]   = 'h5a;
     uart_reg_trans.payload[3]   = 'h5a;
     uart_reg_trans.payload[4]   = 'h5a;
     uart_reg_trans.payload[5]   = chip_id[7:0];
     uart_reg_trans.payload[6]   = {tmp_pkt_value,chip_id[9:8]};
     uart_reg_trans.payload[7]   = rw.addr[13:6];
     uart_reg_trans.payload[8]   = len;
     uart_reg_trans.payload[9]   = (top_vif.REG_UART_CHECK_MODE_SEL)?get_ecc(cmd_value):get_crc(cmd_value);

     if(rw.kind == UVM_WRITE) begin
         for(int i=0; i<len; i++) begin
           uart_reg_trans.payload[10+i*5]  = rw.data[(i*32+0)+:8];
           uart_reg_trans.payload[11+i*5]  = rw.data[(i*32+8)+:8];
           uart_reg_trans.payload[12+i*5]  = rw.data[(i*32+16)+:8];
           uart_reg_trans.payload[13+i*5]  = rw.data[(i*32+24)+:8];
           uart_reg_trans.payload[14+i*5]  = (top_vif.REG_UART_CHECK_MODE_SEL)?get_ecc(rw.data):get_crc(rw.data);
         end
         uart_reg_trans.inter_cycle_delay = 0;
     end else begin
     end

     return uart_reg_trans;
   endfunction: reg2bus

   // -----------------------------------------------------------------------------
   // bus2reg is to do explicit predict, (will execute once by monitor's transaction, not by driver's rsp when set_frontdoor)
   // -----------------------------------------------------------------------------
   function void svt_uart_reg_adapter::bus2reg(uvm_sequence_item bus_item,
                              ref uvm_reg_bus_op rw);
     cust_svt_uart_transaction bus_trans; 
     if(!$cast(bus_trans, bus_item))begin
       `uvm_fatal("BUS2REG", "bus_item is not correct type");
     end

     //`uvm_info("svt_uart_reg_adapter", $sformatf("kind = %0d, addr = %0h, data = %0h",bus_trans.payload[6][1:0],bus_trans.addr,bus_trans.data), UVM_LOW);
     if ( bus_trans.payload[6][3:2] == 'b00 ) begin
         rw.kind        = UVM_READ;
         rw.addr        = bus_trans.addr;
         rw.data        = bus_trans.data;
         rw.status      = UVM_IS_OK;
     end else if ( bus_trans.payload[6][3:2] == 'b01 ) begin
         rw.kind        = UVM_WRITE;
         rw.addr        = bus_trans.addr;
         rw.data        = bus_trans.data;
         rw.status      = UVM_IS_OK;
     end else begin
         rw.status      = UVM_HAS_X;
     end

   endfunction: bus2reg


`endif // GUARD_SVT_UART_REG_ADAPTER_SV


 

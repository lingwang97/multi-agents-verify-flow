`define UVM_MX2_REG
class uart_adapter extends uvm_reg_adapter;


  virtual top_if top_vif;  
  `uvm_object_utils(uart_adapter)

   function new(string name = "uart_adapter");
      super.new(name);
 
   endfunction

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);

    uart_sequence_item apb = uart_sequence_item::type_id::create("apb");

    apb.we = (rw.kind == UVM_READ) ? 0 : 1;
    apb.mode = (rw.kind == UVM_READ) ?  2'b00 : 2'b01;

    apb.addr = rw.addr;
    apb.data = rw.data;

    // ------------------------------------------------------
    // RAL MODEL only support the right transimission pattern
    apb.frame_nidles = 0;
    apb.packet_nidles = 0;
    apb.err_trigger = 0;
    // ------------------------------------------------------

//    case (apb.addr)
//        
//        REG_VERSION_ADDR 		:  apb.tranlen  = REG_VERSION_WIDTH   -1;   
//        REG_WORK_ADDR 		  :  apb.tranlen  = REG_WORK_WIDTH      -1;   
//        REG_NONCEBUF_ADDR   :  apb.tranlen  = REG_NONCEBUF_WIDTH  -1;  
//        REG_SPDCORE_ADDR 		:  apb.tranlen  = REG_SPDCORE_WIDTH   -1;   
//        REG_SPD_ADDR 		    :  apb.tranlen  = REG_SPD_WIDTH       -1;   
//        REG_SPDLOG_ADDR	    :  apb.tranlen  = REG_SPDLOG_WIDTH    -1;   
//        REG_SSLOG_ADDR 		  :  apb.tranlen  = REG_SSLOG_WIDTH     -1;   
//        REG_TCLKPD_ADDR 		:  apb.tranlen  = REG_TCLKPD_WIDTH      -1 ;  
//	      default			        :  apb.tranlen  = 0; 
//    endcase
   

    case (apb.addr)
        
        REG_VERSION_ADDR 		:  apb.tranlen  = REG_VERSION_WIDTH   ;   
        REG_WORK_ADDR 		  :  apb.tranlen  = REG_WORK_WIDTH      ;   
        REG_NONCEBUF_ADDR   :  apb.tranlen  = REG_NONCEBUF_WIDTH  ;  
        REG_SPDCORE_ADDR 		:  apb.tranlen  = REG_SPDCORE_WIDTH   ;   
        REG_SPD_ADDR 		    :  apb.tranlen  = REG_SPD_WIDTH       ;   
        REG_SPDLOG_ADDR	    :  apb.tranlen  = REG_SPDLOG_WIDTH    ;   
        REG_SSLOG_ADDR 		  :  apb.tranlen  = REG_SSLOG_WIDTH     ;   
        REG_TCLKPD_ADDR 		:  apb.tranlen  = REG_TCLKPD_WIDTH       ;  
	      default			        :  apb.tranlen  = 1; 
    endcase
 
    if (apb.addr)

	/*
	apb.mode_t  = rw.mode_t;
	apb.chipaddr = rw.chipaddr;
	apb.needdly  = rw.needdly;
	apb.tranlen  = rw.tranlen;
	*/
	`ifdef UVM_MX2_REG
		if(rw.addr[15:12] == 4'hf) begin
			apb.addr = REG_CORE_CFG_ADDR;
			apb.data = {rw.data[31:16],rw.addr[7:0],rw.data[7:0]};
			//apb.data = {15'h0,~apb.we,rw.addr[7:0],rw.data[7:0]};
		end
	`endif

    return apb;
  endfunction: reg2bus

  virtual function void bus2reg(uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);


    uart_sequence_item apb;
    if (!$cast(apb, bus_item)) begin
      `uvm_fatal("NOT_APB_TYPE","Provided bus_item is not of the correct type")
      return;
    end

    rw.kind = apb.we ? UVM_WRITE : UVM_READ;
    rw.addr = apb.addr;
    rw.data = apb.data;
    rw.status = UVM_IS_OK;
    //turn info to debug
    //`uvm_info(get_type_name(), $sformatf("KIND = %s, ADDR = 'h%h, DATA = 'h%h",rw.kind, rw.addr, rw.data), UVM_MEDIUM);

  endfunction: bus2reg

endclass: uart_adapter


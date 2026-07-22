`define UVM_MX2_REG
class jamlink_adapter extends uvm_reg_adapter;

  virtual top_if top_vif;  
  `uvm_object_utils(jamlink_adapter)

   function new(string name = "jamlink_adapter");
      super.new(name);
 
   endfunction

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);

    jamlink_sequence_item apb = jamlink_sequence_item::type_id::create("apb");

    apb.we = (rw.kind == UVM_READ) ? 0 : 1;
	apb.addr = rw.addr;
    apb.data = rw.data;
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


    jamlink_sequence_item apb;
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

endclass: jamlink_adapter


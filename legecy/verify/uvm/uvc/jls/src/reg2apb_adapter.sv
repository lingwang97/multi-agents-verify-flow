`define UVM_MX2_REG
class reg2apb_adapter extends uvm_reg_adapter;

  `uvm_object_utils(reg2apb_adapter)

   function new(string name = "reg2apb_adapter");
      super.new(name);
   endfunction

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    jls_sequence_item apb = jls_sequence_item::type_id::create("apb");
    apb.we = (rw.kind == UVM_READ) ? 0 : 1;
	apb.addr = rw.addr;
    apb.data = rw.data;
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
    jls_sequence_item apb;
    if (!$cast(apb, bus_item)) begin
      `uvm_fatal("NOT_APB_TYPE","Provided bus_item is not of the correct type")
      return;
    end
    rw.kind = apb.we ? UVM_WRITE : UVM_READ;
    rw.addr = apb.addr;
    rw.data = apb.data;
    rw.status = UVM_IS_OK;
  endfunction: bus2reg

endclass: reg2apb_adapter



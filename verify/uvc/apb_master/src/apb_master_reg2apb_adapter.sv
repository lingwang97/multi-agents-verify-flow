class apb_master_reg2apb_adapter extends uvm_reg_adapter;

  `uvm_object_utils(apb_master_reg2apb_adapter)

   function new(string name = "apb_master_reg2apb_adapter");
      super.new(name);
   endfunction

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    apb_master_sequence_item apb = apb_master_sequence_item::type_id::create("apb");
    apb.we   = (rw.kind == UVM_READ) ? 0 : 1;
    apb.addr = rw.addr;
    apb.data = rw.data;

    return apb;
  endfunction: reg2bus

  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);

    apb_master_sequence_item apb;
    if (!$cast(apb, bus_item)) begin
      `uvm_fatal("NOT_VALID_TYPE","Provided bus_item is not of the correct type")
      return;
    end
    rw.kind = apb.we ? UVM_WRITE : UVM_READ;
    rw.addr = apb.addr;
    rw.data = apb.data;
    rw.status = UVM_IS_OK;
  endfunction: bus2reg

endclass: apb_master_reg2apb_adapter

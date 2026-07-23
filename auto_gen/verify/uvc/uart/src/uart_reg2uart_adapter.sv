class uart_reg2uart_adapter extends uvm_reg_adapter;

  `uvm_object_utils(uart_reg2uart_adapter)

   function new(string name = "uart_reg2uart_adapter");
      super.new(name);
   endfunction

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    uart_sequence_item uart = uart_sequence_item::type_id::create("uart");
    //Please complete the conversion logic of the bus. Refer to the following as an example.
    uart.we   = (rw.kind == UVM_READ) ? 0 : 1;
	  uart.addr = rw.addr;
    uart.data = rw.data;

    return uart;
  endfunction: reg2bus

  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);

    uart_sequence_item uart;
    if (!$cast(uart, bus_item)) begin
      `uvm_fatal("NOT_VALID_TYPE","Provided bus_item is not of the correct type")
      return;
    end
    //Please complete the conversion logic of the bus. Refer to the following as an example.
    rw.kind = uart.we ? UVM_WRITE : UVM_READ;
    rw.addr = uart.addr;
    rw.data = uart.data;
    rw.status = UVM_IS_OK;
  endfunction: bus2reg

endclass: uart_reg2uart_adapter

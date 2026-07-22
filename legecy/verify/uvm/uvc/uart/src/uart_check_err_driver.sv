
`ifndef UART_CHECK_ERR_DRIVER
`define UART_CHECK_ERR_DRIVER
// ------------------------------------------------------------
// trigger err driver
// ------------------------------------------------------------
//class uart_check_err_driver extends uart_driver;
class uart_check_err_driver extends uart_custom_driver;
  `uvm_component_utils(uart_check_err_driver);

  function new(string name="uart_check_err_driver" , uvm_component parent=null);
    super.new(name , parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction :build_phase


   task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask:run_phase


  function bit [7:0] err_detect(input bit [31:0] data_in);
  if(err_trigger)begin
    void'(std::randomize(err_detect));
    `uvm_info(get_type_name(), $sformatf("err_detect  = 'h%h", err_detect), UVM_HIGH)
  end
  else begin
    if(vif.REG_UART_CHECK_MODE_SEL)      
      err_detect = get_ecc(data_in);
    else err_detect = get_crc(data_in);
  end

  return err_detect;
endfunction: err_detect

endclass:uart_check_err_driver

`endif //`ifndef UART_CHECK_ERR_DRIVER

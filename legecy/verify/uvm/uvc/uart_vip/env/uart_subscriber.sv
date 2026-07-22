
`ifndef GUARD_UART_SUBSCRIBER_SV
`define GUARD_UART_SUBSCRIBER_SV

/** Use uvm_analysis_imp_decl macros to declare analysis imp for subscriber */
`uvm_analysis_imp_decl(_recv)

/**
 * Abstract: 
 * class 'uart_subscriber' is extended from ovm_component base class. 
 * uart_subscriber monitors Agent monitor’s analysis port. It implements few APIs which reads
 * the received data back from the VIP and also compares received data with the transmitted data.
 * 
 * Users can call these APIs from the top level test based on the requirement. 

 * uart_subscriber is the testbench environment component, which implements  
 * 
 * - pop_fifo_char to read single received character
 * - pop_fifo_string to read specified number of characters
 * - pop_fifo_char_expect to read single received character and compare it with user expected character
 * - pop_fifo_string_expect to read specified number of characters and compare it with user expected characters
 * . 
 */
class uart_subscriber extends uvm_component;

  /** Analysis export declaration **/
  uvm_analysis_imp_recv #(svt_uart_transaction, uart_subscriber) item_collected_recv;

  /** Queue used to hold Received transaction */
  svt_uart_transaction recv_fifo_queue[$];

  /** Instance of configuration class */
  svt_uart_configuration cfg; 

  /** variable to count number of transaction recieved */
  int xact_count = 0;

  /** UVM Utility Macros*/
  `uvm_component_utils_begin(uart_subscriber)
    `uvm_field_int(xact_count, UVM_ALL_ON | UVM_NOPRINT)
    `uvm_field_object(cfg, UVM_ALL_ON | UVM_NOPRINT)
  `uvm_component_utils_end

  /** new - constructor */
  extern function new (string name = "uart_subscriber", uvm_component parent = null);

  /** build to create analysis ports and make a copy of the configuration after retriveing */
  extern virtual function void build_phase(uvm_phase phase);

  /** write_recv */
  extern virtual function void write_recv(svt_uart_transaction tr);

  /** Task which Reads single received character */
  extern task pop_fifo_char(output bit [`SVT_UART_MAX_DATA_WIDTH-1:0] recv_data);

  /** Task which Reads specified number of characters */
  extern task pop_fifo_string(input int num_chars, output bit [`SVT_UART_MAX_DATA_WIDTH-1:0] recv_data[]);

  /** Task which Reads single received character and compare it with user expected character */
  extern task pop_fifo_char_expect(input bit [`SVT_UART_MAX_DATA_WIDTH-1:0] exp_data, output bit [`SVT_UART_MAX_DATA_WIDTH-1:0] recv_data);

  /** Task which Reads specified number of characters and compare it with user expected characters */
  extern task pop_fifo_string_expect(input int num_chars, input bit [`SVT_UART_MAX_DATA_WIDTH-1:0] exp_data[], output bit [`SVT_UART_MAX_DATA_WIDTH-1:0] recv_data[]);

endclass: uart_subscriber 

//---------------------------------------------------------------------------------------------
// new()
//---------------------------------------------------------------------------------------------
function uart_subscriber::new (string name = "uart_subscriber", uvm_component parent = null);
  super.new(name, parent);
endfunction: new

//---------------------------------------------------------------------------------------------
// build_phase()
//---------------------------------------------------------------------------------------------
function void uart_subscriber::build_phase(uvm_phase phase);

  super.build_phase(phase);

  /** construct the analysis exports **/
  item_collected_recv = new("item_collected_recv", this);

  /** Retrieve the configuration from the config_db */
  if (cfg == null && !uvm_config_db#(svt_uart_configuration)::get(this,  "",  "cfg",  cfg)) begin
  `uvm_fatal("uart_subscriber",$sformatf("'cfg' is null. An svt_uart_configuration object or derivitive object must be set using the configuration infrastructure."))
  end
endfunction: build_phase

//---------------------------------------------------------------------------------------------
// write_recv()
//---------------------------------------------------------------------------------------------
function void uart_subscriber::write_recv(svt_uart_transaction tr);
  svt_uart_transaction tr_temp;
  tr_temp = svt_uart_transaction::type_id::create("tr_temp");
  tr_temp.copy(tr);
  recv_fifo_queue.push_back(tr_temp);
  xact_count ++;
  //`uvm_info("uart_subscriber:write_recv",$sformatf("Transaction count is xact_count=%d",xact_count),UVM_LOW)

endfunction: write_recv

//---------------------------------------------------------------------------------------------
// pop_fifo_char() : Reads single received character
//---------------------------------------------------------------------------------------------
task uart_subscriber::pop_fifo_char(output bit [`SVT_UART_MAX_DATA_WIDTH-1:0] recv_data);
  svt_uart_transaction tr_recv;
  
  if (recv_fifo_queue.size() == 0)
    wait(recv_fifo_queue.size() > 0);
  tr_recv = recv_fifo_queue.pop_front();
  recv_data = tr_recv.payload[0];
  `uvm_info("uart_subscriber:pop_fifo_char",$sformatf("Received character is recv_data=%0b",recv_data),UVM_LOW)
  xact_count --;
  `uvm_info("uart_subscriber:pop_fifo_char",$sformatf("Transaction count is xact_count=%d",xact_count),UVM_LOW)
endtask: pop_fifo_char

//---------------------------------------------------------------------------------------------
// pop_fifo_string() : Reads specified number of characters 
//---------------------------------------------------------------------------------------------
task uart_subscriber::pop_fifo_string(input int num_chars, output bit [`SVT_UART_MAX_DATA_WIDTH-1:0] recv_data[]);

  svt_uart_transaction tr_recv;
  recv_data =new[num_chars];
  
  for(int k=0;k< num_chars; k++)
    begin
      if (recv_fifo_queue.size() == 0)
        wait(recv_fifo_queue.size() > 0);
      tr_recv = recv_fifo_queue.pop_front();
      recv_data[k] = tr_recv.payload[0];
      `uvm_info("uart_subscriber:pop_fifo_string",$sformatf("Received character is recv_data[]=%0b",recv_data[k]),UVM_LOW)
      xact_count --;
      `uvm_info("uart_subscriber:pop_fifo_string",$sformatf("Transaction count is xact_count=%d",xact_count),UVM_LOW)
    end
endtask: pop_fifo_string

//------------------------------------------------------------------------------------------------------
// pop_fifo_char_expect() : Reads single received character and compare it with user expected character
//------------------------------------------------------------------------------------------------------
task uart_subscriber::pop_fifo_char_expect(input bit [`SVT_UART_MAX_DATA_WIDTH-1:0] exp_data, output bit [`SVT_UART_MAX_DATA_WIDTH-1:0] recv_data);
  svt_uart_transaction tr_recv;
  
  if (recv_fifo_queue.size() == 0)
    wait(recv_fifo_queue.size() > 0);
  tr_recv = recv_fifo_queue.pop_front();
  recv_data = tr_recv.payload[0];

  case(cfg.data_width)
      
    5:
      begin
        `uvm_info("uart_subscriber:pop_fifo_char_expect",$sformatf("Expected character is %0b and payload is %0b",exp_data,tr_recv.payload[0][4:0]),UVM_LOW)
        if(exp_data != tr_recv.payload[0][4:0])
        `uvm_error("uart_subscriber:pop_fifo_char_expect",$sformatf("Mismatch happened between expected character=%0b and payload=%0b",exp_data,tr_recv.payload[0][4:0]))
      end
    6:
      begin
        `uvm_info("uart_subscriber:pop_fifo_char_expect",$sformatf("Expected character is %0b and payload is %0b",exp_data,tr_recv.payload[0][5:0]),UVM_LOW)
        if(exp_data != tr_recv.payload[0][5:0])
        `uvm_error("uart_subscriber:pop_fifo_char_expect",$sformatf("Mismatch happened between expected character=%0b and payload=%0b",exp_data,tr_recv.payload[0][5:0]))
      end
    7:
      begin
        `uvm_info("uart_subscriber:pop_fifo_char_expect",$sformatf("Expected character is %0b and payload is %0b",exp_data,tr_recv.payload[0][6:0]),UVM_LOW)
        if(exp_data != tr_recv.payload[0][6:0])
        `uvm_error("uart_subscriber:pop_fifo_char_expect",$sformatf("Mismatch happened between expected character=%0b and payload=%0b",exp_data,tr_recv.payload[0][6:0]))
      end
    8:
      begin
        `uvm_info("uart_subscriber:pop_fifo_char_expect",$sformatf("Expected character is %0b and payload is %0b",exp_data,tr_recv.payload[0][7:0]),UVM_LOW)
        if(exp_data != tr_recv.payload[0][7:0])
        `uvm_error("uart_subscriber:pop_fifo_char_expect",$sformatf("Mismatch happened between expected character=%0b and payload=%0b",exp_data,tr_recv.payload[0][7:0]))
      end
    9:
      begin
        `uvm_info("uart_subscriber:pop_fifo_char_expect",$sformatf("Expected character is %0b and payload is %0b",exp_data,tr_recv.payload[0][8:0]),UVM_LOW)
        if(exp_data != tr_recv.payload[0][8:0])
          `uvm_error("uart_subscriber:pop_fifo_char_expect",$sformatf("Mismatch happened between expected character=%0b and payload=%0b",exp_data,tr_recv.payload[0][8:0]))
      end
    10:
      begin
        `uvm_info("uart_subscriber:pop_fifo_char_expect",$sformatf("Expected character is %0b and payload is %0b",exp_data,tr_recv.payload[0][9:0]),UVM_LOW)
        if(exp_data != tr_recv.payload[0][9:0])
          `uvm_error("uart_subscriber:pop_fifo_char_expect",$sformatf("Mismatch happened between expected character=%0b and payload=%0b",exp_data,tr_recv.payload[0][9:0]))
      end
    11:
      begin
        `uvm_info("uart_subscriber:pop_fifo_char_expect",$sformatf("Expected character is %0b and payload is %0b",exp_data,tr_recv.payload[0][10:0]),UVM_LOW)
        if(exp_data != tr_recv.payload[0][10:0])
          `uvm_error("uart_subscriber:pop_fifo_char_expect",$sformatf("Mismatch happened between expected character=%0b and payload=%0b",exp_data,tr_recv.payload[0][10:0]))
      end
    12:
      begin
        `uvm_info("uart_subscriber:pop_fifo_char_expect",$sformatf("Expected character is %0b and payload is %0b",exp_data,tr_recv.payload[0][11:0]),UVM_LOW)
        if(exp_data != tr_recv.payload[0][11:0])
          `uvm_error("uart_subscriber:pop_fifo_char_expect",$sformatf("Mismatch happened between expected character=%0b and payload=%0b",exp_data,tr_recv.payload[0][11:0]))
      end
  endcase // case(cfg.data_width)

  `uvm_info("uart_subscriber:pop_fifo_char_expect",$sformatf("Received character is recv_data=%0b",recv_data),UVM_LOW)
  xact_count --;
  `uvm_info("uart_subscriber:pop_fifo_char_expect",$sformatf("Transaction count is xact_count=%d",xact_count),UVM_LOW)
endtask: pop_fifo_char_expect

//---------------------------------------------------------------------------------------------------------------
// pop_fifo_string_expect() : Reads specified number of characters and compare it with user expected characters
//---------------------------------------------------------------------------------------------------------------
task uart_subscriber::pop_fifo_string_expect(input int num_chars, input bit [`SVT_UART_MAX_DATA_WIDTH-1:0] exp_data[], output bit [`SVT_UART_MAX_DATA_WIDTH-1:0] recv_data[]);
  svt_uart_transaction tr_recv;
  recv_data =new[num_chars];

  for(int k=0;k< num_chars; k++)
    begin
      if (recv_fifo_queue.size() == 0)
        wait(recv_fifo_queue.size() > 0);
      tr_recv = recv_fifo_queue.pop_front();
      recv_data[k] = tr_recv.payload[0];

      case(cfg.data_width)
          
        5:
          begin
            `uvm_info("uart_subscriber:pop_fifo_string_expect",$sformatf("Expected character is %0b and payload is %0b",exp_data[k],tr_recv.payload[0][4:0]),UVM_LOW)
            if(exp_data[k] != tr_recv.payload[0][4:0])
            `uvm_error("uart_subscriber:pop_fifo_string_expect",$sformatf("Mismatch happened between expected character=%0b and payload=%0b",exp_data[k],tr_recv.payload[0][4:0]))
          end
        6:
          begin
            `uvm_info("uart_subscriber:pop_fifo_string_expect",$sformatf("Expected character is %0b and payload is %0b",exp_data[k],tr_recv.payload[0][5:0]),UVM_LOW)
            if(exp_data[k] != tr_recv.payload[0][5:0])
            `uvm_error("uart_subscriber:pop_fifo_string_expect",$sformatf("Mismatch happened between expected character=%0b and payload=%0b",exp_data[k],tr_recv.payload[0][5:0]))
          end
        7:
          begin
            `uvm_info("uart_subscriber:pop_fifo_string_expect",$sformatf("Expected character is %0b and payload is %0b",exp_data[k],tr_recv.payload[0][6:0]),UVM_LOW)
            if(exp_data[k] != tr_recv.payload[0][6:0])
            `uvm_error("uart_subscriber:pop_fifo_string_expect",$sformatf("Mismatch happened between expected character=%0b and payload=%0b",exp_data[k],tr_recv.payload[0][6:0]))
          end
        8:
          begin
            `uvm_info("uart_subscriber:pop_fifo_string_expect",$sformatf("Expected character is %0b and payload is %0b",exp_data[k],tr_recv.payload[0][7:0]),UVM_LOW)
            if(exp_data[k] != tr_recv.payload[0][7:0])
            `uvm_error("uart_subscriber:pop_fifo_string_expect",$sformatf("Mismatch happened between expected character=%0b and payload=%0b",exp_data[k],tr_recv.payload[0][7:0]))
          end
        9:
          begin
            `uvm_info("uart_subscriber:pop_fifo_string_expect",$sformatf("Expected character is %0b and payload is %0b",exp_data[k],tr_recv.payload[0][8:0]),UVM_LOW)
            if(exp_data[k] != tr_recv.payload[0][8:0])
            `uvm_error("uart_subscriber:pop_fifo_string_expect",$sformatf("Mismatch happened between expected character=%0b and payload=%0b",exp_data[k],tr_recv.payload[0][8:0]))
          end
        10:
          begin
            `uvm_info("uart_subscriber:pop_fifo_string_expect",$sformatf("Expected character is %0b and payload is %0b",exp_data[k],tr_recv.payload[0][9:0]),UVM_LOW)
            if(exp_data[k] != tr_recv.payload[0][9:0])
            `uvm_error("uart_subscriber:pop_fifo_string_expect",$sformatf("Mismatch happened between expected character=%0b and payload=%0b",exp_data[k],tr_recv.payload[0][9:0]))
          end
        11:
          begin
            `uvm_info("uart_subscriber:pop_fifo_string_expect",$sformatf("Expected character is %0b and payload is %0b",exp_data[k],tr_recv.payload[0][10:0]),UVM_LOW)
            if(exp_data[k] != tr_recv.payload[0][10:0])
            `uvm_error("uart_subscriber:pop_fifo_string_expect",$sformatf("Mismatch happened between expected character=%0b and payload=%0b",exp_data[k],tr_recv.payload[0][10:0]))
          end
        12:
          begin
            `uvm_info("uart_subscriber:pop_fifo_string_expect",$sformatf("Expected character is %0b and payload is %0b",exp_data[k],tr_recv.payload[0][11:0]),UVM_LOW)
            if(exp_data[k] != tr_recv.payload[0][11:0])
            `uvm_error("uart_subscriber:pop_fifo_string_expect",$sformatf("Mismatch happened between expected character=%0b and payload=%0b",exp_data[k],tr_recv.payload[0][11:0]))
          end
      endcase // case(cfg.data_width)
      `uvm_info("uart_subscriber:pop_fifo_string_expect",$sformatf("Received character is recv_data[]=%0b",recv_data[k]),UVM_LOW)
      xact_count --;
      `uvm_info("uart_subscriber:pop_fifo_string_expect",$sformatf("Transaction count is xact_count=%d",xact_count),UVM_LOW)
    end
endtask: pop_fifo_string_expect

`endif // `ifndef GUARD_UART_SUBSCRIBER_SV

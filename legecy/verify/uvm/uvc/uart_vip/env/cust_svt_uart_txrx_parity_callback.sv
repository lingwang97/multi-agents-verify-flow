
`ifndef GUARD_CUST_SVT_UART_TXRX_PARITY_CALLBACK_SV
`define GUARD_CUST_SVT_UART_TXRX_PARITY_CALLBACK_SV

/** 
 * Class cust_svt_uart_txrx_parity_callback takes the transaction object from
 * the driver's callback and inserts PARITY ERROR exception.
 *
 * For inserting FRAMING ERROR user can assign the type of error  
 * inside post_seq_item_get function as follows:
 * exception.error_kind = svt_uart_transaction_exception::FRAMING_ERROR;
 */
class cust_svt_uart_txrx_parity_callback extends svt_uart_txrx_callback;

  /** Constructor */
  function new(string name);
    super.new(name);
  endfunction: new
  
  /** 
   * Callback issued after pulling a transaction descriptor out of its input TLM port,  
   * but before acting on the transaction descriptor in any way.
   */
  virtual function void post_seq_item_get(svt_uart_txrx component, svt_uart_transaction xact, ref bit drop);

    /** Create a local handle of exception list and exception class */
    //svt_uart_transaction_exception_list cust_exception_list;
    //svt_uart_transaction_exception      exception;
   //`uvm_info("body", "Inserting Exception ...", UVM_NONE)


   `uvm_info("body", "Inserting ******callback ********* ...", UVM_NONE)

 
   //    /** Create the exception class */
   //    exception = new("cust_exception");

   //    /** Create the exception list and pass exception handle */
   //    cust_exception_list = new("cust_exception_list",exception);

   //    /** Push the configuration and transaction into the exception object */
   //    cust_exception_list.setup_randomized_exception(xact.cfg,xact);  

   //    /** Assign the type of error to be inserted in exception class*/
   //    exception.error_kind = svt_uart_transaction_exception::PARITY_ERROR;

   //    /** Number of times error injection*/
   //    exception.error_cnt = 2;

   //    /** Add the exception class to the exception list */
   //    cust_exception_list.add_exception(exception);

   //    /** Write the handle of local exception list to the transaction exception list handle */
   //    void'($cast(xact.exception_list, cust_exception_list));

  endfunction: post_seq_item_get
endclass: cust_svt_uart_txrx_parity_callback
`endif // GUARD_CUST_SVT_UART_TXRX_PARITY_CALLBACK_SV



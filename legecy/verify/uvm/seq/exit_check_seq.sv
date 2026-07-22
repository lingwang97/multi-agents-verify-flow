class exit_check_seq extends base_seq;
   virtual top_if   top_vif;
   `uvm_object_utils(exit_check_seq)

   //////////////////////////////////////////////////////////////
   // Function Used To "New" The Class
   //////////////////////////////////////////////////////////////
   function new(string name="exit_check_seq");
      super.new(name);
   endfunction : new

   task pre_body();
     super.pre_body();
     if (!uvm_config_db #(virtual interface top_if)::get(m_sequencer, "", "top_vif", top_vif))
      `uvm_error("RO_VIP:ERROR", "VIF top_vif is missing from config_db")

   endtask

   task body();
     //super.body();
     mid_clk_calc();

     `ifdef USE_JAMLINK_DRV
     ci_clk_calc();
     uart_cnt_check();
     `endif

     `ifndef NO_ECC_CHK
     `ifndef USE_UART_DRV
	 `ifdef USE_JAMLINK_DRV
     ral_chkc_exit();
	 `endif
     `endif
     `endif
    #1000;// for jls_jam_datacheck() in jls scoreboard   by wuqiang,do not change

   endtask


  //-----------------------------------------------------------------------
  // uart err detect turn off under jlm mode
  //-----------------------------------------------------------------------
  task  uart_cnt_check();
    uvm_reg targets[$];
    bit [31:0] rd_data;

    targets.push_back(ral.reg_uart_timeout);
    targets.push_back(ral.reg_uart_hdrpass);
    targets.push_back(ral.reg_uart_hdrfail);
    targets.push_back(ral.reg_uart_chkpass);
    targets.push_back(ral.reg_uart_chkfail);
    targets.push_back(ral.reg_uart_rx_start_err);
    targets.push_back(ral.reg_uart_rx_glitch);
    
    foreach(targets[i])begin
      targets[i].read(status, rd_data, UVM_BACKDOOR, ,this);
      if(rd_data!=0)begin
        `uvm_error(get_type_name(), $sformatf("[ERR] %s rd_data = 'h%0h != 0",targets[i].get_name(), rd_data))
      end
      else begin 
        `uvm_info(get_type_name(), $sformatf("[SUCC] %s rd_data = 'h%0h == 0",targets[i].get_name(), rd_data), UVM_HIGH)
      end
    end

  endtask:uart_cnt_check



   virtual task ral_chkc_exit();
       logic [31:0] ecc0,ecc1,ecc2;
	   top_vif.chipaddr = 0;
	   ral.comm.reg_ecc0.rd(ecc0);
	   ral.comm.reg_ecc1.rd(ecc1);
	   ral.comm.reg_ecc2.rd(ecc2);
	   //if()
	   if(ecc1 != 32'h0) begin
			`uvm_error(get_type_name(), $psprintf("Jls ecc1 is not 32'h0, the value is %h, please check this",ecc1))
	   end

	   if(ecc2 != 32'h0) begin
			`uvm_error(get_type_name(), $psprintf("Jls ecc2 is not 32'h0, the value is %h, please check this",ecc2))
	   end

   endtask

   virtual task mid_clk_calc();

       realtime time1,time2,period,freq;
       `uvm_info(get_type_name(), $psprintf("mid_clk_calc start ..."),UVM_MEDIUM);
      
      fork 
        begin
          @(posedge top_vif.jls_mid_clk);
          time1 = $realtime();
          @(posedge top_vif.jls_mid_clk);
          time2 = $realtime();
          period = time2 - time1;
          freq = 1000/period;
          `uvm_info(get_type_name(), $psprintf("\n\n\n************************************************\n mid_clk frequence check: \n mid_clk_period:      %f ns\n mid_clk_freq  :      %f MHz\n************************************************\n\n",period,freq),UVM_MEDIUM);
        end
        begin
          #4us;
          `uvm_warning(get_type_name(), $sformatf("MID_CLK TIMEOUT !!!"))
        end
      join_any

      disable fork;
   endtask

   virtual task ci_clk_calc();

       realtime time1,time2,period,freq;
       `uvm_info(get_type_name(), $psprintf("ci_clk_calc start ..."),UVM_MEDIUM);

      fork 
        begin
          @(posedge top_vif.jls_pin_ci);
          time1 = $realtime();
          @(posedge top_vif.jls_pin_ci);
          time2 = $realtime();
          period = time2 - time1;
          freq = 1000/period;
          `uvm_info(get_type_name(), $psprintf("\n\n\n************************************************\n ci_clk frequence check: \n ci_clk_period:      %f ns\n ci_clk_freq  :      %f MHz\n************************************************\n\n",period,freq),UVM_MEDIUM);
        end
        begin
          #4us;
          `uvm_warning(get_type_name(), $sformatf("CI_CLK TIMEOUT !!!"))
        end
      join_any

      disable fork;
   endtask

endclass: exit_check_seq

class jls_driver extends uvm_driver#(jls_sequence_item);

  uvm_analysis_port #(jls_sequence_item) ap;
  jls_sequence_item req;
  jls_sequence_item rsp;
  RAL_PKG::ral_gen_main 	ral;  
  `uvm_component_utils(jls_driver);

  virtual jls_if vif;
  jls_base_cfg m_cfg; 
  logic xclk_pwrite_r;
  logic pwrite_r;
  
  function new(string name="jls_driver" , uvm_component parent=null);
    super.new(name , parent);
    ap = new("ap", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual jls_if)::get(this , "" , "jls_vif" ,vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")

    if (!uvm_config_db #(jls_base_cfg)::get(this, "", "jls_config", m_cfg) )
      `uvm_info("CONFIG_LOAD", "Cannot get configuration jls_config from uvm_config_db. Have you set it?", UVM_MEDIUM)

    if(!uvm_config_db#(RAL_PKG::ral_gen_main)::get(this , "" , "ral" ,ral))
      `uvm_fatal(get_full_name(), "Ral handle missing")

      
  endfunction

  
  `ifdef USE_RAL_MODEL

  task run_phase(uvm_phase phase);

    reset_signals();
    `uvm_info(get_type_name(), "Wait por start begin", UVM_MEDIUM)
    #1000ns; // Jerry add 2023/8/11
    `uvm_info(get_type_name(), "Wait por finish end", UVM_MEDIUM)

    fork
    get_and_drive();      
    do_reset();
    join_none

  endtask:run_phase


  virtual task get_and_drive(); 
      `uvm_info(get_type_name(), "Starting Driver:  Null ........", UVM_MEDIUM)
  endtask:get_and_drive

  
  task do_reset();
    fork
      forever begin
        @(!vif.mid_rst_f_n);  //jira sm2-105
          vif.psel	  <= 0;
	        vif.pwrite	<= 0;
	        vif.paddr   <= 0;
          vif.pwdata	<= 0;
	        vif.penable	<= 0;      
      end
    join_none
  endtask:do_reset


  `else
  task main_phase(uvm_phase phase);
    bit [31:0] data;
  endtask

  `endif

  task do_drive();
      `uvm_info(get_full_name(), "Entering ... " , UVM_FULL)
      @(posedge vif.clk);
      vif.card_sel  <= req.card_sel;
      `uvm_info(get_full_name(), "Exiting ... ", UVM_FULL)  
  endtask

  task reset_signals();
    vif.card_sel  <= 'h0;

    vif.std_psel 		<= 0;
    vif.std_penable 	<= 0;
    vif.std_paddr  	    <= 0;
    vif.std_pready 	    <= 0;
    vif.std_pwrite		<= 0;
    vif.std_pwdata		<= 0;

    vif.xclk_psel 		<= 0;
    vif.xclk_penable 	<= 0;
    vif.xclk_paddr  	<= 0;
    vif.xclk_pready 	<= 1;
    vif.xclk_pwrite		<= 0;
    vif.xclk_pwdata		<= 0;
    
    vif.psel 		  	<= 0;
    vif.penable 		<= 0;
    vif.paddr  			<= 0;
    vif.pready 			<= 1;
    vif.pwrite			<= 0;
    vif.pwdata			<= 0;
    `uvm_info(get_type_name(), "jls Driver:   reset all apb bus signal to zero........", UVM_MEDIUM)

  endtask


  
endclass


`define PROP_DELAY 0.3ns

`ifdef PL_SIM
  `define MID_PLS_DELAY #(`PROP_DELAY);
  `define PLS_DELAY  #(`XCLK_P_NS/4);
`elsif POST_SIM
  `define MID_PLS_DELAY #(`PROP_DELAY);
  `define PLS_DELAY #(`XCLK_P_NS/4);
`else
  `define MID_PLS_DELAY 
  `define PLS_DELAY
`endif




class jls_btc_driver extends jls_driver#(jls_sequence_item);
    uvm_table_printer my_printer;
    logic [31:0]    addr_base;
    logic [9:0]     length;
    logic [31:0]    addr;
    logic 		we;
	uvm_reg all_regs[$];

    `uvm_component_utils(jls_btc_driver);
    function new(string name="jls_btc_driver" , uvm_component parent=null);
        super.new(name , parent);
        my_printer = new();
        my_printer.knobs.prefix = "  ";
        my_printer.knobs.type_name = 0;
        my_printer.knobs.size = 0;

        
    endfunction


    virtual task get_and_drive();

        ral.get_registers(all_regs, UVM_HIER);

        `uvm_info(get_type_name(), "Starting Driver:   jls_btc_driver........", UVM_MEDIUM)
        forever begin:driver_code
            seq_item_port.get_next_item(req);
            addr = req.addr;		 
            we = req.we;

            foreach(all_regs[i]) begin
                if(all_regs[i].get_address == addr) begin
                    addr_base = all_regs[i].get_address;
                    length = all_regs[i].get_n_bits()/32;
                    break;
                end
            end

            wait(vif.mid_rst_f_n);

            `ifdef JLS_DEBUG
                if(req.we == 1'b1) begin
                    `uvm_info(get_type_name(),$sformatf("\n %d  Speed_up mode: reg wr, chip_id = %d, addr = 0x%h, wdata = 0x%h .",$time, 1'b0, req.addr, req.data), UVM_LOW)
                end 
                else begin
                    `uvm_info(get_type_name(),$sformatf("\n %d  Speed_up mode: reg rd, chip_id = %d, addr = 0x%h, rdata = 0x%h .",$time, 1'b0, req.addr, req.data), UVM_LOW)
                end
            `endif
            
            if((req.addr >= `DOMAIN_XCLK_BASE) && (req.addr <= `DOMAIN_XCLK_END)) begin
                xclk_jls_drv();
            end  
            else if((req.addr >=`DOMAIN_STD_BASE) && (req.addr <= `DOMAIN_STD_END))begin
                std_jls_drv();
            end         
            else begin
                jls_drv();
            end

            `ifdef JLS_DEBUG
                if(req.we == 1'b0) begin
                    `uvm_info(get_type_name(),$sformatf("\n %d  Speed_up mode:      							    rdata = 0x%h .",$time, req.data), UVM_LOW)
                end
            `endif

            length = length -1;
            seq_item_port.item_done();
            #5ns;

            if(length == 10'h0) begin//4
                foreach(all_regs[i]) begin//3
                    if(all_regs[i].get_address == addr_base) begin//2
                        if(we == 1'b0) begin
                            //$display("After read, the %s output info:",reg_name);
                            //all_regs[i].print();
                            $display("  ----------------------------------------------------");
                            $display("  | Register     Read           Time:",$time);
                            all_regs[i].print(my_printer);
                            break;

                        end           
                        else begin//1
                            //$display("After write, the %s output info:",reg_name);
                            //all_regs[i].print();
                            $display("  -----------------------------------------------------");
                            $display("  | Register     Write           Time:",$time);
                            all_regs[i].print(my_printer);

                            break;

                        end//1
                    end //2
                end//3
            end//4

        end:driver_code

    endtask:get_and_drive



    `ifdef PL_SIM
    // post gate level
    virtual task jls_drv();
        @(posedge vif.clk);
            `MID_PLS_DELAY
            vif.pwdata		<= req.data;
            vif.paddr 		<= req.addr;
        @(posedge vif.clk);
            `MID_PLS_DELAY
            vif.psel 		  <= 1;
            vif.pwrite		<= req.we;
            pwrite_r		  <= req.we;
        @(posedge vif.clk);
            `MID_PLS_DELAY
            vif.pwrite		<= 0;	  
            vif.penable	  <= 1;
            // @(posedge vif.clk);
            // vif.psel 	<= 0;
            // vif.penable	  <= 0;

        @(negedge vif.clk);
            req.data = vif.prdata;
            //if((pwrite_r == 0) && (vif.penable == 1) ) begin
            //req.data = vif.prdata;
            //end
        @(posedge vif.clk);
            `MID_PLS_DELAY
            vif.penable 		<= 0;

            // `ifdef POST_SIM
            //     @(posedge vif.clk);
            // `endif

            vif.psel 		<= 0;
            vif.paddr  		<= 0;
            vif.pready 		<= 1;
            vif.pwrite		<= 0;
            //vif.pwdata		<= 0;
    endtask



    virtual task xclk_jls_drv();
        @(posedge vif.xclk);
            `PLS_DELAY
            vif.paddr 	<= req.addr;
            vif.pwdata	<= req.data;
        @(posedge vif.xclk);
            `PLS_DELAY
            vif.xclk_psel 	<= 1;
            vif.xclk_pwrite	<= req.we;
            xclk_pwrite_r		<= req.we;
        @(posedge vif.xclk);
            `PLS_DELAY
            vif.xclk_penable  <= 1;
            vif.xclk_pwrite	  <= 0;
            // @(posedge vif.xclk);
            // 	vif.xclk_psel 	<= 0;
            //  vif.xclk_penable  <= 0;

        @(negedge vif.xclk);
            req.data = vif.xclk_prdata;  
            // if((xclk_pwrite_r == 0) && (vif.xclk_penable == 1) ) begin
            //     req.data = vif.xclk_prdata;
            // end

        @(posedge vif.xclk);
            `PLS_DELAY
            vif.xclk_psel 	  <= 0;
            vif.xclk_penable 	<= 0;
            vif.paddr  	<= 0;
            vif.xclk_pready 	<= 1;
            vif.xclk_pwrite	  <= 0;
            //vif.pwdata	  <= 0;
            xclk_pwrite_r     <= 0;

    endtask

    virtual task std_jls_drv();
        @(posedge vif.xclk);
            `PLS_DELAY
            vif.std_pwdata		<= req.data;
            vif.std_paddr 		<= req.addr;
        @(posedge vif.xclk);
            `PLS_DELAY
            vif.std_psel        <= 1;
            vif.std_pwrite		<= req.we;  
        @(posedge vif.xclk);
            `PLS_DELAY        
            vif.std_penable	        <= 1;
        @(posedge vif.std_pready);

        @(negedge vif.xclk);
            if((vif.std_pready == 1) && (vif.std_penable == 1) ) begin
                req.data = vif.std_prdata;
            
            end
        @(posedge vif.xclk);
            `PLS_DELAY

            //vif.std_pwdata	<= req.data;
            vif.std_paddr 		<= 0;
            vif.std_psel 	    <= 0;
            vif.std_pwrite	    <= 0;
            vif.std_penable     <= 0; 

    endtask

    `else
    //rtl level 

    virtual task std_jls_drv();
        //$display("=====DEBUG=======USE_STD_DRIVER+++++++++++++++++++Time:",$time);
        @(posedge vif.xclk);
            `PLS_DELAY
            vif.std_pwdata		<= req.data;
            vif.std_paddr 		<= req.addr;
            //$display("[DEBUG] req.data=%x,req_addr=%x",req.data,req.addr);
        @(posedge vif.xclk);
            `PLS_DELAY
            vif.std_psel        <= 1;
            vif.std_pwrite		<= req.we;  
            //$display("[DEBUG] req.we=%x,",req.we);
        @(posedge vif.xclk);
            `PLS_DELAY        
            vif.std_penable	        <= 1;
        @(posedge vif.std_pready);
            //$display("=====DEBUG======JLS GET PREADY+++++++++++++++++++Time:",$time);
        @(negedge vif.xclk);
            if((vif.std_pready == 1) && (vif.std_penable == 1) ) begin
                req.data = vif.std_prdata;
                //$display("=====DEBUG======JLS GET RDATA+++++++++++++++++++Time:",$time);
                //$display("[DEBUG] read: req.data=%x",req.data);
            end
        @(posedge vif.xclk);
            `PLS_DELAY

            //vif.std_pwdata	<= req.data;
            vif.std_paddr 		<= 0;
            vif.std_psel 	    <= 0;
            vif.std_pwrite	    <= 0;
            vif.std_penable     <= 0; 

    endtask

    virtual task jls_drv();
        @(posedge vif.clk);
            `MID_PLS_DELAY
            vif.pwdata		<= req.data;
            vif.paddr 		<= req.addr;
        @(posedge vif.clk);
            `MID_PLS_DELAY
            vif.psel 		  <= 1;
            vif.pwrite		<= req.we;
            pwrite_r		  <= req.we;
        @(posedge vif.clk);
            `MID_PLS_DELAY
            vif.pwrite		<= 0;	  
            vif.penable	  <= 1;
        @(negedge vif.clk);
            if((pwrite_r == 0) && (vif.penable == 1) ) begin
                req.data = vif.prdata;
            end
        @(posedge vif.clk);
            `MID_PLS_DELAY
            vif.penable 	<= 0;

            // `ifdef POST_SIM
            //     @(posedge vif.clk);
            // `endif

            vif.psel 		<= 0;
            vif.paddr  		<= 0;
            vif.pready 		<= 1;
            vif.pwrite		<= 0;
            //vif.pwdata		<= 0;
    endtask



    virtual task xclk_jls_drv();

        @(posedge vif.xclk);
            `PLS_DELAY
            vif.paddr 	<= req.addr;
            vif.pwdata	<= req.data;
        @(posedge vif.xclk);
            `PLS_DELAY
            vif.xclk_psel 	<= 1;
            vif.xclk_pwrite	<= req.we;
            xclk_pwrite_r		<= req.we;
        @(posedge vif.xclk);
            `PLS_DELAY
            vif.xclk_penable  <= 1;
            vif.xclk_pwrite	  <= 0;
        @(negedge vif.xclk);
            if((xclk_pwrite_r == 0) && (vif.xclk_penable == 1) ) begin
                req.data = vif.xclk_prdata;
            end
        @(posedge vif.xclk);
            `PLS_DELAY
            vif.xclk_psel 	  <= 0;
            vif.xclk_penable 	<= 0;
            vif.paddr  	<= 0;
            vif.xclk_pready 	<= 1;
            vif.xclk_pwrite	  <= 0;
            //vif.pwdata	  <= 0;
            xclk_pwrite_r     <= 0;

    endtask


    `endif

endclass


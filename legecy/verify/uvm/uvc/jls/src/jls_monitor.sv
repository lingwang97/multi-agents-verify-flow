
class jls_monitor extends base_monitor;

  uvm_analysis_port #(jls_item) jls_monitor_main_ap;  //nouse
  uvm_analysis_port #(jls_coverage_item) frame_collected_port;
  uvm_analysis_port #(jls_sequence_item) jls_monitor_adapter_ap;
  //
  `uvm_component_utils(jls_monitor);

  jls_coverage_item req;
  jls_item jls_item_h;
  jls_sequence_item jls_item_adapter;

  virtual jls_if vif;
  


  function new(string name="jls_monitor" , uvm_component parent=null);
    super.new(name , parent);
    jls_monitor_main_ap = new("jls_monitor_main_ap",this);
    frame_collected_port = new("frame_collected_port",this);
    jls_monitor_adapter_ap = new("jls_monitor_adapter_ap",this);
  endfunction
 
   function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual jls_if)::get(this , "" , "jls_vif" ,vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")

    req = jls_coverage_item::type_id::create("req",this);
    jls_item_adapter = jls_sequence_item::type_id::create("jls_item_adapter",this);      
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    #100ns;//wait POR reset release
    fork
      //main_traffic();
      collect_coverage();
	  `ifdef USE_RAL_MODEL
	  `ifndef USE_JAMLINK_DRV
	  `ifndef USE_UART_DRV

 mid_tran_adapter();
 xclk_tran_adapter();

	  `endif

	  `endif
	  `endif

    join_none
  endtask :run_phase   
  
  
  // -----------------------------------------
  // External task defined here
  // -----------------------------------------
  //extern task main_traffic();
  extern task collect_coverage();
  extern task  mid_tran_adapter();
  extern task  xclk_tran_adapter();


endclass:jls_monitor



//task jls_monitor::main_traffic();
//    begin
//    forever
//    begin
//      wait(~vif.rst);
//      @(posedge vif.clk);
//      begin
//        jls_item_h.card_sel = vif.card_sel  ;
//        jls_monitor_main_ap.write(jls_item_h);
//      end
//    end
//    end
//endtask

task jls_monitor::collect_coverage();
    begin 
    forever
    begin
    @(posedge vif.clk);
    req.card_sel  = vif.card_sel  ;
    frame_collected_port.write(req);   
    end
    end
endtask

`ifdef USE_RAL_MODEL
`ifndef USE_JAMLINK_DRV
`ifndef USE_UART_DRV

task jls_monitor::mid_tran_adapter();
    begin
    	forever begin
      	//wait(vif.wait_flag === 1'b1);
        #1;
        @(posedge vif.psel);
        @(negedge vif.clk); 
        if (vif.pwrite==1'b1 && vif.penable==1'b0 ) begin //write
          @(negedge vif.clk);    
            if (vif.penable==1'b1)begin
              jls_item_adapter.addr = vif.paddr;
              jls_item_adapter.we 	= 1'b1;
              jls_item_adapter.data 	= vif.pwdata;
              `ifdef JLS_DATA_DEBUG          
              $display("-------------------------------------------------------");
              $display("APB BEGIN PRIDICT MIDCLK:");
              $display("now time :",$time);
              $display("jls_sequence_item.addr= %h",jls_item_adapter.addr);
              $display("jls_sequence_item.we= %h",jls_item_adapter.we);
              $display("jls_sequence_item.data= %h",jls_item_adapter.data);
              $display("-------------------------------------------------------");
              `endif        
              jls_monitor_adapter_ap.write(jls_item_adapter);
            end
      	end
        else if (vif.pwrite==1'b0 && vif.penable==1'b0) begin  //read
          @(negedge vif.clk);    
            if (vif.penable==1'b1)begin
              jls_item_adapter.addr = vif.paddr;
              jls_item_adapter.we 	= 1'b0;
              jls_item_adapter.data 	= vif.prdata;
              `ifdef JLS_DATA_DEBUG          
              $display("-------------------------------------------------------");
              $display("APB BEGIN PRIDICT MIDCLK:");
              $display("now time :",$time);
              $display("jls_sequence_item.addr= %h",jls_item_adapter.addr);
              $display("jls_sequence_item.we= %h",jls_item_adapter.we);
              $display("jls_sequence_item.data= %h",jls_item_adapter.data);
              $display("-------------------------------------------------------");
              `endif        
              jls_monitor_adapter_ap.write(jls_item_adapter);
            end
        end
    	end
    end
endtask




task jls_monitor::xclk_tran_adapter();
    begin
    	forever begin
      	//wait(vif.wait_flag === 1'b1);
        #1;
        @(posedge vif.xclk_psel);
        @(negedge vif.xclk); 
        if (vif.xclk_pwrite==1'b1 && vif.xclk_penable==1'b0 ) begin //write
          @(negedge vif.xclk);    
            if (vif.xclk_penable==1'b1)begin
              jls_item_adapter.addr = vif.paddr;
              jls_item_adapter.we 	= 1'b1;
              jls_item_adapter.data 	= vif.pwdata;
              `ifdef JLS_DATA_DEBUG        
              $display("-------------------------------------------------------");
              $display("APB BEGIN PRIDICT XCLK:");
              $display("now time :",$time);
              $display("jls_sequence_item.addr= %h",jls_item_adapter.addr);
              $display("jls_sequence_item.we= %h",jls_item_adapter.we);
              $display("jls_sequence_item.data= %h",jls_item_adapter.data);
              $display("-------------------------------------------------------");
              `endif
              jls_monitor_adapter_ap.write(jls_item_adapter);
            end
      	end
        else if (vif.xclk_pwrite==1'b0 && vif.xclk_penable==1'b0) begin  //read
          @(negedge vif.xclk);    
            if (vif.xclk_penable==1'b1)begin
              jls_item_adapter.addr = vif.paddr;
              jls_item_adapter.we 	= 1'b0;
              jls_item_adapter.data 	= vif.xclk_prdata;
              `ifdef JLS_DATA_DEBUG         
              $display("-------------------------------------------------------");
              $display("APB BEGIN PRIDICT XCLK:");
              $display("now time :",$time);
              $display("jls_sequence_item.addr= %h",jls_item_adapter.addr);
              $display("jls_sequence_item.we= %h",jls_item_adapter.we);
              $display("jls_sequence_item.data= %h",jls_item_adapter.data);
              $display("-------------------------------------------------------");
              `endif        
              jls_monitor_adapter_ap.write(jls_item_adapter);
            end
        end
    	end
    end
endtask




`endif


`endif
`endif




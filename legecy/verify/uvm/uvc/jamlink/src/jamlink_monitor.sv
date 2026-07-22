
class jamlink_monitor extends base_monitor;

  uvm_analysis_port #(jamlink_item) jamlink_monitor_main_ap;
  uvm_analysis_port #(jamlink_coverage_item) frame_collected_port;
  uvm_analysis_port #(jamlink_sequence_item) jamlink_monitor_adapter_ap;

  `uvm_component_utils(jamlink_monitor);

  jamlink_coverage_item req;
  jamlink_item jamlink_item_h;
  jamlink_sequence_item jamlink_item_adapter;


  virtual jamlink_if vif_jamlink;
  virtual jls_if vif;
  
  extern task main_traffic();
  extern task collect_coverage();
  extern task mid_tran_adapter();
  extern task xclk_tran_adapter();

  function new(string name="jamlink_monitor" , uvm_component parent=null);
    super.new(name , parent);
    jamlink_monitor_main_ap = new("jamlink_monitor_main_ap",this);
    frame_collected_port = new("frame_collected_port",this);
    jamlink_monitor_adapter_ap = new("jamlink_monitor_adapter_ap",this);

  endfunction
 
   function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual jamlink_if)::get(this , "" , "jamlink_vif" ,vif_jamlink))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
    if(!uvm_config_db#(virtual jls_if)::get(this , "" , "jls_vif" ,vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")


    req = jamlink_coverage_item::type_id::create("req",this);
    jamlink_item_h = jamlink_item::type_id::create("jamlink_item_h",this);
    jamlink_item_adapter = jamlink_sequence_item::type_id::create("jamlink_item_adapter",this); 

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction
  
  task main_phase(uvm_phase phase);
    //super.run_phase(phase);
    if (`CHIP_NUM == 1)begin
      fork
        collect_coverage();    
	    `ifdef USE_RAL_MODEL
	    `ifdef USE_JAMLINK_DRV
      `ifndef JLM_NO_PREDICT
        mid_tran_adapter();	  	
        xclk_tran_adapter();
	    `endif        
	    `endif
	    `endif
      join_none
    end
    else begin
      collect_coverage();
    end

  endtask  
endclass

task jamlink_monitor::main_traffic();
    begin
    forever
    begin
      wait(~vif.rst);
      @(posedge vif.clk);
      begin
        jamlink_item_h.card_sel = vif.card_sel  ;
        jamlink_monitor_main_ap.write(jamlink_item_h);
        `uvm_info(get_type_name(), $sformatf(""), UVM_MEDIUM)
      end
    end
    end
endtask

task jamlink_monitor::collect_coverage();
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
`ifdef USE_JAMLINK_DRV


task jamlink_monitor::mid_tran_adapter();
    begin
    	forever begin
      	//wait(vif.wait_flag === 1'b1);
        #1ns;
        @(posedge vif.psel);
        @(negedge vif.clk); 
        if (vif.pwrite==1'b1 && vif.penable==1'b0 ) begin //write
          @(negedge vif.clk);    
            if (vif.penable==1'b1)begin
              jamlink_item_adapter.addr = vif.paddr;
              jamlink_item_adapter.we 	= 1'b1;
              jamlink_item_adapter.data 	= vif.pwdata;
              `ifdef JLM_DATA_DEBUG         
                  $display("-------------------------------------------------------");
                  $display("JLM BEGIN PRIDICT MIDCLK:");
                  $display("now time :",$time);
                  $display("jamlink_sequence_item.addr= %h",jamlink_item_adapter.addr);
                  $display("jamlink_sequence_item.we= %h",jamlink_item_adapter.we);
                  $display("jamlink_sequence_item.data= %h",jamlink_item_adapter.data);
                  $display("-------------------------------------------------------");
              `endif        
              jamlink_monitor_adapter_ap.write(jamlink_item_adapter);
            end
      	end
        else if (vif.pwrite==1'b0 && vif.penable==1'b0) begin  //read
          @(negedge vif.clk);    
            if (vif.penable==1'b1)begin
              jamlink_item_adapter.addr = vif.paddr;
              jamlink_item_adapter.we 	= 1'b0;
              jamlink_item_adapter.data 	= vif.prdata;
              `ifdef JLM_DATA_DEBUG         
                  $display("-------------------------------------------------------");
                  $display("JLM BEGIN PRIDICT MIDCLK:");
                  $display("now time :",$time);
                  $display("jamlink_sequence_item.addr= %h",jamlink_item_adapter.addr);
                  $display("jamlink_sequence_item.we= %h",jamlink_item_adapter.we);
                  $display("jamlink_sequence_item.data= %h",jamlink_item_adapter.data);
                  $display("-------------------------------------------------------");
              `endif        
              jamlink_monitor_adapter_ap.write(jamlink_item_adapter);
            end
        end
    	end
    end
endtask


task jamlink_monitor::xclk_tran_adapter();
    begin
    	forever begin
      	//wait(vif.wait_flag === 1'b1);
        #1ns;
        @(posedge vif.xclk_psel);
        @(negedge vif.xclk); 
        if (vif.xclk_pwrite==1'b1 && vif.xclk_penable==1'b0 ) begin //write
          @(negedge vif.xclk);    
            if (vif.xclk_penable==1'b1)begin
              jamlink_item_adapter.addr = vif.paddr;
              jamlink_item_adapter.we 	= 1'b1;
              jamlink_item_adapter.data 	= vif.pwdata;
              `ifdef JLM_DATA_DEBUG       
                  $display("-------------------------------------------------------");
                  $display("JLM BEGIN PRIDICT XCLK:");
                  $display("now time :",$time);
                  $display("jamlink_sequence_item.addr= %h",jamlink_item_adapter.addr);
                  $display("jamlink_sequence_item.we= %h",jamlink_item_adapter.we);
                  $display("jamlink_sequence_item.data= %h",jamlink_item_adapter.data);
                  $display("-------------------------------------------------------");
              `endif
              jamlink_monitor_adapter_ap.write(jamlink_item_adapter);
            end
      	end
        else if (vif.xclk_pwrite==1'b0 && vif.xclk_penable==1'b0) begin  //read
          @(negedge vif.xclk);    
            if (vif.xclk_penable==1'b1)begin
              jamlink_item_adapter.addr = vif.paddr;
              jamlink_item_adapter.we 	= 1'b0;
              jamlink_item_adapter.data 	= vif.xclk_prdata;
              `ifdef JLM_DATA_DEBUG      
                  $display("-------------------------------------------------------");
                  $display("JLM BEGIN PRIDICT XCLK:");
                  $display("now time :",$time);
                  $display("jamlink_sequence_item.addr= %h",jamlink_item_adapter.addr);
                  $display("jamlink_sequence_item.we= %h",jamlink_item_adapter.we);
                  $display("jamlink_sequence_item.data= %h",jamlink_item_adapter.data);
                  $display("-------------------------------------------------------");
              `endif        
              jamlink_monitor_adapter_ap.write(jamlink_item_adapter);
            end
        end
    	end
    end
endtask


`endif
`endif

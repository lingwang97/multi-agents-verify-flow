class efuse_driver extends uvm_driver#(efuse_sequence_item);

  uvm_analysis_port #(efuse_sequence_item) ap;

  `uvm_component_utils(efuse_driver);

  virtual efuse_if vif;
  efuse_base_cfg m_cfg;  
  
  function new(string name="efuse_driver" , uvm_component parent=null);
    super.new(name , parent);
    ap = new("ap", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual efuse_if)::get(this , "" , "efuse_vif" ,vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")

    if (!uvm_config_db #(efuse_base_cfg)::get(this, "", "efuse_config", m_cfg) )
      `uvm_info("CONFIG_LOAD", "Cannot get configuration efuse_config from uvm_config_db. Have you set it?", UVM_MEDIUM)
  endfunction
  
  task main_phase(uvm_phase phase);
    bit [31:0] data;
    forever
    begin
      wait(~vif.pin_ri);
      reset_signals();
      seq_item_port.get_next_item(req);
      $cast(rsp,req.clone());
      rsp.set_id_info(req);
      do_drive();
      seq_item_port.item_done(rsp);
    end
  endtask
  

  task do_drive();
      `uvm_info(get_full_name(), "Entering efuse apb drive... " , UVM_MEDIUM)
      @(posedge vif.xclk_gated);
        vif.psel      <= 'h1; 
        vif.pwrite    <= req.we;
        if(req.we==1'b1) vif.pwdata    <= req.data;
        vif.paddr     <= req.addr;
      @(posedge vif.xclk_gated);   
        vif.penable   <= 'h1;
        @(negedge vif.xclk_gated);
        if(req.we==1'b0)    req.data <= vif.prdata;
      @(posedge vif.xclk_gated);

          vif.psel      <= 'h0;
          vif.pwrite    <= 'h0;
          vif.penable   <= 'h0;
          vif.paddr     <= 'h0;
          vif.pwdata    <= 'h0;
          vif.prdata    <= 'h0;

      `uvm_info(get_full_name(), "Exiting efuse apb drive... ", UVM_MEDIUM)
  
  endtask

  task reset_signals();
    vif.card_sel  <= 'h0;
    vif.psel      <= 'h0;
    vif.pwrite    <= 'h0;
    vif.penable   <= 'h0;
    vif.paddr     <= 'h0;
    vif.pwdata    <= 'h0;
    vif.prdata    <= 'h0;
  endtask
  
endclass

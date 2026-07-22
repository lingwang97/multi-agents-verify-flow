class cpft_driver extends uvm_driver#(cpft_sequence_item);

  uvm_analysis_port #(cpft_sequence_item) ap;

  `uvm_component_utils(cpft_driver);

  virtual cpft_if vif;
  cpft_base_cfg m_cfg;  
  
  function new(string name="cpft_driver" , uvm_component parent=null);
    super.new(name , parent);
    ap = new("ap", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual cpft_if)::get(this , "" , "cpft_vif" ,vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")

    if (!uvm_config_db #(cpft_base_cfg)::get(this, "", "cpft_config", m_cfg) )
      `uvm_info("CONFIG_LOAD", "Cannot get configuration cpft_config from uvm_config_db. Have you set it?", UVM_MEDIUM)
  endfunction
  
  task main_phase(uvm_phase phase);
    bit [31:0] data;
    forever
    begin
      wait(~vif.rst);
      reset_signals();
      seq_item_port.get_next_item(req);
      $cast(rsp,req.clone());
      rsp.set_id_info(req);
      do_drive();
      seq_item_port.item_done(rsp);
    end
  endtask
  

  task do_drive();
      `uvm_info(get_full_name(), "Entering ... " , UVM_FULL)
      @(posedge vif.clk);
      vif.card_sel  <= req.card_sel;
      `uvm_info(get_full_name(), "Exiting ... ", UVM_FULL)
  
  endtask

  task reset_signals();
    vif.card_sel  <= 'h0;
  endtask
  
endclass

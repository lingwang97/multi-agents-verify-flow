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

    if (!uvm_config_db #(efuse_base_cfg)::get(this, "", "efuse_cfg", m_cfg) )
      `uvm_info("CONFIG_LOAD", "Cannot get configuration efuse_cfg from uvm_config_db. Have you set it?", UVM_MEDIUM)
  endfunction
  
  task main_phase(uvm_phase phase);
    
    forever begin
      wait(~vif.rst);   //could be updated
      reset_signals();
      seq_item_port.get_next_item(req);
      $cast(rsp,req.clone());
      rsp.set_id_info(req);
      do_drive(req, rsp);
      seq_item_port.item_done(rsp);
    end
  endtask
  
  virtual task do_drive(efuse_sequence_item req, efuse_sequence_item rsp);

    `uvm_info(get_full_name(), "Driving transaction in efuse_driver...", UVM_MEDIUM)
    // begin your drv logic here.

    @(posedge vif.clk);
    vif.card_sel  <= req.card_sel;

  endtask

  virtual task reset_signals();
    vif.card_sel  <= 'h0;
  endtask
  
endclass

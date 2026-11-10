class apb_master_driver extends uvm_driver#(apb_master_sequence_item);

  uvm_analysis_port #(apb_master_sequence_item) ap;

  `uvm_component_utils(apb_master_driver);

  virtual apb_master_if vif;
  apb_master_base_cfg m_cfg;
  
  function new(string name="apb_master_driver" , uvm_component parent=null);
    super.new(name , parent);
    ap = new("ap", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_master_if)::get(this , "" , "apb_master_vif" ,vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")

    if (!uvm_config_db #(apb_master_base_cfg)::get(this, "", "apb_master_cfg", m_cfg) )
      `uvm_info("CONFIG_LOAD", "Cannot get configuration apb_master_cfg from uvm_config_db. Have you set it?", UVM_MEDIUM)
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
  
  virtual task do_drive(apb_master_sequence_item req, apb_master_sequence_item rsp);

    `uvm_info(get_full_name(), "Driving transaction in apb_master_driver...", UVM_MEDIUM)
    // APB v3 master FSM, driven/sampled on negedge: the DUT updates PRDATA/PSLVERR
    // with blocking assigns inside its posedge ACCESS evaluation.

    // IDLE cycle: guarantees the DUT >=1 full idle posedge between transfers
    @(negedge vif.clk);
    vif.psel <= 1'b0;
    vif.penable <= 1'b0;

    // SETUP phase
    @(negedge vif.clk);
    vif.psel <= 1'b1;
    vif.pwrite <= req.we;
    vif.paddr <= req.addr;
    vif.pwdata <= req.data;
    vif.penable <= 1'b0;

    // ACCESS phase
    @(negedge vif.clk);
    vif.penable <= 1'b1;
    // sample PREADY only while in ACCESS (DUT asserts it early in SETUP when wait is off)
    forever begin
      @(negedge vif.clk);
      if (vif.pready === 1'b1) break;
    end
    rsp.prdata = vif.prdata;
    rsp.pslverr = vif.pslverr;
    vif.penable <= 1'b0;

  endtask

  virtual task reset_signals();
    vif.psel <= 1'b0;
    vif.penable <= 1'b0;
    vif.pwrite <= 1'b0;
    vif.paddr <= 'h0;
    vif.pwdata <= 'h0;
    vif.card_sel <= 'h0;
  endtask
  
endclass

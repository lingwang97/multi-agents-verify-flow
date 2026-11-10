`uvm_analysis_imp_decl(_main_apb_master_monitor)
class apb_master_scoreboard extends base_scoreboard;

  `uvm_component_utils(apb_master_scoreboard);

  virtual apb_master_if apb_master_vif;

  apb_master_item apb_master_item_h;
  apb_master_base_cfg m_cfg;

  uvm_analysis_imp_main_apb_master_monitor #(apb_master_item, apb_master_scoreboard) apb_master_scoreboard_main_ap;

  // shadow reference model of the DUT memory (apb_v3_sram)
  bit [31:0] shadow_mem [int unsigned];
  bit [31:0] prdata_shadow;   // value PRDATA holds after the last in-range read
  bit        model_valid;
  int unsigned mem_size;
  int unsigned n_checked;

  function new(string name="apb_master_scoreboard" , uvm_component parent=null);
    super.new(name , parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_master_scoreboard_main_ap = new("apb_master_scoreboard_main_ap",this);
    apb_master_item_h = apb_master_item::type_id::create("apb_master_item_h",this);
    if (!uvm_config_db #(virtual interface apb_master_if)::get(this, "", "apb_master_vif", apb_master_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
    if (!uvm_config_db #(apb_master_base_cfg)::get(this, "", "apb_master_cfg", m_cfg))
      `uvm_info("CONFIG_LOAD", "Cannot get configuration apb_master_cfg from uvm_config_db. Have you set it?", UVM_MEDIUM)
    mem_size = (m_cfg != null) ? m_cfg.mem_size : 64;
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  virtual task main_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("apb_master_scoreboard begin check"), UVM_MEDIUM)
    if(checks_enable) `uvm_info(get_type_name(), $sformatf("begin to do scoreboard check"), UVM_MEDIUM)
    else `uvm_info(get_type_name(), $sformatf("stop to do scoreboard check"), UVM_MEDIUM)

  endtask:main_phase

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), $sformatf("apb_master_scoreboard checked %0d transfers", n_checked), UVM_LOW)
  endfunction

  // shadow model semantics (apb_v3_sram):
  //  - reset fills every entry with RESET_VAL(0), PRDATA=0
  //  - in-range write updates memory[addr]; in-range read returns memory[addr]
  //  - out-of-range write has no effect; out-of-range read raises PSLVERR and
  //    leaves PRDATA stale (equal to the value after the last in-range read)
  virtual function void write_main_apb_master_monitor(apb_master_item req);
    if (!model_valid) begin
      for (int unsigned i = 0; i < mem_size; i++) shadow_mem[i] = 'h0; // RESET_VAL
      prdata_shadow = 'h0;
      model_valid = 1;
    end
    n_checked++;

    if (req.we) begin
      if (req.addr < mem_size) begin
        shadow_mem[req.addr] = req.wdata;
      end
      // out-of-range write: predicted no memory effect (nothing to check here;
      // the effect is proven by the subsequent in-range re-read in the seq)
      `uvm_info(get_type_name(), $sformatf("WR addr=0x%08h data=0x%08h pslverr=%0b", req.addr, req.wdata, req.pslverr), UVM_HIGH)
    end
    else begin
      if (req.addr < mem_size) begin
        if (req.rdata !== shadow_mem[req.addr])
          `uvm_error(get_full_name(), $sformatf("READ data mismatch: addr=0x%08h got=0x%08h exp=0x%08h", req.addr, req.rdata, shadow_mem[req.addr]))
        if (req.pslverr !== 1'b0)
          `uvm_error(get_full_name(), $sformatf("unexpected PSLVERR on in-range read: addr=0x%08h", req.addr))
        prdata_shadow = req.rdata;
      end
      else begin
        if (req.pslverr !== 1'b1)
          `uvm_error(get_full_name(), $sformatf("missing PSLVERR on out-of-range read: addr=0x%08h", req.addr))
        if (req.rdata !== prdata_shadow)
          `uvm_error(get_full_name(), $sformatf("PRDATA not stale on out-of-range read: addr=0x%08h got=0x%08h exp=0x%08h", req.addr, req.rdata, prdata_shadow))
      end
      `uvm_info(get_type_name(), $sformatf("RD addr=0x%08h data=0x%08h pslverr=%0b", req.addr, req.rdata, req.pslverr), UVM_HIGH)
    end
  endfunction

endclass

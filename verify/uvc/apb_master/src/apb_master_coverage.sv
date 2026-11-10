class apb_master_coverage extends uvm_subscriber #(apb_master_coverage_item);

  `uvm_component_utils(apb_master_coverage)

  uvm_analysis_imp #(apb_master_coverage_item, apb_master_coverage) mon2cov;

  virtual apb_master_if apb_master_vif;
  apb_master_coverage_item req_h;

  string report_id = "apb_master_coverage";

  // NOTE: covergroup-based functional coverage is collected by the VCS golden
  // flow only; Verilator parses covergroups but does not sample them.
  // [METHOD_A] Sample monitor data by TLM
  covergroup cg_apb_transfer;
    option.per_instance = 1;

    cp_addr : coverpoint req_h.addr {
      bins addr_0        = {0};
      bins addr_low      = {[1:15]};
      bins addr_mid      = {[16:47]};
      bins addr_high     = {[48:62]};
      bins addr_63       = {63};
      bins addr_err_64   = {[64:127]};
      bins addr_err_high = {[128:$]};
    }

    cp_we : coverpoint req_h.we {
      bins read  = {0};
      bins write = {1};
    }

    cp_pslverr : coverpoint req_h.pslverr {
      bins ok    = {0};
      bins error = {1};
    }

    cp_wait : coverpoint req_h.wait_cycles {
      bins wait_0    = {0};
      bins wait_1    = {1};
      bins wait_many = {[2:15]};
    }

    addr_x_we : cross cp_addr, cp_we;
  endgroup

  covergroup cg_data;
    option.per_instance = 1;

    cp_wdata : coverpoint req_h.wdata {
      bins zeros   = {0};
      bins ones    = {32'hFFFF_FFFF};
      bins others  = default;
    }

    cp_rdata : coverpoint req_h.rdata {
      bins zeros   = {0};
      bins ones    = {32'hFFFF_FFFF};
      bins others  = default;
    }
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    mon2cov = new("mon2cov",this);
    cg_apb_transfer = new();
    cg_data = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    req_h = apb_master_coverage_item::type_id::create("req_h",this);
    if(!uvm_config_db#(virtual apb_master_if)::get(this , "" , "apb_master_vif" ,apb_master_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction

  function void write(apb_master_coverage_item t);
    req_h = t;
    cg_apb_transfer.sample();
    cg_data.sample();
  endfunction

endclass

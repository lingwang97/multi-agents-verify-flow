class apb_master_monitor extends base_monitor;

  uvm_analysis_port #(apb_master_item) apb_master_monitor_main_ap;
  uvm_analysis_port #(apb_master_coverage_item) frame_collected_port;

  `uvm_component_utils(apb_master_monitor);

  virtual apb_master_if apb_master_vif;

  // phase tags for the negedge transfer reconstructor
  localparam int MON_PH_IDLE   = 0;
  localparam int MON_PH_SETUP  = 1;
  localparam int MON_PH_ACCESS = 2;

  extern task monitor_trans();
`ifdef OPEN_EDA
  extern function void print_monitor_status();   // oEDA: explicit return type
`else
  extern function print_monitor_status();
`endif
  function new(string name="apb_master_monitor" , uvm_component parent=null);
    super.new(name , parent);
    apb_master_monitor_main_ap = new("apb_master_monitor_main_ap", this);
    frame_collected_port = new("frame_collected_port",this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_master_if)::get(this , "" , "apb_master_vif" ,apb_master_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")

  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    print_monitor_status();
    fork
      monitor_trans();
    join_none
  endtask


endclass : apb_master_monitor

  // Reconstruct APB transfers on negedge (the DUT updates PRDATA/PSLVERR with
  // blocking assigns inside its posedge ACCESS evaluation, so posedge sampling
  // would race). The DUT asserts PREADY one phase early in SETUP when wait
  // states are disabled, and it lags one phase after each transfer - both are
  // tolerated here and must not be flagged.
  task apb_master_monitor::monitor_trans();
    apb_master_item tr;
    apb_master_coverage_item ctr;
    bit [31:0] setup_addr;
    bit [31:0] setup_wdata;
    bit        setup_we;
    bit        setup_valid;
    int unsigned wait_cnt;
    int unsigned idle_cnt;
    int prev_ph;

    forever begin
      @(negedge apb_master_vif.clk);
      if (apb_master_vif.rst) begin
        setup_valid = 0;
        wait_cnt = 0;
        idle_cnt = 0;
        prev_ph = MON_PH_IDLE;
        continue;
      end

      if (!apb_master_vif.psel && !apb_master_vif.penable) begin
        // IDLE phase
        idle_cnt++;
        setup_valid = 0;
        wait_cnt = 0;
        if (checks_enable && idle_cnt >= 2) begin
          if (apb_master_vif.pready !== 1'b0)
            `uvm_error(get_full_name(), $sformatf("PREADY not low in IDLE phase (t=%0t)", $time))
          if (apb_master_vif.pslverr !== 1'b0)
            `uvm_error(get_full_name(), $sformatf("PSLVERR not low in IDLE phase (t=%0t)", $time))
        end
        prev_ph = MON_PH_IDLE;
      end
      else if (!apb_master_vif.penable) begin
        // SETUP phase (psel=1, penable=0)
        idle_cnt = 0;
        if (checks_enable && setup_valid)
          `uvm_error(get_full_name(), $sformatf("new SETUP phase before previous transfer completed (t=%0t)", $time))
        setup_valid = 1;
        setup_addr = apb_master_vif.paddr;
        setup_wdata = apb_master_vif.pwdata;
        setup_we = apb_master_vif.pwrite;
        wait_cnt = 0;
        // PSLVERR is allowed to linger one cycle right after an error transfer
        // (DUT phase lag), so only check it when this SETUP follows an IDLE gap
        if (checks_enable && prev_ph == MON_PH_IDLE && apb_master_vif.pslverr !== 1'b0)
          `uvm_error(get_full_name(), $sformatf("PSLVERR asserted in SETUP phase (t=%0t)", $time))
        prev_ph = MON_PH_SETUP;
      end
      else begin
        // ACCESS phase (psel=1, penable=1)
        idle_cnt = 0;
        if (checks_enable && !setup_valid)
          `uvm_error(get_full_name(), $sformatf("PENABLE asserted without preceding SETUP phase (t=%0t)", $time))
        if (checks_enable) begin
          if (apb_master_vif.paddr !== setup_addr || apb_master_vif.pwrite !== setup_we || apb_master_vif.pwdata !== setup_wdata)
            `uvm_error(get_full_name(), $sformatf("PADDR/PWRITE/PWDATA changed during ACCESS phase (t=%0t)", $time))
          if (apb_master_vif.pslverr !== 1'b0 && apb_master_vif.pready !== 1'b1)
            `uvm_error(get_full_name(), $sformatf("PSLVERR asserted before PREADY in ACCESS phase (t=%0t)", $time))
          if (apb_master_vif.pready !== 1'b0 && apb_master_vif.pready !== 1'b1)
            `uvm_error(get_full_name(), $sformatf("PREADY is not binary in ACCESS phase (t=%0t)", $time))
        end

        if (apb_master_vif.pready === 1'b1) begin
          // transfer completed: publish to scoreboard and (gated) to coverage
          tr = apb_master_item::type_id::create("apb_master_tr");
          tr.addr = setup_addr;
          tr.wdata = setup_wdata;
          tr.we = setup_we;
          tr.rdata = apb_master_vif.prdata;
          tr.pslverr = apb_master_vif.pslverr;
          tr.wait_cycles = wait_cnt;
          apb_master_monitor_main_ap.write(tr);
          if (cov_enable) begin
            ctr = apb_master_coverage_item::type_id::create("apb_master_ctr");
            ctr.addr = setup_addr;
            ctr.wdata = setup_wdata;
            ctr.we = setup_we;
            ctr.rdata = apb_master_vif.prdata;
            ctr.pslverr = apb_master_vif.pslverr;
            ctr.wait_cycles = wait_cnt;
            frame_collected_port.write(ctr);
          end
          setup_valid = 0;
          wait_cnt = 0;
        end
        else begin
          wait_cnt++;
        end
        prev_ph = MON_PH_ACCESS;
      end
    end
  endtask

  // Print monitor status of cov_enable & checks_enable
`ifdef OPEN_EDA
  function void apb_master_monitor::print_monitor_status();
`else
  function apb_master_monitor::print_monitor_status();
`endif
		`uvm_info(get_type_name(), $sformatf("apb_master_monitor status as following:"), UVM_MEDIUM)
		if(checks_enable)begin
			`uvm_info(get_type_name(), $sformatf("apb_master_monitor check switch ON"), UVM_MEDIUM)
		end
		else begin
			`uvm_info(get_type_name(), $sformatf("apb_master_monitor check switch OFF"), UVM_MEDIUM)
		end
		if(cov_enable)begin
			`uvm_info(get_type_name(), $sformatf("apb_master_monitor collect coverages switch ON"), UVM_MEDIUM)
		end
		else begin
			`uvm_info(get_type_name(), $sformatf("apb_master_monitor collect coverages switch OFF"), UVM_MEDIUM)
		end
  endfunction

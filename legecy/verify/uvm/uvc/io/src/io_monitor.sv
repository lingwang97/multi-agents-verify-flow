
class io_monitor extends base_monitor;

  uvm_analysis_port #(io_item) io_monitor_main_ap;
  uvm_analysis_port #(io_coverage_item) frame_collected_port;

  `uvm_component_utils(io_monitor);

  io_coverage_item req;
  io_item io_item_h;
  io_base_cfg   io_cfg_h;

  logic [`CHIP_NUM-1 : 0] sel_v;
  logic [`CHIP_NUM-1 : 0] dsel_v;
  logic [`CHIP_NUM-1 : 0] fbdi_v;
  logic [`CHIP_NUM-1 : 0] fbdo_v;
  logic [`CHIP_NUM-1 : 0] cki_v;
  logic [`CHIP_NUM-1 : 0] cko_v;
  logic [`CHIP_NUM-1 : 0] ci_v;
  logic [`CHIP_NUM-1 : 0] co_v;
  logic [`CHIP_NUM-1 : 0] ri_v;
  logic [`CHIP_NUM-1 : 0] ro_v;
  logic [`CHIP_NUM-1 : 0] di_v;
  logic [`CHIP_NUM-1 : 0] do_v;

  virtual io_if vif;
  
  extern task main_traffic();
  extern task collect_coverage();
  extern task tpsel_check();

  function new(string name="io_monitor" , uvm_component parent=null);
    super.new(name , parent);
    io_monitor_main_ap = new("io_monitor_main_ap",this);
    frame_collected_port = new("frame_collected_port",this);
  endfunction
 
   function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual io_if)::get(this , "" , "io_vif" ,vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")

    if (!uvm_config_db #(io_pkg::io_base_cfg)::get(this, "", "io_cfg", io_cfg_h))
      `uvm_error("TOP_ENV:ERROR", "Env top_env is missing from config_db")

    req = io_coverage_item::type_id::create("req",this);
    io_item_h = io_item::type_id::create("io_item_h",this);
      
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    fork
      main_traffic();
      collect_coverage();
      `ifndef USE_UART_DRV
      tpsel_check();
      `endif
    join_none
  endtask  

  virtual task main_phase(uvm_phase phase);
    `ifndef PL_SIM
        `ifndef USE_UART_DRV
            `ifndef IO_MONITOR_CHK_OFF
                chk_always_io_value();
                check_do_toggle_in_negedge_co();
                `ifndef FPGA_SYN
                    chk_always_sel1_z_state();
                `endif
                `ifdef FUNC_IO_FB_SEL
                    chk_always_fb();
                `endif                
            `endif
        `endif
    `endif
  endtask

  task check_do_toggle_in_negedge_co;
      real delay_period;
      realtime co_neg, do_toggle;
  
      fork
        forever begin
          if(vif.DSEL_n) begin
           @(vif.RI_DO_n);
             do_toggle = $realtime;
             @(negedge vif.CKI_CO_n_dly);
             co_neg = $realtime;
             delay_period = co_neg - do_toggle;
             if(delay_period > 0.2)
             `uvm_error(get_type_name() ,$sformatf("delay_period = %f, co_neg = %f, do_toggle = %f", delay_period, co_neg, do_toggle));  
          end else begin
           @(vif.DO_RI_s);
             do_toggle = $realtime;
             @(negedge vif.CO_CKI_s_dly);
             co_neg = $realtime;
             delay_period = co_neg - do_toggle;
             if(delay_period > 0.2)
             `uvm_error(get_type_name() ,$sformatf("delay_period = %f, co_neg = %f, do_toggle = %f", delay_period, co_neg, do_toggle));  
             end
        end
      join_none
  endtask

  virtual task chk_always_io_value();
    fork
        forever begin
            chk_io_value();
            #1ns;
        end
    join_none
  endtask

  task chk_io_value();
      for(int j = 0; j < `CHIP_NUM; j=j+1) begin
          if((vif.DSEL[j] == 0) && (vif.SEL[j] == 0)) begin
              if(vif.CO_CKI[j] !== ~vif.CI_CKO[j]) begin
                #1ns;
                if(vif.CO_CKI[j] !== ~vif.CI_CKO[j])
                    `uvm_error(get_type_name(), $psprintf("j = %0d, vif.CO_CKI[j] is %0d, vif.CI_CKO[j] is %0d.", j, vif.CO_CKI[j], vif.CI_CKO[j]));
              end
          end
      end  
      for(int m = 0; m < `CHIP_NUM; m=m+1) begin
          if((vif.DSEL[m] == 1) && (vif.SEL[m] == 0)) begin
              if(vif.CKI_CO[m] !== ~vif.CKO_CI[m]) begin
                #1ns;
                if(vif.CKI_CO[m] !== ~vif.CKO_CI[m])
                    `uvm_error(get_type_name(), $psprintf("m = %0d, vif.CKI_CO[m] is %0d, vif.CKO_CI[m] is %0d.", m, vif.CKI_CO[m], vif.CKO_CI[m]));
              end
          end
      end 
      for(int n = 0; n < `CHIP_NUM; n=n+1) begin
          if((vif.DSEL[n] == 0) && (vif.SEL[n] == 0)) begin
              if(vif.RO_DI[n] !== vif.RI_DO[n]) begin
                #1ns;
                if(vif.RO_DI[n] !== vif.RI_DO[n])
                    `uvm_error(get_type_name(), $psprintf("n = %0d, vif.RO_DI[n] is %0d, vif.RI_DO[n] is %0d.", n, vif.RO_DI[n], vif.RI_DO[n]));
              end
          end
      end
      for(int p = 0; p < `CHIP_NUM; p=p+1) begin
          if((vif.DSEL[p] == 1) && (vif.SEL[p] == 0)) begin
              if(vif.DI_RO[p] !== vif.DO_RI[p]) begin
                #1ns;
                if(vif.DI_RO[p] !== vif.DO_RI[p]) 
                    `uvm_error(get_type_name(), $psprintf("p = %0d, vif.DI_RO[p] is %0d, vif.DO_RI[p] is %0d.", p, vif.DI_RO[p], vif.DO_RI[p]));
              end      
          end
      end        
  endtask

  virtual task chk_always_sel1_z_state();
      fork
        begin
            forever begin
                for(int i = 0; i < `CHIP_NUM; i=i+1) begin
                @(negedge vif.CKO_CI[i]);
                    if((vif.SEL[i] == 1) && (vif.DSEL[i] == 0)) begin
                        if(vif.CKO_CI[i] !== 1'bz) `uvm_error(get_type_name(), $psprintf("i = %0d, vif.CKO_CI[i] is %0d.", i, vif.CKO_CI[i]));
                    end
                end
            end
        end
        begin
            forever begin
                for(int i = 0; i < `CHIP_NUM; i=i+1) begin
                @(negedge vif.CO_CKI[i]);
                    if((vif.SEL[i] == 1) && (vif.DSEL[i] == 0)) begin
                        if(vif.CO_CKI[i] !== 1'bz) `uvm_error(get_type_name(), $psprintf("i = %0d, vif.CO_CKI[i] is %0d.", i, vif.CO_CKI[i]));
                    end        
                end
            end
        end
        begin
            forever begin
                for(int i = 0; i < `CHIP_NUM; i=i+1) begin
                @(negedge vif.RO_DI[i]);
                    if((vif.SEL[i] == 1) && (vif.DSEL[i] == 0)) begin
                        if(vif.RO_DI[i] !== 1'bz) `uvm_error(get_type_name(), $psprintf("i = %0d, vif.RO_DI[i] is %0d.", i, vif.RO_DI[i]));
                    end        
                end
            end
        end
        begin
            forever begin
                for(int i = 0; i < `CHIP_NUM; i=i+1) begin
                @(negedge vif.DO_RI[i]);
                    if((vif.SEL[i] == 1) && (vif.DSEL[i] == 0)) begin
                        if(vif.DO_RI[i] !== 1'bz) `uvm_error(get_type_name(), $psprintf("i = %0d, vif.DO_RI[i] is %0d.", i, vif.DO_RI[i]));
                    end        
                end
            end
        end
        begin
            forever begin
                for(int i = 0; i < `CHIP_NUM; i=i+1) begin
                @(negedge vif.CKI_CO[i]);
                    if((vif.SEL[i] == 1) && (vif.DSEL[i] == 1)) begin
                        if(vif.CKI_CO[i] !== 1'bz) `uvm_error(get_type_name(), $psprintf("i = %0d, vif.CKI_CO[i] is %0d.", i, vif.CKI_CO[i]));
                    end        
                end
            end
        end
        begin
            forever begin
                for(int i = 0; i < `CHIP_NUM; i=i+1) begin
                @(negedge vif.CI_CKO[i]);
                    if((vif.SEL[i] == 1) && (vif.DSEL[i] == 1)) begin
                        if(vif.CI_CKO[i] !== 1'bz) `uvm_error(get_type_name(), $psprintf("i = %0d, vif.CI_CKO[i] is %0d.", i, vif.CI_CKO[i]));
                    end        
                end
            end
        end
        begin
            forever begin
                for(int i = 0; i < `CHIP_NUM; i=i+1) begin
                @(negedge vif.RI_DO[i]);
                    if((vif.SEL[i] == 1) && (vif.DSEL[i] == 1)) begin
                        if(vif.RI_DO[i] !== 1'bz) `uvm_error(get_type_name(), $psprintf("i = %0d, vif.RI_DO[i] is %0d.", i, vif.RI_DO[i]));
                    end        
                end
            end
        end
        begin
            forever begin
                for(int i = 0; i < `CHIP_NUM; i=i+1) begin
                @(negedge vif.DI_RO[i]);
                    if((vif.SEL[i] == 1) && (vif.DSEL[i] == 1)) begin
                        if(vif.DI_RO[i] !== 1'bz) `uvm_error(get_type_name(), $psprintf("i = %0d, vif.DI_RO[i] is %0d.", i, vif.DI_RO[i]));
                    end  
                end
            end
        end
      join_none
  endtask  

  task chk_always_fb();
    fork
        forever begin
            chk_fb();
            #1ns;
        end
    join_none  
  endtask

  task chk_fb();
      for(int i = 0; i < `CHIP_NUM; i=i+1) begin
        if(vif.chips_io_fb_sel[i] == 1) begin
            if(vif.DSEL[i] == 0) begin
                if(((vif.FBDO_FBDI[i] !== vif.DO_RI[i]) && (vif.DO_RI[i] !== 1'bz)) || ((vif.DO_RI[i] === 1'bz) && (vif.FBDO_FBDI[i] !== 1'b0)))begin
                    #1ns;
                    if(((vif.FBDO_FBDI[i] !== vif.DO_RI[i]) && (vif.DO_RI[i] !== 1'bz)) || ((vif.DO_RI[i] === 1'bz) && (vif.FBDO_FBDI[i] !== 1'b0))) `uvm_error(get_type_name(), $psprintf("i = %0d, vif.FBDO_FBDI[i] is %0d, vif.DO_RI[i] is %0d.", i, vif.FBDO_FBDI[i], vif.DO_RI[i]));
                end
            end
            if(vif.DSEL[i] == 1) begin
                if(((vif.FBDI_FBDO[i] !== vif.RI_DO[i]) && (vif.RI_DO[i] !== 1'bz)) || ((vif.RI_DO[i] === 1'bz) && (vif.FBDI_FBDO[i] !== 1'b0)))begin
                    #1ns;
                    if(((vif.FBDI_FBDO[i] !== vif.RI_DO[i]) && (vif.RI_DO[i] !== 1'bz)) || ((vif.RI_DO[i] === 1'bz) && (vif.FBDI_FBDO[i] !== 1'b0))) `uvm_error(get_type_name(), $psprintf("i = %0d, vif.FBDI_FBDO[i] is %0d, vif.RI_DO[i] is %0d.", i, vif.FBDI_FBDO[i], vif.RI_DO[i]));
                end
            end
        end 
        else 
        if(vif.chips_io_fb_sel[i] == 0) begin
            `ifndef FPGA_SYN
            if(vif.DSEL[i] == 0) begin
                if(vif.FBDO_FBDI[i] !== vif.FBDI_FBDO[i])  `uvm_error(get_type_name(), $psprintf("i = %0d, vif.FBDO_FBDI[i] is %0d, vif.FBDI_FBDO[i] is %0d.", i, vif.FBDO_FBDI[i], vif.FBDI_FBDO[i]));
            end
            if(vif.DSEL[i] == 1) begin
                if(vif.FBDI_FBDO[i] !== vif.FBDO_FBDI[i])  `uvm_error(get_type_name(), $psprintf("i = %0d, vif.FBDI_FBDO[i] is %0d, vif.FBDO_FBDI[i] is %0d.", i, vif.FBDI_FBDO[i], vif.FBDO_FBDI[i]));
            end        
            `endif
        end
      end   
  endtask

endclass

task io_monitor::main_traffic();
    begin
    forever
    begin
      wait(~vif.rst);
      @(posedge vif.clk);
      begin
        io_item_h.card_sel = vif.card_sel  ;
        io_monitor_main_ap.write(io_item_h);
      end
    end
    end
endtask

task io_monitor::collect_coverage();
    begin 
    forever
    begin
    @(posedge vif.clk);
    req.card_sel  = vif.card_sel  ;
    req.io_ctrl1 = io_cfg_h.io_ctrl1;
    req.io_ctrl2 = io_cfg_h.io_ctrl2;

    frame_collected_port.write(req);   
    end
    end
endtask

task io_monitor::tpsel_check();
    begin
        @(posedge vif.clk);
        foreach(vif.TPSEL_n[i]) begin
            if(vif.TPSEL_n[i])
                $fatal("TPSEL can't be 1 unless in uart mode.");
        end
    end
endtask

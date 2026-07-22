`ifndef __BASE_TEST__
`define __BASE_TEST__

import "DPI-C" function int wallclock();

class base_test extends uvm_test;


    int unsigned start_time_int;
    int unsigned end_time_int;
    string start_time_str;
    string end_time_str;
    int read_value;

    //handle virtual if
    virtual interface top_if top_vif;
    virtual interface ro_if ro_vif;
    virtual interface mx2_if mx2_vif;
    virtual interface ft_if ft_vif;
    virtual interface spd_if spd_vif;
    `ifdef VIP
    virtual interface svt_uart_if dte_vif;
    `endif    
    virtual interface uart_if uart_vif;
    virtual interface jls_if jls_vif;
    virtual interface jamlink_if jamlink_vif;
    virtual interface io_if io_vif;
    virtual interface efuse_if efuse_vif;
    virtual interface cpft_if cpft_vif;
    virtual interface dfx_if dfx_vif;
    virtual interface mc_if mc_vif;
    virtual interface cpm_if cpm_vif;
    virtual interface pvt_if pvt_vif;
    virtual interface rst_if rst_vif;
    virtual interface rst_assertion_if rst_assertion_vif;
    virtual interface work_ctrl_if work_ctrl_vif;
    virtual interface reg_if reg_vif;
    virtual interface selfclk_if selfclk_vif;



    //config
    mx2_pkg::mx2_base_config       mx2_cfg_h;
    ro_pkg::ro_base_cfg   ro_cfg_h;
    jls_pkg::jls_base_cfg   jls_cfg_h;
    jamlink_pkg::jamlink_base_cfg   jamlink_cfg_h;
    `ifdef VIP
    uart_vip_pkg::cust_svt_uart_agent_configuration   dte_cfg;
    `endif    
    io_pkg::io_base_cfg   io_cfg_h;
    efuse_pkg::efuse_base_cfg   efuse_cfg_h;
    dfx_pkg::dfx_base_cfg   dfx_cfg_h;
    cpft_pkg::cpft_base_cfg   cpft_cfg_h;
    spd_pkg::spd_base_cfg   spd_cfg_h;
    ft_pkg::ft_base_cfg   ft_cfg_h;
    reg_pkg::reg_base_cfg   reg_cfg_h;    
    mc_pkg::mc_base_cfg   mc_cfg_h;
    cpm_pkg::cpm_base_cfg   cpm_cfg_h;
    pvt_pkg::pvt_base_cfg   pvt_cfg_h;
    rst_pkg::rst_base_cfg   rst_cfg_h;
    work_ctrl_pkg::work_ctrl_base_cfg   work_ctrl_cfg_h;
    selfclk_pkg::selfclk_base_cfg   selfclk_cfg_h;    
    uart_pkg::uart_base_cfg   uart_cfg_h;
    
    top_virtual_sequencer  vseqr_h;

    // handle to test environment
    top_env top_env_h;


    //users' tasks and functions
    extern function void print_project();

    extern virtual function void set_enable(input string   array_name,
                                            input string   index_name,
                                            input on_off_t enable,
                                            input string event_bind="DEFAULT");
    extern virtual function void set_mon_checks_enable(input string   name,
                                      		       input on_off_t enable,
                                                       input string   event_bind="DEFAULT");
    extern virtual function void set_sb_checks_enable(input string   name,
                                    	              input on_off_t enable,
                                                      input string   event_bind="DEFAULT");
    extern virtual function void set_if_checks_enable(input string   name,
                                                      input on_off_t enable,
                                                      input string   event_bind="DEFAULT");
    extern virtual function void set_mon_cov_enable(input string   name,
                                                    input on_off_t enable,
                                                    input string   event_bind="DEFAULT");
    extern virtual function void set_if_cov_enable(input string   name,
                                                   input on_off_t enable,
                                                   input string   event_bind="DEFAULT");

    extern virtual function void ro_cfg_randomize();
    extern virtual function void mx2_cfg_randomize();
    extern virtual function void mc_cfg_randomize();
    extern virtual function void cpm_cfg_randomize();
    extern virtual function void pvt_cfg_randomize();
    extern virtual function void selfclk_cfg_randomize();
    extern virtual function void work_ctrl_cfg_randomize();
    extern virtual function void set_selfclk_cfg_type(input string selfclk_cfg_override, bit replace=1);
    extern virtual function void set_pvt_cfg_type(input string pvt_cfg_override, bit replace = 1);
    extern virtual function void set_cpm_cfg_type(input string cpm_cfg_override, bit replace = 1);
    extern virtual function void set_ro_cfg_type(input string ro_cfg_override, bit replace = 1);
    extern virtual function void set_spd_cfg_type(input string spd_cfg_override, bit replace = 1);
    extern virtual function void spd_cfg_randomize();
    extern virtual function void set_ft_cfg_type(input string ft_cfg_override, bit replace = 1);
    extern virtual function void ft_cfg_randomize();
    extern virtual function void set_mc_cfg_type(input string mc_cfg_override, bit replace = 1);
    extern virtual function void io_cfg_randomize();
    extern virtual function void set_io_cfg_type(input string io_cfg_override, bit replace = 1);
    extern virtual function void efuse_cfg_randomize();
    extern virtual function void set_efuse_cfg_type(input string efuse_cfg_override, bit replace = 1);
    extern virtual function void reg_cfg_randomize();
    extern virtual function void set_reg_cfg_type(input string reg_cfg_override, bit replace = 1);
    extern virtual function void dfx_cfg_randomize();
    extern virtual function void set_dfx_cfg_type(input string dfx_cfg_override, bit replace = 1);
    extern virtual function void jamlink_cfg_randomize();
    extern virtual function void set_jamlink_cfg_type(input string jamlink_cfg_override, bit replace = 1);
    extern virtual function void uart_cfg_randomize();
    extern virtual function void set_uart_cfg_type(input string uart_cfg_override, bit replace = 1);
    `ifdef VIP
    extern virtual function void dte_cfg_randomize();
    `endif 
    extern virtual function void jls_cfg_randomize();
    extern virtual function void set_jls_cfg_type(input string jls_cfg_override, bit replace = 1);
    extern virtual function void cpft_cfg_randomize();
    extern virtual function void set_cpft_cfg_type(input string cpft_cfg_override, bit replace = 1);
    extern virtual function void rst_cfg_randomize();
    extern virtual function void set_rst_cfg_type(input string rst_cfg_override, bit replace = 1);

    extern task force_cpm_clks();
    extern task release_cpm_clks();
    extern task force_release_spd_lfb();
    extern task force_multi_chips_shaping();


    // automation macro
    `uvm_component_utils_begin(base_test)
    `uvm_component_utils_end


    // constructor
    function new(string name = "base_test",uvm_component parent);
        super.new(name,parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        // create the tb
        `uvm_info(get_type_name (),"****** Creating top_env class ******",UVM_LOW);
        top_env_h = top_env::type_id::create("top_env_h", this);

        // enable transaction recording for everything
        `uvm_info(get_type_name (),"****** Creating All base_cfg class ******",UVM_LOW);
        uvm_config_db#(int)::set(this, "*", "recording_detail" , UVM_FULL);
        ro_cfg_h = ro_pkg::ro_base_cfg::type_id::create("ro_cfg_h", this);
        mx2_cfg_h = mx2_pkg::mx2_base_config::type_id::create("mx2_cfg_h", this);
        cpm_cfg_h = cpm_pkg::cpm_base_cfg::type_id::create("cpm_cfg_h", this);
        pvt_cfg_h = pvt_pkg::pvt_base_cfg::type_id::create("pvt_cfg_h", this);
        rst_cfg_h = rst_pkg::rst_base_cfg::type_id::create("rst_cfg_h", this);
        mc_cfg_h = mc_pkg::mc_base_cfg::type_id::create("mc_cfg_h", this);
        io_cfg_h = io_pkg::io_base_cfg::type_id::create("io_cfg_h", this);
        dfx_cfg_h = dfx_pkg::dfx_base_cfg::type_id::create("dfx_cfg_h", this);
        jls_cfg_h = jls_pkg::jls_base_cfg::type_id::create("jls_cfg_h", this);
        jamlink_cfg_h = jamlink_pkg::jamlink_base_cfg::type_id::create("jamlink_cfg_h", this);
        `ifdef VIP
        dte_cfg = uart_vip_pkg::cust_svt_uart_agent_configuration::type_id::create("dte_cfg", this);
        `endif
        uart_cfg_h = uart_pkg::uart_base_cfg::type_id::create("uart_cfg_h", this);
        efuse_cfg_h = efuse_pkg::efuse_base_cfg::type_id::create("efuse_cfg_h", this);
        cpft_cfg_h = cpft_pkg::cpft_base_cfg::type_id::create("cpft_cfg_h", this);
        spd_cfg_h = spd_pkg::spd_base_cfg::type_id::create("spd_cfg_h", this);
        ft_cfg_h = ft_pkg::ft_base_cfg::type_id::create("ft_cfg_h", this);
        reg_cfg_h = reg_pkg::reg_base_cfg::type_id::create("reg_cfg_h", this);
        selfclk_cfg_h = selfclk_pkg::selfclk_base_cfg::type_id::create("selfclk_cfg_h", this);
        work_ctrl_cfg_h = work_ctrl_pkg::work_ctrl_base_cfg::type_id::create("work_ctrl_cfg_h", this);

        `uvm_info(get_type_name (),"****** Setting All base_cfg class ******",UVM_LOW);
        uvm_config_db#(logic  )::set(this, "*", "check_input_enable", 1);
        uvm_config_db#(logic  )::set(this, "*", "check_pad_enable", 1);
        uvm_config_db #(ro_pkg::ro_base_cfg)::set(uvm_root::get(),"*", "ro_cfg", ro_cfg_h);
        uvm_config_db #(cpm_pkg::cpm_base_cfg)::set(uvm_root::get(),"*", "cpm_cfg", cpm_cfg_h);
        $display("base_testdebug",cpm_cfg_h);
        uvm_config_db #(pvt_pkg::pvt_base_cfg)::set(uvm_root::get(),"*", "pvt_cfg", pvt_cfg_h);
        uvm_config_db #(mx2_pkg::mx2_base_config)::set(uvm_root::get(),"*", "mx2_cfg", mx2_cfg_h);
        uvm_config_db #(rst_pkg::rst_base_cfg)::set(uvm_root::get(),"*", "rst_cfg", rst_cfg_h);
        uvm_config_db #(mc_pkg::mc_base_cfg)::set(uvm_root::get(),"*", "mc_cfg", mc_cfg_h);
        uvm_config_db #(io_pkg::io_base_cfg)::set(uvm_root::get(),"*", "io_cfg", io_cfg_h);
        uvm_config_db #(dfx_pkg::dfx_base_cfg)::set(uvm_root::get(),"*", "dfx_cfg", dfx_cfg_h);
        uvm_config_db #(cpft_pkg::cpft_base_cfg)::set(uvm_root::get(),"*", "cpft_cfg", cpft_cfg_h);
        uvm_config_db #(jamlink_pkg::jamlink_base_cfg)::set(uvm_root::get(),"*", "jamlink_cfg", jamlink_cfg_h);
        `ifdef VIP
          uvm_config_db#(cust_svt_uart_agent_configuration)::set(uvm_root::get(),"uvm_test_top.top_env_h.uart_vip_env_h", "dte_cfg", dte_cfg);
          `uvm_info("build_phase",$sformatf("***************base_test.sv Agent Configuration For DTE**************\n%0s",
            				this.dte_cfg.sprint()), UVM_LOW);
        `endif
        uvm_config_db #(uart_pkg::uart_base_cfg)::set(uvm_root::get(),"*", "uart_cfg", uart_cfg_h);
        uvm_config_db #(jls_pkg::jls_base_cfg)::set(uvm_root::get(),"*", "jls_cfg", jls_cfg_h);
        uvm_config_db #(efuse_pkg::efuse_base_cfg)::set(uvm_root::get(),"*", "efuse_cfg", efuse_cfg_h);
        uvm_config_db #(spd_pkg::spd_base_cfg)::set(uvm_root::get(),"*", "spd_cfg", spd_cfg_h);
        uvm_config_db #(ft_pkg::ft_base_cfg)::set(uvm_root::get(),"*", "ft_cfg", ft_cfg_h);
        uvm_config_db #(reg_pkg::reg_base_cfg)::set(uvm_root::get(),"*", "reg_cfg", reg_cfg_h);
        uvm_config_db #(selfclk_pkg::selfclk_base_cfg)::set(uvm_root::get(),"*", "selfclk_cfg", selfclk_cfg_h);
        uvm_config_db #(work_ctrl_pkg::work_ctrl_base_cfg)::set(uvm_root::get(),"*", "work_ctrl_cfg", work_ctrl_cfg_h);
        uvm_config_db #(top_env)::set(uvm_root::get(),"*", "top_env", top_env_h);

        `uvm_info(get_type_name (),"****** Getting All the virtual interface ******",UVM_LOW);
        if (!uvm_config_db #(virtual interface ro_if)::get(this, "", "ro_vif", ro_vif))
          `uvm_error("GPIO_VIF:ERROR", "Agent ro_vif is missing from config_db")
        if (!uvm_config_db #(virtual interface mx2_if)::get(this, "", "mx2_vif", mx2_vif))
          `uvm_error("GPIO_VIF:ERROR", "Agent mx2_vif is missing from config_db")

        if (!uvm_config_db #(virtual interface spd_if)::get(this, "", "spd_vif", spd_vif))
          `uvm_error("GPIO_VIF:ERROR", "Agent spd_vif is missing from config_db")

        if (!uvm_config_db #(virtual interface ft_if)::get(this, "", "ft_vif", ft_vif))
          `uvm_error("GPIO_VIF:ERROR", "Agent ft_vif is missing from config_db")

        if (!uvm_config_db #(virtual interface mc_if)::get(this, "", "mc_vif", mc_vif))
          `uvm_error("GPIO_VIF:ERROR", "Agent mc_vif is missing from config_db")

        if (!uvm_config_db #(virtual interface cpm_if)::get(this, "", "cpm_vif", cpm_vif))
          `uvm_error("GPIO_VIF:ERROR", "Agent cpm_vif is missing from config_db")

        if (!uvm_config_db #(virtual interface pvt_if)::get(this, "", "pvt_vif", pvt_vif))
          `uvm_error("GPIO_VIF:ERROR", "Agent pvt_vif is missing from config_db")

        if (!uvm_config_db #(virtual interface rst_if)::get(this, "", "rst_vif", rst_vif))
          `uvm_error("GPIO_VIF:ERROR", "Agent rst_vif is missing from config_db")

        if (!uvm_config_db #(virtual interface rst_assertion_if)::get(this, "", "rst_assertion_vif", rst_assertion_vif))
          `uvm_error("GPIO_VIF:ERROR", "Agent rst_assertion_vif is missing from config_db")

        if (!uvm_config_db #(virtual interface work_ctrl_if)::get(this, "", "work_ctrl_vif", work_ctrl_vif))
          `uvm_error("GPIO_VIF:ERROR", "Agent work_ctrl_vif if is missing from config_db")

        if (!uvm_config_db #(virtual interface top_if)::get(this, "", "top_vif", top_vif))
          `uvm_error("GPIO_VIF:ERROR", "Agent top_vif is missing from config_db")

        if (!uvm_config_db #(virtual interface io_if)::get(this, "", "io_vif", io_vif))
          `uvm_error("GPIO_VIF:ERROR", "Agent io_vif is missing from config_db")
        if (!uvm_config_db #(virtual interface jls_if)::get(this, "", "jls_vif", jls_vif))

          `uvm_error("GPIO_VIF:ERROR", "Agent jls_vif is missing from config_db")
        if (!uvm_config_db #(virtual interface jamlink_if)::get(this, "", "jamlink_vif", jamlink_vif))
          `uvm_error("GPIO_VIF:ERROR", "Agent jamlink_vif is missing from config_db")

        `ifdef VIP
        if (!uvm_config_db #(virtual interface svt_uart_if)::get(this, "", "dte_vif", dte_vif))
          `uvm_error("GPIO_VIF:ERROR", "Agent svt_uart_vif is missing from config_db")
        `endif

        if (!uvm_config_db #(virtual interface uart_if)::get(this, "", "uart_vif", uart_vif))
          `uvm_error("GPIO_VIF:ERROR", "Agent uart_vif is missing from config_db")
        if (!uvm_config_db #(virtual interface dfx_if)::get(this, "", "dfx_vif", dfx_vif))
          `uvm_error("GPIO_VIF:ERROR", "Agent dfx_vif is missing from config_db")
        if (!uvm_config_db #(virtual interface cpft_if)::get(this, "", "cpft_vif", cpft_vif))
          `uvm_error("GPIO_VIF:ERROR", "Agent cpft_vif is missing from config_db")
        if (!uvm_config_db #(virtual interface efuse_if)::get(this, "", "efuse_vif", efuse_vif))
          `uvm_error("GPIO_VIF:ERROR", "Agent efuse_vif is missing from config_db")
        if (!uvm_config_db #(virtual interface reg_if)::get(this, "", "reg_vif", reg_vif))
          `uvm_error("GPIO_VIF:ERROR", "Agent reg_vif is missing from config_db")
        if (!uvm_config_db #(virtual interface selfclk_if)::get(this, "", "selfclk_vif", selfclk_vif))
          `uvm_error("GPIO_VIF:ERROR", "Agent selfclk_vif is missing from config_db")

        start_time_int = wallclock();

    endfunction : build_phase


    virtual function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

    endfunction : connect_phase





    // Function: end_of_elaboration_phase
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        // Prints the topology.
        uvm_top.print_topology();  
        vseqr_h = top_env_h.vseqr_h;

    endfunction: end_of_elaboration_phase


    //
    // Function: start_of_simulation_phase
    //
    // Set the sequences to run and override the transaction types.
    virtual function void start_of_simulation_phase(uvm_phase phase);
      //set the starting sequence to system
      
      super.start_of_simulation_phase(phase);

      ro_cfg_randomize();
      cpm_cfg_randomize();
      selfclk_cfg_randomize();
      pvt_cfg_randomize();
      rst_cfg_randomize();
      mc_cfg_randomize();
      io_cfg_randomize();
      dfx_cfg_randomize();
      cpft_cfg_randomize();
      jls_cfg_randomize();
      jamlink_cfg_randomize();
     `ifdef VIP
      //uart_cfg_randomize();
      `endif

      efuse_cfg_randomize();
      spd_cfg_randomize();
      ft_cfg_randomize();
      reg_cfg_randomize();
      work_ctrl_cfg_randomize();
      uart_cfg_randomize();

    endfunction: start_of_simulation_phase

    virtual task pre_reset_phase(uvm_phase phase);
      super.pre_reset_phase(phase);
      begin
        random_core_no_por_seq seq;
        phase.raise_objection(this);
        if($test$plusargs("NO_CORE_POR"))begin
          seq = random_core_no_por_seq::type_id::create("random_core_no_por_seq");
          seq.start(vseqr_h); 
        end
        phase.drop_objection(this);
      end
    endtask

    virtual task reset_phase(uvm_phase phase);
      super.reset_phase(phase);
      begin
        phase.raise_objection(this);
        print_project();
            `ifndef PL_SIM
        uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.crg.clk_ctrl_icg_sync.level_syncer_delay_max[31:0]",41);
        uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.crg.u_crg_rst.mx2_sft_rst_sync.level_syncer_delay_max[31:0]",33);
      `endif
        uvm_hdl_deposit("tb_top.RO",1);
        `uvm_info(get_type_name(),"trigger pad ri",UVM_MEDIUM);
        phase.drop_objection(this);
      end
    endtask

    virtual task pre_configure_phase(uvm_phase phase);
         super.pre_configure_phase(phase);
         begin
         phase.raise_objection(this);
         `uvm_info(get_type_name(),"pre_configure_phase started",UVM_MEDIUM);      
    
    
         force_multi_chips_shaping();  //only used in mc case ,could move to mc_base_test 
    
    
         `uvm_info(get_type_name(),"pre_configure_phase finished",UVM_MEDIUM);      
         phase.drop_objection(this);
         end
    endtask
    
    
    virtual task configure_phase(uvm_phase phase);
        
        super.configure_phase(phase);
        begin
        init_normal_seq init_seq;
        uart_init_seq   uart_seq;
        jamlink_init_seq   jlm_init_seq;
        phase.raise_objection(this);
    
        `ifndef PL_SIM
        force_release_spd_lfb();
        `endif
    
        `ifdef USE_UART_DRV
        uart_seq = uart_init_seq::type_id::create("uart_seq");
    
        `ifdef VIP
        uart_seq.start(vseqr_h.uart_vip_seqr_h);
        `else
        uart_seq.start(vseqr_h.uart_seqr_h);
        `endif
        
        //uart_seq.start(top_env_h.uart_env_h.uart_agent_h.m_sequencer);
         `elsif USE_JAMLINK_DRV
        jlm_init_seq = jamlink_init_seq::type_id::create("jlm_init_seq");
        jlm_init_seq.start(vseqr_h.jamlink_seqr_h);
        `endif
    
        `ifndef NO_INIT
          `ifdef REAL_CORE
            `ifndef STUB_PLL
                force_cpm_clks();
            `endif
          `endif
              fork
              begin
                init_seq = init_normal_seq::type_id::create("init_seq");
                init_seq.start(vseqr_h);
              end
        
          `ifdef REAL_CORE
            `ifndef STUB_PLL
              begin
                @(posedge work_ctrl_vif.REG_Cfg_SpdGo);
                release_cpm_clks();
        
              end
            `endif
          `endif
              join
        `endif
    
          phase.drop_objection(this);
        end
    
    endtask
    
    virtual task post_configure_phase(uvm_phase phase);
        super.post_configure_phase(phase);
        begin
          phase.raise_objection(this);
          `ifndef FT_CM
          uvm_hdl_deposit("tb_top.RO",0);
          `endif
          `uvm_info(get_type_name(),"release pad ri",UVM_MEDIUM);
          #1000ns;
          phase.drop_objection(this);
        end
    endtask
    
    
    virtual task main_phase(uvm_phase phase);
        
        super.main_phase(phase);
        begin
          phase.raise_objection(this);
    
          phase.drop_objection(this);
        end
    
    endtask
    
    
    virtual task post_main_phase(uvm_phase phase);
        
        super.post_main_phase(phase);
        begin
        exit_check_seq exit_seq;
        phase.raise_objection(this);
        exit_seq = exit_check_seq::type_id::create("exit_seq");
        exit_seq.start(vseqr_h);
        phase.drop_objection(this);
        end
    
    endtask



    virtual task run_phase(uvm_phase phase);

        super.run_phase(phase);

    	phase.raise_objection(this);

	///////////////////////////////////////////////////
	// NOTE: this VCS_PLUSARGS_OPT is sim speed-up for bug-hunting,
	// will impact mx2/cpm/xx... , not use as an option in case regression.
	//////////////////////////////////////////////////
	if($test$plusargs("FORCE_CPM_CLK")) begin 
        force_cpm_clks(); 
        end

    	phase.drop_objection(this);

    endtask




    virtual function void report_phase( uvm_phase phase );
        super.report_phase(phase);
        end_time_int = wallclock();
        $display(">>>>>>>>>>>>>>>>>>>>>>>> %s Runned %d Hours<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<",get_type_name(), end_time_int-start_time_int);
    endfunction : report_phase


endclass : base_test



// ********************************************
// *******function and task defination: *******
// ********************************************
function void base_test::print_project();
    integer fp;
    integer code;
    string v_name;
    string project_name;
    $display("*************************************************************");
    $display("**                    Project Checking                     **");
    $display("*************************************************************");
    fp = $fopen("project_name", "r");
    if(fp == 'h0) begin
        $display("Error, Can not open project_name!");
        $finish;
    end
    else begin
        code = $fgets( v_name, fp );
        //$display("code is %d,v_name is %s",code,v_name);
        project_name = v_name.substr(0, v_name.len() - 2);
        $display("    |-Chip is %s", project_name);
        $fclose(fp);
    end
endfunction

task base_test::force_cpm_clks();

  	for(int i=0;i<`CHIP_NUM;i++)begin
    		uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.crg.clk_ctrl",i), 1'b1);
    		uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.crg.trunk_clk",i), {`PLL_NUM{1'b1}});
  	end
   	`uvm_info(get_type_name(), $sformatf("[Force Signals] \n\n\t*******************************\n\tforce cpm.clk_comm/cpm.trunk_clk for speed-up !!! \n\t*******************************\n\n"), UVM_MEDIUM)
endtask

task base_test::release_cpm_clks();
        for(int i=0;i<`CHIP_NUM;i++)begin
                uvm_hdl_release($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.crg.clk_ctrl",i));
                uvm_hdl_release($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.crg.trunk_clk",i));
        end
   	`uvm_info(get_type_name(), $sformatf("[Release Signals] \n\n\t-----------------------------\n\tRelease cpm.clk_comm/cpm.trunk_clk for speed-up !!! \n\t-------------------------------\n\n"), UVM_MEDIUM)
endtask



task base_test::force_release_spd_lfb();

        $display($realtime, "------------->Begin Force State");
        for(int unsigned i=0; i<`DESIGN_CORE_NUM; i++)begin
            uvm_hdl_force($psprintf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_adaptive.ss_cur_state[3:0]", i), $urandom_range(0,16));
        end
        uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.lfb_top.lfb_state_cur[2:0]", $urandom_range(0,9));
        #200ns;
        /*for(int unsigned i=0; i<`DESIGN_CORE_NUM; i++)begin
            uvm_hdl_force($psprintf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_adaptive.ss_cur_state[3:0]", i), 0);
        end
        uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.lfb_top.lfb_state_cur[2:0]", 0);
        #200ns;*/
        for(int unsigned i=0; i<`DESIGN_CORE_NUM; i++)begin
            uvm_hdl_release($psprintf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_adaptive.ss_cur_state[3:0]", i));
        end
        uvm_hdl_release("tb_top.C[0].btnode.btc.sys_ctrl.speed.lfb_top.lfb_state_cur[2:0]");

endtask




task base_test::force_multi_chips_shaping();

    `ifdef UART__XCLK_FIRST_CHIP_SHAPING_MODE1
                uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.comm_interface.REG_UART_XCLK_DO_SHAPING_MODE", 2'b1);
                uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.comm_interface.REG_UART_XCLK_FB_SHAPING_MODE", 2'b1);
    `endif
    
    `ifdef UART_SHAPING5
                for(int i = 0; i < `CHIP_NUM; i = i + 1) begin
                    if((i % 5) == 0) begin
                        uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.REG_UART_XCLK_DO_SHAPING_EN",i), 1'b1);
                        uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.REG_UART_XCLK_FB_SHAPING_EN",i), 1'b1);
                    end
                end
    `endif
    
    `ifdef UART_PLL_SHAPING12_MODE1
                for(int i = 0; i < `CHIP_NUM; i = i + 1) begin
                    uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.REG_UART_PLL_MODE",i), 1'b1);
                    uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.uart_top.REG_UART_PLL_MODE_p",i), 1'b1);
                end
                for(int i = 1; i < `CHIP_NUM; i = i + 1) begin
                    if((i % 12) == 0) begin
                        uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.REG_UART_PLL_DO_SHAPING_EN",i), 1'b1);
                        uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.REG_UART_PLL_FB_SHAPING_EN",i), 1'b1);
                        uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.uart_top.REG_UART_PLL_DO_SHAPING_EN_p",i), 1'b1);
                        uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.uart_top.REG_UART_PLL_FB_SHAPING_EN_p",i), 1'b1);
                        uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.REG_UART_PLL_DO_SHAPING_MODE",i), 1'b1);
                        uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.REG_UART_PLL_FB_SHAPING_MODE",i), 1'b1);
                        uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.uart_top.REG_UART_PLL_DO_SHAPING_MODE_p",i), 1'b1);
                        uvm_hdl_force($sformatf("tb_top.C[%0d].btnode.btc.sys_ctrl.comm_interface.uart_top.REG_UART_PLL_FB_SHAPING_MODE_p",i), 1'b1);
                    end
                end
    `endif    
    #100ns;
endtask




function void base_test::set_enable(input string   array_name,
                         input string   index_name,
                         input on_off_t enable,
                         input string event_bind="DEFAULT");

   string   name;   

    if(event_bind == "DEFAULT")begin
       case (array_name)
         "MON_CHECKS_ENABLE":
           if ( MON_CHECKS_ENABLE.exists(index_name) ) begin
              MON_CHECKS_ENABLE[index_name] = (enable==ON);
              `uvm_info(report_id,$sformatf("Setting MON_CHECKS_ENABLE[%s] = %b\n",
                                            index_name, MON_CHECKS_ENABLE[index_name]),UVM_MEDIUM)
           end else begin
              //List valid names 
              `uvm_info(report_id,"List of legal assoc array strings:",UVM_LOW);
              if ( MON_CHECKS_ENABLE.first(name) ) begin
                 do begin
                    `uvm_info(report_id,$sformatf("    MON_CHECKS_ENABLE[%s]",name),UVM_LOW)
                 end
                 while (MON_CHECKS_ENABLE.next(name));
              end
           end // else: !if( MON_CHECKS_ENABLE.exists(index_name) )
         "SB_CHECKS_ENABLE":
           if ( SB_CHECKS_ENABLE.exists(index_name) ) begin
              SB_CHECKS_ENABLE[index_name] = (enable==ON);
              `uvm_info(report_id,$sformatf("Setting SB_CHECKS_ENABLE[%s] = %b\n",
                                            index_name, SB_CHECKS_ENABLE[index_name]),UVM_MEDIUM)
           end else begin
              //List valid names 
              `uvm_info(report_id,"List of legal assoc array strings:",UVM_LOW);
              if ( SB_CHECKS_ENABLE.first(name) ) begin
                 do begin
                    `uvm_info(report_id,$sformatf("    SB_CHECKS_ENABLE[%s]",name),UVM_LOW)
                 end
                 while (SB_CHECKS_ENABLE.next(name));
              end
           end // else: !if( SB_CHECKS_ENABLE.exists(index_name) ) 
         "MON_COVERAGE_ENABLE":
           if ( MON_COVERAGE_ENABLE.exists(index_name) ) begin
              MON_COVERAGE_ENABLE[index_name] = (enable==ON);
              `uvm_info(report_id,$sformatf("Setting MON_COVERAGE_ENABLE[%s] = %b\n",
                                            index_name, MON_COVERAGE_ENABLE[index_name]),UVM_MEDIUM)
           end else begin
              //List valid names 
              `uvm_info(report_id,"List of legal assoc array strings:",UVM_LOW);
              if ( MON_COVERAGE_ENABLE.first(name) ) begin
                 do begin
                    `uvm_info(report_id,$sformatf("    MON_COVERAGE_ENABLE[%s]",name),UVM_LOW)
                 end
                 while (MON_COVERAGE_ENABLE.next(name));
              end
           end // else: !if( MON_COVERAGE_ENABLE.exists(index_name) )
         
         "IF_CHECKS_ENABLE":
           if ( IF_CHECKS_ENABLE.exists(index_name) ) begin
              IF_CHECKS_ENABLE[index_name] = (enable==ON);
              `uvm_info(report_id,$sformatf("Setting IF_CHECKS_ENABLE[%s] = %b\n",
                                            index_name, IF_CHECKS_ENABLE[index_name]),UVM_MEDIUM)
           end else begin
              //List valid names 
                `uvm_info(report_id,"List of legal assoc array strings:",UVM_LOW);
              if ( IF_CHECKS_ENABLE.first(name) ) begin
                 do begin
                    `uvm_info(report_id,$sformatf("    IF_CHECKS_ENABLE[%s]",name),UVM_LOW)
                 end
                 while (IF_CHECKS_ENABLE.next(name));
              end
           end // else: !if( IF_CHECKS_ENABLE.exists(index_name) )
         
         "IF_COVERAGE_ENABLE":
           if ( IF_COVERAGE_ENABLE.exists(index_name) ) begin
              IF_COVERAGE_ENABLE[index_name] = (enable==ON);
              `uvm_info(report_id,$sformatf("Setting IF_COVERAGE_ENABLE[%s] = %b\n",
                                            index_name, IF_COVERAGE_ENABLE[index_name]),UVM_MEDIUM)
           end else begin
              //List valid names 
              `uvm_info(report_id,"List of legal assoc array strings:",UVM_LOW);
              if ( IF_COVERAGE_ENABLE.first(name) ) begin
                 do begin
                    `uvm_info(report_id,$sformatf("    IF_COVERAGE_ENABLE[%s]",name),UVM_LOW)
                 end
                 while (IF_COVERAGE_ENABLE.next(name));
              end
           end // else: !if( IF_COVERAGE_ENABLE.exists(index_name) )
         
       endcase // (array_name)
       
    end // if (event_bind == "DEFAULT")
endfunction: set_enable

function void base_test::set_mon_checks_enable(input string   name,
                                      input on_off_t enable,
                                      input string   event_bind="DEFAULT");

      `uvm_info(get_full_name(),$psprintf("setting mon check for %s",name),UVM_LOW)
      set_enable(.array_name("MON_CHECKS_ENABLE"),
                 .index_name(name),
                 .enable(enable),
                 .event_bind(event_bind)
                 );
endfunction: set_mon_checks_enable    

function void base_test::set_sb_checks_enable(input string   name,
                                    input on_off_t enable,
                                    input string   event_bind="DEFAULT");

    `uvm_info(get_full_name(),$psprintf("setting sb check for %s",name),UVM_LOW)
    set_enable(.array_name("SB_CHECKS_ENABLE"),
               .index_name(name),
               .enable(enable),
               .event_bind(event_bind)
               );
endfunction: set_sb_checks_enable

function void base_test::set_if_checks_enable(input string   name,
                                    input on_off_t enable,
                                    input string   event_bind="DEFAULT");

    `uvm_info(get_full_name(),$psprintf("setting if check for %s",name),UVM_LOW)
    set_enable(.array_name("IF_CHECKS_ENABLE"),
               .index_name(name),
               .enable(enable),
               .event_bind(event_bind)
               );
endfunction: set_if_checks_enable

function void base_test::set_mon_cov_enable(input string   name,
                                    input on_off_t enable,
                                    input string   event_bind="DEFAULT");

    `uvm_info(get_full_name(),$psprintf("setting mon cov for %s",name),UVM_LOW)
    set_enable(.array_name("MON_COV_ENABLE"),
               .index_name(name),
               .enable(enable),
               .event_bind(event_bind)
               );
endfunction: set_mon_cov_enable

function void base_test::set_if_cov_enable(input string   name,
                                    input on_off_t enable,
                                    input string   event_bind="DEFAULT");

    `uvm_info(get_full_name(),$psprintf("setting if cov for %s",name),UVM_LOW)
    set_enable(.array_name("IF_COV_ENABLE"),
               .index_name(name),
               .enable(enable),
               .event_bind(event_bind)
               );
endfunction: set_if_cov_enable    


// cfg_randomiz
function void base_test::ro_cfg_randomize();
            if (ro_cfg_h.randomize()
               ) `uvm_info(get_type_name (),ro_cfg_h.sprint(),UVM_MEDIUM)
            else `uvm_fatal(get_type_name (),$sformatf("ro_cfg_h randomization failed"))
endfunction : ro_cfg_randomize
function void base_test::mx2_cfg_randomize();
            if (mx2_cfg_h.randomize()
               ) `uvm_info(get_type_name (),mx2_cfg_h.sprint(),UVM_MEDIUM)
            else `uvm_fatal(get_type_name (),$sformatf("mx2_cfg_h randomization failed"))
endfunction : mx2_cfg_randomize

function void base_test::mc_cfg_randomize();
            if (mc_cfg_h.randomize()
               ) `uvm_info(get_type_name (),mc_cfg_h.sprint(),UVM_MEDIUM)
            else `uvm_fatal(get_type_name (),$sformatf("mc_cfg_h randomization failed"))
endfunction : mc_cfg_randomize

function void base_test::cpm_cfg_randomize();
            if (cpm_cfg_h.randomize()
               ) `uvm_info(get_type_name (),cpm_cfg_h.sprint(),UVM_MEDIUM)
            else `uvm_fatal(get_type_name (),$sformatf("cpm_cfg_h randomization failed"))
endfunction : cpm_cfg_randomize

function void base_test::pvt_cfg_randomize();
            if (pvt_cfg_h.randomize()
               ) `uvm_info(get_type_name (),pvt_cfg_h.sprint(),UVM_MEDIUM)
            else `uvm_fatal(get_type_name (),$sformatf("pvt_cfg_h randomization failed"))
endfunction : pvt_cfg_randomize

function void base_test::selfclk_cfg_randomize();
  if (selfclk_cfg_h.randomize())
    `uvm_info(get_type_name(), selfclk_cfg_h.sprint(),UVM_MEDIUM)
  else
    `uvm_fatal(get_type_name(), $sformatf("selfclk_cfg_h randomization failed"))
endfunction : selfclk_cfg_randomize

function void base_test::work_ctrl_cfg_randomize();
  if (work_ctrl_cfg_h.randomize())
    `uvm_info(get_type_name(), work_ctrl_cfg_h.sprint(),UVM_MEDIUM)
  else
    `uvm_fatal(get_type_name(), $sformatf("work_ctrl_cfg_h randomization failed"))
endfunction : work_ctrl_cfg_randomize

function void base_test::set_selfclk_cfg_type(input string selfclk_cfg_override, bit replace=1);
            set_type_override("selfclk_base_cfg", selfclk_cfg_override, replace);
endfunction

function void base_test::set_pvt_cfg_type(input string pvt_cfg_override, bit replace = 1);
            set_type_override("pvt_base_cfg", pvt_cfg_override, replace);
endfunction  

function void base_test::set_cpm_cfg_type(input string cpm_cfg_override, bit replace = 1);
            set_type_override("cpm_base_cfg", cpm_cfg_override, replace);
endfunction 

function void base_test::set_ro_cfg_type(input string ro_cfg_override, bit replace = 1);
            set_type_override("ro_base_cfg", ro_cfg_override, replace);
endfunction 

function void base_test::set_spd_cfg_type(input string spd_cfg_override, bit replace = 1);
            set_type_override("spd_base_cfg", spd_cfg_override, replace);
endfunction 

function void base_test::spd_cfg_randomize();
            if (spd_cfg_h.randomize()
               ) `uvm_info(get_type_name (),spd_cfg_h.sprint(),UVM_MEDIUM)
            else `uvm_fatal(get_type_name (),$sformatf("spd_cfg_h randomization failed"))
endfunction : spd_cfg_randomize

function void base_test::set_ft_cfg_type(input string ft_cfg_override, bit replace = 1);
            set_type_override("ft_base_cfg", ft_cfg_override, replace);
endfunction 

function void base_test::ft_cfg_randomize();
            if (ft_cfg_h.randomize()
               ) `uvm_info(get_type_name (),ft_cfg_h.sprint(),UVM_MEDIUM)
            else `uvm_fatal(get_type_name (),$sformatf("ft_cfg_h randomization failed"))
endfunction : ft_cfg_randomize

function void base_test::set_mc_cfg_type(input string mc_cfg_override, bit replace = 1);
            set_type_override("mc_base_cfg", mc_cfg_override, replace);
endfunction 

function void base_test::io_cfg_randomize();
            if (io_cfg_h.randomize()
               ) `uvm_info(get_type_name (),io_cfg_h.sprint(),UVM_MEDIUM)
            else `uvm_fatal(get_type_name (),$sformatf("io_cfg_h randomization failed"))
endfunction : io_cfg_randomize

function void base_test::set_io_cfg_type(input string io_cfg_override, bit replace = 1);
            set_type_override("io_base_cfg", io_cfg_override, replace);
endfunction  

function void base_test::efuse_cfg_randomize();
            if (efuse_cfg_h.randomize()
               ) `uvm_info(get_type_name (),efuse_cfg_h.sprint(),UVM_MEDIUM)
            else `uvm_fatal(get_type_name (),$sformatf("efuse_cfg_h randomization failed"))
endfunction : efuse_cfg_randomize

function void base_test::set_efuse_cfg_type(input string efuse_cfg_override, bit replace = 1);
            set_type_override("efuse_base_cfg", efuse_cfg_override, replace);
endfunction  

function void base_test::reg_cfg_randomize();
            if (reg_cfg_h.randomize()
               ) `uvm_info(get_type_name (),reg_cfg_h.sprint(),UVM_MEDIUM)
            else `uvm_fatal(get_type_name (),$sformatf("reg_cfg_h randomization failed"))
endfunction : reg_cfg_randomize

function void base_test::set_reg_cfg_type(input string reg_cfg_override, bit replace = 1);
            set_type_override("reg_base_cfg", reg_cfg_override, replace);
endfunction 

function void base_test::dfx_cfg_randomize();
            if (dfx_cfg_h.randomize()
               ) `uvm_info(get_type_name (),dfx_cfg_h.sprint(),UVM_MEDIUM)
            else `uvm_fatal(get_type_name (),$sformatf("dfx_cfg_h randomization failed"))
endfunction : dfx_cfg_randomize

function void base_test::set_dfx_cfg_type(input string dfx_cfg_override, bit replace = 1);
            set_type_override("dfx_base_cfg", dfx_cfg_override, replace);
endfunction  

function void base_test::jamlink_cfg_randomize();
            if (jamlink_cfg_h.randomize()
               ) `uvm_info(get_type_name (),jamlink_cfg_h.sprint(),UVM_MEDIUM)
            else `uvm_fatal(get_type_name (),$sformatf("jamlink_cfg_h randomization failed"))
endfunction : jamlink_cfg_randomize

function void base_test::set_jamlink_cfg_type(input string jamlink_cfg_override, bit replace = 1);
            set_type_override("jamlink_base_cfg", jamlink_cfg_override, replace);
endfunction
  
function void base_test::uart_cfg_randomize();
      bit[9:0] startchipid;
      bit[9:0] startchipid_max;
            if (uart_cfg_h.randomize()
               ) begin 
                 if($value$plusargs("UART_START_ID_MAX=%d", startchipid_max)) uart_cfg_h.chip_start_id_cfg = $urandom_range(0,startchipid_max);
                 else if($value$plusargs("UART_START_ID=%d", startchipid)) uart_cfg_h.chip_start_id_cfg = startchipid;
                 else uart_cfg_h.chip_start_id_cfg = 0;
                 `uvm_info(get_type_name (),uart_cfg_h.sprint(),UVM_MEDIUM)
                 end
            else `uvm_fatal(get_type_name (),$sformatf("uart_cfg_h randomization failed"))
endfunction : uart_cfg_randomize

function void base_test::set_uart_cfg_type(input string uart_cfg_override, bit replace = 1);
            set_type_override("uart_base_cfg", uart_cfg_override, replace);
endfunction 

`ifdef VIP
function void base_test::dte_cfg_randomize();
            if (dte_cfg.randomize()
               ) `uvm_info(get_type_name (),dte_cfg.sprint(),UVM_MEDIUM)
            else `uvm_fatal(get_type_name (),$sformatf("uart_vip dte_cfg randomization failed"))
endfunction : dte_cfg_randomize
`endif

function void base_test::jls_cfg_randomize();
            if (jls_cfg_h.randomize()
               ) `uvm_info(get_type_name (),jls_cfg_h.sprint(),UVM_MEDIUM)
            else `uvm_fatal(get_type_name (),$sformatf("jls_cfg_h randomization failed"))
endfunction : jls_cfg_randomize

function void base_test::set_jls_cfg_type(input string jls_cfg_override, bit replace = 1);
            set_type_override("jls_base_cfg", jls_cfg_override, replace);
endfunction  

function void base_test::cpft_cfg_randomize();
            if (cpft_cfg_h.randomize()
               ) `uvm_info(get_type_name (),cpft_cfg_h.sprint(),UVM_MEDIUM)
            else `uvm_fatal(get_type_name (),$sformatf("cpft_cfg_h randomization failed"))
endfunction : cpft_cfg_randomize

function void base_test::set_cpft_cfg_type(input string cpft_cfg_override, bit replace = 1);
            set_type_override("cpft_base_cfg", cpft_cfg_override, replace);
endfunction  

function void base_test::rst_cfg_randomize();
            if (rst_cfg_h.randomize()
               ) `uvm_info(get_type_name (),rst_cfg_h.sprint(),UVM_MEDIUM)
            else `uvm_fatal(get_type_name (),$sformatf("rst_cfg_h randomization failed"))
endfunction : rst_cfg_randomize

function void base_test::set_rst_cfg_type(input string rst_cfg_override, bit replace = 1);
            set_type_override("rst_base_cfg", rst_cfg_override, replace);
endfunction 


`endif //`ifndef __BASE_TEST__

 
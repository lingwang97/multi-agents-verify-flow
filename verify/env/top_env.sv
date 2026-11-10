`ifndef __TOP_ENV__SVH__
`define __TOP_ENV__SVH__

class top_env extends uvm_env;

    `uvm_component_utils(top_env)
    string      report_id = "top_env";

    // register model object declaration
    RAL_PKG::ral_gen_main 	ral;
    
    // top_virtual_sequencer declaration
    top_virtual_sequencer   vseqr_h;

    // module envs declarations
	reg_env		reg_env_h;
	apb_master_env		apb_master_env_h;
	ro_env		ro_env_h;
	uart_env		uart_env_h;
	efuse_env		efuse_env_h;

    // add reg-model-relative component declaration  



    // add VIP-relative component declaration  


    // new constructor
    function new(string name = "top_env" , uvm_component parent = null);
        super.new(name , parent);
    endfunction

    // build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `ifdef UVM_ERR_QUIT_COUNT
            uvm_report_server::get_server().set_max_quit_count(`UVM_ERR_QUIT_COUNT);
        `endif
        // Create all module envs
		reg_env_h = reg_env::type_id::create("reg_env_h", this);
		apb_master_env_h = apb_master_env::type_id::create("apb_master_env_h", this);
		ro_env_h = ro_env::type_id::create("ro_env_h", this);
		uart_env_h = uart_env::type_id::create("uart_env_h", this);
		efuse_env_h = efuse_env::type_id::create("efuse_env_h", this);
        
        // Setting the active driver
		apb_master_env_h.drv_is_active = UVM_ACTIVE ;
		uart_env_h.drv_is_active = UVM_ACTIVE ;
		efuse_env_h.drv_is_active = UVM_ACTIVE ;

        // Create reg-model related component 



        // Create VIP-relative component  
        

        // build the virtual sequencer
        vseqr_h = top_virtual_sequencer::type_id::create("vseqr_h", this); 

        // Create RAL model and cfg db setting
        ral  = RAL_PKG::ral_gen_main::type_id::create("ral", this);
        ral.configure(null, "");
        ral.build();
        ral.set_coverage(UVM_CVR_ALL);	
        ral.lock_model();
        ral.reset();
        ral.set_hdl_path_root("tb_top.C[0].btnode.btc"); //need to be updated

        uvm_config_db#(RAL_PKG::ral_gen_main)::set(uvm_root::get(), "*", "ral", ral);

    endfunction


    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        vseqr_h.ral = this.ral;
        // connect virtual sequencer to subsequencers
		vseqr_h.reg_seqr_h= reg_env_h.vseqr_h;
		vseqr_h.apb_master_seqr_h= apb_master_env_h.vseqr_h;
		vseqr_h.ro_seqr_h= ro_env_h.vseqr_h;
		vseqr_h.uart_seqr_h= uart_env_h.vseqr_h;
		vseqr_h.efuse_seqr_h= efuse_env_h.vseqr_h;


        // top connect between different module component  



        // ---------------------------------------------
        // RAL MODEL: for top different driver 
        // 1, map.set_sequencer 
        // 2, connect adapter to predictor
        // 3, connect bus_in port of predictor to adapter_ap
        // 4, set predictoon mothod (implicit or explicit)
        // 5, connect ral.map to predictor
        // ---------------------------------------------
        // connect reg-model-relative component    


        // connect VIP-relative component 



    endfunction

endclass
`endif // __TOP_ENV__SVH__

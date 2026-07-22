`ifndef   REG_SEQ
`define   REG_SEQ

`include "./reg_configuration_seq.sv"

//     import RAL_PKG::*; 
class reg_base_seq extends base_seq;
   virtual top_if   top_vif;
   virtual reg_if reg_vif;
   virtual rst_if rst_vif;
  	uvm_status_e status;
   `uvm_object_utils(reg_base_seq)

   //////////////////////////////////////////////////////////////
   // Function Used To "New" The Class
   //////////////////////////////////////////////////////////////
   function new(string name="reg_base_seq");
      super.new(name);
   endfunction : new

  task pre_body();
     super.pre_body();

     if (!uvm_config_db #(virtual interface top_if)::get(uvm_root::get(), get_full_name(), "top_vif", top_vif))
     //if (!uvm_config_db #(virtual interface top_if)::get(m_sequencer, "", "top_vif", top_vif))
      `uvm_error("TOP_VIP:ERROR", "VIF top_vif is missing from config_db")

    //`uvm_info(get_type_name(),$sformatf("%s", this.get_full_name()), UVM_MEDIUM)
    //uvm_test_top.top_env_h.reg_env_h.reg_agent_h.m_sequencer.reg_special_val_seq
    //if (!uvm_config_db #(virtual interface reg_if)::get(m_sequencer, "", "reg_vif", reg_vif))
    if (!uvm_config_db #(virtual interface reg_if)::get(null, get_full_name(), "reg_vif", reg_vif))
      `uvm_error("REG_VIP:ERROR", "VIF reg_vif is missing from config_db")
    
    if (!uvm_config_db #(virtual interface rst_if)::get(m_sequencer, "", "rst_vif", rst_vif))
      `uvm_error("RST_VIP:ERROR", "VIF rst_vif is missing from config_db")
    
    this.set_no_chk();
    this.set_W1T_no_check();
   endtask


   task body();
     super.body();
    //this.set_wait_for_reset();
   endtask


   virtual task wait_cycles(input bit[31:0] n_cycles);
      repeat(n_cycles) @(posedge reg_vif.clk);
   endtask: wait_cycles  
  
   virtual task wait_x_cycles(input bit[31:0] n_cycles);
      repeat(n_cycles) @(posedge reg_vif.xclk);
   endtask: wait_x_cycles     

	//---------------------------------------------------------------------------
	// this task is to set some special fields no need to CHECK==>aim to update
	//---------------------------------------------------------------------------

  	virtual task set_no_chk();
		uvm_reg_field fd[$];

		//-----------------------------------------------------------------
		//NOTE:
		// Include RO field, counter
		//-----------------------------------------------------------------
		//Ro part
		// c2t_rd_vld no need to check
		ral.lvro_master.reg_vldctrl.reg_lvro_c2t_rd_vld.set_compare(UVM_NO_CHECK);	
    
	    //foreach(fd[k])begin
	    //  if( fd[k].get_name() != "reg_div_num" && fd[k].get_name() != "reg_rst_ro_ctrl")
	    //    fd[k].set_compare(UVM_NO_CHECK);
	    //end
        
        //efuse ro filed
        ral.efuse.reg_efuse_ctrl.reg_ip_rf.set_compare(UVM_NO_CHECK);
        ral.efuse.reg_efuse_ctrl.reg_ip_cur_strobe.set_compare(UVM_NO_CHECK);


		//spd part
		ral.speed.reg_pllcnt1.get_fields(fd);
		foreach(fd[k])begin
			fd[k].set_compare(UVM_NO_CHECK);
		end

		ral.speed.reg_pllcnt0.get_fields(fd);
		foreach(fd[k])begin
			fd[k].set_compare(UVM_NO_CHECK);
		end

		// , thsr_wdt_ovf will change
		ral.speed.reg_thsr_wdt_timer_ctrl.reg_thsr_wdt_ovf.set_compare(UVM_NO_CHECK);
		// , timer_stop will change
		ral.speed.reg_spdlog_timer.reg_timer_stop.set_compare(UVM_NO_CHECK);

		ral.work.reg_nonce_update.reg_nonce_rdy.set_compare(UVM_NO_CHECK);

		// 6, pll config
		ral.crg.reg_pll0conf.reg_pll0_lock.set_compare(UVM_NO_CHECK);
		ral.crg.reg_pll0conf.reg_pll0_lock_ip.set_compare(UVM_NO_CHECK);
		ral.crg.reg_pll1conf.reg_pll1_lock.set_compare(UVM_NO_CHECK);
		ral.crg.reg_pll1conf.reg_pll1_lock_ip.set_compare(UVM_NO_CHECK);
		ral.crg.reg_pll2conf.reg_pll2_lock.set_compare(UVM_NO_CHECK);
		ral.crg.reg_pll2conf.reg_pll2_lock_ip.set_compare(UVM_NO_CHECK);
		ral.crg.reg_pll3conf.reg_pll3_lock.set_compare(UVM_NO_CHECK);
		ral.crg.reg_pll3conf.reg_pll3_lock_ip.set_compare(UVM_NO_CHECK);

		// 6, counter
		ral.crg.reg_slice_divcnt1.reg_slice_max_cnt.set_compare(UVM_NO_CHECK);
		ral.crg.reg_slice_divcnt1.reg_slice_min_cnt.set_compare(UVM_NO_CHECK);

    //fpga reg ignore
    ral.comm.reg_fpga_tag_id.get_fields(fd);
		foreach(fd[k])begin
			fd[k].set_compare(UVM_NO_CHECK);
		end
    
	endtask: set_no_chk
   

 	// roctrl is rdy only when [15] is high
	virtual task roctrl_rst();
		`uvm_info(get_type_name(), $sformatf("Set roctrl blk reset start..."), UVM_MEDIUM);
		
		// set not gate roctrl
		ral.work.reg_cg_en.reg_ro_cg_en.set(0);
		ral.work.reg_cg_en.update(status);

		ral.lvro_inst.reg_roctrl0_0.reg_lvro_rst0_0.set(1);
		ral.lvro_inst.reg_roctrl0_0.update(status);
		wait_x_cycles(200);
		ral.lvro_inst.reg_roctrl0_1.reg_lvro_rst0_1.set(1);    
		ral.lvro_inst.reg_roctrl0_1.update(status);
		wait_x_cycles(200);
		wait_x_cycles(200);    
		ral.lvro_inst.reg_roctrl1_0.reg_lvro_rst1_0.set(1);
		ral.lvro_inst.reg_roctrl1_0.update(status);
		wait_x_cycles(200);
		ral.lvro_inst.reg_roctrl1_1.reg_lvro_rst1_1.set(1);
		ral.lvro_inst.reg_roctrl1_1.update(status);
		wait_x_cycles(200);
		wait_x_cycles(200);

		`uvm_info(get_type_name(), $sformatf("Set roctrl blk reset end..."), UVM_MEDIUM);
	endtask:roctrl_rst;
  
  
	virtual task core_test();
		///*cfg cpm
		wrc_cpm_plls();
		work_reg_init_seq();
		initSpd();
		selfclk_conf();
		//select core 0 and select ntime to be 1 to return nonce
		workAssignRound(0,1);
		//*/
	endtask: core_test


	virtual task efuse_clk_enable();

  	// ral.crg.reg_ri_enable.reg_ri_function_pre.set(1'b0);
		// ral.crg.reg_ri_enable.upd();

    ral.crg.reg_mux.reg_xclk_efuse_en.set(1'b1);
    ral.crg.reg_mux.upd();   
    `uvm_info(get_type_name,"open efuse xlck...",UVM_MEDIUM)
    
	endtask: efuse_clk_enable

endclass: reg_base_seq



//-----------------------------------------------------------------------
// Function: 
//  1. registers bit level RW check
//  2. write every bit for a register and read back and check
//  3. reg_basic_single_bit_seq will be called manually by reg_basic_seq
//-----------------------------------------------------------------------
class reg_basic_single_bit_seq extends reg_base_seq;
	uvm_reg rg;  //this reg will be given actual value when this seq called===>polymorphism

	`uvm_object_utils(reg_basic_single_bit_seq)
	function new(string name = "reg_basic_single_bit_seq");
		super.new(name);
	endfunction :new

	task pre_body();
		super.pre_body();
	endtask:pre_body

	virtual task body();
		uvm_reg_field fields[$]; 
		uvm_reg_map maps[$];

		super.body();
		`uvm_info(get_type_name(), "reg_basic_single_bit_seq start", UVM_MEDIUM)
		`uvm_info(get_type_name(), $sformatf("begin to check reg:%s",rg.get_name()), UVM_MEDIUM)
		
		rg.get_maps(maps); //maps=='{default map}
		// get fields of a register
		foreach(maps[k])begin
		rg.get_fields(fields);
		
		foreach(fields[i])begin
			string field_access;
			string fd_name;

			bit [`UVM_REG_DATA_WIDTH-1:0] lsb, n_bits;

			fd_name = fields[i].get_name();
			//str.len() instead of str.size()

			//str.substr(i,j) will return sub string btw [j:i] 
			//sv doesn't support slicing, eg.fd_name[0:2]
			// NOTE:
			// 1, rfu 
			// 2, roctrl.reg_ro_rdy*_*
			// 2, ss_ctrl.reg_glbset
			// 3, efuse_ctrl.reg_sense_rdy, change within one cycle
			// 4, pvt.reg_vsensor.reg_dout_rdy, change within one cycle
			// 5, 
			if( 
				fd_name.substr(0,2) == "rfu"  ||
				fd_name.substr(0,9) == "reg_ro_rdy"  ||
				fd_name == "reg_glbset"     || 
				fd_name == "reg_sense_rdy"  || 
				fd_name == "reg_tvsenr_rdy"     
			)begin
			`uvm_info(get_type_name(), $sformatf("[%s] is rfu or special type field", fields[i].get_full_name()), UVM_MEDIUM)
			continue;
			end
			field_access = fields[i].get_access(maps[k] ) ;                 
			lsb = fields[i].get_lsb_pos();
			n_bits = fields[i].get_n_bits();
			//`uvm_info(get_type_name(), $sformatf("lsb = 'h%0h, n_bits = 'h%0h", lsb, n_bits), UVM_MEDIUM)

			case(field_access)
				//`uvm_info(get_type_name(), $sformatf("[CHECK] lsb = 'h%0h, n_bits = 'h%0h",lsb, n_bits), UVM_MEDIUM);
				"W1T", "RC": 
						for (int j = lsb; j < lsb + n_bits; j ++)begin
							do_W1T_RO_check(rg, j, fields[i], maps[k]); 
						end
				"RO":
						begin: RO
							if (fd_name != "reg_spdlog") begin
								for (int j = lsb; j < lsb + n_bits; j ++)begin
									do_W1T_RO_check(rg, j, fields[i], maps[k]); 
								end
							end
							// -------------------------------------------
							// spdlog reg split for speedup
							// -------------------------------------------
							else begin:spdlog
								if ($test$plusargs("0_999"))  begin: first_part
									for (int j = lsb; j < 'd1000; j++)begin
									do_W1T_RO_check(rg, j, fields[i], maps[k]); 
									end
								end: first_part
								else if ($test$plusargs("1000_1999")) begin: second_part
									for (int j = 'd1000; j < 2000; j ++)begin
									do_W1T_RO_check(rg, j, fields[i], maps[k]); 
									end
								end: second_part
								else if ($test$plusargs("2000_2999")) begin: third_part
									for (int j = 'd2000; j < 3000; j ++)begin
									do_W1T_RO_check(rg, j, fields[i], maps[k]); 
									end
								end: third_part
								else if ($test$plusargs("3000_MAX")) begin: forth_part
									for (int j = 'd3000; j < lsb + n_bits; j ++)begin
									do_W1T_RO_check(rg, j, fields[i], maps[k]); 
									end
								end: forth_part
							end:spdlog
						end:RO
				"W1C": for (int j = lsb; j < lsb + n_bits; j ++)begin
							do_W1C_check(rg, j, fields[i], maps[k]);
						end
				"RW": for (int j = lsb; j < lsb + n_bits; j ++)begin
							do_RW_check(rg, j, fields[i], maps[k]);
						end          
				default:`uvm_error(get_type_name(), $sformatf("[REG ERR] \"%s\" unknow field access type!", field_access))
			endcase
				
		end
		end
			`uvm_info(get_type_name(), "reg_basic_single_bit_seq end", UVM_MEDIUM)
	endtask
  

	virtual task do_W1T_RO_check(uvm_reg         rg,
						bit [`UVM_REG_DATA_WIDTH -1 :0]      i,        //field_index
						uvm_reg_field   field,
						uvm_reg_map     map = null
						);
		uvm_reg_data_t val, exp, init_val;
		uvm_reg_data_t msk;
		
		msk = 'h0;
		msk[i]=1;
		val = init_val;
		init_val = rg.get();	//exp value
	
		val = init_val;

		//repeat 2 times for test 0 & 1
		repeat(2) begin
		val[i] = ~val[i];
		
		// reg_spdlog, no backdoor path
		if(rg.has_hdl_path())  rg.read(status, init_val, UVM_BACKDOOR, map, this);
		else  rg.read(status, init_val, UVM_FRONTDOOR, map, this);

		rg.write(status, val, UVM_FRONTDOOR, map, this);

		rg.read(status, exp, UVM_FRONTDOOR, map, this);
		//rg.mirror(status, UVM_NO_CHECK);
		if (exp[i] === init_val[i])
			`uvm_info(get_type_name(), $sformatf("[\"%s\" SUCC] Writing bit_%0d ['b%0d] in field \"%s\" with init_val = 'h%0h yielded exp = 'h%0h ",field.get_access(map), i,val[i],field.get_full_name(), init_val&msk, exp&msk), UVM_MEDIUM)
		else 
			`uvm_error(get_type_name(), $sformatf("[\"%s\" ERR] Writing bit_%0d ['b%0d] in field \"%s\" with init_value = 'h%0h yielded exp = 'h%0h ",field.get_access(map),i, val[i],field.get_full_name(),init_val&msk, exp&msk))
		end
		
	endtask: do_W1T_RO_check


	virtual task do_W1C_check(uvm_reg         rg,
						bit [`UVM_REG_DATA_WIDTH-1:0]     i,       //field_index
						uvm_reg_field   field,
						uvm_reg_map     map = null
						);
		uvm_reg_data_t  val, exp, init_val;   
		uvm_reg_data_t msk;
		
		msk = 'h0;
		msk[i]=1;    
		
		// set to 1'b1
		//field.set(1'b1);
		//rg.update(status);  
		repeat (2) begin      
		// write 0 check
		val = rg.get();
		val[i] = 1'b0;
		rg.read(status, init_val, UVM_BACKDOOR, map, this);

		rg.write(status, val, UVM_FRONTDOOR, map, this);
		// rg.mirror(status, UVM_NO_CHECK);
		rg.read(status, exp, UVM_FRONTDOOR, map, this);
		if (exp[i] === init_val[i])
			`uvm_info(get_type_name(), $sformatf("[\"%s\" SUCC] Writing 1'b0 in field \"%s\" with initial value init_val = 'h%0h yielded exp = 'h%0h ",field.get_access(map), field.get_full_name(), init_val, exp), UVM_MEDIUM)
		else 
			`uvm_error(get_type_name(), $sformatf("[\"%s\" ERR] Writing 1'b0 in field \"%s\" with initial value init_val = 'h%0h yielded exp = 'h%0h ",field.get_access(map),  field.get_full_name(), init_val, exp))

		// write 1 check
		// init_val 

		val = exp;
		val[i] = 1'b1;

		rg.write(status, val, UVM_FRONTDOOR, map, this);
		//rg.mirror(status, UVM_NO_CHECK);
		rg.read(status, exp, UVM_FRONTDOOR, map, this);
		if (exp[i] === 1'b0)
			`uvm_info(get_type_name(), $sformatf("[\"%s\" SUCC] Writing 1'b1 in field \"%s\" with initial value init_val = 'h%0h yielded exp = 'h%0h ",field.get_access(map),  field.get_full_name(), init_val, exp), UVM_MEDIUM)
		else 
			`uvm_error(get_type_name(), $sformatf("[\"%s\" ERR] Writing 1'b1 in field \"%s\" with initial value init_val = 'h%0h yielded exp = 'h%0h ",field.get_access(map),  field.get_full_name(), init_val, exp))
		end
		
	endtask: do_W1C_check
	

	virtual task do_RW_check(uvm_reg         rg,
						bit [`UVM_REG_DATA_WIDTH-1:0]    i,      //field_index
						uvm_reg_field   field,
						uvm_reg_map     map = null
						);

		uvm_reg_data_t  val, exp, init_val;
		uvm_reg_data_t msk; //msk all bits but the one only need to chk
		bit bit_val;
		
		msk = 'h0;
		msk[i]=1;
		//rg.read(status, init_val, UVM_FRONTDOOR, map, this);
		init_val = rg.get();
	
		val = init_val;

		repeat (2) begin
			val[i] = ~val[i];
			
			rg.write(status, val, UVM_FRONTDOOR, map, this);
			rg.read(status, exp, UVM_FRONTDOOR, map, this);
			//exp = rg.get();
			if (exp[i] === val[i])
			`uvm_info(get_type_name(), $sformatf("[\"%s\" SUCC] Writing bit_%0d ['b%0d] in field \"%s\" with value val = 'h%0h yielded exp = 'h%0h ",field.get_access(map), i, val[i], field.get_full_name(), val&msk, exp&msk), UVM_MEDIUM)
			else 
			`uvm_error(get_type_name(), $sformatf("[\"%s\" ERR] Writing bit_%0d ['b%0d] in field \"%s\" with value val = 'h%0h yielded exp = 'h%0h ",field.get_access(map),i, val[i], field.get_full_name(), val&msk, exp&msk))
		end

	endtask: do_RW_check

endclass: reg_basic_single_bit_seq



//-----------------------------------------------------------------------
// Function:1. block/sub-block level do RW, RO, W1T, WO, W1C test
//          2. executing the <reg_basic_single_bit_seq> 
//-----------------------------------------------------------------------
class reg_basic_seq extends reg_base_seq;
	protected reg_basic_single_bit_seq reg_seq;
	uvm_reg reg_list[string];
    `uvm_object_utils(reg_basic_seq)
      
    function new(string name = "reg_basic_seq");
      super.new(name);
    endfunction: new
    
    task pre_body();
      super.pre_body();
      this.add_excluded_reg_list();
    endtask: pre_body


    task body();
      `uvm_info(get_full_name(), "reg_basic_seq start", UVM_MEDIUM)

      super.body();
      reg_seq = reg_basic_single_bit_seq::type_id::create("reg_basic_single_bit_seq");
      
      set_wait_for_reset();
      wrc_cpm_pll_x(0);

      //---------------------------------------------------
      //function: speedup  simulation
      //---------------------------------------------------
      if ($test$plusargs("WORK_BLK_SINGLE_BIT"))  begin
        do_block(ral.work);      //pass
      end
      
      if ($test$plusargs("SPEED_BLK_SINGLE_BIT"))  begin
        do_block(ral.speed);      //pass
      end

      //---------------------------------------------------
      //function: speedup  simulation for 3 big Regs
      //---------------------------------------------------
      if ($test$plusargs("SPDLOG_SINGLE_BIT"))  begin
        do_reg(ral.reg_spdlog);      //pass
      end
      if ($test$plusargs("SSLOG_SINGLE_BIT")) begin 
        do_reg(ral.reg_sslog);        
      end
      if ($test$plusargs("TCLKPD_SINGLE_BIT"))  begin
        do_reg(ral.reg_tclkpd);      //pass
      end
      //---------------------------------------------------


      if ($test$plusargs("OTHER_BLKS_SINGLE_BIT"))  begin
       do_block(ral.crg);      //pass    
       efuse_clk_enable();
       do_block(ral.efuse);      //pass
       do_block(ral.pvt);        //pass
       do_block(ral.comm);        //pass
       end
      //do_block(ral);      //

      `uvm_info(get_full_name(), "reg_basic_seq end", UVM_MEDIUM)
    endtask: body

	task do_reg(uvm_reg rg);
		reg_seq.rg = rg;
		reg_seq.start(null, this);
		wait_cycles(2);
	endtask:do_reg


	virtual task add_excluded_reg_list();
		reg_list["reg_spd"] =  ral.speed.reg_spd;                 //pwdata -> fpwdata success!
		reg_list["reg_ri_enable"] =  ral.crg.reg_ri_enable;       //rst control      
	endtask:add_excluded_reg_list

	task do_block(uvm_reg_block blk);
		
	
    if( !(blk.get_name() inside {"lvro_inst","lvro_master", "mx2","mx2_tiny"})) begin
			uvm_reg regs[$];
			uvm_reg_addr_t reg_addr;

			blk.get_registers(regs, UVM_NO_HIER); 
			`uvm_info(get_type_name(), $sformatf("regs.size() = 'd%0d", regs.size()), UVM_MEDIUM)
			foreach (regs[i])begin
				reg_addr = regs[i].get_address();
				//`uvm_info(get_type_name(), $sformatf("%s reg_addr = 'h%0h", regs[i].get_name(), reg_addr), UVM_MEDIUM)
				if(reg_addr inside {REG_SPDLOG_ADDR, REG_TCLKPD_ADDR, REG_SSLOG_ADDR, REG_FREQ_SUM_ADDR} )  begin
					`uvm_info(get_type_name(), $sformatf("regs[%s] is a long /special-RO reg, addr = 'h%0h", regs[i].get_name(), reg_addr), UVM_MEDIUM)
					continue;
				end
				else if(reg_list.exists(regs[i].get_name() ) )begin
					`uvm_info(get_type_name(), $sformatf("regs[%s] is excluded", regs[i].get_name()), UVM_MEDIUM)
					continue;
				end
				this.do_reg(regs[i]);
			end
		end

		//begin 
		//  uvm_reg_block sub_blks[$];
		//  blk.get_blocks(sub_blks, UVM_HIER);
		//  foreach(sub_blks[i])begin
		//    //set_wait_for_reset();
		//    do_block(sub_blks[i]);
		//  end
		//end

	endtask: do_block


endclass : reg_basic_seq



//-----------------------------------------------------------------------
// roctrl type regs single bit write/read
// extends reg_basic_single_bit_seq
// update first and check later
// overwrite do_W1T_RO_check &do_RW_check in order to check after updated
//-----------------------------------------------------------------------
class reg_basic_roctrl_single_bit_seq extends reg_basic_single_bit_seq;
  	
	//uvm_reg rg;
	`uvm_object_utils(reg_basic_roctrl_single_bit_seq)
	function new(string name = "reg_basic_roctrl_single_bit_seq");
		super.new(name);
	endfunction :new

	task pre_body();
		super.pre_body();
	endtask:pre_body

	// task body();
	//   uvm_reg_field fields[$]; 
	//   uvm_reg_map maps[$];
	//   super.body();
	// endtask:body

	task do_W1T_RO_check(uvm_reg         rg,
						bit [`UVM_REG_DATA_WIDTH -1 :0]      i,        //field_index
						uvm_reg_field   field,
						uvm_reg_map     map = null);
		uvm_reg_data_t val, exp, init_val;
		uvm_reg_data_t msk;
		
		msk = 'h0;
		msk[i]=1;
		val = init_val;
		init_val = rg.get();
	
		val = init_val;

		repeat(2) begin
		val[i] = ~val[i];

		wait_x_cycles(200);
		rg.read(status, init_val, UVM_BACKDOOR, map, this);

		rg.write(status, val, UVM_FRONTDOOR, map, this);
		wait_x_cycles(200);
		rg.mirror(status,UVM_NO_CHECK, , null);
		wait_x_cycles(200);
		rg.read(status, exp, UVM_FRONTDOOR, map, this);
		//rg.mirror(status, UVM_NO_CHECK);
		if (exp[i] === init_val[i])
			`uvm_info(get_type_name(), $sformatf("[\"%s\" SUCC] Writing bit_%0d ['b%0d] in field \"%s\" with init_val = 'h%0h yielded exp = 'h%0h ",field.get_access(map), i,val[i],field.get_full_name(), init_val&msk, exp&msk), UVM_MEDIUM)
		else 
			`uvm_error(get_type_name(), $sformatf("[\"%s\" ERR] Writing bit_%0d ['b%0d] in field \"%s\" with init_value = 'h%0h yielded exp = 'h%0h ",field.get_access(map),i, val[i],field.get_full_name(),init_val&msk, exp&msk))
		end
	endtask:do_W1T_RO_check


	task do_RW_check(uvm_reg         rg,
						bit [`UVM_REG_DATA_WIDTH-1:0]    i,      //field_index
						uvm_reg_field   field,
						uvm_reg_map     map = null);

		uvm_reg_data_t  val, exp, init_val;
		uvm_reg_data_t msk; //msk all bits but the one only need to chk
		bit bit_val;
	
		msk = 'h0;
		msk[i]=1;
		//rg.read(status, init_val, UVM_FRONTDOOR, map, this);
		init_val = rg.get();
	
		val = init_val;

		repeat (2) begin
			val[i] = ~val[i];
			
			wait_x_cycles(200);
			rg.write(status, val, UVM_FRONTDOOR, map, this);
			wait_x_cycles(200);
			rg.mirror(status,UVM_NO_CHECK, , null);
			wait_x_cycles(200);
			rg.read(status, exp, UVM_FRONTDOOR, map, this);
			//exp = rg.get();
			if (exp[i] === val[i])
			`uvm_info(get_type_name(), $sformatf("[\"%s\" SUCC] Writing bit_%0d ['b%0d] in field \"%s\" with value val = 'h%0h yielded exp = 'h%0h ",field.get_access(map), i, val[i], field.get_full_name(), val&msk, exp&msk), UVM_MEDIUM)
			else 
			`uvm_error(get_type_name(), $sformatf("[\"%s\" ERR] Writing bit_%0d ['b%0d] in field \"%s\" with value val = 'h%0h yielded exp = 'h%0h ",field.get_access(map),i, val[i], field.get_full_name(), val&msk, exp&msk))
		end

	endtask: do_RW_check

endclass : reg_basic_roctrl_single_bit_seq



// -------------------------------------------------------
// function
// 1. roctrl type block level check
// 2. update first and check later
// 3. executing the <reg_basic_roctrl_single_bit_seq>
// -------------------------------------------------------
class reg_basic_roctrl_bit_seq extends reg_base_seq;
  reg_basic_roctrl_single_bit_seq roctrl_single_bit_seq;
 `uvm_object_utils(reg_basic_roctrl_bit_seq)
  function new(string name = "reg_basic_roctrl_bit_seq");
    super.new(name);
  endfunction :new

  task pre_body();
    super.pre_body();
  endtask:pre_body


  task body();
      `uvm_info(get_full_name(), "reg_basic_roctrl_bit_seq start", UVM_MEDIUM)

      super.body();
      roctrl_single_bit_seq = reg_basic_roctrl_single_bit_seq::type_id::create("roctrl_single_bit_seq");
      
      switch_clk(0);
      set_wait_for_reset();
      roctrl_rst();
      
      do_roctrl_block(ral.lvro_inst);     
      do_roctrl_block(ral.lvro_master);     
      //do_roctrl_block(ral.hvro_inst);     

      `uvm_info(get_full_name(), "reg_basic_roctrl_bit_seq end", UVM_MEDIUM)
  endtask: body


  task do_roctrl_block(uvm_reg_block blk);
      uvm_reg regs[$];
      blk.get_registers(regs, UVM_HIER);
      `uvm_info(get_type_name(), $sformatf("regs.size() = 'd%0d", regs.size()), UVM_MEDIUM)

      foreach (regs[i])begin
        regs[i].mirror(status, UVM_NO_CHECK, , null);
        //update first and check later
        roctrl_single_bit_seq.rg = regs[i];
        roctrl_single_bit_seq.start(null, this);
        wait_x_cycles(2);
      end

  endtask:do_roctrl_block

endclass:reg_basic_roctrl_bit_seq



//-------------------------------------------------------------------------
//NOTE:
//`ifdef SIM_SPEED_UP, ral.crg.reg_pll0_gate reset_val = 1'b1, else 1'b0
// add SPEED_UP macro in reg.json
//-----------------------------------------------------------------------
class reg_hw_rst_seq extends reg_base_seq;
  	uvm_reg_hw_reset_seq reg_hw_reset_seq;
    `uvm_object_utils(reg_hw_rst_seq)
    function new(string name = "reg_hw_rst_seq");
      super.new(name);
    endfunction: new
    
    task pre_body();
      super.pre_body();
      //set_report_verbosity_level_hier(UVM_HIGH);
    endtask: pre_body


    task body();
      `uvm_info(get_full_name(), "reg_hw_rst_seq start", UVM_MEDIUM)
      // reset value
      wait(top_vif.ri_rst_n === 1'b1);
      #200ns;

      //test();
      wait_cycles(10);
      set_no_rst_no_check();

      do_block(ral);
      do_lvro_inst_block(ral.lvro_inst);
      print_field_with_reset();
      `uvm_info(get_type_name(),$sformatf("reg_vif.NUM = 'd%0d", reg_vif.NUM) ,UVM_MEDIUM)
      
      `uvm_info(get_full_name(), "reg_hw_rst_seq end", UVM_MEDIUM)
    endtask: body
    

    task set_no_rst_no_check();
      uvm_reg rg[$];
      ral.get_registers(rg);
      foreach(rg[m])begin  
        uvm_reg_map mp[$];    
        uvm_reg_field fd[$];
        
        if(rg[m].get_parent().get_name().substr(0,2) == "mx2")
          continue;
        //end
        rg[m].get_maps(mp);
        rg[m].get_fields(fd);
        foreach(mp[i])begin
          foreach(fd[k])begin
            if(!fd[k].has_reset())begin 
              fd[k].set_compare(UVM_NO_CHECK);            
            end
            if(fd[k].get_name() inside {"reg_pll0_lock","reg_pll1_lock", "reg_pll2_lock", "reg_pll3_lock"}) begin
              fd[k].set_compare(UVM_NO_CHECK);
            end
          end
        end   //foreach(mp[i])begin
      end
    endtask: set_no_rst_no_check


    task do_block(uvm_reg_block blk);
		uvm_reg_block sub_blks[$];
		
		blk.get_blocks(sub_blks, UVM_HIER);
		reg_hw_reset_seq = uvm_reg_hw_reset_seq::type_id::create("uvm_reg_hw_reset_seq");
		foreach (sub_blks[k])begin
			uvm_reg rgs[$];

      if(sub_blks[k].get_name().substr(0,2) == "mx2" || sub_blks[k].get_name() == "lvro_inst")
          continue;
      `ifdef FPGA_SYN
          if(sub_blks[k].get_name() == "crg")
            begin
                uvm_resource_db#(bit)::set({"REG::",this.ral.crg.reg_slice_divcnt0.get_full_name()},
                                            "NO_REG_HW_RESET_TEST",1);
            end
      `endif
			
			// implement the sub-block check
      if(sub_blks[k].get_name() == "efuse")begin
          efuse_clk_enable();
          #1000ns;
      end
			reg_hw_reset_seq.model = sub_blks[k];
			reg_hw_reset_seq.start(null, this);
			
			// NUM counter 
			sub_blks[k].get_registers(rgs);
			foreach(rgs[m])begin  
				uvm_reg_map mp[$];    
				uvm_reg_field fd[$];

				rgs[m].get_maps(mp);
				rgs[m].get_fields(fd);
				foreach(mp[i])begin
					foreach(fd[k])begin
						// get fields with reset
						//if(fd[k].has_reset() && !reg_list.exists(fd[k].get_parent().get_name()))begin 
						if(fd[k].has_reset() )begin 
							reg_vif.field_with_reset[fd[k].get_name()] = fd[k];
							reg_vif.NUM += 1;
							//`uvm_info(get_type_name(),$sformatf("reg_vif.NUM = 'd%0d", reg_vif.NUM) ,UVM_MEDIUM)
							`uvm_info(get_type_name(),$sformatf("FIELD[%s] get_compare = %0d",fd[k].get_full_name(), fd[k].get_compare()) ,UVM_MEDIUM)
						end
					end
				end
			end
		end
    endtask: do_block

    task do_lvro_inst_block(uvm_reg_block lvro_blk);
		uvm_reg rgs[$];			
		lvro_blk.get_registers(rgs);
		foreach(rgs[m])begin  
			uvm_reg_map mps[$];    
			uvm_reg_field fds[$];    
			bit [31:0] rd_val, exp = 0;

			rgs[m].get_maps(mps);
			rgs[m].get_fields(fds);
			// get reset val
			foreach(fds[i])begin
				if(fds[i].has_reset() == 1)begin
					exp = fds[i].get_reset()<<fds[i].get_lsb_pos();
				end
			end

			`uvm_info(get_type_name(), $sformatf("%s reset_val == 'h%0h", rgs[m].get_name(), exp), UVM_MEDIUM)

			foreach(mps[i])begin

				wait_x_cycles(200);
				rgs[m].mirror(status, UVM_NO_CHECK, UVM_FRONTDOOR, mps[i] ,this);
				//lvro_blk  need to be updated,update first and check later
				wait_x_cycles(200);          
				rgs[m].mirror(status, UVM_NO_CHECK, UVM_FRONTDOOR, mps[i] ,this);
				//fix me repeated
				wait_x_cycles(200); 
				rgs[m].read(status, rd_val,UVM_FRONTDOOR, mps[i], this);
				
				if (rd_val === exp)  
					`uvm_info(get_type_name(), $sformatf("[\"%s\"], rd_val == reset_val == 'h%0h", rgs[m].get_full_name(), rd_val), UVM_MEDIUM)
				else  
					`uvm_error(get_type_name(), $sformatf("[\"%s\"],rd_val:'h%0h !== reset_val:'h%0h", rgs[m].get_full_name(),rd_val, exp))

			end
		end
    endtask: do_lvro_inst_block



  	task print_field_with_reset();
		string s;
		int idx;
		s = "";
		s = {s, $sformatf("Total num of fields with reset_value = %0d \n", reg_vif.field_with_reset.size() )};
		foreach(reg_vif.field_with_reset[i])begin
		uvm_reg_field fd;

		fd = reg_vif.field_with_reset[i];
		idx += 1;
		s = {s, $sformatf("- #'d%0d: fd_name = %s, reset_value = 'h%0h \n", 
							idx, fd.get_full_name(), fd.get_reset())};
		end
      	`uvm_info(get_type_name(),$sformatf("[FIELD_WITH_RESET]\n%s", s) ,UVM_MEDIUM)
  	endtask:print_field_with_reset

endclass : reg_hw_rst_seq



//-----------------------------------------------------------------------
//ral 32bits base seq, 32bits random seq extends from this base seq
//difine 2 reg_list: W1C FIELD && EXCLUDE_REG
//-----------------------------------------------------------------------
class reg_32bits_base_seq extends reg_base_seq;
  `uvm_object_utils(reg_32bits_base_seq)
  uvm_reg reg_list[string];
  uvm_reg reg_W1C_list[string];

  function new(string name = "reg_32bits_base_seq");
    super.new(name); 
  endfunction:new

  task pre_body();
    super.pre_body() ; 
    `uvm_info(get_type_name(), "Add reg_list start", UVM_MEDIUM)   
    this.add_excluded_reg_list();
    this.add_W1C_reg_list();
  `uvm_info(get_type_name(), "Add reg_list end", UVM_MEDIUM); ;    
  endtask:pre_body


  task body();
    //empty, wating for child class ... 
  endtask:body


  // whether a reg need check 
  virtual function bit is_chk(uvm_reg rg);
    //empty, wating for child class ... 
  endfunction:is_chk
  

  virtual task add_excluded_reg_list();
    //NOTE,some special reg which need to be update real-time
    reg_list[ral.reg_spdcore.get_name()     ] = ral.reg_spdcore         ;     // <- core speed
    reg_list[ral.reg_tclkpd.get_name()           ] = ral.reg_tclkpd     ;     // recorder
    reg_list[ral.reg_spd.get_name()           ] = ral.reg_spd           ;     //fifo 
    reg_list[ral.reg_spdlog.get_name()        ] = ral.reg_spdlog        ;     //fail & pass recorder
    reg_list[ral.reg_slice_divcnt0.get_name() ] = ral.reg_slice_divcnt0 ;     // REG_SLICE0_DIVCNT0, a counter, add 1 every cycle

    reg_list[ral.reg_ri_enable.get_name()     ] = ral.reg_ri_enable     ;     //ri force = 1'b0
    reg_list[ral.reg_fpga_tag_id.get_name()   ] = ral.reg_fpga_tag_id   ;     //accessable only in fpga mode 
    reg_list[ral.reg_freq_sum.get_name()      ] = ral.reg_freq_sum  ;     

   `uvm_info(get_type_name(),$sformatf("excluded_reg_list \n%p",reg_list), UVM_MEDIUM)
  endtask:add_excluded_reg_list  


  //------------------------------------------------------------
  // W1C register list
  //------------------------------------------------------------
  virtual task add_W1C_reg_list();    
    uvm_reg targets[$];

    ral.get_registers(targets, UVM_HIER);
    foreach(targets[m])begin
      uvm_reg_field fd[$];

      targets[m].get_fields(fd); 
      foreach(fd[k])begin
        if(fd[k].get_access() == "W1C")begin 
          reg_W1C_list[targets[m].get_name()] =  targets[m];  
          break;
        end
      end
    end

    `uvm_info(get_type_name(),$sformatf("reg_W1C_list \n%p",reg_W1C_list), UVM_MEDIUM)
  endtask:add_W1C_reg_list

endclass: reg_32bits_base_seq



//-----------------------------------------------------------------------
//ral 32bits random seq
//-----------------------------------------------------------------------
class reg_32bits_seq extends reg_32bits_base_seq;
  `uvm_object_utils(reg_32bits_seq)

  function new(string name = "reg_32bits_seq");
    super.new(name); 
  endfunction:new

  task pre_body();
    super.pre_body();
  endtask:pre_body


  task body();
    //super.body(); 
    `uvm_info(get_type_name(), "reg_32bits_seq start", UVM_MEDIUM);    
    
    switch_clk(1);
    set_wait_for_reset();
    
    do_normal_block(ral.work);           
    do_normal_block(ral.speed);          
    do_normal_block(ral.crg);            
    do_normal_block(ral.pvt);    

	`ifndef RO_TRIGGER
		//efuse reg rst source controlled by pin_ri, which will be affected by pad_ri, not tested in with RO high case
		initEfuse();
		do_normal_block(ral.efuse);        
	`endif

    do_normal_block(ral.comm);            

    set_wait_for_reset();
    do_normal_block(ral.crg);  

	//do_block(ral) ;             
    `uvm_info(get_type_name(), "reg_32bits_seq end", UVM_MEDIUM);
  endtask:body
  

	virtual task do_block(uvm_reg_block blk);
		uvm_reg_block sub_blks[$];
		blk.get_blocks(sub_blks);       //get_blocks(blks[$], UVM_HIER)
		foreach(sub_blks[i])begin
			// NOTE:
			// top_roctrl and vldctrl is excluded because of ro_gated_clk
		  	if(  !(sub_blks[i].get_name() inside {"lvro_inst","lvro_master", "mx2","mx2_tiny"} )) begin
				`uvm_info(get_type_name(), $sformatf("[\"%s\"] START",sub_blks[i].get_name()), UVM_MEDIUM)  
				do_normal_block(sub_blks[i]);
			end
		end
	endtask: do_block 


	virtual task do_normal_block(uvm_reg_block blk); 
		uvm_reg regs[$];
		uvm_reg_data_t val, exp;
		
		blk.get_registers(regs, UVM_NO_HIER); 
		//UVM_NO_HIER provide info from the local context
		

		foreach (regs[i])begin
			uvm_reg_map maps[$];
			uvm_reg_addr_t reg_addr;
			
			regs[i].get_maps(maps);
			reg_addr = regs[i].get_address();
			if (this.is_chk(regs[i]))begin
				foreach(maps[k])begin

					// `uvm_info(get_type_name(), $sformatf("<=DEBUG_INIT=>Register [\"%s\"]  desire val = 'h%0h", regs[i].get_full_name(),  regs[i].get()), UVM_MEDIUM) 
					// `uvm_info(get_type_name(), $sformatf("<=DEBUG_INIT=>Register [\"%s\"]  mirrored val = 'h%0h", regs[i].get_full_name(),  regs[i].get_mirrored_value()), UVM_MEDIUM) 
					
					if(regs[i].has_hdl_path())  regs[i].mirror(status,UVM_NO_CHECK , UVM_BACKDOOR,maps[k]);
					else  regs[i].mirror(status, UVM_NO_CHECK, UVM_FRONTDOOR, maps[k]);

					// `uvm_info(get_type_name(), $sformatf("<=DEBUG_BEFORE=>Register [\"%s\"]  desire val = 'h%0h", regs[i].get_full_name(),  regs[i].get()), UVM_MEDIUM) 
					// `uvm_info(get_type_name(), $sformatf("<=DEBUG_BEFORE=>Register [\"%s\"]  mirrored val = 'h%0h", regs[i].get_full_name(),  regs[i].get_mirrored_value()), UVM_MEDIUM) 
					
					//write start
					get_wr_val_with_mask(regs[i], val);

					`uvm_info(get_type_name(), $sformatf("Register [\"%s\"] in map [\"%s\"] write val = 'h%0h", regs[i].get_full_name(), maps[k].get_full_name(), val), UVM_MEDIUM) 
					regs[i].write(status, val, UVM_FRONTDOOR, maps[k], this);
					
					// `uvm_info(get_type_name(), $sformatf("<=DEBUG_AFTER=>Register [\"%s\"]  write val = 'h%0h", regs[i].get_full_name(),  val), UVM_MEDIUM) 
					// `uvm_info(get_type_name(), $sformatf("<=DEBUG_AFTER=>Register [\"%s\"]  desire val = 'h%0h", regs[i].get_full_name(),  regs[i].get()), UVM_MEDIUM) 
					// `uvm_info(get_type_name(), $sformatf("<=DEBUG_AFTER=>Register [\"%s\"]  mirrored val = 'h%0h", regs[i].get_full_name(),  regs[i].get_mirrored_value()), UVM_MEDIUM) 
					
					//mirror use UVM_CHECK
					regs[i].mirror(status, UVM_CHECK,,maps[k]);

					// `uvm_info(get_type_name(), $sformatf("<=DEBUG_FINAL=>Register [\"%s\"]  desire val = 'h%0h", regs[i].get_full_name(),  regs[i].get()), UVM_MEDIUM) 
					// `uvm_info(get_type_name(), $sformatf("<=DEBUG_FINAL=>Register [\"%s\"]  mirrored val = 'h%0h", regs[i].get_full_name(),  regs[i].get_mirrored_value()), UVM_MEDIUM) 
					

				end
			end
			else 
				`uvm_info(get_type_name(), $sformatf("Register [\"%s\"] is excluded", regs[i].get_full_name()), UVM_MEDIUM)
		end
	endtask:do_normal_block


	virtual function bit is_chk(uvm_reg rg);
		if ((!reg_list.exists(rg.get_name())) && (!reg_W1C_list.exists(rg.get_name()) ))
			return 1;
		else return 0;
	endfunction:is_chk

  // ---------------------------------------------------------
  // get write val with mask
  // ---------------------------------------------------------
	task get_wr_val_with_mask(input  uvm_reg target,
								output uvm_reg_data_t wr_val);
		uvm_reg_addr_t rg_addr;
		string target_name;

		rg_addr = target.get_address();
		target_name = target.get_name();

		wr_val = get_random_data();
		wr_val &= (1<<target.get_n_bits()) -1;  //get valid bits fitting in differnt length
		
		case(rg_addr)
			REG_SELFVEC_AGING_CTRL_ADDR: begin
				wr_val[0] = 0;
				`uvm_info(get_type_name(), $sformatf("[%s] detected! Do not enable self aging", target_name), UVM_MEDIUM)
			end      
			REG_SS_CTRL_ADDR:begin
				wr_val[3] = 1;
				`uvm_info(get_type_name(), $sformatf("reg_ss_ctrl detected! set glbsetvld = 1"), UVM_MEDIUM)
			end
			// NOTE:disable gbp
			REG_GBP_CTRL_ADDR: begin
				wr_val[0] = 0;
				`uvm_info(get_type_name(), $sformatf("reg_gbp_ctrl detected!"), UVM_MEDIUM)
			end
			REG_MUX_ADDR: begin
				wr_val[24:21] = $urandom_range(1,4)<<1;
				wr_val[29:25] = $urandom_range(3,8)<<1;
				`uvm_info(get_type_name(), $sformatf("[%s] detected! config pll related",target_name), UVM_MEDIUM)
        wr_val[5] = 1;
        `uvm_info(get_type_name(), $sformatf("[%s] detected!set efuse xclk gate = 0",target_name), UVM_MEDIUM)   
			end  
			REG_RI_ENABLE_ADDR:begin
				wr_val[0] = 0;
				`uvm_info(get_type_name(), $sformatf("[%s] detected!set ri_functoin_pre = 0",target_name), UVM_MEDIUM)
			end
      REG_CORE_RD_ADDR_ADDR:begin
          wr_val[31] = 0;
          `uvm_info(get_type_name(), $sformatf("[%s] detected!set REG_Core_rd_clr = 0",target_name), UVM_MEDIUM)
      end
			default : `uvm_info(get_type_name(), $sformatf("No extra operation,PS:this is mirror time!!!!"), UVM_MEDIUM)
		endcase

	endtask:get_wr_val_with_mask


endclass: reg_32bits_seq 



//-----------------------------------------------------------------------
// ral special 5a5a seq, extends reg_32bits_seq
// the special value seq just overwrite the task:get_random_data
//-----------------------------------------------------------------------
class reg_special_5a5a_seq extends reg_32bits_seq;
  uvm_reg_block model;
  `uvm_object_utils(reg_special_5a5a_seq)

  function new(string name = "reg_special_5a5a_seq");
    super.new(name); 
  endfunction:new

  task body();
    `uvm_info(get_type_name(), "reg_special_5a5a_seq start", UVM_MEDIUM);  

    set_wait_for_reset();
    do_block(model) ;

    `uvm_info(get_type_name(), "reg_special_5a5a_seq end", UVM_MEDIUM);
  endtask: body
  
  function uvm_reg_data_t get_random_data();
     uvm_reg_data_t data;
    data = {`UVM_REG_DATA_WIDTH/32 {32'h5a5a_5a5a}};
    return data;
  endfunction:get_random_data

endclass: reg_special_5a5a_seq 


//-----------------------------------------------------------------------
// ral special a5a5 seq, extends reg_32bits_seq
//-----------------------------------------------------------------------
class reg_special_a5a5_seq extends reg_32bits_seq;
  uvm_reg_block model;
  `uvm_object_utils(reg_special_a5a5_seq)

  function new(string name = "reg_special_a5a5_seq");
    super.new(name); 
  endfunction:new

  task body();
    `uvm_info(get_type_name(), "reg_special_a5a5_seq start", UVM_MEDIUM);  

    set_wait_for_reset();
    do_block(model) ;

    `uvm_info(get_type_name(), "reg_special_a5a5_seq end", UVM_MEDIUM);
  endtask: body
  
  function uvm_reg_data_t get_random_data();
     uvm_reg_data_t data;
    data = {`UVM_REG_DATA_WIDTH/32 {32'ha5a5_a5a5}};
    return data;
  endfunction:get_random_data

endclass: reg_special_a5a5_seq 



//-----------------------------------------------------------------------
// ral special all 1 seq, extends reg_32bits_seq
//-----------------------------------------------------------------------
class reg_special_1_seq extends reg_32bits_seq;
  `uvm_object_utils(reg_special_1_seq)
  uvm_reg_block model;
    
  function new(string name = "reg_special_1_seq");
    super.new(name); 
  endfunction:new

  task body();
    `uvm_info(get_type_name(), "reg_special_1_seq start", UVM_MEDIUM);
    set_wait_for_reset();

    do_block(model) ; 
    `uvm_info(get_type_name(), "reg_special_1_seq end", UVM_MEDIUM);
  endtask: body


  function uvm_reg_data_t get_random_data();
    uvm_reg_data_t data;
    data = {`UVM_REG_DATA_WIDTH/32 {32'hffff_ffff}};
    return data;
  endfunction:get_random_data

endclass: reg_special_1_seq 



//-----------------------------------------------------------------------
// ral special all 0 seq, extends reg_32bits_seq
//-----------------------------------------------------------------------
class reg_special_0_seq extends reg_32bits_seq;
  `uvm_object_utils(reg_special_0_seq)
  uvm_reg_block model;

  function new(string name = "reg_special_0_seq");
    super.new(name); 
  endfunction:new

  task body();
    `uvm_info(get_type_name(), "reg_special_0_seq start", UVM_MEDIUM);
    set_wait_for_reset();

    do_block(model) ; 
    `uvm_info(get_type_name(), "reg_special_0_seq end", UVM_MEDIUM);
  endtask: body

  function  uvm_reg_data_t get_random_data();
    uvm_reg_data_t data;
    data = 'h0;
    return data;
  endfunction:get_random_data
  

endclass: reg_special_0_seq



//-----------------------------------------------------------------------
// ral special seq, include all 0, all 1, and 5a5a
//-----------------------------------------------------------------------
class reg_special_val_seq extends reg_base_seq;
	reg_special_1_seq special_1_seq;
	reg_special_0_seq special_0_seq;
	reg_special_5a5a_seq special_5a5a_seq;
	reg_special_a5a5_seq special_a5a5_seq;
	`uvm_object_utils(reg_special_val_seq)      
		
	function new(string name = "reg_special_val_seq");
		super.new(name); 
	endfunction:new

	task pre_body();
		super.pre_body();
	endtask:pre_body

	task body();
		special_1_seq = reg_special_1_seq::type_id::create("reg_special_1_seq") ;
		special_0_seq = reg_special_0_seq::type_id::create("reg_special_0_seq") ;
		special_5a5a_seq = reg_special_5a5a_seq::type_id::create("reg_special_5a5a_seq") ;
		special_a5a5_seq = reg_special_a5a5_seq::type_id::create("reg_special_a5a5_seq") ;

		`uvm_info(get_type_name(), "reg_special_val_seq start", UVM_MEDIUM);
		
		special_1_seq.model = ral;
		special_0_seq.model = ral;
		special_5a5a_seq.model = ral;
		special_a5a5_seq.model = ral;

		special_1_seq.start(null, this);
		special_0_seq.start(null, this);
		special_5a5a_seq.start(null, this);
		special_a5a5_seq.start(null, this);
		`uvm_info(get_type_name(), "reg_special_val_seq end ...", UVM_MEDIUM);
	endtask: body


endclass: reg_special_val_seq 



//-----------------------------------------------------------------------
// verify the roctrl sub_block regs by write a 32bits value
// and read back to check
//-----------------------------------------------------------------------
class reg_roctrl_rg_seq extends reg_base_seq;
	uvm_reg rg;   //must be roctrl type reg

	`uvm_object_utils(reg_roctrl_rg_seq)
	function new(string name = "reg_roctrl_rg_seq");
		super.new(name);
	endfunction :new

	task pre_body();
		super.pre_body();
	endtask:pre_body

	task body();
		uvm_reg_map maps[$];
		rg.get_maps(maps); 
		
		if (this.is_chk(rg))begin
			foreach(maps[k])begin
				do_roctrl_reg(rg, maps[k]);
			end
		end
		else 
			`uvm_info(get_type_name(), $sformatf("Register [\"%s\"] is excluded", rg.get_full_name()), UVM_MEDIUM)

	endtask:body

		// roctrl blk need wait for a long period
	virtual task do_roctrl_reg(uvm_reg      rg,
								uvm_reg_map   mp
								);
		uvm_reg_data_t val_tmp;
		bit[31:0] val, exp;
		bit [31:0]ro_mask;

		//get roctrl reg msk
		get_roctrl_mask(rg.get_name(), ro_mask);
		`uvm_info(get_type_name(), $sformatf("reg[%s], mask = 'h%h", rg.get_name(), ro_mask),UVM_MEDIUM)
		wait_x_cycles(200);

		// -----------------------------------------------------
		//only check RW FIELD
		// -----------------------------------------------------
		//rg.read(status, exp,UVM_FRONTDOOR, mp, this);
		//wait_x_cycles(200); 

		//rg.mirror(status, UVM_NO_CHECK,,mp);
		//wait_x_cycles(200); 
	
		//write start
		val_tmp = get_random_data();
		val = val_tmp[31:0];
		if(rg.get_address() == REG_VLDCTRL_ADDR)
			val[7]=0;   //rst_0_ctrl;
		else val[8] = 0;   //ro_rst;

		`uvm_info(get_type_name(), $sformatf("Reg [\"%s\"] in map [\"%s\"] write val = 'h%0h]", rg.get_full_name(), mp.get_full_name(), val), UVM_MEDIUM) 
		rg.write(status, val, UVM_FRONTDOOR, mp, this);
		wait_x_cycles(200);
		//write end

		// read for the 3rd time
		//ro reg is enabled only when the 15th bit rdy is high
		rg.mirror(status, UVM_NO_CHECK,,mp);
		wait_x_cycles(200);
		
		rg.mirror(status, UVM_NO_CHECK,,mp);
		wait_x_cycles(200); 

		rg.read(status, exp,UVM_FRONTDOOR, mp, this);

		val &=ro_mask;
		exp &=ro_mask;
		if (val === exp)  
			`uvm_info(get_type_name(), $sformatf("[\"%s\"],Write val:'h%0h === exp:'h%0h", rg.get_full_name(), val, exp), UVM_MEDIUM)
		else  
			`uvm_error(get_type_name(), $sformatf("[\"%s\"],Write val:'h%0h !== exp:'h%0h", rg.get_full_name(),val, exp))
	
	endtask:do_roctrl_reg

  //check 
  virtual function bit is_chk(uvm_reg rg);
    //roctrl block: 2 RO regs
    //if((rg.get_name() != "reg_dtdataout_0" ) && (rg.get_name() != "reg_dtdataout_1" ) )
    return 1;
    //else return 0;
  endfunction:is_chk

endclass: reg_roctrl_rg_seq



// -------------------------------------------------------------------------------------
// verify the roctrl, top_roctrl, vldctrl sub_block by executing reg_roctrl_rg_seq
// -------------------------------------------------------------------------------------
class reg_32bits_roctrl_seq extends reg_base_seq;
	reg_roctrl_rg_seq  roctrl_rg_seq;

	`uvm_object_utils(reg_32bits_roctrl_seq)
	function new(string name = "reg_32bits_roctrl_seq");
		super.new(name);
	endfunction :new

	task pre_body();
		super.pre_body();
	endtask:pre_body

	task body();
		roctrl_rg_seq = reg_roctrl_rg_seq::type_id::create("reg_roctrl_rg_seq");
		`uvm_info(get_type_name(), "reg_32bits_roctrl_seq start ...",UVM_MEDIUM)
		
		`ifdef USE_JAMLINK_DRV
			`uvm_info(get_type_name(), "[JAMLINK] init start", UVM_MEDIUM);    
			//set jlm clk frequency division factor = 2
			jlm_reg_wr(32'h14, 32'h0_0002);
			#1000ns;
			`uvm_info(get_type_name(), "[JAMLINK] init end", UVM_MEDIUM); 
		`endif 

		initRst();
		
		switch_clk(0);
		roctrl_rst();

		do_roctrl_blk(ral.lvro_inst);
		do_roctrl_blk(ral.lvro_master);
    		//do_roctrl_blk(ral.hvro_inst);

		`uvm_info(get_type_name(), $sformatf("reg_32bits_roctrl_seq end ..."),   UVM_MEDIUM)   
	endtask:body


	task do_roctrl_blk(uvm_reg_block blk);
		uvm_reg regs[$];

		blk.get_registers(regs, UVM_HIER);
		foreach (regs[i])begin
		roctrl_rg_seq.rg = regs[i];
		roctrl_rg_seq.start(null, this);
		end
	endtask:do_roctrl_blk  
  
  // roctrl is rdy only when [15] is high
  task roctrl_rst();
    //extends from reg_base_seq
    super.roctrl_rst();
  endtask:roctrl_rst

endclass: reg_32bits_roctrl_seq



// -----------------------------------------------------------
// W1C regs 32bits random test 
// reg_ecc0 will err if check from jamlink
// -----------------------------------------------------------
class reg_32bits_W1C_seq extends reg_32bits_base_seq;
  `uvm_object_utils(reg_32bits_W1C_seq)      
    
  function new(string name = "reg_32bits_W1C_seq");
    super.new(name); 
  endfunction:new

  task pre_body();
    super.pre_body();
    //add_W1C_reg_list();
  endtask:pre_body

  task body();
    //super.body();

    `uvm_info(get_type_name(), "reg_32bits_W1C_seq start", UVM_MEDIUM);

    set_wait_for_reset();    

    wait_cycles(10);
    
    do_block(ral) ;
    wait_cycles(5);
    
    `uvm_info(get_type_name(), "reg_32bits_W1C_seq end", UVM_MEDIUM);
  endtask: body


  task do_block(uvm_reg_block blk);
    uvm_reg regs[$];
    blk.get_registers(regs, UVM_NO_HIER);
    foreach (regs[i])begin
      if(this.is_chk(regs[i]) )
        do_W1C_check(regs[i]);
    end
    begin
      uvm_reg_block sub_blks[$];
      blk.get_blocks(sub_blks, UVM_HIER);
      foreach (sub_blks[i])begin
        do_block(sub_blks[i]);
      end
    end
  endtask: do_block  


  virtual task do_W1C_check(uvm_reg rg);
    uvm_reg_map   maps[$];
    uvm_reg_field fds[$];

    rg.get_maps(maps);
    rg.get_fields(fds);
    foreach(maps[k])begin
      foreach(fds[j]) begin
        bit [`UVM_REG_DATA_WIDTH - 1 : 0]   lsb, n_bits;
        bit [`UVM_REG_DATA_WIDTH - 1 : 0]   w1c_mask = 'h0;
        uvm_reg_data_t    init_val, val, exp; 
        bit cmp_flag = 0;

        lsb = fds[j].get_lsb_pos();
        n_bits = fds[j].get_n_bits();
        
        // gte W1C field mask
        for(int m = lsb; m < lsb+n_bits; m++)begin
          w1c_mask[m] = 1;
        end

        //upd ral 
        rg.read(status, init_val,UVM_FRONTDOOR, maps[k],this);

        val = get_random_data();
        val[lsb] = 1;

        rg.write(status, val,UVM_FRONTDOOR, maps[k], this);
        rg.read(status, exp,UVM_FRONTDOOR, maps[k], this);
        
          //`uvm_info(get_type_name(), $sformatf("'h0 & 'hffff_ffff = 'h%0h", ('h0 & 'hffff_ffff)), UVM_MEDIUM)

        if ((exp&w1c_mask) == 0) begin
          cmp_flag = 1;
          //`uvm_info(get_type_name(), $sformatf("[W1C] \"%s\"! exp: 'h%0h, w1c_mask = 'h%0h", 
          //fds[j].get_full_name(), exp&w1c_mask, w1c_mask), UVM_MEDIUM)
        end
        else  begin
          cmp_flag = 0;
          //`uvm_info(get_type_name(), $sformatf("[W1C] \"%s\"! exp: 'h%0h, w1c_mask = 'h%0h", 
          //fds[j].get_full_name(), exp&w1c_mask, w1c_mask), UVM_MEDIUM)
        end
        `uvm_info(get_type_name(), $sformatf("cmp_flag = 'h%0h", cmp_flag), UVM_MEDIUM)

        // NOTE:
        // UART transmit will trigger header_pass_cnt and chk_pass_cnt += 1
        `ifdef USE_UART_DRV
          if(fds[j].get_name() == "reg_hdrpass" || fds[j].get_name() == "reg_chkpass" ) begin
            if ((exp&w1c_mask) == 1) cmp_flag = 1;
            else  cmp_flag = 0;
            `uvm_info(get_type_name(), $sformatf("cmp_flag = 'h%0h", cmp_flag), UVM_MEDIUM)
          end
        `endif      //`ifdef USE_UART_DRV

        if (!cmp_flag) 
            `uvm_error(get_type_name(), $sformatf("[W1C] \"%s\" check fail! init_val: 'h%0h, Write val:'h%0h, exp:'h%0h, w1c_mask: 'h%0h", 
            fds[j].get_full_name(), init_val, val&w1c_mask, exp&w1c_mask, w1c_mask))
        else
          `uvm_info(get_type_name(), $sformatf("[W1C] \"%s\"check succ! exp: 'h%0h, w1c_mask = 'h%0h", 
          fds[j].get_full_name(), exp&w1c_mask, w1c_mask), UVM_MEDIUM)
      end
    end
  endtask : do_W1C_check


  // check only W1C regs
  function bit is_chk(uvm_reg rg);
    if (reg_W1C_list.exists( rg.get_name() ))
      return 1;
    else return 0;
  endfunction:is_chk


endclass: reg_32bits_W1C_seq 



//-----------------------------------------------------------------------
// overwrite is_chk task
// setting UVM_NO_CHECK to some special reg filed
// test random value to excluded regs
//-----------------------------------------------------------------------
class reg_excluded_regs_seq extends reg_32bits_seq;
	uvm_reg_field fields_list[string];
	`uvm_object_utils(reg_excluded_regs_seq)
		
	function new(string name = "reg_excluded_regs_seq");
		super.new(name); 
	endfunction:new

	task pre_body();
		super.pre_body(); 
		//pre_body will add excluded reg list, W1C and W1T
		this.set_fields_cmp();
	endtask


	task body();
		//super.body();
		`uvm_info(get_type_name(), "reg_excluded_regs_seq start", UVM_MEDIUM);
		set_wait_for_reset();

		do_block(ral) ;

		`uvm_info(get_type_name(), "reg_excluded_regs_seq end", UVM_MEDIUM);
	endtask: body


	task set_fields_cmp();
		this.add_all_fields(ral.crg.reg_slice_divcnt0);        //a cnt
		this.add_all_fields(ral.speed.reg_spd);               //fifo, lookuptable      

		push_back_fields(ral.crg.reg_ri_enable.reg_ri_function );     //ri force = 1'b0
		//pin_ri will be set 1 when reg_ri_function tiehigh
		push_back_fields(ral.crg.reg_ri_enable.reg_pin_ri );              
		
		foreach(fields_list[j])begin
			fields_list[j].set_compare(UVM_NO_CHECK);
		end
	endtask:set_fields_cmp


	function push_back_fields(uvm_reg_field fd);
		fields_list[fd.get_full_name()] = fd;
	endfunction: push_back_fields


	virtual task add_all_fields(uvm_reg rg);
		uvm_reg_field fd[$];
		rg.get_fields(fd);
		foreach(fd[k]) begin
			string fd_name;
			fd_name = $sformatf("%s_%s", rg.get_name(), fd[k].get_name()); 
			fields_list[fd_name]=fd[k];
		end
	endtask:add_all_fields
  

	function bit is_chk(uvm_reg rg);
		string blk_name;
		blk_name = rg.get_parent().get_name() ;
		if (reg_list.exists(rg.get_name())  )
			return 1;
		else return 0;
	endfunction:is_chk

endclass: reg_excluded_regs_seq



// --------------------------------------------------------------
//reg random cfg with core test
// --------------------------------------------------------------
class reg_core_seq extends reg_base_seq;
  reg_32bits_seq        reg_seq;
  reg_32bits_W1C_seq    reg_W1C_seq;

  uvm_reg reg_cfg_list[string];
  `uvm_object_utils(reg_core_seq)      
    
  function new(string name = "reg_core_seq");
    super.new(name); 
  endfunction:new

  task pre_body();
    super.pre_body();
    // add special reg list
    // random cfg reg will affect core_test
    add_reg_cfg_list();

  endtask:pre_body


  task body();
    super.body(); 
    `uvm_info(get_type_name(), "reg_core_seq start", UVM_MEDIUM);
    set_wait_for_reset();
    
    //switch to xclk to avoid mid_clk stb
    switch_clk();

    random_block(ral) ;

    // 7, tclkpd, selfclkvla  
    ral.speed.reg_tclkpd.reg_tclkpd.set_compare(UVM_NO_CHECK);
    //----------------------------------------------------------------- 
    wait_cycles(5);
    
    //execute core test
    core_test();
    wait_x_cycles(200);

    //turnoff_clkpd();
    reg_seq = reg_32bits_seq::type_id::create("reg_seq");
    reg_W1C_seq = reg_32bits_W1C_seq::type_id::create("reg_W1C_seq");
    reg_seq.start(null, this);
    reg_W1C_seq.start(null, this);
    `uvm_info(get_type_name(), "reg_core_seq end", UVM_MEDIUM);
  endtask: body


  task random_block(uvm_reg_block blk);
    uvm_reg regs[$];
    if(is_chk(blk) )begin
      blk.get_registers(regs,UVM_NO_HIER);
      foreach (regs[i])begin
        if (!reg_cfg_list.exists(regs[i].get_name()) )begin
          uvm_reg_map maps[$];
          regs[i].get_maps(maps);
          foreach (maps[k]) begin
            uvm_reg_data_t  val;

            val = get_random_data();
            val &= (1<<regs[i].get_n_bits()) -1;
             
            // cpm glitch_free mux
            if(regs[i].get_address() == REG_MUX_ADDR)begin
              val[24:21] = $urandom_range(1,4)<<1;
              val[29:25] = $urandom_range(3,8)<<1;
              `uvm_info(get_type_name(), $sformatf("reg_mux detected! val[24:21] = 'd%0d, val[29:25] = 'd%0d", val[24:21], val[29:25]), UVM_MEDIUM)
            end 

            `uvm_info(get_type_name(), $sformatf("Register [\"%s\"] in map [\"%s\"] write val = 'h%0h", regs[i].get_full_name(), maps[k].get_full_name(), val), UVM_MEDIUM) 

            if(regs[i].get_parent().get_name() inside { "lvro_inst", "lvro_master"}) begin
              wait_x_cycles(200);
              //switch_clk(0);

            end
            regs[i].write(status, val, UVM_FRONTDOOR, maps[k],this);
          end
        end
      end
    end

    begin
      uvm_reg_block sub_blks[$];
      blk.get_blocks(sub_blks, UVM_HIER);
      foreach (sub_blks[i])begin
        random_block(sub_blks[i]);
      end
    end
  endtask: random_block  


  task add_reg_cfg_list();
    // NOTE:
    // enable top rx receiver
    reg_cfg_list[ral.reg_toprx_en_0.get_name()  ]  =  ral.reg_toprx_en_0;  
    reg_cfg_list[ral.reg_toprx_en_1.get_name()  ]  =  ral.reg_toprx_en_1;  
    reg_cfg_list[ral.reg_toprx_en_2.get_name()  ]  =  ral.reg_toprx_en_2;  
//    reg_cfg_list[ral.reg_toprx_en_3.get_name()  ]  =  ral.reg_toprx_en_3;  
//    reg_cfg_list[ral.reg_toprx_en_4.get_name()  ]  =  ral.reg_toprx_en_4;  
  //duanzhiwei comment 2024/09/13  reg_cfg_list[ral.reg_toprx_en_5.get_name()  ]  =  ral.reg_toprx_en_5;  

    // NOTE:
    // will enable self aging
      
    reg_cfg_list[ral.speed.reg_selfcnt_ctrl.get_name()  ]  =  ral.speed.reg_selfcnt_ctrl;
    reg_cfg_list[ral.speed.reg_selfvec_aging_ctrl.get_name()]  =  ral.speed.reg_selfvec_aging_ctrl;
    
    reg_cfg_list[ral.work.reg_core_cfg.get_name() ] =  ral.work.reg_core_cfg;  
    reg_cfg_list[ral.work.reg_cfg.get_name()      ] =  ral.work.reg_cfg;  
    reg_cfg_list[ral.work.reg_ft.get_name()       ] =  ral.work.reg_ft;  
    reg_cfg_list[ral.lvro_master.reg_vldctrl.get_name()    ] =  ral.lvro_master.reg_vldctrl;  
  endtask: add_reg_cfg_list


  function bit is_chk(uvm_reg_block blk);
    //if( (blk.get_name() !="mx2") && (blk.get_name() !="work") ) return 1;
    if( blk.get_name().substr(0,2) !="mx2" ) return 1;
    else return 0;
  endfunction:is_chk


endclass: reg_core_seq



//-----------------------------------------------------------------------
//write all regs, and read back to check
//-----------------------------------------------------------------------
class reg_write_read_seq extends reg_32bits_seq;
	`uvm_object_utils(reg_write_read_seq)
	logic [31:0] reg_wr_a[string];
	logic [31:0] reg_rd_a[string];

	function new(string name = "reg_write_read_seq");
		super.new(name); 
	endfunction:new

	task pre_body();
		super.pre_body();
		this.add_excluded_reg_list();
		this.add_W1C_reg_list();

	endtask:pre_body


	task body();
		//super.body();
		uvm_reg all_regs[$];
		`uvm_info(get_type_name(), "reg_write_read_seq start", UVM_MEDIUM);    
		set_wait_for_reset();

		ral.get_registers(all_regs, UVM_HIER);
		
		write_all_regs(all_regs);
		wait_x_cycles(100);
		check_all_regs(all_regs) ;            

		`uvm_info(get_type_name(), "reg_write_read_seq end", UVM_MEDIUM);
	endtask:body


  task write_all_regs(uvm_reg rg[$]);
    foreach (rg[m]) begin
      uvm_reg_map maps[$];
      uvm_reg_field fd[$];
      string blk_name;
      
      rg[m].get_fields(fd);
      rg[m].get_maps(maps);
      blk_name = rg[m].get_parent().get_name();

      // write all regs
      foreach(maps[k])begin
          //NOTE:
        if ((blk_name.substr(0,2) != "mx2") && (blk_name != "rst") )begin
          if ( blk_name inside {"lvro_inst", "lvro_master"} )begin
            switch_clk(0);
            write_roctrl_rg(rg[m], maps[k]);
          end
          else begin
            write_normal_rg(rg[m], maps[k]);      
            foreach(fd[n])begin
              if(fd[n].get_access() inside {"RO", "W1C", "RC"})
               fd[n].set_compare(UVM_NO_CHECK);
            end
          end
        end
      end
    end
  endtask: write_all_regs


	// ROCTRL type reg write need wait for more time
	task write_roctrl_rg(uvm_reg rg, uvm_reg_map mp);
		uvm_reg_data_t val;
		val = get_random_data();   
		val[29]=0;
		val[15]=0;

		if (this.is_chk(rg) && rg.get_address() != REG_VLDCTRL_ADDR)begin
			wait_x_cycles(100);    
			rg.write(status, val,UVM_FRONTDOOR,mp,this);   
			reg_wr_a[rg.get_name()] = rg.get_mirrored_value();
			`uvm_info(get_type_name(), $sformatf("[%s] desired val='h%0h, mirrored val='h%0h", rg.get_name(),rg.get(),rg.get_mirrored_value() ), UVM_MEDIUM)
		end
	endtask: write_roctrl_rg

	task write_normal_rg(uvm_reg rg, uvm_reg_map mp);
		uvm_reg_data_t val;

		get_wr_val_with_mask(rg, val);
		`uvm_info(get_type_name(), $sformatf("Register [\"%s\"] write val = 'h%0h", rg.get_full_name(), val), UVM_MEDIUM) 
		rg.write(status, val,UVM_FRONTDOOR,mp,this);   
	endtask: write_normal_rg


	task check_all_regs(uvm_reg rg[$]);
		foreach (rg[m])begin  
			string blk_name;
			uvm_reg_map maps[$];

			blk_name = rg[m].get_parent().get_name(); 
			rg[m].get_maps(maps);
			foreach(maps[k])begin
	        if(blk_name.substr(0,2) != "mx2")begin
	          	if ( blk_name inside {"lvro_inst", "lvro_master"} )begin
						switch_clk(0);
						get_roctrl_rg(rg[m]);
					end
					else do_normal_rg_chk(rg[m]);
				end
			end
		end
		
		// after get all roctrl type reg, do check
		do_roctrl_rg_chk();

	endtask:check_all_regs


	task do_normal_rg_chk(uvm_reg rg); 
		uvm_reg_map maps[$];
		rg.get_maps(maps);
		if (this.is_chk(rg))begin
			foreach(maps[k])begin
				//mirror use UVM_CHECK
				`uvm_info(get_type_name(), $sformatf("[%s] desired val='h%0h, mirrored val='h%0h", rg.get_name(),rg.get(),rg.get_mirrored_value() ), UVM_MEDIUM)
				rg.mirror(status, UVM_CHECK,,maps[k]);
				wait_cycles(2); 
			end
		end
		else 
		`uvm_info(get_type_name(), $sformatf("Register [\"%s\"] is excluded", rg.get_full_name()), UVM_MEDIUM)
	endtask:do_normal_rg_chk


	task get_roctrl_rg(uvm_reg rg);    
		uvm_reg_map maps[$];
		bit [31:0] exp;
		rg.get_maps(maps);
		if (this.is_chk(rg))begin
			foreach(maps[k])begin
				
				wait_x_cycles(200);
				rg.mirror(status, UVM_NO_CHECK,,maps[k]);
				wait_x_cycles(200);
				rg.mirror(status, UVM_NO_CHECK,,maps[k]);
				wait_x_cycles(200);
				rg.read(status, exp, UVM_FRONTDOOR, maps[k], this);
				reg_rd_a[rg.get_name()] = exp;
			end
		end
		else 
		`uvm_info(get_type_name(), $sformatf("Register [\"%s\"] is excluded", rg.get_full_name()), UVM_MEDIUM)
	endtask: get_roctrl_rg
  

	task do_roctrl_rg_chk();
		bit [31:0] ro_mask ;
		
		`uvm_info(get_type_name(), $sformatf("reg_wr_a has 'h%0h elements", reg_wr_a.size()), UVM_MEDIUM)
		foreach(reg_wr_a[m])begin
			get_roctrl_mask(m , ro_mask);
			if((reg_wr_a[m] &= ro_mask) === (reg_rd_a[m] &= ro_mask )) `uvm_info(get_type_name(), $sformatf("Reg[%s] write value == read value : 'h%0h ",m,reg_rd_a[m]), UVM_MEDIUM)
			else `uvm_error(get_type_name(), $sformatf("Reg[%s] write value:'h%0h !== read value: 'h%0h ",m,reg_wr_a[m], reg_rd_a[m]))
		end
		reg_wr_a.delete();     //clr roctrl block data array every time
		reg_rd_a.delete();
	endtask:do_roctrl_rg_chk


	function bit is_chk(uvm_reg rg);
		if ((!reg_list.exists(rg.get_name())) && (!reg_W1C_list.exists(rg.get_name()) ))
		return 1;
		else return 0;
	endfunction:is_chk

	task add_excluded_reg_list();
		super.add_excluded_reg_list();
		reg_list[ral.reg_freq_sum.get_name()      ] = ral.reg_freq_sum ;       
	endtask:add_excluded_reg_list  
      
  
  // get wr_val with mask
  task get_wr_val_with_mask(input  uvm_reg target,
                             output uvm_reg_data_t wr_val);
    uvm_reg_addr_t rg_addr;
    string target_name;

    rg_addr = target.get_address();
    target_name = target.get_name();

    wr_val = get_random_data();
    wr_val &= (1<<target.get_n_bits()) -1;
    
    case(rg_addr)
		REG_SELFVEC_AGING_CTRL_ADDR: begin
			wr_val[0] = 0;
		end
		REG_MUX_ADDR: begin
			wr_val[24:21] = $urandom_range(1,4)<<1;
			wr_val[29:25] = $urandom_range(3,8)<<1;
			`uvm_info(get_type_name(), $sformatf("[%s] detected! config pll related",target_name), UVM_MEDIUM)
      wr_val[5] = 1;
      `uvm_info(get_type_name(), $sformatf("[%s] detected!set efuse xclk gate = 0",target_name), UVM_MEDIUM)   
		end
		REG_CG_EN_ADDR: begin
			wr_val[6] = 0;
			`uvm_info(get_type_name(), $sformatf("[%s] detected! Do not gate RO clk",target_name), UVM_MEDIUM)
		end
		REG_SS_CTRL_ADDR:begin
			wr_val[3] = 1;
			`uvm_info(get_type_name(), $sformatf("[%s] detected!set glbsetvld = 1",target_name), UVM_MEDIUM)
		end
		REG_RI_ENABLE_ADDR:begin
			wr_val[0] = 0;
			`uvm_info(get_type_name(), $sformatf("[%s] detected!set ri_functoin_pre = 0",target_name), UVM_MEDIUM)
		end
      default : `uvm_info(get_type_name(), $sformatf("No extra operation,PS:this is mirror time!!!!"), UVM_MEDIUM)
    endcase
  endtask:get_wr_val_with_mask

endclass: reg_write_read_seq


//-----------------------------------------------------------------------
//addr reverse: write all regs, and read back to check
//-----------------------------------------------------------------------
class reg_write_read_reverse_seq extends reg_write_read_seq;
 `uvm_object_utils(reg_write_read_reverse_seq)
  logic [31:0] reg_wr_a[string];
  logic [31:0] reg_rd_a[string];

    
  function new(string name = "reg_write_read_reverse_seq");
    super.new(name); 
  endfunction:new

  task pre_body();
    super.pre_body();    
  endtask:pre_body


  task body();    
    uvm_reg all_regs[$];

    `uvm_info(get_type_name(), "reg_write_read_reverse_seq start", UVM_MEDIUM);    
    set_wait_for_reset();

    ral.reg_freq_sum.reg_freq_sum.set_compare(UVM_NO_CHECK);
    ral.reg_freq_sum.reg_freq_sum_rdy.set_compare(UVM_NO_CHECK);
    

    ral.get_registers(all_regs, UVM_HIER);
    all_regs.reverse();

    // Do not gate roctrl clk
    efuse_clk_enable();
    roctrl_rst();
    write_all_regs(all_regs);
    wait_x_cycles(100);
    check_all_regs(all_regs) ;            

    `uvm_info(get_type_name(), "reg_write_read_reverse_seq end", UVM_MEDIUM);
  endtask:body

endclass: reg_write_read_reverse_seq




//-----------------------------------------------------------------------
// common reg access by uart
//-----------------------------------------------------------------------
class reg_comm_by_uart_seq  extends reg_base_seq;
	`uvm_object_utils(reg_comm_by_uart_seq)
	uvm_reg comm_reg_list[$];

	function new(string name = "reg_comm_by_uart_seq");
		super.new(name); 
	endfunction:new

	task pre_body();
		super.pre_body();    
	endtask:pre_body


	task body();
		super.body();
		`uvm_info(get_type_name(), "reg_comm_by_uart_seq start", UVM_MEDIUM);
		
		comm_reg_by_uart_check();

		`uvm_info(get_type_name(), "reg_comm_by_uart_seq end", UVM_MEDIUM);
	endtask:body


	task comm_reg_by_uart_check();
		bit [31:0] wr_data;
		comm_reg_list.push_back(ral.reg_chip_id);
		comm_reg_list.push_back(ral.reg_fb_sel);
		comm_reg_list.push_back(ral.reg_io_n_pad_cfg);
		comm_reg_list.push_back(ral.reg_io_s_pad_cfg);
		comm_reg_list.push_back(ral.reg_uart_tr_max );
		comm_reg_list.push_back(ral.reg_uart_status);
		
		foreach(comm_reg_list[i])begin
		wr_data = get_random_data();
		`uvm_info(get_type_name(), $sformatf("[REG] \"%s\", wr_data: 'h%h", comm_reg_list[i].get_full_name(), wr_data), UVM_MEDIUM);
		if (comm_reg_list[i].get_name() == "reg_uart_status"||comm_reg_list[i].get_name() == "reg_chip_id")begin
			// ro reg need upd 
			comm_reg_list[i].mirror(status, UVM_NO_CHECK, UVM_BACKDOOR, , this);
		end
			
			comm_reg_list[i].write(status, wr_data, UVM_FRONTDOOR, null, this);
		end	
		foreach(comm_reg_list[i])begin
			comm_reg_list[i].mirror(status, UVM_CHECK, UVM_FRONTDOOR, , this);
		end
	endtask:comm_reg_by_uart_check 

endclass: reg_comm_by_uart_seq



//-----------------------------------------------------------------------
//ral 32bits random seq from jlm or uart
//-----------------------------------------------------------------------
class reg_32bits_jlm_seq extends reg_32bits_base_seq;
  local reg_comm_by_uart_seq comm_uart_seq;

  `uvm_object_utils(reg_32bits_jlm_seq)
    
  function new(string name = "reg_32bits_jlm_seq");
    super.new(name); 
  endfunction:new

  task pre_body();
    super.pre_body();    
    //this.set_no_chk();
  endtask:pre_body

  task body();
    //super.body();
    
    initRst();
    wrc_cpm_pll_x(0);
    //work_reg_init_seq();
    //initSpd();

    
    // 8, Recording All freq sum, UART & JLM operation is slower, change within <R-W-R> check  
    ral.reg_freq_sum.reg_freq_sum.set_compare(UVM_NO_CHECK);
    ral.reg_freq_sum.reg_freq_sum_rdy.set_compare(UVM_NO_CHECK);

    `uvm_info(get_type_name(), "reg_32bits_jlm_seq start", UVM_MEDIUM);    
    
    if ($test$plusargs("WORK_BLK"))  begin
      do_normal_block(ral.work);           //
    end

    if ($test$plusargs("SPEED_BLK"))  begin
      do_normal_block(ral.speed);        
    end

    if ($test$plusargs("REG_SPDLOG")) begin 
      do_reg(ral.reg_spdlog);        
    end
    
    if ($test$plusargs("REG_TCLKPD")) begin 
      do_reg(ral.reg_tclkpd);        
    end

    if ($test$plusargs("REG_SSLOG")) begin 
      do_reg(ral.reg_sslog);        
    end

    if ($test$plusargs("IP_BLK"))  begin
      //initPvt(); TOBE CONFIRMED
      do_normal_block(ral.pvt);            //p

      `ifndef USE_UART_DRV
          do_normal_block(ral.std); 
      `endif
      
      `ifndef PL_SIM
          initEfuse();
          do_normal_block(ral.efuse);          //p
      `endif
      
    end

    if ($test$plusargs("OTHER_BLKS"))  begin
      do_normal_block(ral.crg);    
		`ifdef USE_UART_DRV
			`ifndef PL_SIM
				comm_uart_seq = reg_comm_by_uart_seq::type_id::create("comm_uart_seq");
				comm_uart_seq.start(null, this);
			`endif
		`elsif  USE_JAMLINK_DRV
			do_normal_block(ral.comm);          
		`endif  //`ifndef USE_UART_DRV
		    
    end

    `uvm_info(get_type_name(), "reg_32bits_jlm_seq end", UVM_MEDIUM);
  endtask:body
  

	task do_block(uvm_reg_block blk);
		uvm_reg_block sub_blks[$];
		blk.get_blocks(sub_blks);       //get_blocks(blks[$], UVM_HIER)
		foreach(sub_blks[i])begin
		//NOTE:
	      // roctrl
	      		if( !(sub_blks[i].get_name() inside {"lvro_inst","lvro_master", "mx2","mx2_tiny"})) begin
				`uvm_info(get_type_name(), $sformatf("[\"%s\"] START",sub_blks[i].get_name()), UVM_MEDIUM)  
				do_normal_block(sub_blks[i]);
			end
		end
	endtask: do_block 


	task do_normal_block(uvm_reg_block blk); 
		uvm_reg regs[$];
		uvm_reg_addr_t reg_addr;
		blk.get_registers(regs, UVM_NO_HIER); 

		//UVM_NO_HIER provide info from the local context
		foreach (regs[i])begin
			reg_addr = regs[i].get_address();

			// `ifdef PLSIM
			if((reg_addr inside{ REG_SPDLOG_ADDR, REG_TCLKPD_ADDR
								, REG_SSLOG_ADDR}) ) 
				continue;
			else  do_reg(regs[i]);
		end

	endtask:do_normal_block


	task do_reg(uvm_reg rg);
		uvm_reg_data_t val, exp;
		uvm_reg_addr_t rg_addr;
		uvm_reg_map maps[$];

		rg.get_maps(maps);
		rg_addr = rg.get_address();
		if (this.is_chk(rg))begin
			foreach(maps[k])begin        
				if(rg.has_hdl_path() )  rg.mirror(status,UVM_NO_CHECK , UVM_BACKDOOR,maps[k]);
				else  rg.mirror(status, UVM_NO_CHECK, UVM_FRONTDOOR, maps[k]);
				
				
				get_wr_val_with_mask(rg, val);

				`uvm_info(get_type_name(), $sformatf("Register [\"%s\"] in map [\"%s\"] write val = 'h%0h]", rg.get_full_name(), maps[k].get_full_name(), val), UVM_MEDIUM) 
				rg.write(status, val, UVM_FRONTDOOR, maps[k], this);
				//write end

				if(rg_addr inside { REG_UART_CFG0_ADDR, REG_UART_CFG1_ADDR })begin
					`uvm_info(get_type_name(), $sformatf("Wait HEADER update"), UVM_MEDIUM) 
					#2000ns; 
				end

				wait_x_cycles(2); 
				//mirror use UVM_CHECK
				rg.mirror(status, UVM_CHECK,,maps[k]);

			end
		end
		else begin
			`uvm_info(get_type_name(), $sformatf("Register [\"%s\"] is excluded", rg.get_full_name()), UVM_MEDIUM)
		end

	endtask:do_reg  


	// NOTE: 
	// Donot use the same excluded list with reg_32bits_base_seq
	// For long reg need to be verified
	task add_excluded_reg_list();
		super.add_excluded_reg_list();
		//NOTE: reg_noncebuf, fifo_reg, read back must be read back at one time instead of multiple 32bits
		reg_list[ral.reg_noncebuf.get_name()      ] = ral.work.reg_noncebuf;   
	endtask:add_excluded_reg_list  


	virtual function bit is_chk(uvm_reg rg);
		if ((!reg_list.exists(rg.get_name())) && (!reg_W1C_list.exists(rg.get_name()) ))
		return 1;
		else return 0;
	endfunction:is_chk


	task set_no_chk();
		super.set_no_chk();
		`ifdef PL_SIM      	
			  ral.speed.reg_pllcnt0.reg_gated_cnt.set_compare(UVM_NO_CHECK);
		`endif
	endtask: set_no_chk

  	// get wr_val with mask
  	task get_wr_val_with_mask(input  uvm_reg target,
                             output uvm_reg_data_t wr_val);
		uvm_reg_addr_t rg_addr;
		string target_name;

		rg_addr = target.get_address();
		target_name = target.get_name();

		wr_val = get_random_data();
		wr_val &= (1<<target.get_n_bits()) -1;
		
		case(rg_addr)
			REG_SELFVEC_AGING_CTRL_ADDR: begin
				wr_val[0] = 0;
				`uvm_info(get_type_name(), $sformatf("[%s] detected! Do not enable self aging", target_name), UVM_MEDIUM)
			end

			`ifdef PL_SIM
				REG_PLL_COM_CFG_ADDR: 
				begin
					wr_val[19:16] = 'h8; // xclk_div_num = 8
					`uvm_info(get_type_name(), $sformatf("[%s] detected! config pll related",target_name), UVM_MEDIUM)
				end  
			`endif        

			REG_SS_CTRL_ADDR:begin
				wr_val[3] = 1;
				`uvm_info(get_type_name(), $sformatf("reg_ss_ctrl detected! set glbsetvld = 1"), UVM_MEDIUM)
			end
			REG_MUX_ADDR: begin
				wr_val[24:21] = $urandom_range(1,4)<<1;
				wr_val[29:25] = $urandom_range(3,8)<<1;
				`uvm_info(get_type_name(), $sformatf("[%s] detected! config pll related",target_name), UVM_MEDIUM)
        wr_val[5] = 1;
          `uvm_info(get_type_name(), $sformatf("[%s] detected!set efuse xclk gate = 0",target_name), UVM_MEDIUM)   
			end

      //REG_PLL0H_ADDR, REG_PLL1H_ADDR, REG_PLL2H_ADDR, REG_PLL3H_ADDR: begin
      //  wr_val[6] = 0;      //  AFC_ENB = 0
      //  wr_val[21:12] = 0;  //  RSEL = 0
      //  `uvm_info(get_type_name(), $sformatf("[%s] detected! Disable AFC_ENA, rsel = 0 ",target_name), UVM_MEDIUM)
      //end
			REG_RI_ENABLE_ADDR:begin
				wr_val[0] = 0;
				`uvm_info(get_type_name(), $sformatf("[%s] detected!set ri_functoin_pre = 0",target_name), UVM_MEDIUM)
			end
			REG_CORE_CFG_ADDR:begin
				wr_val[16] = 0;
				`uvm_info(get_type_name(), $sformatf("[%s] detected!set corerw = 0",target_name), UVM_MEDIUM)
			end
			default : `uvm_info(get_type_name(), $sformatf("No extra operation,PS:this is mirror time!!!!"), UVM_MEDIUM)
		endcase
	endtask:get_wr_val_with_mask

endclass: reg_32bits_jlm_seq 


//-----------------------------------------------------------------------
// implement uvm built_in seq: uvm_reg_single_access_bash_seq / uvm_reg_access_seq
// check the backdoor path
//-----------------------------------------------------------------------
class reg_access_seq extends reg_base_seq;  
  // ------------------------------------------------------------------
  // BUILT-IN sequence:
  // will reset the block, cannot be used in BTC chip
  //-------------------------------------------------------------------
  //protected uvm_reg_access_seq reg_access_seq;
  uvm_reg_single_access_seq reg_single_access_seq;
  uvm_reg_field special_fds[$];
  uvm_reg no_access_rgs[$];
  uvm_reg non_RW_access_rgs[$];

   `uvm_object_utils(reg_access_seq)

   function new(string name="reg_access_seq");
      super.new(name);
   endfunction : new

  task pre_body();
     super.pre_body();      
     set_fds_no_check();
     set_rgs_no_access();
  endtask

  task body();
    super.body();
    `uvm_info(get_full_name(), "reg_access_seq start", UVM_MEDIUM)

    rst_vif.checks_enable = 1'b1; //Jerry add, close stage3__pin_ri_check
    
    set_wait_for_reset();
    //switch_clk(0);
  
    //-------------------------------------------
    // check all reg by implement uvm_reg_access_seq
    //-------------------------------------------
    //-------------------------------------------
     // disable uart clock gating 
    //-------------------------------------------
    uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.comm_interface.tp_sel", 'b1);
    single_backdoor_path_check(ral.work);    
    single_backdoor_path_check(ral.speed);  //reg_spd,   
    single_backdoor_path_check(ral.comm);     //skipping RO reg 
    single_backdoor_path_check(ral.pvt);     //skipping RO reg 
    efuse_clk_enable();
    single_backdoor_path_check(ral.efuse);    //p    
    single_backdoor_path_check(ral.crg);    //the last one to check


    //-------------------------------------------
    // check non RW field
    //-------------------------------------------
    set_wait_for_reset();
   
    check_non_RW_access(ral.work);
    check_non_RW_access(ral.speed);    
    check_non_RW_access(ral.pvt);
    efuse_clk_enable();
    check_non_RW_access(ral.efuse);
    check_non_RW_access(ral.comm);
    check_non_RW_access(ral.crg);

    `uvm_info(get_full_name(), "reg_access_seq end", UVM_MEDIUM)
  endtask


  task add_special_fds_list();
    // verified in task:  check_non_RW_access 
    // efuse, change within one cycle
    // 1, burn_off
    // 2, sense_rdy
    special_fds.push_back(ral.crg.reg_ri_enable.reg_pin_ri);            //RO pin_ri = REG_ri_function | pad_ri_sync
    special_fds.push_back(ral.crg.reg_ri_enable.reg_ri_function);       //RO ri_function =  (~ri_rst_n) | ri_function_pre      
  endtask:add_special_fds_list


  task set_fds_no_check();
    add_special_fds_list();
    foreach(special_fds[i])begin
      special_fds[i].set_compare(UVM_NO_CHECK);
      `uvm_info(get_full_name(), $sformatf("Set field [%s] UVM_NO_CHECK", special_fds[i].get_full_name()), UVM_MEDIUM)
    end
  endtask:set_fds_no_check


  // --------------------------------------------------------
  // regs will change by itself
  // --------------------------------------------------------
  task set_rgs_no_access();
    uvm_reg_field fds_tmp[$];

    no_access_rgs.push_back(ral.work.project_id);   
    no_access_rgs.push_back(ral.comm.reg_fpga_tag_id);   //FPGA_SYN only

    //verified in reg_access_fiforeg_seq
    no_access_rgs.push_back(ral.reg_spd);       //fifo RW reg
    no_access_rgs.push_back(ral.reg_spdcore);   //fifo RO reg
    //efuse no rw reg
    no_access_rgs.push_back(ral.efuse.reg_efuse_ctrl);   //fifo RO reg
    no_access_rgs.push_back(ral.comm.reg_uart_rdfsm_cfg);   //part RO reg

    //no_access_rgs.push_back(ral.speed.reg_spdlog);    //TODO
    //no_access_rgs.push_back(ral.speed.reg_tclkpd);   //fifo reg
    //no_access_rgs.push_back(ral.speed.reg_sslog);   

    foreach(no_access_rgs[i])begin
      	uvm_resource_db#(bit)::set({"REG::",no_access_rgs[i].get_full_name()}, "NO_REG_ACCESS_TEST", 1, this);
    end
    // --------------------------------------------------------
    // implement check_non_RW_access task but built-in seq
    // --------------------------------------------------------
    ral.get_fields(fds_tmp);
    foreach (fds_tmp[i])begin
      	if(fds_tmp[i].get_access() == "W1C") begin
        	non_RW_access_rgs.push_back(fds_tmp[i].get_parent());        //non_RW
        end
    end

    foreach(non_RW_access_rgs[i])begin
      	uvm_resource_db#(bit)::set({"REG::",non_RW_access_rgs[i].get_full_name()}, "NO_REG_ACCESS_TEST", 1, this);
    end

  endtask: set_rgs_no_access


  	task check_non_RW_access(uvm_reg_block blk);   
  
    		if( (blk.get_name().substr(0,2) !=  "mx2") && ( !(blk.get_name() inside { "lvro_inst","lvro_master"}))) begin
			uvm_reg rg[$];
			uvm_reg_data_t rd_val;
			uvm_reg_data_t access_mask;
			
			blk.get_registers(rg);
			foreach(rg[m])begin 
				uvm_reg_map mp[$];    
				uvm_reg_field fd[$];
				//no_access_rg cannot be access
				if(!is_chk_non_RW(rg[m])) 
					continue;

				rg[m].get_maps(mp);
				rg[m].get_fields(fd);
				foreach(mp[i])begin
					foreach(fd[k])begin
						uvm_reg_data_t access_mask;
						string fd_access,fd_name;
						//string fd_name_sub_3, fd_name_sub_10, fd_name_sub_12;
						bit [`UVM_REG_DATA_WIDTH-1:0] lsb, n_bits, l;

						fd_name = fd[k].get_name();

						//str.substr(i,j) will return sub string btw [j:i] 
						//sv doesn't support slicing, eg.fd_name[0:2]

						// NOTE:
						// 1, reg_speed_dfx.reg_th_timeout_of will return to 0 whthin one cycle
						// 3, reg_pll1_afc_code,  
						// 4, rst.reg_ri_enable.reg_pin_ri, only last only one cycle  
						// 5, reg_freq_sum_rdy RC
						if( fd_name.substr(0,2) == "rfu"  ||  

              						//fd_name.substr(0,9) == "reg_th_tim" ||
							fd_name.substr(9,16) == "afc_code"   || 
							fd_name.substr(0,15) == "reg_freq_sum_rdy"
							//fd_name_sub_10 == "reg_pin_ri"
							) begin
							`uvm_info(get_type_name(), $sformatf("[%s] is rfu or special type field", fd[k].get_full_name()), UVM_MEDIUM)
							continue;
						end

						lsb = fd[k].get_lsb_pos();
						n_bits = fd[k].get_n_bits();

						// get field access mask
						for( l =lsb; l<lsb+ n_bits; l++)begin
							access_mask[l] = 1;
						end
						
						fd_access = fd[k].get_access();
						case(fd_access)
							"W1T", "RC":  // will be conflict with assetion
								begin
									W1T_backdoor_check(fd[k], access_mask);
								end
							"RO", "W1C":
							// W1C will clear only pwdata[0] = 1,
							// poke will not trigger clear all
								begin
									RO_W1C_backdoor_check(fd[k], access_mask);
								end
							"RW":`uvm_info(get_type_name(), $sformatf("[\"%s\" type] no need test in field [\"%s\"]!", fd_access, fd[k].get_full_name()), UVM_MEDIUM)
							default:`uvm_error(get_type_name(), $sformatf("[ERR] \"%s\" unknow field access type!", fd_access))
							
						endcase
					end
				end
			end
		end
  	endtask:check_non_RW_access

  function bit is_chk_non_RW(uvm_reg rg);
    foreach(no_access_rgs[h]) begin
      if( (rg.get_name() == no_access_rgs[h].get_name()) ||  (rg.get_name() == "reg_speed_ovf_bitmap") ) begin
        `uvm_info(get_type_name(), $sformatf("[%s] is  special type reg", rg.get_full_name()), UVM_MEDIUM)
        return 0;
      end
    end
    return 1;
    
  endfunction 


   task W1T_backdoor_check(uvm_reg_field fd ,//fd_name
                          uvm_reg_data_t  access_mask );

    //empty, no need
  endtask:W1T_backdoor_check 


	// NOTE: 
	// 1, REG_PLL0_LOCK_IP/REG_PLL0_LOCK,REG_PLL1_LOCK_IP/REG_PLL1_LOCK, REG_PLL2_LOCK_IP/REG_PLL2,_LOCK, REG_PLL3_LOCK_IP/REG_PLL3_LOCK
	//    apb bus write in crg_regfile, but cdc operation inside dut
	// 2, reg_spdcore_ovf_bitmap
	//    last only one cycle
	task RO_W1C_backdoor_check( uvm_reg_field   fd,  //fd_name
									uvm_reg_data_t  access_mask );
		uvm_reg_data_t poke_val, rd_val;
		bit [`UVM_REG_DATA_WIDTH-1:0] n_bits;
		bit [1:0] sslog_sel;
		
		`uvm_info(get_type_name(), $sformatf("FIELD [%s] is under test", fd.get_full_name()), UVM_MEDIUM)
		n_bits = fd.get_n_bits();
		wait_cycles(1);
		// execute reg.mirror, BACKDOOR-<peek>, FRONTDOOR-<read>
		fd.mirror(status,UVM_NO_CHECK, UVM_BACKDOOR ,null);
		poke_val = ~fd.get();
		
		poke_val &= ((1<<fd.get_n_bits())-1);

        // Avoid have free bits for high bits, which need to be commented out here
		////NOTE: nouse, [511:508] = 0
		//if(fd.get_name() == "reg_spdcore")begin
		//	poke_val[`SPD_LEN-1:(`DESIGN_CORE_NUM+`TINY_CORE_NUM)*4] = 0;
		//end
		//poke_val &= ((1<<f.get_n_bits())-1);
		//rw.value[0] = (value >> f.get_lsb_pos()) & ((1<<f.get_n_bits())-1);

		if(fd.get_name() == "reg_sslog")begin
			void'(std::randomize(sslog_sel) with {sslog_sel inside {2'b01} ;} );
			`uvm_info(get_type_name(), $sformatf("sslog detected ! sslog_sel = %b", sslog_sel), UVM_MEDIUM)
			
			uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.ss_adaptive_en", sslog_sel[0]);  
			ral.reg_sslog.add_hdl_path_slice("speed.adaptive_log",0,32*((`DESIGN_CORE_NUM+1)/2));  
		end


		fd.poke(status, poke_val);
		`uvm_info(get_full_name(), $sformatf("[%s] poke_val='h%0h", 
											fd.get_full_name(), poke_val), UVM_MEDIUM)

		// parent.mirror
		fd.mirror(status,UVM_CHECK, UVM_FRONTDOOR ,null);

	endtask:RO_W1C_backdoor_check

 
	task single_backdoor_path_check(uvm_reg_block blk);

		if( (blk.get_name().substr(0,2) !=  "mx2") &&( ! (blk.get_name() inside { "lvro_master", "lvro_inst"}))) begin

			uvm_reg rgs[$];  
			blk.get_registers(rgs, UVM_NO_HIER); 
			reg_single_access_seq= uvm_reg_single_access_seq::type_id::create("reg_single_access_seq");
			foreach(rgs[j])begin
				uvm_reg_data_t  v, exp;

				`uvm_info(get_type_name(), $sformatf("Verifing access of REG [%s]", rgs[j].get_name()), UVM_MEDIUM)
				rgs[j].mirror(status, UVM_NO_CHECK, UVM_BACKDOOR, , this);
				reg_single_access_seq.rg = rgs[j];
				reg_single_access_seq.start(null,this);

				wait_cycles(2);
			end
		end

		begin 
			uvm_reg_block sub_blks[$];
			blk.get_blocks(sub_blks, UVM_HIER);
			foreach(sub_blks[i])begin
				single_backdoor_path_check(sub_blks[i]);
			end
		end
  	endtask:single_backdoor_path_check
  
endclass: reg_access_seq


//-----------------------------------------------------------------------
// roctrl block
// implement uvm built_in seq: uvm_reg_single_access_bash_seq / uvm_reg_access_seq
// check the backdoor path
//-----------------------------------------------------------------------
class reg_access_roctrl_seq extends reg_base_seq;  
   `uvm_object_utils(reg_access_roctrl_seq)

   function new(string name="reg_access_roctrl_seq");
      super.new(name);
   endfunction : new

  task pre_body();
     super.pre_body();
  endtask
  task body();
    super.body();    
    
    switch_clk(0);
    this.roctrl_rst();

    roctrl_check(ral.lvro_inst);      //
    roctrl_check(ral.lvro_master);      //
    //roctrl_check(ral.hvro_inst);      //
    
  endtask:body


  task roctrl_check(uvm_reg_block blk);
      uvm_reg rgs[$];
      
      blk.get_registers(rgs, UVM_NO_HIER); 
      
      foreach(rgs[j])begin
        `uvm_info(get_type_name(), $sformatf("Verifing access of REG [%s]", rgs[j].get_name()), UVM_MEDIUM)

        rgs[j].mirror(status, UVM_NO_CHECK, UVM_BACKDOOR, , this);
        backdoor_path(rgs[j]);
        roctrl_non_RW_check(rgs[j]);      
        wait_x_cycles(2);
      end
  endtask:roctrl_check
  

  // check RW field
  task backdoor_path(uvm_reg rg);
    bit [31:0] init_val, val, exp;
    bit [31:0] ro_mask;
    int ro;
    // mark the number of RO field 

    uvm_reg_field fds[$];
    rg.get_fields(fds);

    foreach(fds[m])begin
      if(fds[m].get_access() == "RO")
        ro++;
    end

    if (ro == fds.size()) begin
      `uvm_warning("uvm_reg_access_seq", {"Register '",
                rg.get_full_name(),"' has only RO fields , skipping"})
                return;
    end
    //get roctrl reg msk
    get_roctrl_mask(rg.get_name(), ro_mask);

    init_val = rg.get();

    // frontdoor_2_backdoor
    wait_x_cycles(200);
    rg.write(status, ~init_val, UVM_FRONTDOOR, , this);
    wait_x_cycles(200);
    rg.read(status, exp,UVM_BACKDOOR,, this)  ;  
    
    val = (~init_val) & ro_mask;
    exp &= ro_mask;
    if (val === exp)  
      `uvm_info(get_type_name(), $sformatf("frontdoor_2_backdoor [\"%s\"],Write val:'h%0h === exp:'h%0h", rg.get_full_name(), val, exp), UVM_MEDIUM)
    else  
      `uvm_error(get_type_name(), $sformatf("frontdoor_2_backdoor [\"%s\"],Write val:'h%0h !== exp:'h%0h", rg.get_full_name(),val, exp));

    // backdoor_2_frontdoor 
    wait_x_cycles(200);
    rg.write(status, init_val, UVM_BACKDOOR, , this);
    rg.mirror(status, UVM_NO_CHECK, UVM_FRONTDOOR, , this);
    wait_x_cycles(200);

    rg.mirror(status, UVM_NO_CHECK, UVM_FRONTDOOR, , this);
    wait_x_cycles(200);
    rg.read(status, exp,UVM_FRONTDOOR, , this);

    val = (init_val) & ro_mask;
    exp &= ro_mask;
    if (val === exp)  
      `uvm_info(get_type_name(), $sformatf("backdoor_2_frontdoor [\"%s\"],Write val:'h%0h === exp:'h%0h", rg.get_full_name(), val, exp), UVM_MEDIUM)
    else  
      `uvm_error(get_type_name(), $sformatf("backdoor_2_frontdoor [\"%s\"],Write val:'h%0h !== exp:'h%0h", rg.get_full_name(),val, exp));
  endtask:backdoor_path


  // ---------------------------------------------
  // check non RW field
  task roctrl_non_RW_check(uvm_reg rg);      
    uvm_reg_map mp[$];    
    uvm_reg_field fd[$];
    //no_access_rg cannot be access
    rg.get_maps(mp);
    rg.get_fields(fd);
    foreach(mp[i])begin
      foreach(fd[k])begin
        uvm_reg_data_t access_mask;
        string fd_access,fd_name;
        bit [`UVM_REG_DATA_WIDTH-1:0] lsb, n_bits, l;

      fd_name = fd[k].get_name();


      if( fd_name.substr(0,2) == "rfu")begin
        `uvm_info(get_type_name(), $sformatf("[%s] is rfu or special type field", fd[k].get_full_name()), UVM_MEDIUM)
        continue;
      end

        lsb = fd[k].get_lsb_pos();
        n_bits = fd[k].get_n_bits();

        // get field access mask
        for( l =lsb; l<lsb+ n_bits; l++)begin
          access_mask[l] = 1;
        end
        
        fd_access = fd[k].get_access();
        case(fd_access)
          "RO":
            begin
              RO_backdoor_check(fd[k], access_mask);
            end
          "RW", "W1T":`uvm_info(get_type_name(), $sformatf("[\"%s\" type] no need test in field [\"%s\"]!", fd_access, fd[k].get_full_name()), UVM_MEDIUM)
          default:`uvm_error(get_type_name(), $sformatf("[ERR] \"%s\" unknow field access type!", fd_access))
        endcase
      end
    end
  endtask:roctrl_non_RW_check
  
  
  task RO_backdoor_check( uvm_reg_field   fd,  //fd_name
                          uvm_reg_data_t  access_mask );
    uvm_reg_data_t poke_val, rd_val;
    uvm_reg rg_parent;
    //rg_parent = fd.get_parent();

    `uvm_info(get_type_name(), $sformatf("FIELD [%s] is under test", fd.get_full_name()), UVM_MEDIUM)
    
    wait_x_cycles(100);
    // no need mirror, for already update with dut
    poke_val = ~fd.get();
    poke_val &= ((1<<fd.get_n_bits())-1);
    fd.poke(status, poke_val);
    `uvm_info(get_full_name(), $sformatf("[%s] poke_val='h%0h", 
                                          fd.get_full_name(), poke_val), UVM_MEDIUM)
    
    wait_x_cycles(100);
    fd.mirror(status, UVM_NO_CHECK, UVM_FRONTDOOR, , this);
    wait_x_cycles(100);
    fd.read(status, rd_val, UVM_FRONTDOOR, , this);
    
    `uvm_info(get_full_name(), $sformatf("access_mask = 'h%0h", access_mask), UVM_MEDIUM)
    poke_val &= access_mask;
    rd_val &= access_mask;

    if(rd_val == poke_val)
      `uvm_info(get_full_name(), $sformatf("[%s SUCC] poke_val = rd_val = 'h%0h", 
                fd.get_full_name(), poke_val ), UVM_MEDIUM)
    else
      `uvm_error(get_full_name(), $sformatf("[%s ERR] poke_val:'h%0h != rd_val:'h%0h", 
                  fd.get_full_name(), poke_val, rd_val ))
  endtask:RO_backdoor_check
  

endclass: reg_access_roctrl_seq 


//-----------------------------------------------------------------------
// fifo RO reg, access check
// poke then read back using jamlink or uart 
// reg_sslog, reg_spdcore, reg_tclkpd, reg_spdlog, 
//-----------------------------------------------------------------------
class reg_access_fiforeg_seq extends reg_base_seq;  
   `uvm_object_utils(reg_access_fiforeg_seq)

   function new(string name="reg_access_fiforeg_seq");
      super.new(name);
   endfunction : new

  task pre_body();
     super.pre_body();
  endtask

  task body();
    super.body();    
    `uvm_info(get_full_name(), "reg_access_fiforeg_seq start", UVM_MEDIUM)
  
  `ifdef USE_JAMLINK_DRV
    `uvm_info(get_type_name(), "[JAMLINK] init start", UVM_MEDIUM);    
    //set jlm clk frequency division factor = 2
    jlm_reg_wr(32'h14, 32'h0_0002);
    #1000ns;
    initRst();
    wrc_cpm_pll_x(0);
    `uvm_info(get_type_name(), "[JAMLINK] init end", UVM_MEDIUM); 
  `elsif USE_UART_DRV
    initRst();
  `endif   

    fiforeg_backdoor_wr_check();  
    fiforeg_force_wr_check();      

    `uvm_info(get_full_name(), "reg_access_fiforeg_seq end", UVM_MEDIUM)
    
  endtask:body
  

  task  fiforeg_backdoor_wr_check();
    uvm_reg targets[$];
    uvm_reg_data_t init_val;
    uvm_reg target;


    //-----------------------------------------------------------------------
    //reg_sslog 
    //-----------------------------------------------------------------------
    uvm_hdl_force("tb_top.C[0].btnode.btc.sys_ctrl.speed.ss_adaptive_en", 1'b1);
    ral.reg_sslog.add_hdl_path_slice("speed.adaptive_log",0,32*((`DESIGN_CORE_NUM+1)/2));; 
    single_field_backdoor_check(ral.reg_sslog.reg_sslog);

    //-----------------------------------------------------------------------
    //reg_spd, 
    //reg_spdcore 
    //reg_selfclk_roenb
    //reg_tclkpd 
    //-----------------------------------------------------------------------
    targets.push_back(ral.reg_spd);     //'RW'
    targets.push_back(ral.reg_spdcore);
    //targets.push_back(ral.reg_selfclk_roenb);
    targets.push_back(ral.reg_tclkpd);
    foreach(targets[i])begin
      uvm_reg_field fds[$];

      targets[i].get_fields(fds);
      foreach(fds[m])begin
         single_field_backdoor_check(fds[m]);
      end
    end
  endtask:fiforeg_backdoor_wr_check

  task single_field_backdoor_check(input uvm_reg_field fd);
    uvm_reg_data_t poke_val;
    uvm_reg_data_t rd_data;

    `uvm_info(get_type_name(), $sformatf("FIELD [%s] is under test", fd.get_full_name()), UVM_MEDIUM)
    
     fd.mirror(status,UVM_NO_CHECK, UVM_BACKDOOR ,null);//update RAL MODEL
     poke_val = ~fd.get();
     poke_val &= ((1<<fd.get_n_bits())-1);
     
    // avoid have free bits for high bits, which need to be commented out here
    ////NOTE: nouse, [511:508] = 0
    // if(fd.get_name() == "reg_spdcore")begin
    //   poke_val[`SPD_LEN-1:(`DESIGN_CORE_NUM+`TINY_CORE_NUM)*4] = 0;
    // end
     
     fd.poke(status, poke_val);
     `uvm_info(get_full_name(), $sformatf("[%s] poke_val='h%0h", 
                                fd.get_full_name(), poke_val), UVM_MEDIUM)
     fd.mirror(status,UVM_CHECK, UVM_FRONTDOOR ,null);
  endtask:single_field_backdoor_check


  task fiforeg_force_wr_check();
    uvm_reg_data_t force_data;
    uvm_reg_data_t rd_data, exp;
    uvm_btc_reg targets[$];
    //bit [31:0] force_data[uvm_btc_reg];
    int len;
    string s;
    
    targets.push_back(ral.reg_spdlog);

    force_data = get_random_data();
    force_data &=  ( (1 << `DESIGN_CORE_NUM*32) - 1) ;
    for (int i =0; i<`DESIGN_CORE_NUM; i=i+1) begin
      uvm_hdl_force($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.REG_SpdLog[31:0]",i ), force_data[32*i +: 32]);
      `uvm_info(get_full_name(), $sformatf("[%0d] force_data:'h%0h ", i,force_data[i+:32]), UVM_MEDIUM)
    end

    foreach(targets[i])begin
      len = targets[i].get_n_bits()/32;
      targets[i].rd(rd_data);
      s = "";
      s = {s, $sformatf("\n|- %s", targets[i].get_full_name()             ) };
      s = {s, $sformatf("\n|- rd_data: 'h%0h", rd_data                    ) };
      s = {s, $sformatf("\n|- force_data: 'h%0h", force_data  ) };

      if(rd_data == force_data)
        `uvm_info(get_full_name(), $sformatf("%s", s), UVM_MEDIUM)
      else
        `uvm_error(get_full_name(), $sformatf("%s", s))
    end

  endtask:fiforeg_force_wr_check

endclass:reg_access_fiforeg_seq


//-----------------------------------------------------------------------
// soft reset check
// pullup pad_ri, and then config top_reg
// check the reset flow of actual scenario 
// NOTE: 
// 1, efuse is under rst state when pad_ri is pulled up
// 2, should not use reg_32bits_test for it will write rst reg,
//-----------------------------------------------------------------------
class reg_pad_ri_seq extends reg_base_seq;
  logic pad_ri;

   `uvm_object_utils(reg_pad_ri_seq)

   function new(string name="reg_pad_ri_seq");
      super.new(name);
   endfunction : new

  task pre_body();
     super.pre_body();
  endtask
  task body();
    super.body();
    `uvm_info(get_full_name(), "reg_pad_ri_seq start", UVM_MEDIUM)

    //drive pad_ri = "1" on IO_PAD 
    #1666ns;
    uvm_hdl_force("tb_top.C[0].btnode.btc.DO_RI", 1'b1);

    // not sure is mid_clk generated already
    //wait_cycles(2);
    repeat(2) @(posedge reg_vif.xclk);
    uvm_hdl_read("tb_top.C[0].btnode.btc.sys_ctrl.crg.pad_ri", pad_ri);
    `uvm_info(get_type_name(), $sformatf("[PAD_RI] = 'h%h", pad_ri), UVM_MEDIUM)
    if (~pad_ri)
    	`uvm_error(get_type_name(), $sformatf("\n[ERR] %s \n", pad_ri))

    //wait_cycles(30);
    repeat(25) @(posedge reg_vif.xclk);
    uvm_hdl_read("tb_top.C[0].btnode.btc.sys_ctrl.crg.pad_ri", pad_ri);
    `uvm_info(get_type_name(), $sformatf("[PAD_RI] = 'h%h", pad_ri), UVM_MEDIUM)
    if (~pad_ri)
    `uvm_error(get_type_name(), $sformatf("\n[ERR] %s \n", pad_ri))
    
    repeat(25) @(posedge reg_vif.xclk);    
    check_pad_ri_rst();
    `uvm_info(get_full_name(), "reg_pad_ri_seq end", UVM_MEDIUM)
  endtask:body
    

  task  check_pad_ri_rst();
    uvm_reg targets[$];
    uvm_reg_data_t wr_data;
    
    targets.push_back(ral.pvt.reg_tvsenw); // ri_rst_f_n control
    targets.push_back(ral.work.reg_cg_en); // mid_rst_n control
    foreach(targets[i])begin
      wr_data = get_random_data();
      `uvm_info(get_full_name(), $sformatf("REG [%s] is under test, write wr_data = 'h%0h ", targets[i].get_name(), wr_data[31:0]), UVM_MEDIUM)
      targets[i].mirror(status, UVM_NO_CHECK);
      targets[i].write(status, wr_data, UVM_FRONTDOOR, null, this);
      targets[i].mirror(status, UVM_CHECK);
      targets[i].write(status, ~wr_data, UVM_FRONTDOOR, null, this);
      targets[i].mirror(status, UVM_CHECK);
    end
    
  endtask:check_pad_ri_rst

endclass: reg_pad_ri_seq 


//-----------------------------------------------------------------------
// eco reg check 
// NOTE: 
// 1, efuse is under rst state when pad_ri is pulled up
// 2, should not use reg_32bits_test for it will write rst reg,
//-----------------------------------------------------------------------
class reg_access_eco_seq extends reg_base_seq;
  uvm_reg eco_rgs[$];

   `uvm_object_utils(reg_access_eco_seq)

   function new(string name="reg_access_eco_seq");
      super.new(name);
   endfunction : new

  task pre_body();
     super.pre_body();
  endtask

  task body();
    super.body();
    `uvm_info(get_full_name(), "reg_access_eco_seq start", UVM_MEDIUM)
    
    set_wait_for_reset();
    ral.reg_cg_en.reg_ro_cg_en.set(0);
    ral.reg_cg_en.update(status);
    get_ecoreg();
    ecoreg_access_chk();

    `uvm_info(get_full_name(), "reg_access_eco_seq finish", UVM_MEDIUM)
  endtask:body

  task get_ecoreg();
    eco_rgs.push_back(ral.reg_work_ctrl_rfu);
    eco_rgs.push_back(ral.reg_mx2_bridge_rfu);
    eco_rgs.push_back(ral.reg_speed_rfu);
    eco_rgs.push_back(ral.reg_cpm_rfu);
    eco_rgs.push_back(ral.reg_lvro_rfu);
    eco_rgs.push_back(ral.reg_comm_interface_rfu);
    eco_rgs.push_back(ral.reg_rst_rfu);


    // --------------------------------------------------------------------------------------
    // top
    // --------------------------------------------------------------------------------------
		//ral.reg_work_ctrl_rfu.add_hdl_path_slice("work_ctrl.REG_work_eco_rw1",0,1);
		//ral.reg_work_ctrl_rfu.add_hdl_path_slice("work_ctrl.REG_work_eco_rw2",1,1);
		//ral.reg_work_ctrl_rfu.add_hdl_path_slice("work_ctrl.REG_work_eco_rw3",2,1);
		//ral.reg_work_ctrl_rfu.add_hdl_path_slice("work_ctrl.REG_work_eco_rw4",3,1);
		//ral.reg_work_ctrl_rfu.add_hdl_path_slice("work_ctrl.REG_work_eco_rw5",4,4);
		//ral.reg_work_ctrl_rfu.add_hdl_path_slice("work_ctrl.REG_work_eco_rw6",8,4);
		//ral.reg_work_ctrl_rfu.add_hdl_path_slice("work_ctrl.REG_work_eco_rw7",12,4);
		//ral.reg_work_ctrl_rfu.add_hdl_path_slice("work_ctrl.REG_work_eco_rw8",16,4);

    //ral.reg_mx2_bridge_rfu.add_hdl_path_slice("mx2_bridge.REG_mx2_bridge_rfu",0,32);
    ////ral.reg_speed_rfu.add_hdl_path_slice("speed.",0,1);
    //ral.reg_cpm_rfu.add_hdl_path_slice("cpm.REG_cpm_rfu",0,32);
    //ral.reg_rst_rfu.add_hdl_path_slice("rst.REG_rst_eco",0,32);
    //ral.reg_comm_interface_rfu.add_hdl_path_slice("comm_interface.REG_comm_interface_rfu",0,32);


    ral.reg_lvro_rfu.add_hdl_path_slice("sys_ctrl.lvro_master_ctrl.REG_lvro_eco_rw1",0,1);
    ral.reg_lvro_rfu.add_hdl_path_slice("sys_ctrl.lvro_master_ctrl.REG_lvro_eco_rw2",1,1);
    ral.reg_lvro_rfu.add_hdl_path_slice("sys_ctrl.lvro_master_ctrl.REG_lvro_eco_rw3",2,4);
    ral.reg_lvro_rfu.add_hdl_path_slice("sys_ctrl.lvro_master_ctrl.REG_lvro_eco_rw4",6,4);

    // --------------------------------------------------------------------------------------
    // buf
    // --------------------------------------------------------------------------------------
    ///1, work_ctrl: rw1, rw2, rw3, rw4
    for(int i = 0; i<4; i++)begin
		  ral.reg_work_ctrl_rfu.add_hdl_path_slice($sformatf("work_ctrl.eco_work_eco_rw%0d.Y",i+1), i, 1);
    end
    //1, work_ctrl: rw5, rw6, rw7, rw8, 4bit
    for(int i = 0; i<3; i++)begin
      //tb_top.C[0].btnode.btc.sys_ctrl.work_ctrl.genblk7[1].eco_work_eco_rw5
      ral.reg_work_ctrl_rfu.add_hdl_path_slice($sformatf("work_ctrl.GEN_WORK_CTRL_MULTI_BIT_ECO_BUF[%0d].eco_work_eco_rw5.Y",i), i+4 , 1);
      ral.reg_work_ctrl_rfu.add_hdl_path_slice($sformatf("work_ctrl.GEN_WORK_CTRL_MULTI_BIT_ECO_BUF[%0d].eco_work_eco_rw6.Y",i), i+8 , 1);
      ral.reg_work_ctrl_rfu.add_hdl_path_slice($sformatf("work_ctrl.GEN_WORK_CTRL_MULTI_BIT_ECO_BUF[%0d].eco_work_eco_rw7.Y",i), i+12, 1);
      ral.reg_work_ctrl_rfu.add_hdl_path_slice($sformatf("work_ctrl.GEN_WORK_CTRL_MULTI_BIT_ECO_BUF[%0d].eco_work_eco_rw8.Y",i), i+16, 1);
    end
    //2, mx2 bridge
    for(int i = 0; i<10; i++)begin
      ral.reg_mx2_bridge_rfu.add_hdl_path_slice($sformatf("mx2_bridge.GEN_MX2_BRIDGE_ECO_BUF_L[%0d].eco_mx2_bridge_buf_l.Y", i), i, 1) ;
    end

    //3, speed
    for(int i = 0; i<20; i++)begin
      ral.reg_speed_rfu.add_hdl_path_slice($sformatf("speed.GEN_SPEED_ECO_BUF_L[%0d].eco_speed_buf_l.Y",i), i, 1) ;
    end

    //4, cpm
    for(int i = 0; i<20; i++)begin
      ral.reg_cpm_rfu.add_hdl_path_slice($sformatf("crg.GEN_CPM_ECO_BUF_L[%0d].eco_cpm_buf_l.Y",i), i, 1) ;
    end
    
    
    //5,6, lvro & hvro: rw1, rw2
    for(int i = 0; i<2; i++)begin
		 ral.reg_lvro_rfu.add_hdl_path_slice($sformatf("sys_ctrl.lvro_master_ctrl.eco_lvro_buf_rw%0d.Y", i+1), i,1) ;
    end
    //5,6, lvro & hvro: rw3, rw
    for(int i = 0; i<3; i++)begin
     ral.reg_lvro_rfu.add_hdl_path_slice($sformatf("sys_ctrl.lvro_master_ctrl.GEN_LVRO_ECO_BUF_RW34[%0d].eco_lvro_buf_rw3.Y",i), i+2, 1);
     ral.reg_lvro_rfu.add_hdl_path_slice($sformatf("sys_ctrl.lvro_master_ctrl.GEN_LVRO_ECO_BUF_RW34[%0d].eco_lvro_buf_rw4.Y",i), i+6, 1);
    end

    //7, comm_interface
    for(int i = 0; i<10; i++)begin
      ral.reg_comm_interface_rfu.add_hdl_path_slice($sformatf("comm_interface.GEN_COMMON_INTERFACE_ECO_BUF_L[%0d].eco_comm_interface_buf_l.Y",i),i,1);
    end

    //8,rst 
    for(int i = 0; i<10; i++)begin
      ral.reg_rst_rfu.add_hdl_path_slice($sformatf("crg.u_crg_rst.GEN_RI_RST_BUF_L[%0d].eco_rst_buf_l.Y",i), i, 1) ;
    end
    
  endtask:get_ecoreg

  task ecoreg_access_chk();
    bit[31:0] wr_val, rd_val;


    `uvm_info(get_full_name(), "eco reg access chk start, front2back ...", UVM_MEDIUM)
    foreach(eco_rgs[i])begin
      wr_val = get_random_data();
      eco_rgs[i].write(status, wr_val, UVM_FRONTDOOR,null, this);
      wait_x_cycles(2);
      eco_rgs[i].mirror(status,UVM_CHECK, UVM_BACKDOOR, null);
    end
  endtask:ecoreg_access_chk

endclass: reg_access_eco_seq 
`endif  // `ifndef REG_SEQ

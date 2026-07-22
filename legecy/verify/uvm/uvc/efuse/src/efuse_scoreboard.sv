
`uvm_analysis_imp_decl(_main_efuse_monitor)
`uvm_analysis_imp_decl(_main_efuse_driver)

`ifdef PL_SIM
	//timing parameter forRead
	`define RD_TSETUP_PD2CS		        	911
	`define RD_THOLD_PD2CS		        	70
	`define RD_TSETUP_PS2CS		        	177
	`define RD_THOLD_PS2CS		        	144
	`define RD_TSETUP_PD2STROBE				978
	`define RD_THOLD_PD2STROBE				183
	`define RD_TSETUP_PS2STROBE				245
	`define RD_THOLD_PS2STROBE				257
	`define RD_TSETUP_RWL2STROBE	        90
	`define RD_THOLD_RWL2STROBE				86
	`define RD_TSETUP_RSB2STROBE	        91
	`define RD_THOLD_RSB2STROBE				87
	`define RD_TSETUP_CS2STROBE	        	68
	`define RD_THOLD_CS2STROBE				114
	`define RD_TSETUP_PGEN2STROBE	        135
	`define RD_THOLD_PGEN2STROBE	        227
	`define RD_TKEEP_STROBE	                245
	`define RD_TKEEP_MARGIN_STROBE	        609
	`define RD_TSETUP_ADDR2STROBE	        41
	`define RD_THOLD_ADDR2STROBE	        50
	`define RD_TSETUP_LOAD2STROBE	        135
	`define RD_THOLD_LOAD2STROBE	        227
	`define RD_TSETUP_MR2STROBE	        	81      
	`define RD_THOLD_MR2STROBE	        	137
	`define RD_TSETUP_TRCS2STROBE	        72
	`define RD_THOLD_TRCS2STROBE	        69
	`define RD_ACCESS_STROBE2Q	        	237
	`define RD_ACCESS_MARGIN_STROBE2Q		602

	`define RD_TSQ	        				`RD_ACCESS_STROBE2Q
	`define RD_TSQ_M						`RD_ACCESS_MARGIN_STROBE2Q
	`define RD_TSQH 						0

	//for write
	`define PGM_TSETUP_PD2PS			911 
	`define PGM_THOLD_PD2PS		        71
	`define PGM_TSETUP_PS2CS			177
	`define PGM_THOLD_PS2CS		        144
	`define PGM_TSETUP_PD2STROBE		1155
	`define PGM_THOLD_PD2STROBE			327
	`define PGM_TSETUP_PS2STROBE		245
	`define PGM_THOLD_PS2STROBE			256
	`define PGM_TSETUP_RWL2STROBE	    90
	`define PGM_THOLD_RWL2STROBE		86
	`define PGM_TSETUP_RSB2STROBE	    91
	`define PGM_THOLD_RSB2STROBE		87
	`define PGM_TSETUP_CS2STROBE	    68
	`define PGM_THOLD_CS2STROBE			114
	`define PGM_TSETUP_PGEN2STROBE	    135
	`define PGM_THOLD_PGEN2STROBE	    227
	`define PGM_TKEEP_STROBE	        5000
	`define PGM_TSETUP_ADDR2STROBE	    41
	`define PGM_THOLD_ADDR2STROBE	    53
	`define PGM_TSETUP_TRCS2STROBE	    72
	`define PGM_THOLD_TRCS2STROBE	    69
	`define PGM_TSETUP_LOAD2STROBE	    135
	`define PGM_THOLD_LOAD2STROBE	    227

`else
	//=======================================
	`define RD_TSETUP_PD2CS		        865
	`define RD_THOLD_PD2CS		        66
	`define RD_TSETUP_PS2CS		        169
	`define RD_THOLD_PS2CS		        135
	`define RD_TSETUP_PD2STROBE		930
	`define RD_THOLD_PD2STROBE		173
	`define RD_TSETUP_PS2STROBE		232
	`define RD_THOLD_PS2STROBE		244
	`define RD_TSETUP_RWL2STROBE	     86
	`define RD_THOLD_RWL2STROBE		81
	`define RD_TSETUP_RSB2STROBE	     87
	`define RD_THOLD_RSB2STROBE		82
	`define RD_TSETUP_CS2STROBE	        65
	`define RD_THOLD_CS2STROBE		108
	`define RD_TSETUP_PGEN2STROBE	        129
	`define RD_THOLD_PGEN2STROBE	        216
	`define RD_TKEEP_STROBE	                232
	`define RD_TKEEP_MARGIN_STROBE	        579
	`define RD_TSETUP_ADDR2STROBE	        39
	`define RD_THOLD_ADDR2STROBE	        47
	`define RD_TSETUP_LOAD2STROBE	        129
	`define RD_THOLD_LOAD2STROBE	        216
	`define RD_TSETUP_MR2STROBE	        77     
	`define RD_THOLD_MR2STROBE	        130
	`define RD_TSETUP_TRCS2STROBE	        69
	`define RD_THOLD_TRCS2STROBE	        65
	`define RD_ACCESS_STROBE2Q	        131
	`define RD_ACCESS_MARGIN_STROBE2Q	334

	`define RD_TSQ	        `RD_ACCESS_STROBE2Q
	`define RD_TSQ_M	`RD_ACCESS_MARGIN_STROBE2Q
	`define RD_TSQH 	0

	//for write
	`define PGM_TSETUP_PD2PS		866 
	`define PGM_THOLD_PD2PS		        67
	`define PGM_TSETUP_PS2CS		168
	`define PGM_THOLD_PS2CS		        136
	`define PGM_TSETUP_PD2STROBE		1098
	`define PGM_THOLD_PD2STROBE		311
	`define PGM_TSETUP_PS2STROBE		233
	`define PGM_THOLD_PS2STROBE		244
	`define PGM_TSETUP_RWL2STROBE	        86
	`define PGM_THOLD_RWL2STROBE		81
	`define PGM_TSETUP_RSB2STROBE	        71
	`define PGM_THOLD_RSB2STROBE		82
	`define PGM_TSETUP_CS2STROBE	        65
	`define PGM_THOLD_CS2STROBE		108
	`define PGM_TSETUP_PGEN2STROBE	        129
	`define PGM_THOLD_PGEN2STROBE	        216
	`define PGM_TKEEP_STROBE	        5000
	`define PGM_TSETUP_ADDR2STROBE	        39
	`define PGM_THOLD_ADDR2STROBE	        50
	`define PGM_TSETUP_TRCS2STROBE	        69
	`define PGM_THOLD_TRCS2STROBE	        65
	`define PGM_TSETUP_LOAD2STROBE	        129
	`define PGM_THOLD_LOAD2STROBE	        216

`endif

class efuse_scoreboard extends uvm_scoreboard;
	logic efuse_array[512];
	logic efuse_read[63:0];
	logic [8:0]ADDR;

  `uvm_component_utils(efuse_scoreboard);
  efuse_item efuse_item_h;
  efuse_sequence_item  efuse_sequence_item_h;
  virtual efuse_if vif;  

  uvm_analysis_imp_main_efuse_monitor #(efuse_item, efuse_scoreboard)  efuse_scoreboard_main_ap;
  uvm_analysis_imp_main_efuse_driver #(efuse_sequence_item, efuse_scoreboard)  efuse_scoreboard_ap;

  function new(string name="efuse_scoreboard" , uvm_component parent=null);
    super.new(name , parent);
  endfunction
 
   function void build_phase(uvm_phase phase);
    super.build_phase(phase);

       efuse_scoreboard_main_ap = new("efuse_scoreboard_main_ap",this);
       efuse_scoreboard_ap = new("efuse_scoreboard_ap",this);
       if(!uvm_config_db#(virtual efuse_if)::get(this , "" , "efuse_vif" ,vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
   endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  task main_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "scoreboard start work", UVM_MEDIUM);
	#1000;
	`ifndef RANDOM_REG_CHECK
		
		fork

			//*****power up & down begin****
			
			//*****power up & down end****

			//*****program timing begin****
			check_pgm_setup_pd2ps();
			check_pgm_hold_pd2ps();
			check_pgm_setup_ps2cs();
			check_pgm_hold_ps2cs();
			check_pgm_setup_ps2strobe();
			check_pgm_hold_ps2strobe();
			//*****program timing end****
			//*****common timing check start****
			check_strobe_keep();
			check_setup_pd2strobe();
			check_hold_pd2strobe();		
			check_setup_rwl2strobe();
			check_hold_rwl2strobe();
			check_setup_rsb2strobe();
			check_hold_rsb2strobe();
			check_setup_cs2strobe();
			check_hold_cs2strobe();
			check_setup_pgen2strobe();
			check_hold_pgen2strobe();
			check_setup_load2strobe();
			check_hold_load2strobe();
			check_setup_addr2strobe();
			check_hold_addr2strobe();
			check_setup_test_addr2strobe();
			check_hold_test_addr2strobe();
			check_setup_trcs2strobe();
			check_hold_trcs2strobe();
			//*****common timing check end****			
			//*****sense timing start****
			check_load_setup_pd2cs();
			check_load_hold_pd2cs();
			check_load_setup_ps2cs();
			check_load_hold_ps2cs();
			check_load_setup_ps2strobe();
			check_load_hold_ps2strobe();
			check_load_tsq();  
			//*****sense timing end****
						
		join_none
		
	`endif
  endtask

	virtual task check_pgm_setup_pd2ps();
		realtime time1,time2,period;  
		int min_threshold=`PGM_TSETUP_PD2PS;
		forever begin
		
			@(negedge vif.ip_PD);	
			time1=$realtime();
			@(posedge vif.ip_PS);		
			time2=$realtime();
			period=time2-time1;

			if(period< min_threshold)begin
				`uvm_error(get_full_name(), $sformatf("The time between ip_PD and ip_PS is less than %0d ns,actual time=%f!!!",min_threshold,period))
			end
			`ifdef  TIMING_DEBUG
				`uvm_info(get_full_name(),$sformatf("The time between ip_PD and ip_PS ==> actual time=%f!!!", period),UVM_MEDIUM)
			`endif
			
		end
	endtask

	virtual task check_pgm_hold_pd2ps();
		realtime time1,time2,period;  
		int min_threshold=`PGM_THOLD_PD2PS;
		forever begin
		
			@(negedge vif.ip_PS);	
			time1=$realtime();
			@(posedge vif.ip_PD);		
			time2=$realtime();
			period=time2-time1;

			if(period< min_threshold)begin
				`uvm_error(get_full_name(), $sformatf("The hold time between ip_PD and ip_PS is less than %0d ns,actual time=%f!!!",min_threshold,period))
			end
			`ifdef  TIMING_DEBUG
				`uvm_info(get_full_name(),$sformatf("The hold time between ip_PD and ip_PS ==> actual time=%f!!!", period),UVM_MEDIUM)
			`endif
			
		end
	endtask


	virtual task check_pgm_setup_ps2cs();
		realtime time1,time2,period;  
		int min_threshold=`PGM_TSETUP_PS2CS;
		forever begin
		
			@(posedge vif.ip_PS);	
			if (vif.ip_PD==1'b0) begin
				time1=$realtime();
				@(negedge vif.ip_CSB);		
				time2=$realtime();
				period=time2-time1;

				if(period< min_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The time between ip_PS and ip_CSB is less than %0d ns,actual time=%f!!!",min_threshold,period))
				end
				`ifdef  TIMING_DEBUG
					`uvm_info(get_full_name(),$sformatf("The time between ip_PS and ip_CSB ==> actual time=%f!!!", period),UVM_MEDIUM)
				`endif	
			end
			else begin
				`uvm_error(get_full_name(),"when ip_PS raise,but ip_PD is still enabled!")	
			end	
					
		end
	endtask

	virtual task check_pgm_hold_ps2cs();
		realtime time1,time2,period;  
		int min_threshold=`PGM_THOLD_PS2CS;
		forever begin
		
			@(posedge vif.ip_CSB);	
			if (vif.ip_PD==1'b0) begin
				time1=$realtime();
				@(negedge vif.ip_PS);		
				time2=$realtime();
				period=time2-time1;

				if(period< min_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The hold time between ip_PS and ip_CSB is less than %0d ns,actual time=%f!!!",min_threshold,period))
				end
				`ifdef  TIMING_DEBUG
					`uvm_info(get_full_name(),$sformatf("The hold time between ip_PS and ip_CSB ==> actual time=%f!!!", period),UVM_MEDIUM)
				`endif	
			end
			else begin
				`uvm_error(get_full_name(),"when ip_CSB raise, ip_PD is already enabled!")	
			end	
					
		end
	endtask

	virtual task check_setup_pd2strobe();
		realtime time1,time2,period;  
		int min_pgm_threshold=`PGM_TSETUP_PD2STROBE;
		int min_rd_threshold=`RD_TSETUP_PD2STROBE;
		forever begin
		
			@(negedge vif.ip_PD);	
			time1=$realtime();
			@(posedge vif.ip_STROBE);		
			time2=$realtime();
			period=time2-time1;

			if (vif.ip_PGENB==1'b0) begin
				if(period< min_pgm_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The time between ip_PD and ip_STROBE is less than %0d ns,actual time=%f!!!",min_pgm_threshold,period))
				end
			end
			else if (vif.ip_LOAD==1'b1) begin
				if(period< min_rd_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The time between ip_PD and ip_STROBE is less than %0d ns,actual time=%f!!!",min_rd_threshold,period))
				end
			end
			else begin
				`uvm_error(get_full_name(), "The state of ip_PGENB or ip_LOAD dont fit timing!!!")
			end

			`ifdef  TIMING_DEBUG
				`uvm_info(get_full_name(),$sformatf("The time between ip_PD and ip_STROBE ==> actual time=%f!!!", period),UVM_MEDIUM)
			`endif	
		end
	endtask

	virtual task check_hold_pd2strobe();
		realtime time1,time2,period;  
		int min_pgm_threshold=`PGM_THOLD_PD2STROBE;
		int min_rd_threshold=`RD_THOLD_PD2STROBE;
		
		fork	
			forever begin
				@(negedge vif.ip_STROBE);			
				time1=$realtime();
			end
			forever begin
				@(negedge vif.ip_STROBE);		
				time1=$realtime();
				@(posedge vif.ip_PD);		
				time2=$realtime();
				period=time2-time1;

				if (vif.ip_PGENB==1'b0) begin
					if(period< min_pgm_threshold)begin
						`uvm_error(get_full_name(), $sformatf("The hold time between ip_PD and ip_STROBE is less than %0d ns,actual time=%f!!!",min_pgm_threshold,period))
					end
				end
				else if (vif.ip_LOAD==1'b1) begin
					if(period< min_rd_threshold)begin
						`uvm_error(get_full_name(), $sformatf("The hold time between ip_PD and ip_STROBE is less than %0d ns,actual time=%f!!!",min_rd_threshold,period))
					end
				end
	
				
				`ifdef  TIMING_DEBUG
					`uvm_info(get_full_name(),$sformatf("The hold time between ip_PD and ip_STROBE ==> actual time=%f!!!", period),UVM_MEDIUM)
				`endif	
			end
		join_none

	endtask

	virtual task check_pgm_setup_ps2strobe();
		realtime time1,time2,period;  
		int min_pgm_threshold=`PGM_TSETUP_PS2STROBE;
		forever begin
		
			@(posedge vif.ip_PS);	
			if (vif.ip_PD==1'b0) begin
				time1=$realtime();
				@(posedge vif.ip_STROBE);		
				time2=$realtime();
				period=time2-time1;

				if(period< min_pgm_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The time between ip_PS and ip_STROBE is less than %0d ns,actual time=%f!!!",min_pgm_threshold,period))
				end

				`ifdef  TIMING_DEBUG
					`uvm_info(get_full_name(),$sformatf("The time between ip_PS and ip_STROBE ==> actual time=%f!!!", period),UVM_MEDIUM)
				`endif	
			end
			else begin
				`uvm_error(get_full_name(),"when ip_PS raise,but ip_PD is still enabled!")	
			end	
					
		end
	endtask

	virtual task check_load_setup_ps2strobe();
		realtime time1,time2,period;  
		int min_rd_threshold=`RD_TSETUP_PS2STROBE;
		forever begin
		
			@(negedge vif.ip_PS);	
			time1=$realtime();
			@(posedge vif.ip_STROBE);		
			time2=$realtime();
			period=time2-time1;

			if(period< min_rd_threshold)begin
				`uvm_error(get_full_name(), $sformatf("The time between ip_PS and ip_STROBE is less than %0d ns,actual time=%f!!!",min_rd_threshold,period))
			end

			`ifdef  TIMING_DEBUG
				`uvm_info(get_full_name(),$sformatf("The time between ip_PS and ip_STROBE ==> actual time=%f!!!", period),UVM_MEDIUM)
			`endif	
			
					
		end
	endtask


	virtual task check_pgm_hold_ps2strobe();
		realtime time1,time2,period;  
		int min_pgm_threshold=`PGM_THOLD_PS2STROBE;
	
		fork	
			forever begin
				@(negedge vif.ip_STROBE);			
				time1=$realtime();
			end
			forever begin
				@(negedge vif.ip_STROBE);		
				time1=$realtime();
				@(negedge vif.ip_PS);		
				time2=$realtime();
				period=time2-time1;

				if(period< min_pgm_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The hold time between ip_PS and ip_STROBE is less than %0d ns,actual time=%f!!!",min_pgm_threshold,period))
				end
				
				`ifdef  TIMING_DEBUG
					`uvm_info(get_full_name(),$sformatf("The hold time between ip_PS and ip_STROBE ==> actual time=%f!!!", period),UVM_MEDIUM)
				`endif	
			end
		join_none
	endtask

	virtual task check_load_hold_ps2strobe();
		realtime time1,time2,period;  
		int min_rd_threshold=`RD_THOLD_PS2STROBE;
		
		fork	
			forever begin
				@(negedge vif.ip_STROBE);			
				time1=$realtime();
			end
			forever begin
				@(negedge vif.ip_STROBE);		
				time1=$realtime();
				@(posedge vif.ip_PS);		
				time2=$realtime();
				period=time2-time1;

				if(period< min_rd_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The hold time between ip_PS and ip_STROBE is less than %0d ns,actual time=%f!!!",min_rd_threshold,period))
				end
				
				`ifdef  TIMING_DEBUG
					`uvm_info(get_full_name(),$sformatf("The hold time between ip_PS and ip_STROBE ==> actual time=%f!!!", period),UVM_MEDIUM)
				`endif	
			end
		join_none
	endtask


	virtual task check_setup_rwl2strobe();
		realtime time1,time2,period;  
		int min_pgm_threshold=`PGM_TSETUP_RWL2STROBE;
		int min_rd_threshold=`RD_TSETUP_RWL2STROBE;
		forever begin
		
			@(posedge vif.ip_RWL);	
			time1=$realtime();
			@(posedge vif.ip_STROBE);		
			time2=$realtime();
			period=time2-time1;

			if (vif.ip_PGENB==1'b0) begin
				if(period< min_pgm_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The time between ip_RWL and ip_STROBE is less than %0d ns,actual time=%f!!!",min_pgm_threshold,period))
				end
			end
			else if (vif.ip_LOAD==1'b1) begin
				if(period< min_rd_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The time between ip_RWL and ip_STROBE is less than %0d ns,actual time=%f!!!",min_rd_threshold,period))
				end
			end
			else begin
				`uvm_error(get_full_name(), "The state of ip_PGENB or ip_LOAD dont fit timing!!!")
			end
			`ifdef  TIMING_DEBUG
				`uvm_info(get_full_name(),$sformatf("The time between ip_RWL and ip_STROBE ==> actual time=%f!!!", period),UVM_MEDIUM)
			`endif
			
		end
	endtask


	virtual task check_hold_rwl2strobe();
		realtime time1,time2,period;  
		int min_pgm_threshold=`PGM_THOLD_RWL2STROBE;
		int min_rd_threshold=`RD_THOLD_RWL2STROBE;
		
		fork	
			forever begin
				@(negedge vif.ip_STROBE);			
				time1=$realtime();
			end
			forever begin
				@(negedge vif.ip_STROBE);		
				time1=$realtime();
				@(negedge vif.ip_RWL);		
				time2=$realtime();
				period=time2-time1;

				if (vif.ip_PGENB==1'b0) begin
					if(period< min_pgm_threshold)begin
						`uvm_error(get_full_name(), $sformatf("The hold time between ip_RWL and ip_STROBE is less than %0d ns,actual time=%f!!!",min_pgm_threshold,period))
					end
				end
				else if (vif.ip_LOAD==1'b1) begin
					if(period< min_rd_threshold)begin
						`uvm_error(get_full_name(), $sformatf("The hold time between ip_RWL and ip_STROBE is less than %0d ns,actual time=%f!!!",min_rd_threshold,period))
					end
				end

				
				`ifdef  TIMING_DEBUG
					`uvm_info(get_full_name(),$sformatf("The hold time between ip_RWL and ip_STROBE ==> actual time=%f!!!", period),UVM_MEDIUM)
				`endif	
			end
		join_none
	endtask


	virtual task check_setup_rsb2strobe();
		realtime time1,time2,period;  
		int min_pgm_threshold=`PGM_TSETUP_RSB2STROBE;
		int min_rd_threshold=`RD_TSETUP_RSB2STROBE;
		forever begin
		
			@(negedge vif.ip_RSB);	
			time1=$realtime();
			@(posedge vif.ip_STROBE);		
			time2=$realtime();
			period=time2-time1;

			if (vif.ip_PGENB==1'b0) begin
				if(period< min_pgm_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The time between ip_RSB and ip_STROBE is less than %0d ns,actual time=%f!!!",min_pgm_threshold,period))
				end
			end
			else if (vif.ip_LOAD==1'b1) begin
				if(period< min_rd_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The time between ip_RSB and ip_STROBE is less than %0d ns,actual time=%f!!!",min_rd_threshold,period))
				end
			end
			else begin
				`uvm_error(get_full_name(), "The state of ip_PGENB or ip_LOAD dont fit timing!!!")
			end

			`ifdef  TIMING_DEBUG
				`uvm_info(get_full_name(),$sformatf("The time between ip_RSB and ip_STROBE ==> actual time=%f!!!", period),UVM_MEDIUM)
			`endif
			
		end
	endtask

	virtual task check_hold_rsb2strobe();
		realtime time1,time2,period;  
		int min_pgm_threshold=`PGM_THOLD_RSB2STROBE;
		int min_rd_threshold=`RD_THOLD_RSB2STROBE;
		
		fork	
			forever begin
				@(negedge vif.ip_STROBE);			
				time1=$realtime();
			end
			forever begin
				@(negedge vif.ip_STROBE);		
				time1=$realtime();
				@(posedge vif.ip_RSB);		
				time2=$realtime();
				period=time2-time1;

				if (vif.ip_PGENB==1'b0) begin
					if(period< min_pgm_threshold)begin
						`uvm_error(get_full_name(), $sformatf("The hold time between ip_RSB and ip_STROBE is less than %0d ns,actual time=%f!!!",min_pgm_threshold,period))
					end
				end
				else if (vif.ip_LOAD==1'b1) begin
					if(period< min_rd_threshold)begin
						`uvm_error(get_full_name(), $sformatf("The hold time between ip_RSB and ip_STROBE is less than %0d ns,actual time=%f!!!",min_rd_threshold,period))
					end
				end

				
				`ifdef  TIMING_DEBUG
					`uvm_info(get_full_name(),$sformatf("The hold time between ip_RSB and ip_STROBE ==> actual time=%f!!!", period),UVM_MEDIUM)
				`endif	
			end
		join_none
	endtask



	virtual task check_setup_cs2strobe();
		realtime time1,time2,period;  
		int min_pgm_threshold=`PGM_TSETUP_CS2STROBE;
		int min_rd_threshold=`RD_TSETUP_CS2STROBE;
		forever begin
		
			@(negedge vif.ip_CSB);	
			if ((vif.ip_PD==1'b0)) begin
				time1=$realtime();
				@(posedge vif.ip_STROBE);		
				time2=$realtime();
				period=time2-time1;

				if (vif.ip_PGENB==1'b0) begin
					if(period< min_pgm_threshold)begin
						`uvm_error(get_full_name(), $sformatf("The time between ip_CSB and ip_STROBE is less than %0d ns,actual time=%f!!!",min_pgm_threshold,period))
					end
				end
				else if (vif.ip_LOAD==1'b1) begin
					if(period< min_rd_threshold)begin
						`uvm_error(get_full_name(), $sformatf("The time between ip_CSB and ip_STROBE is less than %0d ns,actual time=%f!!!",min_rd_threshold,period))
					end
				end
				else begin
					`uvm_error(get_full_name(), "The state of ip_PGENB or ip_LOAD dont fit timing!!!")
				end

				`ifdef  TIMING_DEBUG
					`uvm_info(get_full_name(),$sformatf("The time between ip_STROBE and ip_CSB ==> actual time=%f!!!", period),UVM_MEDIUM)
				`endif	
			end
			else begin
				`uvm_error(get_full_name(),"when ip_CSB enable,but ip_PD is still enabled!")	
			end	
					
		end
	endtask
	
	virtual task check_hold_cs2strobe();
		realtime time1,time2,period;  
		int min_pgm_threshold=`PGM_THOLD_CS2STROBE;
		int min_rd_threshold=`RD_THOLD_CS2STROBE;
		
		fork	
			forever begin
				@(negedge vif.ip_STROBE);			
				time1=$realtime();
			end
			forever begin
				@(negedge vif.ip_STROBE);		
				time1=$realtime();
				@(posedge vif.ip_CSB);		
				time2=$realtime();
				period=time2-time1;

				if (vif.ip_PGENB==1'b0) begin
					if(period< min_pgm_threshold)begin
						`uvm_error(get_full_name(), $sformatf("The hold time between ip_CSB and ip_STROBE is less than %0d ns,actual time=%f!!!",min_pgm_threshold,period))
					end
				end
				else if (vif.ip_LOAD==1'b1) begin
					if(period< min_rd_threshold)begin
						`uvm_error(get_full_name(), $sformatf("The hold time between ip_CSB and ip_STROBE is less than %0d ns,actual time=%f!!!",min_rd_threshold,period))
					end
				end

				`ifdef  TIMING_DEBUG
					`uvm_info(get_full_name(),$sformatf("The hold time between ip_CSB and ip_STROBE ==> actual time=%f!!!", period),UVM_MEDIUM)
				`endif	
			end
		join_none
	endtask

	virtual task check_setup_pgen2strobe();
		realtime time1,time2,period;  
		int min_pgm_threshold=`PGM_TSETUP_PGEN2STROBE;
		int min_rd_threshold=`RD_TSETUP_PGEN2STROBE;
		forever begin
		
			@(negedge vif.ip_PGENB);	
			time1=$realtime();
			@(posedge vif.ip_STROBE);		
			time2=$realtime();
			period=time2-time1;

			if (vif.ip_PGENB==1'b0) begin
				if(period< min_pgm_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The time between ip_PGENB and ip_STROBE is less than %0d ns,actual time=%f!!!",min_pgm_threshold,period))
				end
			end
			else if (vif.ip_LOAD==1'b1) begin
				if(period< min_rd_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The time between ip_PGENB and ip_STROBE is less than %0d ns,actual time=%f!!!",min_rd_threshold,period))
				end
			end
			else begin
				`uvm_error(get_full_name(), "The state of ip_PGENB or ip_LOAD dont fit timing!!!")
			end

			`ifdef  TIMING_DEBUG
				`uvm_info(get_full_name(),$sformatf("The time between ip_PGENB and ip_STROBE ==> actual time=%f!!!", period),UVM_MEDIUM)
			`endif		
		end
	endtask

	virtual task check_hold_pgen2strobe();
		realtime time1,time2,period;  
		int min_pgm_threshold=`PGM_THOLD_PGEN2STROBE;
		int min_rd_threshold=`RD_THOLD_PGEN2STROBE;
		
		fork	
			forever begin
				@(negedge vif.ip_STROBE);			
				time1=$realtime();
			end
			forever begin
				@(negedge vif.ip_STROBE);		
				time1=$realtime();
				@(posedge vif.ip_PGENB);		
				time2=$realtime();
				period=time2-time1;

				if (vif.ip_PGENB==1'b0) begin
					if(period< min_pgm_threshold)begin
						`uvm_error(get_full_name(), $sformatf("The hold time between ip_PGENB and ip_STROBE is less than %0d ns,actual time=%f!!!",min_pgm_threshold,period))
					end
				end
				else if (vif.ip_LOAD==1'b1) begin
					if(period< min_rd_threshold)begin
						`uvm_error(get_full_name(), $sformatf("The hold time between ip_PGENB and ip_STROBE is less than %0d ns,actual time=%f!!!",min_rd_threshold,period))
					end
				end
			
				`ifdef  TIMING_DEBUG
					`uvm_info(get_full_name(),$sformatf("The hold time between ip_PGENB and ip_STROBE ==> actual time=%f!!!", period),UVM_MEDIUM)
				`endif	
			end
		join_none
	endtask

	virtual task check_setup_load2strobe();
		realtime time1,time2,period;  
		int min_pgm_threshold=`PGM_TSETUP_LOAD2STROBE;
		int min_rd_threshold=`RD_TSETUP_LOAD2STROBE;
		forever begin
		
			@(posedge vif.ip_LOAD);	
			time1=$realtime();
			@(posedge vif.ip_STROBE);		
			time2=$realtime();
			period=time2-time1;

			if (vif.ip_PGENB==1'b0) begin
				if(period< min_pgm_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The time between ip_LOAD and ip_STROBE is less than %0d ns,actual time=%f!!!",min_pgm_threshold,period))
				end
			end
			else if (vif.ip_LOAD==1'b1) begin
				if(period< min_rd_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The time between ip_LOAD and ip_STROBE is less than %0d ns,actual time=%f!!!",min_rd_threshold,period))
				end
			end
			else begin
				`uvm_error(get_full_name(), "The state of ip_PGENB or ip_LOAD dont fit timing!!!")
			end

			`ifdef  TIMING_DEBUG
				`uvm_info(get_full_name(),$sformatf("The time between ip_LOAD and ip_STROBE ==> actual time=%f!!!", period),UVM_MEDIUM)
			`endif		
		end
	endtask

	virtual task check_hold_load2strobe();
		realtime time1,time2,period;  
		int min_pgm_threshold=`PGM_THOLD_LOAD2STROBE;
		int min_rd_threshold=`RD_THOLD_LOAD2STROBE;
		
		fork	
			forever begin
				@(negedge vif.ip_STROBE);			
				time1=$realtime();
			end
			forever begin
				@(negedge vif.ip_STROBE);		
				time1=$realtime();
				@(negedge vif.ip_LOAD);		
				time2=$realtime();
				period=time2-time1;

				if (vif.ip_PGENB==1'b0) begin
					if(period< min_pgm_threshold)begin
						`uvm_error(get_full_name(), $sformatf("The hold time between ip_LOAD and ip_STROBE is less than %0d ns,actual time=%f!!!",min_pgm_threshold,period))
					end
				end
				else if (vif.ip_LOAD==1'b1) begin
					if(period< min_rd_threshold)begin
						`uvm_error(get_full_name(), $sformatf("The hold time between ip_LOAD and ip_STROBE is less than %0d ns,actual time=%f!!!",min_rd_threshold,period))
					end
				end

				`ifdef  TIMING_DEBUG
					`uvm_info(get_full_name(),$sformatf("The hold time between ip_LOAD and ip_STROBE ==> actual time=%f!!!", period),UVM_MEDIUM)
				`endif	
			end
		join_none
	endtask



	virtual task check_setup_addr2strobe();
		realtime time1,time2,period;  
		int min_pgm_threshold=`PGM_TSETUP_ADDR2STROBE;
		int min_rd_threshold=`RD_TSETUP_ADDR2STROBE;
		forever begin
		
			@(vif.ip_A);	
			time1=$realtime();
			@(posedge vif.ip_STROBE);		
			time2=$realtime();
			period=time2-time1;

			if (vif.ip_PGENB==1'b0) begin
				if(period< min_pgm_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The time between ip_A and ip_STROBE is less than %0d ns,actual time=%f!!!",min_pgm_threshold,period))
				end
			end
			else if (vif.ip_LOAD==1'b1) begin
				if(period< min_rd_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The time between ip_A and ip_STROBE is less than %0d ns,actual time=%f!!!",min_rd_threshold,period))
				end
			end
			else begin
				`uvm_error(get_full_name(), "The state of ip_PGENB or ip_LOAD dont fit timing!!!")
			end
			`ifdef  TIMING_DEBUG
				`uvm_info(get_full_name(),$sformatf("The time between ip_A and ip_STROBE ==> actual time=%f!!!", period),UVM_MEDIUM)
			`endif		
		end
	endtask

	virtual task check_hold_addr2strobe();
		realtime time1,time2,period;  
		int min_pgm_threshold=`PGM_THOLD_ADDR2STROBE;
		int min_rd_threshold=`RD_THOLD_ADDR2STROBE;
		
		fork	
			forever begin
				@(negedge vif.ip_STROBE);			
				time1=$realtime();
			end
			forever begin
				@(negedge vif.ip_STROBE);		
				time1=$realtime();
				@(vif.ip_A);		
				time2=$realtime();
				period=time2-time1;

				if (vif.ip_PGENB==1'b0) begin
					if(period< min_pgm_threshold)begin
						`uvm_error(get_full_name(), $sformatf("The hold time between ip_A and ip_STROBE is less than %0d ns,actual time=%f!!!",min_pgm_threshold,period))
					end
				end
				else if (vif.ip_LOAD==1'b1) begin
					if(period< min_rd_threshold)begin
						`uvm_error(get_full_name(), $sformatf("The hold time between ip_A and ip_STROBE is less than %0d ns,actual time=%f!!!",min_rd_threshold,period))
					end
				end


				`ifdef  TIMING_DEBUG
					`uvm_info(get_full_name(),$sformatf("The hold time between ip_A and ip_STROBE ==> actual time=%f!!!", period),UVM_MEDIUM)
				`endif	
			end
		join_none
	endtask

	virtual task check_setup_test_addr2strobe();
		realtime time1,time2,period;  
		int min_pgm_threshold=`PGM_TSETUP_ADDR2STROBE;
		int min_rd_threshold=`RD_TSETUP_ADDR2STROBE;
		forever begin
		
			@(vif.ip_AT);	
			time1=$realtime();
			@(posedge vif.ip_STROBE);		
			time2=$realtime();
			period=time2-time1;

			if (vif.ip_PGENB==1'b0) begin
				if(period< min_pgm_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The  time between ip_AT and ip_STROBE is less than %0d ns,actual time=%f!!!",min_pgm_threshold,period))
				end
			end
			else if (vif.ip_LOAD==1'b1) begin
				if(period< min_rd_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The  time between ip_AT and ip_STROBE is less than %0d ns,actual time=%f!!!",min_rd_threshold,period))
				end
			end
			else begin
				`uvm_error(get_full_name(), "The state of ip_PGENB or ip_LOAD dont fit timing!!!")
			end

			`ifdef  TIMING_DEBUG
				`uvm_info(get_full_name(),$sformatf("The time between ip_AT and ip_STROBE ==> actual time=%f!!!", period),UVM_MEDIUM)
			`endif		
		end
	endtask

	virtual task check_hold_test_addr2strobe();
		realtime time1,time2,period;  
		int min_pgm_threshold=`PGM_THOLD_ADDR2STROBE;
		int min_rd_threshold=`RD_THOLD_ADDR2STROBE;
		
		fork	
			forever begin
				@(negedge vif.ip_STROBE);			
				time1=$realtime();
			end
			forever begin
				@(negedge vif.ip_STROBE);		
				time1=$realtime();
				@(vif.ip_AT);		
				time2=$realtime();
				period=time2-time1;

				if (vif.ip_PGENB==1'b0) begin
					if(period< min_pgm_threshold)begin
						`uvm_error(get_full_name(), $sformatf("The hold time between ip_AT and ip_STROBE is less than %0d ns,actual time=%f!!!",min_pgm_threshold,period))
					end
				end
				else if (vif.ip_LOAD==1'b1) begin
					if(period< min_rd_threshold)begin
						`uvm_error(get_full_name(), $sformatf("The hold time between ip_AT and ip_STROBE is less than %0d ns,actual time=%f!!!",min_rd_threshold,period))
					end
				end


				`ifdef  TIMING_DEBUG
					`uvm_info(get_full_name(),$sformatf("The hold time between ip_AT and ip_STROBE ==> actual time=%f!!!", period),UVM_MEDIUM)
				`endif	
			end
		join_none
	endtask



	virtual task check_setup_trcs2strobe();
		realtime time1,time2,period;  
		int min_pgm_threshold=`PGM_TSETUP_TRCS2STROBE;
		int min_rd_threshold=`RD_TSETUP_TRCS2STROBE;
		forever begin
		
			@(posedge vif.ip_TRCS);	
			time1=$realtime();
			@(posedge vif.ip_STROBE);		
			time2=$realtime();
			period=time2-time1;

			if (vif.ip_PGENB==1'b0) begin
				if(period< min_pgm_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The time between ip_TRCS and ip_STROBE is less than %0d ns,actual time=%f!!!",min_pgm_threshold,period))
				end
			end
			else if (vif.ip_LOAD==1'b1) begin
				if(period< min_rd_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The time between ip_TRCS and ip_STROBE is less than %0d ns,actual time=%f!!!",min_rd_threshold,period))
				end
			end
			else begin
				`uvm_error(get_full_name(), "The state of ip_PGENB or ip_LOAD dont fit timing!!!")
			end

			`ifdef  TIMING_DEBUG
				`uvm_info(get_full_name(),$sformatf("The time between ip_TRCS and ip_STROBE ==> actual time=%f!!!", period),UVM_MEDIUM)
			`endif		
		end
	endtask

	virtual task check_hold_trcs2strobe();
		realtime time1,time2,period;  
		int min_pgm_threshold=`PGM_THOLD_TRCS2STROBE;
		int min_rd_threshold=`RD_THOLD_TRCS2STROBE;
		
		fork	
			forever begin
				@(negedge vif.ip_STROBE);			
				time1=$realtime();
			end
			forever begin
				@(negedge vif.ip_STROBE);		
				time1=$realtime();
				@(negedge vif.ip_TRCS);		
				time2=$realtime();
				period=time2-time1;

				if (vif.ip_PGENB==1'b0) begin
					if(period< min_pgm_threshold)begin
						`uvm_error(get_full_name(), $sformatf("The hold time between ip_TRCS and ip_STROBE is less than %0d ns,actual time=%f!!!",min_pgm_threshold,period))
					end
				end
				else if (vif.ip_LOAD==1'b1) begin
					if(period< min_rd_threshold)begin
						`uvm_error(get_full_name(), $sformatf("The hold time between ip_TRCS and ip_STROBE is less than %0d ns,actual time=%f!!!",min_rd_threshold,period))
					end
				end

				`ifdef  TIMING_DEBUG
					`uvm_info(get_full_name(),$sformatf("The hold time between ip_TRCS and ip_STROBE ==> actual time=%f!!!", period),UVM_MEDIUM)
				`endif	
			end
		join_none
	endtask

	virtual task check_strobe_keep();
		realtime time1,time2,period;  
		int min_pgm_threshold=`PGM_TKEEP_STROBE-500;
		int max_pgm_threshold=`PGM_TKEEP_STROBE+500;
		int min_read_threshold=`RD_TKEEP_STROBE;
		int min_margin_read_threshold=`RD_TKEEP_MARGIN_STROBE;
		forever begin
		
			@(posedge vif.ip_STROBE);	
			
			if (vif.ip_PGENB==1'b0) begin
				time1=$realtime();
				@(negedge vif.ip_STROBE);		
				time2=$realtime();
				period=time2-time1;

				if(period< min_pgm_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The strobe pgm keep time is less than %0d ns,actual time=%f!!!",min_pgm_threshold,period))
				end
				else if (period>max_pgm_threshold) begin
					`uvm_error(get_full_name(), $sformatf("The strobe pgm keep time is bigger than %0d ns,actual time=%f!!!",max_pgm_threshold,period))
				end
				`ifdef  TIMING_DEBUG
					`uvm_info(get_full_name(),$sformatf("The strobe pgm keep time ==> actual time=%f!!!", period),UVM_MEDIUM)
				`endif	
			end
			else if((vif.ip_LOAD==1'b1)&&(vif.ip_MR==1'b1))begin
				time1=$realtime();
				@(negedge vif.ip_STROBE);		
				time2=$realtime();
				period=time2-time1;

				if(period< min_margin_read_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The strobe load keep time is less than %0d ns,actual time=%f!!!",min_margin_read_threshold,period))
				end
				`ifdef  TIMING_DEBUG
					`uvm_info(get_full_name(),$sformatf("The strobe load keep time ==> actual time=%f!!!", period),UVM_MEDIUM)
				`endif
			end
			else if((vif.ip_LOAD==1'b1)&&(vif.ip_MR==1'b0))begin
				time1=$realtime();
				@(negedge vif.ip_STROBE);		
				time2=$realtime();
				period=time2-time1;

				if(period< min_read_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The strobe m_load keep time is less than %0d ns,actual time=%f!!!",min_read_threshold,period))
				end
				`ifdef  TIMING_DEBUG
					`uvm_info(get_full_name(),$sformatf("The strobe m_load keep time ==> actual time=%f!!!", period),UVM_MEDIUM)
				`endif
			end
		end
	endtask


	virtual task check_load_setup_pd2cs();
		realtime time1,time2,period;  
		int min_threshold=`RD_TSETUP_PD2CS;
		forever begin
		
			@(negedge vif.ip_PD);	
			time1=$realtime();
			@(negedge vif.ip_CSB);		
			time2=$realtime();
			period=time2-time1;

			if(period< min_threshold)begin
				`uvm_error(get_full_name(), $sformatf("The time between ip_PD and ip_CSB is less than %0d ns,actual time=%f!!!",min_threshold,period))
			end
			`ifdef  TIMING_DEBUG
				`uvm_info(get_full_name(),$sformatf("The time between ip_PD and ip_CSB ==> actual time=%f!!!", period),UVM_MEDIUM)
			`endif
			
		end
	endtask

	virtual task check_load_hold_pd2cs();
		realtime time1,time2,period;  
		int min_threshold=`RD_THOLD_PD2CS;
		forever begin
		
			@(posedge vif.ip_CSB);	
			time1=$realtime();
			@(posedge vif.ip_PD);		
			time2=$realtime();
			period=time2-time1;

			if(period< min_threshold)begin
				`uvm_error(get_full_name(), $sformatf("The hold time between ip_PD and ip_CSB is less than %0d ns,actual time=%f!!!",min_threshold,period))
			end
			`ifdef  TIMING_DEBUG
				`uvm_info(get_full_name(),$sformatf("The hold time between ip_PD and ip_CSB ==> actual time=%f!!!", period),UVM_MEDIUM)
			`endif
			
		end
	endtask


	virtual task check_load_setup_ps2cs();
		realtime time1,time2,period;  
		int min_threshold=`RD_TSETUP_PS2CS;
		forever begin
		
			@(negedge vif.ip_PS);	
			if (vif.ip_PD==1'b0) begin
				time1=$realtime();
				@(negedge vif.ip_CSB);		
				time2=$realtime();
				period=time2-time1;

				if(period< min_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The time between ip_PS and ip_CSB is less than %0d ns,actual time=%f!!!",min_threshold,period))
				end
				`ifdef  TIMING_DEBUG
					`uvm_info(get_full_name(),$sformatf("The time between ip_PS and ip_CSB ==> actual time=%f!!!", period),UVM_MEDIUM)
				`endif	
			end
			else begin
				`uvm_error(get_full_name(),"when ip_PS raise,but ip_PD is still enabled!")	
			end	
					
		end
	endtask

	virtual task check_load_hold_ps2cs();
		realtime time1,time2,period;  
		int min_threshold=`RD_THOLD_PS2CS;
		forever begin
		
			@(posedge vif.ip_CSB);	
			if (vif.ip_PD==1'b0) begin
				time1=$realtime();
				@(posedge vif.ip_PS);		
				time2=$realtime();
				period=time2-time1;

				if(period< min_threshold)begin
					`uvm_error(get_full_name(), $sformatf("The hold time between ip_PS and ip_CSB is less than %0d ns,actual time=%f!!!",min_threshold,period))
				end
				`ifdef  TIMING_DEBUG
					`uvm_info(get_full_name(),$sformatf("The hold time between ip_PS and ip_CSB ==> actual time=%f!!!", period),UVM_MEDIUM)
				`endif	
			end
			else begin
				`uvm_error(get_full_name(),"when ip_CSB raise, ip_PD is already enabled!")	
			end	
					
		end
	endtask

		
	virtual task check_load_tsq();
		realtime time1,time2,period;  
		int min_threshold=`RD_TSQ;
		int min_mthreshold=`RD_TSQ_M;
		forever begin
		
			@(posedge vif.ip_STROBE);	
			if (vif.ip_CSB==1'b0) begin
				time1=$realtime();

				`ifndef DATA_ALL_ONE
					@(negedge vif.ip_Q_and);
				`else
					@(posedge vif.ip_Q_and);
				`endif

				time2=$realtime();
				period=time2-time1;

				if((vif.ip_LOAD==1'b1)&&(vif.ip_MR==1'b1)&&(vif.ip_Q_and!=1'b1))begin
				
					if(period< min_mthreshold)begin
						`uvm_error(get_full_name(), $sformatf("The strobe to doutq time is less than %0d ns,actual time=%f!!!",min_mthreshold,period))
					end
				end
				else if((vif.ip_LOAD==1'b1)&&(vif.ip_MR==1'b0)&&(vif.ip_Q_and!=1'b1))begin
				
					if(period< min_threshold)begin
						`uvm_error(get_full_name(), $sformatf("The strobe to doutq time is less than %0d ns,actual time=%f!!!",min_threshold,period))
					end
					
				end
				`ifdef  TIMING_DEBUG
					`uvm_info(get_full_name(),$sformatf("The strobe to doutq time ==> actual time=%f!!!", period),UVM_MEDIUM)
				`endif
			end
			else begin
				`uvm_error(get_full_name(),"when ip_STROBE raise , ip_CSB is still disabled!")	
			end	
					
		end
	endtask



  virtual function void write_main_efuse_driver(efuse_sequence_item  efuse_sequence_item_h);
    begin
     //`uvm_info(get_full_name(), $psprintf("efuse_scoreboard card_sel =%d", efuse_item_h.card_sel), UVM_LOW)
    end
  endfunction : write_main_efuse_driver

  virtual function void write_main_efuse_monitor(efuse_item  efuse_item_h);
    begin
     //`uvm_info(get_full_name(), $psprintf("efuse_scoreboard card_sel =%d", efuse_item_h.card_sel), UVM_LOW)
    end

  endfunction : write_main_efuse_monitor






endclass :  efuse_scoreboard

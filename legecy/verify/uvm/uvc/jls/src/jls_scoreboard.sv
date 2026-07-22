`define IDLE  3'b000
`define CMD   3'b001
`define ADDR  3'b010
`define NOP   3'b011
`define INIT  3'b100
`define WR    3'b101
`define LEN   3'b110
`define RD    3'b111

//import top_pkg::*;
//import jamlink_pkg::*;
`uvm_analysis_imp_decl(_main_jls_monitor)
`uvm_analysis_imp_decl(_main_jamlink_driver)

class jls_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(jls_scoreboard);
  
  uvm_analysis_imp_main_jls_monitor #(jls_item, jls_scoreboard)  jls_scoreboard_main_ap;
  uvm_analysis_imp_main_jamlink_driver #(jamlink_sequence_item,jls_scoreboard)  jam2jls;//*
  //jamlink_sequence_item t;//*

  virtual jls_if jls_vif;
  //jls var
  logic [5:0] ci_cnt = 6'h0;
  logic cycle41_di_state = 1'b0;
  logic [50:0] dif;
  logic err_detect;
  logic err_multpl;
  logic [31:0] correct_data;
  
  	//from jamlink_driver
	logic [31:0]  receive_write_x[$];
	logic [31:0]  receive_read_x[$];
	logic [31:0]  receive_write_mid[$];
	logic [31:0]  receive_read_mid[$];
	logic [31:0]  receive_write_std[$];
	logic [31:0]  receive_read_std[$];

	//jls tmp queue
	logic [31:0]  tem_mid[$];
	logic [31:0]  tem_x[$];
	/////////////////////////////////
	RAL_PKG::ral_gen_main 	ral;
	/////////////////////////////////
  	//logic cycle41_di_11 = 1'b0;

  function new(string name="jls_scoreboard" , uvm_component parent=null);
    super.new(name , parent);
  endfunction
 
   function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
		jam2jls = new("jam2jls",this);//*
		
		//t = jamlink_sequence_item::type_id::create("t",this);//*
		jls_scoreboard_main_ap = new("jls_scoreboard_main_ap",this);
       if(!uvm_config_db#(virtual jls_if)::get(this , "" , "jls_vif" ,jls_vif))
       	  `uvm_fatal(get_full_name(), "Virtual interface handle missing")
	//////////////////////////////////////////////////////////////
		if(!uvm_config_db#(RAL_PKG::ral_gen_main)::get(this , "" , "ral" ,ral))
		`uvm_fatal(get_full_name(), "Ral handle missing")
	/////////////////////////////////////////////////////////////

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  virtual function void write_main_jls_monitor(jls_item  jls_item_h);
    begin
     `uvm_info(get_full_name(), $psprintf("jls_scoreboard card_sel =%d", jls_item_h.card_sel), UVM_LOW)
    end
  endfunction : write_main_jls_monitor


  virtual function void write_main_jamlink_driver (jamlink_sequence_item t);     
    begin
		`ifdef JLS_DATA_DEBUG   
			`uvm_info (get_full_name(), "jls_scoreboard get transaction from jamlink_driver", UVM_MEDIUM)//
			$display("-------------------------------------------------------");      
			$display("now time :",$time);
			$display("req.data= %h",t.data);
			$display("req.addr= %h",t.addr);
			$display("req.we= %h",t.we);
			$display("-------------------------------------------------------");
		`endif   


		if(t.we==1'b1)begin//write
			if(t.addr>=14'h3000 && t.addr<=14'h3FFF)begin
				receive_write_x.push_back(32'b1);
				receive_write_x.push_back(t.addr);
				receive_write_x.push_back(t.data);

			end
			else if((t.addr >=`DOMAIN_STD_BASE) && (t.addr <= `DOMAIN_STD_END))begin
                receive_write_std.push_back(32'b1);
				receive_write_std.push_back(t.addr);
				receive_write_std.push_back(t.data);
            end  
			else begin

				receive_write_mid.push_back(32'b1);
				receive_write_mid.push_back(t.addr);
				receive_write_mid.push_back(t.data);

			end
		end

		if(t.we==1'b0)begin
			if(t.addr>=14'h3000 && t.addr<=14'h3FFF)begin  //can update ==> macro
				receive_read_x.push_back(32'b0);
				receive_read_x.push_back(t.addr);
				receive_read_x.push_back(t.data); 

			end
			else if((t.addr >=`DOMAIN_STD_BASE) && (t.addr <= `DOMAIN_STD_END))begin
                receive_read_std.push_back(32'b0);
				receive_read_std.push_back(t.addr);
				receive_read_std.push_back(t.data);
            end  
			else begin
				receive_read_mid.push_back(32'b0);
				receive_read_mid.push_back(t.addr);
				receive_read_mid.push_back(t.data); 
	
			end
		end
	end

  endfunction : write_main_jamlink_driver//

	

  task run_phase(uvm_phase phase);

  	fork

		`ifndef JLM_CLK_GATE_CHK_CLOSE

			do_clk_gate_check(jls_vif.pin_ci_J,"jls_vif.pin_ci_J");//
			do_clk_gate_check(jls_vif.clk_J,"jls_vif.clk_J");//
			do_clk_gate_check(jls_vif.xclk_J,"jls_vif.xclk_J");//
			
		`endif

		do_ci_cnt();
		do_cnt_state();
		do_check();
		do_ecc1_check();
		do_ecc2_check();

		`ifdef USE_JAMLINK_DRV
		`ifndef JLM_DRV_OLD
		`ifndef HAVE_RAL_BUT_NO_USE_RAL
			// follow function similar to asser check in jls_if_pc
			do_mid_ci_constrain_chk();
			do_cdc_check(.name("bus_write_ci2mid"), .src_sig(jls_vif.bus_write_ci2mid),.dst_sig(jls_vif.wr_req_mid),.src_domain_clk(jls_vif.pin_ci),.dst_domain_clk(jls_vif.clk));
			do_cdc_check(.name("bus_read_ci2mid"),  .src_sig(jls_vif.bus_read_ci2mid),.dst_sig(jls_vif.rd_req_mid),.src_domain_clk(jls_vif.pin_ci),.dst_domain_clk(jls_vif.clk));
			do_cdc_check(.name("bus_write_ci2xclk"),.src_sig(jls_vif.bus_write_ci2xclk),.dst_sig(jls_vif.wr_req_xclk),.src_domain_clk(jls_vif.pin_ci),.dst_domain_clk(jls_vif.xclk));
			do_cdc_check(.name("bus_read_ci2xclk"), .src_sig(jls_vif.bus_read_ci2xclk),.dst_sig(jls_vif.rd_req_xclk),.src_domain_clk(jls_vif.pin_ci),.dst_domain_clk(jls_vif.xclk));
			do_cdc_check(.name("bus_write_ci2std"), .src_sig(jls_vif.bus_write_ci2std),.dst_sig(jls_vif.wr_req_std),.src_domain_clk(jls_vif.pin_ci),.dst_domain_clk(jls_vif.xclk));
			do_cdc_check(.name("bus_read_ci2std"),	.src_sig(jls_vif.bus_read_ci2std),.dst_sig(jls_vif.rd_req_std),.src_domain_clk(jls_vif.pin_ci),.dst_domain_clk(jls_vif.xclk));
			do_cdc_check(.name("my_addr_vld_ci2xclk"),.src_sig(jls_vif.myaddr_vld_ci),.dst_sig(jls_vif.myaddr_vld_xclk),.src_domain_clk(jls_vif.pin_ci),.dst_domain_clk(jls_vif.xclk));
			do_cdc_check(.name("apb_rdata_ready_mid2ci"),.src_sig(jls_vif.apb_rdata_ready),.dst_sig(jls_vif.apb_rdata_vld_ci),.src_domain_clk(jls_vif.clk),.dst_domain_clk(jls_vif.pin_ci));
			do_cdc_check(.name("apb_rdata_ready_xclk2ci"),.src_sig(jls_vif.xclk_apb_rdata_ready),.dst_sig(jls_vif.xclk_apb_rdata_ready_ci),.src_domain_clk(jls_vif.xclk),.dst_domain_clk(jls_vif.pin_ci));
			do_cdc_check(.name("apb_rdata_ready_std2ci"),.src_sig(jls_vif.std_apb_rdata_ready),.dst_sig(jls_vif.std_apb_rdata_ready_ci),.src_domain_clk(jls_vif.xclk),.dst_domain_clk(jls_vif.pin_ci));
			jls2jam_check();

		`endif
		`endif
		`endif		

	join  

  endtask

	task  jls2jam_check();
	
		bit [31:0] addr_base;
		bit [31:0] length;
		bit [31:0] addr_base_x;
		bit [31:0] length_x;
		bit [31:0] addr_base_std;
		bit [31:0] length_std;

		////////////////////////

		uvm_reg all_regs[$];
		ral.get_registers(all_regs, UVM_HIER);

		if(`CHIP_NUM == 1)begin

  			`uvm_info(get_full_name(), $psprintf("jls_scoreboard is begin to do jls_jam_datacheck!!!"), UVM_LOW)
	
			fork
				//write mid check
				forever begin
					wait(jls_vif.wait_flag === 1'b1);

					//$display("writeDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD");
					@(posedge jls_vif.psel);

					@(negedge jls_vif.pwrite);
					//$display("@(negedge jls_vif.pwrite);");
					//$display("now time :",$time);

					@(negedge jls_vif.clk);

					if (jls_vif.penable==1'b1)begin
						//$display("jls_vif.penable==1'b1");
						// $display("now time :",$time);

						if(receive_write_mid[0]==32'b1 && jls_vif.paddr==receive_write_mid[1] && jls_vif.pwdata==receive_write_mid[2])begin

							`uvm_info(get_full_name(), $psprintf("write data mid from jamlink to jls check right!!!"), UVM_LOW)
							$display("-------------------------------------------------------");
							$display("now time :",$time);
							$display("\tjls_vif.paddr       		       = 'h%h", jls_vif.paddr);
							$display("\tjls_vif.pwdata      		       = 'h%h", jls_vif.pwdata);
							$display("\treq.we 		                     = 'h%h", receive_write_mid[0]);
							$display("\treq.addr 		                   = 'h%h", receive_write_mid[1]);
							$display("\treq.data                		   = 'h%h", receive_write_mid[2]);
							$display("-------------------------------------------------------");

							receive_write_mid.pop_front;
							receive_write_mid.pop_front;
							receive_write_mid.pop_front;

						end

						else begin

							`uvm_error(get_type_name(), "write data mid from jamlink to jls check wrong!!!");

							$display("-------------------------------------------------------");
							$display("now time :",$time);
							$display("\tjls_vif.paddr       		       = 'h%h", jls_vif.paddr);
							$display("\tjls_vif.pwdata      		       = 'h%h", jls_vif.pwdata);
							$display("\treq.we 		                     = 'h%h", receive_write_mid[0]);
							$display("\treq.addr 		                   = 'h%h", receive_write_mid[1]);
							$display("\treq.data                		   = 'h%h", receive_write_mid[2]);
							$display("-------------------------------------------------------");

							receive_write_mid.pop_front;
							receive_write_mid.pop_front;
							receive_write_mid.pop_front;
							`uvm_info(get_full_name(), $psprintf("simulation finish please check jls_scoreboard!!!"), UVM_LOW)
							$finish;
					
						end
					
					end
				end


				//write x check
				forever begin
					//$display("writeXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
					wait(jls_vif.wait_flag === 1'b1);
					@(posedge jls_vif.xclk_psel);
					@(negedge jls_vif.xclk_pwrite);
					//$display("@(negedge jls_vif.xclk_pwrite);");
					// $display("now time :",$time);

					@(negedge jls_vif.xclk);
					if(jls_vif.xclk_penable==1'b1)begin

						if(receive_write_x[0]==32'b1 && jls_vif.xclk_paddr==receive_write_x[1] && jls_vif.xclk_pwdata==receive_write_x[2])begin
						
							`uvm_info(get_full_name(), $psprintf("write data xclk from jamlink to jls check right!!!"), UVM_LOW)
							$display("-------------------------------------------------------");
							$display("now time :",$time);
							$display("\tjls_vif.xclk_paddr       		   = 'h%h", jls_vif.xclk_paddr);
							$display("\tjls_vif.xclk_pwdata      		   = 'h%h", jls_vif.xclk_pwdata);
							$display("\treq.we 		                     = 'h%h", receive_write_x[0]);
							$display("\treq.addr 		                   = 'h%h", receive_write_x[1]);
							$display("\treq.data                		   = 'h%h", receive_write_x[2]);
							$display("-------------------------------------------------------");

							receive_write_x.pop_front;
							receive_write_x.pop_front;
							receive_write_x.pop_front;

						end
						else begin


							`uvm_error(get_type_name(), "write data xclk from jamlink to jls check wrong!!!");
							$display("-------------------------------------------------------");
							$display("now time :",$time);
							$display("\tjls_vif.xclk_paddr       		   = 'h%h", jls_vif.xclk_paddr);
							$display("\tjls_vif.xclk_pwdata      		   = 'h%h", jls_vif.xclk_pwdata);
							$display("\treq.we 		                     = 'h%h", receive_write_x[0]);
							$display("\treq.addr 		                   = 'h%h", receive_write_x[1]);
							$display("\treq.data                		   = 'h%h", receive_write_x[2]);
							$display("-------------------------------------------------------");

							receive_write_x.pop_front;
							receive_write_x.pop_front;
							receive_write_x.pop_front;
							`uvm_info(get_full_name(), $psprintf("simulation finish please check jls_scoreboard!!!"), UVM_LOW)
							$finish;

						end
					end
				end

				//write std check
				forever begin
					
					wait(jls_vif.wait_flag === 1'b1);
					//$display("writeTTTTTTTTTTTTTTTTTTTTTTTT");
					@(posedge jls_vif.std_psel);
					wait(jls_vif.std_pwrite === 1'b1);
					@(posedge jls_vif.std_pready);
							//$display("=====TTTTTT==WRITE====JLS GET PREADY+++++++++++++++++++Time:",$time);
					@(negedge jls_vif.xclk);
					if((jls_vif.std_penable & jls_vif.std_pready)==1'b1)begin
					
						if(receive_write_std[0]==32'b1 && jls_vif.std_paddr==receive_write_std[1] && jls_vif.std_pwdata==receive_write_std[2])begin
						
							`uvm_info(get_full_name(), $psprintf("write std data from jamlink to jls check right!!!"), UVM_LOW)
							$display("-------------------------------------------------------");
							$display("now time :",$time);
							$display("\tjls_vif.std_paddr       		   = 'h%h", jls_vif.std_paddr);
							$display("\tjls_vif.std_pwdata      		   = 'h%h", jls_vif.std_pwdata);
							$display("\treq.we 		                     = 'h%h", receive_write_std[0]);
							$display("\treq.addr 		                   = 'h%h", receive_write_std[1]);
							$display("\treq.data                		   = 'h%h", receive_write_std[2]);
							$display("-------------------------------------------------------");

							receive_write_std.pop_front;
							receive_write_std.pop_front;
							receive_write_std.pop_front;

						end
						else begin

							`uvm_error(get_type_name(), "write std data from jamlink to jls check wrong!!!");
							$display("-------------------------------------------------------");
							$display("now time :",$time);
							$display("\tjls_vif.std_paddr       		   = 'h%h", jls_vif.std_paddr);
							$display("\tjls_vif.std_pwdata      		   = 'h%h", jls_vif.std_pwdata);
							$display("\treq.we 		                     = 'h%h", receive_write_std[0]);
							$display("\treq.addr 		                   = 'h%h", receive_write_std[1]);
							$display("\treq.data                		   = 'h%h", receive_write_std[2]);
							$display("-------------------------------------------------------");

							receive_write_std.pop_front;
							receive_write_std.pop_front;
							receive_write_std.pop_front;
							`uvm_info(get_full_name(), $psprintf("simulation finish please check jls_scoreboard!!!"), UVM_LOW)
							$finish;

						end
					end
				end		

				//read mid check
				forever begin
					wait(jls_vif.wait_flag === 1'b1);

					@(posedge jls_vif.psel);
					//$display("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
					// $display("now time :",$time);
					@(negedge jls_vif.clk);
					// $display("negedge jls_vif.clk");
					// $display("now time :",$time);
					if(jls_vif.pwrite==1'b0)begin
						@(posedge jls_vif.penable);
						// $display("posedge jls_vif.penable");
						//  $display("now time :",$time);
						@(negedge jls_vif.clk);
						foreach(all_regs[i])begin
							if(jls_vif.paddr == all_regs[i].get_address)begin
								addr_base = all_regs[i].get_address;
								length = all_regs[i].get_n_bits()/32;
								tem_mid.push_back(31'b1);
								tem_mid.push_back(31'b0);
								tem_mid.push_back(jls_vif.paddr);
								tem_mid.push_back(jls_vif.prdata);
							end
						end
						//$display("addr_base=%h",addr_base);
						//$display("length=%h",length);
						//$display("now time :",$time);
						if(jls_vif.paddr > addr_base && jls_vif.paddr <= addr_base +(length-1)*4)begin
							tem_mid.push_back(31'b0);
							tem_mid.push_back(31'b0);
							tem_mid.push_back(jls_vif.paddr);
							tem_mid.push_back(jls_vif.prdata);
						end

						if(tem_mid.size()>=length*4 && tem_mid[0]==32'b1)begin
							// $display("tem_mid.size=%h",tem_mid.size);
							//  $display("now time :",$time);
							while(receive_read_mid.size()!=length*3)begin//
								@(posedge jls_vif.clk);
							end
							// $display("receive_read_mid.size()=%h",receive_read_mid.size());
							// $display("now time :",$time);
							while(receive_read_mid.size()!=0)begin
								//  $display("receive_read_mid.size()=%h",receive_read_mid.size());
								//    $display("now time :",$time);

								if(receive_read_mid[0]==32'b0 && tem_mid[2]==receive_read_mid[1] && tem_mid[3]==receive_read_mid[2])begin
									`uvm_info(get_full_name(), $psprintf("read data mid from jls to jamlink check right!!!"), UVM_LOW)
									$display("-------------------------------------------------------");
									$display("now time :",$time);
									$display("\tjls_vif.paddr       		       = 'h%h", tem_mid[2]);
									$display("\tjls_vif.prdata      		       = 'h%h", tem_mid[3]);
									$display("\treq.we 		                     = 'h%h", receive_read_mid[0]);
									$display("\treq.addr 		                   = 'h%h", receive_read_mid[1]);
									$display("\treq.data                		   = 'h%h", receive_read_mid[2]);
									$display("-------------------------------------------------------");
									receive_read_mid.pop_front;
									receive_read_mid.pop_front;
									receive_read_mid.pop_front;
									tem_mid.pop_front;
									tem_mid.pop_front;
									tem_mid.pop_front;
									tem_mid.pop_front;

								end 
								else begin
										//`uvm_error(get_full_name(), $psprintf("read data mid from jls to jamlink check wrong!!!"), UVM_LOW)
										`uvm_error(get_type_name(), "read data mid from jls to jamlink check wrong!!!");
										$display("-------------------------------------------------------");
										$display("now time :",$time);
										$display("\tjls_vif.paddr       		       = 'h%h", tem_mid[2]);
										$display("\tjls_vif.prdata      		       = 'h%h", tem_mid[3]);
										$display("\treq.we 		                     = 'h%h", receive_read_mid[0]);
										$display("\treq.addr 		                   = 'h%h", receive_read_mid[1]);
										$display("\treq.data                		   = 'h%h", receive_read_mid[2]);
										$display("-------------------------------------------------------");

										receive_read_mid.pop_front;
										receive_read_mid.pop_front;
										receive_read_mid.pop_front;
										tem_mid.pop_front;
										tem_mid.pop_front;
										tem_mid.pop_front;
										tem_mid.pop_front;
										`uvm_info(get_full_name(), $psprintf("simulation finish please check jls_scoreboard!!!"), UVM_LOW)
										$finish;

								end

							end
						end
					end
				end


				//read xclk check
				forever begin
					wait(jls_vif.wait_flag === 1'b1);

					@(posedge jls_vif.xclk_psel);
					// $display("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
					// $display("now time :",$time);
					@(negedge jls_vif.xclk);
					//  $display("negedge jls_vif.clk");
					// $display("now time :",$time);
					if(jls_vif.xclk_pwrite==1'b0)begin
						@(posedge jls_vif.xclk_penable);
						//   $display("posedge jls_vif.penable");
						/// $display("now time :",$time);
						@(posedge jls_vif.xclk);
						foreach(all_regs[i])begin
							if(jls_vif.xclk_paddr == all_regs[i].get_address)begin
								addr_base_x = all_regs[i].get_address;
								length_x = all_regs[i].get_n_bits()/32;
								tem_x.push_back(31'b1);
								tem_x.push_back(31'b0);
								tem_x.push_back(jls_vif.xclk_paddr);
								tem_x.push_back(jls_vif.xclk_prdata);
							end
						end
						// $display("addr_base=%h",addr_base);
						// $display("length=%h",length);
						//$display("now time :",$time);
						if(jls_vif.xclk_paddr > addr_base_x && jls_vif.xclk_paddr <= addr_base_x +(length_x-1)*4)begin
							tem_x.push_back(31'b0);
							tem_x.push_back(31'b0);
							tem_x.push_back(jls_vif.xclk_paddr);
							tem_x.push_back(jls_vif.xclk_prdata);
						end

						if(tem_x.size()>=length_x*4 && tem_x[0]==32'b1)begin
							//$display("tem_mid.size=%h",tem_mid.size);
							//$display("now time :",$time);
							while(receive_read_x.size()!=length_x*3)begin//
								@(posedge jls_vif.xclk);
							end
							// $display("receive_read_x.size()=%h",receive_read_x.size());
							//  $display("now time :",$time);
							while(receive_read_x.size()!=0)begin
								//   $display("receive_read_x.size()=%h",receive_read_x.size());
								//    $display("now time :",$time);

								if(receive_read_x[0]==32'b0 && tem_x[2]==receive_read_x[1] && tem_x[3]==receive_read_x[2])begin
									`uvm_info(get_full_name(), $psprintf("read data xclk from jls to jamlink check right!!!"), UVM_LOW)
									$display("-------------------------------------------------------");
									$display("now time :",$time);
									$display("\tjls_vif.xclk_paddr       		   = 'h%h", tem_x[2]);
									$display("\tjls_vif.xclk_prdata      		   = 'h%h", tem_x[3]);
									$display("\treq.we 		                     = 'h%h", receive_read_x[0]);
									$display("\treq.addr 		                   = 'h%h", receive_read_x[1]);
									$display("\treq.data                		   = 'h%h", receive_read_x[2]);
									$display("-------------------------------------------------------");
									receive_read_x.pop_front;
									receive_read_x.pop_front;
									receive_read_x.pop_front;
									tem_x.pop_front;
									tem_x.pop_front;
									tem_x.pop_front;
									tem_x.pop_front;

								end 
								else begin
									// `uvm_error(get_full_name(), $psprintf("read data xclk from jls to jamlink check wrong!!!"), UVM_LOW)
									`uvm_error(get_type_name(), "read data xclk from jls to jamlink check wrong!!!");

									$display("-------------------------------------------------------");
									$display("now time :",$time);
									$display("\tjls_vif.xclk_paddr       		   = 'h%h", tem_x[2]);
									$display("\tjls_vif.xclk_prdata      		   = 'h%h", tem_x[3]);
									$display("\treq.we 		                     = 'h%h", receive_read_x[0]);
									$display("\treq.addr 		                   = 'h%h", receive_read_x[1]);
									$display("\treq.data                		   = 'h%h", receive_read_x[2]);
									$display("-------------------------------------------------------");

									receive_read_x.pop_front;
									receive_read_x.pop_front;
									receive_read_x.pop_front;
									tem_x.pop_front;
									tem_x.pop_front;
									tem_x.pop_front;
									tem_x.pop_front;
									`uvm_info(get_full_name(), $psprintf("simulation finish please check jls_scoreboard!!!"), UVM_LOW)
									$finish;


								end
							end
						end
					end
				end
				
				//read std check
				forever begin

					wait(jls_vif.wait_flag === 1'b1);
					//$display("readTTTTTTTTTTTTTTTTTTTTTTTT");
					@(posedge jls_vif.std_psel);
					@(negedge jls_vif.xclk);
					//$display("negedge jls_vif.clk");
					//$display("now time :",$time);
					if(jls_vif.std_pwrite==1'b0)begin
						//@(posedge jls_vif.std_penable);
						// $display("posedge jls_vif.penable");
						// $display("now time :",$time);
						@(posedge jls_vif.std_pready);
							//$display("=====TTTTTT==READ====JLS GET PREADY+++++++++++++++++++Time:",$time);
						@(negedge jls_vif.xclk);
						foreach(all_regs[i])begin
							if(jls_vif.std_paddr == all_regs[i].get_address)begin
								addr_base_std = all_regs[i].get_address;
								length_std = all_regs[i].get_n_bits()/32;
								tem_x.push_back(31'b1);
								tem_x.push_back(31'b0);
								tem_x.push_back(jls_vif.std_paddr);
								tem_x.push_back(jls_vif.std_prdata);
							end
						end
						//$display("addr_base_std=%h",addr_base_std);
						//$display("length_std=%h",length_std);
						//$display("now time :",$time);

						if(jls_vif.std_paddr > addr_base_std && jls_vif.std_paddr <= addr_base_std +(length_std-1)*4)begin
							tem_x.push_back(31'b0);
							tem_x.push_back(31'b0);
							tem_x.push_back(jls_vif.std_paddr);
							tem_x.push_back(jls_vif.std_prdata);
						end

						if(tem_x.size()>=length_std*4 && tem_x[0]==32'b1)begin
							//$display("tem_mid.size=%h",tem_mid.size);
							//$display("now time :",$time);
							while(receive_read_std.size()!=length_std*3)begin//
								@(posedge jls_vif.xclk);
							end
							//$display("receive_read_std.size()=%h",receive_read_std.size());
							//$display("now time :",$time);
							while(receive_read_std.size()!=0)begin
								//$display("receive_read_std.size()=%h",receive_read_std.size());
								//$display("now time :",$time);

								if(receive_read_std[0]==32'b0 && tem_x[2]==receive_read_std[1] && tem_x[3]==receive_read_std[2])begin
									`uvm_info(get_full_name(), $psprintf("read data std from jls to jamlink check right!!!"), UVM_LOW)
									$display("-------------------------------------------------------");
									$display("now time :",$time);
									$display("\tjls_vif.std_paddr       		   = 'h%h", tem_x[2]);
									$display("\tjls_vif.std_prdata      		   = 'h%h", tem_x[3]);
									$display("\treq.we 		                     = 'h%h", receive_read_std[0]);
									$display("\treq.addr 		                   = 'h%h", receive_read_std[1]);
									$display("\treq.data                		   = 'h%h", receive_read_std[2]);
									$display("-------------------------------------------------------");
									receive_read_std.pop_front;
									receive_read_std.pop_front;
									receive_read_std.pop_front;
									tem_x.pop_front;
									tem_x.pop_front;
									tem_x.pop_front;
									tem_x.pop_front;

								end 
								else begin
									`uvm_error(get_type_name(), "read data std from jls to jamlink check wrong!!!");

									$display("-------------------------------------------------------");
									$display("now time :",$time);
									$display("\tjls_vif.std_paddr       		   = 'h%h", tem_x[2]);
									$display("\tjls_vif.std_prdata      		   = 'h%h", tem_x[3]);
									$display("\treq.we 		                     = 'h%h", receive_read_std[0]);
									$display("\treq.addr 		                   = 'h%h", receive_read_std[1]);
									$display("\treq.data                		   = 'h%h", receive_read_std[2]);
									$display("-------------------------------------------------------");

									receive_read_std.pop_front;
									receive_read_std.pop_front;
									receive_read_std.pop_front;
									tem_x.pop_front;
									tem_x.pop_front;
									tem_x.pop_front;
									tem_x.pop_front;
									`uvm_info(get_full_name(), $psprintf("simulation finish please check jls_scoreboard!!!"), UVM_LOW)
									$finish;


								end
							end
						end
					end
				end


			join
			
		end
		
	endtask 


	task do_clk_gate_check(ref logic signal,input string name);
		`uvm_info(get_full_name(), $sformatf("now check signal %s",name), UVM_LOW)
		forever begin
			@(posedge jls_vif.tp_sel);	//switch to uart mode
			#0.01ns;
			// $display("now time1  :",$time);

			if(jls_vif.tp_sel==1 && signal ==0)begin

				while(jls_vif.tp_sel==1)begin

					if(signal==1)begin
						`uvm_error(get_type_name(), $sformatf("clk_gate_check wrong"))
						$finish;
						break;
					end
					#0.01ns;
				end
			end

			if(jls_vif.tp_sel==1 && signal ==1)begin
				@(negedge signal);
				// $display("now time4  :",$time);

				#0.01ns;
				if(jls_vif.tp_sel==1 && signal ==0)begin
					while(jls_vif.tp_sel==1)begin
						//$display("now time5  :",$time);

						//#0.0001;
						if(signal==1)begin
							`uvm_error(get_type_name(), $sformatf("clk_gate_check wrong"))
							$finish;
							break;

						end
						#0.01ns;

					end
				end

			end      
		end
	endtask

	task do_uart_clk_gate_check(ref logic signal,input string name);
		`uvm_info(get_full_name(), $sformatf("now check signal %s",name), UVM_LOW)
		forever begin
			@(negedge jls_vif.tp_sel);	//switch to jlm mode
			#0.01ns;
			// $display("now time1  :",$time);

			if(jls_vif.tp_sel==0 && signal ==0)begin

				while(jls_vif.tp_sel==0)begin

					if(signal==1)begin
						`uvm_error(get_type_name(), $sformatf("clk_uart_gate_check wrong"))
						$finish;
						break;
					end
					#0.01ns;
				end
			end

			if(jls_vif.tp_sel==0 && signal ==1)begin
				@(negedge signal);
				//$display("now time4  :",$time);

				#0.01ns;
				if(jls_vif.tp_sel==0 && signal ==0)begin
					while(jls_vif.tp_sel==0)begin
						//$display("now time5  :",$time);

						//#0.0001;
						if(signal==1)begin
							`uvm_error(get_type_name(), $sformatf("clk_uart_gate_check wrong"))
							$finish;
							break;

						end
						#0.01ns;

					end
				end

			end      
		end
	endtask


	task cal_clk_period(ref logic signal,output realtime period_T);
		realtime ts,te;
		fork
			begin
				@(posedge signal);	
				ts=$realtime();
				@(posedge signal);	
				te=$realtime();
				period_T=te-ts;
			end
			begin
				#100000ns;
				`uvm_error(get_type_name(), "freq chk timeout!")
			end
		join_any
		disable fork;
	endtask

	task do_mid_ci_constrain_chk();
		realtime mid_T;
		realtime ci_T;
		forever begin
			#100000ns;
			cal_clk_period(jls_vif.clk,mid_T);
			cal_clk_period(jls_vif.pin_ci,ci_T);
			//`uvm_info(get_full_name(), $psprintf("mid_clk_period=%f, ci_clk_period=%f",mid_T,ci_T), UVM_LOW)
			if(mid_T>(3*ci_T))begin
				`uvm_warning(get_type_name(), "freq constrain between midclk and ci_clk check fail!")
				//$finish();
			end
		end
	endtask

  	task do_cdc_check(ref logic src_sig,ref logic dst_sig,ref logic src_domain_clk,ref logic dst_domain_clk,input string name);
		logic [7:0] cnt;
		logic flag;
		#100ns;
  		`uvm_info(get_full_name(), $psprintf("jls_scoreboard is begin to do %s check!!!",name), UVM_LOW)
		wait(jls_vif.wait_flag === 1'b1);

		forever begin
			cnt  = 8'd64;
			flag = 0;
			@(posedge src_sig);
			@(posedge src_domain_clk);
			do begin
				@(posedge dst_domain_clk);
				if( dst_sig== 1'b1) begin
					flag = 1;
					break;
				end
				cnt = cnt - 1;   		
			end while(cnt > 8'h1);
			
			if(flag == 1'b0) begin
				`uvm_error(get_type_name(), $psprintf("%S cdc check fail!",name))
			end 

		end
		
  	endtask



      //to ECC1 check
  task do_ecc1_check();
    #100ns;
	`ifndef NO_UVM_ECC1_CHK
  		//`uvm_info(get_full_name(), $psprintf("jls_scoreboard is begin to do_ecc1 check!!!"), UVM_LOW)
		forever begin
			wait(jls_vif.t_z_ecc1);
			#2ns;
			wait(~jls_vif.t_z_ecc1);
		  	`uvm_info(get_full_name(), $psprintf("ECC1 check failed, but this transaction can be fixed by JLS DEC part !!!"), UVM_LOW)
		end
	`endif
  endtask

    //to ECC2 check
  task do_ecc2_check();
    //#100ns;
    #`PAD_LOCK_TIME;
	`ifndef NO_UVM_ECC2_CHK
  		//`uvm_info(get_full_name(), $psprintf("jls_scoreboard is begin to do_ecc2 check!!!"), UVM_LOW)
		forever begin
			wait(jls_vif.t_z_ecc2);
			#2ns;
			wait(~jls_vif.t_z_ecc2);
		  	`uvm_error(get_full_name(), $psprintf("ECC2 check failed, please check this transaction is right or not !!!"))
		end
	`endif
  endtask

  //to count ci, get dif data
  task do_ci_cnt();
  	`uvm_info(get_full_name(), $psprintf("jls_scoreboard is begin to do_ci_cnt!!!"), UVM_LOW)
	forever begin

		@(posedge jls_vif.pin_ci);
		if(ci_cnt >= 6'd42 || jls_vif.cur_state == `IDLE) begin
			ci_cnt <= 6'h0;
		end else begin
			ci_cnt <= ci_cnt + 6'h1;
		end
		dif = {dif[49:0],jls_vif.pin_di};

	end
  endtask
  //to check cycle41_di_state, 
  task do_cnt_state();
    `uvm_info(get_full_name(), $psprintf("jls_scoreboard is begin to do_cnt_state!!!"), UVM_LOW)
  	forever begin

  		@(posedge jls_vif.pin_ci);
		if(jls_vif.cur_state == `CMD || jls_vif.cur_state == `ADDR || jls_vif.cur_state == `NOP || jls_vif.cur_state == `INIT || jls_vif.cur_state == `WR) begin
			cycle41_di_state = 1'b1;
		end
  		@(negedge jls_vif.pin_ci);
		if(jls_vif.cur_state == `CMD || jls_vif.cur_state == `ADDR || jls_vif.cur_state == `NOP || jls_vif.cur_state == `INIT || jls_vif.cur_state == `WR) begin
			cycle41_di_state = 1'b1;
		end

	end

  endtask

  task do_ecc_check(input logic [50:0] dif_data, output logic err_detect_t, output logic err_multpl_t, output logic [31:0] data_out);
  	logic [31:0] datain;
	logic [6:0] chkin;
	logic [56:0] dat_in;
	logic [6:0] chkout_int;
	logic [6:0] syndout_int;
	logic [127:0] s_decoded;
	logic [57:0] syndec;
	logic [6:0] fixchk;
	logic [15:0] data_tmp0, data_tmp1, data_tmp2, data_tmp3, data_tmp4, data_tmp5, data_tmp6;
	//forever begin
		datain = dif_data[41:10];
		chkin  = dif_data[6:0];
		dat_in = {25'h0, datain};
		data_tmp0 = {dat_in[0],dat_in[4],dat_in[6],dat_in[7],dat_in[8],dat_in[9],dat_in[11],dat_in[14],dat_in[17],dat_in[18],dat_in[19],dat_in[21],dat_in[26],dat_in[28],dat_in[29],dat_in[31]};
		//dw04_par_gen(data_tmp0, chkout_int[0]);
		data_tmp1 = {dat_in[0],dat_in[1],dat_in[2],dat_in[4],dat_in[6],dat_in[8],dat_in[10],dat_in[12],dat_in[16],dat_in[17],dat_in[18],dat_in[20],dat_in[22],dat_in[24],dat_in[26],dat_in[28]};
		data_tmp2 = {~dat_in[0],dat_in[3],dat_in[4],dat_in[7],dat_in[9],dat_in[10],dat_in[13],dat_in[15],dat_in[16],dat_in[19],dat_in[20],dat_in[23],dat_in[25],dat_in[26],dat_in[29],dat_in[31]};
		data_tmp3 = {~dat_in[0],dat_in[1],dat_in[5],dat_in[6],dat_in[7],dat_in[11],dat_in[12],dat_in[13],dat_in[16],dat_in[17],dat_in[21],dat_in[22],dat_in[23],dat_in[27],dat_in[28],dat_in[29]};
		data_tmp4 = {dat_in[2],dat_in[3],dat_in[4],dat_in[5],dat_in[6],dat_in[7],dat_in[14],dat_in[15],dat_in[18],dat_in[19],dat_in[20],dat_in[21],dat_in[22],dat_in[23],dat_in[30],dat_in[31]};
		data_tmp5 = {dat_in[8],dat_in[9],dat_in[10],dat_in[11],dat_in[12],dat_in[13],dat_in[14],dat_in[15],dat_in[24],dat_in[25],dat_in[26],dat_in[27],dat_in[28],dat_in[29],dat_in[30],dat_in[31]};
		data_tmp6 = {dat_in[0],dat_in[1],dat_in[2],dat_in[3],dat_in[4],dat_in[5],dat_in[6],dat_in[7],dat_in[24],dat_in[25],dat_in[26],dat_in[27],dat_in[28],dat_in[29],dat_in[30],dat_in[31]};
		//generate chkout_int
		dw04_par_gen(data_tmp0, chkout_int[0]);
		dw04_par_gen(data_tmp1, chkout_int[1]);
		dw04_par_gen(data_tmp2, chkout_int[2]);
		dw04_par_gen(data_tmp3, chkout_int[3]);
		dw04_par_gen(data_tmp4, chkout_int[4]);
		dw04_par_gen(data_tmp5, chkout_int[5]);
		dw04_par_gen(data_tmp6, chkout_int[6]);

		//generate syndout_int
		syndout_int = chkout_int ^ chkin;
		//generate s_decoded
		s_decoded = 1 << syndout_int;
		//generate err_detect
		err_detect_t = | syndout_int;
		//generate err_multpl_t
		gen_syndec(s_decoded, syndec, fixchk);
		err_multpl_t = err_detect_t && (~(| {syndec,fixchk}));
		data_out = datain ^ syndec[31:0];



	//end
  endtask

  task do_check();
  	logic [50:0] dif_data;
    `uvm_info(get_full_name(), $psprintf("jls_scoreboard is begin to do_check!!!"), UVM_LOW)

	`ifndef PL_SIM
  		forever begin
			@(negedge jls_vif.pin_ci);
			do_ecc_check(dif, err_detect, err_multpl, correct_data);
			if( (~err_multpl)) begin
				//@(negedge jls_vif.pin_ci);
				if(correct_data != jls_vif.correct_data)
					`uvm_error(get_type_name(), $sformatf("The jls scoreboard dataout is %h, but the actual value is %h!!!",correct_data,jls_vif.correct_data))
			end
		end
	`else
	//logic [50:0] dif_data;
	//dif_data = {9'h0,jls_vif.ecc_datain,3'h0,jls_vif.ecc_chkin};
  		forever begin
			@(negedge jls_vif.pin_ci);

			do_ecc_check(dif, err_detect, err_multpl, correct_data);
			if( (~err_multpl)) begin
				//@(negedge jls_vif.pin_ci);
				`ifndef PL_SIM
				if(correct_data != jls_vif.correct_data)
					`uvm_error(get_type_name(), $sformatf("The jls scoreboard dataout is %h, but the actual value is %h!!!",correct_data,jls_vif.correct_data))
				`endif
			end
		end
	`endif
  		//if()
		
  endtask
 
  task dw04_par_gen(input logic [15:0] data_in, output logic data_out);
	data_out = ^data_in;
  endtask

  task gen_syndec(input logic [127:0] s_decoded, output logic [57:0] syndec, output logic [6:0] fixchk);
       syndec[0] = s_decoded[79];
       syndec[1] = s_decoded[74];
       syndec[2] = s_decoded[82];
       syndec[3] = s_decoded[84];
       syndec[4] = s_decoded[87];
       syndec[5] = s_decoded[88];
       syndec[6] = s_decoded[91];
       syndec[7] = s_decoded[93];
       syndec[8] = s_decoded[35];
       syndec[9] = s_decoded[37];
       syndec[10] = s_decoded[38];
       syndec[11] = s_decoded[41];
       syndec[12] = s_decoded[42];
       syndec[13] = s_decoded[44];
       syndec[14] = s_decoded[49];
       syndec[15] = s_decoded[52];
       syndec[16] = s_decoded[14];
       syndec[17] = s_decoded[11];
       syndec[18] = s_decoded[19];
       syndec[19] = s_decoded[21];
       syndec[20] = s_decoded[22];
       syndec[21] = s_decoded[25];
       syndec[22] = s_decoded[26];
       syndec[23] = s_decoded[28];
       syndec[24] = s_decoded[98];
       syndec[25] = s_decoded[100];
       syndec[26] = s_decoded[103];
       syndec[27] = s_decoded[104];
       syndec[28] = s_decoded[107];
       syndec[29] = s_decoded[109];
       syndec[30] = s_decoded[112];
       syndec[31] = s_decoded[117];
       syndec[32] = s_decoded[94];
       syndec[33] = s_decoded[81];
       syndec[34] = s_decoded[76];
       syndec[35] = s_decoded[73];
       syndec[36] = s_decoded[70];
       syndec[37] = s_decoded[69];
       syndec[38] = s_decoded[67];
       syndec[39] = s_decoded[62];
       syndec[40] = s_decoded[61];
       syndec[41] = s_decoded[59];
       syndec[42] = s_decoded[56];
       syndec[43] = s_decoded[55];
       syndec[44] = s_decoded[50];
       syndec[45] = s_decoded[47];
       syndec[46] = s_decoded[31];
       syndec[47] = s_decoded[13];
       syndec[48] = s_decoded[7];
       syndec[49] = s_decoded[127];
       syndec[50] = s_decoded[124];
       syndec[51] = s_decoded[122];
       syndec[52] = s_decoded[121];
       syndec[53] = s_decoded[118];
       syndec[54] = s_decoded[115];
       syndec[55] = s_decoded[110];
       syndec[56] = s_decoded[97];
       syndec[57] = 1'b0;
	   fixchk[0] = s_decoded[1];
       fixchk[1] = s_decoded[2];
       fixchk[2] = s_decoded[4];
       fixchk[3] = s_decoded[8];
       fixchk[4] = s_decoded[16];
       fixchk[5] = s_decoded[32];
       fixchk[6] = s_decoded[64];
	  
  endtask
endclass :  jls_scoreboard

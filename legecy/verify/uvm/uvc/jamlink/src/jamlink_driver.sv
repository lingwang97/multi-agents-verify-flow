
class jamlink_driver extends uvm_driver#(jamlink_sequence_item);

  uvm_analysis_port #(jamlink_sequence_item) ap;

  `uvm_component_utils(jamlink_driver);

  virtual jamlink_if vif;
  virtual top_if top_vif;  
  jamlink_base_cfg m_cfg;  
  logic [31:0] dof_cmd;
  logic [31:0] dif_cmd;
  logic [31:0] data_o [0:200];
  logic 		we;
  logic [31:0]  addr;
  logic [31:0]  data_t;
  logic [9:0] chipaddr;
  //logic [1:0] bcastsel;
  logic [5:0] mode;
  logic [4:0] chipmask;
  logic       needdly;
  logic [9:0] tranlen;

  function new(string name="jamlink_driver" , uvm_component parent=null);
    super.new(name , parent);
    ap = new("ap", this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual jamlink_if)::get(this , "" , "jamlink_vif" ,vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")

    if (!uvm_config_db #(virtual interface top_if)::get(this, "", "top_vif", top_vif))
      `uvm_error("TOP_VIP:ERROR", "VIF top_vif is missing from config_db")

    if (!uvm_config_db #(jamlink_base_cfg)::get(this, "", "jamlink_config", m_cfg) )
      `uvm_info("CONFIG_LOAD", "Cannot get configuration jamlink_config from uvm_config_db. Have you set it?", UVM_MEDIUM)
  endfunction
  
  task main_phase(uvm_phase phase);
    bit [31:0] data;
    forever
    begin
      wait(~vif.rst);
      reset_signals();
      seq_item_port.get_next_item(req);
      $cast(rsp,req.clone());
      rsp.set_id_info(req);
      do_drive();
      seq_item_port.item_done(rsp);
    end
  endtask
  
  task run_phase(uvm_phase phase);
    jamlink_sequence_item req;
    jamlink_sequence_item rsp;
    bit [31:0] data;
    forever
    begin
	    vif.jlm_stb_i = 0;
		vif.jlm_we_i  = 0;
		vif.jlm_adr_i = 6'h0;
		vif.jlm_dat_i = 32'h0;

		//wait(~vif.rst);
		//reset_signals();
      	seq_item_port.get_next_item(req);
		//set jlm transaction instruction sequence value
		we = req.we;
		addr = req.addr;
		data_t = req.data;

		`ifdef JLM_DATA_DEBUG
			if(req.we == 1'b1) begin
				`uvm_info(get_type_name(),$sformatf("\n %d  Speed_dn mode: reg wr, chip_id = %d, addr = 0x%h, wdata = 0x%h .",$time, top_vif.chipaddr, req.addr, req.data), UVM_LOW)
			end else begin
				`uvm_info(get_type_name(),$sformatf("\n %d  Speed_dn mode: reg rd, chip_id = %d, addr = 0x%h, wdata = 0x%h .",$time, top_vif.chipaddr, req.addr, req.data), UVM_LOW)
			end
		`endif
		
      	//#200_000;
	  	wr_reg(we, addr, data_t, data_o);
		  //`uvm_info(get_type_name(), $sformatf("the efuse.reg_otpcfg.address's value should be %h ",data_o[2]), UVM_MEDIUM);
     	if (we == 0) begin
      		req.data = data_o[4];
			`ifdef JLM_DATA_DEBUG
				`uvm_info(get_type_name(),$sformatf("\n %d  Speed_dn mode:      							    rdata = 0x%h .",$time, req.data), UVM_LOW)
			`endif
   		 end
    	//#10_000;

      	seq_item_port.item_done();
    end
  endtask
  
  task drvm_reg_wr(input [31:0] address, data);
	begin
		@(posedge vif.clk); 
		#0.1ns;
		vif.jlm_stb_i = 0;
		vif.jlm_we_i  = 0;
		vif.jlm_adr_i = address[5:0];
		vif.jlm_dat_i = data;
		@(posedge vif.clk); 
		#0.1ns;
		vif.jlm_stb_i = 1;
		vif.jlm_we_i  = 1;
		vif.jlm_adr_i = address[5:0];
		vif.jlm_dat_i = data;
		@(posedge vif.clk); 
		#0.1ns;
		vif.jlm_stb_i = 0;
		@(posedge vif.clk); 
		#0.1ns;
	end
  endtask

  task drvm_reg_rd(input [31:0] address, output reg [31:0] data);
	begin
		@(posedge vif.clk); 
		#0.1ns;
		vif.jlm_stb_i = 0;
		vif.jlm_we_i  = 0;
		vif.jlm_adr_i = address[5:0];
		vif.jlm_dat_i = $random;
		//vif.jlm_dat_i = 0;
		//$display("=====vif.jlm_dat_i = %h",vif.jlm_dat_i);
		@(posedge vif.clk); 
		#0.1ns;
		vif.jlm_stb_i = 1;
		vif.jlm_we_i  = 0;
		vif.jlm_adr_i = address[5:0];
		vif.jlm_dat_i = $random;

		// vif.jlm_dat_i = 0;
		// $display("vif.jlm_dat_i = %h",vif.jlm_dat_i);

		@(posedge vif.clk); 
		#0.1ns;
		#0.1ns data = vif.jlm_dat_o;
		vif.jlm_stb_i = 0;
		@(posedge vif.clk); 
		#0.1ns;
	end
  endtask

  task wr_reg(input logic we, input logic [31:0] addr, input logic [31:0] data_t, output logic [31:0] data_o [0:200]);
	logic [31:0] data_tmp [0:3];
	logic [31:0] dof_cmd_t;
	logic [31:0] addr_t;
	logic [31:0] fctrl;
	logic [31:0] dif;
	logic [31:0] dif_get[0:200];
	logic [9:0] cmd_len;
	int   num;
	if(we == 1'h0) begin
		mode = 6'h4;
	end else begin
		mode = 6'h2;
	end
	if(vif.init_mode == 1'b1) begin
		mode = 6'h0;
	end
	chipaddr = top_vif.chipaddr;
	//bcastsel = 2'h0;
	chipmask = 5'h0;
    needdly  = 1'h0;
    tranlen  = 10'h1;
 	dof_cmd = {chipaddr,mode,chipmask,needdly,tranlen};
	drvm_reg_rd(32'hc, fctrl);
	while(fctrl[7:0]>52) begin
		drvm_reg_rd(32'hc, fctrl);
	end
	drvm_reg_wr(32'h4, dof_cmd);
	drvm_reg_wr(32'h4, addr);
	drvm_reg_wr(32'h4, 32'h0);
	if(we == 1'b1) begin
		drvm_reg_wr(32'h4, data_t);
	end
	dof_cmd_t = 32'h0;
	addr_t    = 32'h0;
	if(we == 1'b0) begin
		fctrl = 32'h0;
		while(fctrl[23:16] < 8'h3) begin
			drvm_reg_rd(32'hc, fctrl);
		end

		for(num = 0; num < 3; num = num + 1) begin
			drvm_reg_rd(32'h8, dif);
			dif_get[num] = dif;
		end

		for(int i = 0; i < 1; i = i + 1) begin
			drvm_reg_rd(32'hc, fctrl);
			while(fctrl[25]) begin
				drvm_reg_rd(32'hc, fctrl);
			end

			drvm_reg_rd(32'h8, dif);
			num=3;
			dif_get[num] = dif;
            cmd_len = dif[9:0];
			for(int j = 0; j < cmd_len; j = j + 1) begin
				num = num +1;
				drvm_reg_rd(32'hc, fctrl);
				while(fctrl[25]) begin
					drvm_reg_rd(32'hc, fctrl);
				end
				drvm_reg_rd(32'h8, dif);
				dif_get[num] = dif;
			end

		end

	end
	data_o = dif_get;
  endtask


  task do_drive();
      `uvm_info(get_full_name(), "Entering ... " , UVM_FULL)
      @(posedge vif.clk);
      vif.card_sel  <= req.card_sel;
      `uvm_info(get_full_name(), "Exiting ... ", UVM_FULL)
  
  endtask

  task reset_signals();
    vif.card_sel  <= 'h0;
  endtask
  
endclass


class jamlink_new_driver extends jamlink_driver#(jamlink_sequence_item);

  //uvm_analysis_port #(jamlink_sequence_item) ap;


  uvm_table_printer my_printer;
  `uvm_component_utils(jamlink_new_driver);

  virtual jamlink_if vif;
  virtual top_if top_vif;  
  jamlink_base_cfg m_cfg;  
  logic [31:0] dof_cmd;
  logic [31:0] dif_cmd;
  logic [31:0] data_o [0:200];
  logic 		we;
  logic [31:0]  addr;
  logic [31:0]  data_t[0:200];
  logic [31:0]  data_t_60[0:59];
  logic [31:0]  data_o_60[0:59];  
  logic [31:0]  data_tmp;
  logic [31:0]  data_in[$];
  logic [31:0]  data_out[$];
  //logic [200:0] data_t_q;
  logic [9:0] chipaddr;
  //logic [1:0] bcastsel;
  logic [5:0] mode;
  logic [4:0] chipmask;
  logic       needdly;
  logic [9:0] tranlen;
  RAL_PKG::ral_gen_main 	ral;

  
  function new(string name="jamlink_new_driver" , uvm_component parent=null);
    super.new(name , parent);
    //ap = new("ap", this);

  my_printer = new();
  my_printer.knobs.prefix = "  ";
  my_printer.knobs.type_name = 0;
  my_printer.knobs.size = 0;

  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual jamlink_if)::get(this , "" , "jamlink_vif" ,vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")

    if (!uvm_config_db #(virtual interface top_if)::get(this, "", "top_vif", top_vif))
      `uvm_error("TOP_VIP:ERROR", "VIF top_vif is missing from config_db")

    if (!uvm_config_db #(jamlink_base_cfg)::get(this, "", "jamlink_config", m_cfg) )
      `uvm_info("CONFIG_LOAD", "Cannot get configuration jamlink_config from uvm_config_db. Have you set it?", UVM_MEDIUM)

    if(!uvm_config_db#(RAL_PKG::ral_gen_main)::get(this , "" , "ral" ,ral))
      `uvm_fatal(get_full_name(), "Ral handle missing")
	  
  endfunction
  
	task main_phase(uvm_phase phase);
		bit [31:0] data;
		forever
		begin
			wait(~vif.rst);
			reset_signals();
			seq_item_port.get_next_item(req);
			$cast(rsp,req.clone());
			rsp.set_id_info(req);
			do_drive();
			seq_item_port.item_done(rsp);
		end
	endtask
  
	task run_phase(uvm_phase phase);
		jamlink_sequence_item req;
		jamlink_sequence_item rsp;
		bit [31:0] data;
		logic [31:0]  addr_base;
		string reg_name;
		logic [9:0] length;
		logic [9:0] length_cmd;
		logic [8:0] num;
		logic wr_flag;
		logic [5:0] round1_num;
		logic [5:0] round2_num;
		int  bit_start;
		int  bit_end;
		logic [31:0] addr_tmp;
		uvm_reg all_regs[$];
		ral.get_registers(all_regs, UVM_HIER);

		forever begin//8

			vif.jlm_stb_i = 0;
			vif.jlm_we_i  = 0;
			vif.jlm_adr_i = 6'h0;
			vif.jlm_dat_i = 32'h0;

			//wait(~vif.rst);
			//reset_signals();

			seq_item_port.get_next_item(req);
	
			we = req.we;
			addr = req.addr;
			data_tmp = req.data;

			// $display("[JLM_DEBUG]==>req.data= %d",req.data);
			// $display("[JLM_DEBUG]==>req.addr= %d",req.addr);
			// $display("[JLM_DEBUG]==>req.we= %d",req.we);
			foreach(all_regs[i]) begin
				if(all_regs[i].get_address == addr) begin
					addr_base = all_regs[i].get_address;

					// $display("[JLM_DEBUG]==>addr_base= %d",addr_base);
					// $display("[JLM_DEBUG]==>all_regs[i].get_address= %d",all_regs[i].get_address);
					// $display("[JLM_DEBUG]==>addr= %d",addr);

					reg_name = all_regs[i].get_name();
					length = all_regs[i].get_n_bits()/32;		//in order to decrease automaticlly,aim to load all write data into data_in queue
					length_cmd = all_regs[i].get_n_bits()/32;	//remember length 
					// $display("[JLM_DEBUG]==>from uvm reg_name =           %s",reg_name);//
					// $display("[JLM_DEBUG]==>from uvm length_cmd =           %d",length_cmd);//
					num = 9'h4;		//index for rd reg data,skip cfg data
					break;
				end
			end

		


			if(length >0) begin//7
				if(we == 1'b1) begin// jamlink write
					rsp_port.write(req);// *
					//$display("[JLM_DEBUG]==>now time :",$time);
					data_in.push_back(data_tmp);
					//$display("[JLM_DEBUG]==>statrt write  we=1");
					//Begin to write data
					if(length == 10'h1) begin// in order load all wr reg data ==> queue data_in

						foreach(data_t_60[i]) begin
							data_t_60[i] = 32'h0;
						end

						foreach(data_t[i]) begin
							data_t[i] = 32'h0;
						end

						foreach(data_in[i]) begin
							data_t[i] = data_in[i];
						end

						round1_num = length_cmd / 50; //batch fifo trans,50<60,make sure fifo not overflow
						round2_num = length_cmd % 50;
						addr_tmp  = addr_base;
						bit_start = 0;
						bit_end = 0;
						if((round1_num>0) && (round2_num>0)) begin	//include complete fifo round &&incomplete fifo round

							for(int i= 0; i<round1_num; i = i + 1) begin
								addr_tmp = addr_base + i * 50*4;
								bit_start = i*50;
								bit_end = (i+1)*50-1;

								for(int num_t = bit_start; num_t <= bit_end ;num_t = num_t+1) begin
									data_t_60[num_t%50] = data_t[num_t];
								end

								wr_reg_w(reg_name, 50, we, addr_tmp, data_t_60, data_o_60);
							end

							addr_tmp = addr_tmp + 50*4 ;
							bit_start = bit_end + 1;
							bit_end = bit_start + round2_num-1;

							for(int num_t = bit_start; num_t <= bit_end ;num_t = num_t+1)begin
								data_t_60[num_t%50]=data_t[num_t];
							end
							wr_reg_w(reg_name, round2_num, we, addr_tmp, data_t_60, data_o_60);
						end

						if((round1_num>0) && (round2_num==0))begin		//Divisible by 50
							//$display("[JLM_DEBUG]==>write state 2");
							for(int i= 0; i< round1_num; i = i + 1) begin
								addr_tmp = addr_base + i * 50*4;
								bit_start = i*50;
								bit_end = (i+1)*50-1;

								for(int num_t = bit_start; num_t <= bit_end ;num_t = num_t+1) begin
									data_t_60[num_t%50] = data_t[num_t];
								end

								wr_reg_w(reg_name, 50, we, addr_tmp, data_t_60, data_o_60);
							end
						end

						if(round1_num==0) begin		//wr_len<50,total data canbe trans once 
							//$display("[JLM_DEBUG]==>write state 3");
							addr_tmp = addr_base;
							bit_start = 0;
							bit_end = round2_num-1;
							for(int num_t = bit_start; num_t <= bit_end ;num_t = num_t+1)begin
								data_t_60[num_t%50]=data_t[num_t];
							end              

							//$display("[JLM_DEBUG]==>write state3 begin");//
							wr_reg_w(reg_name, round2_num, we, addr_tmp, data_t_60, data_o_60);
						end             
						//$display("[JLM_DEBUG]==>write end");//
						data_in.delete();						
					end
				end 
			
				else begin // jamlink read

					if(length == length_cmd) begin
						foreach(data_o[i]) begin
							data_o[i] = 32'h0;
						end
						//$display("[JLM_DEBUG]==>statrt read ");//
						//Begin to read data
						round1_num = length_cmd / 50;
						round2_num = length_cmd % 50;
						addr_tmp  = addr_base;
						bit_start = 0;
						bit_end = 0;
						//$display("[JLM_DEBUG]==>round1_num= %d",round1_num);//
						//$display("[JLM_DEBUG]==>round2_num= %d",round2_num);//
						//$display("[JLM_DEBUG]==>addr_tmp= %h",addr_tmp);//

						if((round1_num>0) && (round2_num>0)) begin
							//$display("[JLM_DEBUG]==>read state 1");//
							for(int i= 0; i< round1_num; i = i + 1) begin
								addr_tmp = addr_base + i * 50*4;
								//$display("[JLM_DEBUG]==>read state 1 addr_tmp1= %h",addr_tmp);//
								bit_start = i*50;
								bit_end = (i+1)*50-1;
								//$display("[JLM_DEBUG]==>bit_start=  %d",bit_start);//
								//$display("[JLM_DEBUG]==>bit_end=  %d",bit_end);//

								wr_reg_w(reg_name, 50, we, addr_tmp, data_t_60, data_o_60);

								if(i==0) begin
									for(int cfg_index = 0; cfg_index < 4 ; cfg_index = cfg_index + 1) begin
										data_o[cfg_index] = data_o_60[cfg_index];
									end
								end

								for(int num_t = bit_start; num_t <= bit_end ;num_t = num_t+1) begin//
									data_o[num_t+4] = data_o_60[4+num_t%50];
								end
							end

							addr_tmp = addr_tmp + 50*4 ;

							//$display("[JLM_DEBUG]==>read state 1  addr_tmp2= %h",addr_tmp);//
							bit_start = bit_end + 1;
							bit_end = bit_start + round2_num-1;
							//$display("[JLM_DEBUG]==>bit_start=  %d",bit_start);//
							//$display("[JLM_DEBUG]==>bit_end=  %d",bit_end);//

							wr_reg_w(reg_name, round2_num, we, addr_tmp, data_t_60, data_o_60);
							for(int num_t = bit_start; num_t <= bit_end ;num_t = num_t+1) begin//important    
								data_o[num_t+4] = data_o_60[4+num_t%50];
							end
						end


						if((round1_num>0) && (round2_num==0))begin

							//$display("[JLM_DEBUG]==>read state 2");//
							for(int i= 0; i< round1_num; i = i + 1) begin
								addr_tmp = addr_base + i * 50*4;
								//$display("[JLM_DEBUG]==>read state 2 addr_tmp1= %h",addr_tmp);//

								bit_start = i*50;
								bit_end = (i+1)*50-1;
								wr_reg_w(reg_name, 50, we, addr_tmp, data_t_60, data_o_60);
								if(i==0) begin
									for(int cfg_index = 0; cfg_index < 4 ; cfg_index = cfg_index + 1) begin
										data_o[cfg_index] = data_o_60[cfg_index];
									end
								end

								for(int num_t = bit_start; num_t <= bit_end ;num_t = num_t+1) begin
									data_o[num_t+4] = data_o_60[4+num_t%50];
								end

							end                                                  
						end

						if(round1_num==0)begin

							//$display("[JLM_DEBUG]==>read state 3");//
							addr_tmp = addr_base;
							//$display("[JLM_DEBUG]==>read state 3 addr_tmp1= %h",addr_tmp);//

							bit_start = 0;
							bit_end = round2_num-1;
							wr_reg_w(reg_name, round2_num, we, addr_tmp, data_t_60, data_o_60);
							for(int num_t = bit_start; num_t <= bit_end+4 ;num_t = num_t+1) begin
								data_o[num_t] = data_o_60[num_t%50];
							end
						end

					end//5

					req.data = data_o[num];      
					rsp_port.write(req);// *
					//$display();
					//$display("[JLM_DEBUG]==>now time :",$time);

				end//6

				//req.data=521521;
				//rsp_port.write(req);// *

				num = num + 1'b1;		//index ++ for get next reg data
				length = length -1;  //trans done for follow print
				seq_item_port.item_done();
				#5ns;
				if(length == 10'h0) begin//4
					foreach(all_regs[i]) begin//3
						if(all_regs[i].get_address == addr_base) begin//2
							if(we == 1'b0) begin
								//$display("[JLM_DEBUG]==> After read, the %s output info:",reg_name);
								//all_regs[i].print();
								$display("  ----------------------------------------------------");
								$display("  | Register     Read           Time:",$time);
								all_regs[i].print(my_printer);
								break;
							end
							else begin//1
								//$display("[JLM_DEBUG]==>After write, the %s output info:",reg_name);
								//all_regs[i].print();
								$display("  -----------------------------------------------------");
								$display("  | Register     Write           Time:",$time);
								all_regs[i].print(my_printer);
								break;

							end//1
						end //2
					end//3
				end//4


			end//7
		end//8

	endtask
  

	task wr_reg_w(input string reg_name, input logic [9:0] len, input logic we, input logic [31:0] addr, input logic [31:0] data_t[0:59], output logic [31:0] data_o [0:59]);
	logic [31:0] data_tmp [0:3];
	logic [31:0] dof_cmd_t;
	logic [31:0] addr_t;
	logic [31:0] fctrl;
	logic [31:0] dif;
	logic [31:0] dif_get[0:200];
	logic [9:0] cmd_len;
	int   num;

	foreach(dif_get[i]) begin
		dif_get[i] = 32'h0;
	end

	if(we == 1'h0) begin
		mode = 6'h4;
	end else begin
		mode = 6'h2;
	end
	if(vif.init_mode == 1'b1) begin
		mode = 6'h0;
	end

	chipaddr = top_vif.chipaddr;
	//bcastsel = 2'h0;
	chipmask = 5'h0;
	needdly  = 1'h0;
	//tranlen  = 10'h1;
	tranlen = len;
	dof_cmd = {chipaddr,mode,chipmask,needdly,tranlen};
	drvm_reg_rd(32'hc, fctrl);
	while(fctrl[7:0]>5) begin
		drvm_reg_rd(32'hc, fctrl);
	end
	drvm_reg_wr(32'h4, dof_cmd);
	drvm_reg_wr(32'h4, addr);
	drvm_reg_wr(32'h4, 32'h0);
	if(we == 1'b1) begin
		for(int i=0;i<tranlen;i++) begin
			//fctrl = 32'h0;
	//		drvm_reg_rd(32'hc, fctrl);
	//			while(fctrl[7:0] > 8'd2) begin
	//				drvm_reg_rd(32'hc, fctrl);
	//			end	
			drvm_reg_wr(32'h4, data_t[i]);
		end
	end
	dof_cmd_t = 32'h0;
	addr_t    = 32'h0;
	if(we == 1'b0) begin
		fctrl = 32'h0;
		while(fctrl[23:16] < 8'h3) begin
			drvm_reg_rd(32'hc, fctrl);
		end

		for(num = 0; num < 3; num = num + 1) begin
			drvm_reg_rd(32'h8, dif);
			dif_get[num] = dif;
		end

		for(int i = 0; i < 1; i = i + 1) begin
			drvm_reg_rd(32'hc, fctrl);
			while(fctrl[25]) begin
				drvm_reg_rd(32'hc, fctrl);
			end

			drvm_reg_rd(32'h8, dif);
			num=3;
			dif_get[num] = dif;
			cmd_len = dif[9:0];
			for(int j = 0; j < cmd_len; j = j + 1) begin

				num = num +1;
				drvm_reg_rd(32'hc, fctrl);

				while(fctrl[25]) begin
					drvm_reg_rd(32'hc, fctrl);
				end

				drvm_reg_rd(32'h8, dif);
		

				dif_get[num] = dif;
			end

		end

	end

	`ifdef USE_JAMLINK_DRV
		//$display("top_vif.cpft_print_flag value is %d",top_vif.cpft_print_flag);
		if(top_vif.cpft_print_flag == 1'b0) begin
		//$display("print no cpft ");
			print_jlm_trans(reg_name, we, dof_cmd, addr, data_t[0:59], dif_get);

		end else begin 
			cpft_print_jlm_trans(reg_name, we, dof_cmd, addr, data_t[0:59], dif_get);
		end
	`endif

	data_o = dif_get[0:59];
	endtask

	task wr_reg(input string reg_name, input logic [9:0] len, input logic we, input logic [31:0] addr, input logic [31:0] data_t[0:200], output logic [31:0] data_o [0:200]);
	logic [31:0] data_tmp [0:3];
	logic [31:0] dof_cmd_t;
	logic [31:0] addr_t;
	logic [31:0] fctrl;
	logic [31:0] dif;
	logic [31:0] dif_get[0:200];
	logic [9:0] cmd_len;
	int   num;

	foreach(dif_get[i]) begin
		dif_get[i] = 32'h0;
	end

	if(we == 1'h0) begin
		mode = 6'h4;
	end else begin
		mode = 6'h2;
	end
	if(vif.init_mode == 1'b1) begin
		mode = 6'h0;
	end

	chipaddr = top_vif.chipaddr;
	//bcastsel = 2'h0;
	chipmask = 5'h0;
	needdly  = 1'h0;
	//tranlen  = 10'h1;
	tranlen = len;
	dof_cmd = {chipaddr,mode,chipmask,needdly,tranlen};
	drvm_reg_rd(32'hc, fctrl);
	while(fctrl[7:0]>30) begin
		drvm_reg_rd(32'hc, fctrl);
	end
	drvm_reg_wr(32'h4, dof_cmd);
	drvm_reg_wr(32'h4, addr);
	drvm_reg_wr(32'h4, 32'h0);
	if(we == 1'b1) begin
		for(int i=0;i<tranlen;i++) begin
			//fctrl = 32'h0;
			drvm_reg_rd(32'hc, fctrl);
			while(fctrl[7:0] > 8'd62) begin
				drvm_reg_rd(32'hc, fctrl);
			end	
			drvm_reg_wr(32'h4, data_t[i]);
		end
	end
	dof_cmd_t = 32'h0;
	addr_t    = 32'h0;
	if(we == 1'b0) begin
		fctrl = 32'h0;
		while(fctrl[23:16] < 8'h3) begin
			drvm_reg_rd(32'hc, fctrl);
		end

		for(num = 0; num < 3; num = num + 1) begin
			drvm_reg_rd(32'h8, dif);
			dif_get[num] = dif;
		end

		for(int i = 0; i < 1; i = i + 1) begin
			drvm_reg_rd(32'hc, fctrl);
			while(fctrl[25]) begin
				drvm_reg_rd(32'hc, fctrl);
			end

			drvm_reg_rd(32'h8, dif);
			num=3;
			dif_get[num] = dif;
			cmd_len = dif[9:0];
			for(int j = 0; j < cmd_len; j = j + 1) begin
				num = num +1;
				drvm_reg_rd(32'hc, fctrl);
				while(fctrl[25]) begin
					drvm_reg_rd(32'hc, fctrl);
				end
				drvm_reg_rd(32'h8, dif);
				dif_get[num] = dif;
			end

		end

	end
	//print jlm transaction info

	`ifdef USE_JAMLINK_DRV
		//$display("top_vif.cpft_print_flag value is %d",top_vif.cpft_print_flag);
		if(top_vif.cpft_print_flag == 1'b0) begin
		//$display("print no cpft ");
			print_jlm_trans(reg_name, we, dof_cmd, addr, data_t[0:59], dif_get);

		end else begin 
			//$display("print  cpft ");
			cpft_print_jlm_trans(reg_name, we, dof_cmd, addr, data_t[0:59], dif_get);
		end
	`endif

	data_o = dif_get;
	endtask

	task print_jlm_trans(input string reg_name, input logic we, input logic [31:0] cmd_data, input logic [31:0] addr, input logic [31:0] data_wdata [0:59], input logic [31:0] data_rdata [0:200]);
		if(we == 1'b0) begin
			`uvm_info(get_type_name(),$sformatf("\n-------------------------------------------------------"), UVM_LOW)
			$display("Jamlink read loop transaction data print info begin");
    	end 
		else begin 
			`uvm_info(get_type_name(),$sformatf("\n-------------------------------------------------------"), UVM_LOW)
			$display("Jamlink write transaction data print info begin");
		end
      	$display("\treg_name               =  %s", reg_name);
		if(we == 1'b0) begin
			$display("\ttranlen  		       = 'd%0d", data_rdata[3][9:0]);
		end 
		else begin 
			$display("\ttranlen  		       = 'd%0d", cmd_data[9:0]);
		end

		$display("\tneeddly     		   = 'h%h", cmd_data[10]);
		$display("\tchipmask 		       = 'h%h", cmd_data[15:11]);
		$display("\tmode    		       = 'h%h", cmd_data[21:16]);
		//$display("\tbcastsel 		       = 'h%h", cmd_data[23:22]);
		$display("\tchipaddr 		       = 'h%h", cmd_data[31:22]);
		$display("\tcmd      		       = 'h%h", cmd_data);
		$display("\treg_addr	       	   = 'h%h", addr);

		if(we === 1'b1) begin
			for(int i = 0; i < cmd_data[9:0]; i++) begin
				$display("\ttran_data[%0d]		    = 'h%h", i, data_wdata[i]);
			end
			$display("Jamlink write transaction data print info end");
			$display("-------------------------------------------------------");
		end 
		else begin
			for(int i = 0; i < data_rdata[3][9:0]+4; i++) begin
				if(i ==0)
					$display("\ttran_data[%0d]		    = 'h%h,\t[cmd_data],should equal to cmd_data above", i, data_rdata[i]);
				else if(i ==1)
					$display("\ttran_data[%0d]		    = 'h%h,\t[reg_addr_data],should equal to reg_addr above", i, data_rdata[i]);
				else if(i ==2)
					$display("\ttran_data[%0d]		    = 'h%h,\t[Nop_data]", i, data_rdata[i]);
				else if(i ==3)
					$display("\ttran_data[%0d]		    = 'h%h,\t[len_data]", i, data_rdata[i]);
				else
					$display("\ttran_data[%0d]		    = 'h%h,\treg_rdata[%0d]", i, data_rdata[i],(i-4));
			end	
			$display("Jamlink read transaction data print info end");
			$display("-------------------------------------------------------");	
		end

	endtask

	task cpft_print_jlm_trans(input string reg_name, input logic we, input logic [31:0] cmd_data, input logic [31:0] addr, input logic [31:0] data_wdata [0:59], input logic [31:0] data_rdata [0:200]);
		
		if(we == 1'b1) begin
      		for(int i = 0; i < cmd_data[9:0]; i++) begin
				$display("\t %d ns Speed_dn mode: reg wr, addr = 0x%h, wdata = 0x%h, name = %s. ", $time, addr+4*i, data_wdata[i], reg_name);
      		end
		end else begin
      		for(int i = 0; i < data_rdata[3][9:0]; i++) begin
				$display("\t %d ns Speed_dn mode: reg rd, addr = 0x%h, rdata = 0x%h, name = %s. ", $time, addr+4*i, data_rdata[i+4], reg_name);
				//$display("\ttran_data[%0d]		    = 'h%h", i, data_rdata[i+4]);
      		end	

		end
	endtask


endclass




/*  ============================================================  */
/*  ==========================     jamlink     =====================  */
/*  ============================================================  */
/*
parameter A_CTRL   = 32'h00;
parameter A_DOF    = 32'h04;
parameter A_DIF    = 32'h08;
parameter A_FCTRL  = 32'h0c;
parameter A_DLY    = 32'h10;
parameter A_CFG    = 32'h14;
parameter A_INT    = 32'h18;
parameter A_ECC0   = 32'h1c;
parameter A_ECC1   = 32'h20;
parameter A_ECC2   = 32'h24;
*/

task jlm_reg_wr(input logic [31:0] address, input logic [31:0] data);
begin
	@(posedge jamlink_vif.clk);
	#0.1;
	uvm_hdl_force("tb_top.jlm.JLM_STB_I", 1'b0);
	uvm_hdl_force("tb_top.jlm.JLM_WE_I",  1'b0);
	uvm_hdl_force("tb_top.jlm.JLM_ADR_I", address[5:0]);
	uvm_hdl_force("tb_top.jlm.JLM_DAT_I", data);
	@(posedge jamlink_vif.clk);
	#0.1;
	uvm_hdl_force("tb_top.jlm.JLM_STB_I", 1'b1);
	uvm_hdl_force("tb_top.jlm.JLM_WE_I",  1'b1);
	uvm_hdl_force("tb_top.jlm.JLM_ADR_I", address[5:0]);
	uvm_hdl_force("tb_top.jlm.JLM_DAT_I", data);
	@(posedge jamlink_vif.clk);
	#0.1;
	uvm_hdl_force("tb_top.jlm.JLM_STB_I", 1'b0);
	@(posedge jamlink_vif.clk);
	#0.1;
	uvm_hdl_release("tb_top.jlm.JLM_STB_I");
	uvm_hdl_release("tb_top.jlm.JLM_WE_I");
	uvm_hdl_release("tb_top.jlm.JLM_ADR_I");
	uvm_hdl_release("tb_top.jlm.JLM_DAT_I");
end
endtask

task jlm_reg_rd(input logic [31:0] address, output logic [31:0] data);
begin
	@(posedge jamlink_vif.clk);
	#0.1;
	uvm_hdl_force("tb_top.jlm.JLM_STB_I", 1'b0);
	uvm_hdl_force("tb_top.jlm.JLM_WE_I",  1'b0);
	uvm_hdl_force("tb_top.jlm.JLM_ADR_I", address[5:0]);
	uvm_hdl_force("tb_top.jlm.JLM_DAT_I", 32'h0);
	@(posedge jamlink_vif.clk);
	#0.1;
	uvm_hdl_force("tb_top.jlm.JLM_STB_I", 1'b1);
	uvm_hdl_force("tb_top.jlm.JLM_WE_I",  1'b0);
	uvm_hdl_force("tb_top.jlm.JLM_ADR_I", address[5:0]);
	uvm_hdl_force("tb_top.jlm.JLM_DAT_I", 32'h0);
	@(posedge jamlink_vif.clk);
	#0.2;
	uvm_hdl_read("tb_top.API_DAT_O", data);
	uvm_hdl_force("tb_top.jlm.JLM_STB_I", 1'b0);
	@(posedge jamlink_vif.clk);
	#0.1;
	uvm_hdl_release("tb_top.jlm.JLM_STB_I");
	uvm_hdl_release("tb_top.jlm.JLM_WE_I");
	uvm_hdl_release("tb_top.jlm.JLM_ADR_I");
	uvm_hdl_release("tb_top.jlm.JLM_DAT_I");
end
endtask

//init jlm ecc register group
task initm_wb_eccs_jlm();
	//config ecc0 register
	jlm_reg_wr(32'h1c, 32'h0);
	//config ecc1 register
	jlm_reg_wr(32'h20, 32'h0);
	//config ecc2 register
	jlm_reg_wr(32'h24, 32'h0);
	#1000;
endtask

task initm_jlm();
	//origin task initm
	//config dly register
	jlm_reg_wr(32'h10, 32'h64);
	//init jlm ecc register group
	initm_wb_eccs_jlm();
    //config jlm cfg register
	jlm_reg_wr(32'h14, 32'h2_0002);
    #1000;
    //config jlm ctl register
	jlm_reg_wr(32'h0, 32'hf);
	#10000;
endtask

task initc_chipaddr_jlm(input bit [9:0] chip_id = 0);
  	logic [31:0] dof_cmd;
  	logic [31:0] fctrl;
    bit [9:0] chip_id_reverse;
    bit [31:0] chip_enum;

    chip_id_reverse = {<<{chip_id}};
  	//`uvm_info(get_type_name(), $sformatf("Chip_id = 'b%b, chip_id_reverse = 'b%b", chip_id, chip_id_reverse),UVM_LOW)
    chip_enum = (chip_id_reverse<<22);
  	`uvm_info(get_type_name(), $sformatf("Chip_id = 'b%b, Chip_enum = 'h%0h", chip_id, chip_enum),UVM_LOW)

  	`uvm_info(get_type_name(), $sformatf("Chip_id enum initialization begin !!!"),UVM_LOW)
  
  	dof_cmd = {10'h3ff,6'h0,5'h0,1'h0,10'h1};
  	jlm_reg_rd(32'hc, fctrl);
  	while(fctrl[7:0] > 52) begin
  		jlm_reg_rd(32'hc, fctrl);
  	end
  	jlm_reg_wr(32'h4, dof_cmd);
  	jlm_reg_wr(32'h4, 32'h0);
  	jlm_reg_wr(32'h4, 32'h0);
  	jlm_reg_wr(32'h4, chip_enum);
  	if(`CHIP_NUM > 8'd1)  begin
  	   //`uvm_info(get_type_name(), $sformatf("HHHHHHHHHHHHHHHHHHHHHH_____HHHHHHHHHH !!!"),UVM_LOW)		
		#5_000;
	end else begin
  		#6_0000;
	end

  	`uvm_info(get_type_name(), $sformatf("Chip_id enum initialization end !!!"),UVM_LOW)
  
endtask:initc_chipaddr_jlm

task waitm_wb_do_empty_jlm();
	logic [31:0] jlm_rd_reg;
	logic [7:0]  jlm_dofcnt;
	jlm_reg_rd(32'h0c, jlm_rd_reg);
	jlm_dofcnt = jlm_rd_reg[7:0];
	while(jlm_dofcnt !== 0) begin
		jlm_reg_rd(32'h0c, jlm_rd_reg);
		jlm_dofcnt = jlm_rd_reg[7:0];	
	end

	#20000;
endtask

task rd_noncebuf_fifo(input logic [1:0] bsel, input logic [4:0] cmask, output logic [31:0] rd_nonce_buf[254:0][24:0]);
  	logic [31:0] 	dof_cmd, dif;
	logic [31:0]    dif_get[0:10];	
  	logic [31:0] 	dif_cmd;
  	logic [31:0] 	data_o [0:200];
  	logic [31:0]  	addr;
  	logic [31:0]  	data_t;
  	logic [9:0] 	chipaddr;
  	//logic [1:0] 	bcastsel;
  	logic [5:0] 	mode;
  	logic [4:0] 	chipmask;
  	logic       	needdly;
  	logic [9:0] 	tranlen;
	logic [31:0] 	fctrl;
	int             num, addchip, read_pkg_cnt_pre, read_pkg_cnt;
	logic [31:0]    nonce_buf[254:0][24:0];
	logic [4:0]     fchip;
    reg [7:0] chipnum;
	logic [9:0] cmd_len;
	


	//config dof_cmd
	chipaddr	=	`BRD_ADDR;
	//bcastsel	=   bsel;
	mode		=   6'h4;
	chipmask    =   cmask;
	needdly		=	1'b0;
	tranlen     =   10'h1;
	dof_cmd = {chipaddr,mode,chipmask,needdly,tranlen};
	jlm_reg_rd(32'hc, fctrl);
	while(fctrl[7:0]>52) begin
		jlm_reg_rd(32'hc, fctrl);
	end
	//set jlm transaction cmd sequence value
	jlm_reg_wr(32'h4, dof_cmd);
	//set jlm transaction addr sequence value, just noncebuf addr
	jlm_reg_wr(32'h4, 32'ha0);
	//set jlm transaction nop sequence value
	jlm_reg_wr(32'h4, 32'h0);
	
	//begin to get read data
	fctrl = 32'h0;
	while(fctrl[23:16] < 8'h3) begin
		jlm_reg_rd(32'hc, fctrl);
	end
	for(num = 0; num < 3; num = num + 1) begin
		jlm_reg_rd(32'h8, dif);
		dif_get[num] = dif;
	end
	/*
	num = 3;
	for(int i = 0; i < 1; i = i+1) begin
		jlm_reg_rd(32'hc, fctrl);
		while(fctrl[25]) begin
			jlm_reg_rd(32'hc, fctrl);
		end
	end
	jlm_reg_rd(32'h8, dif);
	dif_get[num] = dif;
	*/
	//num = num +1;
	`uvm_info(get_type_name(), $sformatf("The dof_cmd is %h", dif_get[0]),UVM_LOW)
	`uvm_info(get_type_name(), $sformatf("The addr is %h", dif_get[1]),UVM_LOW)
	`uvm_info(get_type_name(), $sformatf("The nop is %h", dif_get[2]),UVM_LOW)
	`uvm_info(get_type_name(), $sformatf("The rfu is %h", dif_get[3]),UVM_LOW)

	`uvm_info(get_type_name(), "Start to broadcast read noncebuf reg!",UVM_LOW)
	 chipnum    = `CHIP_NUM;
	for(int i = 0; i < chipnum; i = i + 1) begin
		//`uvm_info(get_type_name(), $sformatf("The chip_id is %d", fchip+addchip*i), UVM_LOW)
		jlm_reg_rd(32'hc, fctrl);
		while(fctrl[25]) begin
			jlm_reg_rd(32'hc, fctrl);
		end
		jlm_reg_rd(32'h8, dif);
		nonce_buf[i][0] = dif;
		cmd_len = dif[9:0];
		//`uvm_info(get_type_name(), $sformatf("The chip_id is %d", fchip+addchip*i), UVM_LOW)
		if(dif[31:22] != i) begin
			`uvm_error(get_type_name(), $sformatf("The true chip_id is %d, but read chip_id is %d!!!", dif[31:22], i))
		end
		for(int j = 1; j < cmd_len+1; j = j + 1) begin
			//#100;
			jlm_reg_rd(32'hc, fctrl);
			while(fctrl[25]) begin
				jlm_reg_rd(32'hc, fctrl);
			end
			jlm_reg_rd(32'h8, dif);
			//dif_get[num] = dif;
			nonce_buf[i][j] = dif;
		end
	end
	for(int i = 0; i < chipnum; i = i + 1) begin
		`uvm_info(get_type_name(), $sformatf("The chip_id is %d", i), UVM_LOW)
		for(int j = 0; j < cmd_len+1; j = j + 1) begin
			`uvm_info(get_type_name(), $sformatf("The nonce_buf[%d][%d] is %h", i,j,nonce_buf[i][j]),UVM_LOW)

		end
	end
	
	rd_nonce_buf = nonce_buf;
	
endtask

task rd_reg_fifo(input logic [1:0] bsel=0, input logic [4:0] cmask=0, input logic [31:0] addr, input logic [8:0] len, output logic [31:0] rd_reg_buf[254:0][379:0]);
  	logic [31:0] 	dof_cmd, dif;
	logic [31:0]    dif_get[0:10];	
  	logic [31:0] 	dif_cmd;
  	logic [31:0] 	data_o [0:200];
  	logic [31:0]  	data_t;
  	logic [9:0] 	chipaddr;
  	//logic [1:0] 	bcastsel;
  	logic [5:0] 	mode;
  	logic [4:0] 	chipmask;
  	logic       	needdly;
  	logic [9:0] 	tranlen;
	logic [31:0] 	fctrl;
	int             num, addchip, read_pkg_cnt_pre, read_pkg_cnt;
	logic [31:0]    reg_fifo[254:0][379:0];
	logic [4:0]     fchip;
    reg [7:0] chipnum;
	logic [9:0] cmd_len;
	

`ifdef USE_JAMLINK_DRV
	//config dof_cmd
	chipaddr	=	`BRD_ADDR;
	//bcastsel	=   bsel;
	mode		=   6'h4;
	chipmask    =   cmask;
	needdly		=	1'b0;
	tranlen     =   len;
	//			[31:24], [23:22],  [21:16], [15:11], [10],     [9:0]
	dof_cmd = {chipaddr, mode,   chipmask, needdly, tranlen};
	jlm_reg_rd(32'hc, fctrl);
	while(fctrl[7:0]>52) begin
		jlm_reg_rd(32'hc, fctrl);
	end
	//set jlm transaction cmd sequence value
	jlm_reg_wr(32'h4, dof_cmd);
	//set jlm transaction addr sequence value, just noncebuf addr
	jlm_reg_wr(32'h4, addr);
	//set jlm transaction nop sequence value
	jlm_reg_wr(32'h4, 32'h0);
	
	//begin to get read data
	fctrl = 32'h0;
	while(fctrl[23:16] < 8'h3) begin
		jlm_reg_rd(32'hc, fctrl);
	end
	for(num = 0; num < 3; num = num + 1) begin
		jlm_reg_rd(32'h8, dif);
		dif_get[num] = dif;
	end
	/*
	num = 3;
	for(int i = 0; i < 1; i = i+1) begin
		jlm_reg_rd(32'hc, fctrl);
		while(fctrl[25]) begin
			jlm_reg_rd(32'hc, fctrl);
		end
	end
	jlm_reg_rd(32'h8, dif);
	dif_get[num] = dif;
	*/
	//num = num +1;
	`uvm_info(get_type_name(), $sformatf("The dof_cmd is %h", dif_get[0]),UVM_LOW)
	`uvm_info(get_type_name(), $sformatf("The addr is %h", dif_get[1]),UVM_LOW)
	`uvm_info(get_type_name(), $sformatf("The nop is %h", dif_get[2]),UVM_LOW)
	`uvm_info(get_type_name(), $sformatf("The rfu is %h", dif_get[3]),UVM_LOW)

	`uvm_info(get_type_name(), $sformatf("Start to broadcast read reg, the address is %h!", addr),UVM_LOW)
    // if(bcastsel === 2'b00) begin
    //          fchip = 0;
    //          addchip = 1;
    // end
    // else if(bcastsel === 2'b01) begin
    //         fchip = chipmask[2:0];
    //         addchip = 8;
    // end
    // else if(bcastsel === 2'b10) begin
    //         fchip = chipmask[3:0];
    //         addchip = 16;
    // end
    // else if(bcastsel === 2'b11) begin
    //         fchip = chipmask[4:0];
    //         addchip = 32;
    // end
	 chipnum    = `CHIP_NUM;
     //read_pkg_cnt_pre = chipnum/addchip;
     //if(read_pkg_cnt_pre* addchip + fchip <= chipnum-1) begin
             //read_pkg_cnt = read_pkg_cnt_pre + 1;
     //end 
	 //else  begin 
	 		 //read_pkg_cnt = read_pkg_cnt_pre;
	 //end
   //$display("level1");
	for(int i = 0; i < chipnum; i = i + 1) begin
		//`uvm_info(get_type_name(), $sformatf("The chip_id is %d", fchip+addchip*i), UVM_LOW)
		jlm_reg_rd(32'hc, fctrl);
		while(fctrl[25]) begin
			jlm_reg_rd(32'hc, fctrl);
		end
    //$display("level2");

		jlm_reg_rd(32'h8, dif);
		reg_fifo[i][0] = dif;
		cmd_len = dif[9:0];
		//`uvm_info(get_type_name(), $sformatf("The chip_id is %d", fchip+addchip*i), UVM_LOW)
		//if(dif[31:22] != i) begin
			//`uvm_error(get_type_name(), $sformatf("The true chip_id is %d, but read chip_id is %d!!!", dif[31:22], i))
	//	end
      // $display("level3");

		for(int j = 1; j < cmd_len+1; j = j + 1) begin
			//#100;
			jlm_reg_rd(32'hc, fctrl);
			while(fctrl[25]) begin
				jlm_reg_rd(32'hc, fctrl);
			end
        // $display("level4");

			jlm_reg_rd(32'h8, dif);
			//dif_get[num] = dif;
			reg_fifo[i][j] = dif;
		end
	end
	for(int i = 0; i < chipnum; i = i + 1) begin
		`uvm_info(get_type_name(), $sformatf("The chip_id is %d", i), UVM_LOW)
		for(int j = 0; j < cmd_len+1; j = j + 1) begin
			if(reg_fifo[i][j] === 32'hxxxx_xxxx) begin
				`uvm_error(get_type_name(), $sformatf("The reg_fifo[%d][%d] is %h", i,j,reg_fifo[i][j]))
			end
			`uvm_info(get_type_name(), $sformatf("The reg_fifo[%d][%d] is %h", i,j,reg_fifo[i][j]),UVM_LOW)

		end
	end
	
	rd_reg_buf = reg_fifo;

`elsif USE_UART_DRV
  `ifdef VIP
    //VIP code
  `else
    top_vif.chipaddr = `BRD_ADDR;
    uart_tr = uart_sequence_item::type_id::create("uart_tr");
    uart_tr.mode = 2'b00;
    uart_tr.addr = addr;
    uart_tr.tranlen = len-1;

    start_item(uart_tr,,env_h.uart_env_h.uart_agent_h.m_sequencer);
    finish_item(uart_tr);

    reg_fifo = uart_tr.reg_fifo;
   
    `uvm_info("TASK: rd_reg_fifo", $sformatf("broadcast rd reg_fifo: %p",reg_fifo[0]), UVM_HIGH)
    `uvm_info("TASK: rd_reg_fifo", $sformatf("broadcast rd reg_fifo: %p",reg_fifo[1]), UVM_HIGH)
    `uvm_info("TASK: rd_reg_fifo", $sformatf("broadcast rd reg_fifo: %p",reg_fifo[2]), UVM_HIGH)
  `endif      
`endif
	
endtask


task wr_reg_fifo(input logic [1:0] bsel, input logic [4:0] cmask, input logic [31:0] addr, input logic [8:0] len, input logic [31:0] wr_reg_buf[0:400]);
  	logic [31:0] 	dof_cmd, dif;
	logic [31:0]    dif_get[0:10];	
  	logic [31:0] 	dif_cmd;
  	logic [31:0] 	data_o [0:200];
  	logic [31:0]  	data_t;
  	logic [9:0] 	chipaddr;
  	//logic [1:0] 	bcastsel;
  	logic [5:0] 	mode;
  	logic [4:0] 	chipmask;
  	logic       	needdly;
  	logic [9:0] 	tranlen;
	logic [31:0] 	fctrl;
	int             num, addchip, read_pkg_cnt_pre, read_pkg_cnt;
	logic [31:0]    reg_fifo[254:0][379:0];
	logic [4:0]     fchip;
    reg [7:0] chipnum;
	logic [9:0] cmd_len;
	


	//config dof_cmd
	chipaddr	=	`BRD_ADDR;
	//bcastsel	=   bsel;
	mode		=   6'h2;
	chipmask    =   cmask;
	needdly		=	1'b0;
	tranlen     =   len;
	//			[31:24], [23:22],  [21:16], [15:11], [10],     [9:0]
	dof_cmd = {chipaddr,mode,   chipmask, needdly, tranlen};
	jlm_reg_rd(32'hc, fctrl);
	while(fctrl[7:0]>20) begin
		jlm_reg_rd(32'hc, fctrl);
	end
	//set jlm transaction cmd sequence value
	jlm_reg_wr(32'h4, dof_cmd);
	//set jlm transaction addr sequence value, just noncebuf addr
	jlm_reg_wr(32'h4, addr);
	//set jlm transaction nop sequence value
	jlm_reg_wr(32'h4, 32'h0);

    for(int i=0;i<tranlen;i++) begin
			jlm_reg_wr(32'h4, wr_reg_buf[i]);
    end

	
endtask

task wr_reg_fifo_single_chip(input logic [7:0] chip_num, input logic we, input logic [31:0] addr, input logic [8:0] len, input logic [31:0] wr_reg_buf[0:400], output logic [31:0] wr_reg_buf_rd[0:400]);
  	logic [31:0] 	dof_cmd, dif;
	logic [31:0]    dif_get[0:200];	
  	logic [31:0] 	dif_cmd;
  	logic [31:0] 	data_o [0:200];
  	logic [31:0]  	data_t;
  	logic [9:0] 	chipaddr;
  	//logic [1:0] 	bcastsel;
  	logic [5:0] 	mode;
  	logic [4:0] 	chipmask;
  	logic       	needdly;
  	logic [9:0] 	tranlen;
	logic [31:0] 	fctrl;
	int             num, addchip, read_pkg_cnt_pre, read_pkg_cnt;
	logic [31:0]    reg_fifo[254:0][379:0];
	logic [4:0]     fchip;
    reg [7:0] chipnum;
	logic [9:0] cmd_len;
	


	//config dof_cmd
	chipaddr	=	chip_num;
	//bcastsel	=   2'h0;
	if(we==1'b0) begin
		mode		=   6'h4;
	end else begin
		mode		=   6'h2;
	end
	chipmask    =   5'h0;
	needdly		=	1'b0;
	tranlen     =   len;
	//			[31:24], [23:22],  [21:16], [15:11], [10],     [9:0]
	dof_cmd = {chipaddr,mode,   chipmask, needdly, tranlen};
	jlm_reg_rd(32'hc, fctrl);
	while(fctrl[7:0]>20) begin
		jlm_reg_rd(32'hc, fctrl);
	end
	//set jlm transaction cmd sequence value
	jlm_reg_wr(32'h4, dof_cmd);
	//set jlm transaction addr sequence value, just noncebuf addr
	jlm_reg_wr(32'h4, addr);
	//set jlm transaction nop sequence value
	jlm_reg_wr(32'h4, 32'h0);
    if(we == 1'b1) begin
    	for(int i=0;i<tranlen;i++) begin
			jlm_reg_wr(32'h4, wr_reg_buf[i]);
    	end
	end

	if(we == 1'b0) begin
		fctrl = 32'h0;
		while(fctrl[23:16] < 8'h3) begin
			jlm_reg_rd(32'hc, fctrl);
		end
		for(num = 0; num < 3; num = num + 1) begin
			jlm_reg_rd(32'h8, dif);
			dif_get[num] = dif;
		end

		for(int i = 0; i < 1; i = i + 1) begin
			jlm_reg_rd(32'hc, fctrl);
			while(fctrl[25]) begin
				jlm_reg_rd(32'hc, fctrl);
			end

			jlm_reg_rd(32'h8, dif);
			num=3;
			dif_get[num] = dif;
            cmd_len = dif[9:0];
			for(int j = 0; j < cmd_len; j = j + 1) begin
				num = num +1;
				jlm_reg_rd(32'hc, fctrl);
				while(fctrl[25]) begin
					jlm_reg_rd(32'hc, fctrl);
				end
				jlm_reg_rd(32'h8, dif);
				dif_get[num] = dif;
                wr_reg_buf_rd[j] = dif;
			end

		end
        for(int i = 0; i < cmd_len; i = i + 1) begin
			`uvm_info(get_type_name(), $sformatf("The reg_fifo[%d] is %h", i,wr_reg_buf_rd[i]),UVM_LOW)            
		end
		
	end
	
endtask

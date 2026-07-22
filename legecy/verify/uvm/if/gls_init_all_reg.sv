// re-init for clean q x of dff

bit GLS_REG_LIST[int][string];

`define GLS_INIT_REG_T(C_ID,HDL,VAL) initial GLS_REG_LIST[C_ID][`"HDL`"]=VAL;

//`include "gls_deposit_all_reg_list.sv"
`include "gls_deposit_all_reg_list_new110.sv"

function automatic gls_deposit_dffq(bit GLS_REG_LIST[int][string] ,int C_ID);
  bit DFF_ARRAY[int][string]; reg qval,dval;string rid;
  rid=$sformatf("chip_%0d_gls_deposit_dffq",C_ID); 
  `uvm_info(rid,$sformatf("DFF_ARRAY[%0d].size=%0d",C_ID,GLS_REG_LIST[C_ID].size),UVM_NONE)
  //`uvm_info(rid,$sformatf("DFF_ARRAY[%0d]=%p",C_ID,GLS_REG_LIST[C_ID]),UVM_NONE)
  foreach (GLS_REG_LIST[C_ID][hdl]) begin
    dval=$urandom_range(1,0);
    if(uvm_hdl_check_path({hdl})) begin
      if(uvm_hdl_read({hdl},qval)) begin
        if(qval==='x) begin
          assert(uvm_hdl_deposit({hdl},dval));
        end
      end
    end
  end 

endfunction


`define GLS_INIT_REG_PER_CHIP_W(C_ID) \
`GLS_INIT_REG_ARRARY_PER_CHIP_NEW(C_ID) \
initial begin\
    int x_cnt,last_x_cnt=0;\
    `ifdef ADD_DELAY_ZERO_INIT_REG \	
	    #1ns; \
    `else \
    `endif \
    gls_deposit_dffq(GLS_REG_LIST,C_ID);\
    #5ns;  \
    if(!$test$plusargs("DIS_GLS_INIT_REG")) begin\
      repeat(7) begin \
        @(negedge tb_top.C[C_ID].btnode.btc.sys_ctrl.xclk);\
        #1ps;\
        gls_deposit_dffq(GLS_REG_LIST,C_ID);\
      end \
    end\
    `uvm_info($sformatf("C[%0d].gls_init_reg",C_ID),"init after rst done",UVM_NONE);\
 end\
initial begin \
    @(posedge tb_top.C[C_ID].btnode.btc.sys_ctrl.crg.u_crg_rst.xclk);\
    uvm_hdl_deposit("tb_top.C[C_ID].btnode.btc.sys_ctrl.crg.u_crg_rst.clk_cnt[4:0]", 1'b0);\
end\

    `GLS_INIT_REG_PER_CHIP_W(0)
    `ifdef IO_MC_GLS
		`GLS_INIT_REG_PER_CHIP_W(1)
		`GLS_INIT_REG_PER_CHIP_W(2)
		`GLS_INIT_REG_PER_CHIP_W(3)
		
		`ifndef ONLY_INIT_FOUR_CHIP
			`GLS_INIT_REG_PER_CHIP_W(4)
			`GLS_INIT_REG_PER_CHIP_W(5)
			`GLS_INIT_REG_PER_CHIP_W(6)
			`GLS_INIT_REG_PER_CHIP_W(7)
		`endif
    `endif

    `ifdef TEST_SEL00
        `GLS_INIT_REG_PER_CHIP_W(1)
        `GLS_INIT_REG_PER_CHIP_W(2)
        `GLS_INIT_REG_PER_CHIP_W(3)
        `GLS_INIT_REG_PER_CHIP_W(4)
        `GLS_INIT_REG_PER_CHIP_W(5)
        `GLS_INIT_REG_PER_CHIP_W(6)
        `GLS_INIT_REG_PER_CHIP_W(7)
    `endif

    `ifdef UART_VIP_GLS
		`GLS_INIT_REG_PER_CHIP_W(1)
		`GLS_INIT_REG_PER_CHIP_W(2)
    `endif
      



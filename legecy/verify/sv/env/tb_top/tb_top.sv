`timescale 1ns/1ps

`define SLICE_START(x) `SLICE``x``_START
`define SLICE_CORE_NUMS(x)   `SLICE``x``_CORE_NUM

parameter int slice_start[`SLICE_NUM] = '{
    `SLICE_START(0),
    `SLICE_START(1),
    `SLICE_START(2),
    `SLICE_START(3),
    `SLICE_START(4),
    `SLICE_START(5),
    `SLICE_START(6),
    `SLICE_START(7)
};

parameter int slice_core_num[`SLICE_NUM] = '{
    `SLICE_CORE_NUMS(0),
    `SLICE_CORE_NUMS(1),
    `SLICE_CORE_NUMS(2),
    `SLICE_CORE_NUMS(3),
    `SLICE_CORE_NUMS(4),
    `SLICE_CORE_NUMS(5),
    `SLICE_CORE_NUMS(6),
    `SLICE_CORE_NUMS(7)
};

parameter int slice_end[`SLICE_NUM] = '{
    `SLICE_START(0)+`SLICE_CORE_NUMS(0)-1,
    `SLICE_START(1)+`SLICE_CORE_NUMS(1)-1,
    `SLICE_START(2)+`SLICE_CORE_NUMS(2)-1,
    `SLICE_START(3)+`SLICE_CORE_NUMS(3)-1,
    `SLICE_START(4)+`SLICE_CORE_NUMS(4)-1,
    `SLICE_START(5)+`SLICE_CORE_NUMS(5)-1,
    `SLICE_START(6)+`SLICE_CORE_NUMS(6)-1,
    `SLICE_START(7)+`SLICE_CORE_NUMS(7)-1
};
`ifdef VIP
  `include "svt_uart.uvm.pkg"
`endif

module tb_top
    import reg_addr::*;
    import  btc_pkg::*;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  //import reg_pkg::*;
    `ifdef UPF
        import  UPF::*;
    `endif

    `ifdef VIP
    import svt_uvm_pkg::*;
    import svt_uart_uvm_pkg::*;
    `endif

    ();
    //for jls inject
    reg [42:0] g_jlm_ecc_enc = 0;
    logic [31:0] g_rsp_inject_err=0;

    reg        initial_done = 0;

    `include "vif_declare.sv"


    reg RO;
    reg rst_n;
    reg rst_n_vip;

    `ifdef VIP
    assign uart_vip_pif.rst = rst_n_vip;
    assign uart_vip_pif.dsr = 0;
    assign uart_vip_pif.cts = 0;
    assign uart_vip_pif.rts = 1;
    `endif


    initial begin
        $timeformat(-9, 3, "ns", 10);
    end


    //*********************************************************
    //************* < clk_gen > and wire in tb_top*************
    //*********************************************************
    wire JLM_CKO;
    wire CI_CLK;
    wire clk_spd;

    wire uart_clk;
    wire uart_clk16;
    wire uart_vip_clk;


    clk_gen clk_gen(
                    .uart_clk(uart_clk),
                    .uart_clk16(uart_clk16),
                    .uart_vip_clk(uart_vip_clk),

                    .clk_spd(clk_spd),
                    .XCLK(JLM_CKO),
                    .CI_CLK(CI_CLK)

                );
    //********************************************************


initial begin
`ifdef VIP
  rst_n_vip = 0;
  `ifdef PL_SIM
  #200;
  `else
  #1200;
  `endif
  @(posedge CI_CLK)
  rst_n_vip = 1'b1;
  @(posedge CI_CLK)
  rst_n_vip = 1'b0;
`endif
  rst_n = 1'b0;
  #1000;
  rst_n = 1'b1;
end

wire JLM_RO = RO;
wire JLM_CO;
wire JLM_DO;
wire JLM_CI;
wire JLM_DI;

wire [2:0] JLM_CO_RSVD;
wire [2:0] JLM_DO_RSVD;

//--------------------simulation time out-------------------------------//
event e_timeout;
reg [31:0] clk_cnt=0;
reg [31:0] clk_cnt_r=0;
always @(posedge CI_CLK) begin
    clk_cnt <= clk_cnt + 1'b1;
end
//timeout watchdog
initial begin
    while(1) begin
        #400;
        @(posedge CI_CLK);
        clk_cnt_r <= clk_cnt;
        #400;
        if(clk_cnt == clk_cnt_r) begin
            $display("clk is hang,clk_cnt_r is %0h,clk_cnt is %0h",clk_cnt_r,clk_cnt);
            ->e_timeout;
        end
        `ifndef DIS_TIMEOUT
        else if(clk_cnt > 32'h0fff_f000) begin
            $display("clk is timeout,clk_cnt is %0h",clk_cnt);
            ->e_timeout;
        end
        `endif
    end
end

initial
begin
@e_timeout;
$display($time, "    Time Out fail");
$finish;
end

//--------------------simulation time out-------------------------------//

//--------------------jlm instantiation-------------------------------//
reg        API_CYC_I = 0;
reg        API_STB_I = 0;
reg        API_WE_I  = 0;
reg        API_LOCK_I= 0;
reg [2:0]  API_CTI_I = 0;
reg [1:0]  API_BTE_I = 0;
reg [5:0]  API_ADR_I = 0;
reg [31:0] API_DAT_I = 0;
reg [3:0]  API_SEL_I = 0;
wire       API_ACK_O ;
wire       API_ERR_O ;
wire       API_RTY_O ;
wire [31:0]API_DAT_O ;

jlm jlm(
/*input        */ .clk       (CI_CLK    ),
/*input        */ .JLM_CYC_I (API_CYC_I ),
/*input        */ .JLM_STB_I (API_STB_I ),
/*input        */ .JLM_WE_I  (API_WE_I  ),
/*input        */ .JLM_LOCK_I(API_LOCK_I),
/*input  [2:0] */ .JLM_CTI_I (API_CTI_I ),
/*input  [1:0] */ .JLM_BTE_I (API_BTE_I ),
/*input  [5:0] */ .JLM_ADR_I (API_ADR_I ),
/*input  [31:0]*/ .JLM_DAT_I (API_DAT_I ),
/*input  [3:0] */ .JLM_SEL_I (API_SEL_I ),
/*output       */ .JLM_ACK_O (API_ACK_O ),
/*output       */ .JLM_ERR_O (API_ERR_O ),
/*output       */ .JLM_RTY_O (API_RTY_O ),
/*output [31:0]*/ .JLM_DAT_O (API_DAT_O ),

/*output [3:0] */ .JLM_CO    ({JLM_CO_RSVD, JLM_CO}),//  (CO00      ),
/*output [3:0] */ .JLM_DO    ({JLM_DO_RSVD, JLM_DO}),//  (DO        ),
/*input  [3:0] */ .JLM_CI    ({3'b0, JLM_CI}),//  ({3'b0,CO4}),
/*input  [3:0] */ .JLM_DI    ({3'b0, JLM_DI}) //  ({3'b0,DI} ) 
);
wire jlm_fbdi;
wire [`CHIP_NUM:0]   real_cki;
wire [`CHIP_NUM:0]   real_ci ;
wire [`CHIP_NUM:0]   real_di ;
wire [`CHIP_NUM:0]   real_ri ;
wire [`CHIP_NUM:0]   real_fbdi;
reg  [`CHIP_NUM+3:0] real_dsel;
wire [`CHIP_NUM-1:0] real_do;
wire [`CHIP_NUM-1:0] real_co;

wire [`CHIP_NUM:0]   btn_fbdi_fbdo;
wire [`CHIP_NUM:0]   btn_fbdo_fbdi;
wire [`CHIP_NUM:0]   btn_cki_co;
wire [`CHIP_NUM:0]   btn_co_cki;
wire [`CHIP_NUM:0]   btn_ci_cko;
wire [`CHIP_NUM:0]   btn_cko_ci;
wire [`CHIP_NUM:0]   btn_di_ro;
wire [`CHIP_NUM:0]   btn_ro_di;
wire [`CHIP_NUM:0]   btn_ri_do;
wire [`CHIP_NUM:0]   btn_do_ri;
wire [`CHIP_NUM:0]   btn_dsel;
wire [`CHIP_NUM-1:0] btn_to;
wire [`CHIP_NUM-1:0] btn_sel;  
//wire [`CHIP_NUM-1:0] btn_fb_sel;
wire [`CHIP_NUM-1:0] btn_tp_sel; //Add for UART

wire [`CHIP_NUM-1:0] btn_mode0;
wire [`CHIP_NUM:0]   btn_lb_clk;
wire [`CHIP_NUM:0]   btn_lb_dat;

wire [`CHIP_NUM:0]   fb_btc;

logic btn_pad_lock;

initial begin
    btn_pad_lock = 1'b0;
    #`PAD_LOCK_TIME;
    btn_pad_lock = 1'b1;
end
initial begin
    force btn_cki_co = 0;
    force btn_co_cki = 0;
    force btn_cko_ci = 0;
    force btn_ci_cko = 0;
    force btn_dsel = real_dsel;
        
`ifdef IO_MC_GLS
    #1ns;
`else
    #0.1ns;
`endif
    release btn_dsel;
    release btn_cki_co;
    release btn_co_cki;
    release btn_cko_ci;
    release btn_ci_cko;
end    

assign btn_mode0 = `CHIP_NUM'h1 << (`CHIP_NUM-1);

initial begin
`ifdef DSEL_ALL_4
`ifdef FPGA_SYN//Fix zero_delay_loop for BUFGCTRL
    real_dsel[0] = $urandom_range(0,1);
    force real_dsel= 0;
    #0.1ns;
    release real_dsel;
`else
    real_dsel[0] = $urandom_range(0,1);
`endif
    real_dsel[1] = real_dsel[0];
    real_dsel[2] = real_dsel[1];
    real_dsel[3] = real_dsel[2];
`elsif DSEL_H
    real_dsel[0] = 1'b1;
`elsif DSEL_L
    real_dsel[0] = 1'b0;
`else
`ifdef FPGA_SYN//Fix zero_delay_loop for BUFGCTRL
    real_dsel[0] = $urandom_range(0,1);
    force real_dsel= 0;
    #0.1ns;
    release real_dsel;
`else
	real_dsel[0] = $urandom_range(0,1);
`endif
`endif
end

generate for(genvar cd = 0; cd < `CHIP_NUM; cd = cd + 1) begin : DSEL
`ifdef DSEL_ALL_4
    assign real_dsel[cd+4] = ~real_dsel[cd];
`elsif DSEL_H
    assign real_dsel[cd+1] = real_dsel[cd];
`elsif DSEL_L
    assign real_dsel[cd+1] = real_dsel[cd];
`else
    assign real_dsel[cd+1] = ~real_dsel[cd]; 
`endif

`ifdef FPGA_SYN
    assign btn_dsel[cd] = real_dsel[cd];
`else
    assign btn_dsel[cd] = real_dsel[cd] ? 1'b1 : 1'b0;
`endif
end
endgenerate


tran(JLM_CI, real_ci[`CHIP_NUM]);
pulldown(real_ci[`CHIP_NUM]);

tran(JLM_DI, jlm_fbdi);

assign real_cki[0] = JLM_CKO;
`ifdef USE_UART_DRV
    assign real_ci[0]  = '0;
`else
    assign real_ci[0]  = JLM_CO;
`endif
assign real_ri[0]  = JLM_RO;
assign real_di[0]  = JLM_DO;

pulldown(jlm_fbdi);
`ifdef DIRECT_MM
  assign jlm_fbdi = real_dsel[`CHIP_NUM-1] ? btn_ri_do[`CHIP_NUM-1] : btn_do_ri[`CHIP_NUM-1];
`else
  assign jlm_fbdi = real_dsel[0] ? btn_fbdi_fbdo[0] : btn_fbdo_fbdi[0];
`endif

`ifdef FPGA_SYN  //loop back connect
assign btn_lb_clk[`CHIP_NUM] = 1'b0;//c_ci[`CHIP_NUM];
assign btn_lb_dat[`CHIP_NUM] = 1'b0;//c_di[`CHIP_NUM];
`endif



//both files are needed
`include "tb_procedure_btnode.sv"
`include "tb_procedure_jlm.sv"

generate for(genvar c = 0; c < `CHIP_NUM; c = c + 1) begin : C
     
    assign btn_sel[c] = getn_sel(c);
//    assign btn_fb_sel[c] = getn_fb_sel(c);
    assign fb_btc[c] = tb_top.C[c].btnode.btc.sys_ctrl.REG_fb_sel;

    tb_btnode #(
        .FPGA_VCU118( chkn_last(c) ),
        .NODE_ID    (c              )
    ) 
    btnode (
        .DSEL       (btn_dsel[c]    ),
        .CKI_CO     (btn_cki_co[c]  ),
        .CKO_CI     (btn_cko_ci[c]  ),
        .CI_CKO     (btn_ci_cko[c]  ),
        .CO_CKI     (btn_co_cki[c]  ),
        .RI_DO      (btn_ri_do[c]   ),
        .DO_RI      (btn_do_ri[c]   ),
        .DI_RO      (btn_di_ro[c]   ),
        .RO_DI      (btn_ro_di[c]   ),
    
        .LB_CLKI    (btn_lb_clk[c+1]),
        .LB_DATI    (btn_lb_dat[c+1]),
        .MODE0      (btn_mode0[c]   ),
        .LB_CLKO    (btn_lb_clk[c]  ),
        .LB_DATO    (btn_lb_dat[c]  ),

        .SEL        (btn_sel[c]     ),
//        .FB_SEL     (btn_fb_sel[c]  ),
        .TPSEL      (btn_tp_sel[c]  ),  //Add for UART
        .TO         (btn_to[c]      ),        

        .FBDI_FBDO  (btn_fbdi_fbdo[c]),
        .FBDO_FBDI  (btn_fbdo_fbdi[c]),

        .pad_lock   (btn_pad_lock  )
    );
//Add for UART
`ifdef USE_UART_DRV
    assign btn_tp_sel[c] = 1'b1;
`else
    assign btn_tp_sel[c] = 1'b0;
`endif

    //to signal need to be external pull-up 
    pullup(btn_to[c]);

    assign real_cki[c+1] = getn_io_value( .p_io_01(btn_ci_cko[c]), .p_io_10(btn_cko_ci[c]), .p_dsel(real_dsel[c]) );
    assign real_ci[c+1]  = getn_io_value( .p_io_01(btn_cki_co[c]), .p_io_10(btn_co_cki[c]), .p_dsel(real_dsel[c]) );
    assign real_di[c+1]  = getn_io_value( .p_io_01(btn_ri_do[c] ), .p_io_10(btn_do_ri[c] ), .p_dsel(real_dsel[c]) );
    assign real_ri[c+1]  = getn_io_value( .p_io_01(btn_di_ro[c] ), .p_io_10(btn_ro_di[c] ), .p_dsel(real_dsel[c]) );

    assign real_do[c]    = real_di[c+1];
    assign real_co[c]    = real_ci[c+1];

`ifndef FPGA_SYN
    if(getn_sel(c))begin
        pulldown(real_cki[c+1]);
        pulldown(real_ci[c+1]);
        pulldown(real_di[c+1]);
        pulldown(real_ri[c+1]);
        pulldown(real_fbdi[c]);
    end
`endif

    tranif1(btn_co_cki[c], real_cki[c], real_dsel[c]);
    tranif1(btn_cko_ci[c], real_ci[c] , real_dsel[c]);
    tranif1(btn_ro_di[c] , real_di[c] , real_dsel[c]);
    tranif1(btn_do_ri[c] , real_ri[c] , real_dsel[c]);

    tranif0(btn_cki_co[c], real_cki[c], real_dsel[c]);
    tranif0(btn_ci_cko[c], real_ci[c] , real_dsel[c]);
    tranif0(btn_di_ro[c] , real_di[c] , real_dsel[c]);
    tranif0(btn_ri_do[c] , real_ri[c] , real_dsel[c]);

    if(!chkn_last(c)) begin
        assign real_fbdi[c] = getn_io_value( .p_io_01(btn_fbdi_fbdo[c+1]), .p_io_10(btn_fbdo_fbdi[c+1]), .p_dsel(real_dsel[c+1]) );
    end
//`ifndef FPGA_SYN
    else begin
        assign real_fbdi[c] = getn_io_value( .p_io_01(btn_ri_do[c]),       .p_io_10(btn_do_ri[c]),       .p_dsel(real_dsel[c]) );
    end
//`endif

    tranif1(btn_fbdo_fbdi[c] , real_fbdi[c] , real_dsel[c]);
    tranif0(btn_fbdi_fbdo[c] , real_fbdi[c] , real_dsel[c]);
end
endgenerate


initial begin   run_test("");   end

//******* Module   < if_oomr >  instantiation in tb_top ********
    if_oomr if_oomr();                                       
//******* if adding oomr file, please go to Module if_oomr *****


//******* Program  < sdf_annotate >  instantiation in tb_top ***
    sdf_annotate sdf_annotate();
//******* if update sdf file, please go to file: tb_sdf.sv *****


wire [`CHIP_NUM-1:0]   cps_io_fb_sel;
wire cps_io_fb_normal;
generate
    for(genvar c = 0 ; c < `CHIP_NUM; c++) begin
    `ifdef FUNC_IO_FB_SEL
        assign cps_io_fb_sel[c] = `BTC(c).sys_ctrl.REG_fb_sel;
    `else
        assign cps_io_fb_sel[c] = 0;
    `endif
    end
endgenerate
assign cps_io_fb_normal = ~(|cps_io_fb_sel);

function int getcs_io_first_fb_special();
    int v_index;

    v_index = -1;

    for(int i = 0 ; i < `CHIP_NUM ; i++) begin
        if(cps_io_fb_sel[i] === 1'b1) begin
            v_index = i;
            return v_index;
        end
    end

    return v_index;
endfunction


endmodule

module clk_gen(
               output reg uart_clk,
               output reg uart_clk16,
               output reg uart_vip_clk,

               output reg clk_spd,
               output reg XCLK,
               output reg CI_CLK
              );

    //********************* < XCLK > ******************************
    reg source_cko = $random;
    initial begin
    `ifdef FPGA_SYN//Fix zero_delay_loop for BUFGCTRL
        reg XCLK = 0;
    `else
        XCLK = $urandom_range(0,1);
    `endif
    `ifdef IO_MC_GLS
        #6600;
    `endif
        forever #(`XCLK_P_NS/2) source_cko = ~source_cko; //xclk
    end
    int CLK_DELAY;
    initial begin
        CLK_DELAY = $urandom_range(0,20);
        #CLK_DELAY
        $display("*******************xclk phase has been randomize : delay = %0d***********************",CLK_DELAY);
    end
    always@(*)begin
        XCLK <= #CLK_DELAY source_cko; 
    end 

    //********************* < CI CLK > ******************************
    //CI_CLK;
    `ifdef JLM_CO_50MHZ
    initial begin
      CI_CLK =0;
      forever #(1.667) CI_CLK = ~CI_CLK; //jamlink input clk, which can generate CI 
    end
    `elsif JLM_RANDOM_CO_JLM
    initial begin
      int jlm_random_ifreq;
      jlm_random_ifreq = $urandom_range(2,13);
      CI_CLK =0;
      forever #(jlm_random_ifreq) CI_CLK = ~CI_CLK; //jamlink input clk, which can generate CI, half clk is 13.335 
    end
    
    `elsif JLM_RANDOM_CO
    
    initial begin
      int jlm_random_ifreq;
      jlm_random_ifreq = $urandom_range(17,45);
      CI_CLK =0;
      forever #(1000.00/jlm_random_ifreq/2) CI_CLK = ~CI_CLK; //jamlink input clk, which can generate CI, half clk is 13.335 
    end

    `elsif JLM_RANDOM_CO_3M_16M
    
    initial begin
      int jlm_random_ifreq;
      jlm_random_ifreq = $urandom_range(5,28);
      CI_CLK =0;
      forever #(1000.00/jlm_random_ifreq/2) CI_CLK = ~CI_CLK; //jamlink input clk, which can generate CI, CI range from 3M to 16M 
    end


    `elsif JLM_300MHZ
    
    initial begin
      CI_CLK =0;
      forever #(1.67) CI_CLK = ~CI_CLK; // jamlink input clk 300MHz
    end

    `else
    initial begin
      CI_CLK =0;
      forever #(1000.00/`JLM_IFREQ/2) CI_CLK = ~CI_CLK; //jamlink input clk, which can generate CI 
    end
    
    `endif

    //********************* < clk_spd > ******************************
    //clk_spd;
    initial begin
      clk_spd = 1;
      forever #(250.00/`JLM_IFREQ/2) clk_spd = ~clk_spd;
    end

    //********************* < uart_clk > ******************************
    //real uart_divisor ;
    real uart_freq;
    real uart_vip_freq;
    
    initial begin
    `ifndef OSC_48M
      `ifdef UART_SIM_SPEEDUP
      uart_freq = 6*16; //6Mhz
      `else
      uart_freq = 0.1152*16;
      `endif    //`ifdef UART_SIM_SPEEDUP
    `else//OSC_48M
      `ifdef UART_SIM_SPEEDUP
      uart_freq = (6*2)*16; //6Mhz
      `else
      uart_freq = (0.1152*2)*16;
      `endif    //`ifdef UART_SIM_SPEEDUP
    `endif//OSC_48M

      uart_clk =0;
      uart_clk16 =0;
    
      //1,200MHz/(46875/72) = 1.8432 Mhz
      fork
        //forever #(uart_freq*uart_divisor) uart_clk = ~uart_clk; //uart input uart_clk
        //forever #(uart_freq*uart_divisor*16) uart_clk16 = ~uart_clk16; //uart input uart_clk
        forever #(500/uart_freq) uart_clk = ~uart_clk; //uart input uart_clk
        forever #(500/uart_freq*16) uart_clk16 = ~uart_clk16; //uart input uart_clk

        //forever begin #(500000/uart_freq) ps; uart_clk = ~uart_clk; end//uart input uart_clk
        //forever begin #(500000/uart_freq *16) ps; uart_clk16 = ~uart_clk16;  end//uart input uart_clk

      join
    
    end


    //********************* < uart_vip_clk > ******************************
    initial begin
      uart_vip_clk = 0;
      uart_vip_freq = 500;   //huangkang: vip create a new parameter to calc freq  
      forever #(uart_vip_freq) uart_vip_clk = ~uart_vip_clk; //uart input uart_clk
    end
    
endmodule

module if_oomr;

    //some macros are defined in "gls_init_all_reg.sv" ,and they are used in if_oomr.
    //so we move gls_init code here and remove the progam_block gls_init

      import uvm_pkg::*;
    `ifdef PL_SIM
	    `include "gls_init_all_reg.sv"
    `endif
     
    `ifndef PL_SIM
    `include "top_if_oomr.sv" 
    `include "mx2_if_oomr.sv"   
    `include "ro_if_oomr.sv"
    `include "pvt_if_oomr.sv"
    `include "rst_if_oomr.sv" 
    `include "rst_assertion_if_oomr.sv" 
    `include "cpm_if_oomr.sv"
    `include "mc_if_oomr.sv"
    `include "jls_if_oomr.sv"
    `include "jamlink_if_oomr.sv"
    `include "uart_if_oomr.sv"
    `include "efuse_if_oomr.sv"
    `include "ft_if_oomr.sv"
    `include "spd_if_oomr.sv"
    `include "cpft_if_oomr.sv"
    `include "dfx_if_oomr.sv"
    `include "io_if_oomr.sv"
    `include "reg_if_oomr.sv"
    `include "selfclk_if_oomr.sv"
    `include "work_ctrl_if_oomr.sv"
    //`include "rst_reg_norst_oomr.sv" //eddie: guarded with REG_NORST_IF in rst_assertion_if_oomr.sv 
    //`include "rst_reg_rst_oomr.sv"  //eddie: already included in uvm/if/rst_assertion_if_oomr.sv
	
    `else   //ifndef PL_SIM


    `include "top_if_oomr_gls.sv" 
    // `include "mx2_if_oomr_gls.sv"
    `include "ro_if_oomr_gls.sv"
    `include "pvt_if_oomr_gls.sv"
     `include "rst_if_oomr_gls.sv" 
    `ifdef GPLS_RST_ASSERTION_ON
        `include "rst_assertion_if_oomr_gls.sv"
     `endif
    `include "cpm_if_oomr_gls.sv"
    // `include "mc_if_oomr_gls.sv"
    `include "jls_if_oomr_gls.sv"
    `include "jamlink_if_oomr_gls.sv"
    `include "uart_if_oomr_gls.sv"
    `include "efuse_if_oomr_gls.sv"
    `include "ft_if_oomr_gls.sv"
    `include "spd_if_oomr_gls.sv"
     `include "cpft_if_oomr_gls.sv"
    // `include "dfx_if_oomr_gls.sv"
    `include "io_if_oomr_gls.sv"
    `include "reg_if_oomr_gls.sv"
    `include "selfclk_if_oomr_gls.sv"
    `include "work_ctrl_if_oomr_gls.sv"

    `endif  //ifndef PL_SIM
    `include "dump_wave.sv" 

    //core initial
    `ifdef PL_SIM
    `include "core_initial.sv"
    `endif

endmodule



//***************************************************************
//******* Program  < sdf_annotate >  is used for annotate *******
//******* sdf file.                                      ********
//***************************************************************
program sdf_annotate;
    //sv file for taking in sdf files
    `include "tb_sdf.sv"
endprogram

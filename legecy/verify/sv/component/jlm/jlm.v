`define JLM_RD   6'd4
`define JLM_WR   6'd2
`define JLM_INI  6'd0
`define JLM_ERROR_INJECT ^(`TB_TOP.g_jlm_ecc_enc)
module jlm(
input         clk       ,
input         JLM_CYC_I ,
input         JLM_STB_I ,
input         JLM_WE_I  ,
input         JLM_LOCK_I,
input  [2:0]  JLM_CTI_I ,
input  [1:0]  JLM_BTE_I ,
input  [5:0]  JLM_ADR_I ,
input  [31:0] JLM_DAT_I ,
input  [3:0]  JLM_SEL_I ,
output        JLM_ACK_O ,
output        JLM_ERR_O ,
output        JLM_RTY_O ,
output [31:0] JLM_DAT_O ,

output [3:0]  JLM_CO    ,
output [3:0]  JLM_DO    ,
input  [3:0]  JLM_CI    ,
input  [3:0]  JLM_DI     
);

wire [1:0]  REG_IniCh   ;
wire        REG_SetFlush;
wire        REG_DiFRst  ;
wire        REG_DoFRst  ;
wire        REG_SetRst  ;
wire        REG_DoF_push;
wire [31:0] REG_DoF     ;
wire        REG_DiF_pop ;
wire [31:0] REG_DiF     ;
wire        REG_DiFEpt  ;
wire        REG_DiFFull ;
wire [7:0]  REG_DiFCnt  ;
wire        REG_DoFEpt  ;
wire        REG_DoFFull ;
wire [7:0]  REG_DoFCnt  ;
wire [31:0] REG_Dly     ;
wire [7:0]  REG_CoPrd   ;
wire        REG_WrLog   ;
wire        REG_IniLog  ;
wire        REG_CoEn    ;
wire        CO, CI      ;
wire        DO, DI      ;
wire        get_vld     ;
wire [31:0] get_data    ;
wire [1:0]  get_ecc     ;
wire        fifo_pop    ;
wire [31:0] dout        ;
wire        clk_fifo_pop;
wire [3:0]  onehot      ;
wire        di_idle     ;

assign JLM_CO = {4{~CO}};
assign JLM_DO = {4{DO}} & onehot;
assign CI = |(JLM_CI & onehot);
assign DI = |(JLM_DI & onehot);

jlm_wb jlm_wb(
/*input            */ .JLM_CYC_I   (JLM_CYC_I   ),
/*input            */ .JLM_STB_I   (JLM_STB_I   ),
/*input            */ .JLM_WE_I    (JLM_WE_I    ),
/*input            */ .JLM_LOCK_I  (JLM_LOCK_I  ),
/*input  [2:0]     */ .JLM_CTI_I   (JLM_CTI_I   ),
/*input  [1:0]     */ .JLM_BTE_I   (JLM_BTE_I   ),
/*input  [5:0]     */ .JLM_ADR_I   (JLM_ADR_I   ),
/*input  [31:0]    */ .JLM_DAT_I   (JLM_DAT_I   ),
/*input  [3:0]     */ .JLM_SEL_I   (JLM_SEL_I   ),
/*output reg       */ .JLM_ACK_O   (JLM_ACK_O   ),
/*output           */ .JLM_ERR_O   (JLM_ERR_O   ),
/*output           */ .JLM_RTY_O   (JLM_RTY_O   ),
/*output reg [31:0]*/ .JLM_DAT_O   (JLM_DAT_O   ),
/*input            */ .CO          (CO          ),
/*input            */ .CI          (CI          ),
/*input            */ .clk         (clk         ),
/*output reg [1:0] */ .REG_IniCh   (REG_IniCh   ),
/*output reg       */ .REG_SetFlush(REG_SetFlush),
/*output reg       */ .REG_DiFRst  (REG_DiFRst  ),
/*output reg       */ .REG_DoFRst  (REG_DoFRst  ),
/*output reg       */ .REG_SetRst  (REG_SetRst  ),
/*output reg       */ .REG_DoF_push(REG_DoF_push),
/*output reg [31:0]*/ .REG_DoF     (REG_DoF     ),
/*output reg       */ .REG_DiF_pop (REG_DiF_pop ),
/*input  [31:0]    */ .REG_DiF     (REG_DiF     ),
/*input            */ .REG_DiFEpt  (REG_DiFEpt  ),
/*input            */ .REG_DiFFull (REG_DiFFull ),
/*input  [7:0]     */ .REG_DiFCnt  (REG_DiFCnt  ),
/*input            */ .REG_DoFEpt  (REG_DoFEpt  ),
/*input            */ .REG_DoFFull (REG_DoFFull ),
/*input  [7:0]     */ .REG_DoFCnt  (REG_DoFCnt  ),
/*output reg [31:0]*/ .REG_Dly     (REG_Dly     ),
/*output reg [7:0] */ .REG_CoPrd   (REG_CoPrd   ),
/*output reg       */ .REG_WrLog   (REG_WrLog   ),
/*output reg       */ .REG_IniLog  (REG_IniLog  ),
/*output reg       */ .REG_CoEn    (REG_CoEn    ),
/*input            */ .get_vld     (get_vld     ),
/*input  [1:0]     */ .get_ecc     (get_ecc     ) 
);

//--------------------------------------------
// DO
//--------------------------------------------
wire now_rd, now_wr, now_ini;

jlm_doc jlm_doc(
/*input        */ .clk        (clk       ),
/*input        */ .rst        (REG_SetRst),
/*output reg   */ .CO         (CO        ),
/*output       */ .DO         (DO        ),
/*input  [1:0] */ .REG_IniCh  (REG_IniCh ),
/*input  [31:0]*/ .REG_Dly    (REG_Dly   ),
/*input  [7:0] */ .REG_DoFCnt (REG_DoFCnt),
/*input  [7:0] */ .REG_CoPrd  (REG_CoPrd ),
/*input        */ .REG_CoEn   (REG_CoEn  ),
/*ouptut       */ .fifo_pop   (fifo_pop  ),
/*input  [31:0]*/ .dout       (dout      ),
/*output [3:0] */ .onehot     (onehot    ),
/*input        */ .di_idle    (di_idle   ),
/*output reg   */ .now_rd     (now_rd    ),
/*output reg   */ .now_wr     (now_wr    ),
/*output reg   */ .now_ini    (now_ini   ) 
);

sync_fifo_cnt #(.DSIZE(32), .ASIZE(6)) do_fifo(
/*input             */ .clk     (clk            ),
/*input             */ .soft_rst(REG_DoFRst     ),
/*input             */ .wen     (REG_DoF_push   ),
/*input             */ .ren     (fifo_pop       ),//CO2clk
/*input  [DSIZE-1:0]*/ .din     (REG_DoF        ),
/*output [DSIZE-1:0]*/ .dout    (dout           ),//clk2CO
/*output            */ .full    (REG_DoFFull    ),
/*output            */ .empty   (REG_DoFEpt     ),
/*output [ASIZE:0]  */ .cnt     (REG_DoFCnt[6:0])
);
assign REG_DoFCnt[7] = 1'b0;

//--------------------------------------------
// DI
//--------------------------------------------
wire [1:0] di_state;
jlm_dic jlm_dic(
/*input        */ .clk       (clk       ),
/*input        */ .rst       (REG_SetRst),
/*input        */ .CI        (CI        ),
/*input        */ .DI        (DI        ),
/*input  [7:0] */ .REG_CoPrd (REG_CoPrd ),
/*input        */ .REG_WrLog (REG_WrLog ),
/*input        */ .REG_IniLog(REG_IniLog),
/*output reg   */ .get_vld   (get_vld   ),
/*output [31:0]*/ .get_data  (get_data  ),
/*output [1:0] */ .get_ecc   (get_ecc   ),
/*input  [3:0] */ .onehot    (onehot    ),
/*output reg   */ .di_idle   (di_idle   ),
/*input        */ .now_rd    (now_rd    ),
/*input        */ .now_wr    (now_wr    ),
/*input        */ .now_ini   (now_ini   ),
/*output [1:0] */ .di_state  (di_state  )
);

sync_fifo_cnt #(.DSIZE(32), .ASIZE(6)) di_fifo(
/*input             */ .clk     (clk            ),
/*input             */ .soft_rst(REG_DiFRst     ),
/*input             */ .wen     (get_vld        ),
/*input             */ .ren     (REG_DiF_pop    ),
/*input  [DSIZE-1:0]*/ .din     (get_data       ),
/*output [DSIZE-1:0]*/ .dout    (REG_DiF        ),
/*output            */ .full    (REG_DiFFull    ),
/*output            */ .empty   (REG_DiFEpt     ),
/*output [ASIZE:0]  */ .cnt     (REG_DiFCnt[6:0])
);
assign REG_DiFCnt[7] = 1'b0;


endmodule

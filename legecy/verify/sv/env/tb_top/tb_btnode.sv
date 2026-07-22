
`ifndef BYPASS_LINK
    `define BYPASS_LINK                 \
    alias btc_dsel = DSEL;              \
    alias btc_sel  = SEL;               \
    alias btc_to   = TO;                \
    alias btc_cki_co = CKI_CO;          \
    alias btc_cko_ci = CKO_CI;          \
    alias btc_ci_cko = CI_CKO;          \
    alias btc_co_cki = CO_CKI;          \
    alias btc_ri_do = RI_DO;            \
    alias btc_do_ri = DO_RI;            \
    alias btc_di_ro = DI_RO;            \
    alias btc_ro_di = RO_DI;            \
    alias btc_fbdo_fbdi = FBDO_FBDI;    \
    alias btc_fbdi_fbdo = FBDI_FBDO;    \
    alias btc_mode0 = MODE0;            \
    alias btc_lb_clki = LB_CLKI;        \
    alias btc_lb_dati = LB_DATI;        \
    alias btc_lb_clko = LB_CLKO;        \
    alias btc_lb_dato = LB_DATO;
`endif

module tb_btnode(
    input  DSEL     ,

    inout  FBDI_FBDO,
    inout  FBDO_FBDI,

    inout  CKI_CO   ,
    inout  CKO_CI   ,
    inout  CI_CKO   ,
    inout  CO_CKI   ,
    inout  RI_DO    ,
    inout  DO_RI    ,
    inout  DI_RO    ,
    inout  RO_DI    ,

    input  MODE0    ,

    input  LB_CLKI  ,
    input  LB_DATI  ,
    output LB_CLKO  ,
    output LB_DATO  ,

    // inout VDDWL     ,
    // inout FSOURCE   ,
    
    output TO       ,
    input  SEL      ,
    //  input  FB_SEL   ,
    input  TPSEL    ,  //Add for UART

    input pad_lock
);

    parameter FPGA_VCU118 = 1;
    parameter NODE_ID = 0;

    wire  btc_cki_co;
    wire  btc_cko_ci;
    wire  btc_ci_cko;
    wire  btc_co_cki;
    wire  btc_ri_do ;
    wire  btc_do_ri ;
    wire  btc_di_ro ;
    wire  btc_ro_di ;
    wire  btc_dsel  ;
    wire  btc_sel   ;
//    wire  btc_fb_sel;
    wire  btc_to    ;
    wire  btc_fbdo_fbdi;
    wire  btc_fbdi_fbdo; 
    wire  btc_mode0;
    wire  btc_lb_clki;
    wire  btc_lb_dati;
    wire  btc_lb_dato;
    wire  btc_lb_clko;

`ifdef BOARD_ap1_top
    generate
        if(FPGA_VCU118 == 1) begin : G_VCU118
            ap1 ap1(
                .DSEL       (DSEL       ),
                .FBDI_FBDO  (FBDI_FBDO  ),
                .FBDO_FBDI  (FBDO_FBDI  ),
                .CKI_CO     (CKI_CO     ),
                .CKO_CI     (CKO_CI     ),
                .CI_CKO     (CI_CKO     ),
                .CO_CKI     (CO_CKI     ),
                .RI_DO      (RI_DO      ),
                .DO_RI      (DO_RI      ),
                .DI_RO      (DI_RO      ),
                .RO_DI      (RO_DI      ),
            
                .LB_CLKI    (LB_CLKI    ),
                .LB_DATI    (LB_DATI    ),
                .MODE0      (MODE0      ),
                .MODE1      (1'b0       ),
                .LB_CLKO    (LB_CLKO    ),
                .LB_DATO    (LB_DATO    ),
                       
                .FMC_CKI_CO     (btc_cki_co  ),
                .FMC_CKO_CI     (btc_cko_ci  ),
                .FMC_CI_CKO     (btc_ci_cko  ),
                .FMC_CO_CKI     (btc_co_cki  ),
                .FMC_DI_RO      (btc_di_ro   ),
                .FMC_RO_DI      (btc_ro_di   ),
                .FMC_DO_RI      (btc_do_ri   ),
                .FMC_RI_DO      (btc_ri_do   ),
                .FMC_FBDI_FBDO  (btc_fbdi_fbdo),
                .FMC_FBDO_FBDI  (btc_fbdo_fbdi),
                .FMC_DSEL       (btc_dsel    )
            );

            assign btc_sel = 1'bz;
//            assign btc_fb_sel = 1'bz;
            assign btc_mode0 = 1'bz;
            assign btc_lb_clki = 1'bz;
            assign btc_lb_dati = 1'bz;
        end
        else begin : G_BYPASS_LINK
            `BYPASS_LINK
        end
    endgenerate
`else
    `BYPASS_LINK
`endif

    `PROJECT_NAME btc(
    `ifndef FPGA_SYN

        .TO         (btc_to     ),
        .SEL        (btc_sel    ),
    `endif

    `ifdef BOARD_ap1_top
        .LB_CLKI    (btc_lb_clki),
        .LB_DATI    (btc_lb_dati),
        .LB_CLKO    (btc_lb_clko),
        .LB_DATO    (btc_lb_dato),
        .MODE0      (btc_mode0  ),
    `endif
        .DSEL       (btc_dsel   ),
        .FBDI_FBDO  (btc_fbdi_fbdo  ),
        .FBDO_FBDI  (btc_fbdo_fbdi  ),
        .TPSEL      (TPSEL      ),
        .CKI_CO     (btc_cki_co ),
        .CKO_CI     (btc_cko_ci ),
        .CI_CKO     (btc_ci_cko ),
        .CO_CKI     (btc_co_cki ),
        .RI_DO      (btc_ri_do  ),
        .DO_RI      (btc_do_ri  ),
        .DI_RO      (btc_di_ro  ),
        .RO_DI      (btc_ro_di  )
    ); 

endmodule

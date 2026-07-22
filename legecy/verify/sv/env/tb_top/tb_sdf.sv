
//---------------1. INST_PATH--------------------------------------------------
`ifdef PL_SIM   

	`define LVRO_WRAPPER_SLICE_INST_PATH   `BTC(i).lvro_wrapper_slice1
  	`define LVRO_WRAPPER_TOP_INST_PATH     `BTC(i).lvro_wrapper_top
		     
`endif

//---------------2. SDF_PATH----------------------------------------------------
`ifdef PL_SIM   

        /***** <<Input>>  LVRO SDF_PATH for POST_SIM  *****/

        `define LVRO_WRAPPER_SDF_PATH_SETUP_TT "/filesets/project/SG/public/btc_netlist/MAN2/20250214/sdf/lvro_wrapper_slice_tt_0p27v_70c.sdf.gz"
        `define LVRO_WRAPPER_SDF_PATH_MAX      "/filesets/project/SG/public/btc_netlist/MAN2/20250214/sdf/lvro_wrapper_slice_tt_0p27v_70c.sdf.gz"
		`define LVRO_WRAPPER_SDF_PATH_MIN      "/filesets/project/SG/public/btc_netlist/MAN2/20250214/sdf/lvro_wrapper_slice_tt_0p27v_70c.sdf.gz"

    	`ifdef POST_SIM
        	`ifdef CORNER_TYP
            		`define LVRO_WRAPPER_SDF_PATH	    `LVRO_WRAPPER_SDF_PATH_SETUP_TT	
        	`elsif CORNER_MAX
                    `define LVRO_WRAPPER_SDF_PATH	    `LVRO_WRAPPER_SDF_PATH_MAX	
        	`elsif CORNER_MIN
              	   `define LVRO_WRAPPER_SDF_PATH	    `LVRO_WRAPPER_SDF_PATH_MIN	
        	`endif

        /***** <<Input>>  LVRO SDF_PATH for GATE_SIM  *****/
    	`else
		    `define LVRO_WRAPPER_SDF_PATH	    	`LVRO_WRAPPER_SDF_PATH_SETUP_TT
    	`endif

`endif

//`ifdef POST_SIM
//`ifndef BLOCK_TEST
//generate 
//    for(genvar i = 0; i < `CHIP_NUM; i = i + 1) begin
//
//		`ifdef CORNER_TYP
//			initial  $sdf_annotate(`LVRO_WRAPPER_SDF_PATH, `LVRO_WRAPPER_SLICE_INST_PATH , ,"lvro_wrapper_slice1_sdf.log" , `MTM_SPEC, ,);   
//			initial  $sdf_annotate(`LVRO_WRAPPER_SDF_PATH, `LVRO_WRAPPER_TOP_INST_PATH , ,"lvro_wrapper_top_sdf.log" , `MTM_SPEC, ,);  
//		`elsif CORNER_MAX
//			initial  $sdf_annotate(`LVRO_WRAPPER_SDF_PATH, `LVRO_WRAPPER_SLICE_INST_PATH , ,"lvro_wrapper_slice1_sdf.log" , "MAXIMUM", ,);   
//			initial  $sdf_annotate(`LVRO_WRAPPER_SDF_PATH, `LVRO_WRAPPER_TOP_INST_PATH , ,"lvro_wrapper_top_sdf.log" , "MAXIMUM", ,);  
//		`elsif CORNER_MIN
//			initial  $sdf_annotate(`LVRO_WRAPPER_SDF_PATH, `LVRO_WRAPPER_SLICE_INST_PATH , ,"lvro_wrapper_slice1_sdf.log" , "MINIMUM", ,);   
//			initial  $sdf_annotate(`LVRO_WRAPPER_SDF_PATH, `LVRO_WRAPPER_TOP_INST_PATH , ,"lvro_wrapper_top_sdf.log" , "MINIMUM", ,);  
//		`endif
//    end
//endgenerate
//`endif
//`endif

//////////////////////////////////////////////////////////////
//  LVRO 
//////////////////////////////////////////////////////////////


//---------------1. INST_PATH--------------------------------------------------
`ifndef PL_SIM   
        /***** <<Input>>  LVRO INST_PATH for RTL_SIM  *****/
	`define SLICE_RO_CORE_0_INST_PATH   `BTC(i).lvro_wrapper_slice1.G_CORE_RO_BLK[0].RO_INST
   	`define SLICE_RO_CORE_1_INST_PATH   `BTC(i).lvro_wrapper_slice1.G_CORE_RO_BLK[1].RO_INST
   	
  	`define TOP_RO_CORE_0_INST_PATH     `BTC(i).lvro_wrapper_top.G_CORE_RO_BLK[0].RO_INST
   	`define TOP_RO_CORE_1_INST_PATH     `BTC(i).lvro_wrapper_top.G_CORE_RO_BLK[1].RO_INST
   	
`else
        /****** <<Input>>  LVRO INST_PATH for GATE_SIM & POST_SIM *****/
	`define SLICE_RO_CORE_0_INST_PATH   `BTC(i).lvro_wrapper_slice1.G_CORE_RO_BLK_0__RO_INST
   	`define SLICE_RO_CORE_1_INST_PATH   `BTC(i).lvro_wrapper_slice1.G_CORE_RO_BLK_1__RO_INST

  	`define TOP_RO_CORE_0_INST_PATH     `BTC(i).lvro_wrapper_top.G_CORE_RO_BLK_0__RO_INST
   	`define TOP_RO_CORE_1_INST_PATH     `BTC(i).lvro_wrapper_top.G_CORE_RO_BLK_1__RO_INST
		
`endif

//---------------2. SDF_PATH----------------------------------------------------
`ifndef PL_SIM   

        /***** <<Input>>  LVRO SDF_PATH for RTL_SIM  *****/
	`define RO_CORE_CTRL_SDF_PATH       "../../../ip/RO/sdf/MXDWROT4_0P29V_tt_0p27v_70c.sdf.gz"


`else
        /////////////////////// version check:
        // LVRO TT      
        // LVRO MAX	
        // LVRO MIN	
        // LVRO_WRAPPER  TT     
        // LVRO_WRAPPER  MAX	
        // LVRO_WRAPPER  MIN	
        ///////////////////////

        /***** <<Input>>  LVRO SDF_PATH for POST_SIM  *****/
        `define RO_CORE_CTRL_SDF_PATH_SETUP_TT   	"/project/SG/public/btc_netlist/MAN2/20250320/sdf/MXDWROT4_0P29V.mission_setup_tt_0p27v_85c_typical.sdf.gz"
                //
			    //This path is used for gate-sim

        `define RO_CORE_CTRL_SDF_PATH_MAX        	"/project/SG/public/btc_netlist/MAN2/20250320/sdf/MXDWROT4_0P29V.mission_hold_ffgnp_0p27v_25c_cbest_ccbest.sdf.gz"
        `define RO_CORE_CTRL_SDF_PATH_MIN        	"/project/SG/public/btc_netlist/MAN2/20250320/sdf/MXDWROT4_0P29V.mission_hold_ssgnp_0p27v_25c_cworst_ccworst_T.sdf.gz"		
	

    	`ifdef POST_SIM
        	`ifdef CORNER_TYP
            		`define RO_CORE_CTRL_SDF_PATH    `RO_CORE_CTRL_SDF_PATH_SETUP_TT
        	`elsif CORNER_MAX
           		 `define RO_CORE_CTRL_SDF_PATH   `RO_CORE_CTRL_SDF_PATH_MAX
          	`elsif CORNER_MIN
           		 `define RO_CORE_CTRL_SDF_PATH   `RO_CORE_CTRL_SDF_PATH_MIN
        	`elsif CORNER_SETUP_SSG
           		 `define RO_CORE_CTRL_SDF_PATH   `RO_CORE_CTRL_SDF_PATH_SETUP_SSG
        	`elsif CORNER_HOLD_TT
            		`define RO_CORE_CTRL_SDF_PATH    `RO_CORE_CTRL_SDF_PATH_HOLD_TT
        	`elsif CORNER_HOLD_FFG
            		`define RO_CORE_CTRL_SDF_PATH    `RO_CORE_CTRL_SDF_PATH_HOLD_FFG
        	`endif

        /***** <<Input>>  LVRO SDF_PATH for GATE_SIM  *****/
    	`else		
   		    `define RO_CORE_CTRL_SDF_PATH 	`RO_CORE_CTRL_SDF_PATH_SETUP_TT
    	`endif

`endif





//////////////////////////////////////////////////////////////
//  MTM
//////////////////////////////////////////////////////////////
`ifndef POST_SIM
    `define RO_SDF_DLY                      "MAXIMUM"
`else
    `define RO_SDF_DLY                      `MTM_SPEC
`endif



//////////////////////////////////////////////////////////////
//  CHIPTOP 
//////////////////////////////////////////////////////////////

`define CHIPTOP_SDF_PATH_TYP                "/project/SG/public/btc_netlist/MAN2/20250423/sdf/MAN2.mission_setup_tt_0p75v_85c_typical.sdf.gz"
`define CHIPTOP_SDF_PATH_MIN                "/project/SG/public/btc_netlist/MAN2/20250423/sdf/MAN2.mission_setup_ssgnp_0p675v_m40c_rcworst_ccworst_T.sdf.gz"
`define CHIPTOP_SDF_PATH_MAX                "/project/SG/public/btc_netlist/MAN2/20250423/sdf/MAN2.mission_hold_ffgnp_0p825v_125c_cbest_ccbest.sdf.gz"
`define CHIPTOP_SDF_PATH_SETUP_SSG          "To be update"
`define CHIPTOP_SDF_PATH_HOLD_TT            "To be update"
`define CHIPTOP_SDF_PATH_HOLD_FFG           "To be update"


//////////////////////////////////////////////////////////////
//  Generate $sdf_annotate code 
//////////////////////////////////////////////////////////////



/////////////////////////////////////////////////************dont touch , pls edit the path above or comment them****************************
//---------------1. LVRO:
`ifdef PL_SIM
    `define RO_TOP_SDF 
    `define RO_CORE_CTRL_SDF
  `ifndef BLOCK_TEST
	`undef STUB_RO
  `endif
`else
    `ifdef  RO_TEST
        `define RO_TOP_SDF
    `endif

    `ifndef STUB_RO
        `ifdef RO_TEST
            `define RO_CORE_CTRL_SDF
        `endif
    `endif
`endif


`ifndef PL_SIM
`ifdef RO_CORE_CTRL_SDF
generate 
    for(genvar i = 0; i < `CHIP_NUM; i = i + 1) begin
  	`ifndef STUB_RO 
        	initial  $sdf_annotate(`RO_CORE_CTRL_SDF_PATH, `SLICE_RO_CORE_0_INST_PATH , ,"lvro_slice1_0_sdf.log" , `RO_SDF_DLY, ,);   
        	initial  $sdf_annotate(`RO_CORE_CTRL_SDF_PATH, `SLICE_RO_CORE_1_INST_PATH , ,"lvro_slice1_1_sdf.log" , `RO_SDF_DLY, ,);   
        	initial  $sdf_annotate(`RO_CORE_CTRL_SDF_PATH, `TOP_RO_CORE_0_INST_PATH   , ,"lvro_top_0_sdf.log" , `RO_SDF_DLY, ,);   
        	initial  $sdf_annotate(`RO_CORE_CTRL_SDF_PATH, `TOP_RO_CORE_1_INST_PATH   , ,"lvro_top_1_sdf.log" , `RO_SDF_DLY, ,);   
   	`endif
    end
endgenerate
`endif
`endif

//---------------3. CHIPTOP
generate 
    for(genvar i = 0; i < `CHIP_NUM; i = i + 1) begin
	`ifdef POST_SIM
    `ifndef BLOCK_TEST
    	`ifdef CORNER_TYP
        	initial  $sdf_annotate(`CHIPTOP_SDF_PATH_TYP,  `BTC(i), , "chiptop_typ_sdf.log", "TYPICAL", ,);
    	`elsif CORNER_MAX
        	initial  $sdf_annotate(`CHIPTOP_SDF_PATH_MAX,  `BTC(i), , "chiptop_max_sdf.log", "MINIMUM", ,);
    	`elsif CORNER_MIN
        	initial  $sdf_annotate(`CHIPTOP_SDF_PATH_MIN,  `BTC(i), , "chiptop_min_sdf.log", "MAXIMUM", ,);
    	`elsif CORNER_SETUP_SSG
        	initial  $sdf_annotate(`CHIPTOP_SDF_PATH_SETUP_SSG,  `BTC(i), , , `MTM_SPEC, ,);
    	`elsif CORNER_HOLD_TT
        	initial  $sdf_annotate(`CHIPTOP_SDF_PATH_HOLD_TT,  `BTC(i), , , `MTM_SPEC, ,);
    	`elsif CORNER_HOLD_FFG
        	initial  $sdf_annotate(`CHIPTOP_SDF_PATH_HOLD_FFG,  `BTC(i), , , `MTM_SPEC, ,);
    	`endif
    `endif
	`endif
    end
endgenerate
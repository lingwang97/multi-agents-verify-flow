//----------------------------------------------------------------------------------------
// Place Global Uvm-base Env Filelist Here
//----------------------------------------------------------------------------------------

// --------------BASE FILE Start-------------------- 
../../../../verify/utils/global_pkg.sv
../../../../verify/utils/reg/reg_mdl_pkg.sv
../../../../verify/ral/ral_reg_model.sv

../../../../verify/utils/base_uvc/base_uvc_pkg.sv

// --------------BASE FILE End----------------------


// --------------MODULE-FILE Start----------------------
../../../../verify/env/top_if.sv
-f ../../../../verify/uvc/reg/script/uvm.f
-f ../../../../verify/uvc/jls/script/uvm.f
-f ../../../../verify/uvc/cpft/script/uvm.f
-f ../../../../verify/uvc/uart/script/uvm.f
-f ../../../../verify/uvc/efuse/script/uvm.f
// --------------MODULE-FIlE End------------------------



-f ../../../../verify/tb_top/filelist/tb_top_soc.f
../../../../verify/env/top_pkg.sv



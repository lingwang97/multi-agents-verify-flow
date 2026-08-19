//----------------------------------------------------------------------------------------
// Place Block Uvm-base Env Filelist Here
//----------------------------------------------------------------------------------------

// --------------BASE FILE Start-------------------- 
../../../../verify/utils/global_pkg.sv
../../../../verify/utils/reg/reg_mdl_pkg.sv
../../../../verify/ral/ral_reg_model.sv

../../../../verify/utils/base_uvc/base_uvc_pkg.sv

// --------------BASE FILE End----------------------


-f ../../../../verify/uvc/jls/script/uvm.f

../../../../verify/seq/jls_block_base_seq.sv
../../../../verify/test/jls_block_base_test.sv

-f ../../../../verify/tb_top/filelist/tb_top_jls.f



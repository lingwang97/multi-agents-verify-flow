class reg_coverage extends uvm_subscriber #(reg_coverage_item);
 
   `uvm_component_utils(reg_coverage)
  
   uvm_analysis_imp #(reg_coverage_item, reg_coverage)  mon2cov;

   virtual reg_if reg_vif;
   reg_coverage_item req_h;
    RAL_PKG::ral_gen_main ral;

   string report_id = "reg_coverage";

// //mid_clk domain 
//  covergroup cg_write_read_ral ; //@ (posedge reg_vif.clk);
//    option.per_instance = 0;
//    cov_psel  : coverpoint reg_vif.psel{
//      type_option.weight = 0;
//      bins SEL = {1};
//    }
//    cov_penable  : coverpoint reg_vif.penable{
//      type_option.weight = 0;
//      bins EN = (0 => 1);
//    }
//     cov_pwrite  : coverpoint reg_vif.pwrite{
//      type_option.weight = 0;
//      bins WR = (1 => 0);
//      bins RD = {0};
//    }   
//    cov_paddr  : coverpoint reg_vif.paddr{
//      type_option.weight = 0;
//      bins work_reg_version_addr[]    =  {[REG_VERSION_ADDR: REG_VERSION_ADDR + (REG_VERSION_WIDTH-1)*32]} with (item%4==0);
//      bins work_reg_work_addr[]       =  {[REG_WORK_ADDR: REG_WORK_ADDR + (REG_WORK_WIDTH-1)*32]} with (item%4==0);
//      bins work_reg_noncebuf_addr[]   =  {[REG_NONCEBUF_ADDR: REG_NONCEBUF_ADDR + (REG_NONCEBUF_WIDTH-1)*32]} with (item%4==0);
//      bins work_reg_spdcore_addr[]    =  {[REG_SPDCORE_ADDR: REG_SPDCORE_ADDR + (REG_SPDCORE_WIDTH-1)*32]} with (item%4==0);
//      bins work_reg_rest_addr[]       =  {[REG_CORE_CFG_ADDR:REG_DH_MON_OUT_10_ADDR ], 
//                                          [REG_NONCE_UPDATE_ADDR: PROJECT_ID_ADDR]} with (item%4==0);
//      bins speed_reg_spd_addr[]       =  {[REG_SPD_ADDR: REG_SPD_ADDR + (REG_SPD_WIDTH-1)*32]} with (item%4==0);
//      bins speed_reg_selfcal_wtd_timeout_addr[]       
//                                      =  {[REG_SELFCAL_WTD_TIMEOUT_ADDR: REG_SELFCAL_WTD_TIMEOUT_ADDR + (REG_SELFCAL_WTD_TIMEOUT_WIDTH-1)*32]} with (item%4==0);
//      bins speed_reg_spdlog_addr[]    =  {[REG_SPDLOG_ADDR: REG_SPDLOG_ADDR + (REG_SPDLOG_WIDTH-1)*32]} with (item%4==0);
//      bins speed_reg_sslog_addr[]     =  {[REG_SSLOG_ADDR: REG_SSLOG_ADDR + (REG_SSLOG_WIDTH-1)*32]} with (item%4==0);
//      
//      bins speed_reg_selfcal_log_addr[] =  {[REG_SELFCAL_LOG_ADDR: REG_SELFCAL_LOG_ADDR + (REG_SELFCAL_LOG_WIDTH-1)*32]} with (item%4==0);
//      bins speed_reg_tclkpd_addr[]     =  {[REG_tclkpd_ADDR: REG_tclkpd_ADDR + (REG_tclkpd_WIDTH-1)*32]} with (item%4==0);
//      bins speed_reg_rest_addr[]        =  {[REG_SS_CTRL_ADDR: REG_GBP_STAT_ADDR],
//                                            [REG_SELFCAL_CTRL_ADDR: REG_SELFCAL_CTRL],
//                                            [`BASE_SPEED + `UVM_REG_ADDR_WIDTH'h628:`BASE_SPEED + `UVM_REG_ADDR_WIDTH'h63c],
//                                            [`BASE_SPEED + `UVM_REG_ADDR_WIDTH'h6a8:`BASE_SPEED + `UVM_REG_ADDR_WIDTH'h6b8]  } with (item%4==0);
//      //comment:
//      //mx2 is configured by write reg_core_cfg and reg_core_wr_data
//      //it should be covered by mx2 module
//    }    
//    cov_ral_addr : cross cov_psel, cov_penable, cov_pwrite, cov_paddr;
//  endgroup
//
//  // xclk domain
//  covergroup cg_write_read_ral_xclk ; //@ (posedge reg_vif.clk);
//    option.per_instance = 0;
//    cov_psel_xclk  : coverpoint reg_vif.xclk_psel{
//      type_option.weight = 0;
//      bins SEL = {1};
//    }
//    cov_penable_xclk  : coverpoint reg_vif.xclk_penable{
//      type_option.weight = 0;
//      bins EN = (0 => 1);
//    }
//     cov_pwrite_xclk  : coverpoint reg_vif.xclk_pwrite{
//      type_option.weight = 0;
//      bins WR = (1 => 0);
//      bins RD = {0};
//    } 
//
//    cov_paddr_xclk  : coverpoint reg_vif.xclk_paddr{
//      type_option.weight = 0;
//      //reg_pllchgt,reg_pllrstt, reg_pll_mf, reg_pll_mfclkf not in use
//      bins rst_addr[]     =  {[REG_RI_WEN_ADDR: REG_IO_PAD_CFG_ADDR]} with (item%4==0);
//      bins cpm_addr[]     =  {[REG_ri_wen_addr: REG_io_pad_cfg_addr], 
//                              [] } with (item%4==0);
//      bins pvt_addr[]     =  {[`BASE_PVT:`BASE_PVT + `UVM_REG_ADDR_WIDTH'h4]} with (item%4==0);
//      bins efuse_addr[]   =  {[`BASE_EFUSE:`BASE_EFUSE + `UVM_REG_ADDR_WIDTH'h8],
//                              [`BASE_EFUSE + `UVM_REG_ADDR_WIDTH'h80:`BASE_EFUSE + `UVM_REG_ADDR_WIDTH'hbc]} with (item%4==0);
//      bins roctrl_addr[]  =  {[`BASE_ROCTRL0:`BASE_ROCTRL0 + `UVM_REG_ADDR_WIDTH'h4], 
//                              [`BASE_ROCTRL0 + `UVM_REG_ADDR_WIDTH'h20:`BASE_ROCTRL0 + `UVM_REG_ADDR_WIDTH'h24], 
//                              [`BASE_ROCTRL0 + `UVM_REG_ADDR_WIDTH'h40:`BASE_ROCTRL0 + `UVM_REG_ADDR_WIDTH'h44]} with (item%4==0);
//      bins vldctrl_addr   =  {`BASE_VLDCTRL} ;
//      bins top_roctrl_addr=  {`BASE_TOP_ROCTRL};
//      bins jls_addr[]     =  {[`BASE_JLS: `BASE_JLS + `UVM_REG_ADDR_WIDTH'hc]} with (item%4==0);
//    }
//    cov_ral_addr_rd_xclk : cross cov_psel_xclk, cov_penable_xclk, cov_pwrite_xclk, cov_paddr_xclk;
//    //cov_ral_addr_wr_xclk : cross cov_psel_xclk, cov_pwrite_xclk, cov_paddr_xclk;
//  endgroup

// reset field number
  covergroup cg_rst_check;
    option.per_instance = 0;
    cov_rst_field: coverpoint reg_vif.NUM{
    //bins field_num = {459};
    bins field_num = {`RST_FD_NUM};
    }
  endgroup
//*/


  function new(string name, uvm_component parent);
    begin
    super.new(name, parent);
    //cg_write_read_ral = new();    
    //cg_write_read_ral_xclk = new();    
    cg_rst_check = new( );
    mon2cov = new("mon2cov",this);

    end
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual reg_if)::get(this , "" , "reg_vif" ,reg_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
    if(!uvm_config_db#(RAL_PKG::ral_gen_main)::get(this , "" , "ral" ,ral))
      `uvm_fatal(get_full_name(), "Ral handle missing")


  endfunction

  function void write(reg_coverage_item t); 
   req_h = t;
   cg_rst_check.sample();

  endfunction

endclass

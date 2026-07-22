class io_coverage extends uvm_subscriber #(io_coverage_item);
 
   `uvm_component_utils(io_coverage)
  
   uvm_analysis_imp #(io_coverage_item, io_coverage)  mon2cov;

   virtual io_if io_vif;
   io_coverage_item req_h;

   string report_id = "io_coverage";

   covergroup cg_io_pad_cfg;
     option.per_instance = 0;

     cov_IO_DS_CKI_CO : coverpoint  io_vif.REG_io_n_cfg[1:0];
     cov_IO_DS_CI_CKO : coverpoint  io_vif.REG_io_n_cfg[5:4];
     cov_IO_DS_DI_RO : coverpoint  io_vif.REG_io_n_cfg[9:8];
     cov_IO_DS_RI_DO : coverpoint  io_vif.REG_io_n_cfg[13:12];
     cov_IO_DS_FBDO_FBDI : coverpoint  io_vif.REG_io_n_cfg[17:16];
     cov_IO_DS_PAD : coverpoint  io_vif.REG_io_n_cfg[21:20];
     cov_IO_ST_CKI_CO : coverpoint  io_vif.REG_io_n_cfg[24];
     cov_IO_ST_CI_CKO : coverpoint  io_vif.REG_io_n_cfg[25];
     cov_IO_ST_DI_RO : coverpoint  io_vif.REG_io_n_cfg[26];
     cov_IO_ST_RI_DO : coverpoint  io_vif.REG_io_n_cfg[27];
     cov_IO_ST_FBDO_FBDI : coverpoint  io_vif.REG_io_n_cfg[28];
     cov_IO_ST_PAD : coverpoint  io_vif.REG_io_n_cfg[29];

     cov_IO_DS_CO_CKI : coverpoint  io_vif.REG_io_s_cfg[1:0];
     cov_IO_DS_CKO_CI : coverpoint  io_vif.REG_io_s_cfg[5:4];
     cov_IO_DS_RO_DI : coverpoint  io_vif.REG_io_s_cfg[9:8];
     cov_IO_DS_DO_RI : coverpoint  io_vif.REG_io_s_cfg[13:12];
     cov_IO_DS_FBDI_FBDO : coverpoint  io_vif.REG_io_s_cfg[17:16];
     cov_IO_ST_CO_CKI : coverpoint  io_vif.REG_io_s_cfg[20];
     cov_IO_ST_CKO_CI : coverpoint  io_vif.REG_io_s_cfg[21];
     cov_IO_ST_RO_DI : coverpoint  io_vif.REG_io_s_cfg[22];
     cov_IO_ST_DO_RI : coverpoint  io_vif.REG_io_s_cfg[23];
     cov_IO_ST_FBDI_FBDO : coverpoint  io_vif.REG_io_s_cfg[24];

     cov_io_dis_cko_inv : coverpoint  io_vif.REG_cko_inv;

   endgroup

   covergroup cg_io_reg_fb_sel;
     option.per_instance = 0;

     cov_reg_fb_sel : coverpoint  io_vif.REG_fb_sel;

   endgroup

   covergroup cg_io_sel_dsel;
     option.per_instance = 0;

     cov_io_sel : coverpoint  io_vif.SEL_n;
     cov_io_dsel : coverpoint  io_vif.DSEL_n;

     cross_io_sel_dsel : cross cov_io_sel, cov_io_dsel;

   endgroup

   covergroup cg_io_sel_dsel_toggle;
     option.per_instance = 0;

     cov_io_sel_toggle : coverpoint  io_vif.SEL_n
      {
        bins sel_l2h = (1'b0 => 1'b1);
        bins sel_h2l = (1'b1 => 1'b0);
      }
     cov_io_dsel_toggle : coverpoint  io_vif.DSEL_n
      {
        bins dsel_l2h = (1'b0 => 1'b1);
        bins dsel_h2l = (1'b1 => 1'b0);
      }     

   endgroup

   covergroup cg_io_tpsel;
     option.per_instance = 0;

     cov_pin_tpsel : coverpoint  io_vif.pin_tpsel;

   endgroup

   covergroup cg_card_sel;
     option.per_instance = 0;
     cov_card_sel  : coverpoint  io_vif.card_sel;
   endgroup

  function new(string name, uvm_component parent);
    begin
    super.new(name, parent);
    //cg_card_sel = new();
    cg_io_pad_cfg = new();
    cg_io_reg_fb_sel = new();
    cg_io_sel_dsel = new();
    cg_io_sel_dsel_toggle = new();
    cg_io_tpsel = new();
    mon2cov = new("mon2cov",this);
    end
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual io_if)::get(this , "" , "io_vif" ,io_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction
  
  function void write(io_coverage_item t); 
   req_h = t;
   //cg_card_sel.sample();
   cg_io_pad_cfg.sample();
   cg_io_reg_fb_sel.sample();
   cg_io_sel_dsel.sample();
   cg_io_sel_dsel_toggle.sample();
   cg_io_tpsel.sample();
   
  endfunction

endclass

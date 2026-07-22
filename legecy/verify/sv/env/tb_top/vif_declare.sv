//virtual interface
virtual top_if top_vif;
virtual ro_if ro_vif;
virtual mx2_if mx2_vif;
top_if top_pif();
ro_if ro_pif();
mx2_if mx2_pif();

initial  top_vif = top_pif;
initial  ro_vif = ro_pif;
initial  mx2_vif = mx2_pif;

virtual cpm_if cpm_vif;
cpm_if cpm_pif();
initial  cpm_vif = cpm_pif;

virtual pvt_if pvt_vif;
pvt_if pvt_pif();
initial  pvt_vif = pvt_pif;

virtual rst_if rst_vif;
rst_if rst_pif();

initial  rst_vif = rst_pif;

virtual rst_assertion_if rst_assertion_vif;
rst_assertion_if rst_assertion_pif();

initial  rst_assertion_vif = rst_assertion_pif;

virtual mc_if mc_vif;
mc_if mc_pif();

initial  mc_vif = mc_pif;

virtual work_ctrl_if work_ctrl_vif;
work_ctrl_if work_ctrl_pif();
initial work_ctrl_vif = work_ctrl_pif;

virtual cpft_if cpft_vif;
cpft_if cpft_pif();

initial  cpft_vif = cpft_pif;

virtual jls_if jls_vif;
jls_if jls_pif();

initial  jls_vif = jls_pif;

virtual jamlink_if jamlink_vif;
jamlink_if jamlink_pif();

initial  jamlink_vif = jamlink_pif;
virtual efuse_if efuse_vif;
efuse_if efuse_pif();

initial  efuse_vif = efuse_pif;

virtual io_if io_vif;
io_if io_pif();

initial  io_vif = io_pif;

virtual dfx_if dfx_vif;
dfx_if dfx_pif();

initial  dfx_vif = dfx_pif;

virtual spd_if spd_vif;
spd_if spd_pif();

initial  spd_vif = spd_pif;

virtual ft_if ft_vif;
ft_if ft_pif();

initial  ft_vif = ft_pif;

virtual reg_if reg_vif;
reg_if reg_pif();

initial reg_vif = reg_pif;

virtual selfclk_if selfclk_vif;
selfclk_if selfclk_pif();

initial selfclk_vif = selfclk_pif;

`ifdef VIP
  svt_uart_if uart_vip_pif(.clk(uart_clk));
  svt_uart_bfm_wrapper  #(.UV_DEVICE_TYPE(`UV_DTE)) Bfm0 (uart_vip_pif);
  virtual  svt_uart_if uart_vip_vif;
  initial  uart_vip_vif = uart_vip_pif;
`endif

  virtual uart_if uart_vif;
  uart_if uart_pif();
  initial  uart_vif = uart_pif;

initial
  begin
    uvm_config_db#(virtual interface top_if)::set( null, "*", "top_vif",top_vif);
    uvm_config_db#(virtual interface ro_if)::set( null, "*", "ro_vif",ro_vif);
    uvm_config_db#(virtual interface mx2_if)::set(null, "*", "mx2_vif", mx2_vif);
    uvm_config_db#(virtual interface cpm_if)::set( null, "*", "cpm_vif",cpm_vif);
    uvm_config_db#(virtual interface pvt_if)::set( null, "*", "pvt_vif",pvt_vif);
    uvm_config_db#(virtual interface rst_if)::set( null, "*", "rst_vif",rst_vif);
    uvm_config_db#(virtual interface rst_assertion_if)::set( null, "*", "rst_assertion_vif",rst_assertion_vif);
    uvm_config_db#(virtual interface mc_if)::set( null, "*", "mc_vif",mc_vif);
    uvm_config_db#(virtual interface io_if)::set( null, "*", "io_vif",io_vif);
    uvm_config_db#(virtual interface cpft_if)::set( null, "*", "cpft_vif",cpft_vif);
    uvm_config_db#(virtual interface dfx_if)::set( null, "*", "dfx_vif",dfx_vif);
    uvm_config_db#(virtual interface efuse_if)::set( null, "*", "efuse_vif",efuse_vif);
    uvm_config_db#(virtual interface ft_if)::set( null, "*", "ft_vif",ft_vif);
    uvm_config_db#(virtual interface spd_if)::set( null, "*", "spd_vif",spd_vif);
    uvm_config_db#(virtual interface jamlink_if)::set( null, "*", "jamlink_vif",jamlink_vif);
    `ifdef VIP
    uvm_config_db#(virtual interface svt_uart_if)::set( null, "*", "dte_vif",uart_vip_vif);
    //uvm_config_db#(virtual interface svt_uart_if)::set(uvm_root::get(),"uvm_test_top.top_env_h.uart_env_h","dte_vif", uart_pif);
    `endif

    uvm_config_db#(virtual interface uart_if)::set( null, "*", "uart_vif",uart_vif);
    uvm_config_db#(virtual interface jls_if)::set( null, "*", "jls_vif",jls_vif);
    uvm_config_db#(virtual interface reg_if)::set( null, "*", "reg_vif",reg_vif);
    uvm_config_db#(virtual interface selfclk_if)::set( null, "*", "selfclk_vif",selfclk_vif);

    uvm_config_db#(virtual interface work_ctrl_if)::set( null, "*", "work_ctrl_vif",work_ctrl_vif);

    //uvm_config_db#(pvt_tvsenw)::set( null, "*", "m_pvt_tsensw",`TB_TOP.g_spac.esm_pvt_spaces.m_pvt_tsensw);    
  end

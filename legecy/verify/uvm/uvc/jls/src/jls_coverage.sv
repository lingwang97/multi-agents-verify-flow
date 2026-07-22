//`define 
//package chip_jls_type;
//	typedef enum {IDLE, CMD, ADDR, NOP, INIT, WR, LEN, RD} fsm_a;
//endpackage

//import chip_jls_type::*;
   //typedef enum {IDLE, CMD, ADDR, NOP, INIT, WR, LEN, RD} fsm_a;

//-----------------------------
// FSM

localparam JlS_FSM_IDLE = 3'b000;
localparam JlS_FSM_CMD	= 3'b001;
localparam JlS_FSM_ADDR = 3'b010;
localparam JlS_FSM_NOP  = 3'b011;
localparam JlS_FSM_INIT = 3'b100;
localparam JlS_FSM_WR   = 3'b101;
localparam JlS_FSM_LEN  = 3'b110;
localparam JlS_FSM_RD   = 3'b111;

localparam APB_BUS_IDLE = 2'b00;
localparam APB_BUS_WSETUP = 2'b01;
localparam APB_BUS_RSETUP = 2'b10;
localparam APB_BUS_ENABLE = 2'b11;

class jls_coverage extends uvm_subscriber #(jls_coverage_item);
 
   `uvm_component_utils(jls_coverage)
  
   uvm_analysis_imp #(jls_coverage_item, jls_coverage)  mon2cov;

   virtual jls_if jls_vif;
   jls_coverage_item req_h;
	//enum logic[2:0]
   string report_id = "jls_coverage";
   //typedef enum {IDLE, CMD, ADDR, NOP, INIT, WR, LEN, RD} fsm_a;
   logic [2:0] cur_state_t;
   logic [1:0] xclk_cur_state_t;
   logic [1:0] midclk_cur_state;

   covergroup cg_cur_state @(cur_state_t);
     option.per_instance = 0;
    cov_cur_state : coverpoint jls_vif.cur_state
					{
						//bins s1 = (`IDLE => `CMD => `ADDR => `IDLE);
						bins s1 = (JlS_FSM_IDLE => JlS_FSM_CMD => JlS_FSM_ADDR => JlS_FSM_IDLE);
						bins s2 = (JlS_FSM_IDLE => JlS_FSM_CMD => JlS_FSM_ADDR => JlS_FSM_NOP => JlS_FSM_INIT => JlS_FSM_IDLE);	
						bins s3 = (JlS_FSM_IDLE => JlS_FSM_CMD => JlS_FSM_ADDR => JlS_FSM_NOP => JlS_FSM_WR => JlS_FSM_IDLE);	
						bins s4 = (JlS_FSM_IDLE => JlS_FSM_CMD => JlS_FSM_ADDR => JlS_FSM_NOP => JlS_FSM_LEN => JlS_FSM_RD => JlS_FSM_IDLE);		
						//bins s5 = (JlS_FSM_CMD => JlS_FSM_IDLE);
						//bins s6 = (JlS_FSM_ADDR => JlS_FSM_IDLE);
						bins s7 = (JlS_FSM_IDLE => JlS_FSM_CMD => JlS_FSM_ADDR => JlS_FSM_NOP => JlS_FSM_LEN => JlS_FSM_IDLE);	
						//by reset_detect
						bins s8 = (JlS_FSM_CMD => JlS_FSM_IDLE);
						bins s9 = (JlS_FSM_ADDR => JlS_FSM_IDLE);
						bins s10 = (JlS_FSM_NOP => JlS_FSM_IDLE);
						bins s11 = (JlS_FSM_INIT => JlS_FSM_IDLE);
						bins s12 = (JlS_FSM_WR => JlS_FSM_IDLE);
						bins s13 = (JlS_FSM_LEN => JlS_FSM_IDLE);
						bins s14 = (JlS_FSM_RD => JlS_FSM_IDLE);
						//by start_detect
						bins s15 = (JlS_FSM_IDLE => JlS_FSM_CMD);
						bins s16 = (JlS_FSM_ADDR => JlS_FSM_CMD);
						bins s17 = (JlS_FSM_NOP => JlS_FSM_CMD);
						bins s18 = (JlS_FSM_INIT => JlS_FSM_CMD);
						bins s19 = (JlS_FSM_WR => JlS_FSM_CMD);
						bins s20 = (JlS_FSM_LEN => JlS_FSM_CMD);
						bins s21 = (JlS_FSM_RD => JlS_FSM_CMD);
						
						bins allother = default;
					}
   endgroup




   covergroup cg_xclk_cur_state @(xclk_cur_state_t);
        option.per_instance = 0;
	  cov_xclk_cur_state : coverpoint jls_vif.xclk_apb_state_cur
					{
						bins s1 = (APB_BUS_IDLE => APB_BUS_RSETUP => APB_BUS_ENABLE => APB_BUS_IDLE);
						bins s2 = (APB_BUS_IDLE => APB_BUS_WSETUP => APB_BUS_ENABLE => APB_BUS_IDLE);
						bins allother = default;
					}
   endgroup

   covergroup cg_std_cur_state;
        option.per_instance = 0;
	      cov_xclk_cur_state : coverpoint jls_vif.std_apb_state_cur
					{
						bins s1 = (APB_BUS_IDLE => APB_BUS_RSETUP => APB_BUS_ENABLE => APB_BUS_IDLE);
						bins s2 = (APB_BUS_IDLE => APB_BUS_WSETUP => APB_BUS_ENABLE => APB_BUS_IDLE);
						bins allother = default;
					}
   endgroup
   
   covergroup cg_midclk_cur_state @(midclk_cur_state);
           option.per_instance = 0;

  	cov_midclk_cur_state : coverpoint jls_vif.apb_state_cur
					{
						bins s1 = (APB_BUS_IDLE => APB_BUS_RSETUP => APB_BUS_ENABLE => APB_BUS_IDLE);
						bins s2 = (APB_BUS_IDLE => APB_BUS_WSETUP => APB_BUS_ENABLE => APB_BUS_IDLE);
						bins allother = default;
					}
   endgroup
   
  
   covergroup cg_jls_mid;
     option.per_instance = 0;
    cov_jls_mid_psel : coverpoint jls_vif.psel;
    cov_jls_mid_penable : coverpoint jls_vif.penable;
    cov_jls_mid_pwrite : coverpoint jls_vif.pwrite;
    selenable:cross cov_jls_mid_psel,cov_jls_mid_penable{
      bins one_zero = binsof(cov_jls_mid_psel)intersect{1}&&binsof(cov_jls_mid_penable)intersect{0};
      bins one_one  = binsof(cov_jls_mid_psel)intersect{1}&&binsof(cov_jls_mid_penable)intersect{1};
      ignore_bins hi= binsof(cov_jls_mid_psel)intersect{0}&&binsof(cov_jls_mid_penable)intersect{1};
    }
    selwrite:cross cov_jls_mid_psel,cov_jls_mid_pwrite{
      bins one_zero = binsof(cov_jls_mid_psel)intersect{1}&&binsof(cov_jls_mid_pwrite)intersect{0};
      bins one_one  = binsof(cov_jls_mid_psel)intersect{1}&&binsof(cov_jls_mid_pwrite)intersect{1};
      ignore_bins hi= binsof(cov_jls_mid_psel)intersect{0}&&binsof(cov_jls_mid_pwrite)intersect{1};
    }
    enablewrite:cross cov_jls_mid_penable,cov_jls_mid_pwrite{
      bins one_zero  = binsof(cov_jls_mid_penable)intersect{1}&&binsof(cov_jls_mid_pwrite)intersect{0};
      bins zero_one  = binsof(cov_jls_mid_penable)intersect{0}&&binsof(cov_jls_mid_pwrite)intersect{1};
      bins zero_zero = binsof(cov_jls_mid_penable)intersect{0}&&binsof(cov_jls_mid_pwrite)intersect{0};
      ignore_bins hi = binsof(cov_jls_mid_penable)intersect{1}&&binsof(cov_jls_mid_pwrite)intersect{1};
    }
   endgroup

   covergroup cg_jls_xclk;
     option.per_instance = 0;
    cov_jls_xclk_psel : coverpoint jls_vif.xclk_psel;
    cov_jls_xclk_penable : coverpoint jls_vif.xclk_penable;
    cov_jls_xclk_pwrite : coverpoint jls_vif.xclk_pwrite;
    selenable:cross cov_jls_xclk_psel,cov_jls_xclk_penable{
      bins one_zero = binsof(cov_jls_xclk_psel)intersect{1}&&binsof(cov_jls_xclk_penable)intersect{0};
      bins one_one  = binsof(cov_jls_xclk_psel)intersect{1}&&binsof(cov_jls_xclk_penable)intersect{1};
      ignore_bins hi= binsof(cov_jls_xclk_psel)intersect{0}&&binsof(cov_jls_xclk_penable)intersect{1};

    }
    selwrite:cross cov_jls_xclk_psel,cov_jls_xclk_pwrite{
      bins one_zero = binsof(cov_jls_xclk_psel)intersect{1}&&binsof(cov_jls_xclk_pwrite)intersect{0};
      bins one_one  = binsof(cov_jls_xclk_psel)intersect{1}&&binsof(cov_jls_xclk_pwrite)intersect{1};
      ignore_bins hi= binsof(cov_jls_xclk_psel)intersect{0}&&binsof(cov_jls_xclk_pwrite)intersect{1};

    }
    enablewrite:cross cov_jls_xclk_penable,cov_jls_xclk_pwrite{
      bins one_zero  = binsof(cov_jls_xclk_penable)intersect{1}&&binsof(cov_jls_xclk_pwrite)intersect{0};
      bins zero_one  = binsof(cov_jls_xclk_penable)intersect{0}&&binsof(cov_jls_xclk_pwrite)intersect{1};
      bins zero_zero = binsof(cov_jls_xclk_penable)intersect{0}&&binsof(cov_jls_xclk_pwrite)intersect{0};
      ignore_bins hi = binsof(cov_jls_xclk_penable)intersect{1}&&binsof(cov_jls_xclk_pwrite)intersect{1};
    }
   endgroup

   covergroup cg_jls_std;
     option.per_instance = 0;
    cov_jls_std_psel : coverpoint jls_vif.std_psel;
    cov_jls_std_penable : coverpoint jls_vif.std_penable;
    cov_jls_std_pwrite : coverpoint jls_vif.std_pwrite;
    selenable:cross cov_jls_std_psel,cov_jls_std_penable{
      bins one_zero = binsof(cov_jls_std_psel)intersect{1}&&binsof(cov_jls_std_penable)intersect{0};
      bins one_one  = binsof(cov_jls_std_psel)intersect{1}&&binsof(cov_jls_std_penable)intersect{1};
      ignore_bins hi= binsof(cov_jls_std_psel)intersect{0}&&binsof(cov_jls_std_penable)intersect{1};

    }
    selwrite:cross cov_jls_std_psel,cov_jls_std_pwrite{
      bins one_zero = binsof(cov_jls_std_psel)intersect{1}&&binsof(cov_jls_std_pwrite)intersect{0};
      bins one_one  = binsof(cov_jls_std_psel)intersect{1}&&binsof(cov_jls_std_pwrite)intersect{1};
      ignore_bins hi= binsof(cov_jls_std_psel)intersect{0}&&binsof(cov_jls_std_pwrite)intersect{1};

    }
    enablewrite:cross cov_jls_std_penable,cov_jls_std_pwrite;

   endgroup



   covergroup cg_work;
     option.per_instance = 0;
    cov_work_psel : coverpoint jls_vif.work_psel;
    cov_work_penable : coverpoint jls_vif.work_penable;
    cov_work_pwrite : coverpoint jls_vif.work_pwrite;
    selenable:cross cov_work_psel,cov_work_penable{
      bins one_zero = binsof(cov_work_psel)intersect{1}&&binsof(cov_work_penable)intersect{0};
      bins one_one  = binsof(cov_work_psel)intersect{1}&&binsof(cov_work_penable)intersect{1};
      ignore_bins hi= binsof(cov_work_psel)intersect{0}&&binsof(cov_work_penable)intersect{1};
    }
    selwrite:cross cov_work_psel,cov_work_pwrite{
      bins one_zero = binsof(cov_work_psel)intersect{1}&&binsof(cov_work_pwrite)intersect{0};
      bins one_one  = binsof(cov_work_psel)intersect{1}&&binsof(cov_work_pwrite)intersect{1};

    }
    enablewrite:cross cov_work_penable,cov_work_pwrite{
      bins one_zero  = binsof(cov_work_penable)intersect{1}&&binsof(cov_work_pwrite)intersect{0};
      bins zero_one  = binsof(cov_work_penable)intersect{0}&&binsof(cov_work_pwrite)intersect{1};
      bins zero_zero = binsof(cov_work_penable)intersect{0}&&binsof(cov_work_pwrite)intersect{0};
      ignore_bins hi = binsof(cov_work_penable)intersect{1}&&binsof(cov_work_pwrite)intersect{1};
    }
   endgroup

   covergroup cg_speed;
     option.per_instance = 0;
    cov_speed_psel : coverpoint jls_vif.speed_psel;
    cov_speed_penable : coverpoint jls_vif.speed_penable;
    cov_speed_pwrite : coverpoint jls_vif.speed_pwrite;
    selenable:cross cov_speed_psel,cov_speed_penable{
      bins one_zero = binsof(cov_speed_psel)intersect{1}&&binsof(cov_speed_penable)intersect{0};
      bins one_one  = binsof(cov_speed_psel)intersect{1}&&binsof(cov_speed_penable)intersect{1};
      ignore_bins hi= binsof(cov_speed_psel)intersect{0}&&binsof(cov_speed_penable)intersect{1};

    }
    selwrite:cross cov_speed_psel,cov_speed_pwrite{
      bins one_zero = binsof(cov_speed_psel)intersect{1}&&binsof(cov_speed_pwrite)intersect{0};
      bins one_one  = binsof(cov_speed_psel)intersect{1}&&binsof(cov_speed_pwrite)intersect{1};

    }
    enablewrite:cross cov_speed_penable,cov_speed_pwrite{
      bins one_zero  = binsof(cov_speed_penable)intersect{1}&&binsof(cov_speed_pwrite)intersect{0};
      bins zero_one  = binsof(cov_speed_penable)intersect{0}&&binsof(cov_speed_pwrite)intersect{1};
      bins zero_zero = binsof(cov_speed_penable)intersect{0}&&binsof(cov_speed_pwrite)intersect{0};
      ignore_bins hi = binsof(cov_speed_penable)intersect{1}&&binsof(cov_speed_pwrite)intersect{1};
    }
   endgroup


   covergroup cg_rirst;
     option.per_instance = 0;
    cov_rst_psel : coverpoint jls_vif.rst_psel;
    cov_rst_penable : coverpoint jls_vif.rst_penable;
    cov_rst_pwrite : coverpoint jls_vif.rst_pwrite;
    selenable:cross cov_rst_psel,cov_rst_penable{
      bins one_zero = binsof(cov_rst_psel)intersect{1}&&binsof(cov_rst_penable)intersect{0};
      bins one_one  = binsof(cov_rst_psel)intersect{1}&&binsof(cov_rst_penable)intersect{1};
      ignore_bins hi= binsof(cov_rst_psel)intersect{0}&&binsof(cov_rst_penable)intersect{1};
    }
    selwrite:cross cov_rst_psel,cov_rst_pwrite{
      bins one_zero = binsof(cov_rst_psel)intersect{1}&&binsof(cov_rst_pwrite)intersect{0};
      bins one_one  = binsof(cov_rst_psel)intersect{1}&&binsof(cov_rst_pwrite)intersect{1};

    }
    enablewrite:cross cov_rst_penable,cov_rst_pwrite{
      bins one_zero  = binsof(cov_rst_penable)intersect{1}&&binsof(cov_rst_pwrite)intersect{0};
      bins zero_one  = binsof(cov_rst_penable)intersect{0}&&binsof(cov_rst_pwrite)intersect{1};
      bins zero_zero = binsof(cov_rst_penable)intersect{0}&&binsof(cov_rst_pwrite)intersect{0};
      ignore_bins hi = binsof(cov_rst_penable)intersect{1}&&binsof(cov_rst_pwrite)intersect{1};
    }
   endgroup


   covergroup cg_cpm;
     option.per_instance = 0;
    cov_cpm_psel : coverpoint jls_vif.cpm_psel;
    cov_cpm_penable : coverpoint jls_vif.cpm_penable;
    cov_cpm_pwrite : coverpoint jls_vif.cpm_pwrite;
    selenable:cross cov_cpm_psel,cov_cpm_penable{
      bins one_zero = binsof(cov_cpm_psel)intersect{1}&&binsof(cov_cpm_penable)intersect{0};
      bins one_one  = binsof(cov_cpm_psel)intersect{1}&&binsof(cov_cpm_penable)intersect{1};
      ignore_bins hi= binsof(cov_cpm_psel)intersect{0}&&binsof(cov_cpm_penable)intersect{1};//

    }
    selwrite:cross cov_cpm_psel,cov_cpm_pwrite{
      bins one_zero = binsof(cov_cpm_psel)intersect{1}&&binsof(cov_cpm_pwrite)intersect{0};
      bins one_one  = binsof(cov_cpm_psel)intersect{1}&&binsof(cov_cpm_pwrite)intersect{1};

    }
    enablewrite:cross cov_cpm_penable,cov_cpm_pwrite{
      bins one_zero  = binsof(cov_cpm_penable)intersect{1}&&binsof(cov_cpm_pwrite)intersect{0};
      bins zero_one  = binsof(cov_cpm_penable)intersect{0}&&binsof(cov_cpm_pwrite)intersect{1};
      bins zero_zero = binsof(cov_cpm_penable)intersect{0}&&binsof(cov_cpm_pwrite)intersect{0};
      ignore_bins hi = binsof(cov_cpm_penable)intersect{1}&&binsof(cov_cpm_pwrite)intersect{1};//
    }
   endgroup


   covergroup cg_pvt;
     option.per_instance = 0;
    cov_pvt_psel : coverpoint jls_vif.pvt_psel;
    cov_pvt_penable : coverpoint jls_vif.pvt_penable;
    cov_pvt_pwrite : coverpoint jls_vif.pvt_pwrite;
    selenable:cross cov_pvt_psel,cov_pvt_penable{
      bins one_zero = binsof(cov_pvt_psel)intersect{1}&&binsof(cov_pvt_penable)intersect{0};
      bins one_one  = binsof(cov_pvt_psel)intersect{1}&&binsof(cov_pvt_penable)intersect{1};
      ignore_bins hi= binsof(cov_pvt_psel)intersect{0}&&binsof(cov_pvt_penable)intersect{1};
    }
    selwrite:cross cov_pvt_psel,cov_pvt_pwrite{
      bins one_zero = binsof(cov_pvt_psel)intersect{1}&&binsof(cov_pvt_pwrite)intersect{0};
      bins one_one  = binsof(cov_pvt_psel)intersect{1}&&binsof(cov_pvt_pwrite)intersect{1};

    }
    enablewrite:cross cov_pvt_penable,cov_pvt_pwrite{
      bins one_zero  = binsof(cov_pvt_penable)intersect{1}&&binsof(cov_pvt_pwrite)intersect{0};
      bins zero_one  = binsof(cov_pvt_penable)intersect{0}&&binsof(cov_pvt_pwrite)intersect{1};
      bins zero_zero = binsof(cov_pvt_penable)intersect{0}&&binsof(cov_pvt_pwrite)intersect{0};
      ignore_bins hi = binsof(cov_pvt_penable)intersect{1}&&binsof(cov_pvt_pwrite)intersect{1};
    }
   endgroup

   covergroup cg_efuse;
     option.per_instance = 0;
    cov_efuse_psel : coverpoint jls_vif.efuse_psel;
    cov_efuse_penable : coverpoint jls_vif.efuse_penable;
    cov_efuse_pwrite : coverpoint jls_vif.efuse_pwrite;
    selenable:cross cov_efuse_psel,cov_efuse_penable{
      bins one_zero = binsof(cov_efuse_psel)intersect{1}&&binsof(cov_efuse_penable)intersect{0};
      bins one_one  = binsof(cov_efuse_psel)intersect{1}&&binsof(cov_efuse_penable)intersect{1};
      ignore_bins hi= binsof(cov_efuse_psel)intersect{0}&&binsof(cov_efuse_penable)intersect{1};

    }
    selwrite:cross cov_efuse_psel,cov_efuse_pwrite{
      bins one_zero = binsof(cov_efuse_psel)intersect{1}&&binsof(cov_efuse_pwrite)intersect{0};
      bins one_one  = binsof(cov_efuse_psel)intersect{1}&&binsof(cov_efuse_pwrite)intersect{1};

    }
    enablewrite:cross cov_efuse_penable,cov_efuse_pwrite{
      bins one_zero  = binsof(cov_efuse_penable)intersect{1}&&binsof(cov_efuse_pwrite)intersect{0};
      bins zero_one  = binsof(cov_efuse_penable)intersect{0}&&binsof(cov_efuse_pwrite)intersect{1};
      bins zero_zero = binsof(cov_efuse_penable)intersect{0}&&binsof(cov_efuse_pwrite)intersect{0};
      ignore_bins hi = binsof(cov_efuse_penable)intersect{1}&&binsof(cov_efuse_pwrite)intersect{1};//
    }
   endgroup

   covergroup cg_lvro;
     option.per_instance = 0;
    cov_lvro_psel : coverpoint jls_vif.lvro_psel;
    cov_lvro_penable : coverpoint jls_vif.lvro_penable;
    cov_lvro_pwrite : coverpoint jls_vif.lvro_pwrite;
    selenable:cross cov_lvro_psel,cov_lvro_penable{
      bins one_zero = binsof(cov_lvro_psel)intersect{1}&&binsof(cov_lvro_penable)intersect{0};
      bins one_one  = binsof(cov_lvro_psel)intersect{1}&&binsof(cov_lvro_penable)intersect{1};
      ignore_bins hi= binsof(cov_lvro_psel)intersect{0}&&binsof(cov_lvro_penable)intersect{1};
    }
    selwrite:cross cov_lvro_psel,cov_lvro_pwrite{
      bins one_zero = binsof(cov_lvro_psel)intersect{1}&&binsof(cov_lvro_pwrite)intersect{0};
      bins one_one  = binsof(cov_lvro_psel)intersect{1}&&binsof(cov_lvro_pwrite)intersect{1};

    }
    enablewrite:cross cov_lvro_penable,cov_lvro_pwrite{
      bins one_zero  = binsof(cov_lvro_penable)intersect{1}&&binsof(cov_lvro_pwrite)intersect{0};
      bins zero_one  = binsof(cov_lvro_penable)intersect{0}&&binsof(cov_lvro_pwrite)intersect{1};
      bins zero_zero = binsof(cov_lvro_penable)intersect{0}&&binsof(cov_lvro_pwrite)intersect{0};
      ignore_bins hi = binsof(cov_lvro_penable)intersect{1}&&binsof(cov_lvro_pwrite)intersect{1};
    }
   endgroup


   covergroup cg_lvro_master;
     option.per_instance = 0;
    cov_lvro_master_psel : coverpoint jls_vif.lvro_master_psel;
    cov_lvro_master_penable : coverpoint jls_vif.lvro_master_penable;
    cov_lvro_master_pwrite : coverpoint jls_vif.lvro_master_pwrite;
    selenable:cross cov_lvro_master_psel,cov_lvro_master_penable{
      bins one_zero = binsof(cov_lvro_master_psel)intersect{1}&&binsof(cov_lvro_master_penable)intersect{0};
      bins one_one  = binsof(cov_lvro_master_psel)intersect{1}&&binsof(cov_lvro_master_penable)intersect{1};
      ignore_bins hi= binsof(cov_lvro_master_psel)intersect{0}&&binsof(cov_lvro_master_penable)intersect{1};
    }
    selwrite:cross cov_lvro_master_psel,cov_lvro_master_pwrite{
      bins one_zero = binsof(cov_lvro_master_psel)intersect{1}&&binsof(cov_lvro_master_pwrite)intersect{0};
      bins one_one  = binsof(cov_lvro_master_psel)intersect{1}&&binsof(cov_lvro_master_pwrite)intersect{1};

    }
    enablewrite:cross cov_lvro_master_penable,cov_lvro_master_pwrite{
      bins one_zero  = binsof(cov_lvro_master_penable)intersect{1}&&binsof(cov_lvro_master_pwrite)intersect{0};
      bins zero_one  = binsof(cov_lvro_master_penable)intersect{0}&&binsof(cov_lvro_master_pwrite)intersect{1};
      bins zero_zero = binsof(cov_lvro_master_penable)intersect{0}&&binsof(cov_lvro_master_pwrite)intersect{0};
      ignore_bins hi = binsof(cov_lvro_master_penable)intersect{1}&&binsof(cov_lvro_master_pwrite)intersect{1};
    }
   endgroup





   covergroup cg_chip_id;
     option.per_instance = 0;
	  cov_chip_id : coverpoint jls_vif.chip_id
				{
					bins chip_id[]   = {[0:1022]};
				}
   endgroup
   
   

   covergroup cg_t_z_ecc2;
     option.per_instance = 0;
	  cov_t_z_ecc2 : coverpoint jls_vif.t_z_ecc2;
   endgroup




  function new(string name, uvm_component parent);
    begin
    super.new(name, parent);
  
    cg_work = new();
    cg_speed = new();
    cg_rirst = new();
    cg_cpm = new();
    cg_pvt = new();
    cg_efuse = new();
    cg_lvro = new();
    cg_lvro_master = new();

    cg_cur_state = new();

    cg_xclk_cur_state = new();
    cg_midclk_cur_state = new();
    cg_chip_id   = new();
    cg_t_z_ecc2  = new();
    cg_jls_mid = new();
    cg_jls_xclk = new();
    cg_jls_std= new();

    mon2cov = new("mon2cov",this);
    end
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual jls_if)::get(this , "" , "jls_vif" ,jls_vif))
      `uvm_fatal(get_full_name(), "Virtual interface handle missing")
  endfunction
  
  function void write(jls_coverage_item t); 
   req_h = t;
   
   cg_work.sample();
   cg_speed.sample();
   cg_rirst.sample();
   cg_cpm.sample();
   cg_pvt.sample();
   cg_efuse.sample();
   cg_lvro.sample();
   cg_lvro_master.sample();
  
   cg_jls_mid.sample();
   cg_jls_xclk.sample();
   cg_jls_std.sample();

   cur_state_t = jls_vif.cur_state;
   xclk_cur_state_t = jls_vif.xclk_apb_state_cur;
   midclk_cur_state = jls_vif.apb_state_cur;
   cg_chip_id.sample();
   cg_t_z_ecc2.sample();
 
  endfunction

endclass

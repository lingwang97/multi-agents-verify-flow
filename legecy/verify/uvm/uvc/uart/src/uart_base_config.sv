class uart_base_cfg extends uvm_object;

   cpm_pkg::cpm_base_cfg   cpm_cfg_h;  
   virtual uart_if vif;

   rand bit [15:0] plldiv_int;
   rand bit [15:0] plldiv_frc;
   rand bit [9:0]  chip_start_id_cfg;
   rand bit        cfg_plls_en; // whether to config 4 plls
   rand bit        cfg_pll0_en; // whether to config  pll0


   // Registration
   /////////////////////////////////////////////////////////
   `uvm_object_utils_begin(uart_base_cfg)
     `uvm_field_int(plldiv_int, UVM_ALL_ON + UVM_HEX)
     `uvm_field_int(plldiv_frc, UVM_ALL_ON + UVM_HEX)
     `uvm_field_int(chip_start_id_cfg, UVM_ALL_ON + UVM_HEX)
     `uvm_field_int(cfg_plls_en, UVM_ALL_ON + UVM_HEX)
     `uvm_field_int(cfg_pll0_en, UVM_ALL_ON + UVM_HEX)
   `uvm_object_utils_end

   ///////////////////////////////////////////////////////
   // Function To "new" The Class
   ///////////////////////////////////////////////////////
   function new(string name="uart_base_cfg");

      super.new(name);

      ///////////////////////////////////////////////////////
      // Assign to actual real variables in post_randomize()
      ///////////////////////////////////////////////////////
       post_randomize();

   endfunction : new

  function void pre_randomize();
      super.pre_randomize();
      if (!uvm_config_db #(cpm_pkg::cpm_base_cfg)::get(uvm_root::get(), get_full_name(), "cpm_cfg", cpm_cfg_h))
      `uvm_error("CPM_CFG:ERROR", "CFG cpm_cfg is missing from config_db") 
      if(!uvm_config_db#(virtual uart_if)::get(uvm_root::get() , get_full_name() , "uart_vif" ,vif))
        `uvm_fatal(get_full_name(), "Virtual interface handle missing")    

      //this.constr_base_uart_plldiv_int.constraint_mode(1);
      this.constr_base_uart_plldiv_frc.constraint_mode(1);
      this.constr_base_uart_chip_start_id.constraint_mode(1);
      this.constr_base_uart_plls_config_en.constraint_mode(1);      
      
      `ifndef PL_SIM
        this.constr_base_uart_plldiv_int_rtlsim.constraint_mode(1);
        this.constr_base_uart_plldiv_int_plsim.constraint_mode(0);
      `else
        this.constr_base_uart_plldiv_int_rtlsim.constraint_mode(0);
        this.constr_base_uart_plldiv_int_plsim.constraint_mode(1);
      `endif
   endfunction : pre_randomize


   /////////////////////////////////////////////////////
   // Function To Run After Randomization
   // Get Real Numbers From Randomized Values
   /////////////////////////////////////////////////////
   function void post_randomize();
      super.post_randomize();
   endfunction : post_randomize

  /////////////////////////////////////
   // Constraints
   /////////////////////////////////////
   constraint constr_base_uart_plldiv_int_rtlsim;
   constraint constr_base_uart_plldiv_int_plsim;
   constraint constr_base_uart_plldiv_frc;
   constraint constr_base_uart_chip_start_id;

   constraint constr_base_uart_plls_config_en;
endclass: uart_base_cfg

constraint uart_base_cfg::constr_base_uart_plls_config_en
  {
  `ifdef STUB_PLL
    cfg_plls_en == 0; 
    cfg_pll0_en == 0; 
  `else
    soft cfg_plls_en == 1; 
    soft cfg_pll0_en == 1; 
  `endif 
  }


constraint uart_base_cfg::constr_base_uart_plldiv_int_rtlsim
  {
//  if(cpm_cfg_h.divmode >= 6) plldiv_int inside {[2:$]};
`ifdef STUB_PLL
    if(vif.fake_pll_freq >= 1000 )
      plldiv_int inside {['d0:'d3]};
    else if(vif.fake_pll_freq < 1000 && vif.fake_pll_freq >= 500)
      plldiv_int inside {['d0:'d2]};
    else if(vif.fake_pll_freq < 500 )
      plldiv_int inside {['d0:'d2]};
`else
    if(cpm_cfg_h.pll0_table <= 'h5)
      // pll_freq inside {'d50, 'd100, 'd150, 'd198, 'd200, 'd300}
      plldiv_int inside {['d0:'d1]} ;
    else if(cpm_cfg_h.pll0_table >= 'h6 && cpm_cfg_h.pll0_table <= 'h13)
      // pll_freq inside {'d324, 348, 372, 396, 400, 420, 444, 480, 504, 600, 696, 792, 888, 1008}
      plldiv_int inside {['d0:'d3]};
    else if (cpm_cfg_h.pll0_table >= 'h14 )
      // pll_freq inside {1104, 1200, 1296, 1392, 1488, 1584, 1600}
      plldiv_int inside {['d0:'d6]};
`endif
  }



constraint uart_base_cfg::constr_base_uart_plldiv_int_plsim
  {
    if(cpm_cfg_h.pll0_table <= 'h5)
      // pll_freq inside {'d50, 'd100, 'd150, 'd198, 'd200, 'd300}
      plldiv_int inside {['d0:'d1]} ;
    else if(cpm_cfg_h.pll0_table >= 'h6 && cpm_cfg_h.pll0_table <= 'h10)
      // pll_freq inside {'d324, 348, 372, 396, 400, 420, 444, 480, 504, 600, 696}
      plldiv_int inside {['d0:'d3]};
    else if (cpm_cfg_h.pll0_table >= 'h11 && cpm_cfg_h.pll0_table <= 'h15)
      // pll_freq inside {792, 888, 1008, 1104, 1200}
      plldiv_int inside {['d3:'d4]};
    else if (cpm_cfg_h.pll0_table >= 'h16 ) 
      // pll_freq inside {1296, 1392, 1488, 1584, 1600}
      plldiv_int inside {['d3:'d6]};
  }


constraint uart_base_cfg::constr_base_uart_plldiv_frc
  {
    // UART_BAUD_RATE = (pll0_freq/2 * frac) /(2**16) / 16 <= pll0_freq / 64 
    `ifdef DIV_FRC_ERR 
      plldiv_frc > (2**15 - 1); 
    `else 
      plldiv_frc inside {['h1000:'h7fff]};
      plldiv_frc <= (2**15 - 1); // <= 'd32767
    `endif
  }

constraint uart_base_cfg::constr_base_uart_chip_start_id
  {
      chip_start_id_cfg inside {[0:1022]};
      soft chip_start_id_cfg  == 0;
  }


class efuse_base_seq extends base_seq;
   virtual efuse_if efuse_vif;
   virtual top_if   top_vif;
   reg [31:0] qqport;
   integer i ,j;
   reg [31:0] tmp;
   int tem;
   logic [31:0] efuse_ctrl;
   `uvm_object_utils(efuse_base_seq)

   //////////////////////////////////////////////////////////////
   // Function Used To "New" The Class
   //////////////////////////////////////////////////////////////
   function new(string name="efuse_base_seq");
      super.new(name);
   endfunction : new

   task pre_body();
     super.pre_body();
     if (!uvm_config_db #(virtual interface efuse_if)::get(m_sequencer, "", "efuse_vif", efuse_vif))
      `uvm_error("RO_VIP:ERROR", "VIF efuse_vif is missing from config_db")

     if (!uvm_config_db #(virtual interface top_if)::get(m_sequencer, "", "top_vif", top_vif))
      `uvm_error("RO_VIP:ERROR", "VIF top_vif is missing from config_db")

   endtask


   task body();
     super.body();
   endtask

endclass


class efuse_xlck_gate_seq extends efuse_base_seq;
   `uvm_object_utils(efuse_xlck_gate_seq)
		reg [31:0] qqport;
		int            count=0;
		logic [31:0]   rd_value;
		
   //////////////////////////////////////////////////////////////
   // Function Used To "New" The Class
   //////////////////////////////////////////////////////////////
   function new(string name="efuse_xlck_gate_seq");
      super.new(name);
   endfunction : new

   task pre_body();
     super.pre_body();

   endtask


   task body();
     super.body();

     `uvm_info(get_type_name(), "efuse_xlck_gate_seq start", UVM_MEDIUM);
	
	 /*		1. initial the rst, pull down the mid_pin_ri  */
		top_vif.chipaddr=10'h00;
      ral.crg.reg_mux.reg_xclk_efuse_en.set(1'b1);
      ral.crg.reg_mux.upd();
		ral.crg.reg_ri_wen.reg_ri_wen.set(1'b1);
		ral.crg.reg_ri_wen.upd();
		ral.crg.reg_ri_enable.reg_ri_function_pre.set(1'b0);
		ral.crg.reg_ri_enable.upd();

    	repeat(20)@(posedge efuse_vif.xclk_gated);
		
    	ral.efuse.reg_efuse_strobe_timer.rd(rd_value);
		if(rd_value!=0) `uvm_error(get_full_name(), $sformatf("read efuse_strobe_timer failed!rd_data=%0d",rd_value));

        `uvm_info(get_type_name(), "begin to set strobe_timer cfg reg" , UVM_LOW)
        ral.efuse.reg_efuse_strobe_timer.set(32'd100);
        ral.efuse.reg_efuse_strobe_timer.upd();
        `PRINT_REG_SETTING(efuse,efuse_strobe_timer); 
		repeat(20)@(posedge efuse_vif.xclk_gated);

        ral.efuse.reg_efuse_strobe_timer.rd(rd_value);
		if(rd_value!=100) `uvm_error(get_full_name(), $sformatf("read efuse_strobe_timer failed!rd_data=%0d",rd_value));
      
      //first
      ral.crg.reg_mux.reg_xclk_efuse_en.set(1'b0);
      ral.crg.reg_mux.upd();   

      repeat(20)@(posedge efuse_vif.xclk);

      fork:check_xclk_gate
         begin
            if(efuse_vif.xclk_gated==1'b0)begin
               @(posedge efuse_vif.xclk_gated);
               `uvm_error(get_type_name,"check gated xclk toggled!!!")
            end
            else begin
               @(negedge efuse_vif.xclk_gated);
               `uvm_error(get_type_name,"check gated xclk toggled!!!")
            end   
         end
         begin
            repeat(100)@(posedge efuse_vif.xclk);
            `uvm_info(get_type_name,"check gated xclk passed!!!",UVM_MEDIUM)
         end
      join_any
      disable check_xclk_gate;

        `uvm_info(get_type_name(), "begin to set strobe_timer cfg reg" , UVM_LOW)
        ral.efuse.reg_efuse_strobe_timer.set(32'd200);
        ral.efuse.reg_efuse_strobe_timer.upd();
        `PRINT_REG_SETTING(efuse,efuse_strobe_timer); 
		repeat(20)@(posedge efuse_vif.xclk);

        ral.efuse.reg_efuse_strobe_timer.rd(rd_value);
		if(rd_value!=100) `uvm_error(get_full_name(), $sformatf("read efuse_strobe_timer failed!rd_data=%0d",rd_value));

      //second

      ral.crg.reg_mux.reg_xclk_efuse_en.set(1'b1);
      ral.crg.reg_mux.upd();   

    	repeat(20)@(posedge efuse_vif.xclk);

      ral.efuse.reg_efuse_strobe_timer.set(32'd1000);
      ral.efuse.reg_efuse_strobe_timer.upd();
      `PRINT_REG_SETTING(efuse,efuse_strobe_timer); 
		repeat(20)@(posedge efuse_vif.xclk);

        ral.efuse.reg_efuse_strobe_timer.rd(rd_value);
		if(rd_value!=1000) `uvm_error(get_full_name(), $sformatf("read efuse_strobe_timer failed!rd_data=%0d",rd_value));

      ral.crg.reg_mux.reg_xclk_efuse_en.set(1'b0);
      ral.crg.reg_mux.upd();   
      repeat(20)@(posedge efuse_vif.xclk);

      fork:check_xclk_gate0
         begin 
            if(efuse_vif.xclk_gated==1'b0)begin
               @(posedge efuse_vif.xclk_gated);
               `uvm_error(get_type_name,"check gated xclk toggled!!!")
            end
            else begin
               @(negedge efuse_vif.xclk_gated);
               `uvm_error(get_type_name,"check gated xclk toggled!!!")
            end   
         end
         begin
            repeat(100)@(posedge efuse_vif.xclk);
            `uvm_info(get_type_name,"check gated xclk passed!!!",UVM_MEDIUM)
         end
      join_any
      disable check_xclk_gate0;

        `uvm_info(get_type_name(), "begin to set strobe_timer cfg reg" , UVM_LOW)
        ral.efuse.reg_efuse_strobe_timer.set(32'd200);
        ral.efuse.reg_efuse_strobe_timer.upd();
        `PRINT_REG_SETTING(efuse,efuse_strobe_timer); 
		repeat(20)@(posedge efuse_vif.xclk);

        ral.efuse.reg_efuse_strobe_timer.rd(rd_value);
		if(rd_value!=1000) `uvm_error(get_full_name(), $sformatf("read efuse_strobe_timer failed!rd_data=%0d",rd_value));



    	`uvm_info(get_type_name(), "efuse_xlck_gate_seq end", UVM_MEDIUM);

   endtask
endclass
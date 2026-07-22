/////////////////////////////////////////////
//
//  using uvm ral sequences
//
////////////////////////////////////////////
class ro_ral_base_seq extends base_seq;
   virtual ro_if 	ro_vif;
   virtual top_if   	top_vif;

   `uvm_object_utils(ro_ral_base_seq)

   //////////////////////////////////////////////////////////////
   // Function Used To "New" The Class
   //////////////////////////////////////////////////////////////
   function new(string name="ro_ral_base_seq");
      super.new(name);

   endfunction : new

   task pre_body();
     super.pre_body();
     if (!uvm_config_db #(virtual interface ro_if)::get(m_sequencer, "", "ro_vif", ro_vif))
      `uvm_error("RO_VIP:ERROR", "VIF ro_vif is missing from config_db")

     if (!uvm_config_db #(virtual interface top_if)::get(m_sequencer, "", "top_vif", top_vif))
      `uvm_error("RO_VIP:ERROR", "VIF top_vif is missing from config_db")
   endtask

   task body();
     super.body();
     
     switch_xclk_to_midclk();
     ro_clk_gate_dis();
   endtask

   //**************ro reg rw delay***********
   virtual task wait_ro_r2r();
	repeat (`RO_R2R_PROD_DLY_MARGIN_CNT) @(posedge ro_vif.ro_clk);
   endtask
   virtual task wait_ro_w2r();
	repeat (`RO_W2R_PROD_DLY_MARGIN_CNT) @(posedge ro_vif.ro_clk);
   endtask
  
   //**************ro reg rw delay***********
   virtual task switch_xclk_to_midclk();
        ral.crg.reg_mux.reg_mid_clk_mux.set(0);
        ral.crg.reg_mux.upd();
        `uvm_info(get_type_name(), "ro test midclk setting: switch to xclk........", UVM_MEDIUM);        
        #100ns;
   endtask


   virtual task ro_clk_gate_dis();
     #1us;
     ral.work.reg_cg_en.reg_ro_cg_en.set(0);
     ral.work.reg_cg_en.upd();
     #1000ns;
     `uvm_info(get_type_name(),$sformatf("ro clk_gate set 1->0..........."),UVM_LOW)     
   endtask

endclass



class ro_ral_lvro_smoke_seq extends ro_ral_base_seq;
   `uvm_object_utils(ro_ral_lvro_smoke_seq)

   uvm_event lv_ro_ev;
   uvm_event lv_ro_period_ev;

   ro_item 	lv_ro_trans;

   integer i;
   integer j;
   integer k;
   bit [31:0] rdata;
   bit [31:0] wdata;

 
   //////////////////////////////////////////////////////////////
   // Function Used To "New" The Class
   //////////////////////////////////////////////////////////////
   function new(string name="ro_ral_lvro_smoke_seq");
      super.new(name);
      lv_ro_trans = ro_item::type_id::create("lv_ro_trans");

   endfunction : new

   task pre_body();
     super.pre_body();

   endtask

   task body();
     super.body();

     `uvm_info(get_type_name(), "ro_ral_lvro_smoke_seq start", UVM_MEDIUM);

     //--------------------------------
     //-----step1.1:initialization
     //--------------------------------

     top_vif.chipaddr=10'h00;
     #1000ns;

     `uvm_info(get_type_name(), "======div_num=1======", UVM_MEDIUM);

     ral.lvro_master.reg_vldctrl.reg_lvro_div_num.set(1);//div_num=1
     ral.lvro_master.reg_vldctrl.upd();   

     #1000ns;
     //rst ro  -----------------------
     ral.lvro_master.reg_vldctrl.reg_lvro_rst_ro_ctrl.set(1);
     ral.lvro_master.reg_vldctrl.upd(); 
     #1000ns;
     ral.lvro_master.reg_vldctrl.reg_lvro_rst_ro_ctrl.set(0);
     ral.lvro_master.reg_vldctrl.upd(); 
     `uvm_info(get_type_name(), "ro vldctrl RST is completed", UVM_MEDIUM);
     //---------------------------------
     #1000ns;
      for(i = 0; i < `RO_NUM; i = i + 1) begin
        for(j = 0; j < `RO_SEL_NUM; j = j + 1) begin

            `ifndef PL_SIM
                //-----Trigger: checker ; send trans data-------
                lv_ro_trans.div_num  		= 1;
                lv_ro_trans.ro_num  		= i;
                lv_ro_trans.ro_sel  		= j;
                lv_ro_period_ev = uvm_event_pool::get_global("lv_ro_period_ev"); 
                lv_ro_period_ev.trigger(lv_ro_trans);
                `uvm_info(get_type_name(),$sformatf("Send triggering the event:period check"),UVM_LOW)
            `endif

            for(k = 0; k<`CORE_RO_NUM; k++) begin
		        wait_ro_r2r();						//ro_r2r delay
                wdata = 0;
                wdata[14:9] = j;                                      	//data.sel = j;
                wdata[8]    = 1;                                      	//data.rst = 1;
                wdata[4:0]   =16;                                      	//data.cnt = 16;
                #1000ns;
                ral.default_map.get_reg_by_offset(`BASE_LVRO_INST+32'h20*i +32'h4*k).write(status,wdata);
                `uvm_info(get_type_name(), "debug: write-----------------------------------", UVM_HIGH);

		        wait_ro_w2r();						//ro_w2r delay
                ral.default_map.get_reg_by_offset(`BASE_LVRO_INST+32'h20*i +32'h4*k).read(status,rdata);
                `uvm_info(get_type_name(), "debug: read-----------------------------------", UVM_HIGH);

                do begin
		            wait_ro_r2r();					//ro_r2r delay
                    ral.default_map.get_reg_by_offset(`BASE_LVRO_INST+32'h20*i +32'h4*k).read(status,rdata);
                end
                while(!(rdata[15]));                                   //ready  bit 15

   	  	        //-----Trigger: checker ; send trans data-------
                lv_ro_trans.div_num  		= 1;
                lv_ro_trans.ro_num  		= i;
                lv_ro_trans.ro_inst  		= k;
                lv_ro_trans.ro_sel  		= j;
                lv_ro_trans.ro_dataout 		= rdata[31:16];
                lv_ro_ev = uvm_event_pool::get_global("lv_ro_ev"); 
                lv_ro_ev.trigger(lv_ro_trans);
                `uvm_info(get_type_name(),$sformatf("Send triggering the event:dataout check"),UVM_LOW)
                `uvm_info(get_type_name(),$sformatf("Send trans, \n %s", lv_ro_trans.sprint()),UVM_LOW)
                #10ns;
            end

        end
      end
     
     #5000ns;

     `uvm_info(get_type_name(), "ro_ral_lvro_smoke_seq end", UVM_MEDIUM);
   endtask

endclass

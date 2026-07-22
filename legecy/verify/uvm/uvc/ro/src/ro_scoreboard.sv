typedef class ro_callback;


`uvm_analysis_imp_decl(_main_ro_monitor)
class ro_scoreboard extends uvm_scoreboard;

   `uvm_component_utils(ro_scoreboard)

   `uvm_register_cb(ro_scoreboard, ro_callback)

   uvm_analysis_imp_main_ro_monitor #(ro_item, ro_scoreboard)  ro_scoreboard_main_ap;

   virtual ro_if vif;
   uvm_event 	lv_ro_ev;
   uvm_event 	lv_ro_period_ev;

   ro_item 	lv_ro_trans;

   real delta_low  = 0.66;
   real delta_high = 0.66;
   //-------For LV RO 
   real LV_RO_Freq_6M 		[`RO_SEL_NUM];
   real LV_RO_Freq_6M_min 	[`RO_SEL_NUM];
   real LV_RO_Freq_6M_max	[`RO_SEL_NUM];

   real LV_RO_Freq_3M 		[`RO_SEL_NUM];
   real LV_RO_Freq_3M_min 	[`RO_SEL_NUM];
   real LV_RO_Freq_3M_max	[`RO_SEL_NUM];

   int  LV_RO_Out_6M_min	[`RO_SEL_NUM];
   int  LV_RO_Out_6M_max	[`RO_SEL_NUM];
   int  LV_RO_period_6M_min	[`RO_SEL_NUM];
   int  LV_RO_period_6M_max	[`RO_SEL_NUM];

   int  LV_RO_Out_3M_min	[`RO_SEL_NUM];
   int  LV_RO_Out_3M_max	[`RO_SEL_NUM];
   int  LV_RO_period_3M_min	[`RO_SEL_NUM];
   int  LV_RO_period_3M_max	[`RO_SEL_NUM];

   function new(string name="ro_scoreboard" , uvm_component parent=null);
     super.new(name , parent);

   endfunction
  
   function void build_phase(uvm_phase phase);
     super.build_phase(phase);
        ro_scoreboard_main_ap = new("ro_scoreboard_main_ap",this);
      if(!uvm_config_db#(virtual ro_if)::get(this , "" , "ro_vif" ,vif))
       `uvm_fatal(get_full_name(), "Virtual interface handle missing") 
  
   endfunction
 
   virtual function void connect_phase(uvm_phase phase);
     super.connect_phase(phase);
   endfunction
 
  //..................... main_phase .................. //
   task main_phase(uvm_phase phase);

     //--------------------------------
     //-----set, calculate ro_out data
     //--------------------------------
     set_ro_data();
     #100;
     `uvm_do_callbacks(ro_scoreboard,ro_callback,set_ro_gold_freq())
     calc_ro_data();

    `ifdef RO_TEST
        fork
          lv_ro_check();
         
        join
    `endif
 
   endtask
 

  //.....................lv ro sub task .................. //
   virtual task lv_ro_check();
   forever
   begin
       integer i;
       integer j;
       integer k;

       `uvm_info(get_full_name(), "Entering ................... lv_ro_check " , UVM_LOW)

       fork

       //`ifndef PL_SIM
       //begin : period_check

       //        lv_ro_period_ev = uvm_event_pool::get_global("lv_ro_period_ev"); 
       //        lv_ro_period_ev.wait_trigger();
       //        `uvm_info(get_type_name(),$sformatf("Get triggering the event:lv_ro_period_ev"),UVM_LOW)
       //        $cast(lv_ro_trans, lv_ro_period_ev.get_trigger_data()); 
       //        i = lv_ro_trans.ro_num;
       //        j = lv_ro_trans.ro_sel;
       //        //check_lv_ro_period(i,j);
       //  
       //end : period_check
       //`endif

       begin : dataout_check
	       lv_ro_ev = uvm_event_pool::get_global("lv_ro_ev"); 
	       lv_ro_ev.wait_trigger();
	       `uvm_info(get_type_name(),$sformatf("Get triggering the event:lv_ro_ev"),UVM_LOW)
	       $cast(lv_ro_trans, lv_ro_ev.get_trigger_data()); 
	       `uvm_info(get_type_name(),$sformatf("Received trans, \n %s",lv_ro_trans.sprint()),UVM_LOW) 
	
	       i = lv_ro_trans.ro_num;
	       j = lv_ro_trans.ro_sel;
	       k = lv_ro_trans.ro_inst;
	
	       if(lv_ro_trans.div_num == 1) begin
	         if((lv_ro_trans.ro_dataout > LV_RO_Out_6M_max[j]) || (lv_ro_trans.ro_dataout < LV_RO_Out_6M_min[j]))begin
	           `uvm_error(get_type_name(), $psprintf("  RO=%d ring=%d v_rd_grp.v_ro_cl.data.dout check fail ro_dataout=%d ro_max:%d ro_min:%d",i, j,lv_ro_trans.ro_dataout, LV_RO_Out_6M_max[j],LV_RO_Out_6M_min[j]));
	           `uvm_info(get_type_name(),$sformatf("\n[Check Result]---------[ xxx Fail xxx ] \n\n"),UVM_LOW) 
	         end
          else begin 
          `uvm_info(get_type_name(),$sformatf("\n[Check Result]---------[ *** Pass ***] \n\n"),UVM_LOW)
           `uvm_info(get_type_name(), $psprintf("  RO=%d ring=%d v_rd_grp.v_ro_cl.data.dout check fail ro_dataout=%d ro_max:%d ro_min:%d",i, j,lv_ro_trans.ro_dataout, LV_RO_Out_6M_max[j],LV_RO_Out_6M_min[j]),UVM_MEDIUM);
          end
	       end
	       if(lv_ro_trans.div_num == 2) begin
	         if((lv_ro_trans.ro_dataout > LV_RO_Out_3M_max[j]) || (lv_ro_trans.ro_dataout < LV_RO_Out_3M_min[j]))begin
	           `uvm_error(get_type_name(), $psprintf("  RO=%d ring=%d v_rd_grp.v_ro_cl.data.dout check fail ro_dataout=%d ro_max:%d ro_min:%d",i, j, lv_ro_trans.ro_dataout,LV_RO_Out_3M_max[j],LV_RO_Out_3M_min[j]));
	           `uvm_info(get_type_name(),$sformatf("\n[Check Result]---------[ xxx Fail xxx ] \n\n"),UVM_LOW) 
	         end
          else begin 
          `uvm_info(get_type_name(),$sformatf("\n[Check Result]---------[ *** Pass ***] \n\n"),UVM_LOW)
          `uvm_info(get_type_name(), $psprintf("  RO=%d ring=%d v_rd_grp.v_ro_cl.data.dout check fail ro_dataout=%d ro_max:%d ro_min:%d",i, j,lv_ro_trans.ro_dataout, LV_RO_Out_6M_max[j],LV_RO_Out_6M_min[j]),UVM_MEDIUM);
          end
	       end
       end : dataout_check


       join
       `uvm_info(get_full_name(), "Exiting .............. lv_ro_check", UVM_LOW)
   end
   endtask : lv_ro_check

   virtual task check_lv_ro_period(int ro_num,int ro_sel);
     realtime time1,time2,period;
     logic[19:0] actual_period;
     if(ro_num == 0) begin
       @(posedge vif.ro0_ro_core0_rdy);
       @(posedge vif.ro0_ro_core0_rosc);
       time1 = $realtime();
       @(posedge vif.ro0_ro_core0_rosc);
       time2 = $realtime();
     end
     else if(ro_num == 1) begin
       @(posedge vif.ro1_ro_core0_rdy);
       @(posedge vif.ro1_ro_core0_rosc);
       time1 = $realtime();
       @(posedge vif.ro1_ro_core0_rosc);
       time2 = $realtime();
     end
     period = time2 - time1;
     actual_period = period*1000;

     if(lv_ro_trans.div_num == 1) begin
        if((actual_period > LV_RO_period_6M_max[ro_sel])||(actual_period < LV_RO_period_6M_min[ro_sel])) begin
          `uvm_error(get_type_name(), $psprintf("ro_sel:%d period check error actual_period:%h min_period:%h max_period:%h",ro_sel,actual_period,LV_RO_period_6M_min[ro_sel],LV_RO_period_6M_max[ro_sel]));

        end
        else begin
          `uvm_info(get_type_name(), $psprintf("ro_sel:%d period check: actual_period:%h min_period:%h max_period:%h",ro_sel,actual_period,LV_RO_period_6M_min[ro_sel],LV_RO_period_6M_max[ro_sel]),UVM_MEDIUM);
        end
     end

     if(lv_ro_trans.div_num == 2) begin
        if((actual_period > LV_RO_period_3M_max[ro_sel])||(actual_period < LV_RO_period_3M_min[ro_sel])) begin
          `uvm_error(get_type_name(), $psprintf("ro_sel:%d period check error actual_period:%h min_period:%h max_period:%h",ro_sel,actual_period,LV_RO_period_3M_min[ro_sel],LV_RO_period_3M_max[ro_sel]));

        end
        else begin
          `uvm_info(get_type_name(), $psprintf("ro_sel:%d period check: actual_period:%h min_period:%h max_period:%h",ro_sel,actual_period,LV_RO_period_3M_min[ro_sel],LV_RO_period_3M_max[ro_sel]),UVM_MEDIUM);
        end
     end
    
  endtask

 
     //--------------------------------
     //-----calculate ro_out data
     //--------------------------------
   virtual task calc_ro_data ();

     //LV RO data
     foreach(LV_RO_Freq_6M_min[i]) LV_RO_Freq_6M_min[i]= LV_RO_Freq_6M[i] - delta_low;
     foreach(LV_RO_Freq_6M_max[i]) LV_RO_Freq_6M_max[i]= LV_RO_Freq_6M[i] + delta_high;  
     foreach(LV_RO_Out_6M_min[i])    LV_RO_Out_6M_min[i]= $rtoi(LV_RO_Freq_6M_min[i] * 16 / 6);
     foreach(LV_RO_Out_6M_max[i])    LV_RO_Out_6M_max[i]= $rtoi(LV_RO_Freq_6M_max[i] * 16 / 6);
     foreach(LV_RO_period_6M_min[i]) LV_RO_period_6M_min[i]= $rtoi( 1000000 / LV_RO_Freq_6M_max[i]);
     foreach(LV_RO_period_6M_max[i]) LV_RO_period_6M_max[i]= $rtoi( 1000000 / LV_RO_Freq_6M_min[i] );

     foreach(LV_RO_Freq_3M_min[i]) LV_RO_Freq_3M_min[i]= LV_RO_Freq_3M[i] - delta_low;
     foreach(LV_RO_Freq_3M_max[i]) LV_RO_Freq_3M_max[i]= LV_RO_Freq_3M[i] + delta_high;  
     foreach(LV_RO_Out_3M_min[i])    LV_RO_Out_3M_min[i]= $rtoi(LV_RO_Freq_3M_min[i] * 16 / 3);
     foreach(LV_RO_Out_3M_max[i])    LV_RO_Out_3M_max[i]= $rtoi(LV_RO_Freq_3M_max[i] * 16 / 3);
     foreach(LV_RO_period_3M_min[i]) LV_RO_period_3M_min[i]= $rtoi( 1000000 / LV_RO_Freq_3M_max[i]);
     foreach(LV_RO_period_3M_max[i]) LV_RO_period_3M_max[i]= $rtoi( 1000000 / LV_RO_Freq_3M_min[i] );
    
     `ifdef RO_TEST
        `uvm_info(get_type_name(), $psprintf("LV_RO_Freq_6M 	debug:%p",LV_RO_Freq_6M),	UVM_MEDIUM);
        `uvm_info(get_type_name(), $psprintf("LV_RO_Freq_6M_min 	debug:%p",LV_RO_Freq_6M_min),	UVM_HIGH);
        `uvm_info(get_type_name(), $psprintf("LV_RO_Freq_6M_max 	debug:%p",LV_RO_Freq_6M_max),	UVM_HIGH);
        `uvm_info(get_type_name(), $psprintf("LV_RO_Out_6M_min 	debug:%p",LV_RO_Out_6M_min),	UVM_HIGH);
        `uvm_info(get_type_name(), $psprintf("LV_RO_Out_6M_max 	debug:%p",LV_RO_Out_6M_max),	UVM_HIGH);
        `uvm_info(get_type_name(), $psprintf("LV_RO_period_6M_min 	debug:%p",LV_RO_period_6M_min),	UVM_HIGH);
        `uvm_info(get_type_name(), $psprintf("LV_RO_period_6M_max 	debug:%p",LV_RO_period_6M_max),	UVM_HIGH);
    
        `uvm_info(get_type_name(), $psprintf("LV_RO_Freq_3M 	debug:%p",LV_RO_Freq_3M),	UVM_MEDIUM);
        `uvm_info(get_type_name(), $psprintf("LV_RO_Freq_3M_min 	debug:%p",LV_RO_Freq_3M_min),	UVM_HIGH);
        `uvm_info(get_type_name(), $psprintf("LV_RO_Freq_3M_max 	debug:%p",LV_RO_Freq_3M_max),	UVM_HIGH);
        `uvm_info(get_type_name(), $psprintf("LV_RO_Out_3M_min 	debug:%p",LV_RO_Out_3M_min),	UVM_HIGH);
        `uvm_info(get_type_name(), $psprintf("LV_RO_Out_3M_max 	debug:%p",LV_RO_Out_3M_max),	UVM_HIGH);
        `uvm_info(get_type_name(), $psprintf("LV_RO_period_3M_min 	debug:%p",LV_RO_period_3M_min),	UVM_HIGH);
        `uvm_info(get_type_name(), $psprintf("LV_RO_period_3M_max 	debug:%p",LV_RO_period_3M_max),	UVM_HIGH);

     `endif
   endtask : calc_ro_data



     //--------------------------------
     //-----set ro_out data
     //--------------------------------
   virtual task set_ro_data ();

     LV_RO_Freq_6M = '{
                    237.375, 297,     104.625,  61.875,  102,      52.5,     104.25,  133.875,
                    44.625,  27,      45.375,   23.25,   59.625,   79.125,   24.375,  14.25,
                    26.625,  13.875,  156.75,   161.625, 125.25,   132.75,   85.875,  87,
                    67.875,  31.125,  31.125,   31.125,  30.75,    30.75,    30.75,   30.75,
                    30.75,   31.125,  31.125,   31.125,  30.375,   30.75,    30.75,   531.75,
                    616.5,   490.875, 519
                };


     LV_RO_Freq_3M = '{
                    237.375, 297,     104.625,  61.875,  102,      52.5,     104.25,  133.875,
                    44.625,  27,      45.375,   23.25,   59.625,   79.125,   24.375,  14.25,
                    26.625,  13.875,  156.75,   161.625, 125.25,   132.75,   85.875,  87,
                    67.875,  31.125,  31.125,   31.125,  30.75,    30.75,    30.75,   30.75,
                    30.75,   31.125,  31.125,   31.125,  30.375,   30.75,    30.75,   531.75,
                    616.5,   490.875, 519
                };

  	`ifdef PL_SIM

		LV_RO_Freq_6M = '{234.375, 330.75,  106.125,  65.625,  108,      56.25,    102,     146.625,
                      44.25,   27.375,  45.75,    23.625,  49.875,   71.625,   21,      12.375,
                      21.75,   11.625,  198.375,  199.875, 147.375,  155.625,  105.375, 106.875,
                      79.125,  31.5,    31.5,     31.5,    31.5,     31.125,   31.125,  31.125,
                      31.5,    31.5,    31.5,     31.5,    31.125,   31.125,   31.125,  567,
                      656.25,  508.125, 536.25};


		LV_RO_Freq_3M = LV_RO_Freq_6M;
	
  
		`ifdef POST_SIM

			`ifdef CORNER_TYP
				LV_RO_Freq_6M = '{232.5,   330.75,  106.125, 66,      108,     56.25,   102,     146.25,
                          44.25,   27.375,  45.375,  23.625,  49.875,  71.625,  21,      12.375,
                          21.75,   11.625,  192,     194.25,  145.875, 152.25,  102.375, 103.875,
                          78.375,  31.5,    31.5,    31.125,  31.5,    31.125,  31.125,  31.125,
                          31.5,    31.5,    31.5,    31.5,    31.125,  31.125,  31.125,  567.75,
                          660,     514.5,   534.75
                      };


				LV_RO_Freq_3M = LV_RO_Freq_6M;

			`endif

			`ifdef CORNER_MAX

					LV_RO_Freq_6M = '{327.000,  457.500,  148.875,  95.625,   150.375,  81.375,   154.125,  218.250,
                            67.500,   42.750,   69.000,   36.750,   79.875,   112.125,  33.000,   20.250,
                            34.875,   18.750,   288.000,  127.125,  94.500,   99.375,   154.125,  69.000,
                            51.375,   32.250,   31.875,   31.500,   31.875,   31.875,   31.500,   31.500,
                            31.875,   31.875,   31.875,   31.875,   31.875,   31.875,   31.875,   835.875,
                            952.125,  735.375,  762.375
                        };

					LV_RO_Freq_3M = LV_RO_Freq_6M;


			`endif

			`ifdef CORNER_MIN

						LV_RO_Freq_6M = '{98.625,  136.875, 43.875,  28.5,    42.75,   21.75,   32.625,  43.875,
                      13.875,  8.25,    13.125,  6.375,   11.625,  18,      4.5,     2.625,
                      4.5,     2.25,    48,      48.75,   36.375,  37.5,    27,      26.625,
                      19.875,  28.5,    28.5,    28.5,    28.5,    28.125,  28.125,  28.125,
                      28.5,    28.875,  28.875,  28.5,    28.5,    28.5,    28.125,  234.75,
                      273,     210,     220.5
                  };

						LV_RO_Freq_3M = LV_RO_Freq_6M;


			`endif


		`endif


  	`endif
  
   endtask : set_ro_data


 

   virtual function void write_main_ro_monitor(ro_item  ro_item_h);
    //  begin
    //   `uvm_info(get_full_name(), $psprintf("ro_scoreboard card_sel =%d", ro_item_h.card_sel), UVM_LOW)
    //  end
   endfunction : write_main_ro_monitor
 
endclass :  ro_scoreboard






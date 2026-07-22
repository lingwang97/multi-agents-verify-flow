class ro_sequence_item extends uvm_sequence_item;

  // used for messaging purposes
  string report_id = "ro_sequence_item";
  //int card_sel;


  //**********************************************************
  //         Using this trans for dff part
  //**********************************************************
  
  rand bit          dff_trig             	;
  rand bit          tst_sel             	;
  rand bit          pattern_inv             	;
  rand bit          setup_hold_check            ;
  rand bit [4:0]    latch_sel             	;
  rand bit [4:0]    dff_sel             	;

  rand bit [2:0]    init_clk_dly                ;
  rand bit [2:0]    chk_clk_dly                 ;
  rand bit [2:0]    cap_data_dly        	;
  rand bit [2:0]    cap_clk_dly                 ;
  rand bit [2:0]    lun_clk_dly                 ;

  rand bit [31:0]   dff_datain             	;
  rand bit [15:0]   gold_data             	;


  // registering the properties of this object
  `uvm_object_utils_begin(ro_sequence_item)

    //`uvm_field_int(card_sel,     		UVM_ALL_ON)  //not use. for coding exmaple

    `uvm_field_int(dff_trig,     		UVM_ALL_ON)
    `uvm_field_int(tst_sel,     		UVM_ALL_ON)
    `uvm_field_int(pattern_inv,     		UVM_ALL_ON)
    `uvm_field_int(setup_hold_check,     	UVM_ALL_ON)
    `uvm_field_int(latch_sel,     		UVM_ALL_ON)
    `uvm_field_int(dff_sel,     		UVM_ALL_ON)

    `uvm_field_int(init_clk_dly,     		UVM_ALL_ON)
    `uvm_field_int(chk_clk_dly,     		UVM_ALL_ON)
    `uvm_field_int(cap_data_dly,     		UVM_ALL_ON)
    `uvm_field_int(cap_clk_dly,     		UVM_ALL_ON)
    `uvm_field_int(lun_clk_dly,     		UVM_ALL_ON)

    `uvm_field_int(dff_datain,     		UVM_ALL_ON)

    `uvm_field_int(gold_data,     		UVM_ALL_ON)

  `uvm_object_utils_end

  // constructor
  function new(string name="ro_sequence_item");
    begin

    super.new(name);

    end
  endfunction : new

  // prints this class properties,
  // used when error is encountered
  virtual function void do_print (uvm_printer printer);
    super.do_print(printer);
    printer.print_object("RO_SEQUENCE_ITEM:", this);
  endfunction

  /////////////////////////////////////
  // Constraints
  /////////////////////////////////////
  constraint constr_dff_number;
  constraint constr_dff_select;
  constraint constr_tst_select;
  constraint constr_gold_data ;



endclass : ro_sequence_item



  constraint ro_sequence_item::constr_dff_number
  { 
     dff_sel inside {[0:11]} ;     
  }                                                                                  

  constraint ro_sequence_item::constr_dff_select
  { 
     if          (dff_sel==0)        { latch_sel==5'b0_0000;      pattern_inv==0;   }
     else if     (dff_sel==1)        { latch_sel==5'b1_0000;      pattern_inv==1;   }
     else if     (dff_sel==2)        { latch_sel==5'b1_0001;      pattern_inv==1;   }
     else if     (dff_sel==3)        { latch_sel==5'b1_0010;      pattern_inv==1;   }
     else if     (dff_sel==4)        { latch_sel==5'b1_0011;      pattern_inv==1;   }
     else if     (dff_sel==5)        { latch_sel==5'b1_0100;      pattern_inv==1;   }
     else if     (dff_sel==6)        { latch_sel==5'b1_0101;      pattern_inv==1;   }
     else if     (dff_sel==7)        { latch_sel==5'b1_0110;      pattern_inv==1;   }
     else if     (dff_sel==8)        { latch_sel==5'b1_0111;      pattern_inv==1;   }
     else if     (dff_sel==9)        { latch_sel==5'b1_1000;      pattern_inv==1;   }
     else if     (dff_sel==10)       { latch_sel==5'b1_1001;      pattern_inv==1;   }
     else if     (dff_sel==11)       { latch_sel==5'b1_1010;      pattern_inv==1;   }
                                                                                           
  }                                                                                  
    
  constraint ro_sequence_item::constr_tst_select
  { 
     dff_sel inside {[0:5]} ->   tst_sel==0;                                                                                      
  }      

  constraint ro_sequence_item::constr_gold_data
  { 
     dff_datain[0]==1  ->   gold_data==dff_datain[31:16];     
     dff_datain[0]==0  ->   gold_data==dff_datain[15:0];                                                                                      
                                                                                 
  }      

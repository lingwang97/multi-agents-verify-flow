class efuse_block_base_seq extends uvm_sequence;

  RAL_PKG::ral_gen_main 		ral;
  virtual efuse_if efuse_vif;

  `uvm_object_utils(efuse_block_base_seq)

  function new(string name = "efuse_block_base_seq");
    super.new(name);
  endfunction


  task pre_body();
    `uvm_info(get_full_name(),"testpath",UVM_MEDIUM)
    if(!uvm_config_db#(RAL_PKG::ral_gen_main)::get(null,"", "ral" ,ral))
           `uvm_error(get_full_name(), "1. Ral handle missing")
    if(!uvm_config_db#(virtual interface efuse_if)::get(null,"","efuse_vif", efuse_vif))
          `uvm_error(get_full_name(), "1. efuse vif handle missing")
    super.pre_body();
  endtask


  task body();
      
  endtask
  
  `include "../../../seq/base_efuse_seq.sv"

endclass

class efuse_access_block_seq extends efuse_block_base_seq;

  logic [31:0]   rd_value;
  		logic [31:0]   dout_q_0;
		logic [31:0]   dout_q_1;
		logic [63:0]   dout_line_data;
		logic		      continuous_save,odd_row_a4;
      logic [1:0]    strobe_ctrl,lword_ctrl;
		logic [63:0]   efuse_pgm_data;
		logic [3:0]    line_addr;
		
  `uvm_object_utils(efuse_access_block_seq)

  function new(string name = "efuse_access_block_seq");
    super.new(name);
  endfunction


  task pre_body();
      super.pre_body();

  endtask

  task body();
     super.body();
      `uvm_info(get_type_name(), "efuse_access_block_seq start", UVM_MEDIUM);
	
      repeat(20)@(posedge efuse_vif.xclk_gated);
		  //  2.setting ctrl reg for pgm prepare
      set_efuse_pgm_prepare();
      //  3.prepate line cfg data
      line_addr=4'd1;
      efuse_pgm_data=64'ha5a5;
      continuous_save=1'b0;


      lword_ctrl  =  2'b00;
      odd_row_a4  =  1'b0;
      efuse_pgm_line(.line_addr(line_addr),.efuse_data(efuse_pgm_data[31:0]), .continuous_save(continuous_save), .lword_ctrl(lword_ctrl),.odd_row_a4(odd_row_a4));    
      odd_row_a4  =  1'b1;
      efuse_pgm_line(.line_addr(line_addr),.efuse_data(efuse_pgm_data[63:32]), .continuous_save(continuous_save), .lword_ctrl(lword_ctrl),.odd_row_a4(odd_row_a4));
      
      //  4.pgm exit
      set_efuse_pgm_exit();
		//  5.setting ctrl reg for read prepare
 
      set_efuse_read_prepare();
      //  5. setting read line data cfg info
        
      efuse_read_line(.line_addr(line_addr),.dout_q_0(dout_q_0),.dout_q_1(dout_q_1),.dout_line_data(dout_line_data));
      set_efuse_read_exit();

      if(dout_q_0!=efuse_pgm_data[31:0])begin
         `uvm_error(get_full_name(), $sformatf("read efuse value failed!line=%0d wr_data =%0h,rd_data=%0h",line_addr,efuse_pgm_data[31:0],dout_q_0));
      end
      if(dout_q_1!=efuse_pgm_data[63:32])begin
         `uvm_error(get_full_name(), $sformatf("read efuse value failed!line=%0d wr_data =%0h,rd_data=%0h",line_addr,efuse_pgm_data[63:32],dout_q_1));
      end


    	`uvm_info(get_type_name(), "efuse_access_block_seq end", UVM_MEDIUM);

  endtask


endclass

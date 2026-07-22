`define XCLK_INT_PERIOD                 41
//for nearest timing setting for wr
`define PGM_TSETUP_PS2PGEN     (`PGM_TSETUP_PS2STROBE -  `PGM_TSETUP_PGEN2STROBE)         //   pegm timing is the same as load
`define PGM_TSETUP_PGEN2RSB    (`PGM_TSETUP_PGEN2STROBE -`PGM_TSETUP_RSB2STROBE)          //   rsb/rwl timing is the same almostly
`define PGM_TSETUP_RSB2TRCS    (`PGM_TSETUP_RSB2STROBE - `PGM_TSETUP_TRCS2STROBE)         //   
`define PGM_TSETUP_TRCS2CS     (`PGM_TSETUP_TRCS2STROBE -`PGM_TSETUP_CS2STROBE)           //   
`define PGM_TSETUP_CS2ADDR     (`PGM_TSETUP_CS2STROBE -  `PGM_TSETUP_ADDR2STROBE)         // 

`define PGM_THOLD_ADDR2TRCS    (`PGM_THOLD_TRCS2STROBE - `PGM_THOLD_ADDR2STROBE)          //   
`define PGM_THOLD_TRCS2RWL     (`PGM_THOLD_RWL2STROBE -  `PGM_THOLD_TRCS2STROBE)          //   rsb/rwl timing is the same almostly
`define PGM_THOLD_RWL2CS       (`PGM_THOLD_CS2STROBE -   `PGM_THOLD_RWL2STROBE)           //   
`define PGM_THOLD_CS2PGEN      (`PGM_THOLD_PGEN2STROBE -  `PGM_THOLD_CS2STROBE)           //   pegm timing is the same as load
`define PGM_THOLD_PGEN2PS      (`PGM_THOLD_PS2STROBE -  `PGM_THOLD_PGEN2STROBE)           //   
`define PGM_THOLD_PS2PD        (`PGM_THOLD_PD2STROBE -  `PGM_THOLD_PS2STROBE)             //   

//for nearest timing setting for rd
`define RD_TSETUP_PD2PS		    (`RD_TSETUP_PD2CS - `RD_TSETUP_PS2CS)
`define RD_TSETUP_PS2LOAD           (`RD_TSETUP_PS2CS - `RD_TSETUP_LOAD2STROBE)         //   pegm timing is the same as load
`define RD_TSETUP_LOAD2RSB          (`RD_TSETUP_LOAD2STROBE - `RD_TSETUP_RSB2STROBE)    //   rsb/rwl timing is the same almostly
`define RD_TSETUP_RSB2MR            (`RD_TSETUP_RSB2STROBE - `RD_TSETUP_MR2STROBE)      //    TRCS is the same as MR almostly
`define RD_TSETUP_MR2CS             (`RD_TSETUP_MR2STROBE - `RD_TSETUP_CS2STROBE)       //   
`define RD_TSETUP_CS2ADDR           (`RD_TSETUP_CS2STROBE - `RD_TSETUP_ADDR2STROBE)     //   

`define RD_THOLD_ADDR2TRCS           (`RD_THOLD_TRCS2STROBE- `RD_THOLD_ADDR2STROBE)     //   
`define RD_THOLD_TRCS2RWL            (`RD_THOLD_RWL2STROBE- `RD_THOLD_TRCS2STROBE)      //    rsb/rwl timing is the same almostly
`define RD_THOLD_RWL2CS              (`RD_THOLD_CS2STROBE- `RD_THOLD_RWL2STROBE)        //  
`define RD_THOLD_CS2MR               (`RD_THOLD_MR2STROBE- `RD_THOLD_CS2STROBE)        //  
`define RD_THOLD_MR2PD               (`RD_THOLD_PD2STROBE- `RD_THOLD_MR2STROBE)         //  
`define RD_THOLD_PD2LOAD             (`RD_THOLD_LOAD2STROBE- `RD_THOLD_PD2STROBE)        //   pegm timing is the same as load
`define RD_THOLD_LOAD2PS             (`RD_THOLD_PS2STROBE- `RD_THOLD_LOAD2STROBE)        //  
  

task set_efuse_pgm_prepare(input pd=0,input ps=1,input csb=0,input mr=0,input pgenb=0,input load=0,input rsb=1,input rwl=0,input trcs=0);
    
        
        `uvm_info(get_type_name(), "begin to set ctrl cfg for efuse propram prepare" , UVM_MEDIUM)
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_pd" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_pd.wr(pd);
        repeat($ceil(`PGM_TSETUP_PD2PS / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_ps" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_ps.wr(ps);

        
        repeat($ceil(`PGM_TSETUP_PS2PGEN / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_load /ip_pgen" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_pgenb.set(pgenb);
        ral.efuse.reg_efuse_ctrl.reg_ip_load.set(load);
        ral.efuse.reg_efuse_ctrl.upd();
        
        repeat($ceil(`PGM_TSETUP_PGEN2RSB / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_rsb /ip_mr" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_rsb.set(rsb);
        ral.efuse.reg_efuse_ctrl.reg_ip_rwl.set(rwl);
        ral.efuse.reg_efuse_ctrl.reg_ip_mr.set(mr);  //FIX ME   mr init value
        ral.efuse.reg_efuse_ctrl.upd();

        repeat($ceil(`PGM_TSETUP_RSB2TRCS / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_trcs" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_trcs.wr(trcs);

        repeat($ceil(`PGM_TSETUP_TRCS2CS / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_csb" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_csb.wr(csb);

        `PRINT_REG_SETTING(efuse,efuse_ctrl);
       repeat($ceil(`PGM_TSETUP_CS2ADDR/ `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);

endtask


task set_efuse_pgm_data(input[9:0] addr=0,input[1:0] addr_test=0,input[31:0] strobe_timer=32'h7a);
    
        
         `uvm_info(get_type_name(), "begin to set ctrl cfg for efuse propram data" , UVM_LOW)
        if($isunknown(addr))begin
            `uvm_error(get_full_name(),"current fuse addr is X state");      
            repeat(1000)@(posedge efuse_vif.xclk);
            $finish();
        end  

        set_strobe_timer(strobe_timer);

        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_addr" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_a.set(addr);
        ral.efuse.reg_efuse_ctrl.reg_ip_at.set(addr_test);
        
        ral.efuse.reg_efuse_ctrl.upd();

        repeat($ceil(`PGM_TSETUP_ADDR2STROBE/ `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_strobe/timer_we" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_strobe_timer_we.set(1'b1);   
        ral.efuse.reg_efuse_ctrl.upd();
        `PRINT_REG_SETTING(efuse,efuse_ctrl);

        `uvm_info(get_type_name(), "begin to rst ctrl cfg for strobe_timer_we" , UVM_MEDIUM)
        if($urandom_range(1,5)==1) ral.efuse.reg_efuse_ctrl.reg_strobe_timer_we.wr(1'b0);

        `ifdef USE_UART_DRV     
                `uvm_info(get_type_name(), "use uart drive,cant wait ip_strobe" , UVM_MEDIUM)
        `elsif USE_JAMLINK_DRV
                `uvm_info(get_type_name(), "use jlm drive,cant wait ip_strobe" , UVM_MEDIUM)
        `else
                @(negedge efuse_vif.ip_STROBE);
        `endif
        repeat($ceil(`PGM_THOLD_ADDR2STROBE/ `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
       

endtask

task  set_strobe_timer(input[31:0] strobe_timer=0);

        `uvm_info(get_type_name(), "begin to set strobe_timer cfg reg" , UVM_LOW)
        ral.efuse.reg_efuse_strobe_timer.set(strobe_timer);
        ral.efuse.reg_efuse_strobe_timer.upd();
        `PRINT_REG_SETTING(efuse,efuse_strobe_timer);
endtask

task set_efuse_pgm_exit(input pd=1,input ps=0,input csb=1,input mr=0,input pgenb=1,input load=0,input rsb=1,input rwl=0,input trcs=0);

        `uvm_info(get_type_name(), "clean we flag before read" , UVM_LOW)
        ral.efuse.reg_efuse_ctrl.reg_strobe_timer_we.wr(1'b0); 

        `uvm_info(get_type_name(), "begin to set ctrl cfg for efuse propram exit" , UVM_LOW)
        repeat($ceil(`PGM_THOLD_ADDR2TRCS / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_trcs" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_trcs.wr(trcs);
        
        repeat($ceil(`PGM_THOLD_TRCS2RWL / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_rsb/mr" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_rsb.set(rsb);
        ral.efuse.reg_efuse_ctrl.reg_ip_rwl.set(rwl);
        ral.efuse.reg_efuse_ctrl.reg_ip_mr.set(mr);  
        ral.efuse.reg_efuse_ctrl.upd();

        repeat($ceil(`PGM_THOLD_RWL2CS / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_csb" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_csb.wr(csb);

        repeat($ceil(`PGM_THOLD_CS2PGEN / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_load/pgen" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_pgenb.set(pgenb);
        ral.efuse.reg_efuse_ctrl.reg_ip_load.set(load);
        ral.efuse.reg_efuse_ctrl.upd();

        repeat($ceil(`PGM_THOLD_PGEN2PS / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_ps" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_ps.wr(ps);

        repeat($ceil(`PGM_THOLD_PS2PD / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_pd" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_pd.wr(pd);

        `PRINT_REG_SETTING(efuse,efuse_ctrl);
   
endtask

task efuse_pgm_line(input[3:0] line_addr=0,input[1:0] addr_test=0,input [63:0] efuse_data=0, input continuous_save=0, input [1:0] lword_ctrl=0,input odd_row_a4=0);
      
        logic[9:0] pgm_addr;
        bit[5:0] addr_quene[$];

        if ((continuous_save==1'b1) && ((lword_ctrl==2'd0)||(lword_ctrl==2'd3))) begin
			//64 bit
                for(int i=0;i<64;i++)begin
                        if (efuse_data[i]==1'b1) begin
                                addr_quene.push_back(i);
                                `uvm_info(get_type_name(), $sformatf("current bit %0d need to be programed",i), UVM_MEDIUM)
                        end
                end
                foreach(addr_quene[i])begin
                        pgm_addr={addr_quene[i],line_addr};
                        `uvm_info(get_type_name(), $sformatf("current line=%0d,address=%0d need to be programed",line_addr,pgm_addr), UVM_MEDIUM)
                        set_efuse_pgm_data(.addr(pgm_addr),.addr_test(addr_test));
                end
			 
        end
        else if((continuous_save==1'b1) && (lword_ctrl==2'd1))begin
            //low-32 bit
                for(int i=0;i<32;i++)begin
                        if (efuse_data[i]==1'b1) begin
                                addr_quene.push_back(i);
                                `uvm_info(get_type_name(), $sformatf("current bit %0d need to be programed",i), UVM_MEDIUM)
                        end
                end
                foreach(addr_quene[i])begin
                        pgm_addr={addr_quene[i],line_addr};
                        `uvm_info(get_type_name(), $sformatf("current line=%0d,address=%0d need to be programed",line_addr,pgm_addr), UVM_MEDIUM)
                        set_efuse_pgm_data(.addr(pgm_addr),.addr_test(addr_test));
                end
        end
        else if((continuous_save==1'b1) && (lword_ctrl==2'd2))begin
            //high-32 bit
                for(int i=0;i<32;i++)begin
                        if (efuse_data[i]==1'b1) begin
                                addr_quene.push_back(i);
                                `uvm_info(get_type_name(), $sformatf("current bit %0d need to be programed",i), UVM_MEDIUM)
                        end
                end
                foreach(addr_quene[i])begin
                        pgm_addr={(addr_quene[i]+6'd32),line_addr};
                        `uvm_info(get_type_name(), $sformatf("current line=%0d,address=%0d need to be programed",line_addr,pgm_addr), UVM_MEDIUM)
                        set_efuse_pgm_data(.addr(pgm_addr),.addr_test(addr_test));
                end
        end
        else if((continuous_save==1'b0) && (odd_row_a4==1'b0))begin
            //A4==0
                for(int i=0;i<32;i++)begin
                        if (efuse_data[i]==1'b1) begin
                                addr_quene.push_back(i);
                                `uvm_info(get_type_name(), $sformatf("current bit %0d need to be programed",i), UVM_MEDIUM)
                        end
                end
                foreach(addr_quene[i])begin
                        pgm_addr={addr_quene[i][4:0],1'b0,line_addr};
                        `uvm_info(get_type_name(), $sformatf("current line=%0d,address=%0d need to be programed",line_addr,pgm_addr), UVM_MEDIUM)
                        set_efuse_pgm_data(.addr(pgm_addr),.addr_test(addr_test));
                end
        end
        else begin
            //A4==1
                for(int i=0;i<32;i++)begin
                        if (efuse_data[i]==1'b1) begin
                                addr_quene.push_back(i);
                                `uvm_info(get_type_name(), $sformatf("current bit %0d need to be programed",i), UVM_MEDIUM)
                        end
                end
                foreach(addr_quene[i])begin
                        pgm_addr={addr_quene[i][4:0],1'b1,line_addr};
                        `uvm_info(get_type_name(), $sformatf("current line=%0d,address=%0d need to be programed",line_addr,pgm_addr), UVM_MEDIUM)
                        set_efuse_pgm_data(.addr(pgm_addr),.addr_test(addr_test));
                end
        end
	addr_quene.delete();
endtask

task efuse_pgm_col(input[1:0] addr_test=0,input [15:0] efuse_data=0);

        logic[9:0] pgm_addr;
        logic[5:0] other_bits;
        bit[3:0] addr_quene[$];

        other_bits= $urandom_range(0,63);
        for(int i=0;i<16;i++)begin
                if (efuse_data[i]==1'b1) begin
                        addr_quene.push_back(i);
                end
        end
        foreach(addr_quene[i])begin
                pgm_addr={other_bits,addr_quene[i]};
                `uvm_info(get_type_name(), $sformatf("current line=%0d need to be programed",addr_quene[i]), UVM_MEDIUM)
                set_efuse_pgm_data(.addr(pgm_addr),.addr_test(addr_test));
        end
	addr_quene.delete();
endtask

task set_efuse_read_prepare(input pd=0,input ps=0,input csb=0,input mr=0,input pgenb=1,input load=1,input rsb=1,input rwl=0,input trcs=0);
	
	`uvm_info(get_type_name(), "begin to set ctrl cfg for efuse reading" , UVM_LOW)
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_pd" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_pd.wr(pd);

        repeat($ceil(`RD_TSETUP_PD2PS / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_ps" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_ps.wr(ps);

        repeat($ceil(`RD_TSETUP_PS2LOAD / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_load/pgen" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_pgenb.set(pgenb);
        ral.efuse.reg_efuse_ctrl.reg_ip_load.set(load);
        ral.efuse.reg_efuse_ctrl.upd();

        repeat($ceil(`RD_TSETUP_LOAD2RSB / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_rsb" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_rsb.set(rsb);
        ral.efuse.reg_efuse_ctrl.reg_ip_rwl.set(rwl);  
        ral.efuse.reg_efuse_ctrl.upd();

        repeat($ceil(`RD_TSETUP_RSB2MR / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_mr/trcs" , UVM_MEDIUM)     
        ral.efuse.reg_efuse_ctrl.reg_ip_mr.set(mr);  
        ral.efuse.reg_efuse_ctrl.reg_ip_trcs.set(trcs);
        ral.efuse.reg_efuse_ctrl.upd();

        repeat($ceil(`RD_TSETUP_MR2CS / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);  
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_csb" , UVM_MEDIUM)     
        ral.efuse.reg_efuse_ctrl.reg_ip_csb.wr(csb);
        `PRINT_REG_SETTING(efuse,efuse_ctrl);

        repeat($ceil(`RD_TSETUP_CS2ADDR/ `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
endtask


task efuse_read_line(input[3:0] line_addr=0,input[1:0] addr_test=0,input mr=0,input[31:0] strobe_timer=32'h6,output [31:0]dout_q_0,output [31:0]dout_q_1,output [63:0]dout_line_data);
    
        logic [9:0] addr;
        logic strobe;
        logic strobe_timer_we;
        logic[3:0] reg_repair_flag;

        `uvm_info(get_type_name(), "begin to set ctrl cfg for efuse reading data " , UVM_LOW)
        
        if(mr==0)
           set_strobe_timer(strobe_timer);
        else
           set_strobe_timer(32'h10);
   
        //dout_Q_0
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_addr" , UVM_MEDIUM)
        addr={5'd0,1'b0,line_addr};
        ral.efuse.reg_efuse_ctrl.reg_ip_a.set(addr);
        ral.efuse.reg_efuse_ctrl.reg_ip_at.set(addr_test);  
        ral.efuse.reg_efuse_ctrl.upd();

        repeat($ceil(`RD_TSETUP_ADDR2STROBE/ `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_strobe/timer_we" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_strobe_timer_we.set(1'b1);   
        ral.efuse.reg_efuse_ctrl.upd();
        `PRINT_REG_SETTING(efuse,efuse_ctrl);

        
        `uvm_info(get_type_name(), "begin to rst ctrl cfg for timer_we" , UVM_MEDIUM)
        if($urandom_range(1,5)==1) ral.efuse.reg_efuse_ctrl.reg_strobe_timer_we.wr(1'b0);

        `ifdef USE_UART_DRV     
        `uvm_info(get_type_name(), "use uart drive,cant wait ip_strobe" , UVM_MEDIUM)
        `elsif USE_JAMLINK_DRV
        `uvm_info(get_type_name(), "use jlm drive,cant wait ip_strobe" , UVM_MEDIUM)
        `else
        @(negedge efuse_vif.ip_STROBE);
        `endif

        ral.efuse.reg_efuse_dout.rd(dout_q_0);
        `uvm_info(get_type_name(), $sformatf("current line address=%0d ,dout_Q_0=%0b",line_addr,dout_q_0), UVM_LOW)

        repeat($ceil(`RD_THOLD_ADDR2STROBE / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);     

        //dout_Q_1
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_addr" , UVM_MEDIUM)
        addr={5'd0,1'b1,line_addr};
        ral.efuse.reg_efuse_ctrl.reg_ip_a.set(addr);
        ral.efuse.reg_efuse_ctrl.reg_ip_at.set(addr_test);
        ral.efuse.reg_efuse_ctrl.upd();
        repeat($ceil(`RD_TSETUP_ADDR2STROBE/ `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);

        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_strobe/timer_we" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_strobe_timer_we.set(1'b1);   
        ral.efuse.reg_efuse_ctrl.upd();
        `PRINT_REG_SETTING(efuse,efuse_ctrl);

      
        `uvm_info(get_type_name(), "begin to rst ctrl cfg for timer_we" , UVM_MEDIUM)
        if($urandom_range(1,5)==1) ral.efuse.reg_efuse_ctrl.reg_strobe_timer_we.wr(1'b0);

        `ifdef USE_UART_DRV     
        `uvm_info(get_type_name(), "use uart drive,cant wait ip_strobe" , UVM_MEDIUM)
        `elsif USE_JAMLINK_DRV
        `uvm_info(get_type_name(), "use jlm drive,cant wait ip_strobe" , UVM_MEDIUM)
        `else
        @(negedge efuse_vif.ip_STROBE);
        `endif

        `uvm_info(get_type_name(), "begin to read efuse ..." , UVM_MEDIUM)
        ral.efuse.reg_efuse_dout.rd(dout_q_1);
        `uvm_info(get_type_name(), $sformatf("current line address=%0d ,dout_Q_1=%0b",line_addr,dout_q_1), UVM_LOW)
                
        repeat($ceil(`RD_THOLD_ADDR2STROBE / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);     
        
        for(int i=0;i<64;i++)begin
            if (i%2==0) begin
                dout_line_data[i]=dout_q_0[(i/2)];
            end
            else begin
                dout_line_data[i]=dout_q_1[(i/2)];
            end
        end
        `uvm_info(get_type_name(), $sformatf("current line address=%0d ,dout_line_data=%0b",line_addr,dout_line_data), UVM_LOW)
endtask


task efuse_read_col(input[1:0] addr_test=0,input mr=0,input[31:0] strobe_timer=32'h6,output [31:0]dout_q_col);
    
        logic [9:0] addr;
        logic strobe;
        logic strobe_timer_we;
        logic [31:0] dout_q_0;

        dout_q_col=16'd0;
        if(addr_test[1]==1'b0)begin
             `uvm_error(get_full_name(),"addr_test ctrl cfg error!!!!!!!!!!!"); 
        end
    
        `uvm_info(get_type_name(), "begin to set ctrl cfg for efuse reading data " , UVM_LOW)       
        set_strobe_timer(strobe_timer);

        for(int line_addr=0;line_addr<16;line_addr++)begin

                `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_addr" , UVM_MEDIUM)
                addr={5'd0,1'b0,line_addr};
                ral.efuse.reg_efuse_ctrl.reg_ip_a.set(addr);
                ral.efuse.reg_efuse_ctrl.reg_ip_at.set(addr_test);
                
                ral.efuse.reg_efuse_ctrl.upd();
                repeat($ceil(`RD_TSETUP_ADDR2STROBE/ `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
                `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_strobe/timer_we" , UVM_MEDIUM)
                ral.efuse.reg_efuse_ctrl.reg_strobe_timer_we.set(1'b1);   
                ral.efuse.reg_efuse_ctrl.upd();
                `PRINT_REG_SETTING(efuse,efuse_ctrl);

                
                `uvm_info(get_type_name(), "begin to rst ctrl cfg for timer_we" , UVM_MEDIUM)
                if($urandom_range(1,5)==1) ral.efuse.reg_efuse_ctrl.reg_strobe_timer_we.wr(1'b0);

                        `ifdef USE_UART_DRV     
                        `uvm_info(get_type_name(), "use uart drive,cant wait ip_strobe" , UVM_MEDIUM)
                `elsif USE_JAMLINK_DRV
                        `uvm_info(get_type_name(), "use jlm drive,cant wait ip_strobe" , UVM_MEDIUM)
                `else
                        @(negedge efuse_vif.ip_STROBE);
                `endif
                
                ral.efuse.reg_efuse_dout.rd(dout_q_0);
                `uvm_info(get_type_name(), $sformatf("current line address=%0d ,dout_Q_0=%0b",line_addr,dout_q_0), UVM_LOW)
        
                repeat($ceil(`RD_THOLD_ADDR2STROBE / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);     
        
                if(addr_test==2'b10)begin
                    dout_q_col[line_addr]=dout_q_0[0];
                end
                else begin
                    dout_q_col[line_addr]=dout_q_0[31];
                end
        end    
        `uvm_info(get_type_name(), $sformatf("current row_dout_data =%0b",dout_q_col), UVM_LOW)
 
endtask



task set_efuse_read_exit(input pd=1,input ps=0,input csb=1,input mr=0,input pgenb=1,input load=0,input rsb=1,input rwl=0,input trcs=0);
    
        `uvm_info(get_type_name(), "clean we flag before read" , UVM_LOW)
        ral.efuse.reg_efuse_ctrl.reg_strobe_timer_we.wr(1'b0); 

        `uvm_info(get_type_name(), "begin to set ctrl cfg for efuse read exit" , UVM_LOW)
        repeat($ceil(`RD_THOLD_ADDR2TRCS / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_trcs" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_trcs.wr(trcs);
        
        repeat($ceil(`RD_THOLD_TRCS2RWL / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_rsb" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_rsb.set(rsb);
        ral.efuse.reg_efuse_ctrl.reg_ip_rwl.set(rwl);
        ral.efuse.reg_efuse_ctrl.upd();

        repeat($ceil(`RD_THOLD_RWL2CS / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_csb" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_csb.wr(csb);

        repeat($ceil(`RD_THOLD_CS2MR / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_mr" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_mr.wr(mr);

        repeat($ceil(`RD_THOLD_MR2PD / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_pd" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_pd.wr(pd);

        repeat($ceil(`RD_THOLD_PD2LOAD / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_load/pgen" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_pgenb.set(pgenb);
        ral.efuse.reg_efuse_ctrl.reg_ip_load.set(load);
        ral.efuse.reg_efuse_ctrl.upd();

        repeat($ceil(`RD_THOLD_LOAD2PS / `XCLK_INT_PERIOD))@(posedge efuse_vif.xclk);
        `uvm_info(get_type_name(), "begin to set ctrl cfg for ip_ps" , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_ps.wr(ps);
        `PRINT_REG_SETTING(efuse,efuse_ctrl);
endtask

task    read_repair_flag(output[3:0] reg_rf);
     
        `uvm_info(get_type_name(), "begin to read RF reg " , UVM_MEDIUM)
        ral.efuse.reg_efuse_ctrl.reg_ip_rf.rd(reg_rf);
        `uvm_info(get_type_name(), $sformatf("read efuse reg_ip_rf value, reg_rf=%0b",reg_rf), UVM_MEDIUM)
       
endtask 
`ifndef MDL_EFUSE

`define EFUSE_PATH  `BTC0.evt_top.u_efuse

assign efuse_pif.xclk						= `BTC0.evt_top.xclk;
assign efuse_pif.xclk_gated				    = `EFUSE_PATH.xclk_g;
assign efuse_pif.pin_ri						= `EFUSE_PATH.pin_ri;
assign efuse_pif.psel						= `EFUSE_PATH.psel;
assign efuse_pif.penable					= `EFUSE_PATH.penable;
assign efuse_pif.pready_in					= `EFUSE_PATH.pready_in;
assign efuse_pif.pwrite						= `EFUSE_PATH.pwrite;
assign efuse_pif.pready_out					= `EFUSE_PATH.pready_out;
assign efuse_pif.prdata						= `EFUSE_PATH.prdata;


assign efuse_pif.ip_Q						= `EFUSE_PATH.REG_ip_Q;
assign efuse_pif.ip_RF						= `EFUSE_PATH.REG_ip_RF;
assign efuse_pif.ip_CSB						= `EFUSE_PATH.REG_ip_CSB;
assign efuse_pif.ip_STROBE					= `EFUSE_PATH.REG_ip_STROBE;
assign efuse_pif.ip_LOAD					= `EFUSE_PATH.REG_ip_LOAD;
assign efuse_pif.ip_PGENB					= `EFUSE_PATH.REG_ip_PGENB;
assign efuse_pif.ip_PS					    = `EFUSE_PATH.REG_ip_PS;
assign efuse_pif.ip_MR						= `EFUSE_PATH.REG_ip_MR;
assign efuse_pif.ip_PD						= `EFUSE_PATH.REG_ip_PD;
assign efuse_pif.ip_RWL						= `EFUSE_PATH.REG_ip_RWL;
assign efuse_pif.ip_RSB						= `EFUSE_PATH.REG_ip_RSB;
assign efuse_pif.ip_A					    = `EFUSE_PATH.REG_ip_A;
assign efuse_pif.ip_AT					    = `EFUSE_PATH.REG_ip_AT;
assign efuse_pif.ip_TRCS					= `EFUSE_PATH.REG_ip_TRCS;

assign efuse_pif.reg_strobe_timer			= `EFUSE_PATH.REG_EFUSE_STROBE_TIMER;
assign efuse_pif.reg_strobe_timer_we	    = `EFUSE_PATH.REG_EFUSE_CTRL[26];


`ifdef EFUSE_INIT_DEPOSIT

initial  begin
    uvm_hdl_force("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_CSB", 1'b1);
    uvm_hdl_force("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_STROBE", 1'b0);
    uvm_hdl_force("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_LOAD", 1'b0);
    uvm_hdl_force("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_PGENB", 1'b1);
    uvm_hdl_force("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_PS", 1'b0);
    uvm_hdl_force("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_MR", 1'b0);
    uvm_hdl_force("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_PD", 1'b1);
    uvm_hdl_force("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_RWL", 1'b0);
    uvm_hdl_force("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_RSB", 1'b1);
    uvm_hdl_force("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_A",  'b0);
    uvm_hdl_force("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_AT", 'b0);
    uvm_hdl_force("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_TRCS",1'b0);
    
    repeat(1)@(posedge efuse_pif.xclk);
    @(negedge efuse_pif.xclk);
    uvm_hdl_release("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_CSB");
    uvm_hdl_release("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_STROBE");
    uvm_hdl_release("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_LOAD");
    uvm_hdl_release("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_PGENB");
    uvm_hdl_release("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_PS");
    uvm_hdl_release("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_MR");
    uvm_hdl_release("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_PD");
    uvm_hdl_release("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_RWL");
    uvm_hdl_release("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_RSB");
    uvm_hdl_release("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_A");
    uvm_hdl_release("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_AT");
    uvm_hdl_release("tb_top.C[0].btnode.btc.evt_top.u_efuse.REG_ip_TRCS");

    //init fuse data 
    //fuse region
    for(int p=0;p<1024;p++)begin
        uvm_hdl_force($sformatf("tb_top.C[0].btnode.btc.evt_top.u_efuse.i_efuse.fuse_data[%0d]",p), 'b0);
    end
    //test region

    for (int i=0; i<2; i++) begin
        for(int p=0;p<32;p++)begin
            uvm_hdl_force($sformatf("tb_top.C[0].btnode.btc.evt_top.u_efuse.i_efuse.test_row[%0d][%0d]",i,p), 'b0);
        end     
    end

    for (int i=0; i<2; i++) begin
        for(int p=0;p<16;p++)begin
            uvm_hdl_force($sformatf("tb_top.C[0].btnode.btc.evt_top.u_efuse.i_efuse.test_column[%0d][%0d]",i,p), 'b0);
        end     
    end

    //redun region
    for(int p=0;p<64;p++)begin
        uvm_hdl_force($sformatf("tb_top.C[0].btnode.btc.evt_top.u_efuse.i_efuse.fb_data[%0d]",p), 'b0);
    end

    repeat(3)@(posedge efuse_pif.xclk);
    @(negedge efuse_pif.xclk);

    for(int p=0;p<1024;p++)begin
        uvm_hdl_release($sformatf("tb_top.C[0].btnode.btc.evt_top.u_efuse.i_efuse.fuse_data[%0d]",p));
    end
    
    for (int i=0; i<2; i++) begin
        for(int p=0;p<32;p++)begin
            uvm_hdl_release($sformatf("tb_top.C[0].btnode.btc.evt_top.u_efuse.i_efuse.test_row[%0d][%0d]",i,p));
        end     
    end

    for (int i=0; i<2; i++) begin
        for(int p=0;p<16;p++)begin
            uvm_hdl_release($sformatf("tb_top.C[0].btnode.btc.evt_top.u_efuse.i_efuse.test_column[%0d][%0d]",i,p));
        end     
    end

    for(int p=0;p<64;p++)begin
        uvm_hdl_release($sformatf("tb_top.C[0].btnode.btc.evt_top.u_efuse.i_efuse.fb_data[%0d]",p));
    end
end

`endif

`else 
//for block envs
    `define EFUSE_PATH  tb_top.efuse_inst  

    assign efuse_pif.ip_Q						= `EFUSE_PATH.REG_ip_Q;
    assign efuse_pif.ip_RF						= `EFUSE_PATH.REG_ip_RF;
    assign efuse_pif.ip_CSB						= `EFUSE_PATH.REG_ip_CSB;
    assign efuse_pif.ip_STROBE					= `EFUSE_PATH.REG_ip_STROBE;
    assign efuse_pif.ip_LOAD					= `EFUSE_PATH.REG_ip_LOAD;
    assign efuse_pif.ip_PGENB					= `EFUSE_PATH.REG_ip_PGENB;
    assign efuse_pif.ip_PS					    = `EFUSE_PATH.REG_ip_PS;
    assign efuse_pif.ip_MR						= `EFUSE_PATH.REG_ip_MR;
    assign efuse_pif.ip_PD						= `EFUSE_PATH.REG_ip_PD;
    assign efuse_pif.ip_RWL						= `EFUSE_PATH.REG_ip_RWL;
    assign efuse_pif.ip_RSB						= `EFUSE_PATH.REG_ip_RSB;
    assign efuse_pif.ip_A					    = `EFUSE_PATH.REG_ip_A;
    assign efuse_pif.ip_AT					    = `EFUSE_PATH.REG_ip_AT;
    assign efuse_pif.ip_TRCS					= `EFUSE_PATH.REG_ip_TRCS;

    assign efuse_pif.reg_strobe_timer			= `EFUSE_PATH.REG_EFUSE_STROBE_TIMER;
    assign efuse_pif.reg_strobe_timer_we	    = `EFUSE_PATH.REG_EFUSE_CTRL[26];

    initial  begin
        uvm_hdl_force("tb_top.efuse_inst.REG_ip_CSB", 1'b1);
        uvm_hdl_force("tb_top.efuse_inst.REG_ip_STROBE", 1'b0);
        uvm_hdl_force("tb_top.efuse_inst.REG_ip_LOAD", 1'b0);
        uvm_hdl_force("tb_top.efuse_inst.REG_ip_PGENB", 1'b1);
        uvm_hdl_force("tb_top.efuse_inst.REG_ip_PS", 1'b0);
        uvm_hdl_force("tb_top.efuse_inst.REG_ip_MR", 1'b0);
        uvm_hdl_force("tb_top.efuse_inst.REG_ip_PD", 1'b1);
        uvm_hdl_force("tb_top.efuse_inst.REG_ip_RWL", 1'b0);
        uvm_hdl_force("tb_top.efuse_inst.REG_ip_RSB", 1'b1);
        uvm_hdl_force("tb_top.efuse_inst.REG_ip_A",  'b0);
        uvm_hdl_force("tb_top.efuse_inst.REG_ip_AT", 'b0);
        uvm_hdl_force("tb_top.efuse_inst.REG_ip_TRCS",1'b0);
        
        repeat(1)@(posedge efuse_pif.xclk);
        @(negedge efuse_pif.xclk);
        uvm_hdl_release("tb_top.efuse_inst.REG_ip_CSB");
        uvm_hdl_release("tb_top.efuse_inst.REG_ip_STROBE");
        uvm_hdl_release("tb_top.efuse_inst.REG_ip_LOAD");
        uvm_hdl_release("tb_top.efuse_inst.REG_ip_PGENB");
        uvm_hdl_release("tb_top.efuse_inst.REG_ip_PS");
        uvm_hdl_release("tb_top.efuse_inst.REG_ip_MR");
        uvm_hdl_release("tb_top.efuse_inst.REG_ip_PD");
        uvm_hdl_release("tb_top.efuse_inst.REG_ip_RWL");
        uvm_hdl_release("tb_top.efuse_inst.REG_ip_RSB");
        uvm_hdl_release("tb_top.efuse_inst.REG_ip_A");
        uvm_hdl_release("tb_top.efuse_inst.REG_ip_AT");
        uvm_hdl_release("tb_top.efuse_inst.REG_ip_TRCS");

        //init fuse data 
        //fuse region
        for(int p=0;p<1024;p++)begin
            uvm_hdl_force($sformatf("tb_top.efuse_inst.i_efuse.fuse_data[%0d]",p), 'b0);
        end
        //test region

        for (int i=0; i<2; i++) begin
            for(int p=0;p<32;p++)begin
                uvm_hdl_force($sformatf("tb_top.efuse_inst.i_efuse.test_row[%0d][%0d]",i,p), 'b0);
            end     
        end

        for (int i=0; i<2; i++) begin
            for(int p=0;p<16;p++)begin
                uvm_hdl_force($sformatf("tb_top.efuse_inst.i_efuse.test_column[%0d][%0d]",i,p), 'b0);
            end     
        end

        //redun region
        for(int p=0;p<64;p++)begin
            uvm_hdl_force($sformatf("tb_top.efuse_inst.i_efuse.fb_data[%0d]",p), 'b0);
        end

        repeat(3)@(posedge efuse_pif.xclk);
        @(negedge efuse_pif.xclk);

        for(int p=0;p<1024;p++)begin
            uvm_hdl_release($sformatf("tb_top.efuse_inst.i_efuse.fuse_data[%0d]",p));
        end
        
        for (int i=0; i<2; i++) begin
            for(int p=0;p<32;p++)begin
                uvm_hdl_release($sformatf("tb_top.efuse_inst.i_efuse.test_row[%0d][%0d]",i,p));
            end     
        end

        for (int i=0; i<2; i++) begin
            for(int p=0;p<16;p++)begin
                uvm_hdl_release($sformatf("tb_top.efuse_inst.i_efuse.test_column[%0d][%0d]",i,p));
            end     
        end

        for(int p=0;p<64;p++)begin
            uvm_hdl_release($sformatf("tb_top.efuse_inst.i_efuse.fb_data[%0d]",p));
        end
    end

`endif   
   
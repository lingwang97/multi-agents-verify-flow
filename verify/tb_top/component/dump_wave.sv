//==============================================
//======     Setting dump waveform     =========
//==============================================

`ifdef DUMP_VPD
    initial begin
        $display("\n[NOTE]\tStart Dump VPD at%t\n", $time);
        $vcdplusfile("novas.vpd");
        $vcdpluson(12, `TB_TOP);
    end
`endif


`ifdef DUMP_FSDB
    initial begin
        $display("\n[NOTE]\tStart Dump FSDB at%t\n", $time);
        $fsdbDumpfile("novas.fsdb");
        $fsdbDumpMDA;
        
        `ifdef UPF
            $fsdbDumpvars("+power");
        `endif

        $fsdbDumpvars(12,"+all",`TB_TOP);
        $fsdbDumpon;
    end
`endif


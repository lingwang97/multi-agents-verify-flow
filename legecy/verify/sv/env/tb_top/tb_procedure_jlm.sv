
task setm_io_ro_high();
    RO = 1'b1;
endtask

task setm_io_ro_low();
    RO = 1'b0;
endtask

initial begin
    forever @(RO) begin
        $display( $time, " JLM_RO changed into %1d", RO);
    end
end

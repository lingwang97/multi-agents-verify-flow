interface gls_dff_yx_check_if(input Y,input out_temp,input rst_n);
  import uvm_pkg::*;

  always@(Y iff rst_n===1'b1) begin
    if(Y==='x && (out_temp===1'b1 || out_temp===1'b0)) begin
      `uvm_error("gls_dff_yx_check_if",$sformatf("DFF_YX_CHECK_ERROR Y=%0b,out_temp=%0b",Y,out_temp));
    end
  end

endinterface


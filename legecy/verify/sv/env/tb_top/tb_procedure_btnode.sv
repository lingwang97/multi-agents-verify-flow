function bit chkn_mod(input int p_chipindex, input int unsigned p_mode);
    return (({1'b0,p_chipindex+1} % p_mode) === 0);
endfunction

function bit chkn_last(input int p_chipindex);
    return (p_chipindex === `CHIP_NUM-1);
endfunction

function int getn_sel(input int p_chipindex);
    return chkn_mod(p_chipindex, `TB_BTMATRIX_ROW_WIDTH) && !chkn_last(p_chipindex);
endfunction

function int getn_fb_sel(input int p_chipindex);
    if(p_chipindex == 0)
      return 0;
    else
      return chkn_mod((p_chipindex-1), `TB_BTMATRIX_ROW_WIDTH) && !chkn_last(p_chipindex);
endfunction

function logic getn_io_value(input logic p_io_01, input logic p_io_10, input logic p_dsel);
    logic v_dsel_result;
    logic v_result;
    v_dsel_result = (p_dsel? p_io_01 : p_io_10);
    v_result = v_dsel_result;
    return v_result;
endfunction


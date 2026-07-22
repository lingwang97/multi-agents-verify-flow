`ifndef UART_ERR_DETECT
`define UART_ERR_DETECT
 function bit [7:0] get_crc(input bit [31:0] data_in );
      bit   [7:0]   chkpre =  0;
      parameter DATA_WIDTH = 32; 
      parameter POLY_WIDTH = 8; 
      bit   [DATA_WIDTH + POLY_WIDTH - 1 :0]  tmp_data;
      bit   [POLY_WIDTH - 1:0]   poly = 'b1_1101_0101 ;   //x8+x7+x6+x4+x2+1, CRC-8
      bit   [7:0]   crc_data ;
      int unsigned i;
      bit   [DATA_WIDTH + POLY_WIDTH - 1 :0]  mask;

      tmp_data = (data_in << 8);
      for (i = (DATA_WIDTH + POLY_WIDTH - 1); i>= 8; i--)begin
        mask = 32'hffff_ffff;
        if (!tmp_data[i]) 
          continue;
        else begin
          crc_data = (tmp_data[i-:9] ^ poly);
          mask >>= (DATA_WIDTH + POLY_WIDTH - i);
          tmp_data = (crc_data << (i-8)) + (tmp_data & mask);
          //`uvm_info(get_type_name(), $sformatf("mask is 'b%b", mask), UVM_MEDIUM)
          //`uvm_info(get_type_name(), $sformatf("i is 'd%0d", i), UVM_MEDIUM)
          //`uvm_info(get_type_name(), $sformatf("tmp_data is %b", tmp_data), UVM_MEDIUM)
          //`uvm_info(get_type_name(), $sformatf("tmp_data[i-:9] is %b", tmp_data[i-:9]), UVM_MEDIUM)
          //`uvm_info(get_type_name(), $sformatf("crc_data is %b", crc_data), UVM_MEDIUM)
        end
      end
      crc_data = tmp_data[7:0];

      return crc_data;
  endfunction:get_crc



  function bit [7:0] get_ecc(input bit [31:0] data_in );
      logic [15:0] data_tmp0; 
      logic [15:0] data_tmp1; 
      logic [15:0] data_tmp2; 
      logic [15:0] data_tmp3; 
      logic [15:0] data_tmp4; 
      logic [15:0] data_tmp5; 
      logic [15:0] data_tmp6; 
      data_tmp0 = ({data_in[31],
                   data_in[29], data_in[28], data_in[26], data_in[21],
                   data_in[19], data_in[18], data_in[17], data_in[14],
                   data_in[11], data_in[9], data_in[8], data_in[7],
                   data_in[6], data_in[4], data_in[0]
                   });
      data_tmp1 = ({data_in[28],
                   data_in[26], data_in[24], data_in[22], data_in[20],
                   data_in[18], data_in[17], data_in[16], data_in[12],
                   data_in[10], data_in[8], data_in[6], data_in[4],
                   data_in[2], data_in[1], data_in[0]
                   });

      data_tmp2 = ({data_in[31],
                   data_in[29], data_in[26], data_in[25], data_in[23],
                   data_in[20], data_in[19], data_in[16], data_in[15],
                   data_in[13], data_in[10], data_in[9], data_in[7],
                   data_in[4], data_in[3], ~data_in[0] 
                   });
      data_tmp3= ({data_in[29],
                  data_in[28], data_in[27], data_in[23], data_in[22],
                  data_in[21], data_in[17], data_in[16], data_in[13],
                  data_in[12], data_in[11], data_in[7], data_in[6],
                  data_in[5], data_in[1], ~data_in[0]
                   });
      data_tmp4= ({data_in[31],
                  data_in[30], data_in[23], data_in[22], data_in[21],
                  data_in[20], data_in[19], data_in[18], data_in[15],
                  data_in[14], data_in[7], data_in[6], data_in[5],
                  data_in[4], data_in[3], data_in[2]
                   });
      data_tmp5= ({data_in[31],
                  data_in[30], data_in[29], data_in[28], data_in[27],
                  data_in[26], data_in[25], data_in[24], data_in[15],
                  data_in[14], data_in[13], data_in[12], data_in[11],
                  data_in[10], data_in[9], data_in[8]
                   });
      data_tmp6= ({data_in[31], data_in[30], data_in[29], data_in[28], data_in[27],
                  data_in[26], data_in[25], data_in[24], data_in[7],
                  data_in[6], data_in[5], data_in[4], data_in[3],
                  data_in[2], data_in[1], data_in[0]
                   });
      get_ecc[0]  = dw04_par_gen(data_tmp0);
      get_ecc[1]  = dw04_par_gen(data_tmp1);
      get_ecc[2]  = dw04_par_gen(data_tmp2);
      get_ecc[3]  = dw04_par_gen(data_tmp3);
      get_ecc[4]  = dw04_par_gen(data_tmp4);
      get_ecc[5]  = dw04_par_gen(data_tmp5);
      get_ecc[6]  = dw04_par_gen(data_tmp6);
      get_ecc[7]  = 0;
  endfunction:get_ecc

  function bit dw04_par_gen(input logic [15:0] datain);
    dw04_par_gen = ^datain;
  endfunction:dw04_par_gen



`endif    //`ifndef UART_ERR_DETECT
    

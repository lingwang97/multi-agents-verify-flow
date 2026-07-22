`ifndef _UVM_REG_MACROS_SVH_
`define _UVM_REG_MACROS_SVH_

`define ON                  1
`define OFF                 0
`define HIGH                1
`define LOW                 0
`define W1C                 1
`define W1T                 1
`define WRITE               0
`define READ                1
`define FT_EN               1
`define FT_DIS              0
`define SPD_LEVEL0          0
`define SPD_LEVEL1          1
`define SPD_LEVEL2          2
`define SPD_LEVEL3          3
`define SPD_LEVEL4          4
`define BROADCAST           8'hFF
`define NONCEBUF_LEN        8
`define WORK_NUM            23
`define VERSION_NUM         `ABS_NUM
`define NONCEBUF_NUM        24
`define SELFCLK_CLK_SPD     8'b00000001
`define SELFCLK_HS_RO       8'b00000010
`define SELFCLK_RO_PLL      8'b00000011
`define SELFCLK_BROADCAST   4'h8
`define FT_BITMAP_NUM       8
`define SELFCLK_DIVIDEND    24'h7fffff
`define SELFCLK_CAL_PARA    $pow(2,10)
`define LOWEST_SELFCLK_FREQ (selfclk_cfg_h.lt_table[0]*1000)

//top level register access macro defines
`define WR_REG(module,reg,value) ral.``module``.reg_``reg``.wr(value)
`define GET_REG(module,reg) ral.``module``.reg_``reg``.get()
`define SET_REG(module,reg,value) ral.``module``.reg_``reg``.set(value)
`define SET_REG_FIELD(module,reg,field,value) ral.``module``.reg_``reg``.reg_``field``.set(value)
`define UPDATE_REG(module,reg)    ral.``module``.reg_``reg``.upd()
`define UPDATE_REG_BKDR(module,reg)    ral.``module``.reg_``reg``.update(status, UVM_BACKDOOR )
`define RD_REG(module,reg,value) ral.``module``.reg_``reg``.rd(value)
`define GET_REG_FIELD(module,reg,field) ral.``module``.reg_``reg``.reg_``field``.get_mirrored_value()
`define MIR_REG(module,reg)          ral.``module``.reg_``reg``.mir()
`define MIR_REG_BKDR(module, reg)     ral.``module``.reg_``reg``.mirror(status, UVM_NO_CHECK, UVM_BACKDOOR )
`define PRINT_REG_SETTING(module,reg) `uvm_info("REG CONFIG INFO",$psprintf("set ``module``.``reg``:(0x%0x)  0x%0x",ral.``module``.reg_``reg``.get_offset(), ral.``module``.reg_``reg``.get()),UVM_MEDIUM)

//MACRO MIR_REG&MIR_REG_BKDR is in order to update ral mirror value

//core register access macro defines
`define SET_CORE_REG_FIELD(reg,field,value) ral.mx2.reg_``reg``.``field``.set(value)
`define GET_CORE_REG_FIELD(reg,field) ral.mx2.reg_``reg``.``field``.get_mirrored_value()
`define GET_CORE_REG(reg) ral.mx2.reg_``reg``.get()
`define WR_CORE_REG(reg, coreid, value)  core_wr(ral.mx2.reg_``reg``, coreid, value);
`define RD_CORE_REG(reg, coreid, value)  core_rd(ral.mx2.reg_``reg``, coreid, value);
`define GET_CORE_REG_ADDR(reg)  ral.mx2.reg_``reg``.get_offset()

`endif

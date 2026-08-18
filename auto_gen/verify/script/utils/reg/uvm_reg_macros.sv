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


//register access macro defines
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

`endif


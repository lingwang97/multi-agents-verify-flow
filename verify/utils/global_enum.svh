`ifndef _GLOBAL_ENUM_SVH_
`define _GLOBAL_ENUM_SVH_


typedef enum {OFF,ON}     on_off_t;
  
  typedef enum {
    UNDETERMINE   ,
    DETERMINE_ODD ,
    DETERMINE_EVEN
  } seed_mode_t;

typedef enum {FT_NONE,FT_INIT,FT_PLL,FT_CFG,FT_RUN} e_dump_cpft;
//typedef enum { T_MODE, V_MODE,TV_MODE} e_tv_mode;
typedef enum { T_MODE, V_MODE,TV_MODE} tv_mode;


// -------------------------------------------------
// UART cmd pattern
// -------------------------------------------------
typedef struct packed{  
  bit [ 7:0] tranlen        ;
  bit [11:0] addr       ;   
  //bit        rfu        ;   
  //bit       nonce_empt ;   
  bit [1:0] mode       ;   
  bit [9:0] chipaddr    ;   
  } UART_CMD;

`endif   //`ifndef _GLOBAL_ENUM_SVH_


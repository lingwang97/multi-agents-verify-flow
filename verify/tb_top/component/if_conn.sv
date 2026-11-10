//==============================================
//====== Manage each module's if_conn  =========
//==============================================

module if_conn;

    import uvm_pkg::*;

    //Other initial cfg


    `ifndef GPL_SIM

		`include "top_if_conn.sv"
		`include "reg_if_conn.sv"
		`include "apb_master_if_conn.sv"
		`include "ro_if_conn.sv"
		`include "uart_if_conn.sv"
		`include "efuse_if_conn.sv"

    `else

		`include "top_if_conn_gpls.sv"
		`include "reg_if_conn_gpls.sv"
		`include "apb_master_if_conn_gpls.sv"
		`include "ro_if_conn_gpls.sv"
		`include "uart_if_conn_gpls.sv"
		`include "efuse_if_conn_gpls.sv"


    `endif

    // Other if connection 

endmodule


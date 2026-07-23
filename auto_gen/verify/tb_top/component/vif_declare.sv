//========================================
//==   instance all module interface    ==
//==   vitual if declaration            ==
//========================================
top_if	top_pif();
reg_if	reg_pif();
jls_if	jls_pif();
cpft_if	cpft_pif();
uart_if	uart_pif();
efuse_if	efuse_pif();
// Other Interface Instances

virtual	top_if	top_vif;
virtual	reg_if	reg_vif;
virtual	jls_if	jls_vif;
virtual	cpft_if	cpft_vif;
virtual	uart_if	uart_vif;
virtual	efuse_if	efuse_vif;
// Other Vitual Interface Declare 

initial	top_vif = top_pif;
initial	reg_vif = reg_pif;
initial	jls_vif = jls_pif;
initial	cpft_vif = cpft_pif;
initial	uart_vif = uart_pif;
initial	efuse_vif = efuse_pif;
// Other Vitual Interface Initialization 

// TB Top set inteface
initial begin
	uvm_config_db#(virtual interface top_if)::set(null,"*", "top_vif",top_vif);
	uvm_config_db#(virtual interface reg_if)::set(null,"*", "reg_vif",reg_vif);
	uvm_config_db#(virtual interface jls_if)::set(null,"*", "jls_vif",jls_vif);
	uvm_config_db#(virtual interface cpft_if)::set(null,"*", "cpft_vif",cpft_vif);
	uvm_config_db#(virtual interface uart_if)::set(null,"*", "uart_vif",uart_vif);
	uvm_config_db#(virtual interface efuse_if)::set(null,"*", "efuse_vif",efuse_vif);
    //Other Vitual Interface Setting 

end


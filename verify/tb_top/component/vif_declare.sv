//========================================
//==   instance all module interface    ==
//==   vitual if declaration            ==
//========================================
top_if	top_pif();
reg_if	reg_pif();
apb_master_if	apb_master_pif();
ro_if	ro_pif();
uart_if	uart_pif();
efuse_if	efuse_pif();
// Other Interface Instances

virtual	top_if	top_vif;
virtual	reg_if	reg_vif;
virtual	apb_master_if	apb_master_vif;
virtual	ro_if	ro_vif;
virtual	uart_if	uart_vif;
virtual	efuse_if	efuse_vif;
// Other Vitual Interface Declare 

// Vif assignment and config_db set run in one initial block: the handles must
// be assigned before they are published, independent of initial-block order.
initial begin
	top_vif = top_pif;
	reg_vif = reg_pif;
	apb_master_vif = apb_master_pif;
	ro_vif = ro_pif;
	uart_vif = uart_pif;
	efuse_vif = efuse_pif;
	// Other Vitual Interface Initialization

	// TB Top set inteface
	uvm_config_db#(virtual interface top_if)::set(null,"*", "top_vif",top_vif);
	uvm_config_db#(virtual interface reg_if)::set(null,"*", "reg_vif",reg_vif);
	uvm_config_db#(virtual interface apb_master_if)::set(null,"*", "apb_master_vif",apb_master_vif);
	uvm_config_db#(virtual interface ro_if)::set(null,"*", "ro_vif",ro_vif);
	uvm_config_db#(virtual interface uart_if)::set(null,"*", "uart_vif",uart_vif);
	uvm_config_db#(virtual interface efuse_if)::set(null,"*", "efuse_vif",efuse_vif);
    //Other Vitual Interface Setting

end


class uvm_btc_block extends uvm_reg_block;
	//`uvm_object_utils(efuse_type)

	function new(string name="uvm_btc_block", int has_coverage);
		super.new(name, has_coverage);
	endfunction : new

	virtual task mir(input uvm_check_e check = UVM_NO_CHECK);
		uvm_status_e       status;	
		this.mirror(status, check, UVM_FRONTDOOR);
		//in order to update ral mirror value
	endtask


	virtual task upd();
		uvm_status_e       status;	
		this.update(status, UVM_FRONTDOOR);
	endtask

endclass : uvm_btc_block


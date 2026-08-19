
class uvm_btc_reg extends uvm_reg;
	//`uvm_object_utils(uvm_btc_reg)


	function new(string name="uvm_btc_reg", int unsigned n_bits, int has_coverage);
		super.new(name, n_bits, has_coverage);
		//super.new(name);
	endfunction : new
	//`uvm_object_utils(uvm_btc_reg)

	virtual task wr(input uvm_reg_data_t value);
		uvm_status_e       status;
		this.write(status, value, UVM_FRONTDOOR);
	endtask

	virtual task rd(output uvm_reg_data_t value);
		uvm_status_e       status;	
		this.read(status, value, UVM_FRONTDOOR);
	endtask

	virtual task mir(input uvm_check_e check = UVM_NO_CHECK);
		uvm_status_e       status;	
		this.mirror(status, check, UVM_FRONTDOOR);
		//in order to update ral mirror value
	endtask
	
	//this task is for write mx2 core sel
	virtual task coresel_wr(input uvm_reg_data_t value);
		uvm_status_e       status;
		this.write(status, value, UVM_FRONTDOOR);
	endtask
	//this task if for read mx2 core sel
	virtual task coresel_rd(output uvm_reg_data_t value);
		uvm_status_e       status;	
		this.read(status, value, UVM_FRONTDOOR);
	endtask


	virtual task upd();
		uvm_status_e       status;	
		this.update(status, UVM_FRONTDOOR);
	endtask

endclass : uvm_btc_reg


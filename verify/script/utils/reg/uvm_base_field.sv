
class uvm_base_field extends uvm_reg_field;
  string _reset_souce0 = "";
  string _reset_souce1 = "";

   `uvm_object_utils(uvm_base_field)

	function new(string name = "uvm_base_field");
   		super.new(name);
	endfunction: new

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

  virtual function void set_reset_source0(string source0 = "");
   this._reset_souce0 = source0;
  endfunction:set_reset_source0

  virtual function void set_reset_source1(string source1 ="" );
   this._reset_souce1 = source1;
  endfunction:set_reset_source1

  virtual function string get_reset_source0();
    return this._reset_souce0;
  endfunction:get_reset_source0

  virtual function string get_reset_source1();
    return this._reset_souce1;
  endfunction:get_reset_source1
  
endclass: uvm_base_field



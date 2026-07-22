
//`ifndef __JLM_TEST__
//`define __JLM_TEST__
class jls_base_test extends base_test;

string report_id = "jls_base_test";
  // automation macro
  `uvm_component_utils_begin(jls_base_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "jls_base_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);

  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
   super.main_phase(phase);
  endtask



endclass : jls_base_test


class jls_chipaddr_255_10_test extends jls_base_test;

string report_id = "jls_chipaddr_255_10_test"; 
  // automation macro
  `uvm_component_utils_begin(jls_chipaddr_255_10_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "jls_chipaddr_255_10_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   jls_chipaddr_255_10_seq   seq;

   phase.raise_objection(this);

   seq = jls_chipaddr_255_10_seq::type_id::create("jls_chipaddr_255_10_seq");
   seq.start(vseqr_h.jls_seqr_h);
   phase.drop_objection(this);

  endtask
endclass : jls_chipaddr_255_10_test

class jls_chipaddr_255_random_jlm_test extends jls_base_test;

string report_id = "jls_chipaddr_255_random_jlm_test"; 
  // automation macro
  `uvm_component_utils_begin(jls_chipaddr_255_random_jlm_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "jls_chipaddr_255_random_jlm_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   jls_chipaddr_255_random_jlm_seq   seq;

   phase.raise_objection(this);

   seq = jls_chipaddr_255_random_jlm_seq::type_id::create("jls_chipaddr_255_random_jlm_seq");
   seq.start(vseqr_h.jls_seqr_h);
   phase.drop_objection(this);

  endtask
endclass : jls_chipaddr_255_random_jlm_test

class jls_co_max_jlm_test extends jls_base_test;

string report_id = "jls_co_max_jlm_test"; 
  // automation macro
  `uvm_component_utils_begin(jls_co_max_jlm_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "jls_co_max_jlm_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   jls_co_max_jlm_seq   seq;

   phase.raise_objection(this);

   seq = jls_co_max_jlm_seq::type_id::create("jls_co_max_jlm_seq");
   seq.start(vseqr_h.jls_seqr_h);
   phase.drop_objection(this);

  endtask
endclass : jls_co_max_jlm_test

class jls_co_min_jlm_test extends jls_base_test;

string report_id = "jls_co_min_jlm_test"; 
  // automation macro
  `uvm_component_utils_begin(jls_co_min_jlm_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "jls_co_min_jlm_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   jls_co_max_jlm_seq   seq;

   phase.raise_objection(this);

   seq = jls_co_max_jlm_seq::type_id::create("jls_co_max_jlm_seq");
   seq.start(vseqr_h.jls_seqr_h);
   phase.drop_objection(this);

  endtask
endclass : jls_co_min_jlm_test

class jls_co_random_jlm_test extends jls_base_test;

string report_id = "jls_co_random_jlm_test"; 
  // automation macro
  `uvm_component_utils_begin(jls_co_random_jlm_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "jls_co_random_jlm_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   jls_co_max_jlm_seq   seq;

   phase.raise_objection(this);

   seq = jls_co_max_jlm_seq::type_id::create("jls_co_max_jlm_seq");
   seq.start(vseqr_h.jls_seqr_h);
   phase.drop_objection(this);

  endtask
endclass : jls_co_random_jlm_test

class jls_ecc1_jlm_test extends jls_base_test;

string report_id = "jls_ecc1_jlm_test"; 
  // automation macro
  `uvm_component_utils_begin(jls_ecc1_jlm_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "jls_ecc1_jlm_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   jls_ecc1_jlm_seq   seq;

   phase.raise_objection(this);

   seq = jls_ecc1_jlm_seq::type_id::create("jls_ecc1_jlm_seq");
   seq.start(vseqr_h.jls_seqr_h);
   phase.drop_objection(this);

  endtask
endclass : jls_ecc1_jlm_test

class jls_ecc2_jlm_test extends jls_base_test;

string report_id = "jls_ecc2_jlm_test"; 
  // automation macro
  `uvm_component_utils_begin(jls_ecc2_jlm_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "jls_ecc2_jlm_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   jls_ecc2_jlm_seq   seq;

   phase.raise_objection(this);

   seq = jls_ecc2_jlm_seq::type_id::create("jls_ecc2_jlm_seq");
   seq.start(vseqr_h.jls_seqr_h);
   phase.drop_objection(this);

  endtask
endclass : jls_ecc2_jlm_test

class jls_access_cross_addr_jlm_test extends jls_base_test;

string report_id = "jls_access_cross_addr_jlm_test"; 
  // automation macro
  `uvm_component_utils_begin(jls_access_cross_addr_jlm_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "jls_access_cross_addr_jlm_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   jls_access_cross_addr_jlm_seq   seq;

   phase.raise_objection(this);

   seq = jls_access_cross_addr_jlm_seq::type_id::create("jls_access_cross_addr_jlm_seq");
   seq.start(vseqr_h.jls_seqr_h);
   phase.drop_objection(this);

  endtask
endclass : jls_access_cross_addr_jlm_test

class jls_access_reg_clk_jlm_test extends jls_base_test;

string report_id = "jls_access_reg_clk_jlm_test"; 
  // automation macro
  `uvm_component_utils_begin(jls_access_reg_clk_jlm_test)
  `uvm_component_utils_end

  // constructor
  function new(string name = "jls_access_reg_clk_jlm_test",uvm_component parent);
    super.new(name,parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  begin
    super.build_phase(phase);
  end
  endfunction: build_phase

   task main_phase(uvm_phase phase);
    //int rd_data;
    logic [7:0] rd_data, exp_data;
   jls_access_reg_clk_jlm_seq   seq;

   phase.raise_objection(this);

   seq = jls_access_reg_clk_jlm_seq::type_id::create("jls_access_reg_clk_jlm_seq");
   seq.start(vseqr_h.jls_seqr_h);
   phase.drop_objection(this);

  endtask
endclass : jls_access_reg_clk_jlm_test

class jls_continuous_address_test extends jls_base_test;

	string report_id = "jls_continuous_address_test";
	// automation macro
	`uvm_component_utils_begin(jls_continuous_address_test)

	`uvm_component_utils_end

	// constructor
	function new(string name = "jls_continuous_address_test",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
	begin
		super.build_phase(phase);
	end
	endfunction: build_phase

	task main_phase(uvm_phase phase);
		jls_continuous_address_seq   seq;
		phase.raise_objection(this);
		seq = jls_continuous_address_seq::type_id::create("jls_continuous_address_seq");
		seq.start(vseqr_h.jls_seqr_h);
		phase.drop_objection(this);
	endtask

endclass : jls_continuous_address_test

class jls_apb_access_reg_test extends jls_base_test;

	string report_id = "jls_apb_access_reg_test";
	// automation macro
	`uvm_component_utils_begin(jls_apb_access_reg_test)

	`uvm_component_utils_end

	// constructor
	function new(string name = "jls_apb_access_reg_test",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
	begin
		super.build_phase(phase);
	end
	endfunction: build_phase

	task main_phase(uvm_phase phase);
		jls_apb_access_reg_seq   seq;
		phase.raise_objection(this);
		seq = jls_apb_access_reg_seq::type_id::create("jls_apb_access_reg_seq");
		seq.start(vseqr_h.jls_seqr_h);
		phase.drop_objection(this);
	endtask

endclass : jls_apb_access_reg_test

class jls_TEST_test extends jls_base_test;

	string report_id = "jls_TEST_test";
	// automation macro
	`uvm_component_utils_begin(jls_TEST_test)

	`uvm_component_utils_end

	// constructor
	function new(string name = "jls_TEST_test",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
	begin
		super.build_phase(phase);
	end
	endfunction: build_phase

	task main_phase(uvm_phase phase);
		jls_TEST_seq   seq;
		phase.raise_objection(this);
		seq = jls_TEST_seq::type_id::create("jls_TEST_seq");
		seq.start(vseqr_h.jls_seqr_h);
		phase.drop_objection(this);
	endtask

endclass : jls_TEST_test


// For standart apb

class jls_std_apb_smoke_test extends jls_base_test;

	string report_id = "jls_std_apb_smoke_test";
	// automation macro
	`uvm_component_utils_begin(jls_std_apb_smoke_test)

	`uvm_component_utils_end

	// constructor
	function new(string name = "jls_std_apb_smoke_test",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
	begin
		super.build_phase(phase);
	end
	endfunction: build_phase

	task main_phase(uvm_phase phase);
		jls_std_apb_smoke_seq   seq;
		phase.raise_objection(this);
		seq = jls_std_apb_smoke_seq::type_id::create("jls_std_apb_smoke_seq");
		seq.start(vseqr_h.jls_seqr_h);
		phase.drop_objection(this);
	endtask

endclass : jls_std_apb_smoke_test

class jls_std_apb_cross_test extends jls_base_test;

	string report_id = "jls_std_apb_cross_test";
	// automation macro
	`uvm_component_utils_begin(jls_std_apb_cross_test)

	`uvm_component_utils_end

	// constructor
	function new(string name = "jls_std_apb_cross_test",uvm_component parent);
		super.new(name,parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
	begin
		super.build_phase(phase);
	end
	endfunction: build_phase

	task main_phase(uvm_phase phase);
		jls_std_apb_cross_seq   seq;
		phase.raise_objection(this);
		seq = jls_std_apb_cross_seq::type_id::create("jls_std_apb_cross_seq");
		seq.start(vseqr_h.jls_seqr_h);
		phase.drop_objection(this);
	endtask

endclass : jls_std_apb_cross_test

//`endif //`ifndef __JLS_TEST__

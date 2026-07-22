class cust_reg_cbs extends uvm_reg_cbs;
   `uvm_object_utils(cust_reg_cbs)
 
   function new(string name = "cust_reg_cbs");
     super.new(name);
   endfunction

   virtual task post_read(uvm_reg_item rw); 

   //#30000ns;
   //uvm_reg this_reg;
   //assert(rw.element_kind == UVM_REG);
   //$cast(this_reg, rw.element);

   //#80000ns;
 
  //    `uvm_info(get_type_name(), $sformatf("mir_value: %h",this_reg.get_mirrored_value()), UVM_MEDIUM)

   
   //assert(this_reg.predict('hffffffff, -1, UVM_PREDICT_READ));

   `uvm_info("body", "Inserting ****** reg post_read callback ********* ...", UVM_NONE)
   //rw.value[0]= 'hbbd27277;
  // value = 'hbbd27277;


   endtask

   virtual task pre_read(uvm_reg_item rw); 
   uvm_reg this_reg;
   assert(rw.element_kind == UVM_REG);
   $cast(this_reg, rw.element);


   `uvm_info("body", "Inserting ****** reg [pre_read] callback ********* ...", UVM_NONE)

   fork  
 begin
  //    #40000ns;
      //rw.value[0]= 'hffffffff;
      //assert(this_reg.do_predict(rw, UVM_PREDICT_DIRECT));

//      assert(this_reg.predict('hffffffff, -1, UVM_PREDICT_DIRECT));
//   `uvm_info("body", "Inserting ****** reg [pre_read] callback do_predict ********* ...", UVM_NONE)

end
   join_none

   endtask


//-------------------
   virtual task pre_write(uvm_reg_item rw); 
   uvm_reg this_reg;
   assert(rw.element_kind == UVM_REG);
   $cast(this_reg, rw.element);


   `uvm_info("body", "Inserting ****** reg [pre_write] callback ********* ...", UVM_NONE)

   fork  
 begin
  //    #50000ns;

 //     assert(this_reg.predict('h55555555, -1, UVM_PREDICT_DIRECT));
 //  `uvm_info("body", "Inserting ****** reg [pre_write] callback do_predict ********* ...", UVM_NONE)

end
   join_none

   endtask




  virtual function void post_predict(input uvm_reg_field  fld,
                                     input uvm_reg_data_t previous,
                                     inout uvm_reg_data_t value,
                                     input uvm_predict_e  kind,
                                     input uvm_path_e     path,
                                     input uvm_reg_map    map);
      //value = 'hbbd27277;

   `uvm_info("body", "Inserting ******[ post_predict ] callback ********* ...", UVM_NONE)

  endfunction




endclass: cust_reg_cbs

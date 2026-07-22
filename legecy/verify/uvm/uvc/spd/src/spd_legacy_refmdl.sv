
class spd_legacy_refmdl extends spd_base_refmdl;
 `uvm_component_utils(spd_legacy_refmdl);

   function new(string name="spd_legacy_refmdl",uvm_component parent);
      super.new(name,parent);
    endfunction

    task initMdl();
        super.initMdl();
        //SpdTh0 = 
        this.th_pass = vif.th_pass;
        this.th_fail = vif.th_fail;
        //SpdTh1 = 
        this.th_init = vif.th_init;
        this.th_ms_sel = vif.th_ms_sel;
        //SpdTh2 =   
        this.th_to = vif.th_to;
        //SpdTh3 = 
        this.lv1thms =      vif.lv1_th_ms;
        this.lv1thmsadd =   vif.lv1_th_ms_add;
        this.lv2thms =      vif.lv2_th_ms;
        this.lv2thmsadd =   vif.lv2_th_ms_add;             
        //SpdTh4 = 
        this.lv3thms =      vif.lv3_th_ms;
        this.lv3thmsadd =   vif.lv3_th_ms_add;
        this.lv4thms =      vif.lv4_th_ms;
        this.lv4thmsadd =   vif.lv4_th_ms_add;
        $display("-----------------------------------------");
        $display("th_init = %x", this.th_init);
        $display("th_pass = %x", this.th_pass);
        $display("th_fail = %x", this.th_fail);
        $display("-----------------------------------------");
        $display("th_ms_sel = %d", this.th_ms_sel);
        $display("th_to = %x", this.th_to);
        $display("lv1thms = %x", this.lv1thms);
        $display("lv1thmsadd = %x", this.lv1thmsadd);
        $display("lv2thms = %x", this.lv2thms);
        $display("lv2thmsadd = %x", this.lv2thmsadd);
        $display("lv3thms = %x", this.lv3thms);
        $display("lv3thmsadd = %x", this.lv3thmsadd);
        $display("lv4thms = %x", this.lv4thms);
        $display("lv4thmsadd = %x", this.lv4thmsadd);

    endtask

    task automatic trig_pass(input done, input pass, input [7:0] coreid);
        logic [15:0]    cur_ms;
        logic           cur_add_sub;
        logic [14:0]    cur_step;
        logic [3:0]     cur_spd;
        
           
        if(vif.check_enable == 0) begin
            return;
        end

        if(this.spden == 0) begin
            return;
        end
        //get current spd level
        cur_spd = this.spds[coreid*4+:4];
       
        //this.mark_spd_chg(coreid);
        if(cur_spd==4'b0000)begin
            return;
        end
        //`uvm_info("SPD_REF_MDL STATUS Before", $psprintf("Coreid=%d Spd=%d Mark=%x", coreid, cur_spd, this.marks[coreid]), UVM_MEDIUM);



        if(this.ssdn_protect==0)begin           
            if(pass == 1) begin
                if({1'b0,this.marks[coreid]} + {1'b0,this.th_pass} >= {1'b1,16'h0}) begin
                    if(cur_spd >= this.spdhigh) begin
                        cur_spd = this.spdhigh;
                        //$display("###1 %d", cur_spd);
                    end
                    else begin
                        cur_spd++;
                        //$display("###2 %d", cur_spd);
                    end
                    this.marks[coreid] = this.th_init;
                    this.spds[coreid*4+:4] = cur_spd;
                end
                else begin
                    this.marks[coreid] += this.th_pass;
                end
            end
            else begin
                if(this.marks[coreid] < this.th_fail) begin
                    if(cur_spd <= this.spdlow) begin
                        cur_spd = this.spdlow;
                        //$display("###3 %d", cur_spd);
                    end
                    else begin
                        cur_spd--;
                        //$display("###4 %d", cur_spd);
                    end
                    this.marks[coreid] = this.th_init;
                    this.spds[coreid*4+:4] = cur_spd;
                end
                else begin
                    this.marks[coreid] -= this.th_fail;
                end
            end
        end
        else begin

           
            if(pass == 1) begin
                if({1'b0,this.marks[coreid]} + {1'b0,this.th_pass} >= {1'b1,16'h0}) begin
                    if(cur_spd >= this.spdhigh) begin
                        cur_spd = this.spdhigh;                      
                    end
                    else begin
                        cur_spd++;
                    end
                    this.marks[coreid] = this.th_init;
                    this.spds[coreid*4+:4] = cur_spd;
                end
                else begin
                    this.marks[coreid] += this.th_pass;
                end
            end
            else if(this.spd_can_down[coreid]==1)begin

                if(this.marks[coreid] < this.th_fail) begin
                    if(cur_spd <= this.spdlow) begin
                        cur_spd = this.spdlow;                        
                    end
                    else begin
                        cur_spd--;  
                        this.spd_can_down[coreid]=0;
                    end
                    
                    this.marks[coreid] = this.th_init;
                    this.spds[coreid*4+:4] = cur_spd;

                end
                else begin
                    this.marks[coreid] -= this.th_fail;
                end
            end
            else begin
                this.marks[coreid] = this.marks[coreid];
                this.spds[coreid*4+:4] = this.spds[coreid*4+:4];
            end
        end

        if (vif.REG_self_aging_en==1'b1) begin  
            return ;
        end
        repeat(3)@(posedge vif.clk);
        
        //`uvm_info("SPD_REF_MDL STATUS After", $psprintf("Coreid=%d Spd=%d Mark=%x", coreid, cur_spd, this.marks[coreid]), UVM_MEDIUM);
        
        //do auto check
        fork
            automatic logic freq_checked = 0;
            begin
                automatic logic [15:0]      rtl_mark;
                automatic logic [3:0]       rtl_spd;
                automatic logic [3:0]       spd_exp = get_map_spd(cur_spd);
                automatic logic [15:0]      mark_exp = this.marks[coreid];
                automatic logic [7:0]       cur_coreid = coreid;

                uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_simple.mark[15:0]",cur_coreid), rtl_mark);
                uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.spd_sel[2:0]",cur_coreid), rtl_spd);
                if(spd_exp != rtl_spd) begin
                    `uvm_error("SPD_REF_MDL CHECK FAILED", $psprintf("mdl_spd=%d rtl_spd=%d", spd_exp, rtl_spd));
                end

                if(mark_exp != rtl_mark) begin
                    `uvm_error("SPD_REF_MDL CHECK FAILED", $psprintf("mdl_mark=%x rtl_mark=%x", mark_exp, rtl_mark));
                end

                `uvm_info("SPD_REF_MDL", $psprintf("Done !, Spd=%d Mark=%x", spd_exp, mark_exp), UVM_MEDIUM);
            end

            /*begin // do the check
                automatic logic [7:0] cur_coreid = coreid;
                automatic logic [3:0] spd_exp = get_map_spd(cur_spd);
                automatic logic [2:0] core_spd = 0;
                automatic real freq_exp = 0,f0=0,f1=0;
                automatic real freq_act = 0;
                // check core spd
                if(this.gbp_en == 1'b0)begin
                    wait(wc_vif.spd_busy == 1'b1);
                    `uvm_info("SPD_REF_MDL", "Start Sync Spds", UVM_MEDIUM);
                    wait(wc_vif.spd_busy == 1'b0);
                    `uvm_info("SPD_REF_MDL", "End Sync Spds", UVM_MEDIUM);
                    freq_checked = 1'b1;
                    core_spd = wc_vif.spd_sel[cur_coreid];
                    `uvm_info("SPD_REF_MDL", $psprintf("Coreid=%d Checking..... exp_spd=%d core_spd=%d", cur_coreid, spd_exp, core_spd), UVM_MEDIUM);
                    if(core_spd != spd_exp) begin
                        `uvm_error("SPD_MDL_CHECK FAILED", $psprintf("exp_spd=%d core_spd=%d mismatch", spd_exp, core_spd));
                    end
                    repeat(5) begin
                        @(posedge vif.clk);
                    end
                    @(posedge mx2_vif.mx2_hash_clk[cur_coreid]) f0=$realtime;
                    @(posedge mx2_vif.mx2_hash_clk[cur_coreid]) f1=$realtime;
                    
                    //check spd freq
                    freq_exp = this.get_freq_exp(spd_exp);
                    freq_act = f1-f0;
                    `uvm_info("SPD_REF_MDL", $psprintf("Start checking Coreid=%d freq_exp=%f ", cur_coreid, freq_exp), UVM_MEDIUM);
                    if(chkc_real_equal(freq_exp,freq_act) !== 1) begin
                        `uvm_error("SPD_MDL_CHECK FAILED", $psprintf("Coreid=%d freq_exp=%f freq_act=%f mismatch", cur_coreid, freq_exp, freq_act));
                    end
                end
                else begin

                end
            end*/
        join_none

    endtask
    
    task automatic check_spd_marks(input [7:0] coreid);
             
        if(vif.check_enable == 0) begin
            return;
        end

        repeat(1) @(posedge vif.clk); 
        
        fork
            begin
                automatic logic [15:0]      rtl_mark;
                automatic logic [3:0]       rtl_spd;
                automatic logic [3:0]       spd_exp = get_map_spd(this.spds[coreid*4+:4]);
                automatic logic [15:0]      mark_exp = this.marks[coreid];
                automatic logic [7:0]       cur_coreid = coreid;

                uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_simple.mark[15:0]",cur_coreid), rtl_mark);
                uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.spd_sel[2:0]",cur_coreid), rtl_spd);
                if(spd_exp != rtl_spd) begin
                    `uvm_error("SPD_REF_MDL CHECK SPD FAILED", $psprintf("coreid=%d,mdl_spd=%d rtl_spd=%d", cur_coreid,spd_exp, rtl_spd));
                end
                else begin
                    `uvm_info("SPD_REF_MDL  CHECK SPD PASSED", $psprintf("coreid=%d,mdl_spd=%d rtl_spd=%d", cur_coreid,spd_exp, rtl_spd), UVM_MEDIUM);
                end

                if(mark_exp != rtl_mark) begin
                    `uvm_error("SPD_REF_MDL CHECK MARK FAILED",     $psprintf("coreid=%d,mdl_mark=%x rtl_mark=%x", cur_coreid,mark_exp, rtl_mark));
                end
                else begin
                    `uvm_info("SPD_REF_MDL  CHECK MARK PASSED", $psprintf("coreid=%d,mdl_mark=%x rtl_mark=%x", cur_coreid,mark_exp, rtl_mark), UVM_MEDIUM);
                end
            end
     
        join_none

    endtask

    
    function automatic  bit[15:0] get_thms(input [7:0] coreid, input [3:0] spd);
        if(this.th_ms_sel == 1'b1) begin
            if(spd === 3'b000)
                return 16'h0000;
            else if(spd === 3'h1)
                return {this.lv1thmsadd, this.lv1thms};
            else if(spd === 3'h2)
                return {this.lv2thmsadd, this.lv2thms};
            else if(spd === 3'h3)
                return {this.lv3thmsadd, this.lv3thms};
            else if(spd === 3'h4)
                return {this.lv4thmsadd, this.lv4thms};
        end
        else begin
            return {this.lv1thmsadd, this.lv1thms};
        end
    endfunction

    task automatic trig_timeout();

        bit [15:0] cur_ms;
        bit        cur_add_sub;
        bit [14:0] cur_step; 
        bit [7:0]  coreid;
        
        for(bit [7:0] i=0; i<`DESIGN_CORE_NUM; i++) begin
            coreid = i;
            cur_ms = get_thms(coreid, this.spds[coreid*4+:4]);
            cur_add_sub = cur_ms[15];
            cur_step = cur_ms[14:0];

            if(cur_step === 15'h0)
                continue;
            //$display("coreid=%d  flag=%d step=%x  cur_spd=%d cur_mark=%x", coreid, cur_add_sub, cur_step, this.spds[coreid*4+:4], this.marks[coreid]);
            if(1'b1 == cur_add_sub) begin
                if(({1'b0, this.marks[coreid]} + {1'b0, cur_step}) > {1'b0, 16'hffff})begin
                    if(this.spds[coreid*4+:4] >= this.spdhigh) begin
                        this.spds[coreid*4+:4] = this.spdhigh;
                    end
                    else begin
                        this.spds[coreid*4+:4]++;
                    end
                    this.marks[coreid] = this.th_init;
                end
                else begin
                    this.marks[coreid] += cur_step;
                end
            end
            else begin
                if(this.marks[coreid] < cur_step) begin
                    if(this.spds[coreid*4+:4] <= this.spdlow) begin
                        this.spds[coreid*4+:4] = this.spdlow;
                    end
                    else begin
                        this.spds[coreid*4+:4]--;
                    end
                    this.marks[coreid] = this.th_init;
                end
                else begin
                    this.marks[coreid] -= cur_step;
                end
            end
        end

        repeat(3)
            @(posedge vif.clk);

        fork
            begin

                for(int id=0; id<`DESIGN_CORE_NUM; id++) begin
                    automatic logic [15:0]      rtl_mark;
                    automatic logic [3:0]       rtl_spd;
                    automatic logic [3:0]       spd_exp = get_map_spd(this.spds[id*4+:4]);
                    automatic logic [15:0]      mark_exp = this.marks[id];
                    automatic logic [7:0]       cur_coreid = id;
                    //wait RTL data Ready
                    

                    uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.smart_speed_simple.mark[15:0]",cur_coreid), rtl_mark);
                    uvm_hdl_read($sformatf("tb_top.C[0].btnode.btc.sys_ctrl.speed.G_SPEED_CORE[%0d].speed_core.spd_sel[2:0]",cur_coreid), rtl_spd);
                    if(spd_exp != rtl_spd) begin
                        `uvm_error("SPD_REF_MDL CHECK TIMEOUT FAILED", $psprintf("Coreid=%d  mdl_spd=%d rtl_spd=%d", cur_coreid, spd_exp, rtl_spd));
                    end

                    if(mark_exp != rtl_mark) begin
                        `uvm_error("SPD_REF_MDL CHECK TIMEOUT FAILED", $psprintf("Coreid=%d  mdl_mark=%x rtl_mark=%x",cur_coreid, mark_exp, rtl_mark));
                    end

                    `uvm_info("SPD_REF_MDL", $psprintf("TIMEOUT Coreid=%d Check Done !, Spd=%d Mark=%x", cur_coreid,spd_exp, mark_exp), UVM_MEDIUM);
                end
            end
        join_none

    endtask

endclass

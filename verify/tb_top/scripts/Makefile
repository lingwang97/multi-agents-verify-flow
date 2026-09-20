#######################################################################################################
# File name  : $git_home/verify/script/sflow/Makefile
# Author     : Mr Wang
# Description: Entry Makefile for simulation, support all kinds of project
# 			   a. Wsim should allow for different configuration parameters for the same test case, 
#				 making it convenient for top-level users to specify them directly through wsim.
# 			   b. For module tests and specific test cases, it is necessary to implement them in the makefile by defining specific macros.
#			   c. 
# History	 :
# --------------------------------------------------------------------------------------------------
#    Version    Date   		    Author      Comment
# --------------------------------------------------------------------------------------------------
#    1.0		2026.06.15		Mr Wang 	Initial version
#
# --------------------------------------------------------------------------------------------------
#
#######################################################################################################

#######################################################################################################
# Step 0: Getting project name and setting common variables
#######################################################################################################
project = `cat project_name`

ifndef dataBasePath
  dataBasePath=../../..
endif

ifndef VCS_MACRO_OPT
   VCS_MACRO_OPT = ""
endif

VCS_MACRO_OPT_LIST := $(subst +, ,$(VCS_MACRO_OPT))
filelist_path=$(dataBasePath)/verify/tb_top/filelist

gate_file =  $(filelist_path)/gate_file_lst.f
gpls_lib_lst = $(filelist_path)/gpls_lib_lst.f
UART_VIP_HOME="/project/SG/public/uart_vip/"
DPO_DATABASE_DIR=/archive/project/SG/dpo_database

#######################################################################################################
# Step 1-a: Checking simulation config setting from Macro Define(description b)
#######################################################################################################

### If **_BLOCK_TEST is defined, it is a module level validation environment,
ifeq ($(findstring BLOCK_TEST, $(VCS_MACRO_OPT)),)
else
	block_env = 1
endif


### This is for array debug-pli access,add define DEBUG_ALL
ifeq ($(findstring DEBUG_ALL, $(VCS_MACRO_OPT)),)
else
	debug_all_test = 1
endif

### This is for X-state propagation check,add define XPROP_CHECK
ifeq ($(findstring XPROP_CHECK, $(VCS_MACRO_OPT)),)
else
	xprop_define =  -xprop=xprop.cfg 
	xprop_sim=  -report=xprop
endif

ifneq ($(findstring $(level),gate post),)
	gpls_en = 1
else
	gpls_en = 0
endif


ifeq ($(findstring FPGA_SYN, $(VCS_MACRO_OPT)),)
else
	fpga_test = 1
endif


jamlink_contains :=$(findstring USE_JAMLINK_DRV, $(VCS_MACRO_OPT))
uart_contains :=$(findstring USE_UART_DRV, $(VCS_MACRO_OPT))
realcore_contains :=$(findstring REAL_CORE, $(VCS_MACRO_OPT))
fakecore_contains :=$(findstring USE_FAKECORE, $(VCS_MACRO_OPT))

ifeq ($(realcore_contains),)
	ifeq ($(fakecore_contains),)
		add_realcore = 
	else
		add_realcore = _USE_FAKECORE
	endif
else
	add_realcore = _USE_REALCORE
endif

ifeq ($(gpls_en),1)
	ifeq ($(block_env),)
		ifeq ($(jamlink_contains),)	
			ifeq ($(uart_contains),)
				designTag = gpls_btc_jls_$(mudue_name)$(dpo_sub_name)$(add_realcore)
			else
				designTag = gpls_btc_uart_$(mudue_name)$(dpo_sub_name)$(add_realcore)
			endif
		else
			designTag = gpls_btc_jamlink_$(mudue_name)$(dpo_sub_name)$(add_realcore)
		endif
	else
		designTag = gpls_block_$(mudue_name)$(dpo_sub_name)$(add_realcore)
	endif
else
	ifeq ($(block_env),)
		ifeq ($(jamlink_contains),)	
			ifeq ($(uart_contains),)
				designTag = btc_jls_$(mudue_name)$(dpo_sub_name)$(add_realcore)
			else
				designTag = btc_uart_$(mudue_name)$(dpo_sub_name)$(add_realcore)
			endif
		else
			designTag = btc_jamlink_$(mudue_name)$(dpo_sub_name)$(add_realcore)
		endif
	else
		designTag = block_$(mudue_name)$(dpo_sub_name)$(add_realcore)
	endif
endif



#######################################################################################################
# Step 1-b: Checking simulation switches from wsim's option (description a)
#######################################################################################################

#-------------------------------------------------------------------------
#  Checking system time
#-------------------------------------------------------------------------
time = 0
ifeq ($(timefix),1)
	ifeq ($(time),0)
		define_para += +define+SYSTIME='"1"'
	else
		define_para += +define+SYSTIME='"$(time)"'
	endif
else
	time = $(shell date +"%Y%m%d%H%M%S")
	define_para += +define+SYSTIME='"$(time)"'
endif

#-------------------------------------------------------------------------
# Checking different-level simulation vcs option and define para  
#-------------------------------------------------------------------------
ifeq ($(level),gate)
	define_para += +define+GPL_SIM +define+NTC+RECREM
	spec += -diag=sdf:verbose
	vcs_para += +neg_tchk +no_notifier
else ifeq ($(level),post)
	define_para += +define+GPL_SIM +define+POST_SIM  +define+NTC+RECREM
	spec += -diag=sdf:verbose
	vcs_para += -sdfretain -negdelay +neg_tchk +optconfigfile+digit_ip_async.lst -tcheckvecsplit
else
	define_para += +define+NTC+RECREM
	vcs_para += +no_notifier +neg_tchk +optconfigfile+cklatch_nospecify.cfg 
endif


#-------------------------------------------------------------------------
# Checking simulation corner when level=post
#-------------------------------------------------------------------------
ifeq ($(corner),wst)
	define_para += +define+CORNER_MIN
else ifeq ($(corner),bst)
	define_para += +define+CORNER_MAX
else ifeq ($(corner),typ)
	define_para += +define+CORNER_TYP
else
	define_para += +define+CORNER_TYP
endif

#-------------------------------------------------------------------------
# Checking mtm type when level=post
#-------------------------------------------------------------------------
ifeq ($(mtm),min)
	define_para += +define+MTM_SPEC='"MINIMUM"'
else ifeq ($(mtm),max)
	define_para += +define+MTM_SPEC='"MAXIMUM"'
else ifeq ($(mtm),typ)
	define_para += +define+MTM_SPEC='"TYPICAL"'
else
	define_para += +define+MTM_SPEC='"TOOL_CONTROL"'
endif

#-------------------------------------------------------------------------
# Checking upf filelst
#-------------------------------------------------------------------------
ifneq ($(upf_file),)
	define_para += +define+UPF -upf $(upf_file)
endif


#-------------------------------------------------------------------------
# Checking system-level ip filelst
#-------------------------------------------------------------------------
ifeq ($(level),gate)
	ip_list = -f $(filelist_path)/gate_ip_file_lst.f
else ifeq ($(level),post)
	ip_list = -f $(filelist_path)/gate_ip_file_lst.f
else
	ip_list = -f $(filelist_path)/ip_file_lst.f
endif

#-------------------------------------------------------------------------
# Checking system-level general filelst cfg 
#-------------------------------------------------------------------------

ifeq ($(block_env),)
	#system env
	ifeq ($(level),gate)
		hdl_fl_para += -f $(gpls_lib_lst) -f $(gate_file)
	else ifeq ($(level),post)
		hdl_fl_para += -f $(gpls_lib_lst) -f $(gate_file) 
	else ifeq ($(fpga_test),1)
		hdl_fl_para +=  -f $(filelist_path)/rtl_file_lst.f  -f $(dataBasePath)/verify/sv/env/tb_top/fpga.f
		fpga_define = -f $(dataBasePath)/verify/sv/env/tb_top/fpga.f  -top glbl
	else
		hdl_fl_para +=  -f $(filelist_path)/lib_lst.f  -f $(filelist_path)/rtl_file_lst.f 
	endif
else
	#block env
	ifeq ($(level),gate)
		hdl_fl_para += -f $(gpls_lib_lst) -f $(gate_file)
	else ifeq ($(level),post)
		hdl_fl_para += -f $(gpls_lib_lst) -f $(gate_file) 
	else
		hdl_fl_para +=  -f $(filelist_path)/lib_lst.f  -f $(filelist_path)/rtl_file_lst.f
	endif
endif

#-------------------------------------------------------------------------
# Checking system-level other specific filelst cfg
#-------------------------------------------------------------------------

#-------------------------------------------------------------------------
# Checking fgp cfg setting
#-------------------------------------------------------------------------
ifneq ($(findstring $(level),gate post),)
	fgp_compile = -fgp -j 4  
	fgp_para = -fgp=num_threads:4
else
	fgp_compile = -fgp 
	fgp_para = -fgp=num_threads:2
endif

ifeq ($(fpg_verbose),1)
	# generate fgp runtime report and other options
	fgp_para += -fgp=diag:ruse -fgp=auto_affinity:allowHyperThreadCpu -fgp=schedpli 
endif

#-------------------------------------------------------------------------
#  Checking timing-check switch
#-------------------------------------------------------------------------
ifeq ($(notimingcheck),1)
	timingcheck_para += +notimingcheck +pathpulse 
else ifeq ($(level),prepost)
	timingcheck_para += +notimingcheck +pathpulse 
else
	timingcheck_para += +pathpulse 
endif

#-------------------------------------------------------------------------
#  UVM VERBOSITY
#-------------------------------------------------------------------------
ifeq ($(uvm_verbosity),0)
	UVM_VERBOSITY = UVM_NONE
else ifeq ($(uvm_verbosity),1)
	UVM_VERBOSITY = UVM_LOW
else ifeq ($(uvm_verbosity),2)
	UVM_VERBOSITY = UVM_MEDIUM
else ifeq ($(uvm_verbosity),3)
	UVM_VERBOSITY = UVM_HIGH
else ifeq ($(uvm_verbosity),4)
	UVM_VERBOSITY = UVM_FULL
else
	UVM_VERBOSITY = UVM_MEDIUM
endif


#-------------------------------------------------------------------------
# Checking specify switch
#-------------------------------------------------------------------------
ifeq ($(specify),1)
	spec +=
else
	spec +=
	#spec += +nospecify
endif

#-------------------------------------------------------------------------
# Checking coverage switch
#-------------------------------------------------------------------------
ifeq ($(cm_switch),1)
	ifneq ($(findstring $(level),gate post),)
	else
		cm_para_comp = -cm line+cond+fsm+tgl+branch -cm_line contassign -cm_name $(testname) -cm_hier Makefile.coverage.cfg 
		cm_para_sim  = -cm line+cond+fsm+tgl+branch -cm_line contassign -cm_name $(if $(cm_name),$(cm_name),$(testname)) $(if $(cm_dir),-cm_dir $(cm_dir),) 
	endif
endif

#-------------------------------------------------------------------------
# Checking rtdbg switch
#-------------------------------------------------------------------------
ifeq ($(rtdbg),1)
	dump_vcs  += -rtdbg
	dump_simv += -rtdbg=dump -do Makefile.rtdbg.tcl
else
	dump_vcs  +=
	dump_simv += -do Makefile.run.tcl
endif

#-------------------------------------------------------------------------
# Checking waveform dumping switch
#-------------------------------------------------------------------------
ifeq ($(fsdb),1)
	dump_vcs += +define+DUMP_FSDB
	fsdb_force = +fsdb+force
	dump_simv += +UVM_VERDI_TRACE=COMPWAVE+HIER+RALWAVE +fsdbfile+novas.fsdb 
	ifeq ($(lib),1)
		dump_vcs += -debug_access+all -debug_region=cell+lib
	else
		dump_vcs += -debug_access+all -debug_region=cell+lib
	endif
else
	fsdb_force =
	ifneq ($(findstring $(level),gate post),)
		ifeq ($(debug_all_test),1)
			dump_vcs += -debug_access+all -debug_region=cell+lib
		else
			dump_vcs += -debug_access+r+f+fwn+w
		endif
	else
		ifeq ($(debug_all_test),1)
			dump_vcs += -debug_access+all -debug_region=cell+lib
		else
			dump_vcs += -debug_access+r+f+fwn+w
		endif
	endif
endif


ifeq ($(vpd),1)
	dump_vcs += -debug_access+dmptf +define+DUMP_VPD
	ifeq ($(lib),1)
		dump_vcs += -debug_access+all -debug_region=cell+lib
	else
		dump_vcs += -debug_access+dmptf
	endif
else
	dump_vcs +=
endif

#add DUMP_CP_WAVEFORM is to enable cpft dump feature
ifeq ($(cpdump),0)
	dump_vcs +=
else
	dump_vcs += +define+DUMP_CP_WAVEFORM
endif

#-------------------------------------------------------------------------
# Checking loop detect/report switch
#-------------------------------------------------------------------------
ifeq ($(loop),1)
	loop_opt += +vcs+loopreport+10000000
else
	loop_opt +=
endif

#-------------------------------------------------------------------------
# Checking simprofile switch
#-------------------------------------------------------------------------
ifeq ($(profile),time)
	simprofile_opt = -simprofile time
else ifeq ($(profile),mem)
	simprofile_opt = -simprofile mem
else ifeq ($(profile),timemem)
	simprofile_opt = -simprofile time+mem
endif

#-------------------------------------------------------------------------
# Checking rtl coding error
#-------------------------------------------------------------------------
ifeq ($(ongs),1)
	compile_option += -error=ONGS
else
	compile_option += +error+10000
endif

#-------------------------------------------------------------------------
# Checking Partition compile setting switch
#-------------------------------------------------------------------------

compile_option += -pcmakeprof 
ifneq ($(findstring $(level),gate post),)
	ifneq ($(findstring NETLIST_MX2CORE,$(VCS_MACRO_OPT)),)
		compile_option += -j4
	endif
	compile_option += -hsopt=gates
else
	compile_option += -j2
endif

#-------------------------------------------------------------------------
#  Checking gui switch
#-------------------------------------------------------------------------
ifeq ($(guiswitch),1)
    gui_option += -gui=verdi
else
    gui_option +=
endif

#-------------------------------------------------------------------------
#  Checking dpo config switch
#-------------------------------------------------------------------------
ifeq ($(dpo),learn)
	vcs_para += -dpo  -dpo_opts mode=learn+dbdir=$(DPO_DATABASE_DIR)/dpo_learn_db  -dpo_opts design_tag=$(designTag)+user_tag=learn+apps=default,lint,upfopt,pgates,gates_ml
	dpo_sim_para = -dpo -dpo_opts test_name=$(testname)
else ifeq ($(dpo),apply_reco)
	vcs_para += -dpo  -dpo_opts mode=apply+learn_dbdir=$(DPO_DATABASE_DIR)/dpo_learn_db+dbdir=$(DPO_DATABASE_DIR)/dpo_apply_db  -dpo_opts design_tag=$(designTag)+user_tag=apply+apps=default,fgp,lint,upfopt,pgates,gates_ml -dpo_opts reco_file=$(dataBasePath)/sim/dpo_reco.csv
	dpo_sim_para = -dpo -dpo_opts test_name=$(testname)
else ifeq ($(dpo),apply)
#   vcs_para += -dpo  -dpo_opts mode=apply+learn_dbdir=$(DPO_DATABASE_DIR)/dpo_learn_db+dbdir=$(DPO_DATABASE_DIR)/dpo_apply_db  -dpo_opts design_tag=$(designTag)+user_tag=apply+apps=default,fgp,lint,upfopt,pgates,gates_ml
	vcs_para += -dpo  -dpo_opts mode=apply+learn_dbdir=$(DPO_DATABASE_DIR)/dpo_learn_db  -dpo_opts design_tag=$(designTag)+user_tag=apply+apps=default,fgp,lint,upfopt,pgates,gates_ml
	dpo_sim_para = -dpo -dpo_opts test_name=$(testname)
else ifeq ($(dpo),refer)
	vcs_para += -dpo  -dpo_opts apps=vcsgd+dbdir=$(DPO_DATABASE_DIR)/dpo_refer_db+design_tag=$(designTag)+user_tag=reference
	dpo_sim_para = -dpo -dpo_opts test_name=$(testname)
else
	vcs_para +=
	dpo_sim_para = 
endif


#-------------------------------------------------------------------------
#  setting simulation seed
#-------------------------------------------------------------------------
#SEED = 1
ifdef seed
	SEED=$(seed)
else
	SEED := $(shell python2 -c "from random import randint; print randint(0,99999999)")
endif

#-------------------------------------------------------------------------
#  setting vcs reg initial cfg
#-------------------------------------------------------------------------

ifeq ($(block_env),)
	#system env
	init_reg_cfg = +vcs+initreg+config+Makefile.initreg.cfg
else
	#block env
	ifneq ($(findstring MX2_BLOCK_TEST, $(VCS_MACRO_OPT)),)
		init_reg_cfg += +vcs+initreg+config+mx2.reg_config
	else
		init_reg_cfg = +vcs+initreg+random 
	endif
endif

#-------------------------------------------------------------------------
#  setting uvm parameters
#-------------------------------------------------------------------------

uvm_package = -ntb_opts uvm-1.2
uvm_para += +UVM_TESTNAME=$(UVM_TESTNAME) +UVM_VERBOSITY=$(UVM_VERBOSITY)
uvm_para +=$(subst +, +,$(VCS_PLUSARGS_OPT))


#-------------------------------------------------------------------------
#  setting specific verify envs filelist
#-------------------------------------------------------------------------

ifeq ($(block_env),)
	#system env
	uvm_file_lst = -f $(dataBasePath)/verify/tb_top/filelist/uvm.f
else
	#block env
	ifneq ($(findstring EFUSE_BLOCK_TEST, $(VCS_MACRO_OPT)),)
		uvm_file_lst = -f $(dataBasePath)/verify/tb_top/filelist/uvm_blk_efuse.f
	else
		uvm_file_lst = 
	endif
endif

#######################################################################################################
# Step 2: Merging define_para , filelist_para and vcs options
#######################################################################################################
ifeq ($(block_env),)
	list_para = $(dataBasePath)/sim/project_name \
		-f $(dataBasePath)/verify/tb_top/macro/rtl_define.f \
		$(dataBasePath)/verify/tb_top/macro/tb_define.sv \
		$(ip_list) \
		-f $(dataBasePath)/verify/tb_top/filelist/include.f \
		$(hdl_fl_para) \
		$(uvm_file_lst) \
		$(fpga_define) \
		$(xprop_define) \
		$(dataBasePath)/verify/utils/dpi_func.c
else
	#block setting
	list_para = $(dataBasePath)/sim/project_name \
		-f $(dataBasePath)/verify/tb_top/macro/rtl_define.f \
		$(dataBasePath)/verify/tb_top/macro/tb_define.sv \
		$(ip_list) \
		-f $(dataBasePath)/verify/tb_top/filelist/include.f \
		$(hdl_fl_para) \
		$(uvm_file_lst) \
		$(fpga_define) \
		$(xprop_define) \
		$(dataBasePath)/verify/utils/dpi_func.c
endif


#######################################################################################################
# Step 3: Objects
#######################################################################################################
default:cmp
debug:
	@echo "=================VAR VALUE BEGIN==================================="
	@echo "VCS_MACRO_OPT:"$(VCS_MACRO_OPT)
	@echo "VCS_MACRO_OPT_LIST:" $(VCS_MACRO_OPT_LIST)
	@echo "block_env:" $(block_env)
	@echo "================= VAR VALUE END ==================================="
echo_hostname:
	echo $HOSTNAME > ./hostname
cmp:
	make com_echo; make echo_hostname cmpr; echo current time is $(time);
cmpr:
	vcs $(VCS_MACRO_OPT) -timescale=1ns/10ps  +v2k -sverilog $(fgp_compile) -full64 -l compile.log -licqueue -kdb -lca +error+100 \
	+sdfverbose \
	+lint=PCWM \
	+lint=TFIPC-L \
	+lint=PCWM \
	-P ${VERDI_HOME}/share/PLI/VCS/linux64/novas.tab  \
	${VERDI_HOME}/share/PLI/VCS/linux64/pli.a \
	$(init_reg_cfg) \
    $(uvm_package) \
	$(spec) \
	$(loop_opt) \
	$(dump_vcs) \
	$(compile_option) \
	$(cm_para_comp) \
	$(vcs_para) \
	$(define_para) \
	$(timingcheck_para) \
	$(simprofile_opt) \
	$(sim_define_option) \
	$(list_para) \
	$(vip_comp_para) \
	-top tb_top

sim:
	make simv_echo; make covsim; echo current SEED is $(SEED);
covsim:
	simv +vcs+lic+wait -ucli -l sim.log +ntb_stop_on_constraint_solver_error=1 -assert quiet+report \
	$(dump_simv) $(fsdb_force) $(uvm_para) $(gui_option) +ntb_random_seed=$(SEED) $(cm_para_sim) $(fgp_para) \
	$(simv_opt) $(vip_sim_para)$(xprop_sim) $(init_reg_cfg) $(dpo_sim_para)
show:
	dve -vpd simv.vpd -full64 &
covshow:
	dve -full64 -covdir simv.vdb&
clean:
	rm -rf *.fsdb *.log simv.vdb simv.vpd DVEfiles waveform.vpd csrc  gvlist simv  simv.daidir    ucli.key  vcdplus.vpd  vcs.log pulltime sdfAnnotateInfo 64 verdiLog novas.conf novas.rc


#######################################################################################################
# Step 4: Store vcs cmd
#######################################################################################################
#com_var:
com_var = vcs $(VCS_MACRO_OPT) -timescale=1ns/10ps  +v2k -sverilog $(fgp_compile) -full64 -l compile.log -licqueue -kdb -lca +error+100 \
	+sdfverbose \
	+lint=PCWM \
	+lint=TFIPC-L \
	+lint=PCWM \
	-P ${VERDI_HOME}/share/PLI/VCS/linux64/novas.tab  \
	${VERDI_HOME}/share/PLI/VCS/linux64/pli.a \
	$(init_reg_cfg) \
    $(uvm_package) \
	$(spec) \
	$(loop_opt) \
	$(dump_vcs) \
	$(compile_option) \
	$(cm_para_comp) \
	$(vcs_para) \
	$(define_para) \
	$(timingcheck_para) \
	$(simprofile_opt) \
	$(sim_define_option) \
	$(list_para) \
	$(vip_comp_para) \
	-top tb_top

simv_var = simv +vcs+lic+wait -ucli -l sim.log +ntb_stop_on_constraint_solver_error=1 -assert quiet+report \
	$(dump_simv) $(fsdb_force) $(uvm_para) $(gui_option) +ntb_random_seed=$(SEED) $(cm_para_sim) $(fgp_para) \
	$(simv_opt) $(vip_sim_para)$(xprop_sim) $(init_reg_cfg) $(dpo_sim_para)

com_echo:
	echo -e "#!/bin/bash\n\n"  $(com_var) > com_cmd; chmod +x com_cmd
simv_echo:
	echo -e "#!/bin/bash\n\n"  $(simv_var) > simv_cmd; chmod +x simv_cmd

run_com:
	com_cmd | tee compile.log

run_simv:
	simv_cmd | tee sim.log
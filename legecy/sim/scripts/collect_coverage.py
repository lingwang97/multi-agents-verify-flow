#!/usr/bin/python3
# -*- coding: utf-8 -*-

#This script is for collect coverage
#date: 08/28/2024
#author:Brent Wang

import os
import re
import sys
import time
import threading
import subprocess

without_mdl_module_name = ["mx2_block_negative","mx2_block","self_top","ft","ro","efuse","work","mx2","jls","rst","io","spd_gbp","spd_lfb","spd_smp","spd_ada","uart","uart_vip","reg"]
with_mdl_module_name = ["pvt","cpm"]
current_directory = '.'
covered_dirs = []
cover_dir = "./coverage"
def gen_log(log):
    with open("./coverage/coverage.log", "w") as file:
        file.write(log)
processes = []
cover_log = "**************This is collect coverage log file for ./scripts/collect_coverage.py****************\n"
def gen_without_mdl_vdb_file(path,name):
    global cover_log
    vdb_str=""
    for item in os.listdir(path):
        if name in item:
            pattern = r'uvm_scratch_(\S+)_\d+_\d+_\d+_\d+_\d+_\d+___RTL$'
            match_pan = re.match(pattern,item)
            if match_pan and (name == match_pan.group(1)):
                item_path = os.path.join(path, item)
                process = subprocess.Popen(['bsub', '-n','1', '-q','a7t83','-I','urg','-dir',f'{item_path}/*_sim_*/*.vdb','-dbname',f'coverage/{name}.vdb'])
                time.sleep(2)
                processes.append(process)
                cover_log +="Collecting "+name+" coverage\n"
                covered_dirs.append(name)
                

def gen_with_mdl_vdb_file(path,name):
    global cover_log
    mdl_vdb_str=""
    sys_vdb_str=""
    for item in os.listdir(path):
        if name in item:
            pattern = r'uvm_scratch_(\S+)_\d+_\d+_\d+_\d+_\d+_\d+___RTL$'
            match_pan = re.match(pattern,item)
            if match_pan and (name == match_pan.group(1)):
                item_path = os.path.join(path, item)
                if os.path.isdir(item_path):
                    for sub_item in os.listdir(item_path):
                        sub_item_path = os.path.join(item_path, sub_item)
                        if os.path.isdir(sub_item_path):
                            if sub_item.startswith("FAKECORE") or sub_item.startswith("REALCORE"):
                                if "_mdl_" in sub_item:
                                    if os.path.exists(sub_item_path+"/simv.vdb"):
                                        mdl_vdb_str += sub_item_path+"/simv.vdb"+" "        
                                    else:
                                        cover_log += "Error:"+sub_item_path+"/simv.vdb is not exit !!!\n"
                                else:
                                    if os.path.exists(sub_item_path+"/simv.vdb"):
                                        sys_vdb_str += sub_item_path+"/simv.vdb"+" "        
                                    else:
                                        cover_log += "Error:"+sub_item_path+"/simv.vdb is not exit !!!\n"
    return (mdl_vdb_str,sys_vdb_str)


if not os.path.exists(cover_dir):
    os.makedirs(cover_dir)
else:
    print("DIR: "+cover_dir+" is exit !!!,please remove it")
    exit()

########################This is for without mdl coverage##############################
for name in without_mdl_module_name:
    print("Collect coverage for module(without mdl) : ",name)
    gen_without_mdl_vdb_file(current_directory,name)
    

#########################This is for with mdl coverage##############################
for name in with_mdl_module_name:
    print("Collect coverage for module(with mdl) : ",name)
    mdl_cover_vdb_str ,sys_cover_vdb_str= gen_with_mdl_vdb_file(current_directory,name)
    if(mdl_cover_vdb_str == "" and sys_cover_vdb_str == "" ):
        print(name,"is not exit!!")
        cover_log += "Error: module "+name+" file is not exit !!!\n"
    else:
        if(name == "cpm"):
            name = "crg"
            process = subprocess.Popen(['bsub', '-n','1', '-q','a7t83','-I','urg','-dir',f'{sys_cover_vdb_str}',f'{mdl_cover_vdb_str}','-dbname',f'coverage/{name}.vdb','-map','crg'])
        if(name == "pvt"):
            process = subprocess.Popen(['bsub', '-n','1', '-q','a7t83','-I','urg','-dir',f'{sys_cover_vdb_str}',f'{mdl_cover_vdb_str}','-dbname',f'coverage/{name}.vdb','-map','pvt_top'])
        time.sleep(2)
        processes.append(process)
        cover_log +="Collecting "+name+" coverage\n"
        covered_dirs.append(name)
#########################wait module collect coverage finish##############################
gen_log(cover_log)
for process in processes:
    process.wait()
cover_log += "Module coverage is finish\n"
gen_log(cover_log)
#check coverge dir
cover_log +="Check coverage dir...\n"
merge_module_name = without_mdl_module_name + with_mdl_module_name
for item in merge_module_name:
    if item+".vdb" in os.listdir("./coverage"):
        print(item,"is exit.")
    else:
        cover_log +=""+item+".vdb is not exit\n"

gen_log(cover_log)
btc_cover_vdb_str = ""
for vdb_file in covered_dirs:
    if vdb_file != "reg" and vdb_file != "pvt":
        btc_cover_vdb_str += "coverage/"+vdb_file+".vdb "
#system vdb must be in the first !!!!!!!!
btc_cover_cmd = "urg -dir coverage/pvt.vdb "+btc_cover_vdb_str+" -dbname coverage/btc.vdb"
cover_log += "Collecting btc coverage ...\n"
cover_log += btc_cover_cmd+"\n"
gen_log(cover_log)
os.system(btc_cover_cmd)
print("Btc coverage is finish!")
cover_log += "Btc coverage is finish!\n"
gen_log(cover_log)

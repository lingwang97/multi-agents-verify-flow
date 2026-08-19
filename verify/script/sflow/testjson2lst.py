import os
os.environ['OPENBLAS_NUM_THREADS'] = '1'
import json
from optparse import OptionParser
import sys
import re

filename="./test.json"

def getDesignCoreNum(chipDefineFile):
  design_core_pattern=".*((SLICE([0-9]+))|(DEMI))+_CORE_NUM\s*[0-9]+'d([0-9]+)*"
  total_core_num=0
  with open(chipDefineFile,"r") as define_f:
    while(True):
      line=define_f.readline()
      if not line:
        break
      design_core_match = re.match(design_core_pattern, line)
      if design_core_match:
        #print(design_core_match)
        print("groups",design_core_match.groups()[-1])
        total_core_num+=int(design_core_match.groups()[-1])
  print("total_core_num:",total_core_num)
  return total_core_num

class JsonHighLevelStruct():
  uvmMacroOpt="UVM_VCS_MACRO_OPT"
  globalMacroOpt="GLOBAL_VCS_MACOR_OPT"
  realCoreOpt="REAL_CORE_OPT"
  modules="modules"

class moduleStruct():
  name="name"
  commonMacroOpt="COMMON_VCS_MACRO_OPT"
  tests="tests"

class testStruct():
  module="module"
  stage1="stage1"
  stage2="stage2"
  smoke="smoke"
  full="full"
  codecoverage="codecoverage"
  iteration="iteration" 
  uvmTestName="UVM_TESTNAME"
  macroOpt="VCS_MACRO_OPT"
  plusArgs="VCS_PLUSARGS_OPT"

ymlJobFormat="\
{module} {index}/{total} [{case}]:\n\
  extends: template\n\
{stageFormat}\
{scheduleFormat}\
  script:\n\
    - ./uvm_case.sh {case} {option}\n\
  interruptible: {interruptible}\n\
  rules: \n\
    - !reference [.default_rules, rules]\n"

stageFormat="\
  stage: {stage}\n"
scheduleOnly="\
  stage: stage2\n\
  rules: \n\
    - !reference [.default_rules, rules]\n\
    - if: $CI_PIPELINE_SOURCE != \"schedule\"\n\
      when: never\n"
scheduleExcept="\
  rules: \n\
    - !reference [.default_rules, rules]\n\
    - if: $CI_PIPELINE_SOURCE == \"schedule\"\n\
      when: never\n"

modules=[]
uvmMacroOpt=""
globalMacroOpt=""

#compile_command="make"

def writeYml(module_file, f, name):
  with open(module_file,"r") as module_f:
    module=json.load(module_f)
  module_f.close()
  tests = module[moduleStruct.tests]
  stage1_index = 0
  stage2_index = 0
  schedule_index = 0
  stage1_total = 0
  stage2_total = 0
  schedule_total = 0
  for key in tests:
    if "#" in key:
      continue
    if "gate_only" in tests[key]:
      if tests[key]["gate_only"] == "true":
        continue
    if tests[key][testStruct.stage1] == "true":
      stage1_total += 1
    elif tests[key][testStruct.stage2] == "true":
      stage2_total += 1
    else:
      schedule_total += 1
    
  for key in tests:
    if "#" in key:
      continue
    if "gate_only" in tests[key]:
      if tests[key]["gate_only"] == "true":
        continue
    case=key
    option=""
    if "fpga" in name:
      option="-fpga"
    if "mx2_block" in name:
      option="-block"
    if tests[key][testStruct.stage1] == "true":
      stage1_index += 1
      stage=stageFormat.format(stage=testStruct.stage1)
      schedule=scheduleExcept
      interruptible = "true"
      f.write(ymlJobFormat.format(module=name,case=case,index=stage1_index, total=stage1_total,stageFormat=stage,scheduleFormat=schedule,option=option,interruptible=interruptible))
    elif tests[key][testStruct.stage2] == "true":
      stage2_index += 1
      stage=stageFormat.format(stage=testStruct.stage2)
      schedule=""
      interruptible="true"
      f.write(ymlJobFormat.format(module=name,case=case,index=stage2_index, total=stage2_total,stageFormat=stage,scheduleFormat=schedule,option=option,interruptible=interruptible))
    else:
      schedule_index += 1
      stage=""
      schedule=scheduleOnly
      interruptible="false"
      f.write(ymlJobFormat.format(module=name,case=case,index=schedule_index, total=schedule_total,stageFormat=stage,scheduleFormat=schedule,option=option,interruptible=interruptible))
    f.write("\n")

def writeModule(module_file, regression_type,f,name,gls_mode):
  global uvmMacroOpt
  global globalMacroOpt
  macros=[]
  with open(module_file,"r") as module_f:
    module=json.load(module_f)
  module_f.close()
  if not name == module[moduleStruct.name]:
    print("ERROR: the name in "+module_file+" is not the same as "+name+". Please check "+module_file)
    exit(1)
  tests = module[moduleStruct.tests]
  
  for item in module[moduleStruct.commonMacroOpt].split("+"):
    macros.append(item)
  for key in tests:
    if "#" in key:
      continue

    if not regression_type == testStruct.module:
      if not (tests[key][regression_type] == "true"):
        continue

    #gate level simulation define
    netlist = ""
    if gls_mode:
      if not "gate_post_sim" in tests[key]:
        continue
      elif tests[key]["gate_post_sim"] != "true":
        continue

      if "core_netlist" in tests[key]:
        if tests[key]["core_netlist"] == "true":
          netlist = " core_netlist=1"
    else:
      if "gate_only" in tests[key]:
        if tests[key]["gate_only"] == "true":
          continue

    block_level=""
    if name == "mx2_block":
      block_level = " BLOCK_TEST=1"

    dpo_sub_name=""
    mudue_name="mudue_name="+module[moduleStruct.name]+" "
    testname="testname="+key+" "
    if (option.dpo_status != "learn"):
      iteration=" iter="+tests[key][testStruct.iteration]+" "
    else:
      iteration=" iter=1 "
    uvmtestname=" UVM_TESTNAME="+tests[key][testStruct.uvmTestName]
    testOpt=module
    vcsOpt = " VCS_MACRO_OPT=\'+define" + uvmMacroOpt + globalMacroOpt + module[moduleStruct.commonMacroOpt] + tests[key][testStruct.macroOpt] + "\'"
    if "exclude" in tests[key]:
      vcsOpt = vcsOpt.replace(tests[key]["exclude"], "")
    for item in tests[key][testStruct.macroOpt].split("+"):
      # print("tests: item", item,"macros:",macros)
      if not (item in macros):
        macros.append(item)
    if("DPO_SUB_NAME" in vcsOpt):
      dpo_sub_name=re.search("DPO_SUB_NAME.*=\w+",vcsOpt).group(0).split("=")[1]
      dpo_sub_name="dpo_sub_name=_"+dpo_sub_name+" "
    
    plusArgs="" if tests[key][testStruct.plusArgs] == "" else " VCS_PLUSARGS_OPT="+tests[key][testStruct.plusArgs]
    coverage=" cm=1" if tests[key][testStruct.codecoverage] == "true" else ""
    line=testname+iteration+mudue_name+dpo_sub_name+uvmtestname+coverage+vcsOpt+plusArgs+netlist+block_level
    #line=testname+iteration+mudue_name+dpo_sub_name+compile_command+uvmtestname+coverage+vcsOpt+plusArgs+netlist+block_level
    f.write(line)
    f.write("\n")

  f2 = open(name+"macros", "a+")
  for item in macros:
    f2.write(item+"\n")

def writeTest(mudue_name,testcase,moduleCommonOpt,f,name):
  global uvmMacroOpt
  global globalMacroOpt
  uvmtestname=" UVM_TESTNAME="+testcase[testStruct.uvmTestName]
  dpo_sub_name=""
  
  if (option.dpo_status != "learn"):
    iteration=" iter="+testcase[testStruct.iteration]+" "
  else:
    iteration=" iter=1 "
    
  vcsOpt = " VCS_MACRO_OPT=\'+define" + uvmMacroOpt + globalMacroOpt + moduleCommonOpt + testcase[testStruct.macroOpt] + "\'"
  if "exclude" in testcase:
    vcsOpt=vcsOpt.replace(testcase["exclude"],"")
  if("DPO_SUB_NAME" in vcsOpt):
    dpo_sub_name="_"+re.search("DPO_SUB_NAME.*=\w+",vcsOpt).group(0).split("=")[1]

  plusArgs="" if testcase[testStruct.plusArgs] == "" else " VCS_PLUSARGS_OPT="+testcase[testStruct.plusArgs]
  coverage=" cm=1" if testcase[testStruct.codecoverage] == "true" else ""
  line="testname="+name+iteration+"mudue_name="+mudue_name+" dpo_sub_name="+dpo_sub_name+uvmtestname+coverage+vcsOpt+plusArgs
  #line="testname="+name+iteration+"mudue_name="+mudue_name+" dpo_sub_name="+dpo_sub_name+" make"+uvmtestname+coverage+vcsOpt+plusArgs
  f.write(line)
  f.write("\n")

if __name__=="__main__":
  ## initialize the Optionparser
  usage="%prog [options] arg1 arg2\nPlease check -h for usage\n"
  parser=OptionParser(usage=usage)
  ## parse whether there is a given input json file
  parser.add_option('-f',action='store',type="string",dest="filename",help="put the target json file")
  ## parse whether there is a chip_define file
  parser.add_option('--define',action='store',type="string",dest="chip_define",help="put chip_define.sv file")
  ## parse whether single case to be executed
  parser.add_option('-c',action='store',type="string",dest="testcase",help="put the testcase you want to running")
  ## parse whether command want to run in module-wise
  parser.add_option('-m',action='store',type="string",dest="module",help="btc module, including "+str(modules))
  ## parse whether command want to have a specific output path
  parser.add_option('-o',action='store',type="string",dest="output", help="write output to specified file")
  ## parse whether command want to run with real core
  parser.add_option('--real',action='store_true',dest="realcore", help="define macro to run real core")
  ## parse whether command wants to run in smoke stage1
  parser.add_option('--stage1', action='store_true',dest="smoke_stage1", help="find out all tests that expected to run in smoke stage1")
  ## parse whether command wants to run in smoke stage2
  parser.add_option('--stage2', action='store_true',dest="smoke_stage2", help="find out all tests that expected to run in smoke stage2")
  ## parse whether command wants to run in smoke
  parser.add_option('--smoke', action='store_true', dest="smoke", help="find out all tests that expected to run in smoke")
  ## parse whether command wants to run in full regression
  parser.add_option('--full', action='store_true', dest="full", help="find out all tests that expected to run full regression")
  ## parse whether command wants to run with level
  parser.add_option('-l', action='store', type="string", dest="level", help="decide whether need to run in gate/post level simulation")
  ## dpo status
  parser.add_option('--dpo', action='store', type="string", dest="dpo_status", help="decide what dpo status is")
  ## parse project
  parser.add_option('--project', action='store', type="string", dest="project", help="store project name")
  option, args = parser.parse_args(sys.argv)

  if (option.filename is not None):
    filename=option.filename
  filepath=os.path.dirname(os.path.realpath(filename))+"/"
  print("filepath:",filepath)
  # print("filename:",filename)

  with open(filename,'r') as load_f:
    load_dict = json.load(load_f)
  load_f.close()
  total_core_num=getDesignCoreNum(option.chip_define)
  if(32*total_core_num > 1408):
    uvmMacroOpt=load_dict[JsonHighLevelStruct.uvmMacroOpt]+"+UVM_REG_DATA_WIDTH="+str(32*total_core_num)+"+UVM_HDL_MAX_WIDTH="+str(32*total_core_num)
  else:
  	uvmMacroOpt=load_dict[JsonHighLevelStruct.uvmMacroOpt]+"+UVM_REG_DATA_WIDTH=1408"+"+UVM_HDL_MAX_WIDTH=1408"
  #print(uvmMacroOpt)
  globalMacroOpt=load_dict[JsonHighLevelStruct.globalMacroOpt]
  if option.realcore :
    globalMacroOpt+=load_dict[JsonHighLevelStruct.realCoreOpt]
  modules = load_dict[JsonHighLevelStruct.modules]
  #print("modules:",modules)
  project_name=option.project

  GLS_mode = False
  if (option.level == "gate" or option.level == "post"):
    GLS_mode = True
  print("GLS_mode:",GLS_mode)

  singleTestMode=False
  if (option.testcase is not None):
    singleTestMode=True
    testcase=option.testcase

  FullMode=True
  #print("option.module is: ",option.module)
  if (option.module is not None):
    if not option.module in modules:
      print("ERROR: from "+__file__+" please check the module name to be correct or not.")
      print("current available module are ", modules)
      exit(1)
    FullMode=False
    targetmodule=option.module

  output="./fullUvmTest.list"
  if option.output is not None:
    output=option.output
  f = open(output,"a+")

  
## decide which regression set want to run, default will be smoke
  regression_type=testStruct.module
  if option.smoke_stage1:
    regression_type=testStruct.stage1
  elif option.smoke_stage2:
    regression_type=testStruct.stage2
  elif option.smoke:
    regression_type=testStruct.smoke
  elif option.full:
    regression_type=testStruct.full

  if not FullMode:
    #single module regression
    if targetmodule in modules:
      f.write("//"+targetmodule+"\n")
      print("current regression module:",modules[targetmodule])
      module_file=filepath+modules[targetmodule]
      writeModule(module_file, regression_type, f, targetmodule,GLS_mode)

  else:
    casefound=False
    for key in modules:
      if "#" in key:
        continue
      module_file=filepath+modules[key]
      if singleTestMode:
        with open(module_file,"r") as module_f:
          print("module file open is:"+module_file)
          module=json.load(module_f)
        module_f.close()
        if not key == module[moduleStruct.name]:
          print("ERROR: the "+module[moduleStruct.name]+" in "+module_file+" is not the same as "+key+". Please check "+module_file)
          exit(1)
        mudue_name=module[moduleStruct.name]
        if not testcase in module[moduleStruct.tests]:
          casefound=False
        else:
          casefound=True
          f.write("//"+testcase+"\n")
          writeTest(mudue_name,module[moduleStruct.tests][testcase], module[moduleStruct.commonMacroOpt],f,testcase)
          break
      else:
        #all module regression
        f.write("//"+key+"\n")
        writeModule(module_file, regression_type, f, key, GLS_mode)

    if singleTestMode and not casefound:
      print("ERROR: from file (" + __file__ + ") " + testcase + " is not in the test.json file")
      exit(1)
  f.close()


  ##yml generation
  # output=os.path.dirname(os.path.abspath(__file__))+"/.gitlab-ci-case.yml"
  # f_yml = open(output, "w")
  # f_yml.write("include:\n")
  # for key in modules:
  #   if "#" in key:
  #     continue
  #   f_yml.write(" - '"+project_name+"/verify/uvm/test/.gitlab-ci-case-"+key+".yml'\n")
  #   module_file=filepath+modules[key]
  #   module_yml=open(os.path.dirname(os.path.abspath(__file__))+"/.gitlab-ci-case-"+key+".yml","w")
  #   writeYml(module_file, module_yml, key)
  #   module_yml.close()
  # f_yml.close()
#!/bin/bash

OPTS_LSF="TRUE"
OPTS_LSF_QUEUE="m7763"
OPTS_LSF_CORES="1"

# -r: reg module not merge
# -h: help
optname="opt_no"
while [ $# -gt 0 ]
do
{
  case "$1" in
    -r|--reg)
      optname="opt_reg"
      echo "reg module coverage will not be merged."
      ;;
    -h|--help)
      echo "-r/--reg    : reg module coverage will not be merged."
      echo "no option   : merge all module, except mx2_block."
      exit
      ;;
  esac
  shift
}
done

host=$(env | grep "^HOST=" | head -n 1 | cut -d '-' -f 3)
echo "host is ${host}"
bsub_option=""
if [[ ${host} == cch* ]]; then
  OPTS_LSF="FALSE"
  echo "OPTS_LSF is ${OPTS_LSF} due to host is not gat."
fi
if [[ ${OPTS_LSF} == "TRUE" ]]; then
  m7773x_max=2560
  m7763_max=1280
  m7773x_running_jobs=`bqueues -o "queue_name njobs delimiter=':'" | grep m7773x | cut -d ":" -f 2`
  m7763_running_jobs=`bqueues -o "queue_name njobs delimiter=':'" | grep m7763 | cut -d ":" -f 2`
#  echo "m7773x has run jobs $m7773x_running_jobs $(($m7773x_max-$m7773x_running_jobs))"
#  echo "m7763 has run jobs $m7763_running_jobs $(($m7763_max-$m7763_running_jobs))"
  if [[ $(($m7773x_max-$m7773x_running_jobs)) -gt $(($m7763_max-$m7763_running_jobs)) ]]; then
    OPTS_LSF_QUEUE="m7773x"
  else
    OPTS_LSF_QUEUE="m7763"
  fi
  bsub_option="bsub -n ${OPTS_LSF_CORES} -I -q ${OPTS_LSF_QUEUE}"
fi

filename=$(ls)
number=0
for file in ${filename}; do
{
  if [[ ${file} == uvm_scratch_* ]]; then
    let number=${number}+1
    module=$(echo $file | cut -d '_' -f 3)
    addition=$(echo $file | cut -d '_' -f 4)
    if [[ ${addition} == "block" || ${addition} == "fpga" ]]; then
      module=${module}_${addition}
    fi

    if [[ ${module} == mx2_block ]]; then
      echo "${number}: ${module} coverage collection."
      ${bsub_option} urg -dir ${file}/*_sim_*/*.vdb -dbname ${module}_cov.vdb >mx2_block_cov.log 2>&1 &

    elif [[ ${optname} == opt_reg && ${module} == reg ]]; then
      echo "${number}: ${module} coverage is not collected."

    else
      echo "${number}: ${module} coverage collection."
      ${bsub_option} urg -dir ${file}/*_sim_*/*.vdb -dbname ${file}/cov_${module}.vdb >${file}/cov_log.log 2>&1 &
    fi
    echo ""
  fi 
}
done

wait
case ${optname} in
  opt_no)
    echo "Weekly coverage collection, except mx2_block."
    ${bsub_option} urg -dir uvm_scratch_*/cov_*.vdb -dbname cov_weekly.vdb >cov_log.log 2>&1
    ;;
  opt_reg)
    echo "Weekly coverage collection, except mx2_block and reg."
    ${bsub_option} urg -dir uvm_scratch_*/cov_*.vdb -dbname cov_weekly.vdb >cov_log.log 2>&1
    ;;
esac



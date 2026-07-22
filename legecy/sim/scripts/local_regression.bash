#!/bin/bash

sim_opt=""
# -t/time: calculate vcs sim time
# -h: help
while [ $# -gt 0 ]
do
{
  case "$1" in
    -t|--time)
      time_opt="-profile time"
      echo "Regression will calculate simulation time."
      ;;
    -h|--help)
      echo "-t/--time   : Regression will calculate simulation time."
      echo "no option   : Local regression."
      exit
      ;;
  esac
  shift
}
done

sim_opt="${time_opt}"

sim_opt="-q n4a83"

###################################################
#############total 23 module case##################
###################################################

#####################regression 1####################
#./msim -m work -uvm ${sim_opt}&
#./msim -m self_top -uvm ${sim_opt}&
#./msim -m mx2_block -uvm ${sim_opt}&
#./msim -m spd_ada -uvm ${sim_opt}&
#sleep 6h
#./msim -m mx2_block_negative -uvm ${sim_opt}&
#./msim -m mx2 -uvm ${sim_opt}&
#./msim -m reg -uvm ${sim_opt}&
#./msim -m uart -uvm ${sim_opt}&
#./msim -m dfx -uvm ${sim_opt}&
#sleep 6h
#######################regression 2####################
#./msim -m spd_smp -uvm ${sim_opt}&
#./msim -m efuse -uvm ${sim_opt}&
#./msim -m pvt -uvm ${sim_opt}&
#sleep 6h
#./msim -m fpga -uvm ${sim_opt} &
#./msim -m jls -uvm ${sim_opt}&
#./msim -m ro -uvm ${sim_opt}&
#./msim -m cpm -uvm ${sim_opt}&
#./msim -m ft -uvm ${sim_opt}&
#sleep 6h
#########################regression 3####################
#./msim -m spd_gbp -uvm ${sim_opt}&
#./msim -m rst -uvm ${sim_opt}&
#./msim -m mc -uvm ${sim_opt}&
#sleep 6h
#./msim -m io -uvm ${sim_opt}&
#./msim -m uart_vip -uvm ${sim_opt}&
#./msim -m spd_lfb -uvm ${sim_opt}&
#
##################wangling############
#./msim -m spd_smp -uvm ${sim_opt}&
#./msim -m spd_ada -uvm ${sim_opt}&
#./msim -m reg -uvm ${sim_opt}&
#./msim -m efuse -uvm ${sim_opt}&
######################zhongyi####################
./msim -m work -uvm ${sim_opt}&
./msim -m mx2_block -uvm ${sim_opt}&
./msim -m uart -uvm ${sim_opt}&
./msim -m jls -uvm ${sim_opt}&
######################yaqing####################
./msim -m mx2_block_negative -uvm ${sim_opt}&
./msim -m mx2 -uvm ${sim_opt}&
./msim -m dfx -uvm ${sim_opt}&
./msim -m ro -uvm ${sim_opt}&
./msim -m self_top -uvm ${sim_opt}&
######################sirui####################
./msim -m pvt -uvm ${sim_opt}&
./msim -m spd_lfb -uvm ${sim_opt}&
./msim -m fpga -uvm ${sim_opt} &
./msim -m cpm -uvm ${sim_opt}&
./msim -m io -uvm ${sim_opt}&
./msim -m uart_vip -uvm ${sim_opt}&
########################wangjianli####################
./msim -m spd_gbp -uvm ${sim_opt}&
./msim -m rst -uvm ${sim_opt}&
./msim -m mc -uvm ${sim_opt}&
./msim -m ft -uvm ${sim_opt}&

# This script is used to compare the efficiency of the following:
# scalar reorder of data based on a split
# vector reorder of data based on a split
# rsorting  data based on a split
#!/bin/bash
#max_n=33554432
max_n=16777216
max_nT=4
max_mode=3

n=65536
while [ $n -le $max_n ]; do
  nT=1
  while [ $nT -le $max_nT ]; do
    mode=1
    while [ $mode -le $max_mode ]; do
      # echo "n = $n, nT = $nT, mode = $mode"
      ./ut_mt_reorder $n $nT $mode
      mode=` echo "$mode + 1" | bc `; 
    done
    nT=` echo "$nT + 1" | bc `; 
  done
  n=` echo "$n * 2" | bc `; 
done
  

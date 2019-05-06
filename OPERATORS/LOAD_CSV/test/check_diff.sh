#!/bin/bash
iter=1
N=1024
bigfile="../../../DATA_SETS/MNIST/mnist/train_data.csv"
while [ $iter -le $N ]; do
  filename="./_test_files/_f${iter}.bin"
  test -f $filename
  cut -f $iter -d "," $bigfile > _temp.csv
  ../../../UTILS/src/asc2bin _temp.csv I2 _temp.bin
  cmp _temp.bin $filename
  echo "done $iter"
  iter=`expr $iter + 1`
done

#for i in {1..1024}
#do
#  filename="./_test_files/_f$i.bin"
#  cat $bigfile | awk -F"," -v I=$i '{print $I}' > "_temp.csv"
#  ../../../UTILS/src/asc2bin _temp.csv I4 _temp.bin
#  cmp _temp.bin $filename
#  echo "done $i"
#done

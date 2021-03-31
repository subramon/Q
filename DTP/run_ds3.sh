#!/bin/bash
set -e 
num_nodes=16055
num_features=54
tree=./data/DS3/tree.csv 
meta=./data/DS3/meta.csv 
counts=./data/DS3/counts.csv 
meta_bin=./data/DS3/meta.bin 
counts_bin=./data/DS3/counts.bin 
./dtp $num_nodes $num_features $tree $meta $counts $meta_bin $counts_bin

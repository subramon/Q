#!/bin/bash
set -e 
num_nodes=3
num_features=4
tree=./data/DS1/tree.csv 
meta=./data/DS1/meta.csv 
counts=./data/DS1/counts.csv 
meta_bin=./data/DS1/meta.bin
counts_bin=./data/DS1/counts.bin
./dtp $num_nodes $num_features $tree $meta $counts $meta_bin $counts_bin

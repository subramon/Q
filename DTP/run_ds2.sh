#!/bin/bash
set -e 
num_nodes=7259
num_features=54
tree=./data/DS2/tree.csv 
meta=./data/DS2/meta.csv 
counts=./data/DS2/counts.csv 
meta_bin=./data/DS2/meta.bin
counts_bin=./data/DS2/counts.bin 
./dtp $num_nodes $num_features $tree $meta $counts $meta_bin $counts_bin

#!/bin/bash
set env -e 
pushd .
cd $Q_SRC_ROOT/UTILS/build/
make
popd
bash test_print_csv.sh 

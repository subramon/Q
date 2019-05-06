#!/bin/bash
set -e 
## Calculate Q.vvadd total execution time
test -d $Q_SRC_ROOT
cd $Q_SRC_ROOT/UTILS/build/
make clean
export QC_FLAGS=" -O4 $QC_FLAGS"
make
cd $Q_SRC_ROOT/experimental/q_performance_testing
time luajit test_vvadd.lua
# You will get something like 
# vvadd total execution time : 6.752498
# =========================
# real  0m6.943s
# user  0m4.689s
# sys 0m2.229s
# =========================
# TODO KRUSHNAKANT: Connvert following into a script like above
## Calculate vvadd C execution time

# Copy Q/experimental/q_performance_testing/init.lua to Q/init.lua
# Copy Q/experimental/q_performance_testing/expander_f1f2opf3.lua to Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3.lua
# run test
# cd Q/experimental/q_performance_testing
# luajit test_vvadd.lua

#.g
# root@ubuntu:/opt/zbstudio/myprograms/Q/experimental/q_performance_testing# luajit test_vvadd.lua
# vvadd total execution time : 22.44
# =========================
# vvadd_I4_I4_I4  0.522636

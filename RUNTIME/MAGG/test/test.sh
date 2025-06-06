#/bin/bash
set -e 
INCS=" -I../../../UTILS/inc "
VG="valgrind  --leak-check=full --show-leak-kinds=all "
VG=""
#-------------------
export QC_FLAGS=" -g $QC_FLAGS"
cd ../lua && luajit gen_so.lua test1 && cd -
gcc -g  ${INCS} $QC_FLAGS test1.c $Q_ROOT/lib/libaggtest1.so \
    -I../xgen_inc/ -I../inc
$VG  ./a.out
#-------------------
cd ../lua && luajit gen_so.lua test2 && cd -
gcc -g  ${INCS} $QC_FLAGS test2.c $Q_ROOT/lib/libaggtest2.so -I../xgen_inc/ -I../inc
$VG  ./a.out
#-------------------
cd ../lua && luajit gen_so.lua test2 && cd -
gcc -g ${INCS}  $QC_FLAGS test2n.c $Q_ROOT/lib/libaggtest2.so -I../xgen_inc/ -I../inc
$VG  ./a.out
#-------------------
gcc -g ${INCS} $QC_FLAGS test_fastdiv.c -I../inc/
$VG  ./a.out

echo SUCCESS

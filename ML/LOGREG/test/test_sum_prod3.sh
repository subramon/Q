gcc -O4 $QC_FLAGS test_sum_prod3.c ../src/vanilla_sum_prod3.c \
  ../src/sum_prod3.c ../../../UTILS/src/rdtsc.c \
  -I../inc/ -I../../../UTILS/inc/ -I../../../UTILS/gen_inc/ \
  -lpthread -lgomp
./a.out
rm -f ./a.out

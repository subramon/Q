#/bin/bash
set -e
# Add -DDEBUG for debugging
gcc -O4 -std=gnu99 -Wall \
  degree_histo.c \
  qsort_asc_I4.c  \
  ../../../UTILS/src/mmap.c  \
  ../../../UTILS/src/rdtsc.c  \
  -I../../../UTILS/inc/  \
  -I../../../UTILS/gen_inc/ 
echo "Built"
maxid=124900000
echo ./a.out ../data/efile _node_id _degree $maxid
./a.out ../data/efile _node_id _degree $maxid
echo "Done"

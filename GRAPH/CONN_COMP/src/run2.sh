#/bin/bash
set -e
gcc -g -std=gnu99 -Wall -fopenmp \
  conn.c \
  ../../../UTILS/src/mmap.c  \
  ../../../UTILS/src/rdtsc.c  \
  -I../../../UTILS/inc/  \
  -I../../../UTILS/gen_inc/ \
  -lpthread -lgomp
echo "Built"
maxid=124900000
echo ./a.out ../data/efile _node_id _degree $maxid
./a.out ../data/efile _node_id _degree $maxid
echo "Done"

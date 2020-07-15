gcc -O4 -I../../../UTILS/inc/ -std=c99 qsort2_asc_I4_basic.c -o qsort2_asc_I4_basic.o
gcc -O4 -I../../../UTILS/inc/ -fPIC -std=gnu99 -shared  qsort2_asc_I4_basic.c -o qsort2_asc_I4_basic.so

./qsort2_asc_I4_basic.o

rm qsort2_asc_I4_basic.o

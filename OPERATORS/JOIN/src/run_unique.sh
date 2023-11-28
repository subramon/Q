gcc -O4 -I../../../UTILS/inc/ -std=c99 unique.c -o unique.o
gcc -O4 -I../../../UTILS/inc/ -fPIC -std=gnu99 -shared  unique.c -o unique.so

./unique.o

rm unique.o

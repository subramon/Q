
gcc -g -I$Q_SRC_ROOT/UTILS/inc/ -I$Q_SRC_ROOT/OPERATORS/GETK/inc/ -std=c99 mink.c -o mink.o
# gcc -O4 -I$Q_SRC_ROOT/UTILS/inc/ -I$Q_SRC_ROOT/OPERATORS/GETK/inc/ -fPIC -std=gnu99 -shared  mink.c -o mink.so

./mink.o

#rm mink.o


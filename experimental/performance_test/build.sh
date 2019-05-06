gcc -O4 -fPIC -std=gnu99 -shared  add.c -o libadd.so

gcc -std=c99 -O4 -Wall -shared -fPIC -o add.so -I. -I/usr/include/lua5.1 -llua5.1 add_wrapper.c add.c

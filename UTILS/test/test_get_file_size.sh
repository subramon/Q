#!/bin/bash
set -e 
gcc  -g test_get_file_size.c ../src/get_file_size.c -std=gnu99 -I../inc/ -I../gen_inc/ 
valgrind --track-origins=yes --leak-check=full ./a.out 
echo "SUCCESS for $0"

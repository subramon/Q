#!/bin/bash
set -e
# Clean output files
rm rslt_test_test_copy_file.c rslt_test_dictionary.lua
gcc  -g test_copy_file.c ../src/copy_file.c ../src/buf_to_file.c ../src/get_file_size.c -std=gnu99 -I../inc/ -I../gen_inc/ -lm
valgrind --track-origins=yes --leak-check=full ./a.out test_copy_file.c rslt_test_test_copy_file.c
valgrind --track-origins=yes --leak-check=full ./a.out test_dictionary.lua rslt_test_dictionary.lua
echo "SUCCESS for $0"
# Remove output files
rm rslt_test_test_copy_file.c rslt_test_dictionary.lua

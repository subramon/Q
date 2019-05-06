#!/bin/bash
set -e 
UDIR=${Q_SRC_ROOT}/UTILS/lua
test -d $UDIR
rm -rf ../gen_inc/; mkdir -p ../gen_inc/
rm -rf ../gen_src; mkdir -p ../gen_src
lua $UDIR/cli_extract_func_decl.lua mmap.c ../gen_inc
lua $UDIR/cli_extract_func_decl.lua is_valid_chars_for_num.c ../gen_inc
lua $UDIR/cli_extract_func_decl.lua f_mmap.c ../gen_inc
lua $UDIR/cli_extract_func_decl.lua f_munmap.c ../gen_inc
lua $UDIR/cli_extract_func_decl.lua bytes_to_bits.c ../gen_inc
lua $UDIR/cli_extract_func_decl.lua bits_to_bytes.c ../gen_inc
lua $UDIR/cli_extract_func_decl.lua get_bit.c ../gen_inc
lua $UDIR/cli_extract_func_decl.lua set_bit.c ../gen_inc
lua $UDIR/cli_extract_func_decl.lua clear_bit.c ../gen_inc
lua $UDIR/cli_extract_func_decl.lua copy_bits.c ../gen_inc
lua $UDIR/cli_extract_func_decl.lua write_bits_to_file.c ../gen_inc
lua $UDIR/cli_extract_func_decl.lua get_bits_from_array.c ../gen_inc
lua bin_search_generator.lua
#--------
# TODO: Improve below
rm -f _x
echo "mmap.c " >> _x
echo "is_valid_chars_for_num.c " >> _x
echo "f_mmap.c " >> _x
echo "f_munmap.c " >> _x
echo "get_bit.c " >> _x
echo "set_bit.c " >> _x
echo "clear_bit.c " >> _x
echo "copy_bits.c " >> _x
echo "bytes_to_bits.c " >> _x
echo "bits_to_bytes.c " >> _x
echo "write_bits_to_file.c " >> _x
echo "get_bits_from_array.c " >> _x
#-------------------
while read line; do
  echo $line
  gcc -c $line $QC_FLAGS -I../gen_inc -I../inc/ 
done< _x
#-------------------
cd ../gen_src/
ls *.c > _x
while read line; do
  echo $line
  gcc -c $line $QC_FLAGS -I../gen_inc -I../inc/ 
done< _x

gcc $Q_LINK_FLAGS ../gen_src/*.o ../src/*.o -o libutils.so
cp libutils.so $Q_ROOT/lib/
cd -
#-------------------
echo "Completed $0 in $PWD"

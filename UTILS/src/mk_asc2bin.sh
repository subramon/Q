#!/bin/bash
set -e
make 

make -C  ../../OPERATORS/LOAD_CSV/lua/
make -C  ../../OPERATORS/PRINT/lua/

gcc -g -std=gnu99 \
  asc2bin.c \
  is_valid_chars_for_num.c \
  ../../OPERATORS/LOAD_CSV/src/txt_to_SC.c \
  ../../OPERATORS/LOAD_CSV/gen_src/_txt_to_I1.c \
  ../../OPERATORS/LOAD_CSV/gen_src/_txt_to_I2.c \
  ../../OPERATORS/LOAD_CSV/gen_src/_txt_to_I4.c \
  ../../OPERATORS/LOAD_CSV/gen_src/_txt_to_I8.c \
  ../../OPERATORS/LOAD_CSV/gen_src/_txt_to_F4.c \
  ../../OPERATORS/LOAD_CSV/gen_src/_txt_to_F8.c \
  -I../inc/ \
  -I../gen_inc/ \
  -I../../OPERATORS/LOAD_CSV/gen_inc/  \
  -I../../OPERATORS/LOAD_CSV/inc/  \
  -o asc2bin

gcc -g -std=gnu99 \
  bin2asc.c \
  mmap.c  \
  is_valid_chars_for_num.c \
  ../../OPERATORS/LOAD_CSV/gen_src/_txt_to_I4.c \
  ../../OPERATORS/PRINT/src/SC_to_txt.c \
  ../../OPERATORS/PRINT/gen_src/_I1_to_txt.c \
  ../../OPERATORS/PRINT/gen_src/_I2_to_txt.c \
  ../../OPERATORS/PRINT/gen_src/_I4_to_txt.c \
  ../../OPERATORS/PRINT/gen_src/_I8_to_txt.c \
  ../../OPERATORS/PRINT/gen_src/_F4_to_txt.c \
  ../../OPERATORS/PRINT/gen_src/_F8_to_txt.c \
  -I../inc/ \
  -I../gen_inc/ \
  -I../../OPERATORS/LOAD_CSV/gen_inc/  \
  -I../../OPERATORS/PRINT/gen_inc/  \
  -I../../OPERATORS/PRINT/inc/  \
  -o bin2asc
# chmod +x txt_to_bin
# Run some basic tests
./asc2bin inF4.csv F4 _xx
od -f _xx > _yy
diff _yy chk_inF4.txt
#------------
./asc2bin inI4.csv I4 _xx
od -i _xx > _yy
diff _yy chk_inI4.txt
# echo PREMATURE; exit;
./asc2bin inB1.csv B1 _xx
od -d _xx > _yy
filesize=`stat --printf=%s _xx`
if [ $filesize != 8 ]; then echo ERROR; exit 1; fi 
diff _yy chk_inB1.txt
#------------
./asc2bin inSC.csv SC _xx 16 
od -c --width=16 _xx > _yy
diff _yy chk_inSC.csv
#---------------
rm -f _xx _yy

echo "Completed $0 in $PWD"

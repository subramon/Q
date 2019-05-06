#!/bin/bash
set -e
gcc -DSTAND_ALONE -g -std=gnu99 \
  ../../AUX/dbauxil.c \
  ../../AUX/auxil.c \
  ../../AUX/mmap.c \
  ../../AUX/mk_file.c \
  ../../PRIMITIVES/src/s_to_f_const_I1.c \
  ../../PRIMITIVES/src/s_to_f_const_I2.c \
  ../../PRIMITIVES/src/s_to_f_const_I4.c \
  ../../PRIMITIVES/src/s_to_f_const_I8.c \
  ../../PRIMITIVES/src/s_to_f_const_F4.c \
  ../../PRIMITIVES/src/s_to_f_const_F8.c \
  ./s_to_f_const_SC.c \
  ./s_to_f_const.c \
  ./ut_s_to_f_const.c \
  -I../../AUX/ \
  -I../../PRIMITIVES/inc/ \
   -o ut_s_to_f_const


vg=" "
vg="valgrind   --leak-check=full --show-leak-kinds=all "
$vg ./ut_s_to_f_const

od -c -v _xI1 > _goodI1; diff goodI1 _goodI1
od -d -v _xI2 > _goodI2; diff goodI2 _goodI2
od -i -v _xI4 > _goodI4; diff goodI4 _goodI4
od -l _xI8 -v > _goodI8; diff goodI8 _goodI8
od -c --width=11 -v _xSC > _goodSC; diff goodSC _goodSC
# rm -f _* 
echo "SUCCESSFULLY COMPLETED $0 IN $PWD"

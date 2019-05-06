#!/bin/bash
set -e
gcc -DSTAND_ALONE -g -std=gnu99 \
  ../../AUX/dbauxil.c \
  ../../AUX/auxil.c \
  ../../AUX/mmap.c \
  ../../AUX/mk_file.c \
  ../../PRIMITIVES/src/s_to_f_seq_I1.c \
  ../../PRIMITIVES/src/s_to_f_seq_I2.c \
  ../../PRIMITIVES/src/s_to_f_seq_I4.c \
  ../../PRIMITIVES/src/s_to_f_seq_I8.c \
  ../../PRIMITIVES/src/s_to_f_seq_F4.c \
  ../../PRIMITIVES/src/s_to_f_seq_F8.c \
  ./s_to_f_seq.c \
  ./ut_s_to_f_seq.c \
  -I../../AUX/ \
  -I../../PRIMITIVES/inc/ \
   -o ut_s_to_f_seq


vg=" "
vg="valgrind   --leak-check=full --show-leak-kinds=all "
$vg ./ut_s_to_f_seq

od -d -v _xI2 > _good_seq_I2; diff good_seq_I2 _good_seq_I2
od -i -v _xI4 > _good_seq_I4; diff good_seq_I4 _good_seq_I4
od -l -v _xI8 > _good_seq_I8; diff good_seq_I8 _good_seq_I8
# rm -f _* 
echo "SUCCESSFULLY COMPLETED $0 IN $PWD"

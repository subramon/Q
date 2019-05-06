#!/bin/bash
set -e
gcc -DSTAND_ALONE -g -std=gnu99 \
  ../../AUX/dbauxil.c \
  ../../AUX/auxil.c \
  ../../AUX/mmap.c \
  ../../AUX/mk_file.c \
  ./aux_add_fld.c \
  ./add_fld.c \
  ./add_fld_SC.c \
  ./add_fld_SV.c \
  ./ut_add_fld.c \
  -I../../AUX/ \
   -o ut_add_fld

vg=" "
vg="valgrind   --leak-check=full --show-leak-kinds=all "
$vg ./ut_add_fld 
od -c --width=8 _y > _yy; diff _yy goody
od -c .nn._y       > _nn_yy; diff _nn_yy nn_goody

od -i _x           > _xx; diff _xx goodx
od -c .nn._x       > _nn_xx; diff _nn_xx nn_goodx

od -c _z           > _zz;     diff _zz     goodz
od -c .nn._z       > _nn_zz;  diff _nn_zz  nn_goodz
od -d .len._z      > _len_zz; diff _len_zz len_goodz
od -l .off._z      > _off_zz; diff _off_zz off_goodz
# rm -f _* .*len* .*off* .*nn*
echo "SUCCESSFULLY COMPLETED $0 IN $PWD"

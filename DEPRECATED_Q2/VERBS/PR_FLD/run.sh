#!/bin/bash
set -e
cd ../ADD_FLD/
bash run.sh
cp _z      ../PR_FLD/_out31
cp .nn._z  ../PR_FLD/.nn._out31
cp .len._z ../PR_FLD/.len._out31
cp .off._z ../PR_FLD/.off._out31
cd -
#---- 
gcc -DSTAND_ALONE -g -std=gnu99 \
  ../../AUX/dbauxil.c \
  ../../AUX/auxil.c \
  ../../AUX/mmap.c \
  ../../AUX/mk_file.c \
  ../../PRIMITIVES/src/pr_fld_I1.c \
  ../../PRIMITIVES/src/pr_fld_I2.c \
  ../../PRIMITIVES/src/pr_fld_I4.c \
  ../../PRIMITIVES/src/pr_fld_I8.c \
  ../../PRIMITIVES/src/pr_fld_F4.c \
  ../../PRIMITIVES/src/pr_fld_F8.c \
  ../../PRIMITIVES/src/nn_pr_fld_I1.c \
  ../../PRIMITIVES/src/nn_pr_fld_I2.c \
  ../../PRIMITIVES/src/nn_pr_fld_I4.c \
  ../../PRIMITIVES/src/nn_pr_fld_I8.c \
  ../../PRIMITIVES/src/nn_pr_fld_F4.c \
  ../../PRIMITIVES/src/nn_pr_fld_F8.c \
  ./pr_fld_SC.c \
  ./pr_fld_SV.c \
  ./pr_fld.c \
  ./ut_pr_fld.c \
  -I../../AUX/ \
  -I../../PRIMITIVES/inc/ \
   -o ut_pr_fld


vg=" "
vg="valgrind   --leak-check=full --show-leak-kinds=all "
$vg ./ut_pr_fld 
diff out11.csv _out11.csv
diff out12.csv _out12.csv
diff out21.csv _out21.csv
diff out22.csv _out22.csv

# strip trailing and leading dquote before comparing
cat _out31.csv         | sed s'/^"//'g | sed s'/"$//'g > _x
cat ../ADD_FLD/t2.csv  | sed s'/^"//'g | sed s'/"$//'g > _y
diff _x _y
#---- 
rm -f _*
rm -f .*nn* .*len* .*off*
echo "SUCCESSFULLY COMPLETED $0 in $PWD"

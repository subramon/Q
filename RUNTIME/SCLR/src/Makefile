# Why are we depending on print and load csv?
CC = gcc

INCS := -I../inc/ 
INCS += -I${RSUTILS_SRC_ROOT}/inc/
INCS += -I${RSUTILS_SRC_ROOT}/gen_inc/
INCS += -I../../CMEM/inc 
INCS += -I/usr/include/lua5.1 

all: libsclr.so 

GEN_SRC := _eval_arith.c	 
GEN_SRC += _outer_eval_arith.c 
GEN_SRC += _eval_cmp.c	 

outer_eval_cmp.o : QCFLAGS += -Wno-sign-compare
scalar.o : QCFLAGS += -Wno-sign-compare
SRC := scalar.c
SRC += aux_scalar.c
# SRC += outer_eval_cmp.c  # included in scalar.c

OBJ = $(SRC:.c=.o)

.c.o :
	$(CC) -c -o $@ $< $(QCFLAGS) $(INCS)
clean:
	rm -f *.so ${OBJ} _* ${GEN_SRC} 

# XXXXXX INCS += -I../../../QJIT/GUTILS/inc 
CGUTILS_SO = ${Q_ROOT}/lib/libcgutils.so
${CGUTILS_SO} :
	make -C ../../../QJIT/GUTILS/

RSUTILS_SO = ${RSUTILS_SRC_ROOT}/src/librsutils.so 
#---------------------------------------------
CMEM_SO = ${Q_SRC_ROOT}/RUNTIME/CMEM/src/libcmem.so
CMEM_SO :
	make -C ${Q_SRC_ROOT}/RUNTIME/CMEM/src/
#---------------------------------------------
	
libsclr.so:  ${GEN_SRC} ${OBJ} outer_eval_cmp.c 
	gcc  ${OBJ} -shared ${CMEM_SO} ${RSUTILS_SO}  \
		-o libsclr.so 

#------------------------------------------------------
_eval_arith.c: gen_arith.lua
	luajit gen_arith.lua
_outer_eval_arith.c: gen_arith.lua
	luajit gen_arith.lua
_eval_cmp.c: gen_cmp.lua
	luajit gen_cmp.lua
# _outer_eval_cmp.c: gen_cmp.lua
# 	luajit gen_cmp.lua

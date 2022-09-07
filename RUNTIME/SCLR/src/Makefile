# Why are we depending on print and load csv?
CC = gcc

INCS := -I../inc/ 
INCS += -I../../../UTILS/gen_inc/ 
INCS += -I../../../UTILS/inc 
INCS += -I../../CMEM/inc 
INCS += -I/usr/include/lua5.1 

EXTSO = ${Q_ROOT}/lib/libsclr.so

${EXTSO} : libsclr.so 
	cp libsclr.so ${Q_ROOT}/lib/

all: libsclr.so ${EXTSO}

GEN_SRC := _eval_arith.c	 
GEN_SRC += _outer_eval_arith.c 
GEN_SRC += _eval_cmp.c	 
GEN_SRC += _outer_eval_cmp.c 

SRC := scalar.c
SRC += aux_scalar.c

OBJ = $(SRC:.c=.o)

EXT_SRC := ../../../UTILS/src/is_valid_chars_for_num.c 
EXT_SRC += ../../../UTILS/src/qtypes.c 

EXT_SRC += ../../../UTILS/src/txt_to_B1.c 
EXT_SRC += ../../../UTILS/src/txt_to_I1.c 
EXT_SRC += ../../../UTILS/src/txt_to_I2.c 
EXT_SRC += ../../../UTILS/src/txt_to_I4.c 
EXT_SRC += ../../../UTILS/src/txt_to_I8.c 
EXT_SRC += ../../../UTILS/src/txt_to_F4.c 
EXT_SRC += ../../../UTILS/src/txt_to_F8.c 
EXT_SRC += ../../../UTILS/src/txt_to_SC.c 
	
EXT_SRC += ../../../UTILS/src/B1_to_txt.c 
EXT_SRC += ../../../UTILS/src/I1_to_txt.c 
EXT_SRC += ../../../UTILS/src/I2_to_txt.c 
EXT_SRC += ../../../UTILS/src/I4_to_txt.c 
EXT_SRC += ../../../UTILS/src/I8_to_txt.c 
EXT_SRC += ../../../UTILS/src/F4_to_txt.c 
EXT_SRC += ../../../UTILS/src/F8_to_txt.c 
EXT_SRC += ../../../UTILS/src/SC_to_txt.c 

EXT_SRC += ../../CMEM/src/aux_lua_to_c.c 
EXT_SRC += ../../CMEM/src/aux_cmem.c 

EXT_OBJ = $(EXT_SRC:.c=.o)

.c.o :
	$(CC) -c -o $@ $< $(QC_FLAGS)  $(INCS)
clean:
	rm -f *.so ${EXT_OBJ} ${OBJ} _* ${GEN_SRC} ${EXTSO} ${CMEM_SO}

CMEM_SO = ../../CMEM/src/libcmem.so
	
${CMEM_SO} :
	make -C ../../CMEM/src/


libsclr.so:  ${GEN_SRC} ${EXT_OBJ} ${OBJ} 
	gcc  ${EXT_OBJ} ${OBJ} -shared -o libsclr.so

#------------------------------------------------------
_eval_arith.c: gen_arith.lua
	luajit gen_arith.lua
_outer_eval_arith.c: gen_arith.lua
	luajit gen_arith.lua
_eval_cmp.c: gen_cmp.lua
	luajit gen_cmp.lua
_outer_eval_cmp.c: gen_cmp.lua
	luajit gen_cmp.lua


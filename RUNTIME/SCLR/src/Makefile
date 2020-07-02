# Why are we depending on print and load csv?
INCS=-I. -I../inc/ \
	-I../../../UTILS/gen_inc/ \
	-I../../../UTILS/inc \
	-I../../CMEM/inc \

all: libsclr.so 
	cp libsclr.so ${Q_ROOT}/lib/
	echo "done"

all_for_dc : 
	cp ../inc/scalar_struct.h ${Q_BUILD_DIR}/include/

LOCAL_GEN_FILES = \
	_eval_arith.c	 \
	_outer_eval_arith.c \
	_eval_cmp.c	 \
	_outer_eval_cmp.c \

GEN_INC_FILES =  \
	../../../UTILS/gen_inc/_B1_to_txt.h  \
	../../../UTILS/gen_inc/_SC_to_txt.h  \
	../../../UTILS/gen_inc/_txt_to_B1.h  \
	../../../UTILS/gen_inc/_txt_to_SC.h  \
	../../../UTILS/gen_inc/_is_valid_chars_for_num.h \
	\
	../../../UTILS/gen_inc/_I1_to_txt.h  \
	../../../UTILS/gen_inc/_I2_to_txt.h  \
	../../../UTILS/gen_inc/_I4_to_txt.h  \
	../../../UTILS/gen_inc/_I8_to_txt.h  \
	../../../UTILS/gen_inc/_F4_to_txt.h  \
	../../../UTILS/gen_inc/_F8_to_txt.h  \
	\
	../../../UTILS/gen_inc/_txt_to_I1.h  \
	../../../UTILS/gen_inc/_txt_to_I2.h  \
	../../../UTILS/gen_inc/_txt_to_I4.h  \
	../../../UTILS/gen_inc/_txt_to_I8.h  \
	../../../UTILS/gen_inc/_txt_to_F4.h  \
	../../../UTILS/gen_inc/_txt_to_F8.h  \

SRC_FILES = \
	../../../UTILS/src/is_valid_chars_for_num.c \
	../../../UTILS/src/txt_to_B1.c \
	../../../UTILS/src/B1_to_txt.c \
	../../../UTILS/src/SC_to_txt.c \
	../../../UTILS/src/txt_to_SC.c \

GEN_SRC_FILES = \
	../../../UTILS/gen_src/_txt_to_I1.c \
	../../../UTILS/gen_src/_txt_to_I2.c \
	../../../UTILS/gen_src/_txt_to_I4.c \
	../../../UTILS/gen_src/_txt_to_I8.c \
	../../../UTILS/gen_src/_txt_to_F4.c \
	../../../UTILS/gen_src/_txt_to_F8.c \
	\
	../../../UTILS/gen_src/_I1_to_txt.c \
	../../../UTILS/gen_src/_I2_to_txt.c \
	../../../UTILS/gen_src/_I4_to_txt.c \
	../../../UTILS/gen_src/_I8_to_txt.c \
	../../../UTILS/gen_src/_F4_to_txt.c \
	../../../UTILS/gen_src/_F8_to_txt.c \

clean:
	rm -f *.so *.o _* _*.c
	
../../CMEM/src/libcmem.so :
	make -C ../../CMEM/src/


libsclr.so:  \
   	${GEN_SRC_FILES} \
   	${GEN_INC_FILES} \
	${LOCAL_GEN_FILES} \
   	${SRC_FILES} \
 	../../CMEM/src/libcmem.so
	gcc ${QC_FLAGS} ${INCS} \
	scalar.c \
   	${SRC_FILES} \
   	${GEN_SRC_FILES} \
	../../CMEM/src/cmem.c \
	../../CMEM/src/aux_lua_to_c.c \
	-shared -o libsclr.so
	cp ../inc/scalar_struct.h ${Q_BUILD_DIR}/include/

../../../UTILS/gen_inc/_B1_to_txt.h : 
	make -C ../../../UTILS/src/ ../gen_inc/_B1_to_txt.h
../../../UTILS/gen_inc/_SC_to_txt.h : 
	make -C ../../../UTILS/src/ ../gen_inc/_SC_to_txt.h
../../../UTILS/gen_inc/_I1_to_txt.h : 
	make -C ../../../UTILS/src/ ../gen_inc/_I1_to_txt.h
../../../UTILS/gen_inc/_I2_to_txt.h : 
	make -C ../../../UTILS/src/ ../gen_inc/_I2_to_txt.h
../../../UTILS/gen_inc/_I4_to_txt.h : 
	make -C ../../../UTILS/src/ ../gen_inc/_I4_to_txt.h
../../../UTILS/gen_inc/_I8_to_txt.h : 
	make -C ../../../UTILS/src/ ../gen_inc/_I8_to_txt.h
../../../UTILS/gen_inc/_F4_to_txt.h : 
	make -C ../../../UTILS/src/ ../gen_inc/_F4_to_txt.h
../../../UTILS/gen_inc/_F8_to_txt.h : 
	make -C ../../../UTILS/src/ ../gen_inc/_F8_to_txt.h
#------------------------------------------------------
../../../UTILS/gen_src/_I1_to_txt.c : 
	make -C ../../../UTILS/src/ ../gen_src/_I1_to_txt.c
../../../UTILS/gen_src/_I2_to_txt.c : 
	make -C ../../../UTILS/src/ ../gen_src/_I2_to_txt.c
../../../UTILS/gen_src/_I4_to_txt.c : 
	make -C ../../../UTILS/src/ ../gen_src/_I4_to_txt.c
../../../UTILS/gen_src/_I8_to_txt.c : 
	make -C ../../../UTILS/src/ ../gen_src/_I8_to_txt.c
../../../UTILS/gen_src/_F4_to_txt.c : 
	make -C ../../../UTILS/src/ ../gen_src/_F4_to_txt.c
../../../UTILS/gen_src/_F8_to_txt.c : 
	make -C ../../../UTILS/src/ ../gen_src/_F8_to_txt.c
#------------------------------------------------------
#------------------------------------------------------
../../../UTILS/gen_inc/_is_valid_chars_for_num.h : 
	make -C ../../../UTILS/src/ ../gen_inc/_is_valid_chars_for_num.h
../../../UTILS/gen_inc/_txt_to_B1.h : 
	make -C ../../../UTILS/src/ ../gen_inc/_txt_to_B1.h
../../../UTILS/gen_inc/_txt_to_SC.h : 
	make -C ../../../UTILS/src/ ../gen_inc/_txt_to_SC.h
../../../UTILS/gen_inc/_txt_to_I1.h : 
	make -C ../../../UTILS/src/ ../gen_inc/_txt_to_I1.h
../../../UTILS/gen_inc/_txt_to_I2.h : 
	make -C ../../../UTILS/src/ ../gen_inc/_txt_to_I2.h
../../../UTILS/gen_inc/_txt_to_I4.h : 
	make -C ../../../UTILS/src/ ../gen_inc/_txt_to_I4.h
../../../UTILS/gen_inc/_txt_to_I8.h : 
	make -C ../../../UTILS/src/ ../gen_inc/_txt_to_I8.h
../../../UTILS/gen_inc/_txt_to_F4.h : 
	make -C ../../../UTILS/src/ ../gen_inc/_txt_to_F4.h
../../../UTILS/gen_inc/_txt_to_F8.h : 
	make -C ../../../UTILS/src/ ../gen_inc/_txt_to_F8.h
#------------------------------------------------------
../../../UTILS/gen_src/_txt_to_I1.c : 
	make -C ../../../UTILS/src/ ../gen_src/_txt_to_I1.c
../../../UTILS/gen_src/_txt_to_I2.c : 
	make -C ../../../UTILS/src/ ../gen_src/_txt_to_I2.c
../../../UTILS/gen_src/_txt_to_I4.c : 
	make -C ../../../UTILS/src/ ../gen_src/_txt_to_I4.c
../../../UTILS/gen_src/_txt_to_I8.c : 
	make -C ../../../UTILS/src/ ../gen_src/_txt_to_I8.c
../../../UTILS/gen_src/_txt_to_F4.c : 
	make -C ../../../UTILS/src/ ../gen_src/_txt_to_F4.c
../../../UTILS/gen_src/_txt_to_F8.c : 
	make -C ../../../UTILS/src/ ../gen_src/_txt_to_F8.c
#------------------------------------------------------
_eval_arith.c: gen_arith.lua
	luajit gen_arith.lua
_outer_eval_arith.c: gen_arith.lua
	luajit gen_arith.lua
_eval_cmp.c: gen_cmp.lua
	luajit gen_cmp.lua
_outer_eval_cmp.c: gen_cmp.lua
	luajit gen_cmp.lua


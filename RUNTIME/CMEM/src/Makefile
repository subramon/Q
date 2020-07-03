# Why are we depending on print and load csv?
INCS=-I. \
     	-I../inc/ \
	-I../../../UTILS/gen_inc/ \
	-I../../../UTILS/inc 

all: libcmem.so 
	cp libcmem.so ${Q_ROOT}/lib/

all_for_dc : 
	cp ../inc/cmem_struct.h ${Q_BUILD_DIR}/include/

clean:
	rm -f *.so *.o _*
		
GEN_INC_FILES = \
	../../../UTILS/gen_inc/_B1_to_txt.h \
	../../../UTILS/gen_inc/_I1_to_txt.h \
	../../../UTILS/gen_inc/_I2_to_txt.h \
	../../../UTILS/gen_inc/_I4_to_txt.h \
	../../../UTILS/gen_inc/_I8_to_txt.h \
	../../../UTILS/gen_inc/_F4_to_txt.h \
	../../../UTILS/gen_inc/_F8_to_txt.h \

SRC_FILES = \
	../../../UTILS/src/B1_to_txt.c \

GEN_SRC_FILES = \
	../../../UTILS/gen_src/_I1_to_txt.c \
	../../../UTILS/gen_src/_I2_to_txt.c \
	../../../UTILS/gen_src/_I4_to_txt.c \
	../../../UTILS/gen_src/_I8_to_txt.c \
	../../../UTILS/gen_src/_F4_to_txt.c \
	../../../UTILS/gen_src/_F8_to_txt.c \

../../../UTILS/gen_inc/_B1_to_txt.h : 
	make -C ../../../UTILS/src/ ../gen_inc/_B1_to_txt.h
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

libcmem.so:   cmem.c  \
	${SRC_FILES} ${GEN_SRC_FILES}  ${GEN_INC_FILES} 
	gcc ${QC_FLAGS} ${INCS} \
		cmem.c \
		aux_lua_to_c.c \
		${SRC_FILES} \
		${GEN_SRC_FILES} \
		-shared -o libcmem.so

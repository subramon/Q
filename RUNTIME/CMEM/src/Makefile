# Why are we depending on print and load csv?
INCS=-I. \
     	-I../inc/ \
	-I../../../UTILS/gen_inc/ \
	-I../../../UTILS/inc 

all: libcmem.so 
	cp libcmem.so ${Q_ROOT}/lib/

clean:
	rm -f *.so *.o _*
	rm -f ${Q_ROOT}/lib/libcmem.so
		
GEN_INC_FILES = \
	../../../UTILS/inc/B1_to_txt.h \
	../../../UTILS/inc/I1_to_txt.h \
	../../../UTILS/inc/I2_to_txt.h \
	../../../UTILS/inc/I4_to_txt.h \
	../../../UTILS/inc/I8_to_txt.h \
	../../../UTILS/inc/F4_to_txt.h \
	../../../UTILS/inc/F8_to_txt.h \

SRC_FILES = \
	../../../UTILS/src/B1_to_txt.c \

GEN_SRC_FILES = \
	../../../UTILS/src/I1_to_txt.c \
	../../../UTILS/src/I2_to_txt.c \
	../../../UTILS/src/I4_to_txt.c \
	../../../UTILS/src/I8_to_txt.c \
	../../../UTILS/src/F4_to_txt.c \
	../../../UTILS/src/F8_to_txt.c \

libcmem.so:   cmem.c  \
	${GEN_SRC_FILES} ${SRC_FILES}  ${INC_FILES} \
		aux_lua_to_c.c 
	gcc ${QC_FLAGS} ${INCS} \
		${GEN_SRC_FILES} \
		${SRC_FILES} \
		cmem.c \
		aux_lua_to_c.c \
		-shared -o libcmem.so

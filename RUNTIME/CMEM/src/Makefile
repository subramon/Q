
CC=gcc

CFLAGS := -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align 
CFLAGS += -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings 
CFLAGS += -Wunused-variable -Wunused-parameter -Wno-pedantic 
CFLAGS += -Wno-unused-label 
# CFLAGS := -fsanitize=address -fno-omit-frame-pointer -fsanitize=undefined 
CFLAGS += -Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith 
CFLAGS += -Wmissing-declarations -Wredundant-decls -Wnested-externs 
CFLAGS += -Wshadow -Wcast-qual -Wcast-align -Wwrite-strings 
CFLAGS += -Wold-style-definition -Wsuggest-attribute=noreturn 
CFLAGS += -Wduplicated-cond -Wmisleading-indentation -Wnull-dereference 
CFLAGS += -Wduplicated-branches -Wrestrict

# Why are we depending on print and load csv?
INCS=-I. \
     	-I../inc/ \
	-I../../../UTILS/gen_inc/ \
	-I../../../UTILS/inc  \
	-I/usr/include/lua5.1 \


all: libcmem.so 

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
	gcc ${CFLAGS} ${INCS} \
		${GEN_SRC_FILES} \
		${SRC_FILES} \
		cmem.c \
		aux_lua_to_c.c \
		-shared -o libcmem.so

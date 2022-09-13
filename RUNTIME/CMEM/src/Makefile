CC=gcc

# use QC_FLAGS
# QCFLAGS := -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align 
# CFLAGS += -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings 
# CFLAGS += -Wunused-variable -Wunused-parameter -Wno-pedantic 
# CFLAGS += -Wno-unused-label 
# CFLAGS := -fsanitize=address -fno-omit-frame-pointer -fsanitize=undefined 
# CFLAGS += -Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith 
# CFLAGS += -Wmissing-declarations -Wredundant-decls -Wnested-externs 
# CFLAGS += -Wshadow -Wcast-qual -Wcast-align -Wwrite-strings 
# CFLAGS += -Wold-style-definition -Wsuggest-attribute=noreturn 
# CFLAGS += -Wduplicated-cond -Wmisleading-indentation -Wnull-dereference 
# CFLAGS += -Wduplicated-branches -Wrestrict

# Why are we depending on print and load csv?
INCS := -I../inc/ 
INCS += -I../../../UTILS/gen_inc/ 
INCS += -I../../../UTILS/inc/
INCS += -I../../../QJIT/GUTILS/inc/
INCS += -I/usr/include/lua5.1/ 

all: libcmem.so 

clean:
	rm -f *.so *.o _* ${OBJS}
	rm -f ${Q_ROOT}/lib/libcmem.so
		
SRCS := cmem.c
SRCS += aux_cmem.c
SRCS += aux_lua_to_c.c
SRCS += ../../../UTILS/src/qtypes.c
SRCS +=	../../../UTILS/src/I1_to_txt.c 
SRCS +=	../../../UTILS/src/I2_to_txt.c 
SRCS +=	../../../UTILS/src/I4_to_txt.c 
SRCS +=	../../../UTILS/src/I8_to_txt.c 
SRCS +=	../../../UTILS/src/F4_to_txt.c 
SRCS +=	../../../UTILS/src/F8_to_txt.c 
SRCS +=	../../../UTILS/src/cat_to_buf.c 

OBJS = $(SRCS:.c=.o)

.c.o : 
	$(CC) -c -o $@ $< ${QC_FLAGS} ${DFLAGS} $(INCS) -DGLOBALS
# GLOBALS needed for g_mem_used

libcmem.so:   ${OBJS} 
	$(CC) ${OBJS} -shared -o libcmem.so
	cp libcmem.so ${Q_ROOT}/lib/libcmem.so

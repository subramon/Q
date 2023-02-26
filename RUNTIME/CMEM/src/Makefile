
CC=gcc

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
SRCS +=	../../../UTILS/src/BL_to_txt.c 
SRCS +=	../../../UTILS/src/I1_to_txt.c 
SRCS +=	../../../UTILS/src/I2_to_txt.c 
SRCS +=	../../../UTILS/src/I4_to_txt.c 
SRCS +=	../../../UTILS/src/I8_to_txt.c 
SRCS +=	../../../UTILS/src/F4_to_txt.c 
SRCS +=	../../../UTILS/src/F8_to_txt.c 
SRCS +=	../../../UTILS/src/cat_to_buf.c 

OBJS = $(SRCS:.c=.o)

# NOTE: Add -DVERBOSE to following to get messages printed out 
.c.o : 
	$(CC) -c -o $@ $< ${QCFLAGS} $(INCS) -DGLOBALS
# GLOBALS needed for g_mem_used

CGUTILS_SO = ${Q_ROOT}/lib/libcgutils.so
	
${CGUTILS_SO} :
	make -C ../../../QJIT/GUTILS/

libcmem.so:   ${OBJS} 
	$(CC) ${OBJS} -shared -o libcmem.so ${CGUTILS_SO} ${QLDFLAGS}
	cp libcmem.so ${Q_ROOT}/lib/libcmem.so 

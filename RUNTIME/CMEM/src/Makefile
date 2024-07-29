
CC=gcc

# Why are we depending on print and load csv?
INCS := -I../inc/ 
INCS += -I${RSUTILS_SRC_ROOT}/inc/
INCS += -I../../../QJIT/GUTILS/inc/
INCS += -I/usr/include/lua5.1/ 

all: libcmem.so 

clean:
	rm -f *.so *.o _* ${OBJS}
		
SRCS := cmem.c
SRCS += aux_cmem.c
SRCS += aux_lua_to_c.c
# SRCS += ../../../UTILS/src/qtypes.c
# SRCS +=	../../../UTILS/src/BL_to_txt.c 
# SRCS +=	../../../UTILS/src/I1_to_txt.c 
# SRCS +=	../../../UTILS/src/I2_to_txt.c 
# SRCS +=	../../../UTILS/src/I4_to_txt.c 
# SRCS +=	../../../UTILS/src/I8_to_txt.c 
# SRCS +=	../../../UTILS/src/F4_to_txt.c 
# SRCS +=	../../../UTILS/src/F8_to_txt.c 
# SRCS +=	../../../UTILS/src/cat_to_buf.c 

OBJS = $(SRCS:.c=.o)

# QCFLAGS += -DVERBOSE # NOTE: Add -DVERBOSE for verbosity
QCFLAGS += -DUSE_GLOBALS
.c.o : 
	$(CC) -c -o $@ $< ${QCFLAGS} $(INCS) 
# GLOBALS needed for g_mem_used

# CGUTILS_SO = ${Q_SRC_ROOT}/QJIT/GUTILS/libcgutils.so
RSUTILS_SO = ${RSUTILS_SRC_ROOT}/src/librsutils.so 
	
${CGUTILS_SO} :
	make -C ../../../QJIT/GUTILS/

libcmem.so:   ${OBJS} 
	$(CC) ${OBJS} -shared -o libcmem.so \
	  	${CGUTILS_SO} ${RSUTILS_SO}

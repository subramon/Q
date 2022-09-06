CFLAGS=${QC_FLAGS}
INCS=-I. \
     	-I../inc/ \
	-I../../../UTILS/inc/ \
	-I../../../UTILS/inc  \
	-I/usr/include/lua5.1 \


all: libcutils.so 
	cp libcutils.so ${Q_ROOT}/lib/

SRCS := cutils.c 
SRCS += ../../../UTILS/src/qtypes.c 
SRCS += ../../../UTILS/src/get_bit_u64.c 
SRCS += ../../../UTILS/src/get_file_size.c 
SRCS += ../../../UTILS/src/get_time_usec.c 
SRCS += ../../../UTILS/src/isdir.c 
SRCS += ../../../UTILS/src/isfile.c 
SRCS += ../../../UTILS/src/rdtsc.c 
SRCS += ../../../UTILS/src/rs_mmap.c 

OBJS = $(SRCS:.c=.o)

.c.o : 
	$(CC) -c -o $@ $< ${QC_FLAGS} ${DFLAGS} $(INCS) 

clean:
	rm -f *.so *.o _* ${OBJS}
		
libcutils.so:   ${OBJS} 
	gcc ${OBJS} -shared -o libcutils.so


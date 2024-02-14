
INCS=-I. \
     	-I../inc/ \
	-I../../../UTILS/src/ \
	-I../../../UTILS/inc  \
	-I/usr/include/lua5.1 \


EXTSO = ${Q_ROOT}/lib/libcutils.so

all: libcutils.so ${EXTSO}

${EXTSO} : libcutils.so
	cp libcutils.so ${EXTSO}

SRCS := cutils.c 
SRCS += ../../../UTILS/src/qtypes.c 
SRCS += ../../../UTILS/src/file_exists.c 
SRCS += ../../../UTILS/src/get_bit_u64.c 
SRCS += ../../../UTILS/src/get_file_size.c 
SRCS += ../../../UTILS/src/get_time_usec.c 
SRCS += ../../../UTILS/src/isdir.c 
SRCS += ../../../UTILS/src/isfile.c 
SRCS += ../../../UTILS/src/line_breaks.c 
SRCS += ../../../UTILS/src/mk_file.c 
SRCS += ../../../UTILS/src/rdtsc.c 
SRCS += ../../../UTILS/src/rs_mmap.c 
SRCS += ../../../UTILS/src/tm2time.c 

OBJS = $(SRCS:.c=.o)

.c.o : 
	$(CC) -c -o $@ $< ${QCFLAGS} $(INCS) 

cutils.o : QCFLAGS += -Wno-cast-qual
clean:
	rm -f *.so *.o _* ${OBJS} ${EXTSO}
		
libcutils.so:   ${OBJS} 
	gcc ${OBJS} -shared -o libcutils.so -lgomp ${QLDFLAGS}


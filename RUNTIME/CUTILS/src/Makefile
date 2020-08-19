CFLAGS=${QC_FLAGS}
INCS=-I. \
     	-I../inc/ \
	-I../../../UTILS/inc/ \
	-I../../../UTILS/inc 


all: libcutils.so 
	cp libcutils.so ${Q_ROOT}/lib/

UTILS_INC_FILES = \
	../../../UTILS/inc/get_bit_u64.h \
	../../../UTILS/inc/get_file_size.h \
	../../../UTILS/inc/get_time_usec.h \
	../../../UTILS/inc/isdir.h \
	../../../UTILS/inc/isfile.h \
	../../../UTILS/inc/rdtsc.h \
	../../../UTILS/inc/rs_mmap.h \

UTILS_SRC_FILES = \
	../../../UTILS/src/get_bit_u64.c \
	../../../UTILS/src/get_file_size.c \
	../../../UTILS/src/get_time_usec.c \
	../../../UTILS/src/isdir.c \
	../../../UTILS/src/isfile.c \
	../../../UTILS/src/rdtsc.c \
	../../../UTILS/src/rs_mmap.c \

clean:
	rm -f *.so *.o _*
		
libcutils.so:   cutils.c \
	${UTILS_SRC_FILES} \
	${UTILS_INC_FILES} 
	gcc ${CFLAGS} ${INCS} \
	cutils.c \
	${UTILS_SRC_FILES} \
	-shared -o libcutils.so


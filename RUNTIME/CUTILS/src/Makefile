# Why are we depending on print and load csv?
INCS=-I. \
     	-I../inc/ \
	-I../../../UTILS/gen_inc/ \
	-I../../../UTILS/inc 


all: libcutils.so 
	cp libcutils.so ${Q_ROOT}/lib/

UTILS_INC_FILES = \
	../../../UTILS/gen_inc/_get_file_size.h \
	../../../UTILS/gen_inc/_get_time_usec.h \
	../../../UTILS/gen_inc/_isdir.h \
	../../../UTILS/gen_inc/_isfile.h \
	../../../UTILS/gen_inc/_rdtsc.h \
	../../../UTILS/gen_inc/_rs_mmap.h \

UTILS_SRC_FILES = \
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
	gcc ${QC_FLAGS} ${INCS} \
	cutils.c \
	${UTILS_SRC_FILES} \
	${Q_LINK_FLAGS} -shared -o libcutils.so

../../../UTILS/gen_inc/_get_file_size.h  : 
	make -C ../../../UTILS/src/ ../gen_inc/_get_file_size.h
../../../UTILS/gen_inc/_get_time_usec.h  : 
	make -C ../../../UTILS/src/ ../gen_inc/_get_time_usec.h
../../../UTILS/gen_inc/_isdir.h  : 
	make -C ../../../UTILS/src/ ../gen_inc/_isdir.h
../../../UTILS/gen_inc/_isfile.h  : 
	make -C ../../../UTILS/src/ ../gen_inc/_isfile.h
../../../UTILS/gen_inc/_rdtsc.h  : 
	make -C ../../../UTILS/src/ ../gen_inc/_rdtsc.h
../../../UTILS/gen_inc/_rs_mmap.h  : 
	make -C ../../../UTILS/src/ ../gen_inc/_rs_mmap.h
#-------------------

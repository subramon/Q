CFLAGS = -g -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -Wunused-variable -Wunused-parameter -Wno-pedantic -fopenmp -mavx2 -mfma -Wno-unused-label 
# CFLAGS+= -fsanitize=address -fno-omit-frame-pointer 
# CFLAGS+= -fsanitize=undefined
CFLAGS+= -Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith
# https://lemire.me/blog/2016/04/20/no-more-leaks-with-sanitize-flags-in-gcc-and-clang/
CFLAGS+= -Wmissing-declarations -Wredundant-decls -Wnested-externs
CFLAGS+= -Wshadow -Wcast-qual -Wcast-align -Wwrite-strings
CFLAGS+= -Wold-style-definition
CFLAGS+= -Wsuggest-attribute=noreturn 
# NOT DOING THIS BECUASE WILL HAVE TO REWRITE TOO MUCH -Wjump-misses-init
# New GCC 6/7 flags:
CFLAGS+= -Wduplicated-cond -Wmisleading-indentation -Wnull-dereference
CFLAGS+= -Wduplicated-branches -Wrestrict
# Why are we depending on print and load csv?
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
	${Q_LINK_FLAGS} -shared -o libcutils.so
	test -d ${Q_ROOT}/lib/


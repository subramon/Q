
INCS = -I ./inc/ -I../../UTILS/inc/
all: libapprox_unique.so

SRCS = \
	src/approx_unique.c \
	../../UTILS/src/rdtsc.c \
	../../UTILS/src/spooky_hash.c \

libapprox_unique.so : ${SRCS}
	gcc ${QC_FLAGS} ${SRCS} ${INCS} \
	  -shared -o libapprox_unique.so  -lm

test_approx_unique: libapprox_unique.so ./test/*.c
	gcc ${QC_FLAGS} ${INCS} test/test_approx_unique.c \
	-o test_approx_unique  \
	libapprox_unique.so  -lm
	./test_approx_unique

clean:
	rm -f *.o test_approx_unique *.so

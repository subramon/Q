
#CC = icc -O3 -std=c99 
#LINKOPTIONS = -ipp -DIPP -DCILK -lm -g


INCS = -I ./src/ -I../../UTILS/inc/
all: libapprox_unique.so

SRCS = ./test/test_approx_unique.c  \
	../../UTILS/src/rdtsc.c \
	../../UTILS/src/spooky_hash.c 

libapprox_unique.so : ${SRCS}
	gcc ${QC_FLAGS} ${SRCS} ${INCS} \
	  -shared -o libapprox_unique.so  -lm

# TODO Add following
test: libapprox_unique.so ./test/*.c
	$(CC) test/test_approx_unique.c \
	./libapprox_unique.so \
	-o test -lm

clean:
	rm -f *.o test 

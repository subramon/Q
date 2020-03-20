#CC = icc -O3 -std=c99 
#LINKOPTIONS = -ipp -DIPP -DCILK -lm -g


INCS = -I./src/ -I./inc/ -I../../UTILS/inc/
all: test_approx_quantile 

test_approx_quantile: ./src/approx_quantile.c  \
	  ./test/test_approx_quantile.c  inc/*.h src/*.c
	gcc ${QC_FLAGS} ${INCS} \
	  ./src/approx_quantile.c  \
	  ./src/Collapse.c  \
	  ./src/New.c  \
	  ./src/fast_output.c  \
	  ./src/slow_output.c  \
	  ./src/determine_b_k.c  \
	  ./src/qsort_asc_F8.c  \
	  ./test/test_approx_quantile.c  \
	  ../../UTILS/src/rdtsc.c \
	  ../../UTILS/src/spooky_hash.c \
	  -o test_approx_quantile -lm

# TODO Add following
testSpookyHash: $(SRCOBJS) bin/testSpookyHash.o
	$(CC) $(SRCOBJS) bin/testSpookyHash.o \
	-o testSpookyHash.exe -lm

test_quantile : test_approx_quantile
	./test_approx_quantile

clean:
	rm -f *.o test_approx_quantile

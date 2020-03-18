
#CC = icc -O3 -std=c99 
#LINKOPTIONS = -ipp -DIPP -DCILK -lm -g


INCS = -I ./src/ -I../../UTILS/inc/
all: test_approx_unique 

test_approx_unique: ./src/approx_unique.c  \
	  ./test/test_approx_unique.c  
	gcc ${QC_FLAGS} ${INCS} \
	  ./src/approx_unique.c  \
	  ./test/test_approx_unique.c  \
	  ../../UTILS/src/rdtsc.c \
	  ../../UTILS/src/spooky_hash.c \
	  -o test_approx_unique -lm

# TODO Add following
testSpookyHash: $(SRCOBJS) bin/testSpookyHash.o
	$(CC) $(SRCOBJS) bin/testSpookyHash.o \
	-o testSpookyHash.exe -lm

test_unique : test_approx_unique
	./test_approx_unique

clean:
	rm -f *.o test_approx_unique

#CC = icc -O3 -std=c99 
#LINKOPTIONS = -ipp -DIPP -DCILK -lm -g

INCS = -I./inc/ -I./inc/ -I../../UTILS/inc/ -I../ApproxQuantile/inc/
all: libapprox_frequent.so

libapprox_frequent.so: ./src/approx_frequent.c  \
	  ./test/test_approx_frequent.c  inc/*.h src/*.c
	gcc ${QC_FLAGS} ${INCS} \
	./src/approx_frequent.c  \
	../ApproxQuantile/src/qsort_asc_F8.c \
	src/sorted_array_to_id_freq.c \
	src/update_counter.c \
	../../UTILS/src/rdtsc.c \
	../../UTILS/src/spooky_hash.c \
	-shared -o libapprox_frequent.so -lm

test_frequent : libapprox_frequent.so
	gcc ${QC_FLAGS} ${INCS} \
	./test/test_approx_frequent.c \
	-o test_frequent \
	ibapprox_frequent.so -lm


clean:
	rm -f *.o test_frequent


#CC = icc -O3 -std=c99 
#LINKOPTIONS = -ipp -DIPP -DCILK -lm -g


INCS = -I ./src/ -I../UTILS/inc/ -I./inc/
all: hmap.so test_hmap

SRCS = \
	  ../UTILS/src/get_time_usec.c  \
	  ../UTILS/src/spooky_hash.c  \
	  ../UTILS/src/rdtsc.c  \
	  ./src/hmap_aux.c  \
	  ./src/hmap_chk.c  \
	  ./src/hmap_del.c  \
	  ./src/hmap_destroy.c  \
	  ./src/hmap_get.c  \
	  ./src/hmap_insert.c  \
	  ./src/hmap_instantiate.c  \
	  ./src/hmap_put.c  \
	  ./src/hmap_resize.c  \
	  ./src/calc_new_size.c  \
	  ./src/murmurhash.c  \

.c.o : 
	$(CC) -c -o $@ $< $(QC_FLAGS)  $(INCS) 

hmap.so: ${SRCS}  ./inc/*.h 
	gcc ${QC_FLAGS} ${SRCS} ${INCS} \
	  -shared -o hmap.so 

test_hmap : hmap.so ./test/*.c 
	gcc ${QC_FLAGS} ${INCS} \
	./test/test_hmap.c  \
	hmap.so -o test_hmap 

clean:
	rm -f *.o test_hmap *.so

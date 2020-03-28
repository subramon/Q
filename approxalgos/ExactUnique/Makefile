
#CC = icc -O3 -std=c99 
#LINKOPTIONS = -ipp -DIPP -DCILK -lm -g


INCS = -I ./src/ -I../../UTILS/inc/ -I./inc/
all: hmap.so

SRCS = \
	  ./src/hmap_create.c  \
	  ./src/hmap_instantiate.c  \
	  ./src/hmap_insert.c  \
	  ./src/hmap_put.c  \
	  ./src/hmap_nitems.c  \
	  ./src/hmap_destroy.c  \
	  ./src/hmap_resize.c  \
	  ./src/calc_new_size.c  \
	  ./src/murmurhash.c  \

hmap.so: ./src/*.c  ./inc/*.h 
	gcc ${QC_FLAGS} ${SRCS} ${INCS} \
	  -shared -o hmap.so 

test_hmap : hmap.so ./test/*.c 
	gcc ${QC_FLAGS} ${INCS} \
	./test/test_hmap.c  \
	-o test_hmap hmap.so -lm
	./test_hmap

clean:
	rm -f *.o test_hmap *.so

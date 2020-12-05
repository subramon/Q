
#CC = icc -O3 -std=c99 
#LINKOPTIONS = -ipp -DIPP -DCILK -lm -g


INCS = -I ./src/ -I../UTILS/inc/ -I./inc/
all: hmap.so test1 test1a test3 test4 test4a

V1SRCS = \
	src/val_update_1.c \
	src/val_free_1.c  \
	src/val_pr_4.c  \

V3SRCS = \
	src/val_update_3.c \
	src/val_free_3.c  \
	src/val_pr_3.c  \

V4SRCS = \
	src/val_update_4.c \
	src/val_free_4.c  \
	src/val_pr_4.c  \

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
	  ./src/hmap_mput.c  \
	  ./src/hmap_put.c  \
	  ./src/hmap_resize.c  \
	  ./src/hmap_update.c  \
	  ./src/calc_new_size.c  \
	  ./src/murmurhash.c  \

.c.o : 
	$(CC) -c -o $@ $< $(QC_FLAGS)  $(INCS) 

libval1.so: ${V1SRCS}  ./inc/*.h 
	gcc  ${QC_FLAGS} ${V1SRCS} ${INCS} \
	  -shared -o libval1.so 

libval3.so: ${V3SRCS}  ./inc/*.h 
	gcc  ${QC_FLAGS} ${V3SRCS} ${INCS} \
	  -shared -o libval3.so 

libval4.so: ${V4SRCS}  ./inc/*.h 
	gcc  ${QC_FLAGS} ${V4SRCS} ${INCS} \
	  -shared -o libval4.so 

hmap.so: ${SRCS}  ./inc/*.h 
	gcc  ${QC_FLAGS} ${SRCS} ${INCS} -shared -o hmap.so 

test1 : hmap.so ./test/test1.c ${V1SRCS} libval1.so 
	gcc  ${QC_FLAGS} ${INCS} ./test/test1.c \
	hmap.so libval1.so -o test1 

test1a : hmap.so ./test/test1a.c ${V1SRCS}  libval1.so 
	gcc  ${QC_FLAGS} ${INCS} ./test/test1a.c \
	hmap.so libval1.so -o test1a  -lm

test3 : hmap.so ./test/test3.c ${V3SRCS}  libval3.so 
	gcc  ${QC_FLAGS} ${INCS} ./test/test3.c \
	hmap.so libval3.so -o test3  -lm

test4 : hmap.so ./test/test4.c ${e2SRCS}  libval4.so 
	gcc  ${QC_FLAGS} ${INCS} ./test/test4.c \
	hmap.so libval4.so -o test4  -lm

test4a : hmap.so ./test/test4a.c ${e2SRCS}  libval4.so 
	gcc  ${QC_FLAGS} ${INCS} ./test/test4a.c \
	hmap.so libval4.so -o test4a  -lm

clean:
	rm -f *.o test_hmap *.so

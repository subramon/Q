
CFLAGS := -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align 
CFLAGS += -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings 
CFLAGS += -Wunused-variable -Wunused-parameter -Wno-pedantic 
CFLAGS += -Wno-unused-label 
# CFLAGS := -fsanitize=address -fno-omit-frame-pointer -fsanitize=undefined 
CFLAGS += -Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith 
CFLAGS += -Wmissing-declarations -Wredundant-decls -Wnested-externs 
CFLAGS += -Wshadow -Wcast-qual -Wcast-align -Wwrite-strings 
CFLAGS += -Wold-style-definition -Wsuggest-attribute=noreturn 
# CFLAGS += -Wduplicated-cond -Wmisleading-indentation -Wnull-dereference 
# CFLAGS += -Wduplicated-branches -Wrestrict

DFLAGS = -g -DDEBUG -fopenmp -DVECTOR
DFLAGS = -g -DDEBUG -fopenmp -DSCALAR
DFLAGS = -g -DDEBUG -DVECTOR -fopenmp
DFLAGS = -g -DDEBUG -DSCALAR -DSEQUENTIAL
DFLAGS = -O3 -fopenmp -DVECTOR -pg
DFLAGS = -O3 -fopenmp -DSCALAR 
DFLAGS = -O3 -fopenmp -DVECTOR 
DFLAGS = -g -DDEBUG -DSCALAR -DSEQUENTIAL
# Add -pg for grpof 

INCS = -I./src/ -I../UTILS/inc/ -I./inc/
all: libhmap.so test1 test1a test3 test4 test4a test4b \
  	test_fastrem

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
	  ./src/fasthash.c  \

.c.o : 
	$(CC) -c -o $@ $< ${CFLAGS} ${DFLAGS} $(INCS) 

libval1.so: ${V1SRCS}  ./inc/*.h 
	gcc  ${CFLAGS} ${DFLAGS} ${V1SRCS} ${INCS} \
	  -shared -o libval1.so 

libval3.so: ${V3SRCS}  ./inc/*.h 
	gcc  ${CFLAGS} ${DFLAGS} ${V3SRCS} ${INCS} \
	  -shared -o libval3.so 

libval4.so: ${V4SRCS}  ./inc/*.h 
	gcc  ${CFLAGS} ${DFLAGS} ${V4SRCS} ${INCS} \
	  -shared -o libval4.so 

libhmap.so: ${SRCS}  ./inc/*.h 
	gcc  ${CFLAGS} ${DFLAGS} ${SRCS} ${INCS} -shared -lm -o libhmap.so  

test_kUI8_v_UI4 : libhmap.so ./test/test_kUI8_v_UI4.c ${V1SRCS} libval1.so 
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test_kUI8_v_UI4.c \
	libhmap.so libval1.so -o test_kUI8_v_UI4 

test1 : libhmap.so ./test/test1.c ${V1SRCS} libval1.so 
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test1.c \
	libhmap.so libval1.so -o test1 

test1a : libhmap.so ./test/test1a.c ${V1SRCS}  libval1.so 
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test1a.c \
	libhmap.so libval1.so -o test1a  -lm

test3 : libhmap.so ./test/test3.c ${V3SRCS}  libval3.so 
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test3.c \
	libhmap.so libval3.so -o test3  -lm

test4 : libhmap.so ./test/test4.c ${e2SRCS}  libval4.so 
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test4.c \
	libhmap.so libval4.so -o test4  -lm

test4a : libhmap.so ./test/test4a.c ${e2SRCS}  libval4.so 
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test4a.c \
	libhmap.so libval4.so -o test4a  -lm

test4b : libhmap.so ./test/test4b.c ${e2SRCS}  libval4.so 
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test4b.c \
	libhmap.so libval4.so -o test4b  -lm

test_fastrem : ./test/test_fastrem.c 
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test_fastrem.c \
	  src/get_time_usec.c \
	-o test_fastrem

./inc/hmap_struct_isp.h : ./inc/hmap_struct.h 
	cat ./inc/hmap_struct.h | \
	  sed s'/int8_t/int8/'g | \
	  sed s'/int16_t/int16/'g | \
	  sed s'/int32_t/int32/'g | \
	  sed s'/int64_t/int64/'g > ./inc/hmap_struct_isp.h 

clean:
	rm -f *.o test_hmap *.so

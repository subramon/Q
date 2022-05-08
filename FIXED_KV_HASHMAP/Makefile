
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

# DFLAGS = -g -DDEBUG 
DFLAGS = -O4
# Add -pg for grpof 

INCS := -I../inc/
INCS += -I./inc/ 
INCS += -I../UTILS/inc/ 
INCS += -I./CASE1/inc/ 

all: libhmap.so test_kUI8_vUI4 

SRCS := ../UTILS/src/get_time_usec.c  
SRCS +=	../UTILS/src/spooky_hash.c  
SRCS +=	../UTILS/src/rdtsc.c  
SRCS +=	./src/hmap_aux.c  
SRCS +=	./src/hmap_chk.c  
# TODO SRCS +=	./src/hmap_del.c  
SRCS +=	./src/hmap_destroy.c  
SRCS +=	./src/hmap_get.c  
SRCS +=	./src/hmap_insert.c  
SRCS +=	./src/hmap_instantiate.c  
SRCS +=	./src/hmap_put.c  
SRCS +=	./src/hmap_resize.c  
SRCS +=	./src/hmap_bindmp.c  
SRCS +=	./src/calc_new_size.c  
SRCS +=	./src/murmurhash.c  
SRCS +=	./src/fasthash.c  

OBJS = $(SRCS:.c=.o)

CUSTOM_SRCS +=	./CASE1/src/pr.c  
CUSTOM_SRCS +=	./CASE1/src/key_cmp.c  
CUSTOM_SRCS +=	./CASE1/src/val_update.c  
CUSTOM_SRCS +=	./CASE1/src/key_ordr.c  

CUSTOM_OBJS = $(CUSTOM_SRCS:.c=.o)

.c.o : 
	$(CC) -c -o $@ $< ${CFLAGS} ${DFLAGS} $(INCS) 

libcustom1.so: ${CUSTOM_OBJS}  ./inc/*.h 
	gcc  ${CFLAGS} ${DFLAGS} ${CUSTOM_OBJS} ${INCS} \
		-shared -lm -o libcustom1.so  

libhmap.so: ${OBJS}  ./inc/*.h 
	gcc  ${CFLAGS} ${DFLAGS} ${OBJS} ${INCS} -shared -lm -o libhmap.so  

test_kUI8_vUI4 : libhmap.so ./test/test_kUI8_vUI4.c libcustom1.so
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test_kUI8_vUI4.c \
	libcustom1.so libhmap.so -o test_kUI8_vUI4 

test_fastrem : ./test/test_fastrem.c 
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test_fastrem.c \
	  src/get_time_usec.c \
	-o test_fastrem

clean:
	rm -f *.o test_hmap *.so ./src/*.o test_kUI8_vUI4
	rm -f ./CASE1/src/*.o

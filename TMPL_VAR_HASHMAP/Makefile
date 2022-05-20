
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

DFLAGS = -O4 
DFLAGS = -g -DDEBUG 
# Add -pg for grpof 

INCS := -I./inc/
INCS += -I./CUSTOM1/inc/  # TODO This should not be here 

all: libhmap.so test1 test_fastrem

TMPL=CUSTOM1

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
	  ./src/fasthash.c  \

OBJS = $(SRCS:.c=.o)

.c.o : 
	$(CC) -c -o $@ $< ${CFLAGS} ${DFLAGS} $(INCS) 


libhmap_${TMPL}.so: 
	make -C ${TMPL}
	cp ${TMPL}/libhmap_${TMPL}.so .

libhmap.so: ${OBJS}  ./inc/*.h 
	gcc  ${CFLAGS} ${DFLAGS} ${OBJS} ${INCS} \
		-shared -lm -ldl -o libhmap.so   

test1 : libhmap.so ./test/test1.c libhmap_${TMPL}.so
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test1.c \
	libhmap.so libhmap_${TMPL}.so -o test1 

test_fastrem : ./test/test_fastrem.c 
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test_fastrem.c \
	  src/get_time_usec.c \
	-o test_fastrem

clean:
	rm -f *.o test_hmap *.so ./src/*.o

INCS := -I./inc/ 
INCS += -I../inc/ 

TMPL=hw

all: libhmap_${TMPL}.so test_${TMPL} # TODO TODO P1 test_merge_${TMPL}

SRCS :=	./src/${TMPL}_rs_hmap_instantiate.c  
SRCS +=	./src/rsx_pr.c  
SRCS +=	./src/rsx_key_cmp.c  
SRCS +=	./src/rsx_val_update.c  
SRCS +=	./src/rsx_key_ordr.c  
SRCS +=	./src/rsx_bkt_chk.c  
SRCS +=	./src/rsx_set_hash.c  

OBJS = $(SRCS:.c=.o)

TEST_SRCS := ./test/test_hw.c
TEST_OBJS = $(TEST_SRCS:.c=.o)

CC = gcc

.c.o : 
	$(CC) -c -o $@ $< ${QCFLAGS} $(INCS) 

libhmap_${TMPL}.so: ${OBJS}   ./inc/*.h 
	gcc ${QLDFLAGS} ${OBJS} -shared -o libhmap_${TMPL}.so \
		libhmap.so -lm -ldl

test_${TMPL} : libhmap_${TMPL}.so ${TEST_OBJS}
	gcc  ${TEST_OBJS} \
	libhmap_${TMPL}.so -o test_${TMPL} ${QLDFLAGS} -ldl

test_merge_${TMPL} : libhmap_${TMPL}.so ./test/test_merge_${TMPL}.c 
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test_merge_${TMPL}.c \
	libhmap_${TMPL}.so -o test_merge_${TMPL} -ldl

clean:
	rm -f *.o test_${TMPL} *.so ./src/*.o 


CFLAGS := -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align 
CFLAGS += -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings 
CFLAGS += -Wunused-variable -Wunused-parameter -Wno-pedantic 
CFLAGS += -Wno-unused-label 
# CFLAGS := -fsanitize=address -fno-omit-frame-pointer -fsanitize=undefined 
CFLAGS += -Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith 
CFLAGS += -Wmissing-declarations -Wredundant-decls -Wnested-externs 
CFLAGS += -Wshadow -Wcast-qual -Wcast-align -Wwrite-strings 
CFLAGS += -Wold-style-definition -Wsuggest-attribute=noreturn 
CFLAGS += -Wduplicated-cond -Wmisleading-indentation -Wnull-dereference 
CFLAGS += -Wduplicated-branches -Wrestrict

DFLAGS = -g -DDEBUG 
# DFLAGS = -O4
# Add -pg for grpof 

INCS := -I./inc/ 
INCS += -I../inc/ 

TMPL=CASE1

all: libhmap.so test1 test_merge

SRCS :=	./spooky_hash.c  
SRCS +=	./rdtsc.c  
SRCS +=	./rs_hmap_aux.c  
SRCS +=	./rs_hmap_instantiate.c  
SRCS +=	./rs_hmap_pr.c  
SRCS +=	./rs_hmap_chk.c  
SRCS +=	./rs_hmap_del.c  
SRCS +=	./rs_hmap_destroy.c  
SRCS +=	./rs_hmap_get.c  
SRCS +=	./rs_hmap_insert.c  
SRCS +=	./rs_hmap_merge.c  
SRCS +=	./rs_hmap_put.c  
SRCS +=	./rs_hmap_resize.c  
SRCS +=	./rs_hmap_row_bindmp.c  
SRCS +=	./calc_new_size.c  
SRCS +=	./murmurhash.c  
SRCS +=	./fasthash.c  

OBJS = $(SRCS:.c=.o)

CUSTOM_SRCS +=	./rsx_pr.c  
CUSTOM_SRCS +=	./rsx_key_cmp.c  
CUSTOM_SRCS +=	./rsx_val_update.c  
CUSTOM_SRCS +=	./rsx_key_ordr.c  
CUSTOM_SRCS +=	./rsx_bkt_chk.c  
CUSTOM_SRCS +=	./rsx_set_hash.c  

CUSTOM_OBJS = $(CUSTOM_SRCS:.c=.o)

TEST_SRCS := ../test/test1.c 
TEST_OBJS = $(TEST_SRCS:.c=.o)

MERGE_SRCS := ../test/test_merge.c 
MERGE_OBJS = $(MERGE_SRCS:.c=.o)

.c.o : 
	$(CC) -c -o $@ $< ${CFLAGS} ${DFLAGS} $(INCS) 

libhmap.so: ${OBJS} ${CUSTOM_OBJS}  
	gcc  ${CFLAGS} ${DFLAGS} ${OBJS} ${CUSTOM_OBJS} \
	${INCS} -shared -lm -o libhmap.so  -ldl

test1 : libhmap.so ${TEST_OBJS}
	gcc ${TEST_OBJS} libhmap.so -o test1  -ldl

test_merge : libhmap.so ${MERGE_OBJS}
	gcc  ${MERGE_OBJS} libhmap.so -o test_merge -ldl

test_fastrem : ./test/test_fastrem.c 
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test_fastrem.c \
	  src/get_time_usec.c \
	-o test_fastrem

clean:
	rm -f *.o test_hmap *.so ./src/*.o test_kUI8_vUI4
	rm -f ./${TMPL}/src/*.o

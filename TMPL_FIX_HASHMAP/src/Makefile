
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

INCS := -I../inc/ 
INCS += -I../../UTILS/inc/

TMPL=CASE1

all: libhmap.so test1 test_merge

SRCS :=	./aux.c  
SRCS +=	./spooky_hash.c  
SRCS +=	./rdtsc.c  
SRCS +=	./calc_new_size.c  
SRCS +=	./murmurhash.c  
SRCS +=	./fasthash.c  
SRCS +=	./set_probe_loc.c  

OBJS = $(SRCS:.c=.o)

HMAP_SRCS :=	./rs_hmap_instantiate.c  
HMAP_SRCS +=	./rs_hmap_pr.c  
HMAP_SRCS +=	./rs_hmap_chk.c  
HMAP_SRCS +=	./rs_hmap_del.c  
HMAP_SRCS +=	./rs_hmap_destroy.c  
HMAP_SRCS +=	./rs_hmap_get.c  
HMAP_SRCS +=	./rs_hmap_insert.c  
HMAP_SRCS +=	./rs_hmap_merge.c  
HMAP_SRCS +=	./rs_hmap_put.c  
HMAP_SRCS +=	./rs_hmap_resize.c  
HMAP_SRCS +=	./rs_hmap_row_dmp.c  

HMAP_OBJS = $(HMAP_SRCS:.c=.o)

CUSTOM_SRCS :=	./rsx_pr.c  
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

libhmap.so: ${OBJS} 
	gcc  ${OBJS} -shared -lm -o libhmap.so  -ldl

EXTSO = ${Q_ROOT}/lib/libhmap.so

${EXTSO} : libhmap.so
	cp libhmap.so ${EXTSO}

libhmap_test.so: ${HMAP_OBJS} ${CUSTOM_OBJS}  
	gcc  ${HMAP_OBJS} ${CUSTOM_OBJS} ${INCS} -shared -lm \
		-o libhmap_test.so libhmap.so  -ldl 

test1 : libhmap.so libhmap_test.so ${TEST_OBJS} ../inc/rs_hmap_struct.h
	gcc ${TEST_OBJS} libhmap_test.so libhmap.so -o test1  -ldl

test_merge : libhmap.so libhmap_test.so ${MERGE_OBJS}
	gcc  ${MERGE_OBJS} libhmap_test.so libhmap.so -o test_merge -ldl

test_fastrem : ./test/test_fastrem.c 
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test_fastrem.c \
	  src/get_time_usec.c \
	-o test_fastrem

clean:
	rm -f *.o test_hmap *.so ./src/*.o \
		test1 test_merge test_fastrem ${EXTSO}

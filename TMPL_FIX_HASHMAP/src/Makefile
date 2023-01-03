CC = gcc

INCS := -I../inc/ 
INCS += -I../../UTILS/inc/

TMPL=CASE1

EXTSO = ${Q_ROOT}/lib/libhmap.so

all: libhmap.so test1 test_merge ${EXTSO}

SRCS :=	./aux.c  
SRCS +=	./calc_new_size.c  
SRCS +=	./fasthash.c  
SRCS +=	./mk_dir_file_name.c  
SRCS +=	./murmurhash.c  
SRCS +=	./set_probe_loc.c  
SRCS +=	./spooky_hash.c  
SRCS +=	../../UTILS/src/get_time_usec.c  
SRCS +=	../../UTILS/src/rdtsc.c  
SRCS +=	../../UTILS/src/rs_mmap.c  

OBJS = $(SRCS:.c=.o)

HMAP_SRCS :=	./rs_hmap_instantiate.c  
HMAP_SRCS +=	./rs_hmap_chk.c  
HMAP_SRCS +=	./rs_hmap_del.c  
HMAP_SRCS +=	./rs_hmap_destroy.c  
HMAP_SRCS +=	./rs_hmap_freeze.c  
HMAP_SRCS +=	./rs_hmap_get.c  
HMAP_SRCS +=	./rs_hmap_insert.c  # local 
HMAP_SRCS +=	./rs_hmap_set_fn_ptrs.c  # local 
HMAP_SRCS +=	./rs_hmap_merge.c  
HMAP_SRCS +=	./rs_hmap_pr.c  
HMAP_SRCS +=	./rs_hmap_put.c  
HMAP_SRCS +=	./rs_hmap_resize.c  
HMAP_SRCS +=	./rs_hmap_row_dmp.c  
HMAP_SRCS +=	./rs_hmap_unfreeze.c  

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
	$(CC) -c -o $@ $< ${QCFLAGS} $(INCS) 

libhmap.so: ${OBJS} 
	gcc  ${OBJS} -shared -lm -o libhmap.so  -ldl ${QLDFLAGS}


${EXTSO} : libhmap.so
	cp libhmap.so ${EXTSO}

libhmap_test.so: ${HMAP_OBJS} ${CUSTOM_OBJS}  
	gcc  ${HMAP_OBJS} ${CUSTOM_OBJS} ${INCS} -shared -lm \
		-o libhmap_test.so \
		libhmap.so  -ldl ${QLDFLAGS}

test1 : libhmap.so libhmap_test.so ${TEST_OBJS} ../inc/rs_hmap_struct.h
	gcc ${QCFLAGS} ${TEST_OBJS} libhmap_test.so libhmap.so -o test1   \
		-ldl ${QLDFLAGS}

test_merge : libhmap.so libhmap_test.so ${MERGE_OBJS}
	gcc  ${QCFLAGS} ${MERGE_OBJS} libhmap_test.so libhmap.so -o test_merge \
		-ldl ${QLDFLAGS}

test_fastrem : ./test/test_fastrem.c 
	gcc  ${QCFLAGS} ${INCS} ./test/test_fastrem.c \
	  src/get_time_usec.c \
	-o test_fastrem ${QLDFLAGS} 

clean:
	rm -f *.o test_hmap *.so ./src/*.o ../test/*.o \
		test1 test_merge test_fastrem ${EXTSO}

INCS := -I./inc/ 
INCS += -I../inc/ 
INCS += -I../../UTILS/inc/ # TODO THIS DEPENDENCY IS UGLY 
INCS += -I../HELLO_WORLD/inc/

TMPL=hw2

all: libhmap_${TMPL}.so test_${TMPL} \
	test_hw1hw2 # TODO TODO P1 test_merge_${TMPL}

TMPL_DIR=../src/

SRCS :=	./src/${TMPL}_rs_hmap_instantiate.c  
SRCS +=	./src/rsx_pr.c  
SRCS +=	./src/rsx_key_cmp.c  
SRCS +=	./src/rsx_val_update.c  
SRCS +=	./src/rsx_key_ordr.c  
SRCS +=	./src/rsx_bkt_chk.c  
SRCS +=	./src/rsx_set_hash.c  
#---- START Stuff borrowed from template library 

# THIS IS SOME UGLY HACKERY UNTIL I FIGURE OUT HOW TO HAVE SRC
# IN ONE DIRECTORY AND OBJ IN ANOTHER 
_rs_hmap_chk.c : ${TMPL_DIR}/rs_hmap_chk.c  
	cp $< $@
_rs_hmap_del.c : ${TMPL_DIR}/rs_hmap_del.c  
	cp $< $@
_rs_hmap_destroy.c : ${TMPL_DIR}/rs_hmap_destroy.c  
	cp $< $@
_rs_hmap_freeze.c : ${TMPL_DIR}/rs_hmap_freeze.c  
	cp $< $@
_rs_hmap_get.c : ${TMPL_DIR}/rs_hmap_get.c  
	cp $< $@
_rs_hmap_insert.c : ${TMPL_DIR}/rs_hmap_insert.c  
	cp $< $@
_rs_hmap_set_fn_ptrs.c : ${TMPL_DIR}/rs_hmap_set_fn_ptrs.c  
	cp $< $@
_rs_hmap_merge.c : ${TMPL_DIR}/rs_hmap_merge.c  
	cp $< $@
_rs_hmap_pr.c : ${TMPL_DIR}/rs_hmap_pr.c  
	cp $< $@
_rs_hmap_put.c : ${TMPL_DIR}/rs_hmap_put.c  
	cp $< $@
_rs_hmap_resize.c : ${TMPL_DIR}/rs_hmap_resize.c  
	cp $< $@
_rs_hmap_row_dmp.c : ${TMPL_DIR}/rs_hmap_row_dmp.c  
	cp $< $@
_rs_hmap_unfreeze.c : ${TMPL_DIR}/rs_hmap_unfreeze.c  
	cp $< $@
_rs_hmap_instantiate.c : ${TMPL_DIR}/rs_hmap_instantiate.c  
	cp $< $@

SRCS +=	_rs_hmap_chk.c  
SRCS +=	_rs_hmap_del.c  
SRCS +=	_rs_hmap_destroy.c  
SRCS +=	_rs_hmap_freeze.c  
SRCS +=	_rs_hmap_get.c  
SRCS +=	_rs_hmap_insert.c  # local 
SRCS +=	_rs_hmap_set_fn_ptrs.c  # local 
SRCS +=	_rs_hmap_merge.c  
SRCS +=	_rs_hmap_pr.c  
SRCS +=	_rs_hmap_put.c  
SRCS +=	_rs_hmap_resize.c  
SRCS +=	_rs_hmap_row_dmp.c  
SRCS +=	_rs_hmap_unfreeze.c  
SRCS +=	_rs_hmap_instantiate.c  
#---- STOP  Stuff borrowed from template library 

OBJS = $(SRCS:.c=.o)

TEST_SRCS := ./test/test_${TMPL}.c
TEST_OBJS = $(TEST_SRCS:.c=.o)

../HELLO_WORLD/libhmap_hw.so :
	make -C ../HELLO_WORLD/

../src/libhmap.so :
	make -C ../src/

CC = gcc

.c.o : 
	$(CC) -c -o $@ $< ${QCFLAGS} $(INCS) 

# TODO P1 Why do we have to do ../src/libhap.so?
# Why is LD_LIBRARY_PATH not working?
libhmap_${TMPL}.so: ${OBJS}   ./inc/*.h 
	gcc ${QLDFLAGS} ${OBJS} ../src/libhmap.so \
		-shared -o libhmap_${TMPL}.so \
		-lm -ldl

test_${TMPL} : libhmap_${TMPL}.so ${TEST_OBJS}
	gcc  ${TEST_OBJS} \
	libhmap_${TMPL}.so -o test_${TMPL} ${QLDFLAGS} -ldl

test_hw1hw2 : libhmap_${TMPL}.so \
	../src/libhmap.so \
	test/test_hw1hw2.o \
	../HELLO_WORLD/libhmap_hw.so 
	gcc  test/test_hw1hw2.o \
	../src/libhmap.so \
	libhmap_hw2.so \
	../HELLO_WORLD/libhmap_hw.so \
	-o test_hw1hw2 ${QLDFLAGS} -ldl

test_merge_${TMPL} : libhmap_${TMPL}.so ./test/test_merge_${TMPL}.c 
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test_merge_${TMPL}.c \
	libhmap_${TMPL}.so -o test_merge_${TMPL} -ldl

clean:
	rm -f *.o test_${TMPL} *.so ./src/*.o 

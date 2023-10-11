INCS := -I../inc/ # files for general hashmap 
INCS += -I./${TMPL}/inc/  # files specific to key counter 
INCS += -I../../UTILS/inc/ # TODO THIS DEPENDENCY IS UGLY 

# TMPL=hw This must be passed as make -e "TMPL=hw"

all: libhmap_${TMPL}.so test_${TMPL} 

GNRL_SRC_DIR=../src/ # ????

_rsx_key_cmp.c : ./src/rsx_key_cmp.c   
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rsx_set_hash.c : ./src/rsx_set_hash.c   
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rsx_val_update.c : ./src/rsx_val_update.c   
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
# Customized code 
SRCS +=	_rsx_key_cmp.c  
SRCS +=	_rsx_set_hash.c  
SRCS +=	_rsx_val_update.c  

OBJS = $(SRCS:.c=.o)

TEST_SRCS := ./test/test_${TMPL}.c
TEST_OBJS = $(TEST_SRCS:.c=.o)

CC = gcc

.c.o : 
	$(CC) -c -o $@ $< ${QCFLAGS} $(INCS) 

# TODO P1 Why do we have to do ../src/libhap.so?
# Why is LD_LIBRARY_PATH not working?
libhmap_${TMPL}.so: ${OBJS} 
	gcc ${QCFLAGS} ${OBJS} \
		-shared -o libhmap_${TMPL}.so \
		-lm -ldl

test_${TMPL} : libhmap_${TMPL}.so ${TEST_OBJS} ${HINCS}
	gcc  ${QLDFLAGS} ${TEST_OBJS} libhmap_${TMPL}.so libhmap.so -ldl  \
	-o test_${TMPL} 

test_merge_${TMPL} : libhmap_${TMPL}.so ./test/test_merge_${TMPL}.c 
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test_merge_${TMPL}.c \
	libhmap_${TMPL}.so -o test_merge_${TMPL} -ldl

clean:
	rm -f *.o test_${TMPL} *.so ./src/*.o _*.c
	rm -f inc/hw_rs_hmap_instantiate.h  
	rm -f inc/hw_rs_hmap_struct.h  
	rm -f inc/rs_hmap_struct.h  
	rm -f ./_rs_hmap_*

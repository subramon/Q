INCS := -I./inc/ 
INCS += -I../inc/ 
INCS += -I../../UTILS/inc/ # TODO THIS DEPENDENCY IS UGLY 
INCS += -I../HELLO_WORLD/inc/

TMPL=chnk
MYSO= libhmap_${TMPL}.so
EXTSO=${Q_ROOT}/lib/${MYSO}

${EXTSO} : ${MYSO}
	cp ${MYSO} ${EXTSO}

all: ${MYSO} ${EXTSO} # test_${TMPL}  TODO Write a test 

TMPL_DIR=../src/
TMPL_INC_DIR=../inc/

#---- START Stuff borrowed from template library 

HINCS := ./inc/rs_hmap_struct.h
HINCS += ./inc/${TMPL}_rs_hmap_struct.h
HINCS += _rs_hmap_chk.h
HINCS += _rs_hmap_del.h
HINCS += _rs_hmap_destroy.h
HINCS += _rs_hmap_freeze.h
HINCS += _rs_hmap_get.h
HINCS += _rs_hmap_insert.h
HINCS += _rs_hmap_set_fn_ptrs.h
HINCS += _rs_hmap_merge.h
HINCS += _rs_hmap_pr.h
HINCS += _rs_hmap_put.h
HINCS += _rs_hmap_resize.h
HINCS += _rs_hmap_row_dmp.h
HINCS += _rs_hmap_unfreeze.h
HINCS += _rs_hmap_instantiate.h
HINCS += ./inc/${TMPL}_rs_hmap_instantiate.h
HINCS += ./inc/${TMPL}_rs_hmap_unfreeze.h

./src/rsx_pr.o : ./inc/${TMPL}_rs_hmap_struct.h

../inc/xxx :
	echo "hello world" > ../inc/xxx

./inc/rs_hmap_struct.h : ${TMPL_INC_DIR}/rs_hmap_struct.h
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@


./inc/${TMPL}_rs_hmap_struct.h : ./inc/rs_hmap_struct.h 
	cp ./inc/rs_hmap_struct.h ./inc/${TMPL}_rs_hmap_struct.h 
	# Above line needed because that is what external callers need

./inc/${TMPL}_rs_hmap_instantiate.h : _rs_hmap_instantiate.h 
	cp _rs_hmap_instantiate.h ./inc/${TMPL}_rs_hmap_instantiate.h 
	# Above line needed because that is what external callers need

./inc/${TMPL}_rs_hmap_unfreeze.h : _rs_hmap_unfreeze.h 
	cp _rs_hmap_unfreeze.h ./inc/${TMPL}_rs_hmap_unfreeze.h 
	# Above line needed because that is what external callers need

# THIS IS SOME UGLY HACKERY UNTIL I FIGURE OUT HOW TO DO
# BETTER PATTERN MATCHING 
_rs_hmap_chk.c : ${TMPL_DIR}/rs_hmap_chk.c  ${HINCS}
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_del.c : ${TMPL_DIR}/rs_hmap_del.c ${HINCS}
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_destroy.c : ${TMPL_DIR}/rs_hmap_destroy.c ${HINCS} 
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_freeze.c : ${TMPL_DIR}/rs_hmap_freeze.c ${HINCS}
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_get.c : ${TMPL_DIR}/rs_hmap_get.c ${HINCS}
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_insert.c : ${TMPL_DIR}/rs_hmap_insert.c ${HINCS}
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_set_fn_ptrs.c : ${TMPL_DIR}/rs_hmap_set_fn_ptrs.c ${HINCS}  
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_merge.c : ${TMPL_DIR}/rs_hmap_merge.c   ${HINCS}
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_pr.c : ${TMPL_DIR}/rs_hmap_pr.c   ${HINCS}
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_put.c : ${TMPL_DIR}/rs_hmap_put.c   ${HINCS}
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_resize.c : ${TMPL_DIR}/rs_hmap_resize.c   ${HINCS}
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_row_dmp.c : ${TMPL_DIR}/rs_hmap_row_dmp.c   ${HINCS}
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_unfreeze.c : ${TMPL_DIR}/rs_hmap_unfreeze.c   ${HINCS}
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_instantiate.c : ${TMPL_DIR}/rs_hmap_instantiate.c   ${HINCS}
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
#-----------------------------------------
_rs_hmap_chk.h : ${TMPL_INC_DIR}/rs_hmap_chk.h 
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_del.h : ${TMPL_INC_DIR}/rs_hmap_del.h
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_destroy.h : ${TMPL_INC_DIR}/rs_hmap_destroy.h
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_freeze.h : ${TMPL_INC_DIR}/rs_hmap_freeze.h
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_get.h : ${TMPL_INC_DIR}/rs_hmap_get.h
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_insert.h : ${TMPL_INC_DIR}/rs_hmap_insert.h
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_set_fn_ptrs.h : ${TMPL_INC_DIR}/rs_hmap_set_fn_ptrs.h
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_merge.h : ${TMPL_INC_DIR}/rs_hmap_merge.h  
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_pr.h : ${TMPL_INC_DIR}/rs_hmap_pr.h  
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_put.h : ${TMPL_INC_DIR}/rs_hmap_put.h  
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_resize.h : ${TMPL_INC_DIR}/rs_hmap_resize.h  
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_row_dmp.h : ${TMPL_INC_DIR}/rs_hmap_row_dmp.h  
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_unfreeze.h : ${TMPL_INC_DIR}/rs_hmap_unfreeze.h  
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rs_hmap_instantiate.h : ${TMPL_INC_DIR}/rs_hmap_instantiate.h  
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
#-----------------------------------------

SRCS +=	_rs_hmap_chk.c  
SRCS +=	_rs_hmap_del.c  
SRCS +=	_rs_hmap_destroy.c  
SRCS +=	_rs_hmap_freeze.c  
SRCS +=	_rs_hmap_get.c  
SRCS +=	_rs_hmap_insert.c  
SRCS +=	_rs_hmap_set_fn_ptrs.c  
SRCS +=	_rs_hmap_merge.c  
SRCS +=	_rs_hmap_pr.c  
SRCS +=	_rs_hmap_put.c  
SRCS +=	_rs_hmap_resize.c  
SRCS +=	_rs_hmap_row_dmp.c  
SRCS +=	_rs_hmap_unfreeze.c  
SRCS +=	_rs_hmap_instantiate.c  
#---- STOP  Stuff borrowed from template library 

_rsx_pr.c : ./src/rsx_pr.c   
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rsx_key_cmp.c : ./src/rsx_key_cmp.c   
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rsx_val_update.c : ./src/rsx_val_update.c   
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rsx_key_ordr.c : ./src/rsx_key_ordr.c   
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rsx_bkt_chk.c : ./src/rsx_bkt_chk.c   
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
_rsx_set_hash.c : ./src/rsx_set_hash.c   
	bash ${TMPL_DIR}/do_subs.sh  ${TMPL} $< $@
# Customized code 
SRCS +=	_rsx_pr.c  
SRCS +=	_rsx_key_cmp.c  
SRCS +=	_rsx_val_update.c  
SRCS +=	_rsx_key_ordr.c  
SRCS +=	_rsx_bkt_chk.c  
SRCS +=	_rsx_set_hash.c  

OBJS = $(SRCS:.c=.o)

TEST_SRCS := ./test/test_${TMPL}.c
TEST_OBJS = $(TEST_SRCS:.c=.o)

CC = gcc

.c.o : 
	$(CC) -c -o $@ $< ${QCFLAGS} $(INCS) 

# TODO P1 Why do we have to do ../src/libhap.so?
# Why is LD_LIBRARY_PATH not working?
libhmap_${TMPL}.so: ${OBJS}   ./inc/*.h 
	gcc ${QLDFLAGS} ${OBJS} \
		-shared -o libhmap_${TMPL}.so \
		-lm -ldl

test_${TMPL} : libhmap_${TMPL}.so ${TEST_OBJS} ${HINCS}
	gcc  ${TEST_OBJS} -o test_${TMPL} ${QLDFLAGS} \
	libhmap.so libhmap_${TMPL}.so -ldl

test_merge_${TMPL} : libhmap_${TMPL}.so ./test/test_merge_${TMPL}.c 
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test_merge_${TMPL}.c \
	libhmap_${TMPL}.so -o test_merge_${TMPL} -ldl

clean:
	rm -f *.o ${MYSO} ${EXTSO} ./src/*.o _*.c
	rm -f inc/hw_rs_hmap_instantiate.h  
	rm -f inc/hw_rs_hmap_struct.h  
	rm -f inc/rs_hmap_struct.h  

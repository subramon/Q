CC=gcc

INCS := -I../inc/ 
INCS += -I${RSUTILS_SRC_ROOT}/inc/
INCS += -I${RSHMAP_SRC_ROOT}/fixed_len_kv/common/inc/
INCS += -I../../../QJIT/HMAPS/VCTR/gen_inc/
INCS += -I../../../QJIT/HMAPS/VCTR/inc/
INCS += -I../../../QJIT/HMAPS/CHNK/gen_inc/
INCS += -I../../../QJIT/HMAPS/CHNK/inc/
INCS += -I../../CMEM/inc/
INCS += -I../../SCLR/inc/
INCS += -I../../../QJIT/GUTILS/inc
INCS += -I../../../QJIT/LuaJIT-2.1.0-beta3/src/

all: libvctr_core.so  ut1 ut2 ut_memo libvctr.so 

SRCS :=	vctr_add.c  
SRCS +=	vctr_cast.c  
SRCS +=	vctr_cnt.c  
SRCS +=	vctr_chk.c
SRCS +=	vctr_del.c  
SRCS +=	vctr_drop_mem.c  
SRCS +=	vctr_make_mem.c  
SRCS +=	vctr_early_free.c  
SRCS +=	vctr_eov.c  
SRCS +=	vctr_get1.c  
SRCS +=	vctr_get_chunk.c  
SRCS +=	vctr_is.c  
SRCS +=	vctr_get_set.c  
SRCS +=	vctr_nn_get_set.c  
SRCS +=	vctr_nop.c  

SRCS +=	vctr_chnks_to_lma.c  
SRCS +=	vctr_lma_to_chnks.c
# DEPRECATED SRCS +=	vctr_make_lma.c  
SRCS +=	vctr_lma_access.c  
SRCS +=	vctr_set_lma.c  
SRCS +=	vctr_usage.c  

SRCS +=	vctr_name.c  
SRCS +=	vctr_num_chunks.c  
SRCS +=	vctr_num_elements.c  
SRCS +=	vctr_new_uqid.c  
SRCS +=	vctr_persist.c  
SRCS +=	vctr_kill.c  
SRCS +=	vctr_append.c  
SRCS +=	vctr_print.c  
SRCS +=	vctr_putn.c  
SRCS +=	vctr_put1.c 
SRCS +=	vctr_put_chunk.c  
SRCS +=	vctr_memo.c  
SRCS +=	vctr_l1_to_l2.c  
SRCS +=	num_read_write.c  

SRCS +=	chnk_cnt.c  
SRCS +=	chnk_del.c  
SRCS +=	chnk_first.c  
SRCS +=	chnk_free_resources.c  
SRCS +=	chnk_get_data.c  
SRCS +=	chnk_is.c  
SRCS +=	chnk_make_mem.c  
SRCS +=	chnk_drop_mem.c  
SRCS +=	chnk_nop.c  
SRCS +=	chnk_l1_to_l2.c  

OBJS = $(SRCS:.c=.o)

TEST1_SRCS := ../test/C/ut1.c
TEST1_SRCS += ../../../QJIT/GUTILS/src/init_globals.c
TEST1_SRCS += ../../../QJIT/GUTILS/src/init_session.c
TEST1_SRCS += ../../../QJIT/GUTILS/src/free_globals.c
TEST1_SRCS += ../../../QJIT/GUTILS/src/lua_state.c
TEST1_OBJS = $(TEST1_SRCS:.c=.o)

TEST2_SRCS := ../test/C/ut2.c
TEST2_SRCS += ../../CMEM/src/aux_cmem.c 
TEST2_SRCS += ../../../QJIT/GUTILS/src/init_globals.c
TEST2_SRCS += ../../../QJIT/GUTILS/src/init_session.c
TEST2_SRCS += ../../../QJIT/GUTILS/src/free_globals.c
TEST2_SRCS += ../../../QJIT/GUTILS/src/lua_state.c
TEST2_OBJS = $(TEST2_SRCS:.c=.o)

TEST3_SRCS := ../test/C/ut_memo.c
TEST3_SRCS += ../../CMEM/src/aux_cmem.c 
TEST3_SRCS += ../../../QJIT/GUTILS/src/init_globals.c
TEST3_SRCS += ../../../QJIT/GUTILS/src/init_session.c
TEST3_SRCS += ../../../QJIT/GUTILS/src/free_globals.c
TEST3_SRCS += ../../../QJIT/GUTILS/src/lua_state.c
TEST3_OBJS = $(TEST3_SRCS:.c=.o)

# QCFLAGS += -DVERBOSE
# NOTE: Add -DVERBOSE to following to get messages printed out 
.c.o : 
	$(CC) -c -o $@ $< ${QCFLAGS} $(INCS) 

#-------------------------------------------
RSHMAP_SO  = ${RSHMAP_SRC_ROOT}/fixed_len_kv/common/librs_hmap_core.so
RSUTILS_SO = ${RSUTILS_SRC_ROOT}/src/librsutils.so
GUTILS_SO  = ${Q_SRC_ROOT}/QJIT/GUTILS/libcgutils.so
VCTR_SO    = ${Q_SRC_ROOT}/QJIT/HMAPS/VCTR/libvctr_rs_hmap.so
CHNK_SO    = ${Q_SRC_ROOT}/QJIT/HMAPS/CHNK/libchnk_rs_hmap.so

${VCTR_SO} : 
	make -C ${Q_SRC_ROOT}/QJIT/HMAPS/VCTR/
${CHNK_SO} : 
	make -C ${Q_SRC_ROOT}/QJIT/HMAPS/CHNK/
${GUTILS_SO} : 
	make -C ${Q_SRC_ROOT}/QJIT/GUTILS/
${RSUTILS_SO} : 
	make -C ${RSUTILS_SRC_ROOT}/src/
${RSHMAP_SO} : 
	make -C ${RSHMAP_SRC_ROOT}/fixed_len_kv/common/
#-------------------------------------------
libvctr_core.so :  ${OBJS} \
  	${RSHMAP_SO} ${VCTR_SO} ${CHNK_SO} ${GUTILS_SO} ${RSUTILS_SO}
	gcc ${OBJS} -shared \
	${VCTR_SO} ${CHNK_SO} ${GUTILS_SO} ${RSUTILS_SO} ${RSHMAP_SO} \
		-o libvctr_core.so 
#-------------------------------------------
EXT_SRCS := cVector.c
EXT_SRCS += ../../CMEM/src/aux_lua_to_c.c
EXT_SRCS += ../../CMEM/src/aux_cmem.c

EXT_OBJS = $(EXT_SRCS:.c=.o)

libvctr.so: ${EXT_OBJS} libvctr_core.so cVector.o 
	gcc ${EXT_OBJS} \
	libvctr_core.so \
	-shared -o libvctr.so 
	cp libvctr.so ${Q_ROOT}/lib/

#-------------------------------------------
ut1 : ${TEST1_OBJS} \
  	${VCTR_SO} ${CHNK_SO} ${GUTILS_SO} ${RSUTILS_SO} ${RSHMAP_SO} \
	libvctr.so libvctr_core.so 
	gcc ${TEST1_OBJS} \
	${QCFLAGS} ${INCS} \
	libvctr.so \
	libvctr_core.so \
	${VCTR_SO} ${CHNK_SO} ${GUTILS_SO} ${RSUTILS_SO} ${RSHMAP_SO} \
	-o ut1  -lpthread ${QLDFLAGS} # -static-libasan
#-------------------------------------------
ut2 : ${TEST2_OBJS} ${RSUTILS_SO} 
	gcc ${TEST2_OBJS} \
	${QCFLAGS} ${INCS} \
	libvctr_core.so \
	${VCTR_SO} ${CHNK_SO} ${GUTILS_SO} ${RSUTILS_SO} ${RSHMAP_SO} \
	-o ut2 -lm -lpthread ${QLDFLAGS} # -static-libasan
#-------------------------------------------
ut_memo : ${TEST3_OBJS}  ${RSUTILS_SO} 
	gcc ${TEST3_OBJS} \
	${QCFLAGS} ${INCS} \
	libvctr_core.so \
	${VCTR_SO} ${CHNK_SO} ${GUTILS_SO} ${RSUTILS_SO} ${RSHMAP_SO} \
	-o ut_memo -lm -lpthread ${QLDFLAGS} # -static-libasan
#-------------------------------------------


clean:
	rm -f *.o *.so ut1 ut2 ../test/*.o
	rm -f ${VCTR_SO} ${CHNK_SO} ${GUTILS_SO} ${RSUTILS_SO} ${RSHMAP_SO} 

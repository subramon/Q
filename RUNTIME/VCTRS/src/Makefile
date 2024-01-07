CC=gcc

INCS := -I../inc/ 
INCS += -I../../../UTILS/inc/
INCS += -I../../CMEM/inc/
INCS += -I../../SCLR/inc/
INCS += -I../../../TMPL_FIX_HASHMAP/inc/
INCS += -I../../../TMPL_FIX_HASHMAP/VCTR_HMAP/inc/
INCS += -I../../../TMPL_FIX_HASHMAP/CHNK_HMAP/inc/
INCS += -I../../../QJIT/GUTILS/inc
INCS += -I../../../QJIT/LuaJIT-2.1.0-beta3/src/

TMPL=CASE1


all: core_libvctr.so  ut1 ut2 ut_memo libvctr.so 

SRCS :=	vctr_add.c  
SRCS +=	vctr_cnt.c  
SRCS +=	vctr_chk.c
SRCS +=	vctr_del.c  
SRCS +=	vctr_drop_mem.c  
SRCS +=	vctr_make_mem.c  
SRCS +=	vctr_early_free.c  
SRCS +=	vctr_eov.c  
SRCS +=	vctr_get1.c  
SRCS +=	vctr_get_chunk.c  
SRCS +=	vctr_incr_ref_count.c  
SRCS +=	vctr_is.c  
SRCS +=	vctr_is_early_free.c  
SRCS +=	vctr_is_eov.c  
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
SRCS +=	vctr_width.c  
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

TEST1_SRCS := ../test/ut1.c
TEST1_SRCS += ../../../QJIT/GUTILS/src/init_globals.c
TEST1_SRCS += ../../../QJIT/GUTILS/src/init_session.c
TEST1_SRCS += ../../../QJIT/GUTILS/src/free_globals.c
TEST1_SRCS += ../../../QJIT/GUTILS/src/lua_state.c
TEST1_OBJS = $(TEST1_SRCS:.c=.o)

TEST2_SRCS := ../test/ut2.c
TEST2_SRCS += ../../CMEM/src/aux_cmem.c 
TEST2_SRCS += ../../../QJIT/GUTILS/src/init_globals.c
TEST2_SRCS += ../../../QJIT/GUTILS/src/init_session.c
TEST2_SRCS += ../../../QJIT/GUTILS/src/free_globals.c
TEST2_SRCS += ../../../QJIT/GUTILS/src/lua_state.c
TEST2_OBJS = $(TEST2_SRCS:.c=.o)

TEST3_SRCS := ../test/ut_memo.c
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
TMPL_HMAP_LOC = ../../../TMPL_FIX_HASHMAP/src/
TMPL_HMAP_SO  = ${Q_ROOT}/lib/libhmap.so

${TMPL_HMAP_SO} : 
	make -C ${TMPL_HMAP_LOC} ${TMPL_HMAP_SO}
#-------------------------------------------
UTILS_LOC = ../../../UTILS/src/
UTILS_SO  = ${Q_ROOT}/lib/libutils.so

${UTILS_SO} : 
	make -C ${UTILS_LOC} ${UTILS_SO}
#-------------------------------------------
GUTILS_LOC = ../../../QJIT/GUTILS/
GUTILS_SO  = ${Q_ROOT}/lib/libcgutils.so

${GUTILS_SO} : 
	make -C ${GUTILS_LOC} ${GUTILS_SO}
#-------------------------------------------
VCTR_HMAP_LOC = ../../../TMPL_FIX_HASHMAP/VCTR_HMAP
VCTR_HMAP_SO  = ${Q_ROOT}/lib/libhmap_vctr.so

${VCTR_HMAP_SO} : 
	make -C ${VCTR_HMAP_LOC} ${VCTR_HMAP_SO}
#-------------------------------------------
CHNK_HMAP_LOC = ../../../TMPL_FIX_HASHMAP/CHNK_HMAP
CHNK_HMAP_SO  = ${Q_ROOT}/lib/libhmap_chnk.so

${CHNK_HMAP_SO} : 
	make -C ${CHNK_HMAP_LOC} ${CHNK_HMAP_SO}
#-------------------------------------------
core_libvctr.so :  ${OBJS} \
	${TMPL_HMAP_SO} \
	${VCTR_HMAP_SO} \
	${CHNK_HMAP_SO} \
	${GUTILS_SO}  \
	${UTILS_SO} 
	gcc ${OBJS}  \
	-shared -o core_libvctr.so ${LDFLAGS} \
	${VCTR_HMAP_SO} ${CHNK_HMAP_SO} ${GUTILS_SO} ${UTILS_SO} 
	cp core_libvctr.so ${Q_ROOT}/lib/
#-------------------------------------------
EXT_SRCS := cVector.c
EXT_SRCS += ../../CMEM/src/aux_lua_to_c.c
EXT_SRCS += ../../CMEM/src/aux_cmem.c
EXT_SRCS += ../../../UTILS/src/qtypes.c

EXT_OBJS = $(EXT_SRCS:.c=.o)

libvctr.so: ${EXT_OBJS} core_libvctr.so cVector.o 
	gcc ${EXT_OBJS} \
	core_libvctr.so \
	-shared -o libvctr.so 
	cp libvctr.so ${Q_ROOT}/lib/

#-------------------------------------------
ut1 : ${TEST1_OBJS} ${Q_ROOT}/lib/libutils.so 
	gcc ${TEST1_OBJS} \
	${QCFLAGS} ${INCS} \
	core_libvctr.so \
	${VCTR_HMAP_SO} \
	${CHNK_HMAP_SO} \
	${TMPL_HMAP_SO} \
	${UTILS_SO} \
	${GUTILS_SO} \
	-o ut1  -lpthread ${QLDFLAGS} # -static-libasan
#-------------------------------------------
ut2 : ${TEST2_OBJS} ${Q_ROOT}/lib/libutils.so 
	gcc ${TEST2_OBJS} \
	${QCFLAGS} ${INCS} \
	core_libvctr.so \
	${VCTR_HMAP_SO} \
	${CHNK_HMAP_SO} \
	${TMPL_HMAP_SO} \
	${UTILS_SO} \
	${GUTILS_SO} \
	-o ut2 -lm -lpthread ${QLDFLAGS} # -static-libasan
#-------------------------------------------
ut_memo : ${TEST3_OBJS} ${Q_ROOT}/lib/libutils.so 
	gcc ${TEST3_OBJS} \
	${QCFLAGS} ${INCS} \
	core_libvctr.so \
	${VCTR_HMAP_SO} \
	${CHNK_HMAP_SO} \
	${TMPL_HMAP_SO} \
	${UTILS_SO} \
	${GUTILS_SO} \
	-o ut_memo -lm -lpthread ${QLDFLAGS} # -static-libasan
#-------------------------------------------


clean:
	rm -f *.o *.so ut1 ut2 ../test/*.o
	rm -f  ${Q_ROOT}/lib/core_libvctr.so 
	rm -f  ${Q_ROOT}/lib/libvctr.so 
	rm -f ${TMPL_HMAP_SO}
	rm -f ${VCTR_HMAP_SO}
	rm -f ${CHNK_HMAP_SO}
	rm -f ${GUTILS_SO} 
	rm -f ${UTILS_SO} 

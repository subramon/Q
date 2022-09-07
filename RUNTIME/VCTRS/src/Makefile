CC=gcc

CFLAGS := -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align 
CFLAGS += -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings 
CFLAGS += -Wunused-variable -Wunused-parameter -Wno-pedantic 
CFLAGS += -Wno-unused-label 
CFLAGS += -Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith 
CFLAGS += -Wmissing-declarations -Wredundant-decls -Wnested-externs 
CFLAGS += -Wshadow -Wcast-qual -Wcast-align -Wwrite-strings 
CFLAGS += -Wold-style-definition -Wsuggest-attribute=noreturn 
CFLAGS += -Wduplicated-cond -Wmisleading-indentation -Wnull-dereference 
CFLAGS += -Wduplicated-branches -Wrestrict

# CFLAGS += -fsanitize=address -fno-omit-frame-pointer 
# CFLAGS += -fsanitize=undefined 
# CFLAGS +=  -static-libasan # for address sanitizer

DFLAGS = -g -DDEBUG 
# DFLAGS = -O4
# Add -pg for grpof 

INCS := -I../inc/ 
INCS += -I../../../UTILS/inc/
INCS += -I../../CMEM/inc/
INCS += -I../../../TMPL_FIX_HASHMAP/inc/
INCS += -I../../../TMPL_FIX_HASHMAP/VCTR_HMAP/inc/
INCS += -I../../../TMPL_FIX_HASHMAP/CHNK_HMAP/inc/

TMPL=CASE1


all: core_libvctr.so  ut1 ut2 libvctr.so 

SRCS :=	vctr_add.c  
SRCS +=	vctr_cnt.c  
SRCS +=	vctr_chk.c
SRCS +=	vctr_del.c  
SRCS +=	vctr_eov.c  
SRCS +=	vctr_is.c  
SRCS +=	vctr_is_eov.c  
SRCS +=	vctr_name.c  
SRCS +=	vctr_num_chunks.c  
SRCS +=	vctr_num_elements.c  
SRCS +=	vctr_new_uqid.c  
SRCS +=	vctr_put.c  
SRCS +=	vctr_put_chunk.c  
SRCS +=	vctr_get_chunk.c  
SRCS +=	vctr_width.c  

SRCS +=	chnk_cnt.c  
SRCS +=	chnk_del.c  
SRCS +=	chnk_is.c  

OBJS = $(SRCS:.c=.o)

TEST1_SRCS := ../test/ut1.c
TEST1_OBJS = $(TEST1_SRCS:.c=.o)

TEST2_SRCS := ../test/ut2.c
TEST2_SRCS += ../../CMEM/src/aux_cmem.c 
TEST2_OBJS = $(TEST2_SRCS:.c=.o)

.c.o : 
	$(CC) -c -o $@ $< ${CFLAGS} ${DFLAGS} $(INCS) 

#-------------------------------------------
TMPL_HMAP_LOC = ../../../TMPL_FIX_HASHMAP/src/
TMPL_HMAP_SO  = ${Q_ROOT}/lib/libhmap.so

${TMPL_HMAP_SO} : 
	make -C ${TMPL_HMAP_LOC} ${TMPL_HMAP_SO}
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
	${CHNK_HMAP_SO} 
	gcc ${OBJS}  \
	-shared -o core_libvctr.so \
	${VCTR_HMAP_SO} ${CHNK_HMAP_SO} 
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

${Q_ROOT}/lib/libutils.so :
	make -C ../../../UTILS/src/
#-------------------------------------------
ut1 : ${TEST1_OBJS} ${Q_ROOT}/lib/libutils.so 
	gcc ${TEST1_OBJS} -o ut1 \
	core_libvctr.so \
	${VCTR_HMAP_SO} \
	${CHNK_HMAP_SO} \
	${TMPL_HMAP_SO} \
	${Q_ROOT}/lib/libutils.so
#-------------------------------------------
ut2 : ${TEST2_OBJS} ${Q_ROOT}/lib/libutils.so 
	gcc ${TEST2_OBJS} -o ut2 \
	core_libvctr.so \
	${VCTR_HMAP_SO} \
	${CHNK_HMAP_SO} \
	${TMPL_HMAP_SO} \
	${Q_ROOT}/lib/libutils.so \
	-lm 
#-------------------------------------------


clean:
	rm -f *.o *.so ut1 ut2
	rm -f  ${Q_ROOT}/lib/core_libvctr.so 
	rm -f  ${Q_ROOT}/lib/libvctr.so 
	rm -f ${TMPL_HMAP_SO}
	rm -f ${VCTR_HMAP_SO}
	rm -f ${CHNK_HMAP_SO}

CC=gcc

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
SRCS +=	vctr_is.c  
SRCS +=	vctr_is_eov.c  
SRCS +=	vctr_name.c  
SRCS +=	vctr_num_chunks.c  
SRCS +=	vctr_num_elements.c  
SRCS +=	vctr_new_uqid.c  
SRCS +=	vctr_put.c  
SRCS +=	vctr_put_chunk.c  

SRCS +=	chnk_cnt.c  
SRCS +=	chnk_is.c  

OBJS = $(SRCS:.c=.o)

TEST1_SRCS := ../test/ut1.c
TEST1_OBJS = $(TEST1_SRCS:.c=.o)

TEST2_SRCS := ../test/ut2.c
TEST2_OBJS = $(TEST2_SRCS:.c=.o)

.c.o : 
	$(CC) -c -o $@ $< ${CFLAGS} ${DFLAGS} $(INCS) 

#-------------------------------------------
TMPL_HMAP_LOC = ../../../TMPL_FIX_HASHMAP/src/
TMPL_HMAP_SO  = ${TMPL_HMAP_LOC}/libhmap.so

${TMPL_HMAP_SO} : 
	make -C ${TMPL_HMAP_LOC}
#-------------------------------------------
VCTR_HMAP_LOC = ../../../TMPL_FIX_HASHMAP/VCTR_HMAP
VCTR_HMAP_SO  = ${VCTR_HMAP_LOC}/libhmap_vctr.so

${VCTR_HMAP_SO} : 
	make -C ${VCTR_HMAP_LOC}
#-------------------------------------------
CHNK_HMAP_LOC = ../../../TMPL_FIX_HASHMAP/CHNK_HMAP
CHNK_HMAP_SO  = ${CHNK_HMAP_LOC}/libhmap_chnk.so

${CHNK_HMAP_SO} : 
	make -C ${CHNK_HMAP_LOC}
#-------------------------------------------
core_libvctr.so :  ${OBJS} ${VCTR_HMAP_SO}
	gcc ${OBJS} -shared -lm -o core_libvctr.so \
	${VCTR_HMAP_SO} ${CHNK_HMAP_SO}
#-------------------------------------------
libvctr.so: core_libvctr.so \
	cVector.o \
 	../../CMEM/src/cmem.o \
	../../CMEM/src/aux_lua_to_c.o
	gcc cVector.o \
	../../CMEM/src/cmem.o \
	../../CMEM/src/aux_lua_to_c.o \
	core_libvctr.so \
	-shared -lm -o libvctr.so 
#-------------------------------------------
ut1 : ${TEST1_OBJS}
	gcc ${TEST1_OBJS} -o ut1 -lm \
		core_libvctr.so ${VCTR_HMAP_SO} ${CHNK_HMAP_SO} ${TMPL_HMAP_SO} 
#-------------------------------------------
ut2 : ${TEST2_OBJS}
	gcc ${TEST2_OBJS} -o ut2 -lm \
		core_libvctr.so ${VCTR_HMAP_SO} ${CHNK_HMAP_SO} ${TMPL_HMAP_SO} 


clean:
	rm -f *.o *.so ut1 ut2

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
INCS += -I../../../
INCS += -I../../../TMPL_FIX_HASHMAP/inc/
INCS += -I../../../TMPL_FIX_HASHMAP/VCTR_HMAP/inc/
INCS += -I../../../TMPL_FIX_HASHMAP/CHNK_HMAP/inc/

TMPL=CASE1


all: libvctrs.so  ut1

SRCS :=	vctr_is.c  
SRCS +=	vctr_new_uqid.c  
SRCS +=	vctr_add.c  
SRCS +=	vctr_del.c  
SRCS +=	vctr_cnt.c  
SRCS +=	vctr_name.c  

OBJS = $(SRCS:.c=.o)

TEST_SRCS := ../test/ut1.c
TEST_OBJS = $(TEST_SRCS:.c=.o)

.c.o : 
	$(CC) -c -o $@ $< ${CFLAGS} ${DFLAGS} $(INCS) 

VEC_HMAP_LOC = ../../../TMPL_FIX_HASHMAP/VCTR_HMAP
VEC_HMAP_SO  = ${VEC_HMAP_LOC}/libhmap_vctr.so

${VEC_HMAP_SO} : 
	make -C ${VEC_HMAP_LOC}

libvctrs.so :  ${OBJS} ${VEC_HMAP_SO}
	gcc ${OBJS} -shared -lm -o libvctrs.so \
	${VEC_HMAP_SO}

ut1 : ${TEST_OBJS}
	gcc ${TEST_OBJS} -o ut1 \
		-lm \
		libvctrs.so \
		${VEC_HMAP_SO}

clean:
	rm -f *.o *.so ut1

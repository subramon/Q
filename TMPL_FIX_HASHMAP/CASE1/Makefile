
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

INCS := -I./inc/ 
INCS += -I../inc/ 

TMPL=CASE1

all: libhmap_${TMPL}.so test_${TMPL} test_merge_${TMPL}

SRCS :=	../src/spooky_hash.c  
SRCS +=	../src/rdtsc.c  
SRCS +=	../src/rs_hmap_aux.c  
SRCS +=	../src/rs_hmap_instantiate.c  
SRCS +=	../src/rs_hmap_pr.c  
SRCS +=	../src/rs_hmap_chk.c  
SRCS +=	../src/rs_hmap_del.c  
SRCS +=	../src/rs_hmap_destroy.c  
SRCS +=	../src/rs_hmap_get.c  
SRCS +=	../src/rs_hmap_insert.c  
SRCS +=	../src/rs_hmap_merge.c  
SRCS +=	../src/rs_hmap_put.c  
SRCS +=	../src/rs_hmap_resize.c  
SRCS +=	../src/rs_hmap_row_bindmp.c  
SRCS +=	../src/calc_new_size.c  
SRCS +=	../src/murmurhash.c  
SRCS +=	../src/fasthash.c  

OBJS = $(SRCS:.c=.o)

CUSTOM_SRCS +=	./src/rsx_pr.c  
CUSTOM_SRCS +=	./src/rsx_key_cmp.c  
CUSTOM_SRCS +=	./src/rsx_val_update.c  
CUSTOM_SRCS +=	./src/rsx_key_ordr.c  
CUSTOM_SRCS +=	./src/rsx_bkt_chk.c  
CUSTOM_SRCS +=	./src/rsx_set_hash.c  

CUSTOM_OBJS = $(CUSTOM_SRCS:.c=.o)

HFILE = ./inc/_${TMPL}_rs_hmap_struct.h

${HFILE} : ../inc/rs_hmap_struct.h 
	cat ../inc/rs_hmap_struct.h | \
		sed s"/rs_hmap_t/${TMPL}_rs_hmap_t/"g > \
		${HFILE}

${CUSTOM_SRCS} : ${HFILE}

.c.o : 
	$(CC) -c -o $@ $< ${CFLAGS} ${DFLAGS} $(INCS) 

libhmap_${TMPL}.so: ${OBJS} ${CUSTOM_OBJS}   ./inc/*.h 
	gcc  ${CFLAGS} ${DFLAGS} ${OBJS} ${CUSTOM_OBJS} \
	${INCS} -shared -lm -o libhmap_${TMPL}.so  -ldl

test_${TMPL} : libhmap_${TMPL}.so ./test/test_${TMPL}.c 
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test_${TMPL}.c \
	libhmap_${TMPL}.so -o test_${TMPL} -ldl

test_merge_${TMPL} : libhmap_${TMPL}.so ./test/test_merge_${TMPL}.c 
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test_merge_${TMPL}.c \
	libhmap_${TMPL}.so -o test_merge_${TMPL} -ldl

test_fastrem : ./test/test_fastrem.c 
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test_fastrem.c \
	  src/get_time_usec.c \
	-o test_fastrem

clean:
	rm -f *.o test_hmap *.so ./src/*.o test_kUI8_vUI4
	rm -f ./${TMPL}/src/*.o

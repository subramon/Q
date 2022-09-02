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

INCS += -I./inc/ 
INCS += -I../inc/ 
INCS += -I../../UTILS/inc/

TMPL=vctr

all: libhmap_${TMPL}.so # TODO test_${TMPL} 

SRCS1 :=	../src/spooky_hash.c  
SRCS1 +=	../src/rdtsc.c  
SRCS1 +=	../src/murmurhash.c  
SRCS1 +=	../src/fasthash.c  
SRCS1 +=	../src/calc_new_size.c  

SRCS2 :=	./src/rs_hmap_aux.c  
SRCS2 +=	./src/rs_hmap_instantiate.c  
SRCS2 +=	./src/rs_hmap_pr.c  
SRCS2 +=	./src/rs_hmap_chk.c  
SRCS2 +=	./src/rs_hmap_del.c  
SRCS2 +=	./src/rs_hmap_destroy.c  
SRCS2 +=	./src/rs_hmap_get.c  
SRCS2 +=	./src/rs_hmap_insert.c  
SRCS2 +=	./src/rs_hmap_merge.c  
SRCS2 +=	./src/rs_hmap_put.c  
SRCS2 +=	./src/rs_hmap_resize.c  
SRCS2 +=	./src/rs_hmap_row_bindmp.c  

OBJS1 = $(SRCS1:.c=.o)
OBJS2 = $(SRCS2:.c=.o)


OBJS := ${OBJS1} ${OBJS2}

rs_hmap_aux.o : ./src/rs_hmap_aux.c 

CDIR=${PWD}
WDIR=${CDIR}/..
./src/rs_hmap_aux.c : ../src/rs_hmap_aux.c
	echo "WDIR = ${WDIR}"
	echo "CDIR = ${CDIR}"
	cd ..; bash specialize.sh ${WDIR} src c_files.txt ${TMPL} ${CDIR}
	cd ..; bash specialize.sh ${WDIR} inc h_files.txt ${TMPL} ${CDIR}
	cat ./src/rs_hmap_instantiate.c | \
	  	sed s"/^rs_hmap_instantiate/${TMPL}_rs_hmap_instantiate/"g \
		> _tempf
	mv _tempf ./src/rs_hmap_instantiate.c
	cat ./inc/rs_hmap_instantiate.h | \
	  	sed s"/^rs_hmap_instantiate/${TMPL}_rs_hmap_instantiate/"g \
		> _tempf
	mv _tempf ./src/rs_hmap_instantiate.h

CUSTOM_SRCS +=	./src/rsx_pr.c  
CUSTOM_SRCS +=	./src/rsx_key_cmp.c  
CUSTOM_SRCS +=	./src/rsx_val_update.c  
CUSTOM_SRCS +=	./src/rsx_key_ordr.c  
CUSTOM_SRCS +=	./src/rsx_bkt_chk.c  
CUSTOM_SRCS +=	./src/rsx_set_hash.c  

CUSTOM_OBJS = $(CUSTOM_SRCS:.c=.o)

.c.o : 
	$(CC) -c -o $@ $< ${CFLAGS} ${DFLAGS} $(INCS) 

libhmap_${TMPL}.so: ${OBJS} ${CUSTOM_OBJS}   ./inc/*.h 
	gcc  ${CFLAGS} ${DFLAGS} ${OBJS} ${CUSTOM_OBJS} \
	${INCS} -shared -lm -o libhmap_${TMPL}.so  -ldl

test_${TMPL} : libhmap_${TMPL}.so ./test/test_${TMPL}.c 
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test_${TMPL}.c \
	libhmap_${TMPL}.so -o test_${TMPL} -ldl

# TODO Need to delete INCS2 as well.
clean:
	rm -f *.o ./src/*.o ${SRCS2}
	rm -f libhmap_${TMPL}.so

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

TMPL=chnk
MYSO = libhmap_${TMPL}.so
EXTSO = ${Q_ROOT}/lib/${MYSO} 

all: libhmap_${TMPL}.so ${EXTSO}

SRCS2 :=	./src/${TMPL}_rs_hmap_instantiate.c  
SRCS2 +=	./src/rs_hmap_pr.c  
SRCS2 +=	./src/rs_hmap_chk.c  
SRCS2 +=	./src/rs_hmap_del.c  
SRCS2 +=	./src/rs_hmap_destroy.c  
SRCS2 +=	./src/rs_hmap_get.c  
SRCS2 +=	./src/rs_hmap_insert.c  
SRCS2 +=	./src/rs_hmap_merge.c  
SRCS2 +=	./src/rs_hmap_put.c  
SRCS2 +=	./src/rs_hmap_resize.c  
SRCS2 +=	./src/rs_hmap_row_dmp.c  
SRCS2 +=	./src/rs_hmap_set_fn_ptrs.c  
SRCS2 +=	./src/rs_hmap_freeze.c  
SRCS2 +=	./src/rs_hmap_unfreeze.c  

OBJS2 = $(SRCS2:.c=.o)


OBJS := ${OBJS2}

${TMPL}_rs_hmap_instantiate.o : ./src/${TMPL}_rs_hmap_instantiate.c 

CDIR=${PWD}
WDIR=${CDIR}/..
./src/${TMPL}_rs_hmap_instantiate.c : 
	echo "WDIR = ${WDIR}"
	echo "CDIR = ${CDIR}"
	cd ..; bash specialize.sh ${WDIR} src c_files.txt ${TMPL} ${CDIR}
	cd ..; bash specialize.sh ${WDIR} inc h_files.txt ${TMPL} ${CDIR}
	mv ./inc/rs_hmap_struct.h ./inc/${TMPL}_rs_hmap_struct.h
	cat ./inc/${TMPL}_rs_hmap_struct.h | \
	  	sed s"/__RS_HMAP_STRUCT/__${TMPL}_RS_HMAP_STRUCT/"g \
		> _tempf
	mv _tempf ./inc/${TMPL}_rs_hmap_struct.h
	cat ./src/rs_hmap_instantiate.c | \
	  	sed s"/^rs_hmap_instantiate/${TMPL}_rs_hmap_instantiate/"g \
		> _tempf
	mv _tempf ./src/${TMPL}_rs_hmap_instantiate.c
	cat ./inc/rs_hmap_instantiate.h | \
	  	sed s"/^rs_hmap_instantiate/${TMPL}_rs_hmap_instantiate/"g \
		> _tempf
	cp _tempf ./inc/${TMPL}_rs_hmap_instantiate.h # TODO FIX ugly
	mv _tempf ./inc/rs_hmap_instantiate.h

CUSTOM_SRCS +=	./src/rsx_pr.c  
CUSTOM_SRCS +=	./src/rsx_key_cmp.c  
CUSTOM_SRCS +=	./src/rsx_val_update.c  
CUSTOM_SRCS +=	./src/rsx_key_ordr.c  
CUSTOM_SRCS +=	./src/rsx_bkt_chk.c  
CUSTOM_SRCS +=	./src/rsx_set_hash.c  

CUSTOM_OBJS = $(CUSTOM_SRCS:.c=.o)

.c.o : 
	$(CC) -c -o $@ $< ${CFLAGS} ${DFLAGS} $(INCS) 


${EXTSO} : ${MYSO}
	cp ${MYSO} ${EXTSO}

libhmap_${TMPL}.so: ${OBJS} ${CUSTOM_OBJS}   ./inc/*.h 
	gcc  ${CFLAGS} ${DFLAGS} ${OBJS} ${CUSTOM_OBJS} \
	${INCS} -shared -lm -o libhmap_${TMPL}.so  -ldl

test_${TMPL} : libhmap_${TMPL}.so ./test/test_${TMPL}.c 
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test_${TMPL}.c \
	libhmap_${TMPL}.so -o test_${TMPL} -ldl

# TODO Need to delete INCS2 as well.
clean:
	rm -f *.o ./src/*.o ${SRCS2} *.so ${EXTSO}

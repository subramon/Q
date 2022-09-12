#!/bin/ballsh
INCS := -I./inc/
INCS += -I../../UTILS/inc/
INCS += -I../LuaJIT-2.1.0-beta3/src/
INCS += -I../LuaJIT-2.1.0-beta3/src/inc/
INCS += -I../../TMPL_FIX_HASHMAP/inc/
INCS += -I../../TMPL_FIX_HASHMAP/VCTR_HMAP/inc/
INCS += -I../../TMPL_FIX_HASHMAP/CHNK_HMAP/inc/

MYSO = libgutils.so
EXTSO = ${Q_ROOT}/lib/${MYSO}
all : ${MYSO} ${EXTSO} 


SRCS := ./src/l2_file_name.c 
SRCS += ./src/init_globals.c 
SRCS += ./src/mod_mem_used.c 
OBJS = $(SRCS:.c=.o)
#----------------------------------


.c.o : 
	$(CC) -c -o $@ $< ${QC_FLAGS} ${DFLAGS} $(INCS) 

${MYSO} : ${OBJS}
	gcc -shared ${OBJS} -o ${MYSO}

${EXTSO} : ${MYSO}
	cp ${MYSO} ${EXTSO}

clean :
	rm -f ${OBJS}
	rm -f ${MYSO} ${EXTSO}


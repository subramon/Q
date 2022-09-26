#!/bin/ballsh
INCS := -I./inc/
INCS += -I../../UTILS/inc/
INCS += -I../LuaJIT-2.1.0-beta3/src/
INCS += -I../LuaJIT-2.1.0-beta3/src/inc/
INCS += -I../../TMPL_FIX_HASHMAP/inc/
INCS += -I../../TMPL_FIX_HASHMAP/VCTR_HMAP/inc/
INCS += -I../../TMPL_FIX_HASHMAP/CHNK_HMAP/inc/

MYSO  = libcgutils.so
EXTMYSO = ${Q_ROOT}/lib/${MYSO}

ALTSO = liblgutils.so 
EXTALTSO = ${Q_ROOT}/lib/${ALTSO}

UTILS_LOC = ../../UTILS/src/
UTILS_SO = ${Q_ROOT}/lib/libutils.so

all : ${MYSO} ${EXTMYSO} ${ALTSO} ${EXTALTSO}

${UTILS_SO} : 
	make -C ${UTILS_LOC} 


RS_LIBS := -lpthread
RS_LIBS += -levent


SRCS := ./src/l2_file_name.c 
SRCS += ./src/init_globals.c 
SRCS += ./src/get_req_type.c 
SRCS += ./src/mod_mem_used.c 
SRCS += ./src/webserver.c 
SRCS += ./src/mem_mgr.c 
SRCS += ./src/extract_api_args.c 
SRCS += ./src/process_req.c 
SRCS += ./src/handler.c 
SRCS += ./src/read_configs.c 

SRCS += ./../../UTILS/src/rmtree.c 
SRCS += ./../../UTILS/src/rs_mmap.c 
OBJS = $(SRCS:.c=.o)
#----------------------------------

ALTSRCS := ./src/lgutils.c 

ALTOBJS = $(ALTSRCS:.c=.o)


.c.o : 
	$(CC) -c -o $@ $< ${QC_FLAGS} ${DFLAGS} $(INCS) 

${MYSO} : ${OBJS}
	gcc -shared ${OBJS} -o ${MYSO} ${RS_LIBS}

${EXTMYSO} : ${MYSO}
	cp ${MYSO} ${EXTMYSO}

${ALTSO} : ${ALTOBJS} ${UTILS_SO}
	gcc -shared ${ALTOBJS}  ${UTILS_SO} -o ${ALTSO} ${RS_LIBS}

${EXTALTSO} : ${ALTSO}
	cp ${ALTSO} ${EXTALTSO}

clean :
	rm -f ${OBJS}
	rm -f ${MYSO} ${EXTMYSO}
	rm -f ${ALTSO} ${EXTALTSO}


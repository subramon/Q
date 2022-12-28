#!/bin/ballsh
INCS := -I./inc/
INCS += -I../../UTILS/inc/
INCS += -I../LuaJIT-2.1.0-beta3/src/
INCS += -I../LuaJIT-2.1.0-beta3/src/inc/
INCS += -I../../TMPL_FIX_HASHMAP/inc/
INCS += -I../../TMPL_FIX_HASHMAP/VCTR_HMAP/inc/
INCS += -I../../TMPL_FIX_HASHMAP/CHNK_HMAP/inc/

QJIT_AUX_SO  = libqjitaux.so
EXT_QJIT_AUX_SO = ${Q_ROOT}/lib/${QJIT_AUX_SO}

MYSO  = libcgutils.so
EXTMYSO = ${Q_ROOT}/lib/${MYSO}

ALTSO = liblgutils.so 
EXTALTSO = ${Q_ROOT}/lib/${ALTSO}

UTILS_LOC = ../../UTILS/src/
UTILS_SO = ${Q_ROOT}/lib/libutils.so

all : ${MYSO} ${EXTMYSO} ${ALTSO} ${EXTALTSO} ${QJIT_AUX_SO} ${EXT_QJIT_AUX_SO}

${UTILS_SO} : 
	make -C ${UTILS_LOC} 


VCTR_HMAP_LOC = ../../../TMPL_FIX_HASHMAP/VCTR_HMAP
VCTR_HMAP_SO  = ${Q_ROOT}/lib/libhmap_vctr.so

${VCTR_HMAP_SO} : 
	make -C ${VCTR_HMAP_LOC} ${VCTR_HMAP_SO}
#-------------------------------------------
CHNK_HMAP_LOC = ../../../TMPL_FIX_HASHMAP/CHNK_HMAP
CHNK_HMAP_SO  = ${Q_ROOT}/lib/libhmap_chnk.so

${CHNK_HMAP_SO} : 
	make -C ${CHNK_HMAP_LOC} ${CHNK_HMAP_SO}
RS_LIBS := -lpthread
RS_LIBS += -levent
RS_LIBS += -latomic  # This was neeeded on Raspberry Pi 
# Otherwise, some of the atomics were not found 

AUX_SRCS := ./src/extract_api_args.c 
AUX_SRCS += ./src/free_globals.c 
AUX_SRCS += ./src/get_req_type.c 
AUX_SRCS += ./src/handler.c 
AUX_SRCS += ./src/import_tbsp.c 
AUX_SRCS += ./src/init_globals.c 
AUX_SRCS += ./src/init_session.c 
AUX_SRCS += ./src/mem_mgr.c 
AUX_SRCS += ./src/read_configs.c 
AUX_SRCS += ./src/process_req.c 
AUX_SRCS += ./src/webserver.c 

AUX_SRCS += ./../../UTILS/src/rmtree.c 
AUX_SRCS += ./../../UTILS/src/isdir.c 
AUX_OBJS = $(AUX_SRCS:.c=.o)

SRCS := ./src/l2_file_name.c 
SRCS += ./src/mod_mem_used.c 


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

${QJIT_AUX_SO} : ${AUX_OBJS}
	gcc -shared ${AUX_OBJS} \
		${VCTR_HAMP_SO} \
		${CHNK_HAMP_SO} \
		-o ${QJIT_AUX_SO} ${RS_LIBS} 

${EXT_QJIT_AUX_SO} : ${QJIT_AUX_SO}
	cp ${QJIT_AUX_SO} ${EXT_QJIT_AUX_SO}

${ALTSO} : ${ALTOBJS} ${UTILS_SO}
	gcc -shared ${ALTOBJS}  ${UTILS_SO} -o ${ALTSO} ${RS_LIBS}

${EXTALTSO} : ${ALTSO}
	cp ${ALTSO} ${EXTALTSO}

clean :
	rm -f ${OBJS} *.so src/*.o
	rm -f ${QJIT_AUX_SO} ${EXT_QJIT_AUX_SO}
	rm -f ${MYSO} ${EXTMYSO}
	rm -f ${ALTSO} ${EXTALTSO}


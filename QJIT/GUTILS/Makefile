#!/bin/ballsh
CC = gcc

INCS := -I./inc/
INCS += -I${RSUTILS_SRC_ROOT}/RSUTILS/inc/
#-- for hashmaps for chnk and vector 
INCS += -I${RSHMAP_SRC_ROOT}/RSHMAP/fixed_len_kv/common/inc/
INCS += -I../HMAPS/VCTR/inc/
INCS += -I../HMAPS/VCTR/gen_inc/
INCS += -I../HMAPS/CHNK/inc/
INCS += -I../HMAPS/CHNK/gen_inc/
#----------------------
INCS += -I../../RUNTIME/VCTR/inc/
INCS += -I../LuaJIT-2.1.0-beta3/src/
INCS += -I../LuaJIT-2.1.0-beta3/src/inc/

QJIT_AUX_SO  = libqjitaux.so
MYSO  = libcgutils.so
ALTSO = liblgutils.so 


all : ${MYSO} ${ALTSO} ${QJIT_AUX_SO}

#-------------------------------------------
RS_LIBS := -lpthread
RS_LIBS += -levent
RS_LIBS += -latomic  # This was neeeded on Raspberry Pi 
# Otherwise, some of the atomics were not found 

AUX_SRCS := ./src/extract_api_args.c 
AUX_SRCS += ./src/extract_name_value.c 
AUX_SRCS += ./src/free_globals.c 
AUX_SRCS += ./src/get_req_type.c 
AUX_SRCS += ./src/get_body.c 
AUX_SRCS += ./src/lua_state.c 
AUX_SRCS += ./src/mod_mem_used.c 
AUX_SRCS += ./src/handler.c 
AUX_SRCS += ./src/import_tbsp.c 
AUX_SRCS += ./src/init_globals.c 
AUX_SRCS += ./src/init_session.c 
AUX_SRCS += ./src/mem_mgr.c 
AUX_SRCS += ./src/read_configs.c 
AUX_SRCS += ./src/process_req.c 
AUX_SRCS += ./src/webserver.c 

SRCS := ./src/l2_file_name.c 
SRCS += ./src/mod_mem_used.c 
SRCS += ./src/vctr_name_to_uqid.c 

OBJS = $(SRCS:.c=.o)
#----------------------------------

./src/process_req.o : QCFLAGS += -Wno-unused-parameter

ALTSRCS := ./src/lgutils.c 

ALTOBJS = $(ALTSRCS:.c=.o)


.c.o : 
	$(CC) -c -o $@ $< ${QCFLAGS} $(INCS) 

src/process_req.o : QC_FLAGS += -Wunused-parameter

${MYSO} : ${OBJS}
	gcc -shared ${OBJS} -o ${MYSO} ${RS_LIBS} ${QLDFLAGS}

${QJIT_AUX_SO} : ${AUX_OBJS} ${VCTRS_SO} 
	gcc -shared ${AUX_OBJS} \
		-o ${QJIT_AUX_SO} ${RS_LIBS} ${QLDFLAGS}

${ALTSO} : ${ALTOBJS} ${UTILS_SO}
	gcc -shared ${ALTOBJS}  ${UTILS_SO} -o ${ALTSO} \
		${RS_LIBS} ${QLDFLAGS}

clean :
	rm -f ${OBJS} *.so src/*.o
	rm -f ${QJIT_AUX_SO} 
	rm -f ${MYSO} 
	rm -f ${ALTSO} 


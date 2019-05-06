# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS= -I.  -I../../../UTILS/inc/ -I../gen_inc/  -I../inc/ -I../../../UTILS/gen_inc 

INCDIR = ../gen_inc/

UDIR= ${Q_SRC_ROOT}/UTILS/lua/

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : libload_csv.so 
	
../../UTILS/gen_inc/_is_valid_chars_for_num.h :
	make -C ../../../UTILS/src/ 

../gen_inc/_SC_to_TM.h : 
	mkdir -p ../gen_inc/
	lua ${UDIR}/cli_extract_func_decl.lua ../src/SC_to_TM.c ${INCDIR}

../gen_inc/_get_cell.h : 
	mkdir -p ../gen_inc/
	lua ${UDIR}/cli_extract_func_decl.lua ../src/get_cell.c ${INCDIR}

../gen_inc/_set_up_qtypes.h : 
	mkdir -p ../gen_inc/
	lua ${UDIR}/cli_extract_func_decl.lua ../src/set_up_qtypes.c ${INCDIR}

../gen_inc/_new_get_cell.h : 
	mkdir -p ../gen_inc/
	lua ${UDIR}/cli_extract_func_decl.lua ../src/new_get_cell.c ${INCDIR}

../gen_inc/_txt_to_B1.h : 
	mkdir -p ../gen_inc/
	lua ${UDIR}/cli_extract_func_decl.lua ../src/txt_to_B1.c ${INCDIR}

../gen_inc/_txt_to_SC.h : 
	mkdir -p ../gen_inc/
	lua ${UDIR}/cli_extract_func_decl.lua ../src/txt_to_SC.c ${INCDIR}
  
#----------------------------------
../gen_src/_txt_to_I1.c :
	lua gen_code_I.lua 
../gen_src/_txt_to_I2.c :
	lua gen_code_I.lua 
../gen_src/_txt_to_I4.c :
	lua gen_code_I.lua 
../gen_src/_txt_to_I8.c :
	lua gen_code_I.lua 
../gen_src/_txt_to_F4.c :
	lua gen_code_F.lua 
../gen_src/_txt_to_F8.c :
	lua gen_code_F.lua 
#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so

../src/SC_to_TM.c : ../gen_inc/_SC_to_TM.h

../src/get_cell.c : ../gen_inc/_get_cell.h

../src/new_get_cell.c : ../gen_inc/_new_get_cell.h

../src/set_up_qtypes.c : ../gen_inc/_set_up_qtypes.h

../src/txt_to_SC.c : ../gen_inc/_txt_to_SC.h

../src/txt_to_B1.c : ../gen_inc/_txt_to_B1.h

#../src/load_csv_fast.c : ../gen_inc/_load_csv_fast.h

SRC_FILES =  \
	../src/SC_to_TM.c  \
	../src/get_cell.c  \
	../src/new_get_cell.c  \
	../src/set_up_qtypes.c  \
	../src/txt_to_SC.c \
	../src/txt_to_B1.c \
	../src/load_csv_fast.c \

AUX_FILES = \
	../../../UTILS/src/is_valid_chars_for_num.c 

GEN_FILES = \
	../gen_src/_txt_to_I1.c \
	../gen_src/_txt_to_I2.c  \
	../gen_src/_txt_to_I4.c  \
	../gen_src/_txt_to_I8.c  \
	../gen_src/_txt_to_F4.c  \
	../gen_src/_txt_to_F8.c  

XXXX := $(GEN_FILES:.c=.h) # TODO: clean up XXX , do it in one step
GEN_INC_FILES := $(subst gen_src,gen_inc, ${XXXX})

libload_csv.so : ${SRC_FILES} ${GEN_FILES} ${AUX_FILES} 
	gcc ${QC_FLAGS} ${Q_LINK_FLAGS} ${SRC_FILES} ${GEN_FILES} ${AUX_FILES} ${CFLAGS} ${INCS} -shared -o libload_csv.so
	test -d  ${Q_BUILD_DIR}/src/
	cp ${SRC_FILES}      ${Q_BUILD_DIR}/src/
	cp ${GEN_FILES}      ${Q_BUILD_DIR}/src/
	cp ../inc/SC_to_TM.h ${Q_BUILD_DIR}/include/
	cp ${GEN_INC_FILES}        ${Q_BUILD_DIR}/include/
	cp ../gen_inc/_get_cell.h  ${Q_BUILD_DIR}/include/
	cp ../gen_inc/_new_get_cell.h  ${Q_BUILD_DIR}/include/
	cp ../gen_inc/_set_up_qtypes.h  ${Q_BUILD_DIR}/include/
	cp ../gen_inc/_txt_to_SC.h ${Q_BUILD_DIR}/include/
	cp ../gen_inc/_txt_to_B1.h ${Q_BUILD_DIR}/include/
	cp ../inc/load_csv_fast.h ${Q_BUILD_DIR}/include/

test_q : libload_csv.so
	echo "TODO"

test_c :  libload_csv.so
	echo "TODO"

test : test_q test_c


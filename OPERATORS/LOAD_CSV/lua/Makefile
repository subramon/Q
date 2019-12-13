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

#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so

../src/SC_to_TM.c : ../inc/SC_to_TM.h

../src/TM_to_SC.c : ../inc/TM_to_SC.h

../src/TM_to_I8.c : ../inc/TM_to_I8.h

../src/get_cell.c : ../inc/get_cell.h

../src/new_load_csv_fast.c : ../inc/new_load_csv_fast.h

SRC_FILES =  \
	../src/SC_to_TM.c  \
	../src/TM_to_SC.c  \
	../src/TM_to_I8.c  \
	../src/get_cell.c  \
	../src/new_load_csv_fast.c \

AUX_FILES = \
	../../../UTILS/src/is_valid_chars_for_num.c 

../gen_src/_TM_to_hour.c :
	luajit generator.lua

GEN_FILES = \
	../gen_src/_TM_to_hour.c \
	../gen_src/_TM_to_isdst.c \
	../gen_src/_TM_to_mday.c \
	../gen_src/_TM_to_min.c \
	../gen_src/_TM_to_mon.c \
	../gen_src/_TM_to_sec.c \
	../gen_src/_TM_to_wday.c \
	../gen_src/_TM_to_yday.c \
	../gen_src/_TM_to_year.c \


XXXX := $(GEN_FILES:.c=.h) # TODO: clean up XXX , do it in one step
GEN_INC_FILES := $(subst gen_src,gen_inc, ${XXXX})

libload_csv.so : ${SRC_FILES} ${GEN_FILES} ${AUX_FILES} 
	gcc ${QC_FLAGS} ${Q_LINK_FLAGS} ${SRC_FILES} ${GEN_FILES} ${AUX_FILES} ${CFLAGS} ${INCS} -shared -o libload_csv.so
	test -d  ${Q_BUILD_DIR}/src/
	cp ${SRC_FILES}      ${Q_BUILD_DIR}/src/
	cp ../inc/SC_to_TM.h ${Q_BUILD_DIR}/include/
	cp ../inc/TM_to_SC.h ${Q_BUILD_DIR}/include/
	cp ../inc/get_cell.h ${Q_BUILD_DIR}/include/
	cp ../inc/TM_to_I8.h ${Q_BUILD_DIR}/include/
	cp ../inc/new_load_csv_fast.h ${Q_BUILD_DIR}/include/

test_q : libload_csv.so
	echo "TODO"

test_c :  libload_csv.so
	echo "TODO"

test : test_q test_c


# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ -I../../../UTILS/gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : libwhere.so

all_for_dc:
	echo "Nothing to do"
	
#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so

AUX_FILES = \
	    ../../../UTILS/src/get_bit_u64.c \
	    ../../../UTILS/src/set_bit_u64.c \

libwhere.so : ${GEN_FILES} where_B1.tmpl where_BL.tmpl
	qjit generator.lua
	gcc ${GEN_FILES} ${AUX_FILES} ${QCFLAGS} ${INCS} -shared -o libwhere.so

test_q : libwhere.so
	echo "TODO"

test_c :  libwhere.so
	echo "TODO"

test : test_q test_c

GEN_FILES = \
	../gen_src/where_F4_BL.c \
	../gen_src/where_F8_BL.c \
	../gen_src/where_I1_BL.c \
	../gen_src/where_I2_BL.c \
	../gen_src/where_I4_BL.c \
	../gen_src/where_I8_BL.c \
	../gen_src/where_F4_B1.c \
	../gen_src/where_F8_B1.c \
	../gen_src/where_I1_B1.c \
	../gen_src/where_I2_B1.c \
	../gen_src/where_I4_B1.c \
	../gen_src/where_I8_B1.c \



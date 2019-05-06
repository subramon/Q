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

libwhere.so : ${GEN_FILES} \
	where.tmpl
	luajit generator.lua
	gcc ${GEN_FILES} ${AUX_FILES} ${CFLAGS} ${INCS} ${Q_LINK_FLAGS} -o libwhere.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/

test_q : libwhere.so
	echo "TODO"

test_c :  libwhere.so
	echo "TODO"

test : test_q test_c

GEN_FILES = \
	../gen_src/_where_F4.c \
	../gen_src/_where_F8.c \
	../gen_src/_where_I1.c \
	../gen_src/_where_I2.c \
	../gen_src/_where_I4.c \
	../gen_src/_where_I8.c \

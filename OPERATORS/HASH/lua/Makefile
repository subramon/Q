# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS= -I.  -I../../../UTILS/inc/  -I../gen_inc/ -I../inc/ -I../../../UTILS/gen_inc

UDIR= ${Q_SRC_ROOT}/UTILS/lua/

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : libhash.so

all_for_dc :
	echo "Done"
	
clean : 
	rm -r -f ../gen_src;
	rm -r -f ../gen_inc;
	rm -f _*
	rm -f ../gen_src/*
	rm -f ../gen_inc/*
	rm -f *.so

libhash.so :
	luajit generator.lua
	gcc ${QC_FLAGS} ${Q_LINK_FLAGS} ${CFLAGS} ${INCS} ../../../UTILS/src/spooky_hash.c ../gen_src/*.c -shared -o libhash.so
	test -d  ${Q_BUILD_DIR}/src/
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/

test_q : libhash.so
	echo "TODO"

test_c :  libl_hash.so
	echo "TODO"

test : test_q test_c


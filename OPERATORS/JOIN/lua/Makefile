# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ -I../../../UTILS/gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : libjoin.so

all_for_dc :
	echo "Nothing to do" 
	
#AUX_FILES = ../../../UTILS/src/bytes_to_bits.c

../../../UTILS/gen_inc/_bytes_to_bits.h :
	make -C ../../../UTILS/src/

#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so

libjoin.so : ${GEN_FILES} \
	join.tmpl
	luajit generator.lua
	gcc ../gen_src/*.c ${AUX_FILES} ${CFLAGS} ${INCS} ${Q_LINK_FLAGS} -o libjoin.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/

test_q : libjoin.so
	echo "TODO"

test_c :  libjoin.so
	echo "TODO"

test : test_q test_c

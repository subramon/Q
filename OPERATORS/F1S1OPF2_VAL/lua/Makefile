# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ -I../../../UTILS/gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : libf1s1opf2_val.so

all_for_dc :
	luajit gen_specialize.lua
	
../../../UTILS/gen_inc/_bytes_to_bits.h :
	make -C ../../../UTILS/src/

#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so
	rm -f *_val_specialize.lua

libf1s1opf2_val.so : ${GEN_FILES} \
	f1s1opf2_val.tmpl
	luajit gen_specialize.lua
	luajit generator.lua
	gcc ../gen_src/*.c  ${CFLAGS} ${INCS} ${Q_LINK_FLAGS} -o libf1s1opf2_val.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/

test_q : libf1s1opf2_val.so
	echo "TODO"

test_c :  libf1s1opf2_val.so
	echo "TODO"

test : test_q test_c

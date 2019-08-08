# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  \
	-I../../../UTILS/inc/ \
	-I../../../UTILS/gen_inc/ \
	-I../gen_inc/ \
	-I../inc/

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : libf_to_s.so _f_to_s.lua

all_for_dc : \
	_f_to_s.lua
	
#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so
		

libf_to_s.so : 
	luajit generator.lua operators.lua
	gcc ../src/*.c ../gen_src/*.c ${CFLAGS} ${INCS} -shared -o libf_to_s.so 
	test -d ${Q_BUILD_DIR}
	cp ../src/*.c ${Q_BUILD_DIR}/src/
	cp ../inc/*.h ${Q_BUILD_DIR}/include/

_f_to_s.lua : 
	lua pkg_f_to_s.lua

test_q : libf_to_s.so
	luajit ../test/test_f_to_s.lua
	echo "TODO"

test_c :  libf_to_s.so
	bash ../test/test_rand.sh
	echo "TODO"

test : test_q test_c

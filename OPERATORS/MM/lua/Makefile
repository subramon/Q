# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} -Werror

all : libmm_mul.so

all_for_dc :
	echo "Nothing to do"
	
#----------------------------------
clean :
#-------------
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so
		

libmm_mul.so : 
	luajit generator.lua operators.lua
	gcc ../gen_src/*.c ${CFLAGS} ${INCS} -shared -o libmm_mul.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/


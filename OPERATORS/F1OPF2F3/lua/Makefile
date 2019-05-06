# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ -I../../../UTILS/gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} -Werror

all : libf1opf2f3.so

all_for_dc :
	echo "Nothing to do"

#----------------------------------
clean :
#-------------
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
#-------------
../gen_src/_split_I8_I4.c : split.tmpl split_specialize.lua
	luajit generator.lua operators.lua
		
libf1opf2f3.so : ../gen_src/_split_I8_I4.c 
	gcc ../gen_src/*.c ${CFLAGS} ${INCS} -shared -o libf1opf2f3.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/


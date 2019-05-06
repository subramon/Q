# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ -I../../../UTILS/gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : libgroupby.so

all_for_dc :
	echo "nothing to do"
	
#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so

libgroupby.so : sumby.tmpl \
	numby.tmpl \
	maxby_minby.tmpl
	luajit generator.lua
	luajit numby_generator.lua
	luajit minby_generator.lua
	luajit maxby_generator.lua
	gcc ../gen_src/*.c ${CFLAGS} ${INCS} ${Q_LINK_FLAGS} -o libgroupby.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/

test_q : libgroupby.so
	echo "TODO"

test_c :  libgroupby.so
	echo "TODO"

test : test_q test_c

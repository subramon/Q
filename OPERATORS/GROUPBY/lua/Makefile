# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ -I../../../UTILS/gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : sumby.tmpl numby.tmpl maxby_minby.tmpl
	luajit generator.lua
	luajit numby_generator.lua
	luajit minby_generator.lua
	luajit maxby_generator.lua

test : libgroupby.so
	
#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so

libgroupby.so : sumby.tmpl numby.tmpl maxby_minby.tmpl
	gcc ../gen_src/*.c ${CFLAGS} ${INCS} ${Q_LINK_FLAGS} -o libgroupby.so


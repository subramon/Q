# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ -I../../../UTILS/gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : libdrop_nulls.so

all_for_dc :
	echo "Nothing to do"
	
../gen_src/_drop_nulls_I4.c :
	luajit generator.lua # TODO: Should be more specific
#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so

libdrop_nulls.so : ${GEN_FILES} \
	drop_nulls.tmpl  
	luajit generator.lua # TODO This should not be here. Hack
	gcc  ${CFLAGS} ${GEN_FILES} ${INCS} ${Q_LINK_FLAGS} \
	  -o libdrop_nulls.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/

GEN_FILES = \
	../gen_src/_drop_nulls_I1.c \
	../gen_src/_drop_nulls_I2.c \
	../gen_src/_drop_nulls_I4.c \
	../gen_src/_drop_nulls_I8.c \
	../gen_src/_drop_nulls_F4.c \
	../gen_src/_drop_nulls_F8.c \

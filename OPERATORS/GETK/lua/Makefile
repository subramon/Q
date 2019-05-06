# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ -I../../../UTILS/gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : libgetk.so

all_for_dc :
	luajit gen_specializers.lua
	
#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so
	rm -f maxk_specialize.lua
	rm -f mink_specialize.lua
	rm -f maxk_specialize_reducer.lua
	rm -f mink_specialize_reducer.lua

libgetk.so : getk.tmpl \
	merge1.tmpl
	luajit gen_specializers.lua
	luajit generator.lua
	gcc ../gen_src/*.c ${CFLAGS} ${INCS} ${Q_LINK_FLAGS} -o libgetk.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/

test_q : libgetk.so
	echo "TODO"

test_c :  libgetk.so
	echo "TODO"

test : test_q test_c

GEN_FILES = \
	../gen_src/_merge_max_F4.c \
	../gen_src/_merge_max_F8.c \
	../gen_src/_merge_max_I1.c \
	../gen_src/_merge_max_I2.c \
	../gen_src/_merge_max_I4.c \
	../gen_src/_merge_max_I8.c \
	../gen_src/_merge_min_I8.c \
	../gen_src/_merge_min_I4.c \
	../gen_src/_merge_min_I2.c \
	../gen_src/_merge_min_I1.c \
	../gen_src/_merge_min_F8.c \
	../gen_src/_merge_min_F4.c \

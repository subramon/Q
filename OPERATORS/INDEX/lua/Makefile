# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ -I../../../UTILS/gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : libindex.so

all_for_dc :
	echo "nothing to do"
	
#AUX_FILES = ../../../UTILS/src/bytes_to_bits.c

../../../UTILS/gen_inc/_bytes_to_bits.h :
	make -C ../../../UTILS/src/

#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so

libindex.so : ${GEN_FILES} \
	index.tmpl \
  	indices.tmpl
	luajit generator.lua
	luajit generator_indices.lua
	gcc ${GEN_FILES} ${AUX_FILES} ${CFLAGS} ${INCS} ${Q_LINK_FLAGS} -o libindex.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/

test_q : libindex.so
	echo "TODO"

test_c :  libindex.so
	echo "TODO"

test : test_q test_c

GEN_FILES = \
	../gen_src/_index_F4.c \
	../gen_src/_index_F8.c \
	../gen_src/_index_I1.c \
	../gen_src/_index_I2.c \
	../gen_src/_index_I4.c \
	../gen_src/_index_I8.c \
	../gen_src/_indices.c \
  

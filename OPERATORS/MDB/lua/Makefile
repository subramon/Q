# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : _gen_files
	
so : libmdb.so

dc :
	echo "nothing to do"

clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _* *.so
#----------------------------------
_gen_files : mk_comp_key_val.tmpl.lua
	luajit generator.lua 
	touch _gen_files

		
libmdb.so : ${SRC_FILES} mk_comp_key_val.tmpl.lua _gen_files
	gcc ../gen_src/*.c ${CFLAGS} ${INCS} -shared -o libmdb.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/

SRC_FILES = \
	_mk_comp_key_val_I1.c \
	_mk_comp_key_val_I2.c \
	_mk_comp_key_val_I4.c \
	_mk_comp_key_val_I8.c \
	_mk_comp_key_val_F4.c \
	_mk_comp_key_val_F8.c \

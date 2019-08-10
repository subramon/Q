# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : _gen_files
	
so : libsort.so

all_for_dc :
	echo "nothing to do"

clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _* *.so
#----------------------------------
_gen_files : qsort.tmpl
	luajit generator.lua 
	touch _gen_files

		

libsort.so : ${SRC_FILES} qsort.tmpl _gen_files
	gcc ../gen_src/*.c ${CFLAGS} ${INCS} -shared -o libsort.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/

SRC_FILES = \
	_qsort_asc_F4.c \
	_qsort_asc_F8.c \
	_qsort_asc_I1.c \
	_qsort_asc_I2.c \
	_qsort_asc_I4.c \
	_qsort_asc_I8.c \
	_qsort_dsc_F4.c \
	_qsort_dsc_F8.c \
	_qsort_dsc_I1.c \
	_qsort_dsc_I2.c \
	_qsort_dsc_I4.c \
	_qsort_dsc_I8.c \

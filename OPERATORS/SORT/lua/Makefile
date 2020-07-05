# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : gen_files
	
test : libsort.so

clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _* *.so
#----------------------------------
gen_files : qsort.tmpl \
	../gen_src/qsort_asc_I1.c \
	../gen_src/qsort_asc_I2.c \
	../gen_src/qsort_asc_I4.c \
	../gen_src/qsort_asc_I8.c \
	../gen_src/qsort_asc_F4.c \
	../gen_src/qsort_asc_F8.c \
	../gen_src/qsort_dsc_I1.c \
	../gen_src/qsort_dsc_I2.c \
	../gen_src/qsort_dsc_I4.c \
	../gen_src/qsort_dsc_I8.c \
	../gen_src/qsort_dsc_F4.c \
	../gen_src/qsort_dsc_F8.c \
		

libsort.so : qsort.tmpl gen_files
	gcc ../gen_src/*.c ${CFLAGS} ${INCS} -shared -o libsort.so

../gen_src/qsort_asc_I1.c : qsort.tmpl
	luajit generator.lua asc I1 
../gen_src/qsort_asc_I2.c : qsort.tmpl
	luajit generator.lua asc I2 
../gen_src/qsort_asc_I4.c : qsort.tmpl
	luajit generator.lua asc I4 
../gen_src/qsort_asc_I8.c : qsort.tmpl
	luajit generator.lua asc I8 
../gen_src/qsort_asc_F4.c : qsort.tmpl
	luajit generator.lua asc F4
../gen_src/qsort_asc_F8.c : qsort.tmpl
	luajit generator.lua asc F8

../gen_src/qsort_dsc_I1.c : qsort.tmpl
	luajit generator.lua dsc I1 
../gen_src/qsort_dsc_I2.c : qsort.tmpl
	luajit generator.lua dsc I2 
../gen_src/qsort_dsc_I4.c : qsort.tmpl
	luajit generator.lua dsc I4 
../gen_src/qsort_dsc_I8.c : qsort.tmpl
	luajit generator.lua dsc I8 
../gen_src/qsort_dsc_F4.c : qsort.tmpl
	luajit generator.lua dsc F4
../gen_src/qsort_dsc_F8.c : qsort.tmpl
	luajit generator.lua dsc F8

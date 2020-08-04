# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : gen_files
	
test : libsort2.so

clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _* *.so
#----------------------------------
gen_files : sort2.tmpl \
	../gen_src/qsort_asc_I1_I1.c \
	../gen_src/qsort_asc_I1_I2.c \
	../gen_src/qsort_asc_I1_I4.c \
	../gen_src/qsort_asc_I1_I8.c \
	../gen_src/qsort_asc_I1_F4.c \
	../gen_src/qsort_asc_I1_F8.c \
	\
	../gen_src/qsort_asc_I2_I1.c \
	../gen_src/qsort_asc_I2_I2.c \
	../gen_src/qsort_asc_I2_I4.c \
	../gen_src/qsort_asc_I2_I8.c \
	../gen_src/qsort_asc_I2_F4.c \
	../gen_src/qsort_asc_I2_F8.c \
	\
	../gen_src/qsort_asc_I4_I1.c \
	../gen_src/qsort_asc_I4_I2.c \
	../gen_src/qsort_asc_I4_I4.c \
	../gen_src/qsort_asc_I4_I8.c \
	../gen_src/qsort_asc_I4_F4.c \
	../gen_src/qsort_asc_I4_F8.c \
	\
	../gen_src/qsort_asc_I8_I1.c \
	../gen_src/qsort_asc_I8_I2.c \
	../gen_src/qsort_asc_I8_I4.c \
	../gen_src/qsort_asc_I8_I8.c \
	../gen_src/qsort_asc_I8_F4.c \
	../gen_src/qsort_asc_I8_F8.c \
	\
	../gen_src/qsort_asc_F4_I1.c \
	../gen_src/qsort_asc_F4_I2.c \
	../gen_src/qsort_asc_F4_I4.c \
	../gen_src/qsort_asc_F4_I8.c \
	../gen_src/qsort_asc_F4_F4.c \
	../gen_src/qsort_asc_F4_F8.c \
	\
	../gen_src/qsort_asc_F8_I1.c \
	../gen_src/qsort_asc_F8_I2.c \
	../gen_src/qsort_asc_F8_I4.c \
	../gen_src/qsort_asc_F8_I8.c \
	../gen_src/qsort_asc_F8_F4.c \
	../gen_src/qsort_asc_F8_F8.c \
	\
		

libsort2.so : sort2.tmpl gen_files
	gcc ../gen_src/*.c ${CFLAGS} ${INCS} -shared -o libsort2.so

../gen_src/qsort_asc_I1_I1.c : sort2.tmpl
	luajit generator.lua asc I1 I1
../gen_src/qsort_asc_I1_I2.c : sort2.tmpl
	luajit generator.lua asc I1 I2
../gen_src/qsort_asc_I1_I4.c : sort2.tmpl
	luajit generator.lua asc I1 I4
../gen_src/qsort_asc_I1_I8.c : sort2.tmpl
	luajit generator.lua asc I1 I8
../gen_src/qsort_asc_I1_F4.c : sort2.tmpl
	luajit generator.lua asc I1 F4
../gen_src/qsort_asc_I1_F8.c : sort2.tmpl
	luajit generator.lua asc I1 F8
#-------------
../gen_src/qsort_asc_I2_I1.c : sort2.tmpl
	luajit generator.lua asc I2 I1
../gen_src/qsort_asc_I2_I2.c : sort2.tmpl
	luajit generator.lua asc I2 I2
../gen_src/qsort_asc_I2_I4.c : sort2.tmpl
	luajit generator.lua asc I2 I4
../gen_src/qsort_asc_I2_I8.c : sort2.tmpl
	luajit generator.lua asc I2 I8
../gen_src/qsort_asc_I2_F4.c : sort2.tmpl
	luajit generator.lua asc I2 F4
../gen_src/qsort_asc_I2_F8.c : sort2.tmpl
	luajit generator.lua asc I2 F8
#-------------
../gen_src/qsort_asc_I4_I1.c : sort2.tmpl
	luajit generator.lua asc I4 I1
../gen_src/qsort_asc_I4_I2.c : sort2.tmpl
	luajit generator.lua asc I4 I2
../gen_src/qsort_asc_I4_I4.c : sort2.tmpl
	luajit generator.lua asc I4 I4
../gen_src/qsort_asc_I4_I8.c : sort2.tmpl
	luajit generator.lua asc I4 I8
../gen_src/qsort_asc_I4_F4.c : sort2.tmpl
	luajit generator.lua asc I4 F4
../gen_src/qsort_asc_I4_F8.c : sort2.tmpl
	luajit generator.lua asc I4 F8
#-------------
../gen_src/qsort_asc_I8_I1.c : sort2.tmpl
	luajit generator.lua asc I8 I1
../gen_src/qsort_asc_I8_I2.c : sort2.tmpl
	luajit generator.lua asc I8 I2
../gen_src/qsort_asc_I8_I4.c : sort2.tmpl
	luajit generator.lua asc I8 I4
../gen_src/qsort_asc_I8_I8.c : sort2.tmpl
	luajit generator.lua asc I8 I8
../gen_src/qsort_asc_I8_F4.c : sort2.tmpl
	luajit generator.lua asc I8 F4
../gen_src/qsort_asc_I8_F8.c : sort2.tmpl
	luajit generator.lua asc I8 F8
#-------------
../gen_src/qsort_asc_F4_I1.c : sort2.tmpl
	luajit generator.lua asc F4 I1
../gen_src/qsort_asc_F4_I2.c : sort2.tmpl
	luajit generator.lua asc F4 I2
../gen_src/qsort_asc_F4_I4.c : sort2.tmpl
	luajit generator.lua asc F4 I4
../gen_src/qsort_asc_F4_I8.c : sort2.tmpl
	luajit generator.lua asc F4 I8
../gen_src/qsort_asc_F4_F4.c : sort2.tmpl
	luajit generator.lua asc F4 F4
../gen_src/qsort_asc_F4_F8.c : sort2.tmpl
	luajit generator.lua asc F4 F8
#-------------
../gen_src/qsort_asc_F8_I1.c : sort2.tmpl
	luajit generator.lua asc F8 I1
../gen_src/qsort_asc_F8_I2.c : sort2.tmpl
	luajit generator.lua asc F8 I2
../gen_src/qsort_asc_F8_I4.c : sort2.tmpl
	luajit generator.lua asc F8 I4
../gen_src/qsort_asc_F8_I8.c : sort2.tmpl
	luajit generator.lua asc F8 I8
../gen_src/qsort_asc_F8_F4.c : sort2.tmpl
	luajit generator.lua asc F8 F4
../gen_src/qsort_asc_F8_F8.c : sort2.tmpl
	luajit generator.lua asc F8 F8
#-------------

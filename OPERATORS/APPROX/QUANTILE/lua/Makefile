# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I../src/  -I../inc/ -I../../../../UTILS/inc/ -I../gen_inc/ -I../../../SORT/gen_inc/

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : libaq.so all_for_dc

all_for_dc :
	echo "Nothing to do"

#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so
		
SRT_FILES = \
	../../../SORT/gen_src/_qsort_asc_I1.c \
	../../../SORT/gen_src/_qsort_asc_I2.c \
	../../../SORT/gen_src/_qsort_asc_I4.c \
	../../../SORT/gen_src/_qsort_asc_I8.c \


../../../SORT/gen_src/_qsort_asc_I1.c :
	make -C ../../../SORT/lua/ 

../../../SORT/gen_src/_qsort_asc_I2.c :
	make -C ../../../SORT/lua/ 

../../../SORT/gen_src/_qsort_asc_I4.c :
	make -C ../../../SORT/lua/ 

../../../SORT/gen_src/_qsort_asc_I8.c :
	make -C ../../../SORT/lua/ 

../gen_src/_approx_quantile_I1.c :
	luajit generator.lua 

libaq.so : ${SRT_FILES} ${GEN_FILES}
	luajit generator.lua 
	gcc ${SRT_FILES} ../src/*.c ${GEN_FILES} ${CFLAGS} ${INCS} ${Q_LINK_FLAGS}  -o libaq.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/
	cp ../inc/*.h ${Q_BUILD_DIR}/include/

GEN_FILES = \
	../gen_src/_approx_quantile_I1.c \
	../gen_src/_approx_quantile_I2.c \
	../gen_src/_approx_quantile_I4.c \
	../gen_src/_approx_quantile_I8.c \
	../gen_src/_Collapse_I1.c \
	../gen_src/_Collapse_I2.c \
	../gen_src/_Collapse_I4.c \
	../gen_src/_Collapse_I8.c \
	../gen_src/_New_I1.c \
	../gen_src/_New_I2.c \
	../gen_src/_New_I4.c \
	../gen_src/_New_I8.c \
	../gen_src/_Output_I1.c \
	../gen_src/_Output_I2.c \
	../gen_src/_Output_I4.c \
	../gen_src/_Output_I8.c 

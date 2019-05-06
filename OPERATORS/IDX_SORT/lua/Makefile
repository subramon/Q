# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : libidx_sort.so

all_for_dc :
	echo "nothing to do" 
	
#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _* *.so
		
libidx_sort.so : ${GEN_FILES}
	luajit generator.lua 
	gcc ../gen_src/*.c ${CFLAGS} ${INCS} -shared -o libidx_sort.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/

../gen_src/_qsort_asc_val_F4_idx_I1.c : idx_qsort.tmpl
	luajit generator.lua 

GEN_FILES = \
	../gen_src/_qsort_asc_val_F4_idx_I1.c \
	../gen_src/_qsort_asc_val_F4_idx_I2.c \
	../gen_src/_qsort_asc_val_F4_idx_I4.c \
	../gen_src/_qsort_asc_val_F4_idx_I8.c \
	../gen_src/_qsort_asc_val_F8_idx_I1.c \
	../gen_src/_qsort_asc_val_F8_idx_I2.c \
	../gen_src/_qsort_asc_val_F8_idx_I4.c \
	../gen_src/_qsort_asc_val_F8_idx_I8.c \
	../gen_src/_qsort_asc_val_I1_idx_I1.c \
	../gen_src/_qsort_asc_val_I1_idx_I2.c \
	../gen_src/_qsort_asc_val_I1_idx_I4.c \
	../gen_src/_qsort_asc_val_I1_idx_I8.c \
	../gen_src/_qsort_asc_val_I2_idx_I1.c \
	../gen_src/_qsort_asc_val_I2_idx_I2.c \
	../gen_src/_qsort_asc_val_I2_idx_I4.c \
	../gen_src/_qsort_asc_val_I2_idx_I8.c \
	../gen_src/_qsort_asc_val_I4_idx_I1.c \
	../gen_src/_qsort_asc_val_I4_idx_I2.c \
	../gen_src/_qsort_asc_val_I4_idx_I4.c \
	../gen_src/_qsort_asc_val_I4_idx_I8.c \
	../gen_src/_qsort_asc_val_I8_idx_I1.c \
	../gen_src/_qsort_asc_val_I8_idx_I2.c \
	../gen_src/_qsort_asc_val_I8_idx_I4.c \
	../gen_src/_qsort_asc_val_I8_idx_I8.c \
	../gen_src/_qsort_dsc_val_F4_idx_I1.c \
	../gen_src/_qsort_dsc_val_F4_idx_I2.c \
	../gen_src/_qsort_dsc_val_F4_idx_I4.c \
	../gen_src/_qsort_dsc_val_F4_idx_I8.c \
	../gen_src/_qsort_dsc_val_F8_idx_I1.c \
	../gen_src/_qsort_dsc_val_F8_idx_I2.c \
	../gen_src/_qsort_dsc_val_F8_idx_I4.c \
	../gen_src/_qsort_dsc_val_F8_idx_I8.c \
	../gen_src/_qsort_dsc_val_I1_idx_I1.c \
	../gen_src/_qsort_dsc_val_I1_idx_I2.c \
	../gen_src/_qsort_dsc_val_I1_idx_I4.c \
	../gen_src/_qsort_dsc_val_I1_idx_I8.c \
	../gen_src/_qsort_dsc_val_I2_idx_I1.c \
	../gen_src/_qsort_dsc_val_I2_idx_I2.c \
	../gen_src/_qsort_dsc_val_I2_idx_I4.c \
	../gen_src/_qsort_dsc_val_I2_idx_I8.c \
	../gen_src/_qsort_dsc_val_I4_idx_I1.c \
	../gen_src/_qsort_dsc_val_I4_idx_I2.c \
	../gen_src/_qsort_dsc_val_I4_idx_I4.c \
	../gen_src/_qsort_dsc_val_I4_idx_I8.c \
	../gen_src/_qsort_dsc_val_I8_idx_I1.c \
	../gen_src/_qsort_dsc_val_I8_idx_I2.c \
	../gen_src/_qsort_dsc_val_I8_idx_I4.c \
	../gen_src/_qsort_dsc_val_I8_idx_I8.c \


# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
INCS=-I.  -I../../../UTILS/inc/ -I../gen_inc/ -I../../../UTILS/gen_inc/ 

DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

CFLAGS = ${DBGFLAGS} ${OPTFLAGS} ${QC_FLAGS} 

all : libainb.so

all_for_dc :
	echo "nothing to do"
	
AUX_FILES = ../../../UTILS/src/bytes_to_bits.c

../../../UTILS/gen_inc/_bytes_to_bits.h :
	make -C ../../../UTILS/src/


../gen_src/_ainb_F4_F4.c : simple_ainb.tmpl 
	luajit generator.lua 
../gen_src/_ainb_I4_I4.c : bin_search_ainb.tmpl  
	luajit generator.lua 
../gen_src/bin_search_get_idx_I8_by_val_I4.c : bin_search_get_idx_by_val.tmpl  
	luajit generator_get_idx_by_val.lua
#----------------------------------
clean :
	rm -r -f ../gen_src; 
	rm -r -f ../gen_inc; 
	rm -f _*
	rm -f *.so

libainb.so : ${GEN_FILES} ${AUX_FILES} \
	bin_search_ainb.tmpl simple_ainb.tmpl \
	../../../UTILS/gen_inc/_bytes_to_bits.h
	luajit generator.lua 
	luajit generator_get_idx_by_val.lua 
	gcc ${GEN_FILES} ${AUX_FILES} ${CFLAGS} ${INCS} ${Q_LINK_FLAGS} -o libainb.so
	test -d ${Q_BUILD_DIR}
	cp ../gen_src/*.c ${Q_BUILD_DIR}/src/
	cp ../gen_inc/*.h ${Q_BUILD_DIR}/include/

test_q : libainb.so
	echo "TODO"

test_c :  libainb.so
	echo "TODO"

test : test_q test_c

GEN_FILES = \
	../gen_src/_simple_ainb_F4_F4.c \
	../gen_src/_simple_ainb_F4_F8.c \
	../gen_src/_simple_ainb_F4_I1.c \
	../gen_src/_simple_ainb_F4_I2.c \
	../gen_src/_simple_ainb_F4_I4.c \
	../gen_src/_simple_ainb_F4_I8.c \
	../gen_src/_simple_ainb_F8_F4.c \
	../gen_src/_simple_ainb_F8_F8.c \
	../gen_src/_simple_ainb_F8_I1.c \
	../gen_src/_simple_ainb_F8_I2.c \
	../gen_src/_simple_ainb_F8_I4.c \
	../gen_src/_simple_ainb_F8_I8.c \
	../gen_src/_simple_ainb_I1_F4.c \
	../gen_src/_simple_ainb_I1_F8.c \
	../gen_src/_simple_ainb_I1_I1.c \
	../gen_src/_simple_ainb_I1_I2.c \
	../gen_src/_simple_ainb_I1_I4.c \
	../gen_src/_simple_ainb_I1_I8.c \
	../gen_src/_simple_ainb_I2_F4.c \
	../gen_src/_simple_ainb_I2_F8.c \
	../gen_src/_simple_ainb_I2_I1.c \
	../gen_src/_simple_ainb_I2_I2.c \
	../gen_src/_simple_ainb_I2_I4.c \
	../gen_src/_simple_ainb_I2_I8.c \
	../gen_src/_simple_ainb_I4_F4.c \
	../gen_src/_simple_ainb_I4_F8.c \
	../gen_src/_simple_ainb_I4_I1.c \
	../gen_src/_simple_ainb_I4_I2.c \
	../gen_src/_simple_ainb_I4_I4.c \
	../gen_src/_simple_ainb_I4_I8.c \
	../gen_src/_simple_ainb_I8_F4.c \
	../gen_src/_simple_ainb_I8_F8.c \
	../gen_src/_simple_ainb_I8_I1.c \
	../gen_src/_simple_ainb_I8_I2.c \
	../gen_src/_simple_ainb_I8_I4.c \
	../gen_src/_simple_ainb_I8_I8.c \
	../gen_src/_bin_search_get_idx_I1_by_val_F4.c \
	../gen_src/_bin_search_get_idx_I1_by_val_F8.c \
	../gen_src/_bin_search_get_idx_I1_by_val_I1.c \
	../gen_src/_bin_search_get_idx_I1_by_val_I2.c \
	../gen_src/_bin_search_get_idx_I1_by_val_I4.c \
	../gen_src/_bin_search_get_idx_I1_by_val_I8.c \
	../gen_src/_bin_search_get_idx_I2_by_val_F4.c \
	../gen_src/_bin_search_get_idx_I2_by_val_F8.c \
	../gen_src/_bin_search_get_idx_I2_by_val_I1.c \
	../gen_src/_bin_search_get_idx_I2_by_val_I2.c \
	../gen_src/_bin_search_get_idx_I2_by_val_I4.c \
	../gen_src/_bin_search_get_idx_I2_by_val_I8.c \
	../gen_src/_bin_search_get_idx_I4_by_val_F4.c \
	../gen_src/_bin_search_get_idx_I4_by_val_F8.c \
	../gen_src/_bin_search_get_idx_I4_by_val_I1.c \
	../gen_src/_bin_search_get_idx_I4_by_val_I2.c \
	../gen_src/_bin_search_get_idx_I4_by_val_I4.c \
	../gen_src/_bin_search_get_idx_I4_by_val_I8.c \
	../gen_src/_bin_search_get_idx_I8_by_val_F4.c \
	../gen_src/_bin_search_get_idx_I8_by_val_F8.c \
	../gen_src/_bin_search_get_idx_I8_by_val_I1.c \
	../gen_src/_bin_search_get_idx_I8_by_val_I2.c \
	../gen_src/_bin_search_get_idx_I8_by_val_I4.c \
	../gen_src/_bin_search_get_idx_I8_by_val_I8.c \


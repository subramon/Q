# Why are we depending on print and load csv?
INCS=-I. -I../inc/ \
	-I../../../UTILS/gen_inc/ \
	-I../../../UTILS/inc/ \
	-I../../CMEM/inc/ \
	-I../../SCLR/inc/ \
	-I/usr/include/lua5.1/ \


all: libvctr.so 
	cp libvctr.so ${Q_ROOT}/lib/

all_for_dc : 
	cp ../inc/core_vec_struct.h ${Q_BUILD_DIR}/include/

../inc/_struct_timers.h : timers.lua
	lua timers.lua "struct" > ../inc/_struct_timers.h

_reset_timers.c : timers.lua
	lua timers.lua "reset" > _reset_timers.c

_print_timers.c : timers.lua
	lua timers.lua "print" > _print_timers.c 

clean:
	rm -f *.so *.o _*
	rm -f ../inc/_struct_timers.h 
	rm -f reset_timers.c
	rm -f print_timers.c

GEN_INC_FILES =  \
	../../../UTILS/gen_inc/_I1_to_txt.h  \
	../../../UTILS/gen_inc/_I2_to_txt.h  \
	../../../UTILS/gen_inc/_I4_to_txt.h  \
	../../../UTILS/gen_inc/_I8_to_txt.h  \
	../../../UTILS/gen_inc/_F4_to_txt.h  \
	../../../UTILS/gen_inc/_F8_to_txt.h  \
	../../../UTILS/gen_inc/_txt_to_I1.h  \
	../../../UTILS/gen_inc/_txt_to_I2.h  \
	../../../UTILS/gen_inc/_txt_to_I4.h  \
	../../../UTILS/gen_inc/_txt_to_I8.h  \
	../../../UTILS/gen_inc/_txt_to_F4.h  \
	../../../UTILS/gen_inc/_txt_to_F8.h  \

GEN_SRC_FILES = \
	../../../UTILS/gen_src/_I1_to_txt.c \
	../../../UTILS/gen_src/_I2_to_txt.c \
	../../../UTILS/gen_src/_I4_to_txt.c \
	../../../UTILS/gen_src/_I8_to_txt.c \
	../../../UTILS/gen_src/_F4_to_txt.c \
	../../../UTILS/gen_src/_F8_to_txt.c \
	../../../UTILS/gen_src/_txt_to_I1.c  \
	../../../UTILS/gen_src/_txt_to_I2.c  \
	../../../UTILS/gen_src/_txt_to_I4.c  \
	../../../UTILS/gen_src/_txt_to_I8.c  \
	../../../UTILS/gen_src/_txt_to_F4.c  \
	../../../UTILS/gen_src/_txt_to_F8.c  \

UTILS_INC_FILES = \
	../../../UTILS/gen_inc/_B1_to_txt.h \
	../../../UTILS/gen_inc/_copy_file.h \
	../../../UTILS/gen_inc/_file_exists.h \
	../../../UTILS/gen_inc/_get_file_size.h \
	../../../UTILS/gen_inc/_get_time_usec.h \
	../../../UTILS/gen_inc/_is_valid_chars_for_num.h \
	../../../UTILS/gen_inc/_isdir.h \
	../../../UTILS/gen_inc/_isfile.h \
	../../../UTILS/gen_inc/_rdtsc.h \
	../../../UTILS/gen_inc/_rs_mmap.h \

UTILS_SRC_FILES = \
	../../../UTILS/src/copy_file.c \
	../../../UTILS/src/file_exists.c \
	../../../UTILS/src/get_file_size.c \
	../../../UTILS/src/get_time_usec.c \
	../../../UTILS/src/isdir.c \
	../../../UTILS/src/isfile.c \
	../../../UTILS/src/rdtsc.c \
	../../../UTILS/src/rs_mmap.c \

vector.o : vector.c \
	../inc/core_vec_struct.h \
  	../inc/_struct_timers.h  \
	../../../UTILS/gen_inc/_txt_to_I4.h \
	${UTILS_INC_FILES}
	gcc -c $(INCS) ${QC_FLAGS} vector.c -o vector.o

core_vec.o : core_vec.c \
  	../inc/core_vec_struct.h \
	../inc/core_vec.h \
  	../inc/_struct_timers.h \
	_reset_timers.c \
	_print_timers.c \
	${UTILS_INC_FILES}
	gcc -c $(INCS) ${QC_FLAGS} core_vec.c -o core_vec.o

aux_core_vec.o : aux_core_vec.c \
	../inc/core_vec_struct.h \
	../inc/aux_core_vec.h \
  	../inc/_struct_timers.h \
	${UTILS_INC_FILES} 
	gcc -c $(INCS) ${QC_FLAGS} aux_core_vec.c -o aux_core_vec.o

libvctr.so: vector.o core_vec.o aux_core_vec.o \
	${GEN_INC_FILES} \
	${GEN_SRC_FILES} \
	${UTILS_SRC_FILES} \
	${UTILS_INC_FILES} 
	gcc ${QC_FLAGS} $(INCS) \
	  	${GEN_SRC_FILES} \
	  	${UTILS_SRC_FILES} \
		vector.c \
		../../CMEM/src/cmem.c \
		../../CMEM/src/aux_lua_to_c.c \
		core_vec.c \
		aux_core_vec.c \
		-shared -o libvctr.so
	cp ../inc/core_vec_struct.h ${Q_BUILD_DIR}/include/

#------------------------------------------------------
../../../UTILS/gen_inc/_txt_to_I4.h : 
	make -C ../../../UTILS/src/ ../gen_inc/_txt_to_I4.h
../../../UTILS/gen_src/_txt_to_I4.c : 
	make -C ../../../UTILS/src/ ../gen_src/_txt_to_I4.c
#------------------------------------------------------
_eval_arith.c: gen_arith.lua
	luajit gen_arith.lua
_outer_eval_arith.c: gen_arith.lua
	luajit gen_arith.lua
_eval_cmp.c: gen_cmp.lua
	luajit gen_cmp.lua
_outer_eval_cmp.c: gen_cmp.lua
	luajit gen_cmp.lua

#----------
../../../UTILS/gen_inc/_B1_to_txt.h  : 
	make -C ../../../UTILS/src/ ../gen_inc/_B1_to_txt.h
../../../UTILS/gen_inc/_copy_file.h  : 
	make -C ../../../UTILS/src/ ../gen_inc/_copy_file.h
../../../UTILS/gen_inc/_file_exists.h  : 
	make -C ../../../UTILS/src/ ../gen_inc/_file_exists.h
../../../UTILS/gen_inc/_get_file_size.h  : 
	make -C ../../../UTILS/src/ ../gen_inc/_get_file_size.h
../../../UTILS/gen_inc/_get_time_usec.h  : 
	make -C ../../../UTILS/src/ ../gen_inc/_get_time_usec.h
../../../UTILS/gen_inc/_is_valid_chars_for_num.h  : 
	make -C ../../../UTILS/src/ ../gen_inc/_is_valid_chars_for_num.h
../../../UTILS/gen_inc/_isdir.h  : 
	make -C ../../../UTILS/src/ ../gen_inc/_isdir.h
../../../UTILS/gen_inc/_isfile.h  : 
	make -C ../../../UTILS/src/ ../gen_inc/_isfile.h
../../../UTILS/gen_inc/_rdtsc.h  : 
	make -C ../../../UTILS/src/ ../gen_inc/_rdtsc.h
../../../UTILS/gen_inc/_rs_mmap.h  : 
	make -C ../../../UTILS/src/ ../gen_inc/_rs_mmap.h
#-------------------
../../../UTILS/gen_inc/_I1_to_txt.h :
	make -C ../../../UTILS/src ../gen_inc/_I1_to_txt.h
../../../UTILS/gen_inc/_I2_to_txt.h :
	make -C ../../../UTILS/src ../gen_inc/_I2_to_txt.h
../../../UTILS/gen_inc/_I4_to_txt.h :
	make -C ../../../UTILS/src ../gen_inc/_I4_to_txt.h
../../../UTILS/gen_inc/_I8_to_txt.h :
	make -C ../../../UTILS/src ../gen_inc/_I8_to_txt.h
../../../UTILS/gen_inc/_F4_to_txt.h :
	make -C ../../../UTILS/src ../gen_inc/_F4_to_txt.h
../../../UTILS/gen_inc/_F8_to_txt.h :
	make -C ../../../UTILS/src ../gen_inc/_F8_to_txt.h
#----------------------------------
../../../UTILS/gen_src/_I1_to_txt.c :
	make -C ../../../UTILS/src ../gen_src/_I1_to_txt.c
../../../UTILS/gen_src/_I2_to_txt.c :
	make -C ../../../UTILS/src ../gen_src/_I2_to_txt.c
../../../UTILS/gen_src/_I4_to_txt.c :
	make -C ../../../UTILS/src ../gen_src/_I4_to_txt.c
../../../UTILS/gen_src/_I8_to_txt.c :
	make -C ../../../UTILS/src ../gen_src/_I8_to_txt.c
../../../UTILS/gen_src/_F4_to_txt.c :
	make -C ../../../UTILS/src ../gen_src/_F4_to_txt.c
../../../UTILS/gen_src/_F8_to_txt.c :
	make -C ../../../UTILS/src ../gen_src/_F8_to_txt.c
#----------------------------------
#----------------------------------
../../../UTILS/gen_inc/_txt_to_I1.h :
	make -C ../../../UTILS/src/ ../gen_inc/_txt_to_I1.h
../../../UTILS/gen_inc/_txt_to_I2.h :
	make -C ../../../UTILS/src/ ../gen_inc/_txt_to_I2.h
../../../UTILS/gen_inc/_txt_to_I4.h :
	make -C ../../../UTILS/src/ ../gen_inc/_txt_to_I4.h
../../../UTILS/gen_inc/_txt_to_I8.h :
	make -C ../../../UTILS/src/ ../gen_inc/_txt_to_I8.h
../../../UTILS/gen_inc/_txt_to_F4.h :
	make -C ../../../UTILS/src/ ../gen_inc/_txt_to_F4.h
../../../UTILS/gen_inc/_txt_to_F8.h :
	make -C ../../../UTILS/src/ ../gen_inc/_txt_to_F8.h
#----------------------------------
../../../UTILS/gen_src/_txt_to_I1.c :
	make -C ../../../UTILS/src/ ../gen_src/_txt_to_I1.c
../../../UTILS/gen_src/_txt_to_I2.c :
	make -C ../../../UTILS/src/ ../gen_src/_txt_to_I2.c
../../../UTILS/gen_src/_txt_to_I4.c :
	make -C ../../../UTILS/src/ ../gen_src/_txt_to_I4.c
../../../UTILS/gen_src/_txt_to_I8.c :
	make -C ../../../UTILS/src/ ../gen_src/_txt_to_I8.c
../../../UTILS/gen_src/_txt_to_F4.c :
	make -C ../../../UTILS/src/ ../gen_src/_txt_to_F4.c
../../../UTILS/gen_src/_txt_to_F8.c :
	make -C ../../../UTILS/src/ ../gen_src/_txt_to_F8.c
#----------------------------------

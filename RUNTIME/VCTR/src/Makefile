# Why are we depending on print and load csv?
INCS=-I. -I../inc/ \
	-I../../../UTILS/gen_inc/ \
	-I../../../UTILS/inc/ \
	-I../../CMEM/inc/ \
	-I../../SCLR/inc/ \
	-I/usr/include/lua5.1/ \


all: libvctr.so 
	cp libvctr.so ${Q_ROOT}/lib/
	echo "done"

../inc/_struct_timers.h : timers.lua
	lua timers.lua "struct" > ../inc/_struct_timers.h

_reset_timers.c : timers.lua
	lua timers.lua "reset" > _reset_timers.c

_print_timers.c : timers.lua
	lua timers.lua "print" > _print_timers.c 

clean:
	rm -f *.so *.o _*
		
../../../UTILS/src/is_valid_chars_for_num.c :
	make -C ../../../UTILS/src/

../../OPERATORS/PRINT/gen_src/_I1_to_txt.c :
	make -C ../../OPERATORS/PRINT/lua/

vector.o : vector.c ../inc/core_vec_struct.h \
  	../inc/_struct_timers.h 
	gcc -c $(INCS) ${QC_FLAGS} vector.c -o vector.o

core_vec.o : core_vec.c ../inc/core_vec_struct.h ../inc/core_vec.h \
  	../inc/_struct_timers.h _reset_timers.c _print_timers.c 
	gcc -c $(INCS) ${QC_FLAGS} core_vec.c -o core_vec.o

aux_core_vec.o : aux_core_vec.c ../inc/core_vec_struct.h ../inc/aux_core_vec.h
	gcc -c $(INCS) ${QC_FLAGS} aux_core_vec.c -o aux_core_vec.o

libvctr.so: vector.o core_vec.o aux_core_vec.o
	make -C ../../../UTILS/src/
	gcc ${QC_FLAGS} $(INCS) \
		vector.c \
		../../CMEM/src/cmem.c \
		../../CMEM/src/aux_lua_to_c.c \
		core_vec.c \
		aux_core_vec.c \
		buf_to_file.c \
		copy_file.c \
		../../../UTILS/src/rdtsc.c \
		../../../UTILS/src/rs_mmap.c \
		../../../UTILS/gen_src/_txt_to_I4.c \
		../../../UTILS/src/is_valid_chars_for_num.c \
		../../../UTILS/src/rand_file_name.c \
		../../../UTILS/src/get_file_size.c \
		../../../UTILS/src/file_exists.c \
		../../../UTILS/src/isfile.c \
		../../../UTILS/src/isdir.c \
		../../../UTILS/src/get_time_usec.c \
		../../../UTILS/src/B1_to_txt.c \
		../../../UTILS/gen_src/_I1_to_txt.c \
		../../../UTILS/gen_src/_I2_to_txt.c \
		../../../UTILS/gen_src/_I4_to_txt.c \
		../../../UTILS/gen_src/_I8_to_txt.c \
		../../../UTILS/gen_src/_F4_to_txt.c \
		../../../UTILS/gen_src/_F8_to_txt.c \
		-shared -o libvctr.so
	cp ../inc/core_vec_struct.h ${Q_BUILD_DIR}/include/

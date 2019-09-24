# Why are we depending on print and load csv?
INCS=-I. -I../inc/ \
	-I../../../UTILS/gen_inc/ \
	-I../../../UTILS/inc \
	-I/usr/include/lua5.1/ \


all: libvec.so 
	cp libvec.so ${Q_ROOT}/lib/
	echo "done"

clean:
	rm -f *.so *.o _*
		
../../../UTILS/src/is_valid_chars_for_num.c :
	make -C ../../../UTILS/src/

../../OPERATORS/PRINT/gen_src/_I1_to_txt.c :
	make -C ../../OPERATORS/PRINT/lua/

libvec.so: 
	make -C ../../../UTILS/src/
	gcc ${QC_FLAGS} $(INCS) \
		vector.c \
		core_vec.c \
		buf_to_file.c \
		cmem.c \
                copy_file.c \
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
		-shared -o libvec.so
	cp ../inc/core_vec_struct.h ${Q_BUILD_DIR}/include/

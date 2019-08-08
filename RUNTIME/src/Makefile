# Why are we depending on print and load csv?
INCS=-I. -I../inc/ \
	-I../../UTILS/gen_inc/ \
	-I../../UTILS/inc \
	-I/usr/include/lua5.1/ \


all: libvec.so libcmem.so libsclr.so 
	cp libvec.so ${Q_ROOT}/lib/
	cp libcmem.so ${Q_ROOT}/lib/
	cp libsclr.so ${Q_ROOT}/lib/
	cp libmm.so ${Q_ROOT}/lib/
	echo "done"

clean:
	rm -f *.so *.o _*
		
../../UTILS/src/is_valid_chars_for_num.c :
	make -C ../../UTILS/src/

../../OPERATORS/PRINT/gen_src/_I1_to_txt.c :
	make -C ../../OPERATORS/PRINT/lua/

libvec.so: libcmem.so 
	make -C ../../UTILS/src/
	gcc ${QC_FLAGS} $(INCS) \
		vector.c \
		core_vec.c \
		buf_to_file.c \
		cmem.c \
                copy_file.c \
		../../UTILS/src/rs_mmap.c \
		../../UTILS/gen_src/_txt_to_I4.c \
		../../UTILS/src/is_valid_chars_for_num.c \
		../../UTILS/src/rand_file_name.c \
		../../UTILS/src/get_file_size.c \
		../../UTILS/src/file_exists.c \
                ../../UTILS/src/isfile.c \
                ../../UTILS/src/isdir.c \
                ../../UTILS/src/get_time_usec.c \
		../../UTILS/src/B1_to_txt.c \
		../../UTILS/gen_src/_I1_to_txt.c \
		../../UTILS/gen_src/_I2_to_txt.c \
		../../UTILS/gen_src/_I4_to_txt.c \
		../../UTILS/gen_src/_I8_to_txt.c \
		../../UTILS/gen_src/_F4_to_txt.c \
		../../UTILS/gen_src/_F8_to_txt.c \
		libmm.so \
		-shared -o libvec.so
	cp ../inc/core_vec_struct.h ${Q_BUILD_DIR}/include/

# do we need this?	cp ../inc/core_vec.h ${Q_BUILD_DIR}/include/

libmm.so :
	gcc ${QC_FLAGS} ${INCS} -shared mm.c -o libmm.so 

# do we need this?	cp ../inc/mm.h ${Q_BUILD_DIR}/include/

libcmem.so:  libmm.so
	gcc ${QC_FLAGS} ${INCS} \
		cmem.c \
		../../UTILS/src/B1_to_txt.c \
		../../UTILS/gen_src/_I1_to_txt.c \
		../../UTILS/gen_src/_I2_to_txt.c \
		../../UTILS/gen_src/_I4_to_txt.c \
		../../UTILS/gen_src/_I8_to_txt.c \
		../../UTILS/gen_src/_F4_to_txt.c \
		../../UTILS/gen_src/_F8_to_txt.c \
		libmm.so \
		-shared -o libcmem.so
	cp ../inc/cmem_struct.h ${Q_BUILD_DIR}/include/

# do we need this?	cp ../inc/cmem.h ${Q_BUILD_DIR}/include/

libsclr.so: gen_cmp gen_arith libcmem.so libmm.so
	rm -f _*.c
	lua gen_cmp.lua
	lua gen_arith.lua
	gcc ${QC_FLAGS} ${INCS} \
		scalar.c \
		cmem.c \
		../../UTILS/src/txt_to_B1.c \
		../../UTILS/gen_src/_txt_to_I1.c \
		../../UTILS/gen_src/_txt_to_I2.c \
		../../UTILS/gen_src/_txt_to_I4.c \
		../../UTILS/gen_src/_txt_to_I8.c \
		../../UTILS/gen_src/_txt_to_F4.c \
		../../UTILS/gen_src/_txt_to_F8.c \
		../../UTILS/src/B1_to_txt.c \
		../../UTILS/gen_src/_I1_to_txt.c \
		../../UTILS/gen_src/_I2_to_txt.c \
		../../UTILS/gen_src/_I4_to_txt.c \
		../../UTILS/gen_src/_I8_to_txt.c \
		../../UTILS/gen_src/_F4_to_txt.c \
		../../UTILS/gen_src/_F8_to_txt.c \
		../../UTILS/src/is_valid_chars_for_num.c \
		libmm.so \
		-shared -o libsclr.so
	cp ../inc/scalar_struct.h ${Q_BUILD_DIR}/include/

gen_cmp:
	lua gen_cmp.lua

gen_arith:
	lua gen_arith.lua

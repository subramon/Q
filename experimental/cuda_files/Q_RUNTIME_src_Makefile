# Why are we depending on print and load csv?
INCS=-I. -I../inc/ -I../../UTILS/gen_inc/ -I../../UTILS/inc -I../../OPERATORS/LOAD_CSV/gen_inc/ -I../../OPERATORS/PRINT/gen_inc/ -I/usr/include/lua5.1/

all: libvec.so libcmem.so libsclr.so
	mv libvec.so ${Q_ROOT}/lib/
	mv libcmem.so ${Q_ROOT}/lib/
	mv libsclr.so ${Q_ROOT}/lib/
	echo "done"

clean:
	rm -f *.so *.o _*
		
../../UTILS/src/is_valid_chars_for_num.c :
	make -C ../../UTILS/src/

../../OPERATORS/LOAD_CSV/gen_src/_txt_to_I4.c :
	make -C ../../OPERATORS/LOAD_CSV/lua/ 

../../OPERATORS/PRINT/gen_src/_I1_to_txt.c :
	make -C ../../OPERATORS/PRINT/lua/

# CUDA: Using nvcc compiler, also updated QC_FLAGS
libvec.so: libvec.so libcmem.so
	nvcc -g -DDEBUG -Xcompiler -fPIC $(INCS) \
		vector.c \
		../../UTILS/src/err.c \
		core_vec.c \
		cmem.c \
		../../UTILS/src/mmap.c \
		../../OPERATORS/LOAD_CSV/gen_src/_txt_to_I4.c \
		../../UTILS/src/is_valid_chars_for_num.c \
		../../UTILS/src/rand_file_name.c \
		../../UTILS/src/get_file_size.c \
		../../UTILS/src/buf_to_file.c \
                ../../UTILS/src/copy_file.c \
		../../UTILS/src/file_exists.c \
                ../../UTILS/src/isfile.c \
                ../../UTILS/src/isdir.c \
                ../../UTILS/src/cuda_malloc.cu \
                ../../UTILS/src/cuda_free.cu \
		../../OPERATORS/PRINT/src/B1_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_I1_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_I2_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_I4_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_I8_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_F4_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_F8_to_txt.c \
		-shared -o libvec.so

# CUDA: Using nvcc compiler, also updated QC_FLAGS
libcmem.so:
	nvcc -g -DDEBUG -Xcompiler -fPIC ${INCS} \
		cmem.c \
		../../OPERATORS/PRINT/src/B1_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_I1_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_I2_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_I4_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_I8_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_F4_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_F8_to_txt.c \
                ../../UTILS/src/cuda_malloc.cu \
                ../../UTILS/src/cuda_free.cu \
		../../UTILS/src/err.c \
		-shared -o libcmem.so

libsclr.so: gen_cmp gen_arith libcmem.so
	rm -f _*.c
	lua gen_cmp.lua
	lua gen_arith.lua
	nvcc -g -DDEBUG -Xcompiler -fPIC ${INCS} \
		scalar.c \
		cmem.c \
		../../UTILS/src/err.c \
		../../OPERATORS/LOAD_CSV/src/txt_to_B1.c \
		../../OPERATORS/LOAD_CSV/gen_src/_txt_to_I1.c \
		../../OPERATORS/LOAD_CSV/gen_src/_txt_to_I2.c \
		../../OPERATORS/LOAD_CSV/gen_src/_txt_to_I4.c \
		../../OPERATORS/LOAD_CSV/gen_src/_txt_to_I8.c \
		../../OPERATORS/LOAD_CSV/gen_src/_txt_to_F4.c \
		../../OPERATORS/LOAD_CSV/gen_src/_txt_to_F8.c \
		../../OPERATORS/PRINT/src/B1_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_I1_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_I2_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_I4_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_I8_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_F4_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_F8_to_txt.c \
		../../UTILS/src/cuda_malloc.cu \
		../../UTILS/src/cuda_free.cu \
		../../UTILS/src/is_valid_chars_for_num.c \
		-shared -o libsclr.so

gen_cmp:
	lua gen_cmp.lua

gen_arith:
	lua gen_arith.lua

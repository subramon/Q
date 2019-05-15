# Why are we depending on print and load csv?
INCS=-I. -I../inc/ -I../../UTILS/gen_inc/ -I../../UTILS/inc -I../../OPERATORS/LOAD_CSV/gen_inc/ -I../../OPERATORS/PRINT/gen_inc/ -I/usr/include/lua5.1/

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

../../OPERATORS/LOAD_CSV/gen_src/_txt_to_I4.c :
	make -C ../../OPERATORS/LOAD_CSV/lua/ 

../../OPERATORS/PRINT/gen_src/_I1_to_txt.c :
	make -C ../../OPERATORS/PRINT/lua/

libvec.so: libcmem.so 
	gcc ${QC_FLAGS} $(INCS) \
		vector.c \
		../../UTILS/src/err.c \
		core_vec.c \
		buf_to_file.c \
		cmem.c \
                copy_file.c \
		../../UTILS/src/mmap.c \
		../../OPERATORS/LOAD_CSV/gen_src/_txt_to_I4.c \
		../../UTILS/src/is_valid_chars_for_num.c \
		../../UTILS/src/rand_file_name.c \
		../../UTILS/src/get_file_size.c \
		../../UTILS/src/file_exists.c \
                ../../UTILS/src/isfile.c \
                ../../UTILS/src/isdir.c \
                ../../UTILS/src/get_time_usec.c \
		../../OPERATORS/PRINT/src/B1_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_I1_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_I2_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_I4_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_I8_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_F4_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_F8_to_txt.c \
		libmm.so \
		-shared -o libvec.so

libmm.so :
	gcc ${QC_FLAGS} ${INCS} -shared mm.c -o libmm.so 

libcmem.so:  libmm.so
	gcc ${QC_FLAGS} ${INCS} \
		cmem.c \
		../../OPERATORS/PRINT/src/B1_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_I1_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_I2_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_I4_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_I8_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_F4_to_txt.c \
		../../OPERATORS/PRINT/gen_src/_F8_to_txt.c \
		../../UTILS/src/err.c \
		libmm.so \
		-shared -o libcmem.so

libsclr.so: gen_cmp gen_arith libcmem.so libmm.so
	rm -f _*.c
	lua gen_cmp.lua
	lua gen_arith.lua
	gcc ${QC_FLAGS} ${INCS} \
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
		../../UTILS/src/is_valid_chars_for_num.c \
		libmm.so \
		-shared -o libsclr.so

gen_cmp:
	lua gen_cmp.lua

gen_arith:
	lua gen_arith.lua

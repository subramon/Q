# Why are we depending on print and load csv?
INCS=-I. -I../inc/ \
	-I../../UTILS/gen_inc/ \
	-I../../UTILS/inc \
	-I../CMEM/inc \
	-I../SCLR/inc \
	-I/usr/include/lua5.1/ \


all: libvec.so libmm.so
	cp libvec.so ${Q_ROOT}/lib/
	cp libmm.so ${Q_ROOT}/lib/
	echo "done"

clean:
	rm -f *.so *.o _*
		
../../UTILS/src/txt_to_I4.c :
	make -C ../../UTILS/src/

libcmem.so :
	make -C ../CMEM/src/

libvec.so: vector.c core_vec.c buf_to_file.c copy_file.c \
	../../UTILS/src/txt_to_I4.c \
  	libmm.so libcmem.so
	gcc ${QC_FLAGS} $(INCS) \
		vector.c \
		core_vec.c \
		buf_to_file.c \
                copy_file.c \
		../../UTILS/src/B1_to_txt.c \
		../../UTILS/src/file_exists.c \
		../../UTILS/src/get_file_size.c \
                ../../UTILS/src/get_time_usec.c \
		../../UTILS/src/is_valid_chars_for_num.c \
                ../../UTILS/src/isdir.c \
                ../../UTILS/src/isfile.c \
		../../UTILS/src/rand_file_name.c \
		../../UTILS/src/rs_mmap.c \
		../../UTILS/src/txt_to_I4.c \
		../../UTILS/src/I1_to_txt.c \
		../../UTILS/src/I2_to_txt.c \
		../../UTILS/src/I4_to_txt.c \
		../../UTILS/src/I8_to_txt.c \
		../../UTILS/src/F4_to_txt.c \
		../../UTILS/src/F8_to_txt.c \
		libmm.so \
		${Q_ROOT}/lib/libcmem.so \
		-shared -o libvec.so 
	cp ../inc/core_vec_struct.h ${Q_BUILD_DIR}/include/

libmm.so :
	gcc ${QC_FLAGS} ${INCS} -shared mm.c -o libmm.so 

# do we need this?	cp ../inc/mm.h ${Q_BUILD_DIR}/include/


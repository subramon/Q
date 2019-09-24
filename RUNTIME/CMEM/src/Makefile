# Why are we depending on print and load csv?
INCS=-I. -I../inc/ \
	-I../../../UTILS/gen_inc/ \
	-I../../../UTILS/inc \
	-I/usr/include/lua5.1/ \


all: libcmem.so 
	cp libcmem.so ${Q_ROOT}/lib/
	echo "done"

clean:
	rm -f *.so *.o _*
		
../../UTILS/src/is_valid_chars_for_num.c :
	make -C ../../../UTILS/src/

../../OPERATORS/PRINT/gen_src/_I1_to_txt.c :
	make -C ../../../OPERATORS/PRINT/lua/

libcmem.so:   cmem.c 
	gcc ${QC_FLAGS} ${INCS} \
		cmem.c \
		../../../UTILS/src/B1_to_txt.c \
		../../../UTILS/gen_src/_I1_to_txt.c \
		../../../UTILS/gen_src/_I2_to_txt.c \
		../../../UTILS/gen_src/_I4_to_txt.c \
		../../../UTILS/gen_src/_I8_to_txt.c \
		../../../UTILS/gen_src/_F4_to_txt.c \
		../../../UTILS/gen_src/_F8_to_txt.c \
		-shared -o libcmem.so
	cp ../inc/cmem_struct.h ${Q_BUILD_DIR}/include/


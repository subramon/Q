# Why are we depending on print and load csv?
INCS=-I. -I../inc/ \
	-I../../../UTILS/gen_inc/ \
	-I../../../UTILS/inc \
	-I../../CMEM/inc \

all: libsclr.so 
	cp libsclr.so ${Q_ROOT}/lib/
	echo "done"

../../../UTILS/src/txt_to_B1.c :
	make -C ../../../UTILS/src/

clean:
	rm -f *.so *.o _*
		
../../CMEM/src/libcmem.so :
	make -C ../../CMEM/src/

libsclr.so: gen_cmp.lua gen_arith.lua _gen_cmp _gen_arith \
	../../../UTILS/src/txt_to_B1.c \
	../../CMEM/src/libcmem.so
	rm -f _*.c
	lua gen_cmp.lua
	lua gen_arith.lua
	gcc ${QC_FLAGS} ${INCS} \
		scalar.c \
		../../CMEM/src/cmem.c \
		../../../UTILS/src/txt_to_B1.c \
		../../../UTILS/src/txt_to_SC.c \
		../../../UTILS/src/txt_to_I1.c \
		../../../UTILS/src/txt_to_I2.c \
		../../../UTILS/src/txt_to_I4.c \
		../../../UTILS/src/txt_to_I8.c \
		../../../UTILS/src/txt_to_F4.c \
		../../../UTILS/src/txt_to_F8.c \
		../../../UTILS/src/B1_to_txt.c \
		../../../UTILS/src/SC_to_txt.c \
		../../../UTILS/src/I1_to_txt.c \
		../../../UTILS/src/I2_to_txt.c \
		../../../UTILS/src/I4_to_txt.c \
		../../../UTILS/src/I8_to_txt.c \
		../../../UTILS/src/F4_to_txt.c \
		../../../UTILS/src/F8_to_txt.c \
		../../../UTILS/src/is_valid_chars_for_num.c \
		-shared -o libsclr.so
	cp ../inc/scalar_struct.h ${Q_BUILD_DIR}/include/

_gen_cmp:
	lua gen_cmp.lua
	touch _gen_cmp

_gen_arith:
	lua gen_arith.lua
	touch _gen_arih

# Why are we depending on print and load csv?
INCS=-I. \
     	-I../inc/ \
	-I../../../UTILS/gen_inc/ \
	-I../../../UTILS/inc 


all: libcmem.so 
	cp libcmem.so ${Q_ROOT}/lib/
	echo "done"

clean:
	rm -f *.so *.o _*
		
../../UTILS/src/B1_to_txt.c :
	make -C ../../../UTILS/src/

libcmem.so:   cmem.c ../../UTILS/src/B1_to_txt.c
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
	cp ../inc/cmem.h        ${Q_BUILD_DIR}/include/


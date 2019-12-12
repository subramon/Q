# Why are we depending on print and load csv?
INCS=-I. \
     	-I../inc/ \
	-I../../../UTILS/gen_inc/ \
	-I../../../UTILS/inc 


all: libcutils.so 
	cp libcutils.so ${Q_ROOT}/lib/
	echo "done"

../../UTILS/gen_inc/_isdir.h :
	make -C ../../../UTILS/src/
clean:
	rm -f *.so *.o _*
		
libcutils.so:   cutils.c \
	../../UTILS/gen_inc/_isdir.h
	gcc ${QC_FLAGS} ${INCS} \
	cutils.c \
	../../../UTILS/src/isdir.c \
	../../../UTILS/src/isfile.c \
		-shared -o libcutils.so

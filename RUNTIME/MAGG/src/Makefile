# Why are we depending on print and load csv?
INCS=-I. \
     	-I../inc/ \
     	-I../../inc/ \
	-I../xgen_inc/ \
	-I../../../UTILS/gen_inc/ \
	-I../../../UTILS/inc \
	-I/usr/include/lua5.1/ \


all: libagg.so 
	cp libagg.so ${Q_ROOT}/lib/
	echo "done"

clean:
	rm -f *.so *.o _*
	rm -f ${Q_ROOT}/lib/libagg.so
		
libagg.so: ./*.c ../xgen_src/*.c 
	gcc ${QC_FLAGS} ${INCS} \
	../xgen_src/*.c \
	./*.c \
	-shared -o libagg.so


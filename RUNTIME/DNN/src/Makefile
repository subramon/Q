# Why are we depending on print and load csv?
INCS= -I../inc/ \
	-I../../inc/ \
	-I../../../UTILS/inc/ \
	-I/usr/include/lua5.1/

CC=clang
CC=gcc

all: libdnn.so 
	cp libdnn.so ${Q_ROOT}/lib/

clean:
	rm -r -f *.so *.o _*
		
CSRCS := $(wildcard *.c)
COBJS = $(CSRCS:.c=.o)

AVX = -mavx2 -mfma -DAVX
AVX =

CFLAGS = $(QC_FLAGS) $(AVX)
CFLAGS = $(QC_FLAGS) $(AVX) -DTEST_VS_PYTHON


count : CFLAGS = $(QC_FLAGS) -DCOUNT # for counting flops
count : all

.c.o : 
	$(CC) -c -o $@ $< $(CFLAGS)  $(INCS)

dnn.o : dnn.c ../inc/dnn_types.h ../inc/core_dnn.h
	$(CC) -c ${CFLAGS} $(INCS) dnn.c -o dnn.o

fstep_a.o : fstep_a.c ../inc/dnn_types.h ../inc/fstep_a.h
	$(CC) -c ${CFLAGS} $(INCS) fstep_a.c -o fstep_a.o

bstep.o : bstep.c ../inc/dnn_types.h ../inc/bstep.h
	$(CC) -c ${CFLAGS} $(INCS) bstep.c -o bstep.o

act_fns.o : act_fns.c ../inc/dnn_types.h ../inc/act_fns.h
	$(CC) -c ${CFLAGS} $(INCS) act_fns.c -o act_fns.o

update_W_b.o : update_W_b.c ../inc/dnn_types.h ../inc/update_W_b.h
	$(CC) -c ${CFLAGS} $(INCS) update_W_b.c -o update_W_b.o

core_dnn.o : core_dnn.c ../inc/dnn_types.h ../inc/core_dnn.h
	$(CC) -c ${CFLAGS} $(INCS) core_dnn.c -o core_dnn.o

avx.o : avx.c ../inc/dnn_types.h ../inc/avx.h
	$(CC) -c ${CFLAGS} $(INCS) avx.c -o avx.o

libdnn.so: core_dnn.o dnn.o avx.o fstep_a.o bstep.o act_fns.o update_W_b.o
	$(CC) ${CFLAGS} $(INCS) \
	core_dnn.o \
	dnn.o \
	avx.o \
	update_W_b.o \
	act_fns.o \
	fstep_a.o \
	bstep.o \
	-shared -lm -o libdnn.so

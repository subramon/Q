# Why are we depending on print and load csv?
INCS= -I../inc/ \
	-I../../inc/ \
	-I../../../UTILS/gen_inc/ \
	-I../../../UTILS/inc/ \
	-I/usr/include/lua5.1/

CC=clang
CC=gcc

all: libagg.so 
	cp libagg.so ${Q_ROOT}/lib/

clean:
	rm -r -f *.so *.o _*
		
CSRCS := $(wildcard *.c)
COBJS = $(CSRCS:.c=.o)

AVX = -mavx2 -mfma 

CFLAGS = $(QC_FLAGS) $(AVX)

count : CFLAGS = $(QC_FLAGS) 
count : all

.c.o : 
	$(CC) -c -o $@ $< $(CFLAGS)  $(INCS)

libagg.so: agg.o core_agg.o q_rhashmap.o murmurhash.o siphash.o 
	$(CC) ${CFLAGS} $(INCS) \
	agg.o \
	core_agg.o \
	murmurhash.o \
	q_rhashmap.o \
	siphash.o \
	-shared -lm -o libagg.so

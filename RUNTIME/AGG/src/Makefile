
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
		
QSRCS=`luajit expand.lua`
QOBJS=$(QSRCS:.c=.o)

CSRCS := $(wildcard *.c)
CSRCS := $(filter-out $(QSRCS), $(CSRCS))
CSRCS := $(filter-out q_rhashmap.tmpl.c, $(CSRCS))
COBJS = $(CSRCS:.c=.o)
COBJS := $(filter-out q_rhashmap.o,$(COBJS))

CFLAGS = $(QC_FLAGS)

.c.o : 
	$(CC) -c -o $@ $< $(CFLAGS)  $(INCS)

q_rhashmap.h : _buckets.h

_buckets.h : 
	luajit mk_buckets.lua  > _buckets.h

libagg.so: agg.o core_agg.o murmurhash.o _xx
	$(CC) ${CFLAGS} $(INCS) \
	$(COBJS) \
	$(QOBJS) \
	-shared -lm -o libagg.so

t1 :
	echo $(QOBJS)

_xx :
	luajit expand.lua
	touch _xx

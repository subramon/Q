
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

agg.o : agg.c

core_agg.c : ../inc/core_agg.h _files_to_include.h _creation.c

agg.c : ../inc/core_agg.h

libagg.so: agg.o core_agg.o murmurhash.o _q_rhashmap_I8_I8.c
	$(CC) ${CFLAGS} $(INCS) \
	$(COBJS) \
	$(QOBJS) \
	-shared -lm -o libagg.so

_files_to_include.h : 
	luajit expand.lua 1>/dev/null

_creation.c : 
	luajit expand.lua 1>/dev/null

_q_rhashmap_I8_I8.o : _q_rhashmap_I8_I8.c

_q_rhashmap_I8_I8.c :
	luajit expand.lua

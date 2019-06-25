
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

USRCS := $(wildcard _*.c)

CSRCS := $(wildcard *.c)
CSRCS := $(filter-out $(QSRCS), $(CSRCS))
CSRCS := $(filter-out $(USRCS), $(CSRCS))
CSRCS := $(filter-out mk_hash.tmpl.c q_rhashmap.tmpl.c, $(CSRCS))
COBJS = $(CSRCS:.c=.o)
COBJS := $(filter-out q_rhashmap.o,$(COBJS))

CFLAGS = $(QC_FLAGS)

.c.o : 
	$(CC) -c -o $@ $< $(CFLAGS)  $(INCS)

_creation.o : _creation.c

_creation.c : 
	luajit expand.lua 1>/dev/null

junk : 
	echo $(USRCS)

agg.o : agg.c _mk_hash_I4.h  _mk_hash_I8.h 

core_agg.c : ../inc/core_agg.h _files_to_include.h _creation.c

agg.c : ../inc/core_agg.h

libagg.so: agg.o core_agg.o mk_tid.o mk_loc.o murmurhash.o _q_rhashmap_I8_I8.c
	$(CC) ${CFLAGS} $(INCS) \
	$(COBJS) \
	$(QOBJS) \
	-shared -lm -o libagg.so

_mk_hash_I4.h : 
	luajit expand.lua 1>/dev/null

_files_to_include.h : 
	luajit expand.lua 1>/dev/null

_q_rhashmap_I8_I8.o : _q_rhashmap_I8_I8.c

_q_rhashmap_I8_I8.c :
	luajit expand.lua

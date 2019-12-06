
# Note that we have called it x_gen_src and x_gen_inc instead of 
# gen_src and gen_inc because we do not want it to be picked up by
# copy_generated_files() in UTILS/build/
INCS= -I. \
	-I../inc/ \
	-I../x_gen_inc/ \
	-I../x_gen_src/ \
	-I../../inc/ \
	-I../../../UTILS/inc/ \
	-I/usr/include/lua5.1/

CC=gcc

all: libagg.so 
	cp libagg.so ${Q_ROOT}/lib/
	cp ../inc/agg_struct.h  ${Q_BUILD_DIR}/include/
	# cp ../inc/*.h  ${Q_ROOT}/include/
	# cp ../inc/*struc*.h  ${Q_BUILD_DIR}/include/
	# cp ../inc/*common*.h  ${Q_BUILD_DIR}/include/
	# cp ../src/fastdiv.h  ${Q_BUILD_DIR}/include/
	# cp ../src/q_rhashmap_utils.h  ${Q_BUILD_DIR}/include/

clean:
	rm -r -f *.so *.o _*
	rm -r -f ../x_gen_src/
	rm -r -f ../x_gen_inc/
		
QSRCS=`luajit expand.lua` # Files generated
QOBJS=$(QSRCS:.c=.o)

USRCS := $(wildcard _*.c) # Files that start with underscore
TSRCS := $(wildcard *tmpl*.c) # Templates Files 

CSRCS := $(wildcard *.c)
# CSRCS := $(filter-out $(QSRCS), $(CSRCS))
CSRCS := $(filter-out $(USRCS), $(CSRCS))
CSRCS := $(filter-out $(TSRCS), $(CSRCS))
# CSRCS += q_rhashmap_mk_tid.c
# CSRCS += q_rhashmap_mk_loc.c
COBJS = $(CSRCS:.c=.o)

CFLAGS = $(QC_FLAGS)

.c.o : 
	$(CC) -c -o $@ $< $(CFLAGS)  $(INCS)

_creation.o : _creation.c

_creation.c : 
	luajit expand.lua 1>/dev/null

qfiles : 
	echo $(QSRCS)

cfiles : 
	echo $(CSRCS)

agg.o : agg.c _files_to_include.h

core_agg.c : ../inc/core_agg.h _files_to_include.h _creation.c

agg.c : ../inc/core_agg.h _files_to_include.h

libagg.so: agg.o core_agg.o murmurhash.o \
  	_q_rhashmap_I8_I8.o \
  	q_rhashmap_mk_loc.o \
  	q_rhashmap_mk_tid.o
	$(CC) ${CFLAGS} $(INCS) \
	$(COBJS) \
	$(QOBJS) \
	-shared -lm -o libagg.so

_files_to_include.h : 
	luajit expand.lua 1>/dev/null

_q_rhashmap_I8_I8.o : ../x_gen_src/_q_rhashmap_I8_I8.c

../x_gen_src/_q_rhashmap_I8_I8.c :
	luajit expand.lua

CC=gcc

CFLAGS = -g -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -Wunused-variable -Wunused-parameter -Wno-pedantic -Wno-unused-label 
CFLAGS+= -fsanitize=address -fno-omit-frame-pointer # for address sanitizer
CFLAGS+= -fsanitize=undefined
CFLAGS+= -Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith
CFLAGS+= -Wmissing-declarations -Wredundant-decls -Wnested-externs
CFLAGS+= -Wshadow -Wcast-qual -Wcast-align -Wwrite-strings
CFLAGS+= -Wold-style-definition
CFLAGS+= -Wsuggest-attribute=noreturn 
# NOT DOING THIS BECUASE WILL HAVE TO REWRITE TOO MUCH -Wjump-misses-init
# New GCC 6/7 flags:
CFLAGS+= -Wduplicated-cond -Wmisleading-indentation -Wnull-dereference
CFLAGS+= -Wduplicated-branches -Wrestrict

INCS = -I./inc/
all: dt ispdt

CSRCS := $(wildcard ./src/*.c)
CSRCS := $(filter-out ./src/eval_metrics.isp.c, $(CSRCS))
COBJS = $(CSRCS:.c=.o)

XSRCS := $(wildcard ./src/*.c)
XSRCS := $(filter-out ./src/eval_metrics.isp.c, $(CSRCS))
XSRCS := $(filter-out ./src/eval_metrics.c, $(CSRCS))
XOBJS = $(XSRCS:.c=.o)

# DFLAGS = -g -DDEBUG -DFAKE -fopenmp
DFLAGS = -g -DDEBUG -fopenmp

./inc/ispc_types.h : 
	cat ./inc/types.h | sed s'/uint32_t/uint32/'g > ./inc/ispc_types.h

src/eval_metrics.isp.o : ./inc/ispc_types.h
	ispc -I./inc/ ./src/eval_metrics.isp.c -o ./src/eval_metrics.isp.o 

.c.o : 
	$(CC) -c -o $@ $< $(CFLAGS)  $(INCS) $(DFLAGS)


dt : $(CSRCS) ./inc/*.h $(COBJS) 
	gcc ${CFLAGS} ${DFLAGS}  ${COBJS} \
	${INCS} -lm -lgomp -o dt

ispdt : $(XSRCS) ./inc/*.h $(XOBJS) src/eval_metrics.isp.o 
	gcc ${CFLAGS} ${DFLAGS}  ${XOBJS} src/eval_metrics.isp.o \
	${INCS} -lm -lgomp -o dt

clean:
	rm -f _* *.o ./src/*.o dt

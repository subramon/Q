CC=gcc

CFLAGS = -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -Wunused-variable -Wunused-parameter -Wno-pedantic -Wno-unused-label 
# CFLAGS+= -fsanitize=address -fno-omit-frame-pointer # for address sanitizer
# CFLAGS+= -fsanitize=undefined
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
CSRCS := $(filter-out ./src/calc_best_metric.isp.c, $(CSRCS))
COBJS = $(CSRCS:.c=.o)

XSRCS := $(wildcard ./src/*.c)
XSRCS := $(filter-out ./src/eval_metrics.c, $(XSRCS))
XSRCS := $(filter-out ./src/calc_best_metric.c, $(XSRCS))
XOBJS = $(XSRCS:.c=.o)

# DFLAGS = -g -DDEBUG -DFAKE -fopenmp
DFLAGS = -g -DDEBUG -fopenmp -DSCALAR
DFLAGS = -g -DDEBUG -fopenmp -DVECTOR
DFLAGS = -g -DDEBUG -fopenmp -DSCALAR
DFLAGS = -O4 -fopenmp -DSCALAR

./inc/types.isp.h : 
	cat ./inc/types.h | sed s'/uint32_t/uint32/'g > ./inc/types.isp.h

#---------------------------------------------
./inc/eval_metrics.isp.h : ./src/eval_metrics.isp.c
	ispc -I./inc/  src/eval_metrics.isp.c -h inc/eval_metrics.isp.h

./src/eval_metrics.isp.o : ./inc/types.isp.h \
  	./src/eval_metrics.isp.c ./inc/eval_metrics.isp.h
	ispc -I./inc/ ./src/eval_metrics.isp.c -o ./src/eval_metrics.isp.o 

#---------------------------------------------
./inc/calc_best_metric.isp.h : ./src/calc_best_metric.isp.c
	ispc -I./inc/  src/calc_best_metric.isp.c -h inc/calc_best_metric.isp.h

./src/calc_best_metric.isp.o : ./inc/types.isp.h \
	./src/calc_best_metric.isp.c ./inc/calc_best_metric.isp.h
	ispc -I./inc/ ./src/calc_best_metric.isp.c -o ./src/calc_best_metric.isp.o 

#---------------------------------------------

.c.o : 
	$(CC) -c -o $@ $< $(CFLAGS)  $(INCS) $(DFLAGS)


dt : $(CSRCS) $(COBJS) 
	gcc ${CFLAGS} ${DFLAGS} -DSCALAR  ${COBJS} \
	${INCS} -lm -lgomp -o dt

ispdt : $(XSRCS) $(XOBJS) 
	gcc ${CFLAGS} ${DFLAGS} -DVECTOR  \
  	${XOBJS} \
	${INCS} -lm -lgomp -o ispdt

clean:
	rm -f _* *.o ./src/*.o dt
	rm -f ./inc/eval_metrics.isp.h 

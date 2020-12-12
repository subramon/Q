CC=gcc

CFLAGS =  -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -Wunused-variable -Wunused-parameter -Wno-pedantic -Wno-unused-label 
# CFLAGS+= -fsanitize=address -fno-omit-frame-pointer # for address sanitizer
# CFLAGS+= -fsanitize=undefined
CFLAGS+= -Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith
CFLAGS+= -Wmissing-declarations -Wredundant-decls -Wnested-externs
CFLAGS+= -Wshadow -Wcast-qual -Wcast-align -Wwrite-strings
CFLAGS+= -Wold-style-definition
CFLAGS+= -Wsuggest-attribute=noreturn 
# NOT DOING THIS BECUASE WILL HAVE TO REWRITE TOO MUCH -Wjump-misses-init
# New GCC 6/7 flags:
# CFLAGS+= -Wduplicated-cond -Wmisleading-indentation -Wnull-dereference
# CFLAGS+= -Wduplicated-branches -Wrestrict

INCS = -I./inc/
all: dt ut_calc_best_metric

CSRCS := $(wildcard ./src/*.c)
CSRCS := $(filter-out ./src/eval_metrics_isp.c, $(CSRCS))
CSRCS := $(filter-out ./src/calc_best_metric_isp.c, $(CSRCS))
CSRCS := $(filter-out ./src/reorder.isp.c, $(CSRCS))
CSRCS := $(filter-out ./src/ut_eval_metrics.c, $(CSRCS))
CSRCS := $(filter-out ./src/ut_calc_best_metric.c, $(CSRCS))
COBJS = $(CSRCS:.c=.o)

ISP_SRCS := $(wildcard ./src/*.c)
ISP_SRCS := $(filter-out ./src/eval_metrics.c, $(ISP_SRCS))
ISP_SRCS := $(filter-out ./src/calc_best_metric.c, $(ISP_SRCS))
ISP_SRCS := $(filter-out ./src/ut_eval_metrics.c, $(ISP_SRCS))
ISP_SRCS := $(filter-out ./src/ut_calc_best_metric.c, $(ISP_SRCS))
ISP_OBJS = $(ISP_SRCS:.c=.o)

DFLAGS = -g -DDEBUG -fopenmp -DVECTOR
DFLAGS = -g -DDEBUG -fopenmp -DSCALAR
DFLAGS = -g -DDEBUG -DSCALAR
DFLAGS = -O4 -fopenmp -DVECTOR -pg
DFLAGS = -O4 -fopenmp -DSCALAR -pg
DFLAGS = -g -DDEBUG -DSCALAR -DSEQUENTIAL
# to run gprof, add -pg to DFLAGS
# ./dt
# gprof ./dt > _outputfile

./inc/types.isp.h : 
	cat ./inc/types.h | sed s'/uint32_t/uint32/'g > ./inc/types.isp.h

#---------------------------------------------
./inc/eval_metrics_isp.h : ./src/eval_metrics_isp.c
	ispc -I./inc/  src/eval_metrics_isp.c -h inc/eval_metrics_isp.h

./src/eval_metrics_isp.o : ./inc/types.isp.h \
  	./src/eval_metrics_isp.c ./inc/eval_metrics_isp.h
	ispc -O3 --pic -I./inc/ ./src/eval_metrics_isp.c -o ./src/eval_metrics_isp.o 

#---------------------------------------------
./inc/calc_best_metric_isp.h : ./src/calc_best_metric_isp.c
	ispc -I./inc/  src/calc_best_metric_isp.c -h inc/calc_best_metric_isp.h

./src/calc_best_metric_isp.o : ./inc/types.isp.h \
	./src/calc_best_metric_isp.c ./inc/calc_best_metric_isp.h
	ispc -O3 --pic -I./inc/ ./src/calc_best_metric_isp.c -o ./src/calc_best_metric_isp.o 

#---------------------------------------------

.c.o : 
	$(CC) -c -o $@ $< $(CFLAGS)  $(INCS) $(DFLAGS)


dt : $(CSRCS) $(COBJS) 
	gcc ${CFLAGS} ${DFLAGS} -DSCALAR  ${COBJS} \
	${INCS} -lm -lgomp -o dt

ispdt : $(ISP_SRCS) $(ISP_OBJS) 
	gcc ${CFLAGS} ${DFLAGS} -DVECTOR  \
  	${ISP_OBJS} \
	${INCS} -lm -lgomp -o ispdt


UT_SRCS := src/ut_calc_best_metric.c 
UT_SRCS += src/calc_best_metric.c
UT_SRCS += src/get_time_usec.c
UT_OBJS = $(UT_SRCS:.c=.o)
UT_OBJS += ./src/calc_best_metric_isp.o

ut_calc_best_metric : ${UT_OBJS} 
	gcc ${CFLAGS} ${DFLAGS} -DVECTOR ${UT_OBJS} \
	${INCS} -lm -lgomp -o ut_calc_best_metric

qclean:
	rm -f _* *.o ./src/*.o

clean:
	rm -f _* *.o ./src/*.o dt
	rm -f ./inc/eval_metrics_isp.h 
	rm -f ./inc/calc_best_metrics_isp.h 

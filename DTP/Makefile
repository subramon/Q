CC=gcc

CFLAGS = -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -Wunused-variable -Wunused-parameter -Wno-pedantic -Wno-unused-label 
# below  for address sanitizer
# CFLAGS+= -fsanitize=address -fno-omit-frame-pointer 
# CFLAGS+= -fsanitize=undefined
# above  for address sanitizer
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
all: dtp

#---------------------------------------------------
CSRCS := $(wildcard ./src/*.c)

# CSRCS := $(filter-out ./src/eval_metrics_isp.c, $(CSRCS))
COBJS = $(CSRCS:.c=.o)
#---------------------------------------------------
DFLAGS = -g -DDEBUG -fopenmp
# to run gprof, add -pg to DFLAGS
# ./dt
# gprof ./dt > _outputfile
#---------------------------------------------
.c.o : 
	$(CC) -c -o $@ $< $(CFLAGS)  $(INCS) $(DFLAGS)


dtp : $(COBJS) 
	gcc ${CFLAGS} ${DFLAGS} ${COBJS} \
	${INCS} -lm -lgomp -o dtp

#-------------------------------------------
# for unit tests 
UT1_SRCS := src/ut_calc_best_metric.c 
UT1_SRCS += src/calc_best_metric.c
UT1_SRCS += src/get_time_usec.c
UT1_OBJS = $(UT1_SRCS:.c=.o)
UT1_OBJS += ./src/calc_best_metric_isp.o

ut1 : ${UT1_OBJS} ./inc/calc_best_metric.h 
	gcc ${CFLAGS} ${DFLAGS} -DVECTOR ${UT1_OBJS} \
	${INCS} -lm -lgomp -o ut1
#-------------------------------------------
clean:
	rm -f _* *.o ./src/*.o dtp ut1

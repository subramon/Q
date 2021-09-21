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
# CFLAGS+= -Wduplicated-cond -Wmisleading-indentation -Wnull-dereference
# CFLAGS+= -Wduplicated-branches -Wrestrict

INCS = -I./inc/
all: dt \
	ut_calc_best_metric \
	ut_eval_metrics \
	ut_reorder \
	ut_accumulate \
	ut_sort \
	ut_mt_reorder \
	run_dt_eval \
	run_mt_dt_eval \


#---------------------------------------------------
CSRCS := $(wildcard ./src/*.c)

CSRCS := $(filter-out ./src/eval_metrics_isp.c, $(CSRCS))
CSRCS := $(filter-out ./src/calc_best_metric_isp.c, $(CSRCS))
CSRCS := $(filter-out ./src/reorder_isp.c, $(CSRCS))

CSRCS := $(filter-out ./src/ut_eval_metrics.c, $(CSRCS))
CSRCS := $(filter-out ./src/ut_calc_best_metric.c, $(CSRCS))
CSRCS := $(filter-out ./src/ut_reorder.c, $(CSRCS))
CSRCS := $(filter-out ./src/ut_accumulate.c, $(CSRCS))
CSRCS := $(filter-out ./src/ut_sort.c, $(CSRCS))
CSRCS := $(filter-out ./src/benchmark_sort.c, $(CSRCS))
CSRCS := $(filter-out ./src/ut_mt_reorder.c, $(CSRCS))
COBJS = $(CSRCS:.c=.o)
#---------------------------------------------------
ISP_SRCS := $(wildcard ./src/*.c)

ISP_SRCS := $(filter-out ./src/eval_metrics.c, $(ISP_SRCS))
ISP_SRCS := $(filter-out ./src/calc_best_metric.c, $(ISP_SRCS))
ISP_SRCS := $(filter-out ./src/reorder.c, $(ISP_SRCS))

ISP_SRCS := $(filter-out ./src/ut_eval_metrics.c, $(ISP_SRCS))
ISP_SRCS := $(filter-out ./src/ut_calc_best_metric.c, $(ISP_SRCS))
ISP_SRCS := $(filter-out ./src/ut_reorder.c, $(ISP_SRCS))
ISP_SRCS := $(filter-out ./src/ut_sort.c, $(ISP_SRCS))
CSRCS := $(filter-out ./src/ut_mt_reorder.c, $(CSRCS))
ISP_SRCS := $(filter-out ./src/benchmark_sort.c, $(ISP_SRCS))
ISP_OBJS = $(ISP_SRCS:.c=.o)
#---------------------------------------------------

DFLAGS = -g -DDEBUG -DVECTOR -fopenmp
DFLAGS = -O4 -fopenmp -DVECTOR -pg
DFLAGS = -g -DDEBUG -DSCALAR -DSEQUENTIAL
DFLAGS = -g -fopenmp -DDEBUG -DSCALAR
DFLAGS = -g -DDEBUG -fopenmp -DSCALAR
DFLAGS = -O4 -fopenmp -DSCALAR -pg
DFLAGS = -O4
DFLAGS = -g -DDEBUG
DFLAGS = -g -DDEBUG -fopenmp 
# to run gprof, add -pg to DFLAGS
# ./dt
# gprof ./dt > _outputfile

#---------------------------------------------
./inc/reorder_isp.h : ./src/reorder_isp.c
	ispc -I./inc/  src/reorder_isp.c -h inc/reorder_isp.h

./src/reorder_isp.o : ./inc/types_isp.h \
  	./src/reorder_isp.c ./inc/reorder_isp.h
	ispc -O3 --pic -I./inc/ ./src/reorder_isp.c -o ./src/reorder_isp.o 

#---------------------------------------------
./inc/eval_metrics_isp.h : ./src/eval_metrics_isp.c
	ispc -I./inc/  src/eval_metrics_isp.c -h inc/eval_metrics_isp.h

./src/eval_metrics_isp.o : ./inc/types_isp.h \
  	./src/eval_metrics_isp.c ./inc/eval_metrics_isp.h
	ispc -O3 --pic -I./inc/ ./src/eval_metrics_isp.c -o ./src/eval_metrics_isp.o 

#---------------------------------------------
./inc/calc_best_metric_isp.h : ./src/calc_best_metric_isp.c
	ispc -I./inc/  src/calc_best_metric_isp.c -h inc/calc_best_metric_isp.h

./src/calc_best_metric_isp.o : ./inc/types_isp.h \
	./src/calc_best_metric_isp.c ./inc/calc_best_metric_isp.h
	ispc -O3 --pic -I./inc/ ./src/calc_best_metric_isp.c -o ./src/calc_best_metric_isp.o 

./inc/types_isp.h : ./inc/types.h 
	cat ./inc/types.h | \
	sed s'/uint32_t/uint32/'g | sed s'/uint64_t/uint64/'g \
	> ./inc/types_isp.h
#---------------------------------------------
ISP_INCS := ./inc/reorder_isp.h
ISP_INCS += ./inc/calc_best_metric_isp.h
ISP_INCS += ./inc/eval_metrics_isp.h

./src/search_j.o : ${ISP_INCS}
./src/split.o : ${ISP_INCS}

.c.o : 
	$(CC) -c -o $@ $< $(CFLAGS)  $(INCS) $(DFLAGS)


dt : $(COBJS) 
	gcc ${CFLAGS} ${DFLAGS} -DSCALAR  ${COBJS} \
	${INCS} -lm  -o dt -lpthread -lgomp

ispdt : $(ISP_INCS) $(ISP_SRCS) $(ISP_OBJS) 
	gcc ${CFLAGS} ${DFLAGS} -DVECTOR  ${ISP_OBJS} \
	${INCS} -lm -o ispdt -lpthread -lgomp

#-------------------------------------------
UT1_SRCS := src/ut_calc_best_metric.c 
UT1_SRCS += src/calc_best_metric.c
UT1_SRCS += src/get_time_usec.c
UT1_OBJS = $(UT1_SRCS:.c=.o)
UT1_OBJS += ./src/calc_best_metric_isp.o

ut_calc_best_metric : ${UT1_OBJS} ./inc/calc_best_metric.h 
	gcc ${CFLAGS} ${DFLAGS} -DVECTOR ${UT1_OBJS} \
	${INCS} -lm -lgomp -o ut_calc_best_metric
#-------------------------------------------
UT2_SRCS := src/ut_eval_metrics.c 
UT2_SRCS += src/eval_metrics.c
UT2_SRCS += src/get_time_usec.c
UT2_OBJS = $(UT2_SRCS:.c=.o)
UT2_OBJS += ./src/eval_metrics_isp.o

./src/ut_eval_metrics.o : inc/eval_metrics_isp.h 

ut_eval_metrics : ${UT2_OBJS} ./inc/eval_metrics_isp.h 
	gcc ${CFLAGS} ${DFLAGS} -DVECTOR ${UT2_OBJS} \
	${INCS} -lm -lgomp -o ut_eval_metrics
#-------------------------------------------
UT3_SRCS := src/ut_reorder.c 
UT3_SRCS += src/reorder.c
UT3_SRCS += src/prnt_data.c
UT3_SRCS += src/preproc_j.c
UT3_SRCS += src/check.c
UT3_SRCS += src/get_time_usec.c
UT5_SRCS += src/qsort_asc_val_F4_idx_I1.c
UT3_OBJS = $(UT3_SRCS:.c=.o)
UT3_OBJS += ./src/reorder_isp.o

./src/ut_reorder.o : inc/reorder_isp.h 

ut_reorder : ${UT3_OBJS} ./inc/reorder_isp.h 
	gcc ${CFLAGS} ${DFLAGS} -DVECTOR ${UT3_OBJS} \
	${INCS} -lm -lgomp -o ut_reorder

#-------------------------------------------
UT4_SRCS := src/accumulate.c 
UT4_SRCS += src/ut_accumulate.c 
UT4_SRCS += src/read_config.c 
UT4_OBJS = $(UT4_SRCS:.c=.o)
ut_accumulate : ${UT4_OBJS} 
	gcc ${CFLAGS} ${DFLAGS} ${UT4_OBJS} ${INCS} -o ut_accumulate -lgomp

#-------------------------------------------
UT5_SRCS := src/ut_sort.c 
# UT5_SRCS += src/qsort_asc_val_F4_idx_I1.c
UT5_SRCS += src/qsort_asc_val_F4_idx_I1.c
UT5_SRCS += src/qsort_asc_val_F4_idx_I2.c
UT5_OBJS = $(UT5_SRCS:.c=.o)
ut_sort : ${UT5_OBJS} 
	gcc ${CFLAGS} ${DFLAGS} ${UT5_OBJS} ${INCS} -o ut_sort

#-------------------------------------------
UT6_SRCS := src/ut_mt_reorder.c 
UT6_SRCS += src/reorder.c
UT6_SRCS += src/prnt_data.c
UT6_SRCS += src/preproc_j.c
UT6_SRCS += src/check.c
UT6_SRCS += src/get_time_usec.c
UT6_OBJS = $(UT6_SRCS:.c=.o)
UT6_OBJS += ./src/reorder_isp.o

ut_mt_reorder : ${UT6_OBJS} ./inc/reorder_isp.h 
	gcc ${CFLAGS} ${DFLAGS} -DVECTOR ${UT6_OBJS} \
	${INCS} -lm -o ut_mt_reorder -lpthread -lgomp

#-------------------------------------------
# vector evaluation of decision tree
VEC_EVAL_SRCS := dt_eval/main.c
VEC_EVAL_SRCS += dt_eval/sclr_eval.c
VEC_EVAL_SRCS += src/reorder.c
VEC_EVAL_SRCS += src/preproc_j.c
VEC_EVAL_SRCS += src/check.c
VEC_EVAL_SRCS += src/prnt_data.c
VEC_EVAL_SRCS += src/get_time_usec.c
VEC_EVAL_OBJS = $(VEC_EVAL_SRCS:.c=.o)
VEC_EVAL_OBJS += ./dt_eval/vctr_eval_isp.o
VEC_EVAL_OBJS += ./dt_eval/make_fake_tree.o
VEC_EVAL_OBJS += ./dt_eval/make_fake_data.o

# multi-threaded vector evaluation of decision tree
MT_VEC_EVAL_SRCS := dt_eval/mt_main.c
MT_VEC_EVAL_SRCS += dt_eval/sclr_eval.c
MT_VEC_EVAL_SRCS += src/reorder.c
MT_VEC_EVAL_SRCS += src/preproc_j.c
MT_VEC_EVAL_SRCS += src/check.c
MT_VEC_EVAL_SRCS += src/prnt_data.c
MT_VEC_EVAL_SRCS += src/get_time_usec.c
MT_VEC_EVAL_OBJS = $(MT_VEC_EVAL_SRCS:.c=.o)
MT_VEC_EVAL_OBJS += ./dt_eval/vctr_eval_isp.o
MT_VEC_EVAL_OBJS += ./dt_eval/make_fake_tree.o
MT_VEC_EVAL_OBJS += ./dt_eval/make_fake_data.o
INCS += -I./dt_eval/

#---------------------------------------------
./dt_eval/vctr_eval_isp.h : ./dt_eval/vctr_eval_isp.c
	ispc -I./inc/  dt_eval/vctr_eval_isp.c -h dt_eval/vctr_eval_isp.h

./dt_eval/vctr_eval_isp.o : ./inc/types_isp.h \
  	./dt_eval/vctr_eval_isp.c ./dt_eval/vctr_eval_isp.h
	ispc -O3 --pic $(INCS) ./dt_eval/vctr_eval_isp.c -o ./dt_eval/vctr_eval_isp.o 

#---------------------------------------------
run_dt_eval : ${VEC_EVAL_OBJS} ./inc/reorder_isp.h 
	gcc ${CFLAGS} ${DFLAGS} ${VEC_EVAL_OBJS} \
	${INCS} -lm -o run_dt_eval -lpthread -lgomp

run_mt_dt_eval : ${MT_VEC_EVAL_OBJS} ./inc/reorder_isp.h 
	gcc ${CFLAGS} ${DFLAGS} ${MT_VEC_EVAL_OBJS} \
	${INCS} -lm -o run_mt_dt_eval -lpthread -lgomp



qclean:
	rm -f _* *.o ./src/*.o

clean:
	rm -f _* *.o ./src/*.o dt run_dt_eval run_mt_dt_eval
	rm -f ./dt_eval/*.o
	rm -f ./inc/reorder_isp.h 
	rm -f ./inc/eval_metrics_isp.h 
	rm -f ./inc/calc_best_metrics_isp.h 

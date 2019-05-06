CC = gcc
DBG_FLAGS = 
DBG_FLAGS = -g

OPT_FLAGS = -O4
OPT_FLAGS = 
FLAGS= $(OPT_FLAGS) $(DBG_FLAGS) ${QC_FLAGS}

INCS= -I../inc \
	-I../gen_inc \
	-I../../../UTILS/inc \
	-I../../../UTILS/gen_inc

all : test_mm_mul_simple test_mv_mul_simple 

clean :
	rm -f test_mm_mul_simple test_mv_mul_simple *.o
%.o: %.c $(DEPS)
	$(CC) $(INCS) $(FLAGS) -c -o $@ $< -I

../gen_src/_mm_mul_simple_F4_F4_F4.c :
	make -C ../lua/

../gen_src/_mv_mul_simple_F4_F4_F4.c :
	make -C ../lua/

MM_SRCS = ../gen_src/_mm_mul_simple_F4_F4_F4.c test_mm_mul_simple.c 

MV_SRCS = ../gen_src/_mv_mul_simple_F4_F4_F4.c test_mv_mul_simple.c 

test_mm_mul_simple : $(MM_SRCS)
	$(CC) $(MM_SRCS) $(INCS) $(FLAGS) -o test_mm_mul_simple -lm
	  	
test_mv_mul_simple : $(MV_SRCS)
	$(CC) $(MV_SRCS) $(INCS) $(FLAGS) -o test_mv_mul_simple -lm
	  	

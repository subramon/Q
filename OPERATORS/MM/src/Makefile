CC = gcc
DBG_FLAGS = -g
DBG_FLAGS = 

OPT_FLAGS = 
OPT_FLAGS = -O4
FLAGS= $(OPT_FLAGS) $(DBG_FLAGS) ${QC_FLAGS}
DEPS = matrix_multiply.h

INCS= -I../inc \
      -I../../../UTILS/inc/ \
      -I../../../UTILS/gen_inc/

all : mm libmm.so
	test -d ${QQ_BUILD_DIR}
	cp matrix_multiply.c ${Q_BUILD_DIR}/src/
	cp matrix_multiply.h ${Q_BUILD_DIR}/include/

%.o: %.c $(DEPS)
	$(CC) $(INCS) $(FLAGS) -c -o $@ $< -I

libmm.so : matrix_multiply.c 
	$(CC) -c $(INCS) $(FLAGS) ${Q_LINK_FLAGS} matrix_multiply.c -o libmm.so
mm: driver_mm.c matrix_multiply.c
	$(CC) $(INCS) $(FLAGS)  \
	  	driver_mm.c matrix_multiply.c mm_helpers.c -o mm -lm
	cp matrix_multiply.c ${Q_BUILD_DIR}/src/

clean:
	rm -f *.o mm *.so

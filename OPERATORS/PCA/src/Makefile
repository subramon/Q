
CC = gcc
DBG_FLAGS = 
DBG_FLAGS = -g

OPT_FLAGS = -O4
OPT_FLAGS = 

FLAGS= $(OPT_FLAGS) $(DBG_FLAGS) -std=gnu99 -fPIC -Wall -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic -fopenmp -pthread
LINK_FLAGS =  -lm -lgomp 

INCS= -I../../../UTILS/inc -I../inc

all: corrm libcorrm.so eigen
	test -d ${QQ_BUILD_DIR}
	cp corr_mat.c ${Q_BUILD_DIR}/src/
	cp corr_mat.h ${Q_BUILD_DIR}/include/
# The LINK_FLAGS need to go at the end, otherwise the make will not work as
# expected
libcorrm.so : corr_mat.c
	$(CC) -shared $(INCS) $(FLAGS) $(LINK_FLAGS) corr_mat.c -o libcorrm.so 

eigen :
	make -f eigen_Makefile

corrm: corr_mat.o test_corr_mat.o
	$(CC) $(INCS) $(FLAGS) $(LINK_FLAGS) \
	corr_mat.o test_corr_mat.o -o corrm

.c.o : $(DEPS)
	$(CC) $(INCS) $(FLAGS)  -c -o $@ $< 

clean:
	rm -f *.o 
	rm -f corrm
	rm -f *.so
	make -f eigen_Makefile clean




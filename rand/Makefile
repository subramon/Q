#
# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
WARN=  -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic -Wno-aggregate-return -Wno-unused-parameter
INCS= -I. \
	-I../..

DBGFLAGS= -g -DDEBUG
DBGFLAGS= 

OPTFLAGS= 
OPTFLAGS= -O4

LFLAGS= $(DBGFLAGS) $(OPTFLAGS)  $(WARN) 
CFLAGS= $(LFLAGS)  -fopenmp

CC=gcc

CSRCS := $(wildcard *.c)
COBJS = $(CSRCS:.c=.o)

all : test_rand 


.c.o : 
	$(CC) -c -o $@ $< $(CFLAGS)  $(INCS) $(DBGFLAGS)

test_rand : $(COBJS)  
	$(CC) $(CFLAGS) $(COBJS) \
	  -o test_rand  \
	-lm  -lpthread -ldl  -lgsl -lgslcblas

clean:
	rm -r -f test_rand *.o
	echo "ALL CLEAN"


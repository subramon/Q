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

all : driver1  driver2


.c.o : 
	$(CC) -c -o $@ $< $(CFLAGS)  $(INCS) $(DBGFLAGS)

driver1 : driver1.o poisson.o urand.o rdtsc.o
	$(CC) $(CFLAGS) driver1.o poisson.o urand.o rdtsc.o \
	  -o driver1  \
	-lm  -lpthread -ldl  -lgsl -lgslcblas

driver2 : driver2.o poisson.o urand.o rdtsc.o
	$(CC) $(CFLAGS) driver2.o poisson.o urand.o rdtsc.o \
	  -o driver2  \
	-lm  -lpthread -ldl  -lgsl -lgslcblas

clean:
	rm -r -f driver1 driver2 *.o
	echo "ALL CLEAN"


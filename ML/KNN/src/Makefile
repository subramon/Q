# For fast version, make -e DBGFLAGS="" -e OPTFLAGS=" -O4"
#
WARN=  -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic  -fopenmp
# Uncomment following to use openmp. Also, you need
# export LD_LIBRARY_PATH="/usr/local/lib64:$LD_LIBRARY_PATH"
# else you will get 
# else you will get 
# ./test_dt: /usr/lib/x86_64-linux-gnu/libgomp.so.1: version `GOMP_4.0' not
# found (required by ./test_dt)
INCS= -I../inc/ \
	-I../../../UTILS/inc/  


DBGFLAGS= -g -DDEBUG
DBGFLAGS= 

OPTFLAGS= -O4
OPTFLAGS= 
OPTFLAGS= -O4 -fopenmp

LFLAGS= $(DBGFLAGS) $(OPTFLAGS)  $(WARN) 
CFLAGS= $(LFLAGS)  

CC= clang
CC= gcc

CSRCS := $(wildcard *.c)
COBJS = $(CSRCS:.c=.o)

all : calc_vote_per_g.so

.c.o : 
	$(CC) -c -o $@ $< $(CFLAGS)  $(INCS)

calc_vote_per_g.so : $(COBJS) 
	$(CC) -shared $(CFLAGS) $(COBJS) $(INCS) -o calc_vote_per_g.so -lgomp

clean:
	rm -r -f *.so *.o
	echo "ALL CLEAN"


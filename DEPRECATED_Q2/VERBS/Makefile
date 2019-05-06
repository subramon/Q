
WARN= -O2 -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic

INCS= \
  -I../AUX/ \
  -I../PRIMITIVES/inc/ 

LIB_OPTION = -shared

CFLAGS= $(WARN) $(INCS)
CC= gcc

INCDIR=-I./inc/ -I../AUX/ 
# CFLAGS=-I$(INCDIR) -I../AUX/ -std=gnu99 -Wall -pedantic -c


LIBS=-lm

DEPS = $(shell ls inc/ )

SRCS = $(shell find . -name \*.c -print)
OBJS = $(SRCS:.c=.o)

all: verbs.so

%.o : %.c
	$(CC) -c -o $@ $< $(CFLAGS) $(INCS) $(INCDIR)

.c.o :
	$(CC) -c -o $@ $< $(CFLAGS)  $(INCS)


verbs.so: $(OBJS)
	$(CC) $(CFLAGS) $(LIB_OPTION) -o $@ $^ 

.PHONY: clean

clean:
	rm -f $(OBJS) verbs.so



WARN= -O2 -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic

INCS= \
  -I../AUX/ \
  -I./inc/ 

LIB_OPTION = -shared

CFLAGS= $(WARN) $(INCS)
CC= gcc

INCDIR=-I./inc/ -I../AUX/ 
# CFLAGS=-I$(INCDIR) -I../AUX/ -std=gnu99 -Wall -pedantic -c

OBJDIR=./obj
SRCDIR=./src
LIBDIR =../lib

LIBS=-lm

DEPS = $(shell ls inc/ )

SRCS = $(shell ls src/ | sed s'/^/.\/src\//'g )
OBJS = $(shell ls src/ | sed s'/^/.\/obj\//'g  | sed s'/\.c/.o/'g ) 

all: primitives.so

$(OBJDIR)/%.o : $(SRCDIR)/%.c
	echo $(INCS)
	$(CC) -c -o $@ $< $(CFLAGS) $(INCS) $(INCDIR)

.c.o :
	$(CC) -c -o $@ $< $(CFLAGS)  $(INCS)


primitives.so: $(OBJS)
	$(CC) $(CFLAGS) $(LIB_OPTION) -o $@ $^ 

.PHONY: clean

clean:
	rm -f $(OBJS) primitives.so


DBGFLAGS= 
DBGFLAGS= -g -DDEBUG

OPTFLAGS= -O4
OPTFLAGS= 

LFLAGS= $(DBGFLAGS) $(OPTFLAGS)  $(QC_FLAGS)

CFLAGS= $(LFLAGS) 

CC= clang
CC= gcc

CSRCS := $(wildcard *.c)
COBJS = $(CSRCS:.c=.o)

INCS = -I../inc/ -I../../UTILS/inc/
all : q_httpd 

.c.o : 
	$(CC) -c -o $@ $< $(CFLAGS)  $(INCS) $(DBGFLAGS)

q_httpd : $(COBJS)  
	$(CC) $(CFLAGS) $(COBJS) \
	../../UTILS/src/isfile.c \
	$(INCS) \
	-o q_httpd  \
	-lm  -lpthread -ldl -levent /usr/local/lib/libluajit-5.1.so

clean:
	rm -r -f q_httpd $(COBJS) 
	echo "ALL CLEAN"

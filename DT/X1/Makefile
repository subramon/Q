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
all: dt 

#---------------------------------------------------
CSRCS := $(wildcard ./src/*.c)
COBJS = $(CSRCS:.c=.o)
#---------------------------------------------------
.c.o : 
	$(CC) -c -o $@ $< $(CFLAGS)  $(INCS) $(DFLAGS)
#---------------------------------------------------
DFLAGS = -g -DDEBUG 
dt : $(CSRCS) $(COBJS) 
	gcc ${CFLAGS} ${DFLAGS} ${COBJS} ${INCS} -lm -o dt

clean:
	rm -f _* *.o ./src/*.o dt


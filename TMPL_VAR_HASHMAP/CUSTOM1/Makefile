
CFLAGS := -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align 
CFLAGS += -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings 
CFLAGS += -Wunused-variable -Wunused-parameter -Wno-pedantic 
CFLAGS += -Wno-unused-label 
# CFLAGS := -fsanitize=address -fno-omit-frame-pointer -fsanitize=undefined 
CFLAGS += -Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith 
CFLAGS += -Wmissing-declarations -Wredundant-decls -Wnested-externs 
CFLAGS += -Wshadow -Wcast-qual -Wcast-align -Wwrite-strings 
CFLAGS += -Wold-style-definition -Wsuggest-attribute=noreturn 
# CFLAGS += -Wduplicated-cond -Wmisleading-indentation -Wnull-dereference 
# CFLAGS += -Wduplicated-branches -Wrestrict

DFLAGS = -O4 
DFLAGS = -g -DDEBUG 
# Add -pg for grpof 

CC=gcc

TMPL=CUSTOM1
INCS = -I./inc/ -I../inc/
all: libhmap_${TMPL}.so

SRCS := ./src/key_cmp.c 
SRCS += ./src/key_chk.c 
SRCS += ./src/key_copy.c 
SRCS += ./src/key_free.c 
SRCS += ./src/key_hash.c 
SRCS += ./src/key_len.c 

SRCS += ./src/val_free.c 

SRCS += ./src/val_chk.c 
SRCS += ./src/val_copy.c 
SRCS += ./src/val_update.c 

SRCS += ./src/inval_chk.c 
SRCS += ./src/inval_copy.c 
SRCS += ./src/inval_update.c 

# TODO P1 IS THIS NEEDED? SRCS += ./src/val_set.c 

OBJS = $(SRCS:.c=.o)

.c.o : 
	$(CC) -c -o $@ $< ${CFLAGS} ${DFLAGS} $(INCS) 

libhmap_${TMPL}.so: ${OBJS}  ./inc/*.h 
	gcc  ${CFLAGS} ${DFLAGS} ${OBJS} ${INCS} \
	  -shared -o libhmap_${TMPL}.so

clean:
	rm -f *.o *.so ./src/*.o

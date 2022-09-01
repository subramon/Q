
CFLAGS := -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align 
CFLAGS += -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings 
CFLAGS += -Wunused-variable -Wunused-parameter -Wno-pedantic 
CFLAGS += -Wno-unused-label 
# CFLAGS := -fsanitize=address -fno-omit-frame-pointer -fsanitize=undefined 
CFLAGS += -Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith 
CFLAGS += -Wmissing-declarations -Wredundant-decls -Wnested-externs 
CFLAGS += -Wshadow -Wcast-qual -Wcast-align -Wwrite-strings 
CFLAGS += -Wold-style-definition -Wsuggest-attribute=noreturn 
CFLAGS += -Wduplicated-cond -Wmisleading-indentation -Wnull-dereference 
CFLAGS += -Wduplicated-branches -Wrestrict

DFLAGS = -g -DDEBUG 
# DFLAGS = -O4
# Add -pg for grpof 

INCS += -I../inc/ 
INCS += -I./inc/ 

TMPL=CASE1

all: ${OBJS}

SRCS :=	./spooky_hash.c  
SRCS +=	./rdtsc.c  
SRCS +=	./rs_hmap_aux.c  
SRCS +=	./rs_hmap_instantiate.c  
SRCS +=	./rs_hmap_pr.c  
SRCS +=	./rs_hmap_chk.c  
SRCS +=	./rs_hmap_del.c  
SRCS +=	./rs_hmap_destroy.c  
SRCS +=	./rs_hmap_get.c  
SRCS +=	./rs_hmap_insert.c  
SRCS +=	./rs_hmap_merge.c  
SRCS +=	./rs_hmap_put.c  
SRCS +=	./rs_hmap_resize.c  
SRCS +=	./rs_hmap_row_bindmp.c  
SRCS +=	./calc_new_size.c  
SRCS +=	./murmurhash.c  
SRCS +=	./fasthash.c  

OBJS = $(SRCS:.c=.o)


.c.o : 
	$(CC) -c -o $@ $< ${CFLAGS} ${DFLAGS} $(INCS) 

libhmap.so: ${OBJS} 
	gcc  ${OBJS} -shared -lm -o libhmap.so  -ldl

test_fastrem : ./test/test_fastrem.c 
	gcc  ${CFLAGS} ${DFLAGS} ${INCS} ./test/test_fastrem.c \
	  src/get_time_usec.c \
	-o test_fastrem

clean:
	rm -f *.o *.so

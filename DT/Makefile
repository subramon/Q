CFLAGS = -g -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -Wunused-variable -Wunused-parameter -Wno-pedantic -mavx2 -mfma -Wno-unused-label 
CFLAGS+= -fsanitize=address -fno-omit-frame-pointer # for address sanitizer
CFLAGS+= -fsanitize=undefined
CFLAGS+= -Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith
CFLAGS+= -Wmissing-declarations -Wredundant-decls -Wnested-externs
CFLAGS+= -Wshadow -Wcast-qual -Wcast-align -Wwrite-strings
CFLAGS+= -Wold-style-definition
CFLAGS+= -Wsuggest-attribute=noreturn 
# NOT DOING THIS BECUASE WILL HAVE TO REWRITE TOO MUCH -Wjump-misses-init
# New GCC 6/7 flags:
CFLAGS+= -Wduplicated-cond -Wmisleading-indentation -Wnull-dereference
CFLAGS+= -Wduplicated-branches -Wrestrict

INCS = -I./inc/
all: dt

SRCS = \
       ./src/main.c	\
       ./src/mk_data.c	\
       ./src/pr_data.c	\
       ./src/preproc.c	\
       ./src/preproc_j.c	\
       ./src/split.c

DFLAGS = -g

dt : ./src/*.c  ./inc/*.h 
	gcc ${CFLAGS} ${DFLAGS}  ${SRCS} ${INCS} \
	  -o dt

clean:
	rm -f _* *.o dt

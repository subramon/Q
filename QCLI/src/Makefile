CFLAGS := -g 
CFLAGS := -g -O0 # optimizations cause buffer overflow on maas
# CFLAGS := -O4

CFLAGS += -DDEBUG

CFLAGS += -fopenmp
CFLAGS += -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align 
CFLAGS += -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings 
CFLAGS += -Wunused-variable -Wunused-parameter 
CFLAGS += -Wstrict-prototypes -Wmissing-prototypes -Wpointer-arith 
CFLAGS += -Wmissing-declarations -Wredundant-decls -Wnested-externs 
CFLAGS += -Wshadow -Wcast-qual -Wcast-align -Wwrite-strings 
CFLAGS += -Wold-style-definition 
CFLAGS += -Wattributes
CFLAGS += -Wunused-label 
CFLAGS += -Wnull-dereference 
CFLAGS += -Wpedantic 
CFLAGS += -Wuninitialized
#---------------
CFLAGS += -Wno-incompatible-pointer-types
CFLAGS += -Wno-cast-align
CFLAGS += -Wno-aggregate-return
# CFLAGS += -Wno-discarded-qualifiers
CFLAGS += -Wno-ignored-qualifiers
# not for mac CFLAGS += -Wsuggest-attribute=noreturn -Wduplicated-cond 
# not for mac CFLAGS += -Wmisleading-indentation 
# not for mac CFLAGS += -Wduplicated-branches -Wrestrict
# to use address sanitizer
# CFLAGS += -fsanitize=address -fno-omit-frame-pointer 
# CFLAGS += -fsanitize=undefined 
# CFLAGS +=  -static-libasan # for address sanitizer
# Got following error when I put static-libasan at end of LIBS
# ==1645146==Your application is linked against incompatible ASan runtimes.
# Something to do with order of linking???
#
INCS := -I. # for globals.h 
INCS += -I../inc/ 
INCS += -I../../UTILS/inc/ 

LIBS := -lm 
LIBS += -lpthread 
LIBS += -levent 
LIBS += -lcurl 
LIBS += -lreadline
LIBS += /usr/local/lib/libluajit-5.1.so

all : qcli

.c.o :
	$(CC) -c -o $@ $< $(CFLAGS)  $(INCS)

clean:
	rm -f *.o qcli

QCLI_SRC   := qcli.c
QCLI_SRC   += rconnect.c
QCLI_SRC   += setup_curl.c
QCLI_SRC   += ../../UTILS/src/file_exists.c
QCLI_SRC   += ../../UTILS/src/rs_mmap.c
QCLI_OBJ = $(QCLI_SRC:.c=.o)


qcli: ${QCLI_OBJ} 
	gcc ${CFLAGS} ${QCLI_OBJ} -o qcli  ${LIBS}


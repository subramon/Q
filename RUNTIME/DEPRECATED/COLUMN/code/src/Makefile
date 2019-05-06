.DEFAULT_GOAL := all
INC_DIR = ../gen_inc/
CC = gcc
CFLAGS = ${QC_FLAGS} -I$(INC_DIR)
LFLAGS = -shared
RM = rm -f
SOURCE_FILES = $(wildcard *.c)
#CORESO := $(patsubst %.c,%.so,$(SOURCE_FILES))
OBJECTS := $(patsubst %.c,%.o,$(SOURCE_FILES))
CORE_SO = libvector_map.so 

$(OBJECTS): %.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@

libvector_map.so: $(OBJECTS)
	#bash gen_files.sh
	$(CC) -shared -o libvector_mmap.so vector_mmap.o vector_munmap.o bitops.o

all: $(CORE_SO)
	rm $(OBJECTS)
	echo "done"

clean:
	$(RM) $(CORESO) $(OBJECTS)
	rm -f *.o *.so


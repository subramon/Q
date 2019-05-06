.DEFAULT_GOAL := all
INC_DIR = ../gen_inc/
CC = gcc
# CFLAGS = -fPIC -std=gnu99 -I$(INC_DIR)
CFLAGS = ${QC_FLAGS}
DATA_DIR = ${Q_DATA_DIR}
LFLAGS = -shared
RM = rm -f
SOURCE_FILES = $(wildcard *.c)
#CORESO := $(patsubst %.c,%.so,$(SOURCE_FILES))
OBJECTS := $(patsubst %.c,%.o,$(SOURCE_FILES))


#%.so: ./%.c
#	$(CC) -o $@ $< $(CFLAGS)

#%.o: %c
#	$(CC) -c $(CFLAGS) $< -o $@

$(OBJECTS): %.o: %.c
	$(CC) -c $(QC_FLAGS) $< -o $@

../src/libvector_map.so: $(OBJECTS)
	cd ../src/
	#make

libprint.so: $(OBJECTS)
	$(CC) -shared -o libprint.so print.o

all: 
	rm -f $(OBJECTS)
	echo "Now testing c function calls"
	$(CC) $(QC_FLAGS) driver.c -o driver 
	./driver > /dev/null
	# $(CC) `pwd`/../src/vector_mmap.c `pwd`/../src/vector_munmap.c -DTEST -I$(INC_DIR) -o vec
	cp test.txt ${DATA_DIR}/test1.txt
	cp test.txt ${DATA_DIR}/test2.txt
	cp test.txt ${DATA_DIR}/test1.txt_nn
	echo "Now testing lua bindings"
	export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:./"
	luajit testVector.lua
	echo "hello"
	luajit testSave.lua
	#rm -f ./*.txt *_nn _* driver bit vec libprint.so
	#rm -f ${Q_DATA_DIR}/_* ${Q_METADATA_DIR}/_* ${DATA_DIR}/*
clean:
	$(RM) $(CORESO) $(OBJECTS)

